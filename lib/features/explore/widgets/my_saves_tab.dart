import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:provider/provider.dart';
import 'package:travel_app/features/explore/viewmodels/explore_view_model.dart';
import 'package:travel_app/features/explore/widgets/destination_card.dart';

class MySavesTab extends StatelessWidget {
  const MySavesTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ExploreViewModel>(
      builder: (context, viewModel, _) {
        final savedDestinations = viewModel.savedDestinations;

        if (savedDestinations.isEmpty) {
          return _buildEmptyState();
        }

        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: MasonryGridView.count(
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            itemCount: savedDestinations.length,
            itemBuilder: (context, index) {
              final destination = savedDestinations[index];
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

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(CupertinoIcons.heart, size: 64, color: Colors.grey[600]),
          const SizedBox(height: 16),
          Text(
            'No saved destinations yet',
            style: TextStyle(color: Colors.grey[500], fontSize: 16),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap the heart icon to save places',
            style: TextStyle(color: Colors.grey[600], fontSize: 14),
          ),
        ],
      ),
    );
  }
}
