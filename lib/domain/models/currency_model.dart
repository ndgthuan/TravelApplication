// Model đại diện cho một loại tiền tệ
class CurrencyModel {
  final String code;
  final String name;
  final String flag;

  CurrencyModel({required this.code, required this.name, required this.flag});

  factory CurrencyModel.fromJson(Map<String, dynamic> json) {
    return CurrencyModel(
      code: json['code'] ?? '',
      name: json['name'] ?? '',
      flag: json['flag'] ?? '',
    );
  }
}

// Model đại diện cho tỷ giá
class ExchangeRateModel {
  final String baseCurrency;
  final Map<String, double> rates;

  ExchangeRateModel({required this.baseCurrency, required this.rates});
}
