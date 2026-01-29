import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:travel_app/features/explore/screens/explore_map_screen.dart';
import 'package:travel_app/features/explore/widgets/explore_destination_card.dart';
import 'package:travel_app/shared/providers/saved_count_provider.dart';
import 'package:travel_app/shared/widgets/app_bar_widget.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:travel_app/shared/widgets/app_text_field_widget.dart';
import 'package:provider/provider.dart';
import 'package:travel_app/features/explore/utils/category_helper.dart';
import 'package:travel_app/features/explore/viewmodels/explore_view_model.dart';
import 'package:travel_app/features/explore/widgets/category_button_widget.dart';
import 'package:travel_app/features/explore/widgets/city_filter_bottom_sheet.dart';

class SaveScreen extends StatefulWidget {
  const SaveScreen({super.key});

  @override
  State<SaveScreen> createState() => _SaveScreenState();
}

class _SaveScreenState extends State<SaveScreen> {
  bool isLoading = false;
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Reset filters và refresh saved list khi vào SaveScreen
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SavedCountProvider>().reset();
      final viewModel = context.read<ExploreViewModel>();
      viewModel.resetFilters();
      viewModel.refreshSavedDestinations(); // Refresh để sync với Firestore
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<ExploreViewModel>();

    if (viewModel.hasError && viewModel.errorMessage != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(viewModel.errorMessage!),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
        viewModel.clearError();
      });
    }

    return Scaffold(
      backgroundColor: Color(0xFF000000),
      appBar: AppBarWidget(title: 'explore.my_saves'.tr()),
      body: Column(
        children: [
          AppTextFieldWidget(
            controller: _searchController,
            prefixIcon: Icons.search,
            hintText: "explore.search_hint".tr(),
            horizontalPadding: 10,
            onChanged: (query) => viewModel.search(query),
            suffixIcon: viewModel.searchQuery.isNotEmpty
                ? GestureDetector(
                    onTap: () {
                      _searchController.clear();
                      viewModel.clearSearch();
                    },
                    child: Icon(
                      CupertinoIcons.xmark_circle_fill,
                      color: Colors.grey[600],
                    ),
                  )
                : null,
          ),

          // Phân loại
          Padding(
            padding: const EdgeInsets.only(top: 20, bottom: 10),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: viewModel.categories.map((category) {
                  return CategoryButtonWidget(
                    name: getCategoryName(category),
                    icon: getCategoryIcon(category),
                    isSelected: viewModel.selectedCategory == category,
                    onTap: () => viewModel.selectCategory(category),
                  );
                }).toList(),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "explore.saved_destinations".tr(),
                  style: GoogleFonts.beVietnamPro(
                    color: Colors.white,
                    fontSize: 18,
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    showModalBottomSheet(
                      context: context,
                      backgroundColor: Colors.transparent,
                      isScrollControlled: true,
                      builder: (context) => CityFilterBottomSheet(
                        cities: viewModel.cities,
                        selectedCity: viewModel.selectedCity,
                        onCitySelected: (city) => viewModel.selectCity(city),
                      ),
                    );
                  },
                  child: Icon(
                    CupertinoIcons.slider_horizontal_3,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),

          Expanded(
            child: Stack(
              children: [
                Builder(
                  builder: (context) {
                    final saved = viewModel.savedDestinations;

                    // Empty state
                    if (saved.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              CupertinoIcons.heart_fill,
                              color: Colors.grey,
                              size: 80,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              "explore.no_saved_places".tr(),
                              style: GoogleFonts.beVietnamPro(
                                color: Colors.grey,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    // Có data
                    return RefreshIndicator(
                      onRefresh: () => viewModel.refreshSavedDestinations(),
                      color: Color(0xFFFFAD35),
                      child: GridView.custom(
                        padding: EdgeInsets.symmetric(vertical: 10),
                        physics: const AlwaysScrollableScrollPhysics(),
                        gridDelegate: SliverQuiltedGridDelegate(
                          crossAxisCount: 4,
                          mainAxisSpacing: 10,
                          crossAxisSpacing: 10,
                          repeatPattern: QuiltedGridRepeatPattern.inverted,
                          pattern: [
                            QuiltedGridTile(2, 2),
                            QuiltedGridTile(2, 2),
                          ],
                        ),
                        childrenDelegate: SliverChildBuilderDelegate((
                          context,
                          index,
                        ) {
                          final item = saved[index];
                          return ExploreDestinationCard(
                            item: item,
                            isSaved: true,
                            onHeartTap: () async {
                              await viewModel.toggleSave(item.name);
                              if (!context.mounted) return;
                            },
                          );
                        }, childCount: saved.length),
                      ),
                    );
                  },
                ),

                // Nút chuyển đổi giữa my saves và map
                Positioned(
                  bottom: 5,
                  right: 10,
                  child: GestureDetector(
                    onTapDown: (_) => setState(() => isLoading = true),
                    onTapUp: (_) => setState(() => isLoading = false),
                    onTapCancel: () => setState(() => isLoading = false),
                    onTap: () {
                      Navigator.of(context, rootNavigator: true).push(
                        MaterialPageRoute(
                          builder: (context) => ExploreMapScreen(),
                        ),
                      );
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
                          CupertinoIcons.map_fill,
                          color: Color(0xFFFFAD35),
                        ),
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
