"""
Script để normalize categories trong file explore_destinations.json
Quy về 6 loại chuẩn: Hotel, Restaurant, Cafe, Attraction, Malls, Market
"""

import json

# Đường dẫn file
INPUT_FILE = "../../lib/assets/data/explore_destinations.json"
OUTPUT_FILE = "../../lib/assets/data/explore_destinations.json"  # Ghi đè luôn

# Mapping từ category gốc sang 6 loại chuẩn (tên ngắn gọn)
CATEGORY_MAPPING = {
    # Hotel
    "hotel": "Hotel",
    "hotels": "Hotel",
    "resort": "Hotel",
    "hostel": "Hotel",
    "motel": "Hotel",
    "guest house": "Hotel",
    "lodging": "Hotel",
    "inn": "Hotel",
    "bed and breakfast": "Hotel",
    
    # Restaurant
    "restaurant": "Restaurant",
    "restaurants": "Restaurant",
    "vietnamese restaurant": "Restaurant",
    "seafood restaurant": "Restaurant",
    "asian restaurant": "Restaurant",
    "japanese restaurant": "Restaurant",
    "korean restaurant": "Restaurant",
    "chinese restaurant": "Restaurant",
    "italian restaurant": "Restaurant",
    "french restaurant": "Restaurant",
    "fast food restaurant": "Restaurant",
    "buffet restaurant": "Restaurant",
    "vegetarian restaurant": "Restaurant",
    "vegan restaurant": "Restaurant",
    "bbq restaurant": "Restaurant",
    "noodle shop": "Restaurant",
    "pho restaurant": "Restaurant",
    "food court": "Restaurant",
    
    # Cafe
    "coffee shop": "Cafe",
    "coffee shops": "Cafe",
    "cafe": "Cafe",
    "coffee": "Cafe",
    "tea house": "Cafe",
    "bakery": "Cafe",
    "dessert shop": "Cafe",
    "juice bar": "Cafe",
    "bubble tea store": "Cafe",
    
    # Attraction
    "tourist attraction": "Attraction",
    "tourist attractions": "Attraction",
    "museum": "Attraction",
    "art museum": "Attraction",
    "history museum": "Attraction",
    "temple": "Attraction",
    "pagoda": "Attraction",
    "church": "Attraction",
    "cathedral": "Attraction",
    "place of worship": "Attraction",
    "park": "Attraction",
    "national park": "Attraction",
    "zoo": "Attraction",
    "aquarium": "Attraction",
    "botanical garden": "Attraction",
    "beach": "Attraction",
    "landmark": "Attraction",
    "monument": "Attraction",
    "historical place": "Attraction",
    "scenic spot": "Attraction",
    "viewpoint": "Attraction",
    "amusement park": "Attraction",
    "water park": "Attraction",
    "theater": "Attraction",
    "opera house": "Attraction",
    "cultural center": "Attraction",
    
    # Malls
    "shopping mall": "Malls",
    "shopping malls": "Malls",
    "shopping center": "Malls",
    "department store": "Malls",
    "supermarket": "Malls",
    "convenience store": "Malls",
    "store": "Malls",
    "boutique": "Malls",
    
    # Market
    "night market": "Market",
    "market": "Market",
    "street food": "Market",
    "food stall": "Market",
    "bar": "Market",
    "pub": "Market",
    "nightclub": "Market",
    "karaoke": "Market",
    "lounge": "Market",
    "shop": "Market",
}

def normalize_category(original_category):
    """Chuyển đổi category gốc sang 6 loại chuẩn"""
    if not original_category:
        return "Attraction"  # Default
    
    # Chuyển về lowercase để so sánh
    category_lower = original_category.lower().strip()
    
    # Tìm trong mapping (exact match trước)
    if category_lower in CATEGORY_MAPPING:
        return CATEGORY_MAPPING[category_lower]
    
    # Tìm trong mapping (partial match)
    for key, value in CATEGORY_MAPPING.items():
        if key in category_lower or category_lower in key:
            return value
    
    # Nếu không tìm thấy, phân loại dựa trên từ khóa
    if "hotel" in category_lower or "resort" in category_lower:
        return "Hotel"
    elif "restaurant" in category_lower or "food" in category_lower:
        return "Restaurant"
    elif "coffee" in category_lower or "cafe" in category_lower or "tea" in category_lower:
        return "Cafe"
    elif "mall" in category_lower or "store" in category_lower:
        return "Malls"
    elif "market" in category_lower or "shop" in category_lower or "bar" in category_lower or "night" in category_lower or "pub" in category_lower:
        return "Market"
    else:
        return "Attraction"  # Default cho các loại khác

def main():
    print("🔄 Đang đọc file JSON...")
    
    # Đọc file
    with open(INPUT_FILE, 'r', encoding='utf-8') as f:
        data = json.load(f)
    
    print(f"📊 Tổng số địa điểm: {len(data)}")
    
    # Thống kê categories trước khi normalize
    original_categories = {}
    for item in data:
        cat = item.get('category', 'Unknown')
        original_categories[cat] = original_categories.get(cat, 0) + 1
    
    print("\n📋 Categories GỐC:")
    for cat, count in sorted(original_categories.items(), key=lambda x: -x[1]):
        print(f"  - {cat}: {count}")
    
    # Normalize
    print("\n🔄 Đang normalize categories...")
    for item in data:
        original = item.get('category', '')
        item['category'] = normalize_category(original)
    
    # Thống kê sau khi normalize
    normalized_categories = {}
    for item in data:
        cat = item.get('category', 'Unknown')
        normalized_categories[cat] = normalized_categories.get(cat, 0) + 1
    
    print("\n✅ Categories SAU KHI NORMALIZE:")
    for cat, count in sorted(normalized_categories.items(), key=lambda x: -x[1]):
        print(f"  - {cat}: {count}")
    
    # Ghi file
    print(f"\n💾 Đang ghi file {OUTPUT_FILE}...")
    with open(OUTPUT_FILE, 'w', encoding='utf-8') as f:
        json.dump(data, f, ensure_ascii=False, indent=2)
    
    print("✅ Hoàn thành!")

if __name__ == "__main__":
    main()
