import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:travel_app/features/explore/screens/save_screen.dart';
import 'package:travel_app/features/explore/widgets/city_filter_bottom_sheet.dart';
import 'package:travel_app/features/explore/viewmodels/explore_view_model.dart';
import 'package:travel_app/shared/providers/saved_count_provider.dart';
import 'package:travel_app/shared/widgets/heart_button_widget.dart';
import 'package:travel_app/shared/widgets/app_text_field_widget.dart';
import 'package:travel_app/features/explore/widgets/category_button_widget.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  bool isLoading = false;
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    // Load data khi màn hình khởi tạo (giống HomeScreen)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ExploreViewModel>().loadData();
    });
  }

  // Helper method để lấy icon theo category
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

  @override
  Widget build(BuildContext context) {
    // Dùng context.watch để lắng nghe thay đổi (giống HomeScreen)
    final viewModel = context.watch<ExploreViewModel>();

    return Scaffold(
      backgroundColor: const Color(0xFF000000),
      body: Padding(
        padding: const EdgeInsets.only(top: 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header - Khám phá
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 20,
                  ),
                  child: Text(
                    "Khám phá",
                    style: GoogleFonts.beVietnamPro(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 30,
                    ),
                  ),
                ),
                GestureDetector(
                  onTapDown: (_) => setState(() => isLoading = true),
                  onTapUp: (_) => setState(() => isLoading = false),
                  onTapCancel: () => setState(() => isLoading = false),
                  onTap: () {
                    Navigator.of(context, rootNavigator: true).push(
                      MaterialPageRoute(builder: (context) => SaveScreen()),
                    );
                  },
                  child: AnimatedScale(
                    scale: isLoading ? 0.95 : 1.0,
                    duration: const Duration(milliseconds: 100),
                    curve: Curves.easeInOut,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Badge(
                        label: Text(
                          '${context.watch<SavedCountProvider>().unseenCount}',
                          style: GoogleFonts.beVietnamPro(fontSize: 15),
                        ),
                        isLabelVisible:
                            context.watch<SavedCountProvider>().unseenCount > 0,
                        backgroundColor: Color(0XFFFFAD35),
                        child: Icon(
                          CupertinoIcons.bookmark_fill,
                          color: Colors.white,
                          size: 35,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // Search Field
            AppTextFieldWidget(
              controller: _searchController,
              prefixIcon: Icons.search,
              hintText: "Tìm kiếm địa điểm...",
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
                      name: category.isEmpty ? 'Tất cả' : category,
                      icon: _getCategoryIcon(category),
                      isSelected: viewModel.selectedCategory == category,
                      onTap: () => viewModel.selectCategory(category),
                    );
                  }).toList(),
                ),
              ),
            ),

            // Title - Địa điểm du lịch
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Địa điểm du lịch",
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

            // Masonry Grid View
            Expanded(
              child: viewModel.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : viewModel.unsavedDestinations.isEmpty
                  ? const Center(
                      child: Text(
                        "Không có dữ liệu",
                        style: TextStyle(color: Colors.white),
                      ),
                    )
                  : Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: GridView.custom(
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        gridDelegate: SliverQuiltedGridDelegate(
                          crossAxisCount: 4,
                          mainAxisSpacing: 10,
                          crossAxisSpacing: 10,
                          repeatPattern: QuiltedGridRepeatPattern.inverted,
                          pattern: const [
                            QuiltedGridTile(5, 2),
                            QuiltedGridTile(3, 2),
                            QuiltedGridTile(2, 2),
                          ],
                        ),
                        childrenDelegate: SliverChildBuilderDelegate((
                          context,
                          index,
                        ) {
                          final item = viewModel.unsavedDestinations[index];

                          return ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                // Ảnh thật từ data
                                CachedNetworkImage(
                                  imageUrl: item.imageUrl,
                                  fit: BoxFit.cover,
                                  placeholder: (context, url) =>
                                      Container(color: Colors.grey[800]),
                                  errorWidget: (context, url, error) =>
                                      Container(color: Colors.grey[800]),
                                ),

                                // Heart Button
                                Positioned(
                                  top: 10,
                                  right: 10,
                                  child: HeartButtonWidget(
                                    isSaved: viewModel.isSaved(item.name),
                                    onTap: () async {
                                      await viewModel.toggleSave(item.name);
                                      if (!context.mounted) return;
                                      if (viewModel.isSaved(item.name)) {
                                        context
                                            .read<SavedCountProvider>()
                                            .increment();
                                      }
                                    },
                                  ),
                                ),

                                // Gradient mờ
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

                                // Thông tin địa điểm
                                Positioned(
                                  bottom: 8,
                                  left: 8,
                                  right: 8,
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item.name,
                                        style: GoogleFonts.beVietnamPro(
                                          color: Colors.white,
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          shadows: [
                                            Shadow(
                                              offset: Offset(0, 1),
                                              blurRadius: 2.0,
                                              color: Colors.black.withValues(
                                                alpha: 0.5,
                                              ),
                                            ),
                                          ],
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      FittedBox(
                                        fit: BoxFit.scaleDown,
                                        child: Row(
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
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        }, childCount: viewModel.unsavedDestinations.length),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
