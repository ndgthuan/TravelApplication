import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/cupertino.dart';

class AppBarWidget extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final IconData icon;
  const AppBarWidget({
    super.key,
    required this.title,
    this.icon = CupertinoIcons.back,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      title: Text(
        title,
        style: GoogleFonts.beVietnamPro(color: Colors.white, fontSize: 22),
      ),
      surfaceTintColor: Colors.transparent,
      leading: IconButton(
        onPressed: () {
          Navigator.of(context).pop();
        },
        icon: Icon(icon, color: Colors.white),
      ),
      centerTitle: true,
      iconTheme: IconThemeData(color: Colors.white),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
