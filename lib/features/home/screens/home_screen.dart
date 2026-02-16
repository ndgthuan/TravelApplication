import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:provider/provider.dart';
import 'package:travel_app/features/home/viewmodels/home_view_model.dart';
import 'package:travel_app/features/home/widgets/slide_card_widget.dart';
import 'package:travel_app/features/home/widgets/scroll_card_widget.dart';
import 'package:travel_app/shared/widgets/header_title_widget.dart';
import 'package:travel_app/shared/providers/saved_count_provider.dart';
import 'package:travel_app/shared/widgets/app_header_widget.dart';

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
              AppHeaderWidget(
                title: "general.welcome".tr(),
                trailing: Padding(
                  padding: const EdgeInsets.only(right: 10.0),
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
              ),

              // Địa điểm nổi bật
              HeaderTitleWidget(
                titleText: 'home.popular_destination'.tr(),
                fontSize: 20,
              ),

              // PageView Carousel với dots indicator
              viewModel.isLoading
                  ? SizedBox(
                      height: 350,
                      child: Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFFFF6D00),
                        ),
                      ),
                    )
                  : SlideCardWidget(
                      controller: _pageController,
                      destinations: viewModel.top5Display,
                      length: viewModel.top5Display.length,
                      isSaved: viewModel.isSaved,
                      onHeartTap: (name) async {
                        await viewModel.toggleSave(name, false);
                        if (!context.mounted) return;
                        if (viewModel.isSaved(name)) {
                          context.read<SavedCountProvider>().increment();
                        }
                      },
                    ),
              const SizedBox(height: 10),

              // Có thể bạn sẽ thích
              HeaderTitleWidget(
                titleText: 'home.you_might_like'.tr(),
                fontSize: 20,
              ),

              ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                padding: EdgeInsets.zero,
                itemCount: viewModel.top10Display.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: EdgeInsets.only(bottom: 20),
                    child: ScrollCardWidget(
                      destinations: viewModel.top10Display,
                      index: index,
                      isSaved: viewModel.isSaved,
                      onHeartTap: (name) async {
                        await viewModel.toggleSave(name, true);
                        if (!context.mounted) return;
                        if (viewModel.isSaved(name)) {
                          context.read<SavedCountProvider>().increment();
                        }
                      },
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
