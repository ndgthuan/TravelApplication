// Định nghĩa hợp đồng cho Currency: load danh sách tiền tệ + fetch tỷ giá
// ViewModel gọi interface này, không đụng rootBundle/http/json
import 'package:travel_app/domain/models/currency_model.dart';
import 'package:travel_app/domain/models/historical_rates_model.dart';

abstract class ICurrencyRepository {
  // Lấy danh sách tiền tệ được hỗ trợ
  // Throws [Exception] nếu có lỗi khi load
  Future<List<CurrencyModel>> getSupportedCurrencies();

  // Lấy tỷ giá từ API
  // [baseCurrency] - Mã tiền tệ cơ sở (ví dụ: 'USD')
  // Throws [Exception] nếu API call thất bại
  Future<ExchangeRateModel> fetchExchangeRates(String baseCurrency);

  // Lấy dữ liệu tỷ giá 7 ngày (timeseries) cho biểu đồ.
  Future<HistoricalRatesModel> fetchHistoricalRates({
    required String baseCurrency,
    required String targetCurrency,
  });
}
