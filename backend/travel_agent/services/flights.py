"""
Amadeus Flight Offers Search - lấy dữ liệu chuyến bay thực tế.
Dùng OAuth2 client_credentials và Flight Offers Search API v2.
"""
import os
import re
import requests
from typing import List, Dict, Any, Optional
from datetime import datetime

# Map tên thành phố phổ biến (VN + quốc tế) sang IATA
CITY_TO_IATA = {
    # Vietnam
    "sài gòn": "SGN", "saigon": "SGN", "hồ chí minh": "SGN", "ho chi minh": "SGN",
    "hcm": "SGN", "tp hcm": "SGN", "tân sơn nhất": "SGN",
    "hà nội": "HAN", "hanoi": "HAN", "nội bài": "HAN",
    "đà nẵng": "DAD", "da nang": "DAD",
    "nha trang": "CXR",
    "phú quốc": "PQC", "phu quoc": "PQC",
    "đà lạt": "DLI", "da lat": "DLI", "dalat": "DLI",
    "cần thơ": "VCA", "can tho": "VCA",
    "huế": "HUI", "hue": "HUI",
    "hai phong": "HPH", "hải phòng": "HPH",
    # Asia
    "bangkok": "BKK", "singapore": "SIN", "singapore city": "SIN",
    "tokyo": "NRT", "osaka": "KIX", "seoul": "ICN",
    "hong kong": "HKG", "taipei": "TPE", "kuala lumpur": "KUL",
    "jakarta": "CGK", "manila": "MNL",
    # Europe
    "paris": "CDG", "london": "LHR", "frankfurt": "FRA",
    "amsterdam": "AMS", "rome": "FCO", "madrid": "MAD",
}


def _normalize_city(text: str) -> str:
    """Chuẩn hóa tên thành phố để tra IATA."""
    if not text:
        return ""
    s = text.lower().strip()
    s = re.sub(r"[àáạảãâầấậẩẫăằắặẳẵ]", "a", s)
    s = re.sub(r"[èéẹẻẽêềếệểễ]", "e", s)
    s = re.sub(r"[ìíịỉĩ]", "i", s)
    s = re.sub(r"[òóọỏõôồốộổỗơờớợởỡ]", "o", s)
    s = re.sub(r"[ùúụủũưừứựửữ]", "u", s)
    s = re.sub(r"[ỳýỵỷỹ]", "y", s)
    s = re.sub(r"[đ]", "d", s)
    return s


def city_to_iata(city_name: str) -> Optional[str]:
    """
    Chuyển tên thành phố sang mã IATA (3 chữ).
    Nếu city_name đã là mã IATA (3 chữ, viết hoa) thì trả về luôn.
    """
    if not city_name or len(city_name.strip()) < 2:
        return None
    s = city_name.strip().upper()
    if len(s) == 3 and s.isalpha():
        return s
    normalized = _normalize_city(city_name)
    return CITY_TO_IATA.get(normalized)


def get_amadeus_token() -> Optional[str]:
    """
    Lấy access token từ Amadeus OAuth2 (client_credentials).
    Token có hiệu lực ~30 phút.
    """
    api_key = os.getenv("AMADEUS_API_KEY")
    api_secret = os.getenv("AMADEUS_API_SECRET")
    base_url = os.getenv("AMADEUS_BASE_URL", "https://test.api.amadeus.com").rstrip("/")

    if not api_key or not api_secret:
        return None

    url = f"{base_url}/v1/security/oauth2/token"
    headers = {"Content-Type": "application/x-www-form-urlencoded"}
    data = f"grant_type=client_credentials&client_id={api_key}&client_secret={api_secret}"

    try:
        resp = requests.post(url, headers=headers, data=data, timeout=15)
        resp.raise_for_status()
        return resp.json().get("access_token")
    except Exception as e:
        print(f"AMADEUS_TOKEN_ERROR: {e}")
        return None


