# Hướng dẫn refactor: Currency · Language · Contact Support

Hướng dẫn từng bước, có **code mẫu đầy đủ** để bạn tự gõ và hiểu. Làm lần lượt, mỗi bước xong thì chạy app thử.

---

# PHẦN 1: CURRENCY — Đưa logic vào Repository

**Mục tiêu:** Bỏ `rootBundle` + `http` + `json` ra khỏi `CurrencyExchangeViewModel`, chuyển sang `ICurrencyRepository` + `CurrencyRepositoryImpl`.

---

## Bước 1.1: Tạo interface ICurrencyRepository

**Tạo file mới:** `lib/domain/repositories/i_currency_repository.dart`

**Giải thích ngắn:** Interface định nghĩa "hợp đồng" — ViewModel chỉ gọi 2 hàm này, không biết bên trong load JSON hay gọi API thế nào.

**Code nguyên file:**

```dart
// Định nghĩa hợp đồng cho Currency: load danh sách tiền tệ + fetch tỷ giá
// ViewModel gọi interface này, không đụng rootBundle/http/json

abstract class ICurrencyRepository {
  /// Load danh sách supported currencies từ JSON (lib/assets/data/supported_currencies.json)
  /// Trả về List<Map<String, dynamic>>, mỗi map có: code, name, flag
  Future<List<Map<String, dynamic>>> getSupportedCurrencies();

  /// Gọi API tỷ giá, base là mã tiền (vd: USD)
  /// Trả về Map<String, dynamic> rates, vd: {"VND": 25000, "EUR": 0.92, ...}
  Future<Map<String, dynamic>> fetchExchangeRates(String baseCurrency);
}
```

**Bạn làm:** Tạo file, dán nguyên đoạn trên (hoặc gõ lại). Lưu.

---

## Bước 1.2: Tạo CurrencyRepositoryImpl

**Tạo file mới:** `lib/data/repositories/currency_repository_impl.dart`

**Giải thích ngắn:** Đây là lớp **implement** interface. Toàn bộ logic load JSON + gọi API nằm đây. ViewModel không còn dùng `rootBundle` hay `http` nữa.

**Code nguyên file:**

```dart
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:travel_app/domain/repositories/i_currency_repository.dart';

class CurrencyRepositoryImpl implements ICurrencyRepository {
  @override
  Future<List<Map<String, dynamic>>> getSupportedCurrencies() async {
    final String jsonString = await rootBundle.loadString(
      'lib/assets/data/supported_currencies.json',
    );
    final List<dynamic> jsonList = json.decode(jsonString);
    return jsonList.cast<Map<String, dynamic>>();
  }

  @override
  Future<Map<String, dynamic>> fetchExchangeRates(String baseCurrency) async {
    final apiKey = dotenv.env['CURRENCY_TOKEN'] ?? '';
    final response = await http.get(
      Uri.parse(
        'https://api.fxratesapi.com/latest?base=$baseCurrency&api_key=$apiKey',
      ),
    );
    if (response.statusCode != 200) {
      return {};
    }
    final data = json.decode(response.body);
    final rates = data['rates'];
    return rates is Map<String, dynamic> ? rates : {};
  }
}
```

**Bạn làm:** Tạo file, dán (hoặc gõ) code. Lưu. Nếu có lỗi import, kiểm tra `pubspec.yaml` đã có `flutter_dotenv`, `http`.

---

## Bước 1.3: Đăng ký Repository trong DI

**Mở file:** `lib/core/di/injection.dart`

**1) Thêm import** (đặt cùng nhóm import repositories, khoảng dòng 15–22):

```dart
import 'package:travel_app/domain/repositories/i_currency_repository.dart';
import 'package:travel_app/data/repositories/currency_repository_impl.dart';
```

**2) Trong `setupDependencies()`, phần REPOSITORIES** (sau `IExploreRepository`), thêm:

```dart
  getIt.registerLazySingleton<ICurrencyRepository>(
    () => CurrencyRepositoryImpl(),
  );
```

**Bạn làm:** Thêm 2 dòng import và 1 block đăng ký như trên. Lưu.

---

## Bước 1.4: Sửa CurrencyExchangeViewModel

