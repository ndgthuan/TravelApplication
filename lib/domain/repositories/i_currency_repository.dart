// Định nghĩa hợp đồng cho Currency: load danh sách tiền tệ + fetch tỷ giá
// ViewModel gọi interface này, không đụng rootBundle/http/json

abstract class ICurrencyRepository {
  // Phương thức gọi để load danh sách từ json
  // Trả về List<Map<String, dynamic>>, mỗi map có: code, name, flag
  Future<List<Map<String, dynamic>>> getSupportedCurrencies();

  // Gọi API tỷ giá
  Future<Map<String, dynamic>> fetchExchangeRates(String baseCurrency);
}