def search_flights_raw(
    origin: str,
    destination: str,
    departure_date: str,
    adults: int = 1,
    max_results: int = 5,
) -> tuple[Optional[List[Dict[str, Any]]], Optional[Dict]]:
    """
    Gọi Amadeus trực tiếp, trả về (offers đã format, raw_response để debug).
    """
    token = get_amadeus_token()
    if not token:
        return [], {"error": "No token", "hint": "Check AMADEUS_API_KEY and AMADEUS_API_SECRET"}

    origin_code = city_to_iata(origin) or (origin.upper() if len(origin.strip()) == 3 else None)
    dest_code = city_to_iata(destination) or (destination.upper() if len(destination.strip()) == 3 else None)
    if not origin_code or not dest_code:
        return [], {"error": "Invalid origin/destination", "origin_code": origin_code, "dest_code": dest_code}

    base_url = os.getenv("AMADEUS_BASE_URL", "https://test.api.amadeus.com").rstrip("/")
    url = f"{base_url}/v2/shopping/flight-offers"
    headers = {"Authorization": f"Bearer {token}"}
    params = {
        "originLocationCode": origin_code,
        "destinationLocationCode": dest_code,
        "departureDate": departure_date,
        "adults": adults,
        "max": max_results,
    }
    try:
        resp = requests.get(url, headers=headers, params=params, timeout=15)
        data = resp.json()
        offers = data.get("data") or []
        raw = {"status_code": resp.status_code, "keys": list(data.keys()), "data_count": len(offers)}
        if data.get("errors"):
            raw["errors"] = data["errors"]
        if data.get("meta"):
            raw["meta"] = data["meta"]
        return _format_offers(offers), raw
    except Exception as e:
        return [], {"error": str(e)}


def search_flights(
    origin: str,
    destination: str,
    departure_date: str,
    adults: int = 1,
    max_results: int = 5,
) -> List[Dict[str, Any]]:
    """Tìm chuyến bay qua Amadeus. Trả về danh sách offers đã format."""
    offers, _ = search_flights_raw(origin, destination, departure_date, adults, max_results)
    return offers


def _format_offers(offers: List[Dict]) -> List[Dict[str, Any]]:
    """Format Amadeus response thành cấu trúc đơn giản dùng trong plan."""
    result = []
    for o in offers:
        itineraries = o.get("itineraries") or []
        if not itineraries:
            continue
        first = itineraries[0]
        segments = first.get("segments") or []
        if not segments:
            continue
        dep_seg = segments[0]
        arr_seg = segments[-1]
        dep_time = dep_seg.get("departure", {}).get("at", "")[:16].replace("T", " ")
        arr_time = arr_seg.get("arrival", {}).get("at", "")[:16].replace("T", " ")
        duration = first.get("duration", "").replace("PT", "").lower()
        carriers = o.get("travelerPricings", [{}])[0].get("fareDetailsBySegment", [{}])[0]
        price_info = o.get("price") or {}
        total = price_info.get("total", "0")
        currency = price_info.get("currency", "USD")
        airline = dep_seg.get("carrierCode", "") or ""

        result.append({
            "airline": airline,
            "departure_time": dep_time,
            "arrival_time": arr_time,
            "duration": duration,
            "price": total,
            "currency": currency,
            "origin": dep_seg.get("departure", {}).get("iataCode", ""),
            "destination": arr_seg.get("arrival", {}).get("iataCode", ""),
        })
    return result


def format_flight_for_activity(offer: Dict[str, Any]) -> Dict[str, Any]:
    """
    Chuyển 1 flight offer thành cấu trúc activity dùng trong daily_plans.
    """
    dep = offer.get("departure_time", "")[:16]
    arr = offer.get("arrival_time", "")[:16]
    start_time = dep[11:16] if len(dep) >= 16 else "08:00"
    airline = offer.get("airline", "Chuyến bay")
    origin = offer.get("origin", "")
    dest = offer.get("destination", "")
    price = offer.get("price", "0")
    curr = offer.get("currency", "USD")
    duration = offer.get("duration", "")

    title = f"{airline}: {origin} → {dest}"
    desc = f"Khởi hành {dep}, đến {arr}. Thời gian bay: {duration}. Giá ~{price} {curr}"

    return {
        "title": title,
        "description": desc,
        "start_time": start_time,
        "duration_hours": 2,  # placeholder
        "activity_type": "flight",
        "estimated_cost": int(float(price)) if price else 0,
        "location": f"Sân bay {origin} - {dest}",
        "address": f"Chuyến bay {origin}-{dest}",
        "coordinates": "",
        "flight_data": offer,
    }
