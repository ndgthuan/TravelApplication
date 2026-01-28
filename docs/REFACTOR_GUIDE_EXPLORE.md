# Hướng dẫn refactor Explore — chuẩn pattern

Refactor **ExploreViewModel** và **ExploreMapScreen** để đúng MVVM, Repository, DI. Làm từng bước, mỗi phần xong thì chạy app thử.

---

## Các vấn đề hiện tại

| Vấn đề | Vị trí | Hướng xử lý |
|--------|--------|-------------|
| Fallback `repository ?? ExploreRepositoryImpl()` | ExploreViewModel | Bỏ hẳn, luôn inject `IExploreRepository` qua DI |
| Dùng `FirebaseAuth.instance` trực tiếp | ExploreViewModel | Inject `IUserRepository`, lấy user qua `getCurrentUser()` |
| Import `ExploreRepositoryImpl` trong ViewModel | ExploreViewModel | Xóa import, ViewModel chỉ phụ thuộc interface |
| ExploreMapScreen không dùng ViewModel | ExploreMapScreen | Dùng `ExploreViewModel` (saved count, refresh); UI state giữ trong State |

---

# PHẦN 1: ExploreViewModel — Chuẩn DI & bỏ FirebaseAuth

**Mục tiêu:** ViewModel chỉ nhận dependency qua constructor (DI), không tự `new` impl, không dùng `FirebaseAuth.instance`.

---

## Bước 1.1: Xóa fallback Repository và import impl

**Mở file:** `lib/features/explore/viewmodels/explore_view_model.dart`

**1) Xóa import impl.**

Tìm và **xóa** dòng:
```dart
import 'package:travel_app/data/repositories/explore_repository_impl.dart';
```
ViewModel không được import hay phụ thuộc vào implementation, chỉ dùng interface.

**2) Xóa FirebaseAuth.**

Xóa:
```dart
import 'package:firebase_auth/firebase_auth.dart';
```

**3) Thêm import User Repository.**
```dart
import 'package:travel_app/domain/repositories/i_user_repository.dart';
```

**4) Sửa dependencies và constructor.**

**Hiện tại:**
```dart
  final IExploreRepository _repository;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  ExploreViewModel({IExploreRepository? repository})
    : _repository = repository ?? ExploreRepositoryImpl();
```

**Đổi thành:**
```dart
  final IExploreRepository _repository;
  final IUserRepository _userRepository;

  ExploreViewModel(this._repository, this._userRepository);
```

- Bỏ optional `repository?` và fallback.
- Bỏ `_auth`, thay bằng `_userRepository`.
- Constructor nhận 2 tham số theo thứ tự: `_repository`, `_userRepository`.

Lưu file.

---

## Bước 1.2: Thay _auth.currentUser bằng _userRepository.getCurrentUser()

Trong cùng file `explore_view_model.dart`, có 2 chỗ dùng `_auth.currentUser`:

**1) Trong `toggleSave`.**

**Hiện tại:**
```dart
  Future<void> toggleSave(String name) async {
    final user = _auth.currentUser;
    if (user == null) return;
    // ... dùng user.uid
```

**Đổi thành:**
```dart
  Future<void> toggleSave(String name) async {
    final user = await _userRepository.getCurrentUser();
    if (user == null) return;
    // ... dùng user.uid (giữ nguyên)
```

Chỉ đổi cách lấy `user`; phần dùng `user.uid` giữ nguyên.

**2) Trong `refreshSavedDestinations`.**

**Hiện tại:**
```dart
  Future<void> refreshSavedDestinations() async {
    final user = _auth.currentUser;
    if (user == null) return;
    // ...
```

**Đổi thành:**
```dart
  Future<void> refreshSavedDestinations() async {
    final user = await _userRepository.getCurrentUser();
    if (user == null) return;
    // ... phần còn lại giữ nguyên
```

**Lưu ý:** `getCurrentUser()` là `Future`, nên phải `await`. Hai chỗ trên đều đã `async` nên chỉ cần thêm `await`.

Lưu file.

---

## Bước 1.3: Cập nhật DI cho ExploreViewModel

**Mở file:** `lib/core/di/injection.dart`

Tìm đăng ký `ExploreViewModel`:
```dart
  getIt.registerFactory<ExploreViewModel>(
    () => ExploreViewModel(repository: getIt<IExploreRepository>()),
  );
```

**Đổi thành:**
```dart
  getIt.registerFactory<ExploreViewModel>(
    () => ExploreViewModel(
      getIt<IExploreRepository>(),
      getIt<IUserRepository>(),
    ),
  );
```

- Bỏ named param `repository:`.
- Truyền đúng thứ tự: `IExploreRepository`, `IUserRepository`.

Lưu file.

---

## Bước 1.4: Kiểm tra phần ExploreViewModel

- Chạy app → vào **Explore** / **My Saves**.
- Thử: load danh sách, filter category/city, search, save/unsave địa điểm.
- Nếu có lỗi: kiểm tra lại import, tên `_userRepository`, và đăng ký trong `injection.dart`.

---

# PHẦN 2: ExploreMapScreen — Dùng ExploreViewModel (MVVM)

