import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';

class CurrentWeatherCardWidget extends StatelessWidget {
  final String location;
  final String country;
  final int temperature;
  final String condition;
  final int humidity;
  final int windSpeed;
  final int uvIndex;
  final String iconUrl;

  const CurrentWeatherCardWidget({
    super.key,
    required this.location,
    required this.country,
    required this.temperature,
    required this.condition,
    required this.humidity,
    required this.windSpeed,
    required this.uvIndex,
    required this.iconUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Color(0xFF1C1C1D),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Color(0xFFFFAD35), width: 1.2),
      ),
      child: Stack(
        children: [
          // Weather Icon positioned at top right
          Positioned(
            top: 10,
            right: 10,
            child: Lottie.network(
              iconUrl,
              width: 150,
              height: 150,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) => Container(),
            ),
          ),

          // Main Content
          Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Location Row
                Row(
                  children: [
                    Icon(
                      Icons.location_pin,
                      color: Color(0xFFFFAD35),
                      size: 18,
                    ),
                    Expanded(
                      child: Text(
                        '$location, $country',
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.beVietnamPro(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10),

                // Temperature
                Padding(
                  padding: const EdgeInsets.only(left: 40),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$temperature',
                        style: TextStyle(
                          fontFamily: 'ProductSans',
                          fontWeight: FontWeight.w700,
                          color: Color(0xFFFFAD35),
                          fontSize: 100,
                          height: 1,
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: 5),
                        child: Text(
                          '°C',
                          style: TextStyle(
                            fontFamily: 'ProductSans',
                            fontWeight: FontWeight.w400,
                            color: Color(0xFFFFAD35),
                            fontSize: 22,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Condition
                Center(
                  child: Text(
                    condition,
                    style: TextStyle(
                      fontFamily: 'ProductSans',
                      color: Colors.white,
                      fontSize: 20,
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                // Weather Details Row with Dividers
                Container(
                  decoration: BoxDecoration(
                    border: Border(
                      top: BorderSide(color: Color(0xFFFFAD35), width: 1),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildWeatherDetail(
                        Icons.water_drop,
                        'weather.humidity'.tr(),
                        '$humidity%',
                      ),
                      Container(width: 1, height: 43, color: Color(0xFFFFAD35)),
                      _buildWeatherDetail(
                        Icons.air,
                        'weather.wind'.tr(),
                        '$windSpeed km/h',
                      ),
                      Container(width: 1, height: 43, color: Color(0xFFFFAD35)),
                      _buildWeatherDetail(
                        Icons.wb_sunny_outlined,
                        'weather.uv_index'.tr(),
                        '$uvIndex',
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  //==========================================================================//
  //                        HELPER WIDGETS                                    //
  //==========================================================================//

  Widget _buildWeatherDetail(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: Color(0xFFFFAD35), size: 33),
        SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 5),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'ProductSans',
                color: Colors.white,
                fontSize: 13,
              ),
            ),
            Text(
              value,
              style: GoogleFonts.beVietnamPro(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
