// Định nghĩa hợp đồng: load danh sách supported languages từ JSON
// ViewModel gọi interface này, không tự load file
abstract class ILanguageRepository {
  // Phương thức gọi json không có logic
  Future<List<Map<String, dynamic>>> getSupportedLanguages();
}
