import 'package:flutter/material.dart';
import 'package:travel_app/screen/Account/widgets/divider_widget.dart';

class FaqStatWidget extends StatelessWidget {
  final String titleText;
  final String paragraphText;
  const FaqStatWidget({
    super.key,
    required this.titleText,
    required this.paragraphText,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      child: Container(
        decoration: BoxDecoration(
          color: Color(0xFF1C1C1D),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 15, vertical: 15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Tiêu đề
              Text(
                titleText,
                style: TextStyle(
                  color: Colors.white,
                  fontFamily: 'ProductSans',
                  fontWeight: FontWeight.w700,
                  fontSize: 18,
                ),
              ),

              const SizedBox(height: 15),

              DividerWidget(),

              const SizedBox(height: 15),

              // Nội dung
              Text(
                paragraphText,
                textAlign: TextAlign.justify,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                  fontFamily: 'ProductSans',
                  fontWeight: FontWeight.w300,
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }
}
