// Dữ liệu biểu đồ tỷ giá 7 ngày (không phụ thuộc fl_chart).
class HistoricalRatesModel {
  final List<String> dayLabels;
  final List<double> rateValues;

  HistoricalRatesModel({required this.dayLabels, required this.rateValues});

  double get minRate =>
      rateValues.isEmpty ? 0 : rateValues.reduce((a, b) => a < b ? a : b);
  double get maxRate =>
      rateValues.isEmpty ? 0 : rateValues.reduce((a, b) => a > b ? a : b);
  double get avgRate => rateValues.isEmpty
      ? 0
      : rateValues.reduce((a, b) => a + b) / rateValues.length;
}
