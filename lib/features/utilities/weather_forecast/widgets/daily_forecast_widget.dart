import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:lottie/lottie.dart';

class DailyForecastWidget extends StatelessWidget {
  final List<Map<String, dynamic>> dailyData;

  const DailyForecastWidget({super.key, required this.dailyData});

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
            'weather.daily_forecast'.tr(),
            style: GoogleFonts.beVietnamPro(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 15),
          ListView.separated(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: dailyData.length,
            separatorBuilder: (context, index) =>
                Divider(color: Colors.grey[800], height: 1),
            itemBuilder: (context, index) {
              final item = dailyData[index];
              final isToday = item['day'] == 'weather.today'.tr();
              return Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Day name
                    SizedBox(
                      width: 60,
                      child: Text(
                        item['day'],
                        style: GoogleFonts.beVietnamPro(
                          color: isToday ? Color(0xFFFFAD35) : Colors.white,
                          fontSize: 14,
                          fontWeight: isToday
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                    ),
                    // Weather icon
                    Lottie.network(
                      item['icon'],
                      width: 40,
                      height: 40,
                      errorBuilder: (context, error, stackTrace) =>
                          Icon(Icons.error, color: Colors.white, size: 20),
                    ),
                    // Temperature range
                    Row(
                      children: [
                        Text(
                          item['low'],
                          style: GoogleFonts.beVietnamPro(
                            color: Colors.grey[500],
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          ' / ',
                          style: GoogleFonts.beVietnamPro(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          item['high'],
                          style: GoogleFonts.beVietnamPro(
                            color: Color(0xFFFFAD35),
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