**Mở file:** `lib/features/utilities/currency_exchange/viewmodels/currency_exchange_view_model.dart`

**Giải thích ngắn:** ViewModel chỉ còn (1) gọi `_currencyRepository`, (2) cập nhật state, (3) `notifyListeners()`. Không còn `rootBundle`, `http`, `json`, `dotenv`.

**Thay đổi cụ thể:**

**1) Xóa các import sau (không dùng nữa):**
- `import 'package:flutter/services.dart';`
- `import 'package:flutter_dotenv/flutter_dotenv.dart';`
- `import 'package:http/http.dart' as http;`
- `import 'dart:convert';`

**2) Thêm import:**
```dart
import 'package:travel_app/domain/repositories/i_currency_repository.dart';
```

**3) Thêm dependency và sửa constructor.**  
Tìm phần đầu class (sau `class CurrencyExchangeViewModel extends ChangeNotifier {`). Thêm field và constructor:

```dart
  final ICurrencyRepository _currencyRepository;

  CurrencyExchangeViewModel(this._currencyRepository);
```

**4) Sửa `loadCurrencies`.**  
Thay toàn bộ nội dung hàm bằng:

```dart
  Future<void> loadCurrencies({String defaultAmount = '10'}) async {
    _defaultAmount = defaultAmount;
    try {
      _currencies = await _currencyRepository.getSupportedCurrencies();

      _fromCurrency = _currencies.isNotEmpty
          ? _currencies.firstWhere(
              (c) => c['code'] == 'USD',
              orElse: () => _currencies.first,
            )
          : {};
      _toCurrency = _currencies.isNotEmpty
          ? _currencies.firstWhere(
              (c) => c['code'] == 'VND',
              orElse: () => _currencies.last,
            )
          : {};
      notifyListeners();
      await fetchExchangeRates();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
    }
  }
```

**5) Sửa `fetchExchangeRates`.**  
Thay toàn bộ nội dung hàm bằng:

```dart
  Future<void> fetchExchangeRates() async {
    try {
      final base = _fromCurrency['code']?.toString() ?? 'USD';
      _rates = await _currencyRepository.fetchExchangeRates(base);
      _isLoading = false;
      calculateConversion(_defaultAmount);
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
    }
  }
```

**Bạn làm:** Lần lượt xóa import cũ → thêm import mới → thêm dependency + constructor → thay `loadCurrencies` → thay `fetchExchangeRates`. Các getter và hàm `calculateConversion`, `swapCurrencies`, `selectCurrency`, `formatNumber` **giữ nguyên**. Lưu.

---

## Bước 1.5: Cập nhật DI cho CurrencyExchangeViewModel

**Mở file:** `lib/core/di/injection.dart`

Tìm dòng đăng ký `CurrencyExchangeViewModel`:

```dart
  getIt.registerFactory<CurrencyExchangeViewModel>(
    () => CurrencyExchangeViewModel(),
  );
```

Đổi thành:

```dart
  getIt.registerFactory<CurrencyExchangeViewModel>(
    () => CurrencyExchangeViewModel(getIt<ICurrencyRepository>()),
  );
```

**Bạn làm:** Sửa đúng 1 chỗ đó. Lưu.

---

## Bước 1.6: Kiểm tra Currency

- Chạy app → mở màn **Currency Exchange**.
- Kiểm tra: danh sách tiền tệ load được, đổi loại tiền, tỷ giá đổi đúng.

Nếu lỗi: kiểm tra lại import, tên `ICurrencyRepository` / `CurrencyRepositoryImpl`, và đăng ký trong `injection.dart`.

---

# PHẦN 2: LANGUAGE — Đưa load JSON vào Repository

**Mục tiêu:** Bỏ `rootBundle` + `json.decode` khỏi `TextTranslationViewModel.loadLanguages()`, chuyển sang `ILanguageRepository` + `LanguageRepositoryImpl`.

---

## Bước 2.1: Tạo interface ILanguageRepository

**Tạo file mới:** `lib/domain/repositories/i_language_repository.dart`

**Code nguyên file:**

