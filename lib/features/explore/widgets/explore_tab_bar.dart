import 'package:flutter/material.dart';

// Widget Tab Bar cho Explore Screen (Discover / My Saves)
class ExploreTabBar extends StatelessWidget {
  final TabController controller;

  const ExploreTabBar({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: TabBar(
        controller: controller,
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
}
