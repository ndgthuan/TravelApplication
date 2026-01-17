import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:easy_localization/easy_localization.dart';

class SearchSectionWidget extends StatelessWidget {
  final TextEditingController controller;
  final Function(String) onSearchChanged;
  final List<Map<String, dynamic>> searchResults;
  final bool isSearching;
  final Function(Map<String, dynamic>) onLocationSelected;

  const SearchSectionWidget({
    super.key,
    required this.controller,
    required this.onSearchChanged,
    required this.searchResults,
    required this.isSearching,
    required this.onLocationSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Search bar
        TextFormField(
          controller: controller,
          onChanged: onSearchChanged,
          cursorColor: Color(0xFFFFAD35),
          style: GoogleFonts.beVietnamPro(color: Colors.white),
          decoration: InputDecoration(
            prefixIcon: Icon(Icons.search, color: Colors.grey),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: Color(0xFFFFAD35), width: 1.5),
            ),
            hintText: 'weather.search_hint'.tr(),
            hintStyle: GoogleFonts.beVietnamPro(
              color: Colors.grey[600],
              fontSize: 16,
            ),
            fillColor: Color(0xFF1C1C1D),
            filled: true,
          ),
        ),

        // Search Results Dropdown
        if (searchResults.isNotEmpty)
          Container(
            margin: EdgeInsets.only(top: 5),
            decoration: BoxDecoration(
              color: Color(0xFF1C1C1D),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Color(0xFFFFAD35), width: 1),
            ),
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: searchResults.length,
              itemBuilder: (context, index) {
                final location = searchResults[index];
                return ListTile(
                  leading: Icon(Icons.location_on, color: Color(0xFFFFAD35)),
                  title: Text(
                    location['city'] ?? location['name'] ?? '',
                    style: GoogleFonts.beVietnamPro(color: Colors.white),
                  ),
                  subtitle: Text(
                    location['country'] ?? '',
                    style: GoogleFonts.beVietnamPro(color: Colors.grey),
                  ),
                  onTap: () => onLocationSelected(location),
                );
              },
            ),
          ),

        // Loading indicator
        if (isSearching)
          Padding(
            padding: EdgeInsets.all(10),
            child: CircularProgressIndicator(
              color: Color(0xFFFFAD35),
              strokeWidth: 2,
            ),
          ),
      ],
    );
  }
}
