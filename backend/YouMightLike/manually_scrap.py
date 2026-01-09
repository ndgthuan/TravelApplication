# -*- coding: utf-8 -*-
"""
Manual 'You Might Like' Generator
Scraps Top 10 places based on manual Keyword + Location input using Apify.
"""

import asyncio
import aiohttp
import aiofiles
import json
import re
import unicodedata
import os
from typing import List, Dict

# --- CONFIGURATION ---
from dotenv import load_dotenv
from pathlib import Path

async def download_image(session: aiohttp.ClientSession, url: str, save_path: str):
    """Download một ảnh từ URL và lưu vào save_path"""
    try:
        async with session.get(url) as response:
            if response.status == 200:
                # Dùng aiofiles để ghi file async
                async with aiofiles.open(save_path, 'wb') as f:
                    await f.write(await response.read())
                print(f"DOWNLOADED: {save_path}")
            else:
                print(f"DOWNLOAD FAIL: {response.status}")
    except Exception as e:
        print(f"ERROR: {e}")

async def download_all_images(places: List[Dict], output_folder: str):
    """Download tất cả ảnh từ list places, đặt tên theo index"""
    # Tạo thư mục nếu chưa có
    os.makedirs(output_folder, exist_ok=True)
    
    async with aiohttp.ClientSession() as session:
        tasks = []
        for index, place in enumerate(places):
            image_url = place.get('imageUrl', '')
            if image_url:
                # Tên file: 0.jpg, 1.jpg, 2.jpg...
                filename = f"{index}.jpg"
                save_path = os.path.join(output_folder, filename)
                tasks.append(download_image(session, image_url, save_path))
        
        # Download song song tất cả ảnh
        await asyncio.gather(*tasks)

# Load .env from project root (TravelApplication/.env)
env_path = Path(__file__).resolve().parent.parent.parent / '.env'
load_dotenv(env_path)

APIFY_TOKEN = os.getenv('APIFY_TOKEN', '')  # Load from .env
ACTOR_ID = "nwua9Gu5YrADL7ZDj" # Google Maps Scraper Actor ID
# Đường dẫn tương đối đến thư mục data
OUTPUT_FILE = Path(__file__).resolve().parent.parent.parent / 'lib' / 'assets' / 'data' / 'daily_recommendations.json'


