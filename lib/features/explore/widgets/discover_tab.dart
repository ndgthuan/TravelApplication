import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:provider/provider.dart';
import 'package:travel_app/features/explore/viewmodels/explore_view_model.dart';
import 'package:travel_app/features/explore/widgets/destination_card.dart';

// Widget hiển thị tab Discover với infinite scroll
class DiscoverTab extends StatefulWidget {
  const DiscoverTab({super.key});

  @override
  State<DiscoverTab> createState() => _DiscoverTabState();
}

class _DiscoverTabState extends State<DiscoverTab> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  // Infinite scroll: load more khi scroll gần cuối
  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 300) {
      // Lấy viewModel và gọi loadMore
      final viewModel = context.read<ExploreViewModel>();
      if (!viewModel.isLoadingMore && viewModel.hasMore) {
        viewModel.loadMore();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ExploreViewModel>(
      builder: (context, viewModel, _) {
        // Show loading indicator for initial load
        if (viewModel.isInitialLoading) {
          return const Center(
            child: CircularProgressIndicator(color: Color(0xFFFFAD35)),
          );
        }

        // Show searching indicator
        if (viewModel.isSearching) {
          return const Center(
            child: CircularProgressIndicator(color: Color(0xFFFFAD35)),
          );
        }

        final destinations = viewModel.destinations;

        // Empty state for search
        if (destinations.isEmpty && viewModel.searchQuery.isNotEmpty) {
          return _buildEmptySearchState();
        }

        // Empty state for no data
        if (destinations.isEmpty) {
          return _buildEmptyState();
        }

        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: MasonryGridView.count(
            controller: _scrollController,
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            // Thêm 1 item cho loading indicator nếu còn data
            itemCount: destinations.length + (viewModel.hasMore ? 1 : 0),
            itemBuilder: (context, index) {
              // Loading indicator at bottom (infinite scroll)
              if (index >= destinations.length) {
                return _buildLoadingMoreIndicator(viewModel.isLoadingMore);
              }

              final destination = destinations[index];
              // Tạo chiều cao khác nhau cho Masonry effect
              final isLarge = index % 3 == 0;

              return DestinationCard(
                name: destination.name,
                city: destination.city,
                imageUrl: destination.imageUrl,
                rating: destination.rating,
                reviewCount: destination.reviewCount,
                isSaved: destination.isSaved,
                height: isLarge ? 280 : 200,
                onTap: () {
                  // TODO: Navigate to detail
                },
                onSaveToggle: () {
                  viewModel.toggleSave(destination);
                },
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildEmptySearchState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(CupertinoIcons.search, size: 64, color: Colors.grey[600]),
          const SizedBox(height: 16),
          Text(
            'No results found',
            style: TextStyle(color: Colors.grey[500], fontSize: 16),
          ),
          const SizedBox(height: 8),
          Text(
            'Try searching with different keywords',
            style: TextStyle(color: Colors.grey[600], fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(CupertinoIcons.compass, size: 64, color: Colors.grey[600]),
          const SizedBox(height: 16),
          Text(
            'No destinations available',
            style: TextStyle(color: Colors.grey[500], fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingMoreIndicator(bool isLoading) {
    return Container(
      height: 80,
      alignment: Alignment.center,
      child: isLoading
          ? const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(
                  color: Color(0xFFFFAD35),
                  strokeWidth: 2,
                ),
                SizedBox(height: 8),
                Text(
                  'Loading more...',
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            )
          : const SizedBox.shrink(),
    );
  }
}
