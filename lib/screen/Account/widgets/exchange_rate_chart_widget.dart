import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:easy_localization/easy_localization.dart';

class ExchangeRateChartWidget extends StatefulWidget {
  final String fromCurrency;
  final String toCurrency;

  const ExchangeRateChartWidget({
    super.key,
    required this.fromCurrency,
    required this.toCurrency,
  });

  @override
  State<ExchangeRateChartWidget> createState() =>
      _ExchangeRateChartWidgetState();
}

class _ExchangeRateChartWidgetState extends State<ExchangeRateChartWidget> {
  List<FlSpot> _chartData = [];
  List<String> _dayLabels = [];
  double _minRate = 0;
  double _maxRate = 0;
  double _avgRate = 0;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchHistoricalRates();
  }

  @override
  void didUpdateWidget(covariant ExchangeRateChartWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Refetch when currencies change
    if (oldWidget.fromCurrency != widget.fromCurrency ||
        oldWidget.toCurrency != widget.toCurrency) {
      _fetchHistoricalRates();
    }
  }

  Future<void> _fetchHistoricalRates() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Calculate date range (7 days)
      final endDate = DateTime.now();
      final startDate = endDate.subtract(Duration(days: 6));

      final startStr = DateFormat('yyyy-MM-dd').format(startDate);
      final endStr = DateFormat('yyyy-MM-dd').format(endDate);

      final url =
          'https://api.frankfurter.app/$startStr..$endStr?from=${widget.fromCurrency}&to=${widget.toCurrency}';

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final rates = data['rates'] as Map<String, dynamic>;

        // Convert to chart data
        final List<FlSpot> spots = [];
        final List<String> labels = [];
        final List<double> rateValues = [];

        int index = 0;
        // Sort dates to ensure correct order
        final sortedDates = rates.keys.toList()..sort();

        for (final dateStr in sortedDates) {
          final rateData = rates[dateStr] as Map<String, dynamic>;
          final rate = (rateData[widget.toCurrency] as num).toDouble();

          spots.add(FlSpot(index.toDouble(), rate));
          rateValues.add(rate);

          // Format day label
          final date = DateTime.parse(dateStr);
          labels.add(DateFormat('E').format(date)); // Mon, Tue, etc.

          index++;
        }

        // Calculate min/max/avg
        final minVal = rateValues.reduce((a, b) => a < b ? a : b);
        final maxVal = rateValues.reduce((a, b) => a > b ? a : b);
        final avgVal = rateValues.reduce((a, b) => a + b) / rateValues.length;

        setState(() {
          _chartData = spots;
          _dayLabels = labels;
          _minRate = minVal;
          _maxRate = maxVal;
          _avgRate = avgVal;
          _isLoading = false;
        });
      } else {
        throw Exception('Failed to load rates');
      }
    } catch (e) {
      setState(() {
        _error = 'currency.unsupported_currency'.tr();
        _isLoading = false;
      });
    }
  }

  String _formatRate(double rate) {
    if (rate >= 1000) {
      return NumberFormat('#,##0').format(rate);
    } else if (rate >= 1) {
      return rate.toStringAsFixed(2);
    } else {
      return rate.toStringAsFixed(4);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Color(0xFF1C1C1D),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Color(0xFFFFAD35), width: 1.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
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
            '${widget.fromCurrency} → ${widget.toCurrency}',
            style: GoogleFonts.beVietnamPro(
              color: Colors.grey[500],
              fontSize: 12,
            ),
          ),
          SizedBox(height: 5),

          // Content
          if (_isLoading)
            SizedBox(
              height: 120,
              child: Center(
                child: CircularProgressIndicator(
                  color: Color(0xFFFFAD35),
                  strokeWidth: 2,
                ),
              ),
            )
          else if (_error != null)
            SizedBox(
              height: 120,
              child: Center(
                child: Text(
                  _error!,
                  style: GoogleFonts.beVietnamPro(color: Colors.red[400]),
                ),
              ),
            )
          else ...[
            // Chart
            SizedBox(
              height: 120,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: (_maxRate - _minRate) / 3,
                    getDrawingHorizontalLine: (value) =>
                        FlLine(color: Colors.grey[800]!, strokeWidth: 0.5),
                  ),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                        interval: 1,
                        getTitlesWidget: (value, meta) {
                          final index = value.toInt();
                          if (index >= 0 && index < _dayLabels.length) {
                            return Padding(
                              padding: EdgeInsets.only(top: 8),
                              child: Text(
                                _dayLabels[index],
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
                  maxX: (_chartData.length - 1).toDouble(),
                  minY: _minRate * 0.998,
                  maxY: _maxRate * 1.002,
                  lineBarsData: [
                    LineChartBarData(
                      spots: _chartData,
                      isCurved: true,
                      curveSmoothness: 0.3,
                      color: Color(0xFFFFAD35),
                      barWidth: 3,
                      isStrokeCapRound: true,
                      dotData: FlDotData(
                        show: true,
                        getDotPainter: (spot, percent, barData, index) {
                          return FlDotCirclePainter(
                            radius: 4,
                            color: Color(0xFFFFAD35),
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
                            Color(0xFFFFAD35).withValues(alpha: 0.3),
                            Color(0xFFFFAD35).withValues(alpha: 0.0),
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
                            '${_formatRate(spot.y)} ${widget.toCurrency}',
                            GoogleFonts.beVietnamPro(
                              color: Color(0xFFFFAD35),
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
            ),

            SizedBox(height: 15),

            // Rate summary
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildRateStat(
                  'currency.lowest'.tr(),
                  _formatRate(_minRate),
                  Colors.red[400]!,
                ),
                _buildRateStat(
                  'currency.average'.tr(),
                  _formatRate(_avgRate),
                  Colors.grey[400]!,
                ),
                _buildRateStat(
                  'currency.highest'.tr(),
                  _formatRate(_maxRate),
                  Colors.green[400]!,
                ),
              ],
            ),
          ],
        ],
      ),
    );
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
}
