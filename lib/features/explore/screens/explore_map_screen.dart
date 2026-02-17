import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:travel_app/domain/models/destination_model.dart';
import 'package:provider/provider.dart';
import 'package:travel_app/shared/widgets/app_dark_map_widget.dart';
import 'package:travel_app/features/explore/widgets/explore_map_saved_count_chip.dart';
import 'package:travel_app/features/explore/widgets/map_info_window_widget.dart';
import 'package:travel_app/features/explore/widgets/explore_map_search_overlay.dart';
import 'package:travel_app/features/explore/widgets/explore_map_floating_actions.dart';
import 'package:travel_app/features/explore/viewmodels/explore_view_model.dart';

class ExploreMapScreen extends StatefulWidget {
  const ExploreMapScreen({super.key});

  @override
  State<ExploreMapScreen> createState() => _ExploreMapScreenState();
}

class _ExploreMapScreenState extends State<ExploreMapScreen> {
  final _mapController = MapController();
  final Set<String> _hiddenInfoWindows = {}; // Track các info window đã đóng
  final TextEditingController _searchController = TextEditingController();
  List<DestinationModel> _searchResults = [];
  bool _showSearchResults = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ExploreViewModel>().loadCurrentLocation();
      Future.delayed(Duration(milliseconds: 0), () {
        if (!mounted) return;
        _fitAllMarkers();
      });
    });
  }

  void _fitAllMarkers() {
    final viewModel = context.read<ExploreViewModel>();
    final savedDestinations = viewModel.savedDestinations;

    if (savedDestinations.isEmpty) {
      if (viewModel.hasCurrentLocation) {
        _mapController.move(
          LatLng(viewModel.currentLocationLat!, viewModel.currentLocationLng!),
          16.0,
        );
      }
      return;
    }

    final points = savedDestinations
        .map((d) => LatLng(d.latitude, d.longitude))
        .where((p) => p.latitude.isFinite && p.longitude.isFinite)
        .toList();

    if (points.isEmpty) return;

    final allSame =
        points.length == 1 ||
        points.every(
          (p) =>
              p.latitude == points.first.latitude &&
              p.longitude == points.first.longitude,
        );
    if (allSame) {
      _mapController.move(points.first, 17.0);
      return;
    }

    final bounds = LatLngBounds.fromPoints(points);
    _mapController.fitCamera(
      CameraFit.bounds(bounds: bounds, padding: EdgeInsets.all(50)),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _searchDestinations(String query) {
    final viewModel = context.read<ExploreViewModel>();
    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
        _showSearchResults = false;
      });
      return;
    }

    setState(() {
      _searchResults = viewModel.savedDestinations
          .where((d) => d.name.toLowerCase().contains(query.toLowerCase()))
          .toList();
      _showSearchResults = _searchResults.isNotEmpty;
    });
  }

  void _flyToDestination(DestinationModel dest) {
    if (!dest.latitude.isFinite || !dest.longitude.isFinite) return;
    setState(() {
      _hiddenInfoWindows.remove(dest.name); // Hiện lại info window nếu đã ẩn
      _searchController.clear();
      _showSearchResults = false;
    });
    _mapController.move(LatLng(dest.latitude, dest.longitude), 17.0);
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<ExploreViewModel>();
    final savedDestinations = viewModel.savedDestinations;
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          AppDarkMapWidget(
            mapController: _mapController,
            initialCenter: const LatLng(10.7769, 106.7009),
            initialZoom: 15.0,
            onPositionChanged: (camera, hasGesture) {
              if (hasGesture) setState(() {});
            },
            onTap: (tapPosition, point) {},
            children: [
              MarkerLayer(
                markers: [
                  if (viewModel.hasCurrentLocation)
                    Marker(
                      point: LatLng(
                        viewModel.currentLocationLat!,
                        viewModel.currentLocationLng!,
                      ),
                      width: 40,
                      height: 40,
                      alignment: Alignment.bottomCenter,
                      child: GestureDetector(
                        onTap: () {
                          _mapController.move(
                            LatLng(
                              viewModel.currentLocationLat!,
                              viewModel.currentLocationLng!,
                            ),
                            17.0,
                          );
                        },
                        child: Icon(
                          CupertinoIcons.location_fill,
                          color: Color(0xFF34C759),
                          size: 36,
                        ),
                      ),
                    ),
                  ...savedDestinations
                      .where((d) => d.latitude.isFinite && d.longitude.isFinite)
                      .map((dest) {
                        return Marker(
                          point: LatLng(dest.latitude, dest.longitude),
                          width: 180,
                          height: 200,
                          alignment: Alignment.bottomCenter,
                          child: Transform.translate(
                            offset: _hiddenInfoWindows.contains(dest.name)
                                ? Offset.zero
                                : Offset(0, -139),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                if (!_hiddenInfoWindows.contains(dest.name))
                                  MapInfoWindowWidget(
                                    dest: dest,
                                    onClose: () {
                                      setState(() {
                                        _hiddenInfoWindows.add(dest.name);
                                      });
                                    },
                                  ),
                                GestureDetector(
                                  onTap: () {
                                    if (!dest.latitude.isFinite ||
                                        !dest.longitude.isFinite) {
                                      return;
                                    }
                                    setState(() {
                                      _hiddenInfoWindows.remove(dest.name);
                                    });
                                    _mapController.move(
                                      LatLng(dest.latitude, dest.longitude),
                                      17.0,
                                    );
                                  },
                                  child: Icon(
                                    CupertinoIcons.heart_fill,
                                    color: Color(0xFFFF6D00),
                                    size: 30,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }),
                ],
              ),
              RichAttributionWidget(
                attributions: [
                  TextSourceAttribution('OpenStreetMap, CartoDB', onTap: () {}),
                ],
              ),
            ],
          ),
          ExploreMapSearchOverlay(
            searchController: _searchController,
            searchResults: _searchResults,
            showSearchResults: _showSearchResults,
            onSearchChanged: _searchDestinations,
            onDestinationSelected: _flyToDestination,
          ),

          Positioned(
            bottom: 5,
            right: 10,
            child: ExploreMapFloatingActions(
              onFitBounds: _fitAllMarkers,
              onBookmarkTap: () => Navigator.pop(context),
              canFitBounds: savedDestinations.isNotEmpty,
            ),
          ),

          Positioned(
            bottom: 10,
            left: 10,
            child: ExploreMapSavedCountChip(
              savedCount: savedDestinations.length,
            ),
          ),
        ],
      ),
    );
  }
}
