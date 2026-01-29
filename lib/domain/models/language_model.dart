// Model đại diện cho một ngôn ngữ được hỗ trợ
class LanguageModel {
  final String code;
  final String name;
  final String flag;

  LanguageModel({required this.code, required this.name, required this.flag});

  factory LanguageModel.fromJson(Map<String, dynamic> json) {
    return LanguageModel(
      code: json['code'] ?? '',
      name: json['name'] ?? '',
      flag: json['flag'] ?? '',
    );
  }

  /// Convert to Map để tương thích với code cũ (nếu cần)
  Map<String, dynamic> toMap() {
    return {'code': code, 'name': name, 'flag': flag};
  }
}
