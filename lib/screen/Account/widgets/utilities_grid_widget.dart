import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'extension_widget.dart';

class UtilitiesGridWidget extends StatelessWidget {
  const UtilitiesGridWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: ExtensionWidget(
                icon: Icons.monetization_on,
                title: 'home.currency_exchange'.tr(),
              ),
            ),
            const SizedBox(width: 5),

            Expanded(
              child: ExtensionWidget(
                icon: Icons.g_translate,
                title: 'home.text_translation'.tr(),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),

        Row(
          children: [
            Expanded(
              child: ExtensionWidget(
                icon: Icons.cloud,
                title: 'home.weather_forecast'.tr(),
              ),
            ),
            const SizedBox(width: 5),

            Expanded(
              child: ExtensionWidget(
                icon: Icons.public,
                title: 'home.world_clock'.tr(),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
