import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart' as intl;

class CurrencyBarChartCard extends StatelessWidget {
  final List<Map<String, dynamic>> currencyData;
  static const int maxBars = 10; // Show only top 10 currencies

  const CurrencyBarChartCard({super.key, required this.currencyData});

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: _CurrencyBarChartCardContent(currencyData: currencyData),
    );
  }
}

class _CurrencyBarChartCardContent extends StatefulWidget {
  final List<Map<String, dynamic>> currencyData;
  const _CurrencyBarChartCardContent({required this.currencyData});

  @override
  State<_CurrencyBarChartCardContent> createState() =>
      _CurrencyBarChartCardContentState();
}

class _CurrencyBarChartCardContentState
    extends State<_CurrencyBarChartCardContent> {
  int? touchedIndex;
  late final List<Map<String, dynamic>> sortedData;
  late final List<Map<String, dynamic>> displayedData;
  late final double maxY;
  late final double yAxisReservedSize;

  @override
  void initState() {
    super.initState();

    // Sort by value descending
    sortedData = List<Map<String, dynamic>>.from(widget.currencyData)..sort(
      (a, b) => ((b['totalinvoicevalue'] ?? 0) as num).compareTo(
        (a['totalinvoicevalue'] ?? 0) as num,
      ),
    );

    // Show only top N bars
    displayedData = sortedData.take(CurrencyBarChartCard.maxBars).toList();

    // Calculate max Y for chart
    maxY =
        displayedData.isNotEmpty
            ? (displayedData
                    .map((e) => (e['totalinvoicevalue'] ?? 0) as num)
                    .reduce((a, b) => a > b ? a : b)
                    .toDouble() *
                1.2)
            : 1;

    // Pre-calculate Y-axis label width
    yAxisReservedSize = _computeYAxisLabelWidth(maxY);
  }

  double _computeYAxisLabelWidth(double maxY) {
    final maxLabelValue = (maxY / 100000).ceil(); // in Lakhs
    final maxLabelString = '$maxLabelValue L';

    final textPainter = TextPainter(
      text: TextSpan(
        text: maxLabelString,
        style: const TextStyle(fontSize: 12),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    return textPainter.width + 12; // add padding
  }

  void _updateTouchedIndex(int? index) {
    if (mounted) {
      setState(() {
        touchedIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.only(bottom: 4, top: 4),
              child: Text(
                'Currency List',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            AspectRatio(
              aspectRatio: 1.5,
              child: _BarChart(
                displayedData: displayedData,
                maxY: maxY,
                yAxisReservedSize: yAxisReservedSize,
                touchedIndex: touchedIndex,
                onTouched: _updateTouchedIndex,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BarChart extends StatelessWidget {
  final List<Map<String, dynamic>> displayedData;
  final double maxY;
  final double yAxisReservedSize;
  final int? touchedIndex;
  final Function(int?) onTouched;

  const _BarChart({
    required this.displayedData,
    required this.maxY,
    required this.yAxisReservedSize,
    required this.touchedIndex,
    required this.onTouched,
  });

  Widget _leftTitlesWidget(double value, TitleMeta meta) {
    if (value == 0) {
      return SideTitleWidget(meta: meta, space: 8, child: const Text('0'));
    } else if (value % 100000 == 0 && value != 0) {
      return SideTitleWidget(
        meta: meta,
        space: 8,
        child: Text(
          (value / 100000).toStringAsFixed(0),
          style: const TextStyle(fontSize: 12),
        ),
      );
    }
    return const SizedBox.shrink();
  }

  Widget _bottomTitlesWidget(double value, TitleMeta meta) {
    final idx = value.toInt();
    if (idx < 0 || idx >= displayedData.length) {
      return const SizedBox.shrink();
    }
    final label = (displayedData[idx]['currencycode'] ?? '').toString();
    final isSelected = touchedIndex == idx;
    return SideTitleWidget(
      meta: meta,
      space: 8,
      child: GestureDetector(
        onTap: () => onTouched(idx),
        child: Text(
          label.trim(),
          style: TextStyle(
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected ? Colors.blueAccent[700] : Colors.black87,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  BarTooltipItem _getTooltipItem(
    BarChartGroupData group,
    int groupIndex,
    BarChartRodData rod,
    int rodIndex,
  ) {
    final currency = displayedData[groupIndex];
    return BarTooltipItem(
      'Currency: ${(currency['currency'] ?? '').toString().trim()}\n'
      'Amount: ${intl.NumberFormat.currency(locale: 'en_IN', symbol: "").format(currency['totalinvoicevalue'] ?? 0)}',
      const TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.bold,
        fontSize: 14,
        shadows: [
          Shadow(color: Colors.black54, blurRadius: 4, offset: Offset(1, 2)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: maxY,
        barTouchData: BarTouchData(
          enabled: true,
          touchTooltipData: BarTouchTooltipData(
            fitInsideHorizontally: true,
            fitInsideVertically: true,
            getTooltipColor: (group) => Colors.black,
            tooltipPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 8,
            ),
            tooltipRoundedRadius: 8,
            tooltipBorder: BorderSide.none,
            getTooltipItem: _getTooltipItem,
          ),
          touchCallback: (event, response) {
            if (event is FlTapUpEvent &&
                response != null &&
                response.spot != null) {
              onTouched(response.spot!.touchedBarGroupIndex);
            } else if (event is FlTapUpEvent) {
              onTouched(null);
            }
          },
        ),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            axisNameSize: 35,
            axisNameWidget: const Text(
              'Amount (in Lakhs)',
              style: TextStyle(fontSize: 12),
            ),
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: yAxisReservedSize,
              getTitlesWidget: _leftTitlesWidget,
            ),
          ),
          bottomTitles: AxisTitles(
            axisNameSize: 35,
            axisNameWidget: const Text(
              'Currency',
              style: TextStyle(fontSize: 12),
            ),
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: _bottomTitlesWidget,
            ),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        borderData: FlBorderData(show: false),
        gridData: FlGridData(show: true, drawVerticalLine: false),
        barGroups: List.generate(displayedData.length, (idx) {
          final amount =
              (displayedData[idx]['totalinvoicevalue'] ?? 0).toDouble();
          final isSelected = touchedIndex == idx;
          return BarChartGroupData(
            x: idx,
            barRods: [
              BarChartRodData(
                toY: amount,
                color: isSelected ? Colors.blueAccent[700] : Colors.blue,
                width: 18,
                borderRadius: BorderRadius.circular(0),
              ),
            ],
            showingTooltipIndicators: isSelected ? [0] : [],
          );
        }),
      ),
    );
  }
}
