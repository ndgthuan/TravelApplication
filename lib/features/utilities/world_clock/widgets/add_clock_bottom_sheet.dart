import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:provider/provider.dart';
import 'package:travel_app/features/utilities/world_clock/viewmodels/world_clock_view_model.dart';
import 'package:travel_app/shared/widgets/app_text_field_widget.dart';

class AddClockBottomSheet extends StatelessWidget {
  final TextEditingController searchController;

  const AddClockBottomSheet({super.key, required this.searchController});

  @override
  Widget build(BuildContext context) {
    return Consumer<WorldClockViewModel>(
      builder: (context, vm, child) {
        // Show search results if has results, otherwise show popular
        final cities = vm.searchResults.isNotEmpty
            ? vm.searchResults
            : vm.popularCities;
        final isPopular = vm.searchResults.isEmpty;

        return Padding(
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
                      icon: Icon(CupertinoIcons.xmark, color: Colors.grey),
                    ),
                  ],
                ),
                SizedBox(height: 15),

                // Search bar
                AppTextFieldWidget(
                  controller: searchController,
                  onChanged: (query) => vm.searchCities(query),
                  hintText: 'world_clock.search_hint'.tr(),
                  prefixIcon: CupertinoIcons.search,
                  horizontalPadding: 0,
                  suffixIcon: vm.isSearching
                      ? Padding(
                          padding: EdgeInsets.all(12),
                          child: SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Color(0xFFFF6D00),
                              strokeWidth: 2,
                            ),
                          ),
                        )
                      : null,
                ),
                SizedBox(height: 15),

                // Label Popular
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

                // City list
                Expanded(
                  child: ListView.builder(
                    itemCount: cities.length,
                    itemBuilder: (context, index) {
                      final tz = cities[index];
                      final offset = vm.getTimezoneOffset(tz['timezone']);
                      final offsetStr = offset >= 0 ? '+$offset' : '$offset';

                      return ListTile(
                        leading: Icon(
                          CupertinoIcons.location_fill,
                          color: Color(0xFFFF6D00),
                        ),
                        title: Text(
                          '${tz['city']}, ${tz['country']}',
                          style: GoogleFonts.beVietnamPro(color: Colors.white),
                        ),
                        subtitle: Text(
                          'UTC$offsetStr (${tz['timezone']})',
                          style: GoogleFonts.beVietnamPro(color: Colors.grey),
                        ),
                        onTap: () async {
                          await vm.addTimezone(tz);
                          searchController.clear();
                          // ignore: use_build_context_synchronously
                          Navigator.pop(context);
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