```dart
// Định nghĩa hợp đồng: load danh sách supported languages từ JSON
// ViewModel gọi interface này, không tự load file

abstract class ILanguageRepository {
  /// Load từ lib/assets/data/supported_languages.json
  /// Trả về List<Map<String, dynamic>>, mỗi map: code, name, flag
  Future<List<Map<String, dynamic>>> getSupportedLanguages();
}
```

**Bạn làm:** Tạo file, dán code. Lưu.

---

## Bước 2.2: Tạo LanguageRepositoryImpl

**Tạo file mới:** `lib/data/repositories/language_repository_impl.dart`

**Code nguyên file:**

```dart
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:travel_app/domain/repositories/i_language_repository.dart';

class LanguageRepositoryImpl implements ILanguageRepository {
  @override
  Future<List<Map<String, dynamic>>> getSupportedLanguages() async {
    final String jsonString = await rootBundle.loadString(
      'lib/assets/data/supported_languages.json',
    );
    final List<dynamic> jsonData = json.decode(jsonString);
    return jsonData.cast<Map<String, dynamic>>();
  }
}
```

**Bạn làm:** Tạo file, dán code. Lưu.

---

## Bước 2.3: Đăng ký trong DI

**Mở:** `lib/core/di/injection.dart`

**1) Thêm import:**
```dart
import 'package:travel_app/domain/repositories/i_language_repository.dart';
import 'package:travel_app/data/repositories/language_repository_impl.dart';
```

**2) Trong phần REPOSITORIES, thêm:**
```dart
  getIt.registerLazySingleton<ILanguageRepository>(
    () => LanguageRepositoryImpl(),
  );
```

**Bạn làm:** Thêm import + đăng ký. Lưu.

---

## Bước 2.4: Sửa TextTranslationViewModel

**Mở:** `lib/features/utilities/text_translation/viewmodels/text_translation_view_model.dart`

**1) Xóa import** (nếu chỉ dùng cho language):
- `import 'package:flutter/services.dart' show rootBundle;`
- `import 'dart:convert';`  
Chỉ xóa nếu không còn chỗ nào trong file dùng `rootBundle` hay `json`. (Hiện tại chỉ `loadLanguages` dùng, nên có thể xóa.)

**2) Thêm import:**
```dart
import 'package:travel_app/domain/repositories/i_language_repository.dart';
```

**3) Thêm dependency.**  
Ở phần DEPENDENCIES, thêm field và cập nhật constructor:

```dart
  final SpeechTtsService _speechTtsService;
  final ImageTranslationService _imageTranslationService;
  final IUserRepository _userRepository;
  final ILanguageRepository _languageRepository;

  TextTranslationViewModel(
    this._speechTtsService,
    this._imageTranslationService,
    this._userRepository,
    this._languageRepository,
  );
```

**4) Sửa `loadLanguages`.**  
Thay phần load JSON bằng gọi repository. **Giữ nguyên** phần load user preference từ `_userRepository.getCurrentUser()` và gán `_targetLanguage`:

```dart
  Future<void> loadLanguages() async {
    if (!_isLoadingLanguages) return;

    _supportedLanguages = await _languageRepository.getSupportedLanguages();

    try {
      final user = await _userRepository.getCurrentUser();
      if (user?.preferredLanguage != null) {
        final savedLang = _supportedLanguages.firstWhere(
          (lang) => lang['code'] == user!.preferredLanguage,
          orElse: () => _targetLanguage,
        );
        _targetLanguage = savedLang;
      }
    } catch (e) {
      log('ERROR LOADING LANGUAGE PREFERENCES: $e');
    }

    _isLoadingLanguages = false;
    notifyListeners();
  }
```

**Bạn làm:** Sửa import → thêm `_languageRepository` + constructor → thay `loadLanguages` như trên. Lưu.

---

## Bước 2.5: Cập nhật DI cho TextTranslationViewModel

**Mở:** `lib/core/di/injection.dart`

Tìm:

```dart
  getIt.registerFactory<TextTranslationViewModel>(
    () => TextTranslationViewModel(
      getIt<SpeechTtsService>(),
      getIt<ImageTranslationService>(),
      getIt<IUserRepository>(),
    ),
  );
```

Đổi thành:

