import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:travel_app/core/di/injection.dart';
import 'package:travel_app/features/explore/viewmodels/explore_view_model.dart';
import 'package:travel_app/features/explore/widgets/discover_tab.dart';
import 'package:travel_app/features/explore/widgets/my_saves_tab.dart';
import 'package:travel_app/shared/widgets/app_text_field_widget.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _searchController = TextEditingController();
  late ExploreViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    // Lấy ViewModel từ DI container
    _viewModel = getIt<ExploreViewModel>();

    // Khởi tạo dữ liệu
    _viewModel.initData();

    // Lắng nghe tab changes
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        _viewModel.changeTab(_tabController.index);
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _viewModel,
      child: Scaffold(
        backgroundColor: const Color(0xFF121212),
        body: SafeArea(
          child: Column(
            children: [
              // Search Bar
              Consumer<ExploreViewModel>(
                builder: (context, vm, _) {
                  return AppTextFieldWidget(
                    controller: _searchController,
                    hintText: 'Search destinations...',
                    prefixIcon: CupertinoIcons.search,
                    horizontalPadding: 16,
                    onChanged: (query) => _viewModel.search(query),
                    suffixIcon: vm.searchQuery.isNotEmpty
                        ? GestureDetector(
                            onTap: () {
                              _searchController.clear();
                              _viewModel.clearSearch();
                            },
                            child: Container(
                              margin: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFAD35),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                CupertinoIcons.xmark,
                                color: Colors.black,
                                size: 20,
                              ),
                            ),
                          )
                        : null,
                  );
                },
              ),

              // Tab Bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: TabBar(
                  controller: _tabController,
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.grey[500],
                  labelStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                  unselectedLabelStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                  ),
                  indicatorColor: const Color(0xFFFFAD35),
                  indicatorWeight: 3,
                  indicatorSize: TabBarIndicatorSize.label,
                  dividerColor: Colors.transparent,
                  tabs: const [
                    Tab(text: 'Discover'),
                    Tab(text: 'My Saves'),
                  ],
                ),
              ),

              // Content
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [DiscoverTab(), MySavesTab()],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
