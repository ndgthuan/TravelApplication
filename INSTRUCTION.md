# 📖 HƯỚNG DẪN REFACTOR ARCHITECTURE

> Tài liệu này ghi lại từng bước refactor project theo các Design Pattern chuẩn.

---

## 🎯 MỤC TIÊU TỔNG QUAN

Áp dụng các pattern sau vào project:

- **MVVM (Model-View-ViewModel):** Tách UI ra khỏi Logic
- **Repository Pattern:** Trừu tượng hóa nguồn dữ liệu
- **Dependency Injection (DI):** Quản lý dependencies tập trung
- **Factory Pattern:** Chuẩn hóa việc tạo object từ JSON

---

## 📁 CẤU TRÚC THƯ MỤC MỚI

```
lib/
├── core/                      # Utils, constants dùng chung
│   └── di/                    # Dependency Injection setup
│
├── domain/                    # Business logic layer (trừu tượng)
│   ├── models/                # Các class Model
│   └── repositories/          # Interfaces (abstract class)
│
├── data/                      # Implementation layer (cụ thể)
│   ├── repositories/          # Concrete implementations
│   └── datasources/           # Nơi gọi API/Firebase trực tiếp
│
└── screen/                    # UI layer (giữ nguyên)
    └── [Module]/
        ├── screens/
        ├── viewmodels/
        └── widgets/
```

---

## ✅ TIẾN ĐỘ REFACTOR

### BƯỚC 1: Tạo cấu trúc thư mục ✅

**Đã hoàn thành.** Tạo các folder: `core/di/`, `domain/models/`, `domain/repositories/`, `data/repositories/`, `data/datasources/`.

---

### BƯỚC 2: Tạo UserModel ✅

**File:** `lib/domain/models/user_model.dart`

**Mục đích:**

- Thay thế `Map<String, dynamic>` bằng class có kiểu dữ liệu rõ ràng (Type-safe).
- Áp dụng **Factory Pattern** với `UserModel.fromJson()` để tạo object từ JSON Firestore.
- Nếu backend thay đổi key, chỉ cần sửa ở file này, UI không bị ảnh hưởng.

**Nội dung chính:**

```dart
class UserModel {
  final String uid;
  final String name;
  final String email;
  final String? avatarUrl;
  final String? backgroundUrl;
  final DateTime? createAt;

  // Constructor
  // Factory: fromJson(Map<String, dynamic> json, String uid)
  // Method: toJson()
}
```

---

### BƯỚC 3: Tạo AuthResult Model ⏳

**File:** `lib/domain/models/auth_result.dart`

**Mục đích:**

- Đóng gói kết quả trả về khi Login/Register.
- Thay vì trả về `UserCredential?` hoặc `String?` (error), ta trả về một class thống nhất.

_(Đang thực hiện...)_

---

### BƯỚC 4: Tạo IAuthRepository (Interface) ⏳

**File:** `lib/domain/repositories/i_auth_repository.dart`

**Mục đích:**

- Định nghĩa "hợp đồng" (contract) cho các phương thức Auth.
- ViewModel sẽ phụ thuộc vào Interface này, KHÔNG phụ thuộc vào Firebase trực tiếp.

---

### BƯỚC 5: Tạo AuthRepositoryImpl ⏳

**File:** `lib/data/repositories/auth_repository_impl.dart`

**Mục đích:**

- Implement Interface `IAuthRepository`.
- Chứa toàn bộ code gọi Firebase Auth, Firestore.
- Nếu sau này đổi sang Supabase, chỉ cần tạo `AuthRepositorySupabase` mới.

---

### BƯỚC 6: Tạo/Cập nhật LoginViewModel ⏳

**File:** `lib/screen/Auth/viewmodels/login_view_model.dart`

**Mục đích:**

- Chứa toàn bộ logic của màn hình Login.
- Nhận `IAuthRepository` qua constructor (Dependency Injection).
- UI (LoginScreen) chỉ gọi ViewModel, không biết gì về Firebase.

---

### BƯỚC 7: Refactor LoginScreen ⏳

**File:** `lib/screen/Auth/screens/login_screen.dart`

**Mục đích:**

- Xóa bỏ mọi logic xử lý, chỉ giữ lại code vẽ UI.
- Lắng nghe state từ ViewModel và render tương ứng.

---

### BƯỚC 8: Setup Dependency Injection ⏳

**File:** `lib/core/di/injection.dart`

**Mục đích:**

- Đăng ký tất cả Repository và ViewModel vào một nơi tập trung.
- Dùng package `get_it` để inject dependencies.

---

## 📝 GHI CHÚ THÊM

_(Sẽ cập nhật khi có thêm thông tin)_
