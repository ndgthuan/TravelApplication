import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:travel_app/shared/widgets/app_bar_widget.dart';
import 'package:travel_app/shared/widgets/app_text_field_widget.dart';

class OngoingPlanSectionScreen extends StatefulWidget {
  const OngoingPlanSectionScreen({super.key});

  @override
  State<OngoingPlanSectionScreen> createState() =>
      _OngoingPlanSectionScreenState();
}

class _OngoingPlanSectionScreenState extends State<OngoingPlanSectionScreen> {
  final _mapController = MapController();
  TimeOfDay _time = const TimeOfDay(hour: 18, minute: 30);
  DateTime _date = DateTime(2023, 10, 12);
  LatLng _pinPosition = const LatLng(21.0285, 105.8542);

  Future<void> _pickTime() async {
    TimeOfDay temp = _time;
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: 320,
        decoration: BoxDecoration(
          color: Color(0xFF1C1C1D),
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      'Hủy',
                      style: GoogleFonts.beVietnamPro(color: Colors.white70),
                    ),
                  ),
                  Text(
                    'Chọn giờ',
                    style: GoogleFonts.beVietnamPro(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      setState(() => _time = temp);
                      Navigator.pop(context);
                    },
                    child: Text(
                      'Xong',
                      style: GoogleFonts.beVietnamPro(color: Color(0xFFFF6D00)),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: CupertinoTheme(
                data: CupertinoThemeData(
                  brightness: Brightness.dark,
                  textTheme: CupertinoTextThemeData(
                    dateTimePickerTextStyle: GoogleFonts.beVietnamPro(
                      color: Colors.white,
                      fontSize: 21,
                    ),
                  ),
                ),
                child: CupertinoTimerPicker(
                  mode: CupertinoTimerPickerMode.hm,
                  initialTimerDuration: Duration(
                    hours: _time.hour,
                    minutes: _time.minute,
                  ),
                  onTimerDurationChanged: (Duration d) {
                    temp = TimeOfDay(
                      hour: d.inHours % 24,
                      minute: d.inMinutes % 60,
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickDate() async {
    DateTime temp = _date;
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: 320,
        decoration: BoxDecoration(
          color: Color(0xFF1C1C1D),
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      'Hủy',
                      style: GoogleFonts.beVietnamPro(color: Colors.white70),
                    ),
                  ),
                  Text(
                    'Chọn ngày',
                    style: GoogleFonts.beVietnamPro(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      setState(() => _date = temp);
                      Navigator.pop(context);
                    },
                    child: Text(
                      'Xong',
                      style: GoogleFonts.beVietnamPro(color: Color(0xFFFF6D00)),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: CupertinoTheme(
                data: CupertinoThemeData(
                  brightness: Brightness.dark,
                  textTheme: CupertinoTextThemeData(
                    dateTimePickerTextStyle: GoogleFonts.beVietnamPro(
                      color: Colors.white,
                      fontSize: 21,
                    ),
                  ),
                ),
                child: CupertinoDatePicker(
                  mode: CupertinoDatePickerMode.date,
                  initialDateTime: _date,
                  minimumDate: DateTime(2020),
                  maximumDate: DateTime(2030),
                  onDateTimeChanged: (DateTime d) => temp = d,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget(title: 'Thêm điểm đến'),
      backgroundColor: Color(0xFF000000),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  AppTextFieldWidget(
                    labelText: 'Tên hoạt động',
                    showLabel: true,
                    hintText: 'VD: Ăn tối...',
                    labelFontSize: 17,
                  ),
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Text(
                      'Loại hoạt động',
                      style: GoogleFonts.beVietnamPro(
                        color: Colors.white,
                        fontSize: 17,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 10),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.3),
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 10,
                            ),
                            child: Text(
                              'Ăn uống',
                              style: GoogleFonts.beVietnamPro(
                                color: Colors.white,
                                fontSize: 17,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 10),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.3),
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 10,
                            ),
                            child: Text(
                              'Tham quan',
                              style: GoogleFonts.beVietnamPro(
                                color: Colors.white,
                                fontSize: 17,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 10),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.3),
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 10,
                            ),
                            child: Text(
                              'Di chuyển',
                              style: GoogleFonts.beVietnamPro(
                                color: Colors.white,
                                fontSize: 17,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Text(
                      'Thời gian',
                      style: GoogleFonts.beVietnamPro(
                        color: Colors.white,
                        fontSize: 17,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: _pickTime,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 14,
                              ),
                              decoration: BoxDecoration(
                                color: Color(0xFF1C1C1D),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: Color(0xFF333333)),
                              ),
                              child: Row(
                                children: [
                                  Text(
                                    '${_time.hour.toString().padLeft(2, '0')}:${_time.minute.toString().padLeft(2, '0')}',
                                    style: GoogleFonts.beVietnamPro(
                                      color: Colors.white,
                                      fontSize: 17,
                                    ),
                                  ),
                                  const Spacer(),
                                  Icon(
                                    CupertinoIcons.chevron_down,
                                    color: Colors.white54,
                                    size: 20,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: GestureDetector(
                            onTap: _pickDate,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 14,
                              ),
                              decoration: BoxDecoration(
                                color: Color(0xFF1C1C1D),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: Color(0xFF333333)),
                              ),
                              child: Row(
                                children: [
                                  Text(
                                    '${_date.day.toString().padLeft(2, '0')}/${_date.month.toString().padLeft(2, '0')}/${_date.year}',
                                    style: GoogleFonts.beVietnamPro(
                                      color: Colors.white,
                                      fontSize: 17,
                                    ),
                                  ),
                                  const Spacer(),
                                  Icon(
                                    CupertinoIcons.chevron_down,
                                    color: Colors.white54,
                                    size: 20,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Text(
                      'Vị trí',
                      style: GoogleFonts.beVietnamPro(
                        color: Colors.white,
                        fontSize: 17,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.3),
                          width: 1,
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: SizedBox(
                          height: 300,
                          width: double.infinity,
                          child: Stack(
                            children: [
                              Positioned.fill(
                                child: FlutterMap(
                                  mapController: _mapController,
                                  options: MapOptions(
                                    initialCenter: _pinPosition,
                                    initialZoom: 15,
                                    onTap: (_, point) {
                                      setState(() => _pinPosition = point);
                                    },
                                  ),
                                  children: [
                                    TileLayer(
                                      urlTemplate:
                                          'https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}{r}.png',
                                      subdomains: const ['a', 'b', 'c', 'd'],
                                      userAgentPackageName: 'com.travel.app',
                                      retinaMode: RetinaMode.isHighDensity(
                                        context,
                                      ),
                                    ),
                                    MarkerLayer(
                                      markers: [
                                        Marker(
                                          point: _pinPosition,
                                          width: 40,
                                          height: 40,
                                          child: Icon(
                                            Icons.location_on,
                                            size: 40,
                                            color: Color(0xFFFF6D00),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              Positioned(
                                top: 12,
                                left: 12,
                                right: 12,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Color(0xFF1C1C1D),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: Color(0xFF333333),
                                    ),
                                  ),
                                  child: TextField(
                                    style: GoogleFonts.beVietnamPro(
                                      color: Colors.white,
                                      fontSize: 16,
                                    ),
                                    decoration: InputDecoration(
                                      hintText: 'Tìm kiếm địa điểm...',
                                      hintStyle: GoogleFonts.beVietnamPro(
                                        color: Colors.white54,
                                        fontSize: 16,
                                      ),
                                      prefixIcon: Icon(
                                        Icons.search,
                                        color: Colors.white54,
                                        size: 22,
                                      ),
                                      border: InputBorder.none,
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                            horizontal: 16,
                                            vertical: 14,
                                          ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(
              20,
              16,
              20,
              16 + MediaQuery.paddingOf(context).bottom,
            ),
            child: SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFFFF6D00),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Lưu điểm đến',
                  style: GoogleFonts.beVietnamPro(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
