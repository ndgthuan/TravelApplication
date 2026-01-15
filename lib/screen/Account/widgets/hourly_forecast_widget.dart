import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:lottie/lottie.dart';

class HourlyForecastWidget extends StatefulWidget {
  final List<Map<String, dynamic>> hourlyData; // Thêm dòng này
  const HourlyForecastWidget({super.key, required this.hourlyData});

  @override
  State<HourlyForecastWidget> createState() => _HourlyForecastWidgetState();
}

class _HourlyForecastWidgetState extends State<HourlyForecastWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Color(0xFF1C1C1D),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Color(0xFFFFAD35), width: 1.2),
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
                final isNow = item['time'] == 'Now';
                return Container(
                  width: 70,
                  padding: EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                  decoration: BoxDecoration(
                    color: isNow ? Color(0xFFFFAD35) : Color(0xFF2C2C2D),
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
                      Lottie.network(
                        item['icon'],
                        width: 40,
                        height: 40,
                        errorBuilder: (context, error, stackTrace) =>
                            Icon(Icons.error, color: Colors.red),
                      ),
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
