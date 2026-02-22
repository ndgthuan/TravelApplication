// Màn thông báo - dark mode, card bo góc, accent cam

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:travel_app/features/notification/viewmodels/notification_view_model.dart';
import 'package:travel_app/features/notification/widgets/notification_card_widget.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NotificationViewModel>().loadNotifications();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF000000),
      body: SafeArea(
        child: DefaultTextStyle(
          style: GoogleFonts.beVietnamPro(
            color: Colors.white,
            fontSize: 16,
          ),
          child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
              child: Text(
                'Thông báo',
                style: GoogleFonts.beVietnamPro(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Expanded(
              child: Consumer<NotificationViewModel>(
                builder: (context, vm, _) {
                  if (vm.isLoading) {
                    return Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFFFF6D00),
                        strokeWidth: 2,
                      ),
                    );
                  }
                  if (vm.items.isEmpty) {
                    return Center(
                      child: Text(
                        'Chưa có thông báo',
                        style: GoogleFonts.beVietnamPro(
                          color: Colors.white38,
                          fontSize: 16,
                        ),
                      ),
                    );
                  }
                  return RefreshIndicator(
                    onRefresh: vm.loadNotifications,
                    color: Color(0xFFFF6D00),
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                      itemCount: vm.items.length,
                      itemBuilder: (_, i) => NotificationCardWidget(item: vm.items[i]),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
        ),
      ),
    );
  }
}
