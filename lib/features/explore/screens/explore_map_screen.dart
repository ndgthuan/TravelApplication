import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:latlong2/latlong.dart';
import 'package:travel_app/shared/widgets/app_text_field_widget.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ExploreMapScreen extends StatefulWidget {
  const ExploreMapScreen({super.key});

  @override
  State<ExploreMapScreen> createState() => _ExploreMapScreenState();
}

class _ExploreMapScreenState extends State<ExploreMapScreen> {
  bool isLoading = false;
  bool _showInfoWindow = false;
  final MapController _mapController = MapController();

  @override
  Widget build(BuildContext context) {
    double currentZoom = 15.0;
    try {
      currentZoom = _mapController.camera.zoom;
    } catch (_) {
      // Map chưa render xong thì dùng giá trị mặc định
    }

    double heightFactor = currentZoom >= 17.0 ? 3.6 : 4.0;

    double markerSize =
        50.0 * (currentZoom / 18.0); // Zoom càng nhỏ thì marker càng bé
    markerSize = markerSize.clamp(5.0, 80.0);
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController, // Gán controller vào đây
            options: MapOptions(
              initialCenter: LatLng(
                10.7769,
                106.7009,
              ), // Tọa độ mặc định (ví dụ: Chợ Bến Thành)
              initialZoom: 15.0, // Độ zoom ban đầu
              // Lắng nghe zoom để scale marker
              onPositionChanged: (camera, hasGesture) {
                if (hasGesture) {
                  setState(() {});
                }
              },
              onTap: (tapPosition, point) {
                // Đóng Info Window khi bấm ra ngoài bản đồ
                if (_showInfoWindow) {
                  setState(() {
                    _showInfoWindow = false;
                  });
                }
              },
            ),
            children: [
              TileLayer(
                urlTemplate:
                    'https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}{r}.png',
                subdomains: const ['a', 'b', 'c', 'd'],
                userAgentPackageName: 'com.travel.app', // Tên package ứng dụng
                retinaMode: RetinaMode.isHighDensity(context),
              ),

              MarkerLayer(
                markers: [
                  // 1. The Pin Marker
                  Marker(
                    point: LatLng(10.7725, 106.6980),
                    width: markerSize,
                    height: markerSize,
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _showInfoWindow =
                              !_showInfoWindow; // Toggle visibility
                        });
                      },
                      child: const Icon(
                        Icons.location_on,
                        color: Color(0xFFFFAD35),
                        size: 40,
                      ),
                    ),
                  ),

                  // 2. The Info Window Marker (Only if visible)
                  if (_showInfoWindow)
                    Marker(
                      point: LatLng(10.7725, 106.6980),
                      width:
                          markerSize *
                          5, // Tăng chiều rộng để chứa ảnh và thông tin
                      height: markerSize * heightFactor, // Tăng chiều cao
                      alignment: Alignment.topCenter,
                      child: Transform.translate(
                        offset: Offset(0, -markerSize * 0.8),
                        child: GestureDetector(
                          onTap: () {
                            // Xử lý khi bấm vào bảng thông tin (ví dụ: vào trang chi tiết)
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(15),
                              boxShadow: const [
                                BoxShadow(
                                  blurRadius: 15,
                                  color: Colors.black38,
                                  offset: Offset(0, 5),
                                ),
                              ],
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Ảnh địa điểm
                                Expanded(
                                  child: ClipRRect(
                                    borderRadius: const BorderRadius.vertical(
                                      top: Radius.circular(15),
                                    ),
                                    child: CachedNetworkImage(
                                      imageUrl:
                                          "https://lh3.googleusercontent.com/p/AF1QipMcim0JXqpdWGyptHTkJe2JrcgHuhvFxMEGAK8u=w800-h600-k-no",
                                      width: double.infinity,
                                      fit: BoxFit.cover,
                                      placeholder: (context, url) =>
                                          Container(color: Colors.grey[300]),
                                      errorWidget: (context, url, error) =>
                                          const Icon(Icons.error),
                                    ),
                                  ),
                                ),

                                // Thông tin bên dưới
                                Padding(
                                  padding: const EdgeInsets.all(5),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // Tên địa điểm
                                      FittedBox(
                                        fit: BoxFit.scaleDown,
                                        alignment: Alignment.centerLeft,
                                        child: Text(
                                          "Ben Thanh Market",
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: GoogleFonts.beVietnamPro(
                                            fontSize: 16,
                                            color: Colors.black,
                                          ),
                                        ),
                                      ),

                                      // Row đánh giá
                                      FittedBox(
                                        fit: BoxFit.scaleDown,
                                        alignment: Alignment.centerLeft,
                                        child: Row(
                                          children: [
                                            const Icon(
                                              Icons.star,
                                              color: Colors.amber,
                                              size: 14,
                                            ),
                                            const SizedBox(width: 2),
                                            Text(
                                              "4.8",
                                              style: GoogleFonts.beVietnamPro(
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.black87,
                                              ),
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              "(12.5k reviews)",
                                              style: GoogleFonts.beVietnamPro(
                                                fontSize: 12,
                                                color: Colors.grey[600],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              // Nguồn openstreetmap
              RichAttributionWidget(
                attributions: [
                  TextSourceAttribution('OpenStreetMap, CartoDB', onTap: () {}),
                ],
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 40),
            child: Column(
              children: [
                AppTextFieldWidget(
                  hintText: 'Search destinations...',
                  prefixIcon: Icons.search,
                  suffixIcon: Icon(
                    CupertinoIcons.xmark_circle,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),

          Positioned(
            bottom: 5,
            right: 10,
            child: Column(
              children: [
                // Nút tái cấu hình map
                Container(
                  height: 60,
                  width: 60,
                  decoration: BoxDecoration(
                    color: Color(0xFF2A2A2A),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Icon(Icons.my_location, color: Color(0xFFFFAD35)),
                ),
                const SizedBox(height: 10),

                // Nút quay về trang My Saves
                GestureDetector(
                  onTapDown: (_) => setState(() => isLoading = true),
                  onTapUp: (_) => setState(() => isLoading = false),
                  onTapCancel: () => setState(() => isLoading = false),
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: AnimatedScale(
                    scale: isLoading ? 0.95 : 1.0,
                    duration: const Duration(milliseconds: 100),
                    curve: Curves.easeInOut,
                    child: Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0xFF2A2A2A),
                      ),
                      child: Icon(
                        CupertinoIcons.arrow_down_to_line_alt,
                        color: Color(0xFFFFAD35),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
