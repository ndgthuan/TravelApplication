"""
Script để clean và normalize city names trong file explore_destinations.json
Loại bỏ các city name không hợp lệ và map về 63 tỉnh thành Việt Nam
"""

import json
import re

# Đường dẫn file
INPUT_FILE = "../../lib/assets/data/explore_destinations.json"
OUTPUT_FILE = "../../lib/assets/data/explore_destinations.json"

# Danh sách city names KHÔNG HỢP LỆ cần xóa hoặc map
INVALID_CITIES = [
    "binh st", "city hai st", "hai st", "st", "street", "road",
    "unamed road", "unnamed road", "island", "east sea", "khác",
    "p.the lu", "p. the lu", "tran thai tong", "phan thiet", "tp. bac", "tp. bien", "tp. soc",
    # Tiếng Trung/Hàn/Nhật
]

# Mapping từ các biến thể sang tên chuẩn
CITY_MAPPING = {
    # Hà Nội
    "ha noi": "Hà Nội",
    "hanoi": "Hà Nội",
    "hà nội": "Hà Nội",
    
    # Hồ Chí Minh
    "ho chi minh": "Hồ Chí Minh",
    "ho chi minh city": "Hồ Chí Minh",
    "hcm": "Hồ Chí Minh",
    "hồ chí minh": "Hồ Chí Minh",
    "tp ho chi minh": "Hồ Chí Minh",
    "tp. ho chi minh": "Hồ Chí Minh",
    "saigon": "Hồ Chí Minh",
    "sai gon": "Hồ Chí Minh",
    
    # Đà Nẵng
    "da nang": "Đà Nẵng",
    "đà nẵng": "Đà Nẵng",
    "danang": "Đà Nẵng",
    
    # Cần Thơ
    "can tho": "Cần Thơ",
    "cần thơ": "Cần Thơ",
    "tp. can tho": "Cần Thơ",
    
    # Hải Phòng
    "hai phong": "Hải Phòng",
    "hải phòng": "Hải Phòng",
    "haiphong": "Hải Phòng",
    
    # Binh Thuan / Phan Thiet
    "phan thiet": "Bình Thuận",
    "binh thuan": "Bình Thuận",
    "bình thuận": "Bình Thuận",
    "mui ne": "Bình Thuận",
    
    # Đồng Nai / Bien Hoa
    "tp. bien hoa": "Đồng Nai",
    "bien hoa": "Đồng Nai",
    "biên hòa": "Đồng Nai",
    "dong nai": "Đồng Nai",
    "đồng nai": "Đồng Nai",
    
    # Các tỉnh khác
    "an giang": "An Giang",
    "ba ria vung tau": "Bà Rịa - Vũng Tàu",
    "ba ria - vung tau": "Bà Rịa - Vũng Tàu",
    "vung tau": "Bà Rịa - Vũng Tàu",
    "bac lieu": "Bạc Liêu",
    "bạc liêu": "Bạc Liêu",
    "bac giang": "Bắc Giang",
    "bắc giang": "Bắc Giang",
    "bac kan": "Bắc Kạn",
    "bắc kạn": "Bắc Kạn",
    "bac ninh": "Bắc Ninh",
    "bắc ninh": "Bắc Ninh",
    "ben tre": "Bến Tre",
    "bến tre": "Bến Tre",
    "binh dinh": "Bình Định",
    "bình định": "Bình Định",
    "binh duong": "Bình Dương",
    "bình dương": "Bình Dương",
    "binh phuoc": "Bình Phước",
    "bình phước": "Bình Phước",
    "ca mau": "Cà Mau",
    "cà mau": "Cà Mau",
    "cao bang": "Cao Bằng",
    "cao bằng": "Cao Bằng",
    "dak lak": "Đắk Lắk",
    "đắk lắk": "Đắk Lắk",
    "daklak": "Đắk Lắk",
    "dak nong": "Đắk Nông",
    "đắk nông": "Đắk Nông",
    "dien bien": "Điện Biên",
    "điện biên": "Điện Biên",
    "dong thap": "Đồng Tháp",
    "đồng tháp": "Đồng Tháp",
    "gia lai": "Gia Lai",
    "ha giang": "Hà Giang",
    "hà giang": "Hà Giang",
    "ha nam": "Hà Nam",
    "hà nam": "Hà Nam",
    "ha tinh": "Hà Tĩnh",
    "hà tĩnh": "Hà Tĩnh",
    "hai duong": "Hải Dương",
    "hải dương": "Hải Dương",
    "hau giang": "Hậu Giang",
    "hậu giang": "Hậu Giang",
    "hoa binh": "Hòa Bình",
    "hòa bình": "Hòa Bình",
    "hung yen": "Hưng Yên",
    "hưng yên": "Hưng Yên",
    "khanh hoa": "Khánh Hòa",
    "khánh hòa": "Khánh Hòa",
    "nha trang": "Khánh Hòa",
    "kien giang": "Kiên Giang",
    "kiên giang": "Kiên Giang",
    "phu quoc": "Kiên Giang",
    "kon tum": "Kon Tum",
    "lai chau": "Lai Châu",
    "lai châu": "Lai Châu",
    "lang son": "Lạng Sơn",
    "lạng sơn": "Lạng Sơn",
    "lao cai": "Lào Cai",
    "lào cai": "Lào Cai",
    "sapa": "Lào Cai",
    "sa pa": "Lào Cai",
    "lam dong": "Lâm Đồng",
    "lâm đồng": "Lâm Đồng",
    "da lat": "Lâm Đồng",
    "dalat": "Lâm Đồng",
    "long an": "Long An",
    "nam dinh": "Nam Định",
    "nam định": "Nam Định",
    "nghe an": "Nghệ An",
    "nghệ an": "Nghệ An",
    "ninh binh": "Ninh Bình",
    "ninh bình": "Ninh Bình",
    "ninh thuan": "Ninh Thuận",
    "ninh thuận": "Ninh Thuận",
    "phu tho": "Phú Thọ",
    "phú thọ": "Phú Thọ",
    "phu yen": "Phú Yên",
    "phú yên": "Phú Yên",
    "quang binh": "Quảng Bình",
    "quảng bình": "Quảng Bình",
    "quang nam": "Quảng Nam",
    "quảng nam": "Quảng Nam",
    "hoi an": "Quảng Nam",
    "quang ngai": "Quảng Ngãi",
    "quảng ngãi": "Quảng Ngãi",
    "quang ninh": "Quảng Ninh",
    "quảng ninh": "Quảng Ninh",
    "ha long": "Quảng Ninh",
    "quang tri": "Quảng Trị",
    "quảng trị": "Quảng Trị",
    "soc trang": "Sóc Trăng",
    "sóc trăng": "Sóc Trăng",
    "tp. soc trang": "Sóc Trăng",
    "son la": "Sơn La",
    "sơn la": "Sơn La",
    "tay ninh": "Tây Ninh",
    "tây ninh": "Tây Ninh",
    "thai binh": "Thái Bình",
    "thái bình": "Thái Bình",
    "thai nguyen": "Thái Nguyên",
    "thái nguyên": "Thái Nguyên",
    "thanh hoa": "Thanh Hóa",
    "thanh hóa": "Thanh Hóa",
    "thua thien hue": "Thừa Thiên Huế",
    "thừa thiên huế": "Thừa Thiên Huế",
    "hue": "Thừa Thiên Huế",
    "huế": "Thừa Thiên Huế",
    "tien giang": "Tiền Giang",
    "tiền giang": "Tiền Giang",
    "tra vinh": "Trà Vinh",
    "trà vinh": "Trà Vinh",
    "tuyen quang": "Tuyên Quang",
    "tuyên quang": "Tuyên Quang",
    "vinh long": "Vĩnh Long",
    "vĩnh long": "Vĩnh Long",
    "vinh phuc": "Vĩnh Phúc",
    "vĩnh phúc": "Vĩnh Phúc",
    "yen bai": "Yên Bái",
    "yên bái": "Yên Bái",
}

