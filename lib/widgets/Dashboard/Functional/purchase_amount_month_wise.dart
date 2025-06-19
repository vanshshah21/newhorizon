// import 'package:fl_chart/fl_chart.dart';
// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';

// class PurchaseAmountBarChartCard extends StatelessWidget {
//   final List<Map<String, dynamic>> purchaseAmountData;

//   const PurchaseAmountBarChartCard({
//     super.key,
//     required this.purchaseAmountData,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return RepaintBoundary(
//       child: _PurchaseAmountBarChartCardContent(
//         purchaseAmountData: purchaseAmountData,
//       ),
//     );
//   }
// }

// class _PurchaseAmountBarChartCardContent extends StatefulWidget {
//   final List<Map<String, dynamic>> purchaseAmountData;
//   const _PurchaseAmountBarChartCardContent({required this.purchaseAmountData});

//   @override
//   State<_PurchaseAmountBarChartCardContent> createState() =>
//       _PurchaseAmountBarChartCardContentState();
// }

// class _PurchaseAmountBarChartCardContentState
//     extends State<_PurchaseAmountBarChartCardContent> {
//   int? touchedIndex;
//   late final List<Map<String, dynamic>> displayedData;
//   late final double maxY;
//   late final double yAxisReservedSize;

//   @override
//   void initState() {
//     super.initState();

//     // Do NOT sort, just use as is
//     displayedData = List<Map<String, dynamic>>.from(widget.purchaseAmountData);

//     // Calculate max Y for chart
//     maxY =
//         displayedData.isNotEmpty
//             ? (displayedData
//                     .map((e) => (e['amount'] ?? 0) as num)
//                     .reduce((a, b) => a > b ? a : b)
//                     .toDouble() *
//                 1.2)
//             : 1;

//     // Pre-calculate Y-axis label width
//     yAxisReservedSize = _computeYAxisLabelWidth(maxY);
//   }

//   double _computeYAxisLabelWidth(double maxY) {
//     final maxLabelValue = (maxY / 100000).ceil(); // in Lakhs
//     final maxLabelString = maxLabelValue.toString();

//     final textPainter = TextPainter(
//       text: TextSpan(
//         text: maxLabelString,
//         style: const TextStyle(fontSize: 12),
//       ),
//       textDirection: TextDirection.LTR,
//     )..layout();

//     return textPainter.width + 12;
//   }

