import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:travel_app/features/explore/screens/explore_map_screen.dart';
import 'package:travel_app/shared/providers/saved_count_provider.dart';
import 'package:travel_app/shared/widgets/heart_button_widget.dart';
import 'package:travel_app/shared/widgets/app_bar_widget.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:travel_app/shared/widgets/app_text_field_widget.dart';
import 'package:provider/provider.dart';
import 'package:travel_app/features/explore/viewmodels/explore_view_model.dart';
import 'package:travel_app/features/explore/widgets/category_button_widget.dart';
import 'package:travel_app/features/explore/widgets/city_filter_bottom_sheet.dart';

class SaveScreen extends StatefulWidget {
  const SaveScreen({super.key});

  @override
  State<SaveScreen> createState() => _SaveScreenState();
}

IconData _getCategoryIcon(String category) {
  switch (category) {
    case 'Hotel':
      return Icons.hotel;
    case 'Restaurant':
      return Icons.restaurant;
    case 'Cafe':
      return Icons.coffee;
    case 'Attraction':
      return Icons.location_on;
    case 'Mall':
      return Icons.local_mall_rounded;
    case 'Market':
      return Icons.maps_home_work_outlined;
    default:
      return Icons.apps;
  }
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
    return Scaffold(
      backgroundColor: Color(0xFF000000),
      appBar: AppBarWidget(title: 'My Saves'),
      body: Column(
        children: [
          AppTextFieldWidget(
            controller: _searchController,
            prefixIcon: Icons.search,
            hintText: "Tìm kiếm địa điểm...",
            horizontalPadding: 10,
            onChanged: (query) =>
                context.read<ExploreViewModel>().search(query),
            suffixIcon: context.watch<ExploreViewModel>().searchQuery.isNotEmpty
                ? GestureDetector(
                    onTap: () {
                      _searchController.clear();
                      context.read<ExploreViewModel>().clearSearch();
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
                children: context.watch<ExploreViewModel>().categories.map((
                  category,
                ) {
                  final viewModel = context.read<ExploreViewModel>();
                  return CategoryButtonWidget(
                    name: category.isEmpty ? 'Tất cả' : category,
                    icon: _getCategoryIcon(category),
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
                  "Địa điểm đã lưu",
                  style: GoogleFonts.beVietnamPro(
                    color: Colors.white,
                    fontSize: 18,
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    final viewModel = context.read<ExploreViewModel>();
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
                    final viewModel = context.watch<ExploreViewModel>();
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
                              "Chưa có địa điểm nào được lưu",
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
                    return GridView.custom(
                      padding: EdgeInsets.symmetric(vertical: 10),
                      gridDelegate: SliverQuiltedGridDelegate(
                        crossAxisCount: 4,
                        mainAxisSpacing: 10,
                        crossAxisSpacing: 10,
                        repeatPattern: QuiltedGridRepeatPattern.inverted,
                        pattern: [QuiltedGridTile(2, 2), QuiltedGridTile(2, 2)],
                      ),
                      childrenDelegate: SliverChildBuilderDelegate((
                        context,
                        index,
                      ) {
                        final item = saved[index];
                        return ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              CachedNetworkImage(
                                imageUrl: item.imageUrl,
                                fit: BoxFit.cover,
                                placeholder: (context, url) =>
                                    Container(color: Colors.grey[800]),
                                errorWidget: (context, url, error) =>
                                    Container(color: Colors.grey[800]),
                              ),
                              Positioned(
                                top: 10,
                                right: 10,
                                child: HeartButtonWidget(
                                  isSaved: true,
                                  onTap: () => viewModel.toggleSave(item.name),
                                ),
                              ),
                              Positioned(
                                bottom: 0,
                                left: 0,
                                right: 0,
                                height: 120,
                                child: Container(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.bottomCenter,
                                      end: Alignment.topCenter,
                                      colors: [
                                        Colors.black.withValues(alpha: 0.8),
                                        Colors.transparent,
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              Positioned(
                                bottom: 8,
                                left: 8,
                                right: 8,
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.name,
                                      style: GoogleFonts.beVietnamPro(
                                        color: Colors.white,
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    Row(
                                      children: [
                                        const Icon(
                                          CupertinoIcons.star_fill,
                                          color: Color(0xFFFFAD35),
                                          size: 12,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          item.rating,
                                          style: GoogleFonts.beVietnamPro(
                                            color: Colors.white,
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          "(${item.reviewCount})",
                                          style: GoogleFonts.beVietnamPro(
                                            color: Colors.white.withValues(
                                              alpha: 0.8,
                                            ),
                                            fontSize: 10,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      }, childCount: saved.length),
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
