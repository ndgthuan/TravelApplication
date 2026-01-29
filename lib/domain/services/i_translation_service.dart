// Interface định nghĩa hợp đồng cho Translation Service
// ViewModel sẽ inject interface này, không phụ thuộc vào GoogleTranslator
abstract class ITranslationService {
  // Dịch văn bản từ ngôn ngữ nguồn sang ngôn ngữ đích
  // [text] - Văn bản cần dịch
  // [from] - Mã ngôn ngữ nguồn (ví dụ: 'en', 'vi', 'auto')
  // [to] - Mã ngôn ngữ đích (ví dụ: 'vi', 'en')
  // Trả về văn bản đã dịch
  Future<String> translate(
    String text, {
    required String from,
    required String to,
  });
}
