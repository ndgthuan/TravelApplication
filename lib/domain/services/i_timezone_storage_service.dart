// Interface cho lưu/đọc danh sách timezone (SharedPreferences)
abstract class ITimezoneStorageService {
  Future<List<Map<String, dynamic>>> getSavedTimezones();

  Future<void> saveTimezones(List<Map<String, dynamic>> timezones);

  Future<bool> addTimezone(Map<String, dynamic> timezone);

  Future<void> removeTimezone(int index);
}
