import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:travel_app/screen/Account/widgets/exchange_board_widget.dart';
import 'package:travel_app/screen/Account/widgets/exchange_rate_chart_widget.dart';

class CurrencyExchangeScreen extends StatefulWidget {
  const CurrencyExchangeScreen({super.key});

  @override
  State<CurrencyExchangeScreen> createState() => _CurrencyExchangeScreenState();
}

class _CurrencyExchangeScreenState extends State<CurrencyExchangeScreen> {
  final TextEditingController _amountController = TextEditingController(
    text: '100',
  );

  // Currencies from JSON
  List<Map<String, dynamic>> _currencies = [];
  Map<String, dynamic> _fromCurrency = {};
  Map<String, dynamic> _toCurrency = {};

  // Exchange rate data
  Map<String, dynamic> _rates = {};
  double _convertedAmount = 0;
  bool _isLoading = true;
  bool _isSwapPressed = false;

  @override
  void initState() {
    super.initState();
    _loadCurrencies();
    _amountController.addListener(_calculateConversion);
  }

  Future<void> _loadCurrencies() async {
    try {
      final String jsonString = await rootBundle.loadString(
        'lib/assets/data/supported_currencies.json',
      );
      final List<dynamic> jsonList = json.decode(jsonString);
      setState(() {
        _currencies = jsonList.cast<Map<String, dynamic>>();
        // Set defaults
        _fromCurrency = _currencies.firstWhere(
          (c) => c['code'] == 'USD',
          orElse: () => _currencies.first,
        );
        _toCurrency = _currencies.firstWhere(
          (c) => c['code'] == 'VND',
          orElse: () => _currencies.last,
        );
      });
      _fetchExchangeRates();
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _fetchExchangeRates() async {
    try {
      final apiKey = dotenv.env['CURRENCY_TOKEN'] ?? '';
      final response = await http.get(
        Uri.parse(
          'https://api.fxratesapi.com/latest?base=${_fromCurrency['code']}&api_key=$apiKey',
        ),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _rates = data['rates'];
          _isLoading = false;
        });
        _calculateConversion();
      }
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  void _calculateConversion() {
    if (_rates.isEmpty) return;

    final amount = double.tryParse(_amountController.text) ?? 0;
    final rate = _rates[_toCurrency['code']] ?? 1;

    setState(() {
      _convertedAmount = amount * rate;
    });
  }

  void _swapCurrencies() {
    setState(() {
      final temp = _fromCurrency;
      _fromCurrency = _toCurrency;
      _toCurrency = temp;
    });
    _fetchExchangeRates();
  }

  void _showCurrencyPicker(bool isFrom) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Color(0xFF1C1C1D),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                isFrom
                    ? 'currency.select_from'.tr()
                    : 'currency.select_to'.tr(),
                style: GoogleFonts.beVietnamPro(
                  color: Colors.white,
                  fontSize: 18,
                ),
              ),
              SizedBox(height: 15),
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: _currencies.length,
                  itemBuilder: (context, index) {
                    final currency = _currencies[index];
                    final isSelected = isFrom
                        ? currency['code'] == _fromCurrency['code']
                        : currency['code'] == _toCurrency['code'];
                    return ListTile(
                      leading: Text(
                        currency['flag']!,
                        style: GoogleFonts.beVietnamPro(fontSize: 24),
                      ),
                      title: Text(
                        '${currency['code']} - ${currency['name']}',
                        style: GoogleFonts.beVietnamPro(
                          color: isSelected ? Color(0xFFFFAD35) : Colors.white,
                        ),
                      ),
                      trailing: isSelected
                          ? Icon(Icons.check_circle, color: Color(0xFFFFAD35))
                          : null,
                      onTap: () {
                        setState(() {
                          if (isFrom) {
                            _fromCurrency = currency;
                          } else {
                            _toCurrency = currency;
                          }
                        });
                        Navigator.pop(context);
                        _fetchExchangeRates();
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _formatNumber(double number) {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Color(0xFF1C1C1D),
        iconTheme: IconThemeData(color: Colors.white),
        title: Text(
          'currency.title'.tr(),
          style: GoogleFonts.beVietnamPro(color: Colors.white),
        ),
        surfaceTintColor: Colors.transparent,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: Color(0xFFFFAD35)))
          : SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Column(
                  children: [
                    // From board
                    ExchangeBoardWidget(
                      showText: true,
                      showIcon: true,
                      label: 'currency.from'.tr(),
                      amount: _amountController.text,
                      currencyCode: _fromCurrency['code']!,
                      currencyName: _fromCurrency['name']!,
                      flag: _fromCurrency['flag']!,
                      isEditable: true,
                      controller: _amountController,
                      onCurrencyTap: () => _showCurrencyPicker(true),
                    ),

                    SizedBox(height: 10),

                    // Swap button
                    GestureDetector(
                      onTapDown: (_) => setState(() => _isSwapPressed = true),
                      onTapUp: (_) {
                        setState(() => _isSwapPressed = false);
                        _swapCurrencies();
                      },
                      onTapCancel: () => setState(() => _isSwapPressed = false),
                      child: AnimatedScale(
                        scale: _isSwapPressed ? 0.9 : 1.0,
                        duration: Duration(milliseconds: 100),
                        curve: Curves.easeInOut,
                        child: Container(
                          padding: EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Color(0xFFFFAD35),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.swap_vert,
                            color: Colors.black,
                            size: 24,
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: 10),

                    // To board
                    ExchangeBoardWidget(
                      label: 'currency.to'.tr(),
                      amount: _formatNumber(_convertedAmount),
                      currencyCode: _toCurrency['code']!,
                      currencyName: _toCurrency['name']!,
                      flag: _toCurrency['flag']!,
                      isEditable: false,
                      onCurrencyTap: () => _showCurrencyPicker(false),
                    ),

                    SizedBox(height: 20),

                    // 7-Day Chart
                    ExchangeRateChartWidget(
                      fromCurrency: _fromCurrency['code'] ?? 'USD',
                      toCurrency: _toCurrency['code'] ?? 'VND',
                    ),
                    SizedBox(height: 15),

                    // Exchange rate info
                    Text(
                      '${'currency.rate'.tr()}: 1 ${_fromCurrency['code']} = ${_formatNumber((_rates[_toCurrency['code']] ?? 0).toDouble())} ${_toCurrency['code']}',
                      style: GoogleFonts.beVietnamPro(
                        color: Colors.grey[400],
                        fontSize: 14,
                      ),
                    ),

                    SizedBox(height: 30),
                  ],
                ),
              ),
            ),
    );
  }
}
