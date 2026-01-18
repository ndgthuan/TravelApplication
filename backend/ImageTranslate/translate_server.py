from flask import Flask, request, jsonify
from playwright.sync_api import sync_playwright
import base64
import os
import time
import threading
import json

app = Flask(__name__)

# Global variables
playwright_instance = None
browser = None
page = None
lock = threading.Lock()
current_target_lang = 'vi'  # Default language

def init_browser():
    global playwright_instance, browser, page
    playwright_instance = sync_playwright().start()
    
    # Tạo folder riêng cho Playwright
    user_data_dir = os.path.abspath('./playwright_chrome_profile')
    
    context = playwright_instance.chromium.launch_persistent_context(
        user_data_dir,
        headless=False,  # Headful mode - hiển thị trên màn hình
        channel="chrome",
        args=[
            '--disable-blink-features=AutomationControlled',
            '--disable-infobars',
            '--no-sandbox',
            '--start-maximized',  # Force hiện browser maximize
            '--window-size=1920,1080',
        ],
        ignore_default_args=['--enable-automation'],
    )
    
    page = context.new_page()
    page.add_init_script("""
        Object.defineProperty(navigator, 'webdriver', {
            get: () => undefined
        });
    """)
    page.goto('https://translate.google.com/?sl=auto&tl=vi&op=images', timeout=60000)
    page.wait_for_timeout(3000)
    print("Browser ready!")

def get_lang_code(lang_input):
    """Lấy language code - Flutter gửi code trực tiếp"""
    if not lang_input:
        return 'vi'
    
    code = lang_input.lower()
    
    # Google Translate cần zh-CN, zh-TW (viết hoa đúng format)
    if code == 'zh-cn':
        return 'zh-CN'
    if code == 'zh-tw':
        return 'zh-TW'
    
    return code

def process_image(image_base64, target_lang=None):
    global page, current_target_lang
    
    # Xác định language code
    lang_code = get_lang_code(target_lang) if target_lang else 'vi'
    
    # Nếu ngôn ngữ hiện tại khác ngôn ngữ yêu cầu, chuyển trang
    if lang_code != current_target_lang:
        url = f'https://translate.google.com/?sl=auto&tl={lang_code}&op=images'
        print(f"Switching language to {lang_code}: {url}")
        page.goto(url, timeout=60000)
        page.wait_for_timeout(3000)
        current_target_lang = lang_code
    
    # Save temp image
    image_bytes = base64.b64decode(image_base64)
    temp_path = os.path.abspath('temp_image.jpg')
    with open(temp_path, 'wb') as f:
        f.write(image_bytes)
    
    try:
        # Upload image via hidden input
        page.set_input_files('input[type="file"][accept*="image"]', temp_path)
        
        # Đợi ảnh được upload và xử lý
        time.sleep(5)
        
        translated_base64 = None
        # Selector chính xác: ảnh đã dịch nằm trong div.tyW0pd, ảnh gốc trong div.eHJoHd
        translated_img_selector = 'div.tyW0pd img.Jmlpdc'
        
        try:
            # Đợi element xuất hiện - tăng timeout lên 30s
            page.wait_for_selector(translated_img_selector, timeout=30000)
            img_element = page.locator(translated_img_selector).first
            
            if img_element.count() > 0:
                # Check xem có đang loading không (có thể stuck)
                # Đợi thêm 2s để đảm bảo ảnh đã render xong
                page.wait_for_timeout(2000)
                
                # Screenshot trực tiếp element (vì blob URL không thể download)
                screenshot_bytes = img_element.screenshot()
                translated_base64 = base64.b64encode(screenshot_bytes).decode()
                print(f"Screenshot translated image element successfully!")
        except Exception as e:
            print(f"Primary selector failed: {e}")
            # Nếu timeout/stuck, reload page để reset
            print("Reloading page due to timeout...")
            url = f'https://translate.google.com/?sl=auto&tl={current_target_lang}&op=images'
            page.goto(url, timeout=60000)
            page.wait_for_timeout(2000)
        
        # Fallback 1: Thử selector khác
        if not translated_base64:
            fallback_selectors = [
                'img.Jmlpdc',  # Lấy img đầu tiên có class này
                'div[jsname="CHaVHf"] img',  # Container ancestor
            ]
            for selector in fallback_selectors:
                try:
                    # Tìm img có kích thước > 0 (đang hiển thị)
                    imgs = page.locator(selector).all()
                    for img in imgs:
                        box = img.bounding_box()
                        if box and box['width'] > 100 and box['height'] > 100:
                            screenshot_bytes = img.screenshot()
                            translated_base64 = base64.b64encode(screenshot_bytes).decode()
                            print(f"Screenshot with fallback selector '{selector}'")
                            break
                    if translated_base64:
                        break
                except Exception as e:
                    print(f"Fallback selector '{selector}' failed: {e}")
                    continue
        
        # Fallback 2: Screenshot toàn bộ viewport
        if not translated_base64:
            print("Fallback: screenshot full viewport")
            screenshot_bytes = page.screenshot(full_page=False)
            translated_base64 = base64.b64encode(screenshot_bytes).decode()
        
        # Xóa ảnh để chuẩn bị cho request tiếp
        try:
            close_selectors = [
                'button[aria-label="Clear image"]',
            ]
            for selector in close_selectors:
                try:
                    btn = page.locator(selector).first
                    if btn.count() > 0:
                        btn.click(timeout=2000)
                        page.wait_for_timeout(500)
                        break
                except:
                    continue
        except:
            # Nếu lỗi cleanup, reset lại page đúng ngôn ngữ
            url = f'https://translate.google.com/?sl=auto&tl={current_target_lang}&op=images'
            page.goto(url, timeout=30000)
            page.wait_for_timeout(2000)
        
        return translated_base64
    finally:
        if os.path.exists(temp_path):
            os.remove(temp_path)

@app.route('/translate-image', methods=['POST'])
def recognize_text():
    try:
        data = request.json
        image_base64 = data.get('image')
        target_lang = data.get('target_lang')  # Tên ngôn ngữ đích
        
        with lock:
            result = process_image(image_base64, target_lang)
        
        # Log response size
        response_data = json.dumps({'success': True, 'image': result})
        print(f"Response size: {len(response_data)} bytes")
        
        # Tạo response với Content-Length header
        from flask import make_response
        response = make_response(response_data)
        response.headers['Content-Type'] = 'application/json'
        response.headers['Content-Length'] = len(response_data)
        return response
    except Exception as e:
        return jsonify({'success': False, 'error': str(e)}), 500

@app.route('/health', methods=['GET'])
def health():
    return jsonify({'status': 'ok'})

def setup_adb_reverse():
    """Setup ADB reverse port forwarding cho Android emulator"""
    import subprocess
    adb_path = os.path.expandvars(r'%LOCALAPPDATA%\Android\Sdk\platform-tools\adb.exe')
    
    if os.path.exists(adb_path):
        try:
            result = subprocess.run([adb_path, 'reverse', 'tcp:5000', 'tcp:5000'], 
                                    capture_output=True, text=True)
            if result.returncode == 0:
                print("ADB reverse port forwarding: localhost:5000 -> emulator OK!")
            else:
                print(f"ADB reverse failed: {result.stderr}")
        except Exception as e:
            print(f"ADB reverse error: {e}")
    else:
        print(f"ADB not found at {adb_path}, skipping port forwarding")

if __name__ == '__main__':
    print("Setting up ADB reverse...")
    setup_adb_reverse()
    print("Initializing browser...")
    init_browser()
    print("Server running on port 5000...")
    app.run(host='0.0.0.0', port=5000, threaded=False)