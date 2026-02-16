import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// Appbar dùng để đè lên map
class ActivityPlanAppBar extends StatelessWidget {
  final String title;
  final VoidCallback? onBack;
  final VoidCallback? onMenu;

  const ActivityPlanAppBar({
    super.key,
    this.title = 'Chi tiết chuyến đi',
    this.onBack,
    this.onMenu,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: EdgeInsets.fromLTRB(
          8,
          MediaQuery.paddingOf(context).top + 8,
          8,
          12,
        ),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.black54, Colors.transparent],
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              onPressed: onBack ?? () => Navigator.of(context).pop(),
              icon: const Icon(CupertinoIcons.back, color: Colors.white),
            ),
            Expanded(
              child: Text(
                title,
                textAlign: TextAlign.center,
                style: GoogleFonts.beVietnamPro(
                  color: Colors.white,
                  fontSize: 22,
                ),
              ),
            ),
            IconButton(
              onPressed: onMenu,
              icon: const Icon(
                CupertinoIcons.ellipsis_vertical,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
