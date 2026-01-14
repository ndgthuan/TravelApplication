import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class WeatherService {
  static final String _apiKey = dotenv.env['WEATHER_TOKEN'] ?? '';
  static const String _baseUrl = 'https://api.weatherapi.com/v1';

  // 1. Tìm địa điểm
  static Future<List<Map<String, dynamic>>> searchLocations(
    String query,
  ) async {
    if (query.isEmpty) return [];

    final url = '$_baseUrl/search.json?key=$_apiKey&q=$query';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final List data = json.decode(response.body);
      return data.cast<Map<String, dynamic>>();
    }
    return [];
  }

  // 2. Lấy kết quả thời tiết (current + hourly + daily)
  static Future<Map<String, dynamic>?> getForecast(
    String location, {
    String lang = 'en',
  }) async {
    final url =
        '$_baseUrl/forecast.json?key=$_apiKey&q=$location&days=10&aqi=no&lang=$lang';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      return json.decode(response.body);
    }
    return null;
  }
}