**Mục tiêu:** ExploreMapScreen dùng `ExploreViewModel` cho **dữ liệu** (số địa điểm đã save). UI state (map zoom, info window đóng/mở) vẫn để trong `State` — đó là state thuần UI, không business logic.

---

## Bước 2.1: Thêm Provider và dùng ExploreViewModel

**Mở file:** `lib/features/explore/screens/explore_map_screen.dart`

**1) Thêm import Provider và ViewModel.**

Ở đầu file, thêm:
```dart
import 'package:provider/provider.dart';
import 'package:travel_app/features/explore/viewmodels/explore_view_model.dart';
```

**2) Trong `build`, lấy ViewModel.**

Ở đầu `Widget build(BuildContext context) {` của `_ExploreMapScreenState`, thêm:
```dart
    final viewModel = context.watch<ExploreViewModel>();
```

Đặt ngay sau `Widget build(BuildContext context) {`, trước các biến như `currentZoom`, `heightFactor`, v.v.

**Lưu ý:** ExploreMapScreen được mở từ SaveScreen (push route). App dùng `MultiProvider` ở root nên `ExploreViewModel` vẫn có trong cây widget → `context.watch` hoạt động bình thường.

Lưu file.

---

## Bước 2.2: Thay "300 Saved Places" bằng số thật từ ViewModel

**Trong cùng file**, tìm đoạn hiển thị số địa điểm đã save, ví dụ:
```dart
Text(
  '300 Saved Places',
  ...
)
```

**Đổi thành dùng `viewModel`:**
```dart
Text(
  '${viewModel.savedDestinations.length} Saved Places',
  style: GoogleFonts.beVietnamPro(
    color: Color(0xFFFFAD35),
    fontSize: 14,
  ),
),
```

- `savedDestinations` đã có trong ExploreViewModel (danh sách đã save sau filter).
- Nếu bạn đang dùng `savedIds` cho mục đích tương tự, có thể dùng `viewModel.savedIds.length` thay cho `savedDestinations.length` tùy cách bạn muốn đếm. Ở đây dùng `savedDestinations` cho thống nhất với màn My Saves.

Lưu file.

---

## Bước 2.3: (Tùy chọn) Refresh saved list khi mở map

Để map luôn hiển thị số saved mới nhất khi vừa mở, có thể gọi refresh trong `initState`.

**Trong `_ExploreMapScreenState`**, thêm `initState` (nếu chưa có):

```dart
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ExploreViewModel>().refreshSavedDestinations();
    });
  }
```

Nếu đã có `initState` (ví dụ cho controller), chỉ cần thêm `WidgetsBinding.instance.addPostFrameCallback` vào đó, không tạo hai `initState`.

**Lưu ý:** Cần `import 'package:flutter/scheduler.dart';` hoặc thường thì không cần gì thêm vì `WidgetsBinding` có trong `flutter/material.dart`. Nếu báo lỗi thì thêm import tương ứng.

Bước này **tùy chọn**. Nếu bạn luôn mở map từ My Saves (vừa refresh rồi) thì có thể bỏ qua.

Lưu file.

---

## Bước 2.4: Giữ MapController, zoom, showInfoWindow trong State

**Không cần chuyển** những thứ sau sang ViewModel:

- `MapController`
- `currentZoom`, `heightFactor`, `markerSize` (tính từ zoom)
- `_showInfoWindow`
- `isLoading` (trạng thái nút bấm animate)

Đây là **UI state**: gắn với lifecycle của màn hình, không phải business logic. Giữ trong `State` là hợp lý. ViewModel chỉ lo **dữ liệu** (saved count, danh sách địa điểm khi sau này gắn marker thật).

Lưu file.

---

## Bước 2.5: Kiểm tra ExploreMapScreen

- Chạy app → **My Saves** → mở **Map** (nút bản đồ).
- Kiểm tra:
  - "X Saved Places" hiển thị đúng số địa điểm đã save.
  - Save/unsave ở My Saves rồi mở lại map (hoặc refresh nếu đã thêm bước 2.3) thì số cập nhật.

---

# TÓM TẮT

## File chỉnh sửa

| File | Thay đổi |
|------|----------|
| `lib/features/explore/viewmodels/explore_view_model.dart` | Xóa impl + FirebaseAuth; thêm `IUserRepository`; constructor `(repository, userRepo)`; `toggleSave` & `refreshSavedDestinations` dùng `getCurrentUser()` |
| `lib/core/di/injection.dart` | Đăng ký `ExploreViewModel` với `getIt<IExploreRepository>()` và `getIt<IUserRepository>()` |
| `lib/features/explore/screens/explore_map_screen.dart` | Import Provider + ViewModel; `context.watch<ExploreViewModel>`; "X Saved Places" từ `viewModel`; (tùy chọn) refresh khi mở map |

## Nguyên tắc áp dụng

- **DI:** ViewModel không tự tạo implementation, không fallback. Tất cả dependency inject qua constructor.
- **Repository:** Chỉ dùng interface (`IExploreRepository`, `IUserRepository`). Không import `*_impl` trong ViewModel.
- **MVVM:** ExploreMapScreen dùng ViewModel cho **data** (saved count); UI state (map, popup) giữ trong **State**.

Làm xong từng phần thì chạy thử. Nếu vướng bước nào, gửi lại đoạn code + lỗi cụ thể để chỉnh tiếp.
