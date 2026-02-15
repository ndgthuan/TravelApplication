import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:latlong2/latlong.dart';
import 'package:travel_app/shared/widgets/app_text_field_widget.dart';

// Khởi tạo map và tạo ô tìm kiếm địa điểm
// Hiện list cụ thể để chọn
class ActivityLocationMapWidget extends StatefulWidget {
  const ActivityLocationMapWidget({
    super.key,
    required this.mapController,
    required this.locationSearchController,
    required this.pinPosition,
    required this.onPinPositionChanged,
    required this.onSearchQuery,
    required this.onSelectPlaceResult,
    required this.placeSearchResults,
    this.isSearchingLocation = false,
  });

  final MapController mapController;
  final TextEditingController locationSearchController;
  final LatLng pinPosition;
  final ValueChanged<LatLng> onPinPositionChanged;

  // Gọi khi user gõ (debounce), parent gọi searchPlaces.
  final void Function(String query) onSearchQuery;

  // Gọi khi user chọn 1 gợi ý
  final void Function(int index) onSelectPlaceResult;
  final List<Map<String, dynamic>> placeSearchResults;
  final bool isSearchingLocation;

  @override
  State<ActivityLocationMapWidget> createState() =>
      _ActivityLocationMapWidgetState();
}

class _ActivityLocationMapWidgetState extends State<ActivityLocationMapWidget> {
  Timer? _debounceTimer;
  bool _skipNextTextChange = false;
  static const _debounceDuration = Duration(milliseconds: 400);

  @override
  void initState() {
    super.initState();
    widget.locationSearchController.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    widget.locationSearchController.removeListener(_onTextChanged);
    super.dispose();
  }

  void _onTextChanged() {
    if (_skipNextTextChange) {
      _skipNextTextChange = false;
      return;
    }
    _debounceTimer?.cancel();
    _debounceTimer = Timer(_debounceDuration, () {
      if (!mounted) return;
      widget.onSearchQuery(widget.locationSearchController.text);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: SizedBox(
            height: 300,
            width: double.infinity,
            child: Stack(
              children: [
                Positioned.fill(
                  child: FlutterMap(
                    mapController: widget.mapController,
                    options: MapOptions(
                      initialCenter: widget.pinPosition,
                      initialZoom: 15,
                      onTap: (_, point) => widget.onPinPositionChanged(point),
                    ),
                    children: [
                      TileLayer(
                        urlTemplate:
                            'https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}{r}.png',
                        subdomains: const ['a', 'b', 'c', 'd'],
                        userAgentPackageName: 'com.travel.app',
                        retinaMode: RetinaMode.isHighDensity(context),
                      ),
                      MarkerLayer(
                        markers: [
                          Marker(
                            point: widget.pinPosition,
                            width: 40,
                            height: 40,
                            child: Icon(
                              Icons.location_on,
                              size: 40,
                              color: Color(0xFFFF6D00),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Positioned(
                  top: 12,
                  left: 12,
                  right: 12,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      AppTextFieldWidget(
                        controller: widget.locationSearchController,
                        hintText: 'Địa chỉ cụ thể...',
                        showLabel: false,
                        horizontalPadding: 0,
                        prefixIcon: Icons.search,
                        suffixIcon: widget.isSearchingLocation
                            ? Padding(
                                padding: const EdgeInsets.all(12),
                                child: SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white54,
                                  ),
                                ),
                              )
                            : null,
                      ),
                      if (widget.placeSearchResults.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Container(
                          constraints: BoxConstraints(maxHeight: 200),
                          decoration: BoxDecoration(
                            color: Color(0xFF1C1C1D),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Color(0xFF333333)),
                          ),
                          child: ListView.separated(
                            shrinkWrap: true,
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            itemCount: widget.placeSearchResults.length,
                            separatorBuilder: (_, __) => Divider(
                              height: 1,
                              color: Colors.white.withValues(alpha: 0.2),
                            ),
                            itemBuilder: (context, index) {
                              final item = widget.placeSearchResults[index];
                              final name = item['displayName'] as String? ?? '';
                              return Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: () {
                                    _debounceTimer?.cancel();
                                    _skipNextTextChange = true;
                                    widget.onSelectPlaceResult(index);
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 12,
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.place_outlined,
                                          size: 20,
                                          color: Colors.white70,
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Text(
                                            name,
                                            style: GoogleFonts.beVietnamPro(
                                              color: Colors.white,
                                              fontSize: 14,
                                            ),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
