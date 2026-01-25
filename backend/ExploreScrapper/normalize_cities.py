"""
Script để normalize city names trong file explore_destinations.json
Quy về 63 tỉnh thành chuẩn của Việt Nam
"""

import json

# Đường dẫn file
INPUT_FILE = "../../lib/assets/data/explore_destinations.json"
OUTPUT_FILE = "../../lib/assets/data/explore_destinations.json"

# 63 tỉnh thành Việt Nam (tên chuẩn)
VIETNAM_PROVINCES = [
    "An Giang", "Bà Rịa - Vũng Tàu", "Bạc Liêu", "Bắc Giang", "Bắc Kạn",
    "Bắc Ninh", "Bến Tre", "Bình Định", "Bình Dương", "Bình Phước",
    "Bình Thuận", "Cà Mau", "Cao Bằng", "Cần Thơ", "Đà Nẵng",
    "Đắk Lắk", "Đắk Nông", "Điện Biên", "Đồng Nai", "Đồng Tháp",
    "Gia Lai", "Hà Giang", "Hà Nam", "Hà Nội", "Hà Tĩnh",
    "Hải Dương", "Hải Phòng", "Hậu Giang", "Hòa Bình", "Hưng Yên",
    "Khánh Hòa", "Kiên Giang", "Kon Tum", "Lai Châu", "Lạng Sơn",
    "Lào Cai", "Lâm Đồng", "Long An", "Nam Định", "Nghệ An",
    "Ninh Bình", "Ninh Thuận", "Phú Thọ", "Phú Yên", "Quảng Bình",
    "Quảng Nam", "Quảng Ngãi", "Quảng Ninh", "Quảng Trị", "Sóc Trăng",
    "Sơn La", "Tây Ninh", "Thái Bình", "Thái Nguyên", "Thanh Hóa",
    "Thừa Thiên Huế", "Tiền Giang", "TP. Hồ Chí Minh", "Trà Vinh", "Tuyên Quang",
    "Vĩnh Long", "Vĩnh Phúc", "Yên Bái"
]

# Mapping từ các biến thể sang tên chuẩn
CITY_MAPPING = {
    # Hà Nội
    "ha noi": "Hà Nội",
    "hanoi": "Hà Nội",
    "hà nội": "Hà Nội",
    
    # TP. Hồ Chí Minh
    "ho chi minh": "TP. Hồ Chí Minh",
    "ho chi minh city": "TP. Hồ Chí Minh",
    "hcm": "TP. Hồ Chí Minh",
    "hồ chí minh": "TP. Hồ Chí Minh",
    "tp ho chi minh": "TP. Hồ Chí Minh",
    "tp. ho chi minh": "TP. Hồ Chí Minh",
    "saigon": "TP. Hồ Chí Minh",
    "sai gon": "TP. Hồ Chí Minh",
    
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
    "binh thuan": "Bình Thuận",
    "bình thuận": "Bình Thuận",
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
    "dong nai": "Đồng Nai",
    "đồng nai": "Đồng Nai",
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

def normalize_city(original_city):
    """Chuyển đổi city name sang tên chuẩn 63 tỉnh thành"""
    if not original_city:
        return "Khác"
    
    # Chuyển về lowercase để so sánh
    city_lower = original_city.lower().strip()
    
    # Tìm trong mapping (exact match)
    if city_lower in CITY_MAPPING:
        return CITY_MAPPING[city_lower]
    
    # Tìm partial match
    for key, value in CITY_MAPPING.items():
        if key in city_lower or city_lower in key:
            return value
    
    # Nếu không tìm thấy, giữ nguyên tên gốc (có thể là tên tiếng Anh)
    return original_city

def main():
    print("🔄 Đang đọc file JSON...")
    
    with open(INPUT_FILE, 'r', encoding='utf-8') as f:
        data = json.load(f)
    
    print(f"📊 Tổng số địa điểm: {len(data)}")
    
    # Thống kê cities trước khi normalize
    original_cities = {}
    for item in data:
        city = item.get('city', 'Unknown')
        original_cities[city] = original_cities.get(city, 0) + 1
    
    print(f"\n📋 Số lượng cities GỐC: {len(original_cities)}")
    print("Top 20 cities:")
    for city, count in sorted(original_cities.items(), key=lambda x: -x[1])[:20]:
        print(f"  - {city}: {count}")
    
    # Normalize
    print("\n🔄 Đang normalize city names...")
    for item in data:
        original = item.get('city', '')
        item['city'] = normalize_city(original)
    
    # Thống kê sau khi normalize
    normalized_cities = {}
    for item in data:
        city = item.get('city', 'Unknown')
        normalized_cities[city] = normalized_cities.get(city, 0) + 1
    
    print(f"\n✅ Số lượng cities SAU KHI NORMALIZE: {len(normalized_cities)}")
    for city, count in sorted(normalized_cities.items(), key=lambda x: -x[1]):
        print(f"  - {city}: {count}")
    
    # Ghi file
    print(f"\n💾 Đang ghi file {OUTPUT_FILE}...")
    with open(OUTPUT_FILE, 'w', encoding='utf-8') as f:
        json.dump(data, f, ensure_ascii=False, indent=2)
    
    print("✅ Hoàn thành!")

if __name__ == "__main__":
    main()
