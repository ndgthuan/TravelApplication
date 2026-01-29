// Dùng để build các thẻ map
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:travel_app/domain/models/destination_model.dart';
import 'package:travel_app/shared/widgets/app_text_field_widget.dart';
import 'package:easy_localization/easy_localization.dart';

class ExploreMapSearchOverlay extends StatelessWidget {
  final TextEditingController searchController;
  final List<DestinationModel> searchResults;
  final bool showSearchResults;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<DestinationModel> onDestinationSelected;

  const ExploreMapSearchOverlay({
    super.key,
    required this.searchController,
    required this.searchResults,
    required this.showSearchResults,
    required this.onSearchChanged,
    required this.onDestinationSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppTextFieldWidget(
            controller: searchController,
            hintText: "explore.search_hint".tr(),
            prefixIcon: Icons.search,
            horizontalPadding: 0,
            onChanged: onSearchChanged,
            suffixIcon: ValueListenableBuilder<TextEditingValue>(
              valueListenable: searchController,
              builder: (context, value, _) {
                if (value.text.isEmpty) return const SizedBox.shrink();
                return GestureDetector(
                  onTap: () {
                    searchController.clear();
                    onSearchChanged('');
                  },
                  child: Icon(
                    CupertinoIcons.xmark_circle_fill,
                    color: Colors.grey[600],
                  ),
                );
              },
            ),
          ),
          if (showSearchResults && searchResults.isNotEmpty)
            Container(
              margin: const EdgeInsets.only(top: 5, left: 20, right: 20),
              decoration: BoxDecoration(
                color: const Color(0xFF2A2A2A),
                borderRadius: BorderRadius.circular(12),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: ListView.builder(
                  shrinkWrap: true,
                  padding: EdgeInsets.zero,
                  physics: searchResults.length > 4
                      ? const AlwaysScrollableScrollPhysics()
                      : const NeverScrollableScrollPhysics(),
                  itemCount: searchResults.length > 5
                      ? 5
                      : searchResults.length,
                  itemBuilder: (context, index) {
                    final dest = searchResults[index];
                    return ListTile(
                      dense: true,
                      leading: const Icon(
                        CupertinoIcons.location_fill,
                        color: Color(0xFFFFAD35),
                        size: 20,
                      ),
                      title: Text(
                        dest.name,
                        style: GoogleFonts.beVietnamPro(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                      ),
                      subtitle: Text(
                        dest.city,
                        style: GoogleFonts.beVietnamPro(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                      onTap: () => onDestinationSelected(dest),
                    );
                  },
                ),
              ),
            ),
        ],
      ),
    );
  }
}
