import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

// Gọi OpenRouteService để lấy đường đi theo đường bộ (không cắt qua sông/hồ).
// Cần key tại https://openrouteservice.org/dev/#/signup
// Thêm vào .env: OPENROUTE_SERVICE_API_KEY=your_key
class OpenRouteService {
  static const _directionsUrl =
      'https://api.openrouteservice.org/v2/directions/driving-car/geojson';

  // Trả về danh sách điểm theo đường bộ từ [start] đến [end], hoặc null nếu lỗi/không có key.
  static Future<List<LatLng>?> getRoadRoute(
    String? apiKey,
    LatLng start,
    LatLng end,
  ) async {
    if (apiKey == null || apiKey.trim().isEmpty) return null;
    final key = apiKey.trim();
    try {
      final body = jsonEncode({
        'coordinates': [
          [start.longitude, start.latitude],
          [end.longitude, end.latitude],
        ],
      });
      final res = await http
          .post(
            Uri.parse(_directionsUrl),
            headers: {'Authorization': key, 'Content-Type': 'application/json'},
            body: body,
          )
          .timeout(const Duration(seconds: 10));
      if (res.statusCode != 200) return null;
      final data = jsonDecode(res.body) as Map<String, dynamic>;
      final features = data['features'] as List<dynamic>?;
      if (features == null || features.isEmpty) return null;
      final geom =
          (features.first as Map<String, dynamic>)['geometry']
              as Map<String, dynamic>?;
      final coordsList = geom?['coordinates'] as List<dynamic>?;
      if (coordsList == null || coordsList.isEmpty) return null;
      return coordsList.map((e) {
        final list = e as List;
        return LatLng((list[1] as num).toDouble(), (list[0] as num).toDouble());
      }).toList();
    } catch (_) {
      return null;
    }
  }
}
