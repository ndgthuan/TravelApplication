import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class TimezoneService {
  static const String _storageKey = 'saved_timezones';
  static const String _geoBaseUrl = 'https://geocoding-api.open-meteo.com/v1';

  // Model cho timezone
  static Map<String, dynamic> createTimezone({
    required String city,
    required String country,
    required String timezone,
    required double latitude,
    required double longitude,
  }) {
    return {
      'city': city,
      'country': country,
      'timezone': timezone,
      'latitude': latitude,
      'longitude': longitude,
    };
  }

  // Tìm kiếm thành phố (dùng Open-Meteo Geocoding)
  static Future<List<Map<String, dynamic>>> searchCities(String query) async {
    if (query.isEmpty) return [];

    final url =
        '$_geoBaseUrl/search?name=$query&count=10&language=en&format=json';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['results'] != null) {
        return (data['results'] as List).map((item) {
          return {
            'city': item['name'] ?? '',
            'country': item['country'] ?? '',
            'timezone': item['timezone'] ?? 'UTC',
            'latitude': item['latitude'] ?? 0.0,
            'longitude': item['longitude'] ?? 0.0,
          };
        }).toList();
      }
    }
    return [];
  }

  // Lấy offset (giờ) từ timezone name
  static int getTimezoneOffset(String timezone) {
    // Map common timezones to UTC offset
    final Map<String, int> timezoneOffsets = {
      'Asia/Ho_Chi_Minh': 7,
      'Asia/Bangkok': 7,
      'Asia/Tokyo': 9,
      'Asia/Seoul': 9,
      'Asia/Shanghai': 8,
      'Asia/Singapore': 8,
      'Asia/Kolkata': 5, // +5:30, simplified
      'Asia/Dubai': 4,
      'Europe/London': 0,
      'Europe/Paris': 1,
      'Europe/Berlin': 1,
      'Europe/Moscow': 3,
      'America/New_York': -5,
      'America/Los_Angeles': -8,
      'America/Chicago': -6,
      'America/Denver': -7,
      'Australia/Sydney': 11,
      'Australia/Melbourne': 11,
      'Pacific/Auckland': 13,
      'UTC': 0,
    };

    return timezoneOffsets[timezone] ?? 0;
  }

  // Lưu danh sách timezone vào local storage
  static Future<void> saveTimezones(
    List<Map<String, dynamic>> timezones,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = json.encode(timezones);
    await prefs.setString(_storageKey, jsonString);
  }

  // Lấy danh sách timezone đã lưu
  static Future<List<Map<String, dynamic>>> getSavedTimezones() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_storageKey);

    if (jsonString != null) {
      final List decoded = json.decode(jsonString);
      return decoded.cast<Map<String, dynamic>>();
    }

    // Default: Hanoi
    return [
      createTimezone(
        city: 'Hanoi',
        country: 'Vietnam',
        timezone: 'Asia/Ho_Chi_Minh',
        latitude: 21.0285,
        longitude: 105.8542,
      ),
    ];
  }

  // Thêm timezone mới
  static Future<void> addTimezone(Map<String, dynamic> timezone) async {
    final timezones = await getSavedTimezones();

    // Kiểm tra trùng
    final exists = timezones.any(
      (t) =>
          t['city'] == timezone['city'] && t['country'] == timezone['country'],
    );

    if (!exists) {
      timezones.add(timezone);
      await saveTimezones(timezones);
    }
  }

  // Xóa timezone
  static Future<void> removeTimezone(int index) async {
    final timezones = await getSavedTimezones();
    if (index >= 0 && index < timezones.length) {
      timezones.removeAt(index);
      await saveTimezones(timezones);
    }
  }
}
