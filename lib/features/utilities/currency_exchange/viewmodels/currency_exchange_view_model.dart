// Mục đích của file này quản lý state và logic cho CurrencyExchangeScreen
// UI chỉ gọi method và lắng nghe state, không xử lý logic
import 'package:flutter/widgets.dart';
import 'package:travel_app/domain/repositories/i_currency_repository.dart';

class CurrencyExchangeViewModel extends ChangeNotifier {
  //==========================================================================//
  //                        DEPENDENCIES                                      //
  //==========================================================================//
  final ICurrencyRepository _currencyRepository;
  CurrencyExchangeViewModel(this._currencyRepository);

  //==========================================================================//
  //                        STATE VARIABLES                                   //
  //==========================================================================//
  // Khai báo biến để gọi bên UI
  List<Map<String, dynamic>> _currencies = [];
  Map<String, dynamic> _fromCurrency = {};
  Map<String, dynamic> _toCurrency = {};
  Map<String, dynamic> _rates = {};
  double _convertedAmount = 0;
  bool _isLoading = true;

  //==========================================================================//
  //                        GETTERS                                           //
  //==========================================================================//
  // Các hàm gọi bên UI
  List<Map<String, dynamic>> get currencies => _currencies;
  Map<String, dynamic> get fromCurrency => _fromCurrency;
  Map<String, dynamic> get toCurrency => _toCurrency;
  Map<String, dynamic> get rates => _rates;
  double get convertedAmount => _convertedAmount;
  bool get isLoading => _isLoading;

  //==========================================================================//
  //                        ACTION METHODS                                    //
  //==========================================================================//
  // Giá trị mặc định để tính khi load xong
  String _defaultAmount = '10';

  // Load danh sách currencies từ JSON
  Future<void> loadCurrencies({String defaultAmount = '10'}) async {
    _defaultAmount = defaultAmount;
    try {
      _currencies = await _currencyRepository.getSupportedCurrencies();

      _fromCurrency = _currencies.isNotEmpty
          ? _currencies.firstWhere(
              (c) => c['code'] == 'USD',
              orElse: () => _currencies.first,
            )
          : {};
      _toCurrency = _currencies.isNotEmpty
          ? _currencies.firstWhere(
              (c) => c['code'] == 'VND',
              orElse: () => _currencies.last,
            )
          : {};
      notifyListeners();
      await fetchExchangeRates();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Fetch tỷ giá từ API
  Future<void> fetchExchangeRates() async {
    try {
      final base = _fromCurrency['code']?.toString() ?? 'USD';
      _rates = await _currencyRepository.fetchExchangeRates(base);
      _isLoading = false;
      calculateConversion(_defaultAmount);
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Tính toán quy đổi
  void calculateConversion(String amountText) {
    if (_rates.isEmpty) return;
    final amount = double.tryParse(amountText) ?? 0;
    final rate = _rates[_toCurrency['code']] ?? 1;
    _convertedAmount = amount * rate;
    notifyListeners();
  }

  // Swap 2 loại tiền tệ
  Future<void> swapCurrencies() async {
    final temp = _fromCurrency;
    _fromCurrency = _toCurrency;
    _toCurrency = temp;
    notifyListeners();
    await fetchExchangeRates();
  }

  // Chọn tiền tệ
  Future<void> selectCurrency(
    Map<String, dynamic> currency,
    bool isFrom,
  ) async {
    if (isFrom) {
      _fromCurrency = currency;
    } else {
      _toCurrency = currency;
    }
    notifyListeners();
    await fetchExchangeRates();
  }

  //==========================================================================//
  //                        PRIVATE HELPERS                                   //
  //==========================================================================//
  // Format số
  String formatNumber(double number) {
    if (number == 0) return '0.00';
    if (number < 0.01) return number.toStringAsFixed(6);
    if (number >= 1000000) {
      return number
          .toStringAsFixed(2)
          .replaceAllMapped(
            RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
            (Match m) => '${m[1]},',
          );
    }
    return number.toStringAsFixed(2);
  }
}
