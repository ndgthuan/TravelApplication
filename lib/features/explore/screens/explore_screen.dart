import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:travel_app/features/explore/screens/save_screen.dart';
import 'package:travel_app/features/explore/widgets/city_filter_bottom_sheet.dart';
import 'package:travel_app/features/explore/viewmodels/explore_view_model.dart';
import 'package:travel_app/shared/providers/saved_count_provider.dart';
import 'package:travel_app/shared/widgets/app_text_field_widget.dart';
import 'package:travel_app/features/explore/utils/category_helper.dart';
import 'package:travel_app/features/explore/widgets/category_button_widget.dart';
import 'package:travel_app/features/explore/widgets/explore_destination_card.dart';

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

  @override
  Widget build(BuildContext context) {
    var _ = context.locale;
    // Dùng context.watch để lắng nghe thay đổi (giống HomeScreen)
    final viewModel = context.watch<ExploreViewModel>();

    // Hiện lỗi từ ViewModel
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
                    "explore.title".tr(),
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

            // Title - Địa điểm du lịch
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "explore.tourist_destinations".tr(),
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
                  ? Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Color(0xFFFFAD35),
                        ),
                      ),
                    )
                  : viewModel.unsavedDestinations.isEmpty
                  ? Center(
                      child: Text(
                        "explore.no_data".tr(),
                        style: TextStyle(color: Colors.white),
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: () => viewModel.loadData(),
                      color: Color(0xFFFFAD35),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: GridView.custom(
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          physics:
                              const AlwaysScrollableScrollPhysics(), // Scroll ngược lên để refresh
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

                            return ExploreDestinationCard(
                              item: item,
                              isSaved: viewModel.isSaved(item.name),
                              onHeartTap: () async {
                                await viewModel.toggleSave(item.name);
                                if (!context.mounted) return;
                                if (viewModel.isSaved(item.name)) {
                                  context
                                      .read<SavedCountProvider>()
                                      .increment();
                                }
                              },
                            );
                          }, childCount: viewModel.unsavedDestinations.length),
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
