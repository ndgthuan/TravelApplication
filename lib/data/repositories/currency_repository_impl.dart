// Logic được gọi từ đây qua i_currency_repository
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:travel_app/domain/repositories/i_currency_repository.dart';
import 'package:travel_app/domain/models/currency_model.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:travel_app/domain/models/historical_rates_model.dart';

class CurrencyRepositoryImpl implements ICurrencyRepository {
  @override
  Future<List<CurrencyModel>> getSupportedCurrencies() async {
    try {
      final String jsonString = await rootBundle.loadString(
        'lib/assets/data/supported_currencies.json',
      );
      final List<dynamic> jsonList = json.decode(jsonString);
      return jsonList.map((item) => CurrencyModel.fromJson(item)).toList();
    } catch (e) {
      throw Exception('Failed to load supported currencies: $e');
    }
  }

  @override
  Future<ExchangeRateModel> fetchExchangeRates(String baseCurrency) async {
    try {
      final response = await http.get(
        Uri.parse('https://api.fxratesapi.com/latest?base=$baseCurrency'),
      );

      if (response.statusCode != 200) {
        throw Exception('API returned status code: ${response.statusCode}');
      }

      final data = json.decode(response.body);
      final rates = data['rates'];

      if (rates == null || rates is! Map<String, dynamic>) {
        throw Exception('Invalid rates data from API');
      }

      // Convert dynamic values to double
      final Map<String, double> parsedRates = {};
      rates.forEach((key, value) {
        parsedRates[key] = (value as num).toDouble();
      });

      return ExchangeRateModel(baseCurrency: baseCurrency, rates: parsedRates);
    } catch (e) {
      throw Exception('Failed to fetch exchange rates: $e');
    }
  }

  @override
  Future<HistoricalRatesModel> fetchHistoricalRates({
    required String baseCurrency,
    required String targetCurrency,
  }) async {
    try {
      final endDate = DateTime.now().subtract(
        Duration(days: 1),
      ); // Sử dụng ngày hôm qua để tránh lỗi timezone
      final startDate = endDate.subtract(Duration(days: 6));
      final startStr = DateFormat('yyyy-MM-dd').format(startDate);
      final endStr = DateFormat('yyyy-MM-dd').format(endDate);
      final apiKey = dotenv.env['CURRENCY_TOKEN'] ?? '';
      final url =
          'https://api.fxratesapi.com/timeseries?start_date=$startStr&end_date=$endStr&base=$baseCurrency&currencies=$targetCurrency&api_key=$apiKey';

      final response = await http.get(Uri.parse(url));

      if (response.statusCode != 200) {
        throw Exception('Historical rates API returned ${response.statusCode}');
      }

      final data = json.decode(response.body) as Map<String, dynamic>;
      final rates = data['rates'];
      if (rates == null || rates is! Map<String, dynamic>) {
        throw Exception('Invalid historical rates data');
      }

      final sortedDates = rates.keys.toList()..sort();
      final List<String> labels = [];
      final List<double> values = [];

      for (final dateStr in sortedDates) {
        final rateData = rates[dateStr] as Map<String, dynamic>;
        final v = rateData[targetCurrency];
        if (v != null) values.add((v as num).toDouble());
        final date = DateTime.parse(dateStr);
        labels.add(DateFormat('E').format(date));
      }

      return HistoricalRatesModel(dayLabels: labels, rateValues: values);
    } catch (e) {
      throw Exception('Failed to fetch historical rates: $e');
    }
  }
}
