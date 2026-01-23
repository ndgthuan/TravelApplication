import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:provider/provider.dart';
import 'package:travel_app/features/home/viewmodels/home_view_model.dart';
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

  @override
  void initState() {
    super.initState();
    // Gọi ViewModel load data từ firestore sau khi build xong
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HomeViewModel>().loadData();
    });
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
    final viewModel = context.watch<HomeViewModel>();
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
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Color(0xFF1E1E1E), Color(0xFF1A1A1A)],
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

              // Địa điểm nổi bật
              TitleWidget(
                titleText: 'home.popular_destination'.tr(),
                fontSize: 20,
              ),

              // PageView Carousel với dots indicator
              viewModel.isLoading
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
                      length: viewModel.popularDestinations.length,
                      destinations: viewModel.popularDestinations,
                    ),
              const SizedBox(height: 30),

              GradientDividerWidget(),

              // Có thể bạn sẽ thích
              TitleWidget(titleText: 'home.you_might_like'.tr(), fontSize: 20),

              ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                padding: EdgeInsets.zero,
                itemCount: viewModel.recommendDestinations.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: EdgeInsets.only(bottom: 20),
                    child: ScrollCardWidget(
                      recommendDestination: viewModel.recommendDestinations,
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
