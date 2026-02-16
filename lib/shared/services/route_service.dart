import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:latlong2/latlong.dart';
import 'package:travel_app/domain/services/i_route_service.dart';
import 'package:travel_app/shared/services/open_route_service.dart';

// Triển khai [IRouteService] sử dụng OpenRouteService làm nguồn chính.
class RouteService implements IRouteService {
  @override
  Future<List<List<LatLng>>> buildSegments(
    List<LatLng> pointsInTimeOrder,
  ) async {
    final apiKey = dotenv.env['OPENROUTE_SERVICE_API_KEY'];
    final segments = <List<LatLng>>[];

    if (pointsInTimeOrder.length < 2) return segments;

    for (int i = 0; i < pointsInTimeOrder.length - 1; i++) {
      final start = pointsInTimeOrder[i];
      final end = pointsInTimeOrder[i + 1];

      final roadPath = await OpenRouteService.getRoadRoute(apiKey, start, end);

      // Chỉ dùng OpenRouteService; nếu lỗi thì nối đoạn thẳng A→B.
      segments.add(
        (roadPath != null && roadPath.length >= 2)
            ? roadPath
            : <LatLng>[start, end],
      );
    }

    return segments;
  }
}
