// TimezoneStorageService - Chỉ lo việc lưu/đọc timezones từ SharedPreferences
// Tách riêng từ TimezoneService cũ để tuân thủ Single Responsibility Principle
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:travel_app/domain/services/i_timezone_storage_service.dart';

class TimezoneStorageService implements ITimezoneStorageService {
  static const String _storageKey = 'saved_timezones';

  // Default timezone khi chưa có dữ liệu
  static const Map<String, dynamic> _defaultTimezone = {
    'city': 'Hanoi',
    'country': 'Vietnam',
    'timezone': 'Asia/Ho_Chi_Minh',
    'latitude': 21.0285,
    'longitude': 105.8542,
  };

  // Lấy danh sách timezone đã lưu
  @override
  Future<List<Map<String, dynamic>>> getSavedTimezones() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_storageKey);

    if (jsonString != null) {
      final List decoded = json.decode(jsonString);
      return decoded.cast<Map<String, dynamic>>();
    }

    // Default: Hanoi
    return [Map.from(_defaultTimezone)];
  }

  // Lưu danh sách timezone
  @override
  Future<void> saveTimezones(List<Map<String, dynamic>> timezones) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = json.encode(timezones);
    await prefs.setString(_storageKey, jsonString);
  }

  // Thêm timezone mới (kiểm tra trùng)
  @override
  Future<bool> addTimezone(Map<String, dynamic> timezone) async {
    final timezones = await getSavedTimezones();

    // Kiểm tra trùng
    final exists = timezones.any(
      (t) =>
          t['city'] == timezone['city'] && t['country'] == timezone['country'],
    );

    if (!exists) {
      timezones.add(timezone);
      await saveTimezones(timezones);
      return true;
    }
    return false;
  }

  // Xóa timezone theo index
  @override
  Future<void> removeTimezone(int index) async {
    final timezones = await getSavedTimezones();
    if (index >= 0 && index < timezones.length) {
      timezones.removeAt(index);
      await saveTimezones(timezones);
    }
  }
}
