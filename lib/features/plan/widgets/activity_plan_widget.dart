import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:travel_app/features/plan/screens/add_activity_screen.dart';

class ActivityPlanWidget extends StatefulWidget {
  const ActivityPlanWidget({super.key});

  @override
  State<ActivityPlanWidget> createState() => _ActivityPlanWidgetState();
}

class _ActivityPlanWidgetState extends State<ActivityPlanWidget> {
  final _mapController = MapController();

  // 6 địa điểm Hà Nội
  static const _routePoints = [
    LatLng(21.022, 105.848), // 0 - Sân bay Nội Bài (đã đi)
    LatLng(21.026, 105.852), // 1 - Khách sạn Metropole (đang đi)
    LatLng(21.030, 105.855), // 2 - Phở Bát Đàn
    LatLng(21.032, 105.851), // 3 - Văn Miếu
    LatLng(21.034, 105.848), // 4 - Hồ Hoàn Kiếm
    LatLng(21.036, 105.845), // 5 - Phố cổ
  ];
  static const _currentIndex = 1; // index đang hành động

  /// Đường đi theo đường thật từ OpenRouteService (mỗi phần tử = 1 đoạn từ điểm i -> i+1)
  List<List<LatLng>>? _routeSegments;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _fitMapToCurrentAndNext(),
    );
    _fetchRouteFromOpenRouteService();
  }

  /// Gọi OpenRouteService để lấy đường đi theo đường (không cắt qua sông/hồ).
  /// Cần key miễn phí tại https://openrouteservice.org/dev/#/signup
  /// Thêm vào .env: OPENROUTE_SERVICE_API_KEY=your_key
  Future<void> _fetchRouteFromOpenRouteService() async {
    final apiKey = dotenv.env['OPENROUTE_SERVICE_API_KEY']?.trim();
    if (apiKey == null || apiKey.isEmpty) {
      if (mounted) setState(() {});
      return;
    }
    final segments = <List<LatLng>>[];
    for (int i = 0; i < _routePoints.length - 1; i++) {
      try {
        final coords = [
          [_routePoints[i].longitude, _routePoints[i].latitude],
          [_routePoints[i + 1].longitude, _routePoints[i + 1].latitude],
        ];
        final res = await http.post(
          Uri.parse(
            'https://api.openrouteservice.org/v2/directions/driving-car/geojson',
          ),
          headers: {
            'Authorization': apiKey,
            'Content-Type': 'application/json',
          },
          body: jsonEncode({'coordinates': coords}),
        );
        if (res.statusCode == 200) {
          final data = jsonDecode(res.body) as Map<String, dynamic>;
          final features = data['features'] as List<dynamic>?;
          List<dynamic>? coordsList;
          if (features != null && features.isNotEmpty) {
            final geom =
                (features.first as Map<String, dynamic>)['geometry']
                    as Map<String, dynamic>?;
            coordsList = geom?['coordinates'] as List<dynamic>?;
          }
          if (coordsList != null && coordsList.isNotEmpty) {
            segments.add(
              coordsList.map((e) => LatLng((e as List)[1], (e)[0])).toList(),
            );
            continue;
          }
        }
      } catch (_) {}
      segments.add([_routePoints[i], _routePoints[i + 1]]);
    }
    if (mounted) {
      setState(() {
        _routeSegments = segments;
      });
    }
  }

  void _fitMapToCurrentAndNext() {
    if (!mounted) return;
    final screenHeight = MediaQuery.sizeOf(context).height;
    // Padding dưới lớn = phần sheet che → 2 điểm nằm trên vùng map thấy được (trên panel)
    final bottomPadding = screenHeight * 0.52;
    if (_currentIndex + 1 < _routePoints.length) {
      final bounds = LatLngBounds.fromPoints([
        _routePoints[_currentIndex],
        _routePoints[_currentIndex + 1],
      ]);
      _mapController.fitCamera(
        CameraFit.bounds(
          bounds: bounds,
          padding: EdgeInsets.fromLTRB(50, 80, 50, bottomPadding),
        ),
      );
    } else {
      _mapController.move(_routePoints[_currentIndex], 17);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF000000),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Map làm nền
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: const LatLng(21.028, 105.853),
              initialZoom: 10,
            ),
            children: [
              TileLayer(
                urlTemplate:
                    'https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}{r}.png',
                subdomains: const ['a', 'b', 'c', 'd'],
                userAgentPackageName: 'com.travel.app',
                retinaMode: RetinaMode.isHighDensity(context),
              ),
              // Đường đi: đã đi = xanh, đang đi = cam, chưa đi = trắng mờ (theo đường thật nếu có ORS)
              PolylineLayer(
                polylines: [
                  for (int i = 0; i < _routePoints.length - 1; i++)
                    Polyline(
                      points:
                          _routeSegments != null &&
                              i < _routeSegments!.length &&
                              _routeSegments![i].isNotEmpty
                          ? _routeSegments![i]
                          : [_routePoints[i], _routePoints[i + 1]],
                      color: i < _currentIndex
                          ? Colors.green
                          : i == _currentIndex
                          ? const Color(0xFFFF6D00)
                          : Colors.white.withValues(alpha: 0.3),
                      strokeWidth: 5,
                    ),
                ],
              ),
              MarkerLayer(
                markers: [
                  for (int i = 0; i < _routePoints.length; i++)
                    Marker(
                      point: _routePoints[i],
                      width: 28,
                      height: 28,
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: i < _currentIndex
                              ? Colors.green
                              : i == _currentIndex
                              ? const Color(0xFFFF6D00)
                              : Colors.grey.shade700,
                        ),
                        child: i < _currentIndex
                            ? const Icon(
                                Icons.check,
                                color: Colors.white,
                                size: 16,
                              )
                            : null,
                      ),
                    ),
                ],
              ),
            ],
          ),

          // Appbar đè lên map
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.fromLTRB(8, 45, 8, 12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.black54, Colors.transparent],
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: Icon(CupertinoIcons.back, color: Colors.white),
                  ),
                  Expanded(
                    child: Text(
                      'Chi tiết chuyến đi',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.beVietnamPro(
                        color: Colors.white,
                        fontSize: 22,
                      ),
                    ),
                  ),

                  IconButton(
                    onPressed: () {},
                    icon: Icon(
                      CupertinoIcons.ellipsis_vertical,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),

          DraggableScrollableSheet(
            initialChildSize: 0.5,
            minChildSize: 0.25,
            maxChildSize: 0.9,
            builder: (context, scrollController) {
              return Container(
                decoration: BoxDecoration(
                  color: Colors.transparent.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Thanh ngang để kéo
                    Padding(
                      padding: const EdgeInsets.only(top: 12, bottom: 8),
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.white24,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    Expanded(
                      child: SingleChildScrollView(
                        controller: scrollController,
                        padding: EdgeInsets.fromLTRB(
                          20,
                          0,
                          20,
                          24 + MediaQuery.paddingOf(context).bottom,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Title + date gắn chung với scroll
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Hà Nội - Mùa Thu',
                                  style: GoogleFonts.beVietnamPro(
                                    color: Colors.white,
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),

                                IconButton(
                                  onPressed: () {
                                    Navigator.of(
                                      context,
                                      rootNavigator: true,
                                    ).push(
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            AddActivityScreen(),
                                      ),
                                    );
                                  },
                                  icon: Icon(
                                    CupertinoIcons.add,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '10/10 - 15/10',
                              style: GoogleFonts.beVietnamPro(
                                color: Colors.white70,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 20),
                            Row(
                              children: [
                                SizedBox(
                                  width: 56,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '08:00',
                                        style: GoogleFonts.beVietnamPro(
                                          color: Colors.white.withValues(
                                            alpha: 0.8,
                                          ),
                                          fontSize: 18,
                                        ),
                                      ),
                                      Container(
                                        height: 115, // Các value cần gán
                                        decoration: BoxDecoration(
                                          color: Colors.transparent,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Column(
                                  children: [
                                    Icon(
                                      CupertinoIcons.check_mark_circled_solid,
                                      color: Colors.green,
                                      size: 25,
                                    ),
                                    Container(
                                      height: 115, // Các value cần gán
                                      width: 2,
                                      decoration: BoxDecoration(
                                        color: Colors.greenAccent,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(width: 10),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '08:00',
                                      style: GoogleFonts.beVietnamPro(
                                        color: Colors.white.withValues(
                                          alpha: 0.8,
                                        ),
                                        fontSize: 18,
                                      ),
                                    ),
                                    Text(
                                      "Sân bay nội bài",
                                      style: GoogleFonts.beVietnamPro(
                                        color: Colors.white,
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 2),

                                    Row(
                                      children: [
                                        Icon(
                                          CupertinoIcons.pin,
                                          color: Colors.white.withValues(
                                            alpha: 0.8,
                                          ),
                                          size: 16,
                                        ),
                                        const SizedBox(width: 2),
                                        Text(
                                          '90/9A Hoà Bình, P5, Q11',
                                          style: GoogleFonts.beVietnamPro(
                                            color: Colors.white.withValues(
                                              alpha: 0.8,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 5),
                                    Container(
                                      decoration: BoxDecoration(
                                        color: Colors.green.withValues(
                                          alpha: 0.2,
                                        ),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.fromLTRB(
                                          10,
                                          3,
                                          10,
                                          3,
                                        ),
                                        child: Row(
                                          children: [
                                            Icon(
                                              CupertinoIcons
                                                  .check_mark_circled_solid,
                                              color: Colors.green,
                                              size: 18,
                                            ),
                                            const SizedBox(width: 5),
                                            Text(
                                              'Đã check-in',
                                              style: GoogleFonts.beVietnamPro(
                                                color: Colors.white,
                                                fontSize: 16,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),

                                    Container(
                                      height: 30, // Các value cần gán
                                      decoration: BoxDecoration(
                                        color: Colors.transparent,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),

                            Row(
                              children: [
                                SizedBox(
                                  width: 56,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '10:30',
                                        style: GoogleFonts.beVietnamPro(
                                          color: Colors.white.withValues(
                                            alpha: 0.8,
                                          ),
                                          fontSize: 18,
                                        ),
                                      ),
                                      Container(
                                        height: 140, // Các value cần gán
                                        decoration: BoxDecoration(
                                          color: Colors.transparent,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Column(
                                  children: [
                                    Icon(
                                      CupertinoIcons.circle_fill,
                                      color: Color(0xFFFF6D00),
                                      size: 25,
                                    ),
                                    Container(
                                      height: 143, // Các value cần gán
                                      width: 2,
                                      decoration: BoxDecoration(
                                        color: Colors.white.withValues(
                                          alpha: 0.3,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(width: 10),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '10:30',
                                      style: GoogleFonts.beVietnamPro(
                                        color: Colors.white.withValues(
                                          alpha: 0.8,
                                        ),
                                        fontSize: 18,
                                      ),
                                    ),
                                    Text(
                                      "Khách sạn Metropole",
                                      style: GoogleFonts.beVietnamPro(
                                        color: Colors.white,
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 2),

                                    Row(
                                      children: [
                                        Icon(
                                          CupertinoIcons.pin,
                                          color: Colors.white.withValues(
                                            alpha: 0.8,
                                          ),
                                          size: 16,
                                        ),
                                        const SizedBox(width: 2),
                                        Text(
                                          '90/9A Hoà Bình, P5, Q11',
                                          style: GoogleFonts.beVietnamPro(
                                            color: Colors.white.withValues(
                                              alpha: 0.8,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 10),
                                    Container(
                                      width: 270,
                                      height: 50,
                                      decoration: BoxDecoration(
                                        color: Color(0xFFFF6D00),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Align(
                                        alignment: Alignment.center,
                                        child: Text(
                                          'Check-in ngay',
                                          style: GoogleFonts.beVietnamPro(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 18,
                                          ),
                                        ),
                                      ),
                                    ),

                                    Container(
                                      height: 30, // Các value cần gán
                                      decoration: BoxDecoration(
                                        color: Colors.transparent,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                SizedBox(
                                  width: 56,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '12:00',
                                        style: GoogleFonts.beVietnamPro(
                                          color: Colors.white.withValues(
                                            alpha: 0.8,
                                          ),
                                          fontSize: 18,
                                        ),
                                      ),
                                      Container(
                                        height: 115, // Các value cần gán
                                        decoration: BoxDecoration(
                                          color: Colors.transparent,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Column(
                                  children: [
                                    Icon(
                                      CupertinoIcons.circle_fill,
                                      color: Colors.white.withValues(
                                        alpha: 0.3,
                                      ),
                                      size: 25,
                                    ),
                                    Container(
                                      height: 115, // Các value cần gán
                                      width: 2,
                                      decoration: BoxDecoration(
                                        color: Colors.transparent,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(width: 10),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '12:00',
                                      style: GoogleFonts.beVietnamPro(
                                        color: Colors.white.withValues(
                                          alpha: 0.8,
                                        ),
                                        fontSize: 18,
                                      ),
                                    ),
                                    Text(
                                      "Phở gia truyền Bát Đàn",
                                      style: GoogleFonts.beVietnamPro(
                                        color: Colors.white,
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 2),

                                    Row(
                                      children: [
                                        Icon(
                                          CupertinoIcons.pin,
                                          color: Colors.white.withValues(
                                            alpha: 0.8,
                                          ),
                                          size: 16,
                                        ),
                                        const SizedBox(width: 2),
                                        Text(
                                          '90/9A Hoà Bình, P5, Q11',
                                          style: GoogleFonts.beVietnamPro(
                                            color: Colors.white.withValues(
                                              alpha: 0.8,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 30),
                                    Container(
                                      height: 30,
                                      decoration: BoxDecoration(
                                        color: Colors.transparent,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
