import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import '../widgets/destination_card.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();

  // Mock data cho UI - sau này sẽ load từ JSON
  final List<Map<String, dynamic>> _mockDestinations = [
    {
      'name': 'Ha Long Bay',
      'city': 'Quang Ninh',
      'imageUrl':
          'https://images.unsplash.com/photo-1528127269322-539801943592?w=600&q=80',
      'rating': '4.9',
      'reviewCount': '28000',
      'isSaved': true,
    },
    {
      'name': 'Hoi An Lanterns',
      'city': 'Quang Nam',
      'imageUrl':
          'https://images.unsplash.com/photo-1559592413-7cec4d0cae2b?w=600&q=80',
      'rating': '4.8',
      'reviewCount': '32000',
      'isSaved': false,
    },
    {
      'name': 'Phong Nha Cave',
      'city': 'Quang Binh',
      'imageUrl':
          'https://images.unsplash.com/photo-1528181304800-259b08848526?w=600&q=80',
      'rating': '4.8',
      'reviewCount': '12000',
      'isSaved': true,
    },
    {
      'name': 'Golden Bridge',
      'city': 'Da Nang',
      'imageUrl':
          'https://images.unsplash.com/photo-1559592413-7cec4d0cae2b?w=600&q=80',
      'rating': '4.7',
      'reviewCount': '45000',
      'isSaved': false,
    },
    {
      'name': 'Sapa Rice Terraces',
      'city': 'Lao Cai',
      'imageUrl':
          'https://images.unsplash.com/photo-1528127269322-539801943592?w=600&q=80',
      'rating': '4.9',
      'reviewCount': '18000',
      'isSaved': true,
    },
    {
      'name': 'Ninh Binh',
      'city': 'Ninh Binh',
      'imageUrl':
          'https://images.unsplash.com/photo-1528181304800-259b08848526?w=600&q=80',
      'rating': '4.8',
      'reviewCount': '15000',
      'isSaved': false,
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: SafeArea(
        child: Column(
          children: [
            // Search Bar
            _buildSearchBar(),

            // Tab Bar (Discover / My Saves)
            _buildTabBar(),

            // Content
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [_buildDiscoverTab(), _buildMySavesTab()],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 16, top: 8),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E1E),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFFFAD35)),
        ),
        child: TextField(
          controller: _searchController,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: 'Search destinations...',
            hintStyle: TextStyle(color: Colors.grey[500]),
            prefixIcon: Icon(CupertinoIcons.search, color: Colors.grey[500]),
            suffixIcon: Container(
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Color(0xFFFFAD35),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                CupertinoIcons.slider_horizontal_3,
                color: Colors.black,
                size: 20,
              ),
            ),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTabBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: TabBar(
        controller: _tabController,
        labelColor: Colors.white,
        unselectedLabelColor: Colors.grey[500],
        labelStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
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
    );
  }

  Widget _buildDiscoverTab() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: MasonryGridView.count(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        itemCount: _mockDestinations.length,
        itemBuilder: (context, index) {
          final destination = _mockDestinations[index];
          // Tạo chiều cao khác nhau cho Masonry effect
          final isLarge = index % 3 == 0;
          return DestinationCard(
            name: destination['name'],
            city: destination['city'],
            imageUrl: destination['imageUrl'],
            rating: destination['rating'],
            reviewCount: destination['reviewCount'],
            isSaved: destination['isSaved'],
            height: isLarge ? 280 : 200,
            onTap: () {
              // TODO: Navigate to detail
            },
            onSaveToggle: () {
              setState(() {
                destination['isSaved'] = !destination['isSaved'];
              });
            },
          );
        },
      ),
    );
  }

  Widget _buildMySavesTab() {
    final savedDestinations = _mockDestinations
        .where((d) => d['isSaved'] == true)
        .toList();

    if (savedDestinations.isEmpty) {
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
            name: destination['name'],
            city: destination['city'],
            imageUrl: destination['imageUrl'],
            rating: destination['rating'],
            reviewCount: destination['reviewCount'],
            isSaved: destination['isSaved'],
            height: isLarge ? 280 : 200,
            onTap: () {},
            onSaveToggle: () {
              setState(() {
                destination['isSaved'] = !destination['isSaved'];
              });
            },
          );
        },
      ),
    );
  }
}
