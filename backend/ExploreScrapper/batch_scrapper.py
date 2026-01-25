# -*- coding: utf-8 -*-
import asyncio
import os
import sys
from explore_scrapper import ApifyGoogleMapsScraper, save_to_json

API_TOKENS = [
    "apify_api_hmL1M0rA4tI2AmllBnvWBR1MU6niu026kBJy",
    "apify_api_i5sxpWYasepA0z60XDN7gj1v7bZSTu3LLWFl",
    "apify_api_0YaxjGbdgKjiLvfTiGsTHKl0HRJpb40rWQFk",
    "apify_api_tNO88dS3xvc0Td6H6e8e5obPoXUi7o4eCKMu",
    "apify_api_XwPr3Ygd97xrCHCX5DKeRWrnMg2gLx2goDMk",
]

PROVINCES = [
    "Bac Lieu", "Ca Mau"
]

# Các danh mục cần tìm kiếm
CATEGORIES = [
    "Hotels",
    "Restaurants",
    "Coffee Shops",
    "Tourist Attractions",
    "Shopping Malls", 
    "Night Market"
]

CURRENT_DIR = os.path.dirname(os.path.abspath(__file__))
OUTPUT_FILE = os.path.join(CURRENT_DIR, "../../lib/assets/data/explore_destinations.json")
OUTPUT_FILE = os.path.normpath(OUTPUT_FILE)
MAX_RESULTS = 20

async def batch_process(tokens):
    if not tokens:
        print("No tokens provided!")
        return

    current_token_index = 0
    current_token = tokens[current_token_index]
    scraper = ApifyGoogleMapsScraper(api_token=current_token)

    total_provinces = len(PROVINCES)
    
    # Duyệt qua từng tỉnh
    for p_idx, province in enumerate(PROVINCES):
        print(f"\n==================================================")
        print(f"[{p_idx+1}/{total_provinces}] PROCESSING PROVINCE: {province}")
        print(f"==================================================")

        # Duyệt qua từng category của tỉnh đó
        for category in CATEGORIES:
            query = f"{category} in {province}, Vietnam"
            print(f"\n---> Searching: {query}")

            while True:
                try:
                    # Cập nhật token hiện tại cho scraper (quan trọng khi vừa đổi key)
                    scraper.api_token = current_token
                    print(f"   (Using Token #{current_token_index + 1}: ...{current_token[-5:]})")
                    
                    # Gọi hàm scrape
                    places = await scraper.scrape(query=query, max_results=MAX_RESULTS)
                    
                    if places:
                        # Lưu ngay vào file (Append mode)
                        save_to_json(places, OUTPUT_FILE, append=True)
                        print(f"Saved {len(places)} places for '{query}'")
                    else:
                        print(f"No results for '{query}'")
                    
                    # Thành công thì break vòng lặp while để sang category tiếp theo
                    break 

                except Exception as e:
                    error_msg = str(e).lower()
                    print(f"\n[!] ERROR encountered: {e}")

                    # Kiểm tra xem có phải lỗi hết quota/limit không
                    if "401" in error_msg or "403" in error_msg or "402" in error_msg or "429" in error_msg or "run failed" in error_msg:
                        print("\n" + "!"*50)
                        print(f"TOKEN #{current_token_index + 1} EXHAUSTED OR FAILED!")
                        
                        # Logic đổi key tự động
                        if current_token_index + 1 < len(tokens):
                            current_token_index += 1
                            current_token = tokens[current_token_index]
                            print(f"SWITCHING TO TOKEN #{current_token_index + 1}...")
                            print("!"*50 + "\n")
                            # Continue để retry lại query này với token mới ngay lập tức
                            continue 
                        else:
                            print("ALL TOKENS EXHAUSTED! CANNOT CONTINUE.")
                            print("!"*50)
                            sys.exit(1) # Dừng chương trình
                    else:
                        # Lỗi khác (vd mạng, code...) thì skip query này để chạy cái tiếp theo
                        print("Unknown error, skipping this query...")
                        break

if __name__ == "__main__":
    # Chỉ cần chạy thẳng với list tokens đã khai báo ở trên
    print(f"Loaded {len(API_TOKENS)} API tokens.")
    asyncio.run(batch_process(API_TOKENS))
