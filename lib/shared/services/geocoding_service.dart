// GeocodingService - Gọi API tìm kiếm địa điểm (open-meteo cho city, Nominatim cho địa chỉ cụ thể)
// Tách riêng từ TimezoneService cũ để tuân thủ Single Responsibility Principle

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:travel_app/domain/services/i_geocoding_service.dart';

class GeocodingService implements IGeocodingService {
  final String _baseUrl;
  final String _nominatimBaseUrl;

  GeocodingService({String? baseUrl, String? nominatimBaseUrl})
    : _baseUrl = baseUrl ?? 'https://geocoding-api.open-meteo.com/v1',
      _nominatimBaseUrl =
          nominatimBaseUrl ?? 'https://nominatim.openstreetmap.org';

  static const _nominatimUserAgent =
      'TravelApp/1.0 (travel plan destination search)';

  @override
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

  // Tìm kiếm địa điểm vị trí cụ thể
  @override
  Future<List<Map<String, dynamic>>> searchPlaces(
    String query, {
    String? countryCodes,
  }) async {
    if (query.trim().isEmpty) return [];

    final encoded = Uri.encodeQueryComponent(query.trim());
    var url =
        '$_nominatimBaseUrl/search?q=$encoded&format=json&limit=10&addressdetails=0';
    if (countryCodes != null && countryCodes.isNotEmpty) {
      url += '&countrycodes=${Uri.encodeComponent(countryCodes)}';
    }
    final response = await http.get(
      Uri.parse(url),
      headers: {'User-Agent': _nominatimUserAgent},
    );

    if (response.statusCode != 200) return [];

    final list = json.decode(response.body);
    if (list is! List) return [];

    return list.map<Map<String, dynamic>>((item) {
      final lat = item['lat'];
      final lon = item['lon'];
      return {
        'displayName': item['display_name'] as String? ?? '',
        'latitude': lat is num
            ? lat.toDouble()
            : double.tryParse('$lat') ?? 0.0,
        'longitude': lon is num
            ? lon.toDouble()
            : double.tryParse('$lon') ?? 0.0,
      };
    }).toList();
  }

  // Geocoding tên địa điểm để trả về mã quốc gia
  @override
  Future<String?> getCountryCodeForPlace(String placeName) async {
    if (placeName.trim().isEmpty) return null;
    final encoded = Uri.encodeQueryComponent(placeName.trim());
    final url =
        '$_nominatimBaseUrl/search?q=$encoded&format=json&limit=1&addressdetails=1';
    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {'User-Agent': _nominatimUserAgent},
      );
      if (response.statusCode != 200) return null;
      final list = json.decode(response.body);
      if (list is! List || list.isEmpty) return null;
      final item = list.first as Map<String, dynamic>?;
      final address = item?['address'];
      if (address is! Map<String, dynamic>) return null;
      final code = address['country_code'];
      if (code is String && code.length == 2) return code.toLowerCase();
      return null;
    } catch (_) {
      return null;
    }
  }
}
