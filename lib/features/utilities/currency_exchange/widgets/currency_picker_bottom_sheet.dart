import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:provider/provider.dart';
import '../viewmodels/currency_exchange_view_model.dart';

class CurrencyPickerBottomSheet extends StatelessWidget {
  final bool isFrom;

  const CurrencyPickerBottomSheet({super.key, required this.isFrom});

  @override
  Widget build(BuildContext context) {
    return Consumer<CurrencyExchangeViewModel>(
      builder: (context, vm, child) {
        return Container(
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                isFrom
                    ? 'currency.select_from'.tr()
                    : 'currency.select_to'.tr(),
                style: GoogleFonts.beVietnamPro(
                  color: Colors.white,
                  fontSize: 18,
                ),
              ),
              SizedBox(height: 15),
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: vm.currencies.length,
                  itemBuilder: (context, index) {
                    final currency = vm.currencies[index];
                    final isSelected = isFrom
                        ? currency['code'] == vm.fromCurrency['code']
                        : currency['code'] == vm.toCurrency['code'];
                    return ListTile(
                      leading: Text(
                        currency['flag']!,
                        style: TextStyle(fontSize: 24),
                      ),
                      title: Text(
                        '${currency['code']} - ${currency['name']}',
                        style: GoogleFonts.beVietnamPro(
                          color: isSelected ? Color(0xFFFFAD35) : Colors.white,
                        ),
                      ),
                      trailing: isSelected
                          ? Icon(CupertinoIcons.checkmark_circle, color: Color(0xFFFFAD35))
                          : null,
                      onTap: () {
                        vm.selectCurrency(currency, isFrom);
                        Navigator.pop(context);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
