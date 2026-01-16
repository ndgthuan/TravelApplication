import 'package:flutter/material.dart';

class SimpleDividerWidget extends StatelessWidget {
  const SimpleDividerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 0.5,
      width: double.infinity,
      decoration: BoxDecoration(color: Colors.grey.shade400),
    );
  }
}
