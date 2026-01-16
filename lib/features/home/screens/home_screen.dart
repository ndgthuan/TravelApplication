import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:travel_app/features/home/models/destination_model.dart';
import 'package:travel_app/features/home/services/destination_service.dart';
import 'package:travel_app/features/home/widgets/slide_card_widget.dart';
import 'package:travel_app/features/home/widgets/scroll_card_widget.dart';
import 'package:travel_app/features/home/widgets/gradient_divider_widget.dart';
import 'package:travel_app/features/home/widgets/title_widget.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final PageController _pageController = PageController();

  // Danh sách địa điểm Popular Destination
  List<Destination> _popularDestinations = [];

  // Danh sách đia điểm có thể bạn sẽ thích
  List<RecommendDestination> _recommendDestinations = [];

  Future<void> _loadData() async {
    final popular = await DestinationService.loadPopularDestination();
    final recommend = await DestinationService.loadRecommendDestination();
    setState(() {
      _popularDestinations = popular;
      _recommendDestinations = recommend;
    });
  }

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Rebuild mỗi khi đổi ngôn ngữ
    var _ = context.locale;

    // Build trang home
    return Scaffold(
      backgroundColor: Color(0xFF000000),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 5),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Chào mừng
                  TitleWidget(titleText: "general.welcome".tr(), fontSize: 32),
                  // Vẽ logo
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 20,
                      horizontal: 20,
                    ),
                    child: Container(
                      width: 85,
                      height: 85,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle, // Hình tròn
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Color(0xFF1E1E1E), // Màu sáng hơn
                            Color(0xFF1A1A1A), // Màu tối
                          ],
                        ),
                      ),
                      child: ClipOval(
                        child: Image.asset(
                          'lib/assets/images/dark_logo.png',
                          width: 170,
                          height: 200,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              GradientDividerWidget(),

              // Địa điểm nội bật
              TitleWidget(
                titleText: 'home.popular_destination'.tr(),
                fontSize: 20,
              ),

              // PageView Carousel với dots indicator
              _popularDestinations.isEmpty
                  ? SizedBox(
                      height: 350,
                      child: Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFFFFAD35),
                        ),
                      ),
                    )
                  : SlideCardWidget(
                      controller: _pageController,
                      length: _popularDestinations.length,
                      destinations: _popularDestinations,
                    ),
              const SizedBox(height: 30),

              GradientDividerWidget(),

              // Có thể bạn sẽ thích
              TitleWidget(titleText: 'home.you_might_like'.tr(), fontSize: 20),

              ListView.builder(
                shrinkWrap: true, // Quan trọng!
                physics: NeverScrollableScrollPhysics(), // Tắt scroll riêng
                padding: EdgeInsets.zero,
                itemCount: _recommendDestinations.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: EdgeInsets.only(bottom: 20),
                    child: ScrollCardWidget(
                      recommendDestination: _recommendDestinations,
                      index: index,
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
