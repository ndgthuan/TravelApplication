import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:persistent_bottom_nav_bar_v2/persistent_bottom_nav_bar_v2.dart';
import 'package:travel_app/screen/Account/screens/account_screen.dart';
import 'package:travel_app/screen/Favorite/screens/favourite_screen.dart';
import 'package:travel_app/screen/Home/screens/home_screen.dart';
import 'package:travel_app/screen/Notification/screens/notification_screen.dart';
import 'package:travel_app/screen/Plan/screens/plan_screen.dart';

class BottomNavigation extends StatelessWidget {
  const BottomNavigation({super.key});

  ItemConfig _buildItem({required IconData icon, required String title}) {
    return ItemConfig(
      icon: Icon(icon),
      title: title,
      activeForegroundColor: Color(0xFFFFAD35),
      textStyle: GoogleFonts.beVietnamPro(fontSize: 14),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PersistentTabView(
      controller: PersistentTabController(initialIndex: 2),
      tabs: [
        PersistentTabConfig(
          screen: const PlanScreen(),
          item: _buildItem(icon: Icons.map, title: 'Plan'),
        ),
        PersistentTabConfig(
          screen: const FavouriteScreen(),
          item: _buildItem(icon: Icons.favorite, title: 'Favourite'),
        ),
        PersistentTabConfig(
          screen: const HomeScreens(),
          item: _buildItem(icon: Icons.house, title: 'Home'),
        ),
        PersistentTabConfig(
          screen: const NotificationScreen(),
          item: _buildItem(icon: Icons.notifications, title: 'Notification'),
        ),
        PersistentTabConfig(
          screen: const AccountScreen(),
          item: _buildItem(
            icon: Icons.account_circle_rounded,
            title: 'Account',
          ),
        ),
      ],
      navBarBuilder: (navBarConfig) => Style4BottomNavBar(
        navBarConfig: navBarConfig,
        navBarDecoration: NavBarDecoration(color: Color(0xFF1C1C1D)),
      ),
    );
  }
}
