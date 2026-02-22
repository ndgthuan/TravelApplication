# Travel Application

Ứng dụng Flutter quản lý chuyến đi: tạo kế hoạch, mời thành viên, chỉnh sửa realtime, map & check-in, chatbot gợi ý lịch trình, tiện ích (thời tiết, tỷ giá, dịch, đồng hồ thế giới).

---

## Yêu cầu

- Flutter SDK ^3.9.2
- Firebase project (Auth, Firestore)
- (Tùy chọn) OpenRouteService API key, Currency API key, EmailJS cho hỗ trợ

---

## Cài đặt

### 1. Clone và cài dependency

```bash
git clone <repo_url>
cd travel_application
flutter pub get
```

### 2. Cấu hình Firebase

- Tạo project tại [Firebase Console](https://console.firebase.google.com)
- Bật **Authentication** (Email/Password, Google, Facebook nếu dùng)
- Tạo **Firestore Database**
- Thêm Android/iOS app, tải `google-services.json` (Android) và `GoogleService-Info.plist` (iOS) vào đúng thư mục
- Chạy `flutterfire configure` hoặc copy file cấu hình Firebase vào project
- Deploy Firestore rules: copy nội dung `firestore.rules` vào Firebase Console → Firestore → Rules → Publish

### 3. Biến môi trường (.env)

```bash
cp .env.example .env
```

Chỉnh `.env`, thêm các key cần dùng:

| Key | Mô tả |
|-----|--------|
| `OPENROUTE_SERVICE_API_KEY` | API key OpenRouteService (tuyến đường trên bản đồ) |
| `CURRENCY_TOKEN` | API key dịch vụ tỷ giá (ví dụ exchangerate-api.com) |
| `SERVICE_ID`, `TEMPLATE_ID`, `PUBLIC_KEY`, `PRIVATE_KEY` | (Tùy chọn) EmailJS cho màn Liên hệ hỗ trợ |

Không điền key thì tính năng tương ứng có thể bị tắt hoặc dùng fallback (ví dụ route không vẽ được, tỷ giá không load).

### 4. Chạy ứng dụng

```bash
flutter run
```

---

## Cấu trúc project

- `lib/` – Mã nguồn Flutter
  - `main.dart` – Entry, DI, MaterialApp
  - `core/di/` – Dependency injection
  - `domain/` – Models, repository interfaces, services
  - `data/` – Repository implementations (Firestore, API)
  - `features/` – Theo tính năng: auth, account, plan, home, explore, notification, utilities
- `firestore.rules` – Rules bảo mật Firestore (users, plan_created, plan_shared, plan_invites, plan_presence)
- `docs/` – Tài liệu (ví dụ REALTIME_PLAN_EDITING.md)

---

## Tính năng chính

- **Đăng nhập / Đăng ký**: Email, Google, Facebook
- **Plan (Kế hoạch)**:
  - Tạo/sửa/xóa chuyến đi, thêm thành viên (Owner / Editor / Spectator)
  - Mời qua email → chấp nhận → chỉnh sửa realtime chung một plan
  - Optimistic locking (version), hint "Đã cập nhật từ thành viên khác", presence "A, B đang trong chuyến đi"
- **Chi tiết chuyến**: Map, danh sách hoạt động, check-in, chatbot gợi ý chỉnh sửa
- **Home**: Điểm đến phổ biến, gợi ý, đã lưu (Firestore)
- **Explore**: Bản đồ, lưu/bỏ lưu điểm
- **Notification**: Lời mời tham gia plan, thời tiết
- **Tiện ích**: Thời tiết, tỷ giá, dịch văn bản, đồng hồ thế giới, hỗ trợ (FAQ, liên hệ)

---

## Đa ngôn ngữ

Dùng `easy_localization`. File dịch: `lib/assets/translations/` (vi.json, en.json, …). Chuỗi trong code dùng `.tr()` (ví dụ `'plan.ongoing'.tr()`).

---

## Backend (Travel Agent)

Thư mục `backend/travel_agent/` chứa service Python (Gemini, gợi ý lịch trình). Chạy riêng; app Flutter gọi API của backend nếu cấu hình URL. Xem `backend/travel_agent/` và `.env` trong đó để biết API keys (Gemini, Tavily, Geoapify, …).

---

## Firestore

- **users/{userId}**: Profile, `saved_destinations`, `plan_created`, `plan_shared`
- **plan_invites**: Lời mời tham gia plan
- **plan_presence**: Presence theo phòng (ownerId_planId) → viewers

Chi tiết quyền đọc/ghi xem `firestore.rules`.

---

## License

Private / theo quy định của project.
