import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:travel_app/domain/models/historical_rates_model.dart';

class ExchangeRateChartWidget extends StatelessWidget {
  final String fromCurrency;
  final String toCurrency;
  final HistoricalRatesModel? chartData;
  final bool isChartLoading;
  final String? chartError;

  const ExchangeRateChartWidget({
    super.key,
    required this.fromCurrency,
    required this.toCurrency,
    required this.chartData,
    required this.isChartLoading,
    this.chartError,
  });

  String _formatRate(double rate) {
    if (rate >= 1000) {
      return NumberFormat('#,##0').format(rate);
    } else if (rate >= 1) {
      return rate.toStringAsFixed(2);
    } else {
      return rate.toStringAsFixed(4);
    }
  }

  Widget _buildRateStat(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          label,
          style: GoogleFonts.beVietnamPro(
            color: Colors.grey[500],
            fontSize: 11,
          ),
        ),
        SizedBox(height: 4),
        Text(
          value,
          style: GoogleFonts.beVietnamPro(
            color: color,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Color(0xFF1C1C1D),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Color(0xFFFF6D00), width: 1.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'currency.rate_history'.tr(),
            style: GoogleFonts.beVietnamPro(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 5),
          Text(
            '$fromCurrency → $toCurrency',
            style: GoogleFonts.beVietnamPro(
              color: Colors.grey[500],
              fontSize: 12,
            ),
          ),
          SizedBox(height: 5),
          if (isChartLoading)
            SizedBox(
              height: 120,
              child: Center(
                child: CircularProgressIndicator(
                  color: Color(0xFFFF6D00),
                  strokeWidth: 2,
                ),
              ),
            )
          else if (chartError != null)
            SizedBox(
              height: 120,
              child: Center(
                child: Text(
                  chartError!.tr(),
                  style: GoogleFonts.beVietnamPro(color: Colors.red[400]),
                ),
              ),
            )
          else if (chartData == null || chartData!.rateValues.isEmpty)
            SizedBox(
              height: 120,
              child: Center(
                child: Text(
                  'currency.unsupported_currency'.tr(),
                  style: GoogleFonts.beVietnamPro(color: Colors.grey[500]),
                ),
              ),
            )
          else ...[
            _ChartContent(
              chartData: chartData!,
              toCurrency: toCurrency,
              formatRate: _formatRate,
            ),
            SizedBox(height: 15),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildRateStat(
                  'currency.lowest'.tr(),
                  _formatRate(chartData!.minRate),
                  Colors.red[400]!,
                ),
                _buildRateStat(
                  'currency.average'.tr(),
                  _formatRate(chartData!.avgRate),
                  Colors.grey[400]!,
                ),
                _buildRateStat(
                  'currency.highest'.tr(),
                  _formatRate(chartData!.maxRate),
                  Colors.green[400]!,
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _ChartContent extends StatelessWidget {
  final HistoricalRatesModel chartData;
  final String toCurrency;
  final String Function(double) formatRate;

  const _ChartContent({
    required this.chartData,
    required this.toCurrency,
    required this.formatRate,
  });

  @override
  Widget build(BuildContext context) {
    final spots = chartData.rateValues
        .asMap()
        .entries
        .map((e) => FlSpot(e.key.toDouble(), e.value))
        .toList();
    final minR = chartData.minRate;
    final maxR = chartData.maxRate;
    final interval = (maxR - minR) <= 0 ? 1.0 : (maxR - minR) / 3;

    return SizedBox(
      height: 120,
      child: LineChart(
        LineChartData(
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: interval,
            getDrawingHorizontalLine: (value) =>
                FlLine(color: Colors.grey[800]!, strokeWidth: 0.5),
          ),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 30,
                interval: 1,
                getTitlesWidget: (value, meta) {
                  final index = value.toInt();
                  if (index >= 0 && index < chartData.dayLabels.length) {
                    return Padding(
                      padding: EdgeInsets.only(top: 8),
                      child: Text(
                        chartData.dayLabels[index],
                        style: GoogleFonts.beVietnamPro(
                          color: Colors.grey[500],
                          fontSize: 10,
                        ),
                      ),
                    );
                  }
                  return Container();
                },
              ),
            ),
          ),
          borderData: FlBorderData(show: false),
          minX: 0,
          maxX: (spots.length - 1).toDouble(),
          minY: minR * 0.998,
          maxY: maxR * 1.002,
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              curveSmoothness: 0.3,
              color: Color(0xFFFF6D00),
              barWidth: 3,
              isStrokeCapRound: true,
              dotData: FlDotData(
                show: true,
                getDotPainter: (spot, percent, barData, index) {
                  return FlDotCirclePainter(
                    radius: 4,
                    color: Color(0xFFFF6D00),
                    strokeWidth: 2,
                    strokeColor: Colors.white,
                  );
                },
              ),
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFFFF6D00).withValues(alpha: 0.3),
                    Color(0xFFFF6D00).withValues(alpha: 0.0),
                  ],
                ),
              ),
            ),
          ],
          lineTouchData: LineTouchData(
            touchTooltipData: LineTouchTooltipData(
              getTooltipColor: (touchedSpot) => Color(0xFF2C2C2D),
              tooltipRoundedRadius: 10,
              getTooltipItems: (touchedSpots) {
                return touchedSpots.map((spot) {
                  return LineTooltipItem(
                    '${formatRate(spot.y)} $toCurrency',
                    GoogleFonts.beVietnamPro(
                      color: Color(0xFFFF6D00),
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  );
                }).toList();
              },
            ),
          ),
        ),
      ),
    );
  }
}
