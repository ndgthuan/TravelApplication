// Mục đích của file này quản lý state và logic cho CurrencyExchangeScreen
// UI chỉ gọi method và lắng nghe state, không xử lý logic
import 'package:flutter/widgets.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:travel_app/domain/models/historical_rates_model.dart';
import 'package:travel_app/domain/repositories/i_currency_repository.dart';
import 'package:travel_app/domain/models/currency_model.dart';

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
  List<CurrencyModel> _currencies = [];
  Map<String, dynamic> _fromCurrency = {};
  Map<String, dynamic> _toCurrency = {};
  Map<String, double> _rates = {};
  double _convertedAmount = 0;
  bool _isLoading = true;
  String _errorMessage = '';
  HistoricalRatesModel? _chartData;
  bool _isChartLoading = true;
  String? _chartError;

  //==========================================================================//
  //                        GETTERS                                           //
  //==========================================================================//
  // Các hàm gọi bên UI
  List<CurrencyModel> get currencies => _currencies;
  Map<String, dynamic> get fromCurrency => _fromCurrency;
  Map<String, dynamic> get toCurrency => _toCurrency;
  Map<String, double> get rates => _rates;
  double get convertedAmount => _convertedAmount;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;
  HistoricalRatesModel? get chartData => _chartData;
  bool get isChartLoading => _isChartLoading;
  String? get chartError => _chartError;

  //==========================================================================//
  //                        ACTION METHODS                                    //
  //==========================================================================//
  // Giá trị mặc định để tính khi load xong
  String _defaultAmount = '10';

  void clearError() {
    _errorMessage = '';
    notifyListeners();
  }

  // Load danh sách currencies từ JSON, set default from/to, fetch rates + chart
  Future<void> loadCurrencies({String? defaultAmount}) async {
    _defaultAmount = defaultAmount ?? '10';
    _errorMessage = '';
    try {
      _currencies = await _currencyRepository.getSupportedCurrencies();
      if (_currencies.length >= 2) {
        _fromCurrency = {
          'code': _currencies[0].code,
          'name': _currencies[0].name,
          'flag': _currencies[0].flag,
        };
        _toCurrency = {
          'code': _currencies[1].code,
          'name': _currencies[1].name,
          'flag': _currencies[1].flag,
        };
        await fetchExchangeRates(_currencies[0].code);
        calculateConversion(_defaultAmount);
        await fetchChartData();
      }
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'currency.load_error'.tr();
      notifyListeners();
    }
  }

  // Fetch tỷ giá từ API
  Future<void> fetchExchangeRates(String baseCurrency) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      final result = await _currencyRepository.fetchExchangeRates(baseCurrency);
      _rates = result.rates;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'currency.fetch_rates_error'.tr();
      notifyListeners();
    }
  }

  // Tính toán quy đổi
  void calculateConversion(String amountText) {
    if (_rates.isEmpty) return;
    final amount = double.tryParse(amountText) ?? 0;
    final code = _toCurrency['code'] as String?;
    final rate = (code != null ? _rates[code] : null) ?? 1.0;
    _convertedAmount = amount * rate;
    notifyListeners();
  }

  // Swap 2 loại tiền tệ
  Future<void> swapCurrencies() async {
    final temp = _fromCurrency;
    _fromCurrency = _toCurrency;
    _toCurrency = temp;
    notifyListeners();
    final base = _fromCurrency['code'] as String?;
    if (base != null) await fetchExchangeRates(base);
    await fetchChartData();
  }

  // Chọn tiền tệ (nhận CurrencyModel từ UI)
  Future<void> selectCurrency(CurrencyModel currency, bool isFrom) async {
    final map = {
      'code': currency.code,
      'name': currency.name,
      'flag': currency.flag,
    };
    if (isFrom) {
      _fromCurrency = map;
    } else {
      _toCurrency = map;
    }
    notifyListeners();
    final base = _fromCurrency['code'] as String?;
    if (base != null) await fetchExchangeRates(base);
    await fetchChartData();
  }

  Future<void> fetchChartData() async {
    final base = _fromCurrency['code'] as String?;
    final target = _toCurrency['code'] as String?;
    if (base == null || target == null || base.isEmpty || target.isEmpty) {
      _chartData = null;
      _chartError = null;
      _isChartLoading = false;
      notifyListeners();
      return;
    }

    _isChartLoading = true;
    _chartError = null;
    notifyListeners();

    try {
      _chartData = await _currencyRepository.fetchHistoricalRates(
        baseCurrency: base,
        targetCurrency: target,
      );
      _chartError = null;
    } catch (e) {
      _chartData = null;
      _chartError = 'currency.unsupported_currency'.tr();
    }
    _isChartLoading = false;
    notifyListeners();
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
