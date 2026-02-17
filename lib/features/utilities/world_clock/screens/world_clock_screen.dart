import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:provider/provider.dart';
import 'package:travel_app/shared/widgets/app_bar_widget.dart';
import '../widgets/time_zone_card.dart';
import '../viewmodels/world_clock_view_model.dart';
import '../widgets/add_clock_bottom_sheet.dart';
import 'package:travel_app/shared/widgets/app_button_widget.dart';

class WorldClockScreen extends StatefulWidget {
  const WorldClockScreen({super.key});

  @override
  State<WorldClockScreen> createState() => _WorldClockScreenState();
}

class _WorldClockScreenState extends State<WorldClockScreen> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<WorldClockViewModel>().loadTimezones();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<WorldClockViewModel>();

    return Scaffold(
      backgroundColor: Color(0xFF000000),
      appBar: AppBarWidget(title: 'world_clock.title'.tr()),
      body: viewModel.isLoading
          ? Center(child: CircularProgressIndicator(color: Color(0xFFFF6D00)))
          : Stack(
              children: [
                // Danh sách timezone đã lưu
                viewModel.timezones.isEmpty
                    ? Center(
                        child: Text(
                          'world_clock.empty'.tr(),
                          style: GoogleFonts.beVietnamPro(color: Colors.grey),
                        ),
                      )
                    : ListView.builder(
                        padding: EdgeInsets.only(
                          left: 10,
                          right: 10,
                          bottom: 100,
                        ),
                        itemCount: viewModel.timezones.length,
                        itemBuilder: (context, index) {
                          final tz = viewModel.timezones[index];
                          final offset = viewModel.getTimezoneOffset(
                            tz['timezone'],
                          );

                          return TimeZoneCard(
                            city: tz['city'],
                            country: tz['country'],
                            timezone: tz['timezone'],
                            timezoneOffset: offset,
                            onDelete: () => viewModel.removeTimezone(index),
                          );
                        },
                      ),

                // Button thêm city
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 10,
                  child: AppButtonWidget(
                    buttonText: 'world_clock.add_city'.tr(),
                    onTap: () => showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Color(0xFF1C1C1D),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(20),
                        ),
                      ),
                      builder: (_) => AddClockBottomSheet(
                        searchController: _searchController,
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
