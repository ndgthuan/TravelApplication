/// GeocodingService - Chỉ lo việc gọi API tìm kiếm địa điểm
/// Tách riêng từ TimezoneService cũ để tuân thủ Single Responsibility Principle

import 'dart:convert';
import 'package:http/http.dart' as http;

class GeocodingService {
  final String _baseUrl;

  // Constructor cho phép inject base URL
  GeocodingService({String? baseUrl})
    : _baseUrl = baseUrl ?? 'https://geocoding-api.open-meteo.com/v1';

  /// Tìm kiếm thành phố theo tên
  Future<List<Map<String, dynamic>>> searchCities(String query) async {
    if (query.isEmpty) return [];

    final url = '$_baseUrl/search?name=$query&count=10&language=en&format=json';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['results'] != null) {
        return (data['results'] as List)
            .map((item) {
              return {
                'city': item['name'] ?? '',
                'country': item['country'] ?? '',
                'timezone': item['timezone'] ?? 'UTC',
                'latitude': item['latitude'] ?? 0.0,
                'longitude': item['longitude'] ?? 0.0,
              };
            })
            .toList()
            .cast<Map<String, dynamic>>();
      }
    }
    return [];
  }
}
