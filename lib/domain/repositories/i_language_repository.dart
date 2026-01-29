// Định nghĩa hợp đồng: load danh sách supported languages từ JSON
// ViewModel gọi interface này, không tự load file
import 'package:travel_app/domain/models/language_model.dart';

abstract class ILanguageRepository {
  // Lấy danh sách ngôn ngữ được hỗ trợ
  // Throws [Exception] nếu có lỗi khi load
  Future<List<LanguageModel>> getSupportedLanguages();
}
