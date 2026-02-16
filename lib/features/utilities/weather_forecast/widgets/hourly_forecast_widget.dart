import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:lottie/lottie.dart';

class HourlyForecastWidget extends StatefulWidget {
  final List<Map<String, dynamic>> hourlyData;
  const HourlyForecastWidget({super.key, required this.hourlyData});

  @override
  State<HourlyForecastWidget> createState() => _HourlyForecastWidgetState();
}

Widget _buildIcon(BuildContext context, String? iconUrl) {
  final url = (iconUrl ?? '').toString().trim();
  if (url.isEmpty) {
    return Icon(
      CupertinoIcons.cloud_sun_fill,
      color: Color(0xFFFF6D00),
      size: 40,
    );
  }
  return Lottie.network(
    url,
    width: 40,
    height: 40,
    errorBuilder: (context, error, stackTrace) =>
        Icon(CupertinoIcons.exclamationmark_circle, color: Colors.red),
  );
}

class _HourlyForecastWidgetState extends State<HourlyForecastWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Color(0xFF1C1C1D),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Color(0xFFFF6D00), width: 1.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'weather.hourly_forecast'.tr(),
            style: GoogleFonts.beVietnamPro(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 15),
          SizedBox(
            height: 100,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: widget.hourlyData.length,
              separatorBuilder: (context, index) => SizedBox(width: 10),
              itemBuilder: (context, index) {
                final item = widget.hourlyData[index];
                final isNow = item['time'] == 'weather.now'.tr();
                return Container(
                  width: 70,
                  padding: EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                  decoration: BoxDecoration(
                    color: isNow ? Color(0xFFFF6D00) : Color(0xFF2C2C2D),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        item['time'],
                        style: GoogleFonts.beVietnamPro(
                          color: isNow ? Colors.black : Colors.grey[400],
                          fontSize: 12,
                          fontWeight: isNow
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                      _buildIcon(context, item['icon']),
                      Text(
                        '${item['temp'].toInt()}°C',
                        style: GoogleFonts.beVietnamPro(
                          color: isNow ? Colors.black : Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
