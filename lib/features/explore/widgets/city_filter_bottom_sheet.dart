import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:travel_app/shared/widgets/app_text_field_widget.dart';

class CityFilterBottomSheet extends StatefulWidget {
  final List<String> cities;
  final String selectedCity;
  final Function(String) onCitySelected;

  const CityFilterBottomSheet({
    super.key,
    required this.cities,
    required this.selectedCity,
    required this.onCitySelected,
  });

  @override
  State<CityFilterBottomSheet> createState() => _CityFilterBottomSheetState();
}

class _CityFilterBottomSheetState extends State<CityFilterBottomSheet> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Lọc danh sách city theo search query
  List<String> get filteredCities {
    if (_searchQuery.isEmpty) return widget.cities;
    return widget.cities.where((city) {
      final displayName = city.isEmpty ? "Tất cả tỉnh thành" : city;
      return displayName.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: const BoxDecoration(
        color: Color(0xFF1A1A1A),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[600],
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Title
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              "Chọn Tỉnh/Thành phố",
              style: GoogleFonts.beVietnamPro(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          // Search Field
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: AppTextFieldWidget(
              controller: _searchController,
              prefixIcon: Icons.search,
              hintText: "Tìm tỉnh/thành phố...",
              horizontalPadding: 0,
              onChanged: (query) {
                setState(() {
                  _searchQuery = query;
                });
              },
              suffixIcon: _searchQuery.isNotEmpty
                  ? GestureDetector(
                      onTap: () {
                        _searchController.clear();
                        setState(() {
                          _searchQuery = '';
                        });
                      },
                      child: Icon(
                        CupertinoIcons.xmark_circle_fill,
                        color: Colors.grey[600],
                      ),
                    )
                  : null,
            ),
          ),

          // List cities (filtered)
          Expanded(
            child: filteredCities.isEmpty
                ? Center(
                    child: Text(
                      "Không tìm thấy tỉnh/thành phố",
                      style: GoogleFonts.beVietnamPro(color: Colors.grey),
                    ),
                  )
                : ListView.builder(
                    itemCount: filteredCities.length,
                    itemBuilder: (context, index) {
                      final city = filteredCities[index];
                      final isSelected = city == widget.selectedCity;
                      final displayName = city.isEmpty
                          ? "Tất cả tỉnh thành"
                          : city;

                      return ListTile(
                        onTap: () {
                          widget.onCitySelected(city);
                          Navigator.pop(context);
                        },
                        leading: Icon(
                          isSelected
                              ? Icons.radio_button_checked
                              : Icons.radio_button_off,
                          color: isSelected
                              ? const Color(0xFFFFAD35)
                              : Colors.grey,
                        ),
                        title: Text(
                          displayName,
                          style: GoogleFonts.beVietnamPro(
                            color: isSelected
                                ? const Color(0xFFFFAD35)
                                : Colors.white,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                        trailing: isSelected
                            ? const Icon(Icons.check, color: Color(0xFFFFAD35))
                            : null,
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
