// Logic được gọi từ đây qua i_currency_repository
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:travel_app/domain/repositories/i_currency_repository.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class CurrencyRepositoryImpl implements ICurrencyRepository {
  @override
  Future<List<Map<String, dynamic>>> getSupportedCurrencies() async {
    final String jsonString = await rootBundle.loadString(
      'lib/assets/data/supported_currencies.json', // Gọi file json để load danh sách tiền tệ
    );
    final List<dynamic> jsonList = json.decode(jsonString);
    return jsonList.cast<Map<String, dynamic>>();
  }

  @override
  // Fetch tỷ giá từ API
  Future<Map<String, dynamic>> fetchExchangeRates(String baseCurrency) async {
    final apiKey = dotenv.env['CURRENCY_TOKEN'] ?? '';
    final response = await http.get(
      Uri.parse(
        'https://api.fxratesapi.com/latest?base=$baseCurrency&api_key=$apiKey',
      ),
    );
    if (response.statusCode != 200) {
      return {};
    }
    final data = json.decode(response.body);
    final rates = data['rates'];
    return rates is Map<String, dynamic> ? rates : {};
  }
}
