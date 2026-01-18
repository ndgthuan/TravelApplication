// WeatherService chỉ lo gọi API lấy dữ liệu thời tiết

import 'dart:convert';
import 'package:http/http.dart' as http;

class WeatherService {
  final String _baseUrl;

  // Constructor cho phép inject base URL
  WeatherService({String? baseUrl})
    : _baseUrl = baseUrl ?? 'https://api.open-meteo.com/v1';

  /// Lấy dự báo thời tiết theo toạ độ
  Future<Map<String, dynamic>?> getForecast({
    required double latitude,
    required double longitude,
  }) async {
    final url =
        '$_baseUrl/forecast'
        '?latitude=$latitude'
        '&longitude=$longitude'
        '&current=temperature_2m,relative_humidity_2m,weather_code,wind_speed_10m,uv_index'
        '&hourly=temperature_2m,weather_code'
        '&daily=weather_code,temperature_2m_max,temperature_2m_min'
        '&timezone=auto'
        '&forecast_days=14';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      return json.decode(response.body);
    }
    return null;
  }
}
