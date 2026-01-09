import 'package:flutter/material.dart';
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
                title: 'Currency Exchange',
              ),
            ),
            const SizedBox(width: 5),

            Expanded(
              child: ExtensionWidget(
                icon: Icons.g_translate,
                title: 'Text translation',
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
                title: 'Weather Forecast',
              ),
            ),
            const SizedBox(width: 5),

            Expanded(
              child: ExtensionWidget(icon: Icons.public, title: 'World Clock'),
            ),
          ],
        ),
      ],
    );
  }
}
