import 'package:flutter/material.dart';
import 'package:persistent_bottom_nav_bar_v2/persistent_bottom_nav_bar_v2.dart';
import 'package:travel_app/screen/Account/screens/account_screen.dart';
import 'package:travel_app/screen/Favorite/screens/favourite_screen.dart';
import 'package:travel_app/screen/Home/screens/home_screens.dart';
import 'package:travel_app/screen/Notification/screens/notification_screen.dart';
import 'package:travel_app/screen/Plan/screens/plan_screen.dart';

class BottomNavigation extends StatelessWidget {
  const BottomNavigation({super.key});

  @override
  Widget build(BuildContext context) {
    return PersistentTabView(
      controller: PersistentTabController(initialIndex: 2),
      tabs: [
        PersistentTabConfig(
          screen: const PlanScreen(),
          item: ItemConfig(
            icon: Icon(Icons.map),
            title: "Plan",
            activeForegroundColor: Color(0xFFFFAD35),
          ),
        ),
        PersistentTabConfig(
          screen: const FavouriteScreen(),
          item: ItemConfig(
            icon: Icon(Icons.favorite),
            title: 'Favourite',
            activeForegroundColor: Color(0xFFFFAD35),
          ),
        ),
        PersistentTabConfig(
          screen: const HomeScreens(),
          item: ItemConfig(
            icon: Icon(Icons.house),
            title: "Home",
            activeForegroundColor: Color(0xFFFFAD35),
          ),
        ),
        PersistentTabConfig(
          screen: const NotificationScreen(),
          item: ItemConfig(
            icon: Icon(Icons.notifications),
            title: "Notification",
            activeForegroundColor: Color(0xFFFFAD35),
          ),
        ),
        PersistentTabConfig(
          screen: const AccountScreen(),
          item: ItemConfig(
            icon: Icon(Icons.account_circle_rounded),
            title: 'Account',
            activeForegroundColor: Color(0xFFFFAD35),
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