class ApifyScraper:
    def __init__(self, api_token: str):
        self.api_token = api_token
        self.base_url = "https://api.apify.com/v2"
    
    async def scrape_top_10(self, keyword: str, location: str) -> List[Dict]:
        search_query = f"{keyword} in {location}"
        print(f"\nStarting scrape for: {search_query}")
        
        # 1. Start the scraping job
        run_id = await self._start_actor(search_query)
        
        # 2. Wait for it to finish
        print(f"Waiting for Apify (Run ID: {run_id})...")
        await self._wait_for_completion(run_id)
        
        # 3. Get and process results
        print("Fetching results...")
        places = await self._get_results(run_id)
        
        print(f"Found {len(places)} places for '{search_query}'")
        return places

    async def _start_actor(self, query: str) -> str:
        url = f"{self.base_url}/acts/{self.actor_id}/runs?token={self.api_token}"
        # Cấu hình input tối ưu cho Top 10
        input_data = {
            "searchStringsArray": [query],
            "maxCrawledPlacesPerSearch": 10, # CHỈ LẤY TOP 10
            "language": "en",
            "countryCode": "vn",
            "locationQuery": "Vietnam",
            "maxReviews": 0,    # Không lấy review text
            "maxImages": 1,     # Chỉ lấy 1 ảnh
            "scrapeDirectionUrl": False,
            "exportPlaceUrls": False
        }
        async with aiohttp.ClientSession() as session:
            async with session.post(url, json=input_data) as response:
                if response.status not in [200, 201]:
                    raise Exception(f"Failed to start: {await response.text()}")
                data = await response.json()
                return data['data']['id']

    async def _wait_for_completion(self, run_id: str):
        url = f"{self.base_url}/actor-runs/{run_id}?token={self.api_token}"
        async with aiohttp.ClientSession() as session:
            while True:
                async with session.get(url) as response:
                    data = await response.json()
                    status = data['data']['status']
                    if status == 'SUCCEEDED': return
                    elif status in ['FAILED', 'ABORTED']: raise Exception(f"Run {status}")
                    await asyncio.sleep(3) # Check mỗi 3 giây

    async def _get_results(self, run_id: str) -> List[Dict]:
        url = f"{self.base_url}/actor-runs/{run_id}/dataset/items?token={self.api_token}"
        async with aiohttp.ClientSession() as session:
            async with session.get(url) as response:
                if response.status != 200: return []
                raw_data = await response.json()
                return [self._transform_place(p) for p in raw_data]

    def _transform_place(self, item: Dict) -> Dict:
        # 1. Clean Name (Remove Accents)
        raw_name = item.get('title', '')
        name = self._remove_accents(raw_name)

        # 2. Clean Address (Standardize)
        raw_address = item.get('address', '')
        if not raw_address:
             parts = [item.get('street'), item.get('city'), item.get('countryCode')]
             raw_address = ", ".join([p for p in parts if p])
        address = self._clean_address(raw_address)

        # 3. Image URL (High Res)
        image_url = ''
        if item.get('imageUrls'):
            # Resize image url
            image_url = item['imageUrls'][0].split('=')[0] + '=w400-h400-k-no'

        # 4. Category
        category = item.get('categoryName', '')
        if not category and item.get('categories'):
             category = item['categories'][0]

        # Trả về đúng các field bạn yêu cầu
        return {
            "name": name,
            "address": address,
            "latitude": item.get('location', {}).get('lat'),
            "longitude": item.get('location', {}).get('lng'),
            "rating": item.get('totalScore'), 
            "category": category,
            "imageUrl": image_url
        }

    # --- HELPER FUNCTIONS ---
    def _remove_accents(self, input_str: str) -> str:
        if not input_str: return ""
        nfkd = unicodedata.normalize('NFKD', input_str)
        return "".join([c for c in nfkd if not unicodedata.combining(c)]).replace('đ', 'd').replace('Đ', 'D')

    def _clean_address(self, address: str) -> str:
        if not address: return ""
        address = re.sub(r'\b\d{5,6}\b', '', address) # Remove postcodes
        address = self._remove_accents(address) 
        
        parts = [p.strip() for p in address.split(',')]
        clean_parts = []
        for p in parts:
            if re.match(r'^[A-Z0-9]{2,8}\+[A-Z0-9]{2,}', p): continue # Remove Plus Codes
            if "+" in p: continue 

            p = p.replace("Thanh pho", "City").replace("Quan", "District").replace("Phuong", "Ward").replace("Duong", "St")
            clean_parts.append(p)
            
        return ", ".join(clean_parts).replace("City Ho Chi Minh City", "Ho Chi Minh City")

    @property
    def actor_id(self):
        return ACTOR_ID

# --- MAIN EXECUTION ---
async def main():
    print("--- MANUAL 'YOU MIGHT LIKE' GENERATOR ---")
    
    keyword = input("Enter Keyword (e.g., Coffee, Pho): ").strip()
    if not keyword: keyword = "Coffee"
    
    location = input("Enter Location (e.g., Hanoi, District 1): ").strip()
    if not location: location = "Hanoi"

    scraper = ApifyScraper(APIFY_TOKEN)
    results = await scraper.scrape_top_10(keyword, location)

    if results:
        final_data = {
            "metadata": {
                "user_context": {
                    "search_keyword": keyword,
                    "search_location": location
                },
                "generated_at": "Batch Job (Simulated)"
            },
            "recommendations": results
        }
        
        with open(OUTPUT_FILE, 'w', encoding='utf-8') as f:
            json.dump(final_data, f, ensure_ascii=False, indent=2)
            
        print(f"\nDone! Saved {len(results)} places to '{OUTPUT_FILE}'.")
        print("You can open this file to check the JSON structure.")
        script_dir = Path(__file__).resolve().parent
        images_folder = script_dir.parent.parent / 'lib' / 'assets' / 'images' / 'destination' / 'recommend'

        await download_all_images(results, str(images_folder))
    else:
        print("\nNo results found. Try another keyword.")

if __name__ == '__main__':
    if os.name == 'nt':
        asyncio.set_event_loop_policy(asyncio.WindowsSelectorEventLoopPolicy())
    asyncio.run(main())