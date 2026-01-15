import 'dart:convert';
import 'package:http/http.dart' as http;

class WeatherService {
  static const String _geoBaseUrl = 'https://geocoding-api.open-meteo.com/v1';
  static const String _weatherBaseUrl = 'https://api.open-meteo.com/v1';

  // 1. Tìm địa điểm (Geocoding)
  static Future<List<Map<String, dynamic>>> searchLocations(
    String query,
  ) async {
    if (query.isEmpty) return [];

    final url =
        '$_geoBaseUrl/search?name=$query&count=10&language=en&format=json';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['results'] != null) {
        return (data['results'] as List).cast<Map<String, dynamic>>();
      }
    }
    return [];
  }

  // 2. Lấy dự báo thời tiết
  static Future<Map<String, dynamic>?> getForecast({
    required double latitude,
    required double longitude,
  }) async {
    final url =
        '$_weatherBaseUrl/forecast'
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
