import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:persistent_bottom_nav_bar_v2/persistent_bottom_nav_bar_v2.dart';
import 'package:travel_app/features/account/screens/account_screen.dart';
import 'package:travel_app/features/favourite/screens/favourite_screen.dart';
import 'package:travel_app/features/home/screens/home_screen.dart';
import 'package:travel_app/features/notification/screens/notification_screen.dart';
import 'package:travel_app/features/plan/screens/plan_screen.dart';

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
          screen: PlanScreen(),
          item: _buildItem(icon: Icons.map, title: 'navigation.plan'.tr()),
        ),
        PersistentTabConfig(
          screen: FavouriteScreen(),
          item: _buildItem(
            icon: Icons.favorite,
            title: 'navigation.favourite'.tr(),
          ),
        ),
        PersistentTabConfig(
          screen: HomeScreen(),
          item: _buildItem(icon: Icons.house, title: 'home.home'.tr()),
        ),
        PersistentTabConfig(
          screen: NotificationScreen(),
          item: _buildItem(
            icon: Icons.notifications,
            title: 'navigation.notification'.tr(),
          ),
        ),
        PersistentTabConfig(
          screen: AccountScreen(),
          item: _buildItem(
            icon: Icons.account_circle_rounded,
            title: 'account.account'.tr(),
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
