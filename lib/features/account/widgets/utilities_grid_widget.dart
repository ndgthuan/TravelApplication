import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:travel_app/features/utilities/currency_exchange/screens/currency_exchange_screen.dart';
import 'package:travel_app/features/utilities/text_translation/screens/text_translation_screen.dart';
import 'package:travel_app/features/utilities/weather_forecast/screens/weather_forecast_screen.dart';
import 'package:travel_app/features/utilities/world_clock/screens/world_clock_screen.dart';
import 'utility_card_widget.dart';

class UtilitiesGridWidget extends StatelessWidget {
  const UtilitiesGridWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: UtilityCardWidget(
                icon: CupertinoIcons.money_dollar_circle,
                title: 'home.currency_exchange'.tr(),
                onTap: () {
                  Navigator.of(context, rootNavigator: true).push(
                    MaterialPageRoute(
                      builder: (context) => CurrencyExchangeScreen(),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(width: 5),

            Expanded(
              child: UtilityCardWidget(
                icon: Icons.g_translate,
                title: 'home.text_translation'.tr(),
                onTap: () {
                  Navigator.of(context, rootNavigator: true).push(
                    MaterialPageRoute(
                      builder: (context) => TextTranslationScreen(),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),

        Row(
          children: [
            Expanded(
              child: UtilityCardWidget(
                icon: Icons.cloud,
                title: 'home.weather_forecast'.tr(),
                onTap: () {
                  Navigator.of(context, rootNavigator: true).push(
                    MaterialPageRoute(
                      builder: (context) => WeatherForecastScreen(),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(width: 5),

            Expanded(
              child: UtilityCardWidget(
                icon: CupertinoIcons.globe,
                title: 'home.world_clock'.tr(),
                onTap: () {
                  Navigator.of(context, rootNavigator: true).push(
                    MaterialPageRoute(builder: (context) => WorldClockScreen()),
                  );
                },
              ),
            ),
          ],
        ),
      ],
    );
  }
}