```dart
  getIt.registerFactory<TextTranslationViewModel>(
    () => TextTranslationViewModel(
      getIt<SpeechTtsService>(),
      getIt<ImageTranslationService>(),
      getIt<IUserRepository>(),
      getIt<ILanguageRepository>(),
    ),
  );
```

**Bạn làm:** Thêm tham số `getIt<ILanguageRepository>()`. Lưu.

---

## Bước 2.6: Kiểm tra Language

- Chạy app → mở **Text Translation**.
- Kiểm tra: danh sách ngôn ngữ hiển thị, đổi ngôn ngữ nguồn/đích, preference vẫn hoạt động.

---

# PHẦN 3: CONTACT SUPPORT — Đưa gửi email vào Service

**Mục tiêu:** Bỏ `http.post` và `FirebaseAuth.instance` khỏi `ContactSupportViewModel`. Tạo `ISupportEmailService` + `SupportEmailService`; ViewModel lấy user từ `IUserRepository` rồi gọi service.

---

## Bước 3.1: Tạo interface ISupportEmailService

**Tạo file mới:** `lib/domain/services/i_support_email_service.dart`  
(Nếu chưa có folder `domain/services`, tạo luôn.)

**Code nguyên file:**

```dart
// Hợp đồng: gửi email hỗ trợ qua EmailJS
// ViewModel không gọi http hay Firebase, chỉ gọi service này

abstract class ISupportEmailService {
  /// Gửi email. userName, userEmail do ViewModel lấy từ User rồi truyền vào.
  /// Return true nếu gửi thành công, false nếu lỗi.
  Future<bool> sendSupportEmail({
    required String subject,
    required String message,
    required String userName,
    required String userEmail,
  });
}
```

**Bạn làm:** Tạo folder (nếu cần) + file, dán code. Lưu.

---

## Bước 3.2: Tạo SupportEmailService

**Tạo file mới:** `lib/features/support/services/support_email_service.dart`  
(Tạo folder `support/services/` nếu chưa có. Service nằm trong feature Support vì chỉ phục vụ màn Contact Support.)

**Giải thích ngắn:** Service gọi EmailJS API. Nhận sẵn `userName`, `userEmail` từ ViewModel; không dùng `FirebaseAuth` hay `http` ở ViewModel nữa.

**Code nguyên file:**

```dart
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

import 'package:travel_app/domain/services/i_support_email_service.dart';

class SupportEmailService implements ISupportEmailService {
  @override
  Future<bool> sendSupportEmail({
    required String subject,
    required String message,
    required String userName,
    required String userEmail,
  }) async {
    final url = Uri.parse('https://api.emailjs.com/api/v1.0/email/send');
    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${dotenv.env['PRIVATE_KEY']}',
        },
        body: json.encode({
          'service_id': dotenv.env['SERVICE_ID'],
          'template_id': dotenv.env['TEMPLATE_ID'],
          'user_id': dotenv.env['PUBLIC_KEY'],
          'accessToken': dotenv.env['PRIVATE_KEY'],
          'template_params': {
            'title': subject,
            'message': message,
            'name': userName,
            'email': userEmail,
          },
        }),
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}
```

**Bạn làm:** Tạo file, dán code. Lưu. (Nếu đặt `i_support_email_service` ở path khác, sửa import cho đúng.)

---

## Bước 3.3: Đăng ký SupportEmailService trong DI

**Mở:** `lib/core/di/injection.dart`

**1) Thêm import** (cùng nhóm services):
```dart
import 'package:travel_app/domain/services/i_support_email_service.dart';
import 'package:travel_app/features/support/services/support_email_service.dart';
```

**2) Trong phần SERVICES, thêm:**
```dart
  getIt.registerLazySingleton<ISupportEmailService>(
    () => SupportEmailService(),
  );
```

**Bạn làm:** Thêm import + đăng ký. Lưu.

---

## Bước 3.4: Sửa ContactSupportViewModel

**Mở:** `lib/features/support/viewmodels/contact_support_view_model.dart`

**1) Xóa các import:**
- `import 'package:http/http.dart' as http;`
- `import 'dart:convert';`
- `import 'package:flutter_dotenv/flutter_dotenv.dart';`
- `import 'package:firebase_auth/firebase_auth.dart';`

