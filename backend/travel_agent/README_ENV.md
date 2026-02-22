# Travel Agent – chạy server & kết nối emulator

## 1. Chạy server (terminal 1)

```powershell
cd c:\Studybase\travel_application\backend\travel_agent
# Kích hoạt venv (PowerShell):
& .\.venv\Scripts\Activate.ps1
# Nếu bị chặn script: Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
uvicorn main:api --port 5001
```

Nếu không dùng venv (python global đã cài đủ):

```powershell
uvicorn main:api --port 5001
```

## 2. Android Emulator – adb reverse (terminal 2)

`adb` nằm trong Android SDK. Chọn một cách:

**Cách A – Thêm SDK vào PATH (một lần)**

1. Mở **Edit the system environment variables** → Environment Variables.
2. Trong **User** hoặc **System**, sửa biến **Path**.
3. Thêm đường dẫn **platform-tools** của Android SDK, ví dụ:
   - `C:\Users\Admin\AppData\Local\Android\Sdk\platform-tools`
   - hoặc `C:\Android\sdk\platform-tools` (tùy nơi bạn cài SDK).
4. OK, đóng cửa sổ. Mở **PowerShell mới** rồi chạy:

```powershell
adb reverse tcp:5001 tcp:5001
```

**Cách B – Gọi adb bằng đường dẫn đầy đủ**

Nếu bạn biết chỗ cài Android SDK (vd. qua Android Studio):

```powershell
& "C:\Users\Admin\AppData\Local\Android\Sdk\platform-tools\adb.exe" reverse tcp:5001 tcp:5001
```

(Đổi đường dẫn cho đúng máy bạn.)

Sau khi reverse xong, app Flutter trên emulator gọi `http://localhost:5001` sẽ tới server trên máy.

## 3. Biến môi trường (.env)

| Key | Mô tả |
|-----|-------|
| `GOOGLE_API_KEY` | Gemini LLM |
| `TAVILY_API_KEY`, `GEOAPIFY_API_KEY` | Tìm địa điểm |
| `OPENWEATHER_API_KEY` | Thời tiết |
| `RAPIDAPI_KEY` | Khách sạn |
| `AMADEUS_API_KEY` | Chuyến bay (Amadeus test) |
| `AMADEUS_API_SECRET` | Secret cho Amadeus OAuth |
| `AMADEUS_BASE_URL` | `https://test.api.amadeus.com` (test) hoặc `https://api.amadeus.com` (production) |

## 4. API chuyến bay (Amadeus)

- **GET /search-flights**: Tìm chuyến bay thực tế. Query: `origin`, `destination`, `departure_date` (YYYY-MM-DD), `adults`, `max_results`.
- Khi tạo/chỉnh sửa kế hoạch, nếu có hoạt động bay (flight) và đủ thông tin xuất phát/điểm đến/ngày, hệ thống tự lấy dữ liệu Amadeus để làm giàu kế hoạch.
- **Sandbox:** Môi trường test có thể không có dữ liệu cho tuyến VN (SGN-HAN). Để verify API: thử `origin=MAD&destination=BOS&departure_date=2025-06-15`.
