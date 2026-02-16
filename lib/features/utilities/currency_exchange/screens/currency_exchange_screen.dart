import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:provider/provider.dart';
import 'package:travel_app/features/utilities/currency_exchange/widgets/exchange_board_widget.dart';
import 'package:travel_app/features/utilities/currency_exchange/widgets/exchange_rate_chart_widget.dart';
import 'package:travel_app/features/utilities/currency_exchange/viewmodels/currency_exchange_view_model.dart';
import 'package:travel_app/features/utilities/currency_exchange/widgets/currency_picker_bottom_sheet.dart';
import 'package:travel_app/shared/widgets/app_bar_widget.dart';

class CurrencyExchangeScreen extends StatefulWidget {
  const CurrencyExchangeScreen({super.key});

  @override
  State<CurrencyExchangeScreen> createState() => _CurrencyExchangeScreenState();
}

class _CurrencyExchangeScreenState extends State<CurrencyExchangeScreen> {
  final _amountController = TextEditingController(text: '10');
  late VoidCallback _amountListener;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<CurrencyExchangeViewModel>().loadCurrencies(
          defaultAmount: _amountController.text,
        );
      }
    });
    _amountListener = () {
      if (mounted) {
        context.read<CurrencyExchangeViewModel>().calculateConversion(
          _amountController.text,
        );
      }
    };
    _amountController.addListener(_amountListener);
  }

  @override
  void dispose() {
    _amountController.removeListener(_amountListener);
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<CurrencyExchangeViewModel>();

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBarWidget(title: 'currency.title'.tr()),
      body: viewModel.isLoading
          ? Center(child: CircularProgressIndicator(color: Color(0xFFFFAD35)))
          : SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Column(
                  children: [
                    // From board
                    ExchangeBoardWidget(
                      showText: true,
                      showIcon: true,
                      label: 'currency.from'.tr(),
                      amount: _amountController.text,
                      currencyCode: viewModel.fromCurrency['code'] ?? '',
                      currencyName: viewModel.fromCurrency['name'] ?? '',
                      flag: viewModel.fromCurrency['flag'] ?? '',
                      isEditable: true,
                      controller: _amountController,
                      onCurrencyTap: () => showModalBottomSheet(
                        context: context,
                        backgroundColor: Color(0xFF1C1C1D),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(20),
                          ),
                        ),
                        builder: (_) => CurrencyPickerBottomSheet(isFrom: true),
                      ),
                    ), // Currency From Board

                    SizedBox(height: 10),

                    // Swap button
                    GestureDetector(
                      onTap: () => viewModel.swapCurrencies(),
                      child: Container(
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Color(0xFFFFAD35),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          CupertinoIcons.arrow_up_arrow_down,
                          color: Colors.black,
                          size: 24,
                        ),
                      ),
                    ),

                    SizedBox(height: 10),

                    // To board
                    ExchangeBoardWidget(
                      label: 'currency.to'.tr(),
                      amount: viewModel.formatNumber(viewModel.convertedAmount),
                      currencyCode: viewModel.toCurrency['code'] ?? '',
                      currencyName: viewModel.toCurrency['name'] ?? '',
                      flag: viewModel.toCurrency['flag'] ?? '',
                      isEditable: false,
                      onCurrencyTap: () => showModalBottomSheet(
                        context: context,
                        backgroundColor: Color(0xFF1C1C1D),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(20),
                          ),
                        ), // Currency To Board
                        builder: (_) =>
                            CurrencyPickerBottomSheet(isFrom: false),
                      ),
                    ),

                    SizedBox(height: 20),

                    // 7-Day Chart
                    ExchangeRateChartWidget(
                      fromCurrency: viewModel.fromCurrency['code'] ?? 'USD',
                      toCurrency: viewModel.toCurrency['code'] ?? 'VND',
                      chartData: viewModel.chartData,
                      isChartLoading: viewModel.isChartLoading,
                      chartError: viewModel.chartError,
                    ),
                    SizedBox(height: 15),

                    // Exchange rate info
                    Text(
                      '${'currency.rate'.tr()}: 1 ${viewModel.fromCurrency['code']} = ${viewModel.formatNumber((viewModel.rates[viewModel.toCurrency['code']] ?? 0).toDouble())} ${viewModel.toCurrency['code']}',
                      style: GoogleFonts.beVietnamPro(
                        color: Colors.grey[400],
                        fontSize: 14,
                      ),
                    ),

                    SizedBox(height: 30),
                  ],
                ),
              ),
            ),
    );
  }
}
