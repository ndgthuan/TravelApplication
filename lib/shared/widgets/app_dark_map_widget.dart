// Widget map để tất cả các map đều dùng chung
// Tái sử dụng các map
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

// Map nền tối để dùng chung cho Explore Map và Ongoing Plan Section
// Tuỳ biến mapController để có thể kéo thả, di chuyển
// InitialCenter và initialZoom dùng khi khởi tạo
// onTap khi user tap lên map dùng để đổi vị trí pin
// onPositionChanged dùng khi zoom/pan (vd: Explore scale marker theo zoom)
class AppDarkMapWidget extends StatelessWidget {
  final MapController? mapController;
  final LatLng initialCenter;
  final double initialZoom;
  final void Function(TapPosition tapPosition, LatLng point)? onTap;
  final void Function(MapCamera camera, bool hasGesture)? onPositionChanged;
  final List<Widget> children;
  final double? height;
  final double? width;

  const AppDarkMapWidget({
    super.key,
    this.mapController,
    this.initialCenter = const LatLng(21.0285, 105.8542),
    this.initialZoom = 15,
    this.onTap,
    this.onPositionChanged,
    this.children = const [],
    this.height,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    final content = FlutterMap(
      mapController: mapController,
      options: MapOptions(
        initialCenter: initialCenter,
        initialZoom: initialZoom,
        onTap: onTap,
        onPositionChanged: onPositionChanged,
      ),
      children: [
        TileLayer(
          urlTemplate:
              'https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}{r}.png', // Bắt đầu gọi map
          subdomains: const ['a', 'b', 'c', 'd'],
          userAgentPackageName: 'com.travel.app',
          retinaMode: RetinaMode.isHighDensity(context),
        ),
        ...children,
      ],
    );
    if (height != null || width != null) {
      return SizedBox(
        height: height,
        width: width ?? double.infinity,
        child: content,
      );
    }
    return content;
  }
}