def is_valid_city(city):
    """Kiểm tra city name có hợp lệ không"""
    if not city or len(city) < 2:
        return False
    
    city_lower = city.lower().strip()
    
    # Kiểm tra trong danh sách không hợp lệ
    for invalid in INVALID_CITIES:
        if invalid in city_lower or city_lower == invalid:
            return False
    
    # Kiểm tra ký tự không phải latin (Tiếng Trung, Hàn, Nhật, v.v.)
    # Chỉ cho phép chữ latin, dấu tiếng Việt, số, và một số ký tự đặc biệt
    vietnamese_pattern = re.compile(r'^[a-zA-ZÀ-ỹ0-9\s\-\.\,]+$')
    if not vietnamese_pattern.match(city):
        return False
    
    return True

def normalize_city(original_city):
    """Chuyển đổi city name sang tên chuẩn 63 tỉnh thành"""
    if not original_city or not is_valid_city(original_city):
        return None  # Invalid city
    
    city_lower = original_city.lower().strip()
    
    # Tìm trong mapping (exact match)
    if city_lower in CITY_MAPPING:
        return CITY_MAPPING[city_lower]
    
    # Tìm partial match
    for key, value in CITY_MAPPING.items():
        if key in city_lower or city_lower in key:
            return value
    
    # Nếu city name đã hợp lệ, trả về nguyên bản
    return original_city

def main():
    print("🔄 Đang đọc file JSON...")
    
    with open(INPUT_FILE, 'r', encoding='utf-8') as f:
        data = json.load(f)
    
    print(f"📊 Tổng số địa điểm ban đầu: {len(data)}")
    
    # Thống kê cities không hợp lệ
    invalid_count = 0
    invalid_cities = set()
    
    valid_data = []
    for item in data:
        original_city = item.get('city', '')
        normalized = normalize_city(original_city)
        
        if normalized is None:
            invalid_count += 1
            invalid_cities.add(original_city)
        else:
            item['city'] = normalized
            valid_data.append(item)
    
    print(f"\n❌ Số địa điểm bị loại (city không hợp lệ): {invalid_count}")
    print("Cities không hợp lệ:")
    for city in sorted(invalid_cities):
        print(f"  - '{city}'")
    
    # Thống kê sau khi clean
    normalized_cities = {}
    for item in valid_data:
        city = item.get('city', 'Unknown')
        normalized_cities[city] = normalized_cities.get(city, 0) + 1
    
    print(f"\n✅ Số địa điểm còn lại: {len(valid_data)}")
    print(f"📋 Số lượng cities: {len(normalized_cities)}")
    
    # Ghi file
    print(f"\n💾 Đang ghi file {OUTPUT_FILE}...")
    with open(OUTPUT_FILE, 'w', encoding='utf-8') as f:
        json.dump(valid_data, f, ensure_ascii=False, indent=2)
    
    print("✅ Hoàn thành!")

if __name__ == "__main__":
    main()
