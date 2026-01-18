import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';

class ExchangeBoardWidget extends StatelessWidget {
  final bool showIcon;
  final bool showText;
  final String label;
  final String amount;
  final String currencyCode;
  final String currencyName;
  final String flag;
  final bool isEditable;
  final TextEditingController? controller;
  final VoidCallback? onCurrencyTap;

  const ExchangeBoardWidget({
    super.key,
    required this.label,
    required this.amount,
    required this.currencyCode,
    required this.currencyName,
    required this.flag,
    this.isEditable = false,
    this.controller,
    this.onCurrencyTap,
    this.showIcon = false,
    this.showText = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Color(0xFF1C1C1D),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Color(0xFFFFAD35), width: 1.2),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Label (From/To)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    label,
                    style: GoogleFonts.beVietnamPro(
                      color: Colors.grey[400],
                      fontSize: 14,
                    ),
                  ),

                  GestureDetector(
                    onTap: onCurrencyTap,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Color(0xFF2C2C2D),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          Text(flag, style: TextStyle(fontSize: 18)),
                          SizedBox(width: 6),
                          Text(
                            currencyCode,
                            style: GoogleFonts.beVietnamPro(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(width: 4),
                          Icon(
                            CupertinoIcons.chevron_down,
                            color: Colors.white,
                            size: 20,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10),

              // Amount
              isEditable
                  ? TextField(
                      controller: controller,
                      style: GoogleFonts.beVietnamPro(
                        color: Color(0xFFFFAD35),
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                      ),
                      keyboardType: TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: '0.00',
                        hintStyle: GoogleFonts.beVietnamPro(
                          color: Colors.grey[600],
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    )
                  : Text(
                      amount,
                      style: GoogleFonts.beVietnamPro(
                        color: Color(0xFFFFAD35),
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

              SizedBox(height: 8),

              // Currency name
              Text(
                currencyName,
                style: GoogleFonts.beVietnamPro(
                  color: Colors.grey[500],
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
