import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:travel_app/features/Utilities/services/timezone_service.dart';
import 'package:travel_app/features/Utilities/widgets/time_zone_card.dart';
import 'package:travel_app/shared/widgets/app_button_widget.dart';
import 'package:travel_app/shared/widgets/app_text_field_widget.dart';

class WorldClockScreen extends StatefulWidget {
  const WorldClockScreen({super.key});

  @override
  State<WorldClockScreen> createState() => _WorldClockScreenState();
}

class _WorldClockScreenState extends State<WorldClockScreen> {
  List<Map<String, dynamic>> _timezones = [];
  bool _isLoading = true;

  // Search
  List<Map<String, dynamic>> _searchResults = [];
  bool _isSearching = false;
  Timer? _debounce;
  final TextEditingController _searchController = TextEditingController();

  // Popular cities to show by default
  final List<Map<String, dynamic>> _popularCities = [
    {
      'city': 'Tokyo',
      'country': 'Japan',
      'timezone': 'Asia/Tokyo',
      'latitude': 35.6762,
      'longitude': 139.6503,
    },
    {
      'city': 'London',
      'country': 'United Kingdom',
      'timezone': 'Europe/London',
      'latitude': 51.5074,
      'longitude': -0.1278,
    },
    {
      'city': 'New York',
      'country': 'United States',
      'timezone': 'America/New_York',
      'latitude': 40.7128,
      'longitude': -74.0060,
    },
    {
      'city': 'Paris',
      'country': 'France',
      'timezone': 'Europe/Paris',
      'latitude': 48.8566,
      'longitude': 2.3522,
    },
    {
      'city': 'Sydney',
      'country': 'Australia',
      'timezone': 'Australia/Sydney',
      'latitude': -33.8688,
      'longitude': 151.2093,
    },
    {
      'city': 'Singapore',
      'country': 'Singapore',
      'timezone': 'Asia/Singapore',
      'latitude': 1.3521,
      'longitude': 103.8198,
    },
    {
      'city': 'Dubai',
      'country': 'United Arab Emirates',
      'timezone': 'Asia/Dubai',
      'latitude': 25.2048,
      'longitude': 55.2708,
    },
    {
      'city': 'Seoul',
      'country': 'South Korea',
      'timezone': 'Asia/Seoul',
      'latitude': 37.5665,
      'longitude': 126.9780,
    },
    {
      'city': 'Moscow',
      'country': 'Russia',
      'timezone': 'Europe/Moscow',
      'latitude': 55.7558,
      'longitude': 37.6173,
    },
    {
      'city': 'Los Angeles',
      'country': 'United States',
      'timezone': 'America/Los_Angeles',
      'latitude': 34.0522,
      'longitude': -118.2437,
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadTimezones();
  }

  Future<void> _loadTimezones() async {
    final timezones = await TimezoneService.getSavedTimezones();
    setState(() {
      _timezones = timezones;
      _isLoading = false;
    });
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    _debounce = Timer(Duration(milliseconds: 300), () async {
      if (query.isEmpty) {
        setState(() => _searchResults = []);
        return;
      }

      setState(() => _isSearching = true);
      final results = await TimezoneService.searchCities(query);
      setState(() {
        _searchResults = results;
        _isSearching = false;
      });
    });
  }

  Future<void> _addTimezone(Map<String, dynamic> tz) async {
    await TimezoneService.addTimezone(tz);
    await _loadTimezones();
    setState(() {
      _searchResults = [];
      _searchController.clear();
    });
    Navigator.of(context).pop(); // Close bottom sheet
  }

  Future<void> _removeTimezone(int index) async {
    await TimezoneService.removeTimezone(index);
    await _loadTimezones();
  }

  void _showAddClockSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Color(0xFF1C1C1D),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Container(
            height: 500,
            padding: EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'world_clock.add_city'.tr(),
                      style: GoogleFonts.beVietnamPro(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(Icons.close, color: Colors.grey),
                    ),
                  ],
                ),
                SizedBox(height: 15),

                // Search bar
                AppTextFieldWidget(
                  controller: _searchController,
                  onChanged: (query) {
                    _onSearchChanged(query);
                    setModalState(() {});
                  },
                  hintText: 'world_clock.search_hint'.tr(),
                  prefixIcon: Icons.search,
                  suffixIcon: _isSearching
                      ? Padding(
                          padding: EdgeInsets.all(12),
                          child: SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Color(0xFFFFAD35),
                              strokeWidth: 2,
                            ),
                          ),
                        )
                      : null,
                ),
                SizedBox(height: 15),

                // Search results or popular cities
                Expanded(
                  child: Builder(
                    builder: (context) {
                      // Show search results if searching, otherwise show popular
                      final cities = _searchResults.isNotEmpty
                          ? _searchResults
                          : _popularCities;
                      final isPopular = _searchResults.isEmpty;

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (isPopular)
                            Padding(
                              padding: EdgeInsets.only(bottom: 10),
                              child: Text(
                                'world_clock.popular'.tr(),
                                style: GoogleFonts.beVietnamPro(
                                  color: Colors.grey,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          Expanded(
                            child: ListView.builder(
                              itemCount: cities.length,
                              itemBuilder: (context, index) {
                                final tz = cities[index];
                                final offset =
                                    TimezoneService.getTimezoneOffset(
                                      tz['timezone'],
                                    );
                                final offsetStr = offset >= 0
                                    ? '+$offset'
                                    : '$offset';

                                return ListTile(
                                  leading: Icon(
                                    Icons.location_on,
                                    color: Color(0xFFFFAD35),
                                  ),
                                  title: Text(
                                    '${tz['city']}, ${tz['country']}',
                                    style: GoogleFonts.beVietnamPro(
                                      color: Colors.white,
                                    ),
                                  ),
                                  subtitle: Text(
                                    'UTC$offsetStr (${tz['timezone']})',
                                    style: GoogleFonts.beVietnamPro(
                                      color: Colors.grey,
                                    ),
                                  ),
                                  onTap: () => _addTimezone(tz),
                                );
                              },
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF000000),
      appBar: AppBar(
        surfaceTintColor: Colors.transparent,
        iconTheme: IconThemeData(color: Colors.white),
        backgroundColor: Color(0xFF1C1C1D),
        centerTitle: true,
        title: Text(
          'world_clock.title'.tr(),
          style: GoogleFonts.beVietnamPro(color: Colors.white),
        ),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: Color(0xFFFFAD35)))
          : Stack(
              children: [
                // Scrollable content
                _timezones.isEmpty
                    ? Center(
                        child: Text(
                          'world_clock.empty'.tr(),
                          style: GoogleFonts.beVietnamPro(color: Colors.grey),
                        ),
                      )
                    : ListView.builder(
                        padding: EdgeInsets.only(
                          left: 20,
                          right: 20,
                          top: 10,
                          bottom: 100,
                        ),
                        itemCount: _timezones.length,
                        itemBuilder: (context, index) {
                          final tz = _timezones[index];
                          final offset = TimezoneService.getTimezoneOffset(
                            tz['timezone'],
                          );

                          return TimeZoneCard(
                            city: tz['city'],
                            country: tz['country'],
                            timezone: tz['timezone'],
                            timezoneOffset: offset,
                            onDelete: () => _removeTimezone(index),
                          );
                        },
                      ),

                // Fixed button at bottom
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 10,
                  child: AppButtonWidget(
                    buttonText: 'world_clock.add_city'.tr(),
                    onTap: _showAddClockSheet,
                  ),
                ),
              ],
            ),
    );
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }
}