//   void _updateTouchedIndex(int? index) {
//     if (mounted) {
//       setState(() {
//         touchedIndex = index;
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Card(
//       elevation: 2,
//       child: Padding(
//         padding: const EdgeInsets.all(12),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Padding(
//               padding: const EdgeInsets.only(bottom: 8.0),
//               child: Text(
//                 'Purchase Amount (Month Wise)',
//                 style: Theme.of(context).textTheme.titleMedium,
//               ),
//             ),
//             AspectRatio(
//               aspectRatio: 1.5,
//               child: _BarChart(
//                 displayedData: displayedData,
//                 maxY: maxY,
//                 yAxisReservedSize: yAxisReservedSize,
//                 touchedIndex: touchedIndex,
//                 onTouched: _updateTouchedIndex,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// class _BarChart extends StatelessWidget {
//   final List<Map<String, dynamic>> displayedData;
//   final double maxY;
//   final double yAxisReservedSize;
//   final int? touchedIndex;
//   final Function(int?) onTouched;

//   const _BarChart({
//     required this.displayedData,
//     required this.maxY,
//     required this.yAxisReservedSize,
//     required this.touchedIndex,
//     required this.onTouched,
//   });

//   Widget _leftTitlesWidget(double value, TitleMeta meta) {
//     if (value == 0) {
//       return const Text('0');
//     } else if (value % 100000 == 0 && value != 0) {
//       return Text(
//         (value / 100000).toStringAsFixed(0),
//         style: const TextStyle(fontSize: 12),
//       );
//     }
//     return const SizedBox.shrink();
//   }

//   Widget _bottomTitlesWidget(double value, TitleMeta meta) {
//     final idx = value.toInt();
//     if (idx < 0 || idx >= displayedData.length) {
//       return const SizedBox.shrink();
//     }
//     final label = (displayedData[idx]['monthPrefix'] ?? '').toString();
//     final isSelected = touchedIndex == idx;
//     return GestureDetector(
//       onTap: () => onTouched(idx),
//       child: Padding(
//         padding: const EdgeInsets.only(top: 8.0),
//         child: Transform.rotate(
//           angle: -0.75,
//           child: Text(
//             label.trim(),
//             style: TextStyle(
//               fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
//               color: isSelected ? Colors.blueAccent[700] : Colors.black87,
//               fontSize: 12,
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   BarTooltipItem _getTooltipItem(
//     BarChartGroupData group,
//     int groupIndex,
//     BarChartRodData rod,
//     int rodIndex,
//   ) {
//     final month = displayedData[groupIndex];
//     return BarTooltipItem(
//       'Month: ${(month['monthPrefix'] ?? '').toString().trim()}\n'
//       'Amount: ${NumberFormat.currency(locale: 'en_IN', symbol: '', decimalDigits: 2).format(month['amount'] ?? 0)}',
//       const TextStyle(
//         color: Colors.white,
//         fontWeight: FontWeight.bold,
//         fontSize: 14,
//         shadows: [
//           Shadow(color: Colors.black54, blurRadius: 4, offset: Offset(1, 2)),
//         ],
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return BarChart(
//       BarChartData(
//         alignment: BarChartAlignment.spaceAround,
//         maxY: maxY,
//         barTouchData: BarTouchData(
//           enabled: true,
//           touchTooltipData: BarTouchTooltipData(
//             fitInsideHorizontally: true,
//             fitInsideVertically: true,
//             getTooltipColor: (group) => Colors.black,
//             tooltipPadding: const EdgeInsets.symmetric(
//               horizontal: 12,
//               vertical: 8,
//             ),
//             tooltipRoundedRadius: 8,
//             tooltipBorder: BorderSide.none,
//             getTooltipItem: _getTooltipItem,
//           ),
//           touchCallback: (event, response) {
//             if (event is FlTapUpEvent &&
//                 response != null &&
//                 response.spot != null) {
//               onTouched(response.spot!.touchedBarGroupIndex);
//             } else if (event is FlTapUpEvent) {
//               onTouched(null);
//             }
//           },
//         ),
//         titlesData: FlTitlesData(
//           leftTitles: AxisTitles(
//             axisNameWidget: Padding(
//               padding: const EdgeInsets.all(2.0),
//               child: const Text(
//                 'Amount (in Lakhs)',
//                 style: TextStyle(fontSize: 12),
//               ),
//             ),
//             sideTitles: SideTitles(
//               showTitles: true,
//               reservedSize: yAxisReservedSize,
//               getTitlesWidget: _leftTitlesWidget,
//             ),
//           ),
//           bottomTitles: AxisTitles(
//             sideTitles: SideTitles(
//               showTitles: true,
//               getTitlesWidget: _bottomTitlesWidget,
//             ),
//           ),
//           rightTitles: const AxisTitles(
//             sideTitles: SideTitles(showTitles: false),
//           ),
//           topTitles: const AxisTitles(
//             sideTitles: SideTitles(showTitles: false),
//           ),
//         ),
//         borderData: FlBorderData(show: false),
//         gridData: FlGridData(show: true, drawVerticalLine: false),
//         barGroups: List.generate(displayedData.length, (idx) {
//           final amount = (displayedData[idx]['amount'] ?? 0).toDouble();
//           final isSelected = touchedIndex == idx;
//           return BarChartGroupData(
//             x: idx,
//             barRods: [
//               BarChartRodData(
//                 toY: amount,
//                 color: isSelected ? Colors.blueAccent[700] : Colors.blue,
//                 width: 18,
//                 borderRadius: BorderRadius.circular(0),
//               ),
//             ],
//             showingTooltipIndicators: isSelected ? [0] : [],
//           );
//         }),
//       ),
//     );
//   }
// }

import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart' as intl;

class PurchaseAmountBarChartCard extends StatelessWidget {
  final List<Map<String, dynamic>> purchaseAmountData;

  const PurchaseAmountBarChartCard({
    super.key,
    required this.purchaseAmountData,
  });

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: _PurchaseAmountBarChartCardContent(
        purchaseAmountData: purchaseAmountData,
      ),
    );
  }
}

class _PurchaseAmountBarChartCardContent extends StatefulWidget {
  final List<Map<String, dynamic>> purchaseAmountData;
  const _PurchaseAmountBarChartCardContent({required this.purchaseAmountData});

  @override
  State<_PurchaseAmountBarChartCardContent> createState() =>
      _PurchaseAmountBarChartCardContentState();
}

class _PurchaseAmountBarChartCardContentState
    extends State<_PurchaseAmountBarChartCardContent> {
  int? touchedIndex;
  List<Map<String, dynamic>> displayedData = [];
  double maxY = 1;
  double yAxisReservedSize = 32;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _initializeChartData();
  }

  void _initializeChartData() {
    // Use as is, do not sort
    displayedData = List<Map<String, dynamic>>.from(widget.purchaseAmountData);

    // Calculate max Y for chart
    maxY =
        displayedData.isNotEmpty
            ? (displayedData
                    .map((e) => (e['amount'] ?? 0) as num)
                    .reduce((a, b) => a > b ? a : b)
                    .toDouble() *
                1.2)
            : 1;

    // Pre-calculate Y-axis label width
    yAxisReservedSize = _computeYAxisLabelWidth(maxY);

    // Call setState to update the UI if needed
    if (mounted) setState(() {});
  }

  double _computeYAxisLabelWidth(double maxY) {
    final maxLabelValue = (maxY / 100000).ceil(); // in Lakhs
    final maxLabelString = maxLabelValue.toString();

    final textPainter = TextPainter(
      text: TextSpan(
        text: maxLabelString,
        style: const TextStyle(fontSize: 12),
      ),
      // textDirection: TextDirection.ltr,
      textDirection: TextDirection.ltr,
    )..layout();

    return textPainter.width + 12;
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
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Text(
                'Purchase Amount (Month Wise)',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            AspectRatio(
              aspectRatio: 1.3,
              child: _BarChart(
                displayedData: displayedData,
                maxY: maxY,
                yAxisReservedSize: yAxisReservedSize,
                touchedIndex: touchedIndex,
                onTouched: _updateTouchedIndex,
              ),
            ),
            const SizedBox(height: 8),
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
      return SideTitleWidget(
        meta: meta,
        space: 4,
        child: Text('0', style: const TextStyle(fontSize: 12)),
      );
    } else if (value % 100000 == 0 && value != 0) {
      return SideTitleWidget(
        meta: meta,
        space: 4,
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
    final label = (displayedData[idx]['monthPrefix'] ?? '').toString();
    final isSelected = touchedIndex == idx;
    return SideTitleWidget(
      meta: meta,
      space: 8,
      child: GestureDetector(
        onTap: () => onTouched(idx),
        child: Transform.rotate(
          angle: -(math.pi / 3),
          child: Text(
            label.trim(),
            style: TextStyle(
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected ? Colors.blueAccent[700] : Colors.black87,
              fontSize: 12,
            ),
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
    final month = displayedData[groupIndex];
    return BarTooltipItem(
      'Month: ${(month['monthPrefix'] ?? '').toString().trim()}\n'
      'Amount: ${intl.NumberFormat.currency(locale: 'en_IN', symbol: '').format(month['amount'] ?? 0)}',
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
          final amount = (displayedData[idx]['amount'] ?? 0).toDouble();
          final isSelected = touchedIndex == idx;
          return BarChartGroupData(
            x: idx,
            barRods: [
              BarChartRodData(
                toY: amount,
                color: isSelected ? Colors.blueAccent[700] : Colors.blue,
                width: 12,
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
