// Interface cho logic tính toán timezone (offset, format, tạo object)
abstract class ITimezoneUtilService {
  int getTimezoneOffset(String timezone);

  DateTime getCurrentTimeForTimezone(String timezone);

  String formatTime(DateTime dateTime);

  Map<String, dynamic> createTimezone({
    required String city,
    required String country,
    required String timezone,
    required double latitude,
    required double longitude,
  });
}