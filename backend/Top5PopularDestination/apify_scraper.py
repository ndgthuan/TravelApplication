# -*- coding: utf-8 -*-
"""
Google Maps Scraper using Apify API - Optimized for Recommendation System
Output matches 'You Might Like' schema: Name, Address, City (Clean), Country, Lat/Long, Rating, ReviewCount, Category, Image.
"""

import asyncio
import aiohttp
import json
import argparse
import re
import unicodedata
import time
from typing import List, Dict, Tuple

class ApifyGoogleMapsScraper:
    def __init__(self, api_token: str):
        self.api_token = api_token
        self.actor_id = "nwua9Gu5YrADL7ZDj"
        self.base_url = "https://api.apify.com/v2"
    
    async def scrape(self, query: str, max_results: int = 10, language: str = "en") -> List[Dict]:
        print(f"Starting Apify scrape for: {query}")
        run_id = await self._start_actor(query, max_results, language)
        await self._wait_for_completion(run_id)
        places = await self._get_results(run_id)
        print(f"Scraped {len(places)} places")
        return places
    
    async def _start_actor(self, query: str, max_results: int, language: str) -> str:
        url = f"{self.base_url}/acts/{self.actor_id}/runs?token={self.api_token}"
        input_data = {
            "searchStringsArray": [query],
            "maxCrawledPlacesPerSearch": max_results,
            "language": language,
            "countryCode": "vn",
            "locationQuery": "Vietnam",
            "exportPlaceUrls": False,
            "maxReviews": 0, # Vẫn lấy được reviewCount mà không cần lấy nội dung review
            "maxImages": 1,
            "scrapeDirectionUrl": False,
            "includeWebResults": False
        }
        async with aiohttp.ClientSession() as session:
            async with session.post(url, json=input_data) as response:
                if response.status not in [200, 201]:
                    text = await response.text()
                    raise Exception(f"Failed to start actor: {response.status}\n{text}")
                data = await response.json()
                print(f"Run ID: {data['data']['id']}")
                return data['data']['id']
    
    async def _wait_for_completion(self, run_id: str, timeout: int = 300):
        url = f"{self.base_url}/actor-runs/{run_id}?token={self.api_token}"
        start_time = time.time()
        async with aiohttp.ClientSession() as session:
            while True:
                if time.time() - start_time > timeout:
                    raise Exception(f"Timeout waiting for run {run_id}")
                async with session.get(url) as response:
                    data = await response.json()
                    status = data['data']['status']
                    if status == 'SUCCEEDED':
                        print(f"Run completed successfully")
                        return
                    elif status in ['FAILED', 'ABORTED', 'TIMED-OUT']:
                        raise Exception(f"Run {status.lower()}")
                    await asyncio.sleep(3)
    
    async def _get_results(self, run_id: str) -> List[Dict]:
        url = f"{self.base_url}/actor-runs/{run_id}/dataset/items?token={self.api_token}"
        async with aiohttp.ClientSession() as session:
            async with session.get(url) as response:
                if response.status != 200:
                    raise Exception(f"Failed to get results: {response.status}")
                places = await response.json()
                return [self._transform_place(p) for p in places]

    def _remove_accents(self, input_str: str) -> str:
        if not input_str: return ""
        nfkd_form = unicodedata.normalize('NFKD', input_str)
        return "".join([c for c in nfkd_form if not unicodedata.combining(c)]).replace('đ', 'd').replace('Đ', 'D')

    def _parse_address_components(self, address: str) -> Tuple[str, str, str]:
        """
        Returns: (Street Address, City, Country)
        Cleaned: 'Ho Chi Minh City' -> 'Ho Chi Minh'
        """
        if not address: return "", "", ""

        # 1. Clean basics
        address = re.sub(r'\b\d{5,6}\b', '', address)
        address = self._remove_accents(address)

        parts = [p.strip() for p in address.split(',')]
        cleaned_parts = []
        
        replacements = {
            "Thanh pho": "City", "Thi xa": "Town", "Quan": "District",
            "Huyen": "District", "Phuong": "Ward", "Xa": "Commune",
            "Tinh": "Province", "So": "No.", "Lau": "Floor", "Duong": "St"
        }

        for part in parts:
            if not part: continue
            if re.match(r'^[A-Z0-9]{2,8}\+[A-Z0-9]{2,}', part): continue
            if "+" in part: continue

            if part.lower().startswith("duong "):
                part = part[6:].strip() + " St"
            elif re.match(r'^\d+', part) and not re.search(r'\b(St|Street|Rd|Ave|District|Ward)\b', part, re.IGNORECASE):
                 part = f"{part} St"

            for vn, en in replacements.items():
                part = re.sub(r'\b' + vn + r'\b', en, part, flags=re.IGNORECASE)
            
            # Temporary fix for "City Ho Chi Minh City" duplication before splitting
            if "Ho Chi Minh" in part and "City" not in part:
                part = part.replace("Ho Chi Minh", "Ho Chi Minh City")
            
            cleaned_parts.append(part)

        # 2. Logic to Separate City and Country
        country = "Vietnam" 
        city = ""
        street_address = ""

        if not cleaned_parts:
            return "", "", ""

        # Extract Country (Last part)
        if "Vietnam" in cleaned_parts[-1]:
            country = cleaned_parts.pop()
        
        # Extract City (Next last part)
        if cleaned_parts:
            raw_city = cleaned_parts.pop()
            
            # Remove 'City', 'Province', 'Town' from the end
            city = re.sub(r'\s+(City|Province|Town)$', '', raw_city, flags=re.IGNORECASE).strip()

            # Clean up artifacts if any
            if "Ho Chi Minh" in city: city = "Ho Chi Minh"

        # The rest is Street Address
        street_address = ", ".join(cleaned_parts)

        return street_address, city, country

    def _transform_place(self, apify_data: Dict) -> Dict:
        raw_name = apify_data.get('title', '')
        clean_name = self._remove_accents(raw_name)

        image_url = ''
        if apify_data.get('imageUrls') and len(apify_data['imageUrls']) > 0:
            image_url = apify_data['imageUrls'][0]
            if '=' in image_url:
                image_url = image_url.split('=')[0] + '=w800-h600-k-no'
        
        category = ''
        if apify_data.get('categoryName'):
            category = apify_data['categoryName']
        elif apify_data.get('categories'):
            category = apify_data['categories'][0]
        
        raw_address = apify_data.get('address', '')
        if not raw_address:
            parts = [apify_data.get('street'), apify_data.get('city'), apify_data.get('countryCode')]
            raw_address = ', '.join([p for p in parts if p])
        
        street, city, country = self._parse_address_components(raw_address)

        return {
            'name': clean_name,
            'address': street,
            'city': city,       
            'country': country,
            'latitude': apify_data.get('location', {}).get('lat'),
            'longitude': apify_data.get('location', {}).get('lng'),
            'rating': str(apify_data.get('totalScore', '')) if apify_data.get('totalScore') else '',
            'reviewCount': str(apify_data.get('reviewsCount', '')) if apify_data.get('reviewsCount') else '', # Đã thêm lại
            'category': category,
            'imageUrl': image_url
        }

def save_to_json(places: List[Dict], filepath: str):
    with open(filepath, 'w', encoding='utf-8') as f:
        json.dump(places, f, ensure_ascii=False, indent=2)
    print(f"Saved JSON to {filepath}")

async def main():
    parser = argparse.ArgumentParser(description='Google Maps Scraper - Backend')
    parser.add_argument('-q', '--query', required=True, help='Search query')
    parser.add_argument('-n', '--num', type=int, default=10, help='Max results')
    parser.add_argument('-o', '--output', required=True, help='Output filename (auto .json)')
    parser.add_argument('-t', '--token', default='apify_api_aToayaFvYSOoNWcIq9gYPUxdfEv1X32Zfrp2', help='Apify Token')
    
    args = parser.parse_args()
    
    output_file = args.output
    if not output_file.endswith('.json'):
        output_file += '.json'

    print(f"Query: {args.query}")
    
    scraper = ApifyGoogleMapsScraper(api_token=args.token)
    places = await scraper.scrape(query=args.query, max_results=args.num)
    
    if not places:
        print("No results found")
        return
    
    save_to_json(places, output_file)

if __name__ == '__main__':
    asyncio.run(main())