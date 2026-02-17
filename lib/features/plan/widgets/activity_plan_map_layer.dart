import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

// Tạo layer map để chưa các vị trí pin map ở trên map để hiển thị trực quan
// Màu được tuỳ chỉnh theo trạng thái check in chưa check in hoặc chưa tới
class ActivityPlanMapLayer extends StatelessWidget {
  final MapController mapController;
  final List<LatLng> routePoints;
  final List<List<LatLng>>? routeSegments;
  final int currentIndex;
  final List<bool> isCheckedInByRoutePoint;
  final LatLng fallbackCenter;
  final VoidCallback? onMapReady;

  const ActivityPlanMapLayer({
    super.key,
    required this.mapController,
    required this.routePoints,
    this.routeSegments,
    this.currentIndex = 0,
    this.isCheckedInByRoutePoint = const [],
    this.fallbackCenter = const LatLng(21.028, 105.853),
    this.onMapReady,
  });

  @override
  Widget build(BuildContext context) {
    return FlutterMap(
      mapController: mapController,
      options: MapOptions(
        initialCenter: routePoints.isNotEmpty
            ? routePoints.first
            : fallbackCenter,
        initialZoom: routePoints.length >= 2 ? 12.0 : 10.0,
        onMapReady: onMapReady,
      ),
      children: [
        TileLayer(
          urlTemplate:
              'https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}{r}.png',
          subdomains: const ['a', 'b', 'c', 'd'],
          userAgentPackageName: 'com.travel.app',
          retinaMode: RetinaMode.isHighDensity(context),
        ),
        PolylineLayer(
          polylines: [
            for (int i = 0; i < routePoints.length - 1; i++) ...[
              Polyline(
                points:
                    routeSegments != null &&
                        i < routeSegments!.length &&
                        routeSegments![i].isNotEmpty
                    ? routeSegments![i]
                    : [routePoints[i], routePoints[i + 1]],
                color: _segmentColor(i),
                strokeWidth: 5,
              ),
            ],
          ],
        ),
        MarkerLayer(
          markers: [
            for (int i = 0; i < routePoints.length; i++)
              Marker(
                point: routePoints[i],
                width: 28,
                height: 28,
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _markerColor(i),
                  ),
                  child: _isCheckedInAt(i)
                      ? const Icon(Icons.check, color: Colors.white, size: 16)
                      : null,
                ),
              ),
          ],
        ),
      ],
    );
  }

  //=====================================================================//
  //                          HELPER FUNCTION                            //
  //=====================================================================//
  bool _isCheckedInAt(int routeIndex) {
    if (routeIndex < 0 || routeIndex >= isCheckedInByRoutePoint.length) {
      return false;
    }
    return isCheckedInByRoutePoint[routeIndex];
  }

  Color _markerColor(int routeIndex) {
    if (_isCheckedInAt(routeIndex)) return Colors.green;
    if (routeIndex == currentIndex) return const Color(0xFFFF6D00);
    return Colors.grey.shade700;
  }

  // Đoạn từ point [segmentIndex] đến point [segmentIndex+1]: xanh khi đã tới point segmentIndex+1 (check-in), cam khi đang đi đoạn này (đoạn dẫn TỚI điểm current: A→B khi B là current).
  Color _segmentColor(int segmentIndex) {
    final reachedEnd =
        segmentIndex + 1 < isCheckedInByRoutePoint.length &&
        isCheckedInByRoutePoint[segmentIndex + 1];
    if (reachedEnd) return Colors.green;
    // Đoạn đang đi = đoạn nối tới điểm current (segment (currentIndex-1) khi currentIndex>=1, hoặc segment 0 khi currentIndex=0).
    final isCurrentSegment =
        (currentIndex == 0 && segmentIndex == 0) ||
        (currentIndex > 0 && segmentIndex == currentIndex - 1);
    if (isCurrentSegment) return const Color(0xFFFF6D00);
    return Colors.white.withValues(alpha: 0.3);
  }
}
