// TimezoneUtilService - Chỉ lo logic tính toán timezone
// Tách riêng từ TimezoneService cũ để tuân thủ Single Responsibility Principle
import 'package:travel_app/domain/services/i_timezone_util_service.dart';

class TimezoneUtilService implements ITimezoneUtilService {
  // Map common timezones to UTC offset
  static const Map<String, int> _timezoneOffsets = {
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

  /// Lấy offset (giờ) từ timezone name
  int getTimezoneOffset(String timezone) {
    return _timezoneOffsets[timezone] ?? 0;
  }

  /// Lấy thời gian hiện tại theo timezone
  DateTime getCurrentTimeForTimezone(String timezone) {
    final offset = getTimezoneOffset(timezone);
    return DateTime.now().toUtc().add(Duration(hours: offset));
  }

  /// Format thời gian theo định dạng HH:mm
  String formatTime(DateTime dateTime) {
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  /// Tạo timezone object
  Map<String, dynamic> createTimezone({
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
}