**2) Thêm import:**
```dart
import 'package:travel_app/domain/services/i_support_email_service.dart';
import 'package:travel_app/domain/repositories/i_user_repository.dart';
```

**3) Thêm dependency và constructor.**  
Sau `class ContactSupportViewModel extends ChangeNotifier {`, thêm:

```dart
  final ISupportEmailService _supportEmailService;
  final IUserRepository _userRepository;

  ContactSupportViewModel(this._supportEmailService, this._userRepository);
```

**4) Sửa `sendSupportEmail`.**  
Thay toàn bộ nội dung hàm bằng:

```dart
  Future<bool> sendSupportEmail({
    required String subject,
    required String message,
  }) async {
    if (subject.trim().isEmpty || message.trim().isEmpty) {
      _errorMessage = 'account.fill_all_fields';
      notifyListeners();
      return false;
    }
    _state = ContactSupportState.sending;
    _errorMessage = null;
    notifyListeners();

    String userName = 'App User';
    String userEmail = 'no-reply@app.com';
    try {
      final user = await _userRepository.getCurrentUser();
      if (user != null) {
        if (user.name.isNotEmpty) userName = user.name;
        if (user.email.isNotEmpty) userEmail = user.email;
      }
    } catch (_) {}

    final success = await _supportEmailService.sendSupportEmail(
      subject: subject,
      message: message,
      userName: userName,
      userEmail: userEmail,
    );

    if (success) {
      _state = ContactSupportState.success;
      notifyListeners();
      return true;
    } else {
      _state = ContactSupportState.error;
      _errorMessage = 'account.send_error';
      notifyListeners();
      return false;
    }
  }
```

**Bạn làm:** Xóa import cũ → thêm import mới → thêm 2 dependency + constructor → thay `sendSupportEmail`. Các getter, `clearError`, `reset` **giữ nguyên**. Lưu.

---

## Bước 3.5: Cập nhật DI cho ContactSupportViewModel

**Mở:** `lib/core/di/injection.dart`

Tìm:

```dart
  getIt.registerFactory<ContactSupportViewModel>(
    () => ContactSupportViewModel(),
  );
```

Đổi thành:

```dart
  getIt.registerFactory<ContactSupportViewModel>(
    () => ContactSupportViewModel(
      getIt<ISupportEmailService>(),
      getIt<IUserRepository>(),
    ),
  );
```

**Bạn làm:** Sửa đúng 1 chỗ đó. Lưu.

---

## Bước 3.6: Kiểm tra Contact Support

- Chạy app → mở **Contact Support**.
- Nhập tiêu đề + nội dung → gửi. Kiểm tra gửi thành công / lỗi hiển thị đúng.

---

# TÓM TẮT CÁC FILE BẠN TẠO MỚI

| File | Mục đích |
|------|----------|
| `lib/domain/repositories/i_currency_repository.dart` | Interface Currency |
| `lib/data/repositories/currency_repository_impl.dart` | Implement: JSON + API tỷ giá |
| `lib/domain/repositories/i_language_repository.dart` | Interface Language |
| `lib/data/repositories/language_repository_impl.dart` | Implement: JSON languages |
| `lib/domain/services/i_support_email_service.dart` | Interface gửi email |
| `lib/features/support/services/support_email_service.dart` | Implement: EmailJS http.post (trong feature Support) |

# TÓM TẮT CÁC FILE BẠN SỬA

| File | Thay đổi |
|------|----------|
| `injection.dart` | Thêm import + đăng ký Repository/Service; sửa constructor của 3 ViewModel |
| `currency_exchange_view_model.dart` | Inject `ICurrencyRepository`, gọi repo thay vì rootBundle/http |
| `text_translation_view_model.dart` | Inject `ILanguageRepository`, gọi repo trong `loadLanguages` |
| `contact_support_view_model.dart` | Inject `ISupportEmailService` + `IUserRepository`, gọi service + user repo |

Làm xong từng phần thì chạy thử. Nếu vướng bước nào, gửi lại đoạn code + lỗi cụ thể để chỉnh tiếp.
