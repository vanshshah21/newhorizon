// import 'package:fl_chart/fl_chart.dart';
// import 'package:flutter/material.dart';

// class CustomerReceivableOverdueChart extends StatelessWidget {
//   final List<Map<String, dynamic>> chartData;
//   const CustomerReceivableOverdueChart({super.key, required this.chartData});

//   @override
//   Widget build(BuildContext context) {
//     return _CustomerReceivableOverdueChartContent(chartData: chartData);
//   }
// }

// class _CustomerReceivableOverdueChartContent extends StatefulWidget {
//   const _CustomerReceivableOverdueChartContent({required this.chartData});
//   final List<Map<String, dynamic>> chartData;

//   @override
//   State<_CustomerReceivableOverdueChartContent> createState() =>
//       _CustomerReceivableOverdueChartContentState();
// }

// class _CustomerReceivableOverdueChartContentState
//     extends State<_CustomerReceivableOverdueChartContent> {
//   int? touchedIndex;

//   late final double maxY;
//   late final double yAxisReservedSize;

//   @override
//   void initState() {
//     super.initState();

//     // Calculate max Y for chart
//     maxY =
//         widget.chartData
//             .map((e) => e['amount'] as double)
//             .reduce((a, b) => a > b ? a : b) *
//         1.2;

//     // Pre-calculate Y-axis label width
//     yAxisReservedSize = _computeYAxisLabelWidth(maxY);
//   }

//   double _computeYAxisLabelWidth(double maxY) {
//     final maxLabelValue = (maxY / 100000).ceil(); // in Crores
//     final maxLabelString = '$maxLabelValue';

//     final textPainter = TextPainter(
//       text: TextSpan(
//         text: maxLabelString,
//         style: const TextStyle(fontSize: 12),
//       ),
//       textDirection: TextDirection.ltr,
//     )..layout();

//     return textPainter.width + 12; // add padding
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
//       elevation: 4,
//       child: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // const _ChartTitle(),
//             const SizedBox(height: 16),
//             SizedBox(
//               height: 340,
//               child: _BarChart(
//                 data: widget.chartData,
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
//   final List<Map<String, dynamic>> data;
//   final double maxY;
//   final double yAxisReservedSize;
//   final int? touchedIndex;
//   final Function(int?) onTouched;

//   const _BarChart({
//     required this.data,
//     required this.maxY,
//     required this.yAxisReservedSize,
//     required this.touchedIndex,
//     required this.onTouched,
//   });

//   Widget _leftTitlesWidget(double value, TitleMeta meta) {
//     if (value == 0) {
//       return const Text('0');
//     }
//     if (value % 1000000 == 0 && value != 0) {
//       return Text(
//         '${(value / 100000).toStringAsFixed(0)} L',
//         style: const TextStyle(fontSize: 12),
//       );
//     }
//     return const SizedBox.shrink();
//   }

//   Widget _bottomTitlesWidget(double value, TitleMeta meta) {
//     final idx = value.toInt();
//     if (idx < 0 || idx >= data.length) {
//       return const SizedBox.shrink();
//     }
//     final label = data[idx]['monthprefix'] as String;
//     final isSelected = touchedIndex == idx;
//     return GestureDetector(
//       onTap: () => onTouched(idx),
//       child: Padding(
//         padding: const EdgeInsets.only(top: 8.0),
//         child: Text(
//           label.trim(),
//           style: TextStyle(
//             fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
//             color: isSelected ? Colors.blueAccent[700] : Colors.black87,
//             fontSize: 12,
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
//     final item = data[groupIndex];
//     return BarTooltipItem(
//       'Month: ${item['monthprefix']}\nAmount: ${(item['amount'] as double).toStringAsFixed(2)}',
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
//         barGroups: List.generate(data.length, (idx) {
//           final amount = data[idx]['amount'] as double;
//           final isSelected = touchedIndex == idx;
//           return BarChartGroupData(
//             x: idx,
//             barRods: [
//               BarChartRodData(
//                 toY: amount,
//                 color: isSelected ? Colors.blueAccent[700] : Colors.blue,
//                 width: 22,
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

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart' as intl;

class CustomerReceivableOverdueChart extends StatelessWidget {
  final List<Map<String, dynamic>> chartData;
  const CustomerReceivableOverdueChart({super.key, required this.chartData});

  @override
  Widget build(BuildContext context) {
    return _CustomerReceivableOverdueChartContent(chartData: chartData);
  }
}

class _CustomerReceivableOverdueChartContent extends StatefulWidget {
  const _CustomerReceivableOverdueChartContent({required this.chartData});
  final List<Map<String, dynamic>> chartData;

  @override
  State<_CustomerReceivableOverdueChartContent> createState() =>
      _CustomerReceivableOverdueChartContentState();
}

class _CustomerReceivableOverdueChartContentState
    extends State<_CustomerReceivableOverdueChartContent> {
  int? touchedIndex;
  late final double maxY;
  late final double yAxisReservedSize;

  @override
  void initState() {
    super.initState();

    // Calculate max Y for chart, handle empty data
    if (widget.chartData.isNotEmpty) {
      maxY =
          widget.chartData
              .map((e) => (e['amount'] ?? 0) as num)
              .reduce((a, b) => a > b ? a : b)
              .toDouble() *
          1.2;
    } else {
      maxY = 1;
    }

    // Pre-calculate Y-axis label width
    yAxisReservedSize = _computeYAxisLabelWidth(maxY);
  }

  double _computeYAxisLabelWidth(double maxY) {
    // Show in Crores for large numbers
    final maxLabelValue = (maxY / 100000).ceil(); // in Crores
    final maxLabelString = '$maxLabelValue';

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
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Customer Receivable Overdue',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 16),
            AspectRatio(
              aspectRatio: 0.9,
              child: _BarChart(
                data: widget.chartData,
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
  final List<Map<String, dynamic>> data;
  final double maxY;
  final double yAxisReservedSize;
  final int? touchedIndex;
  final Function(int?) onTouched;

  const _BarChart({
    required this.data,
    required this.maxY,
    required this.yAxisReservedSize,
    required this.touchedIndex,
    required this.onTouched,
  });

  // Show Y-axis in Lakhs
  Widget _leftTitlesWidget(double value, TitleMeta meta) {
    if (value == 0) {
      return const Text('0');
    }
    if (value % 100000 == 0 && value != 0) {
      return SideTitleWidget(
        meta: meta,
        child: Text(
          (value / 100000).toStringAsFixed(0),
          style: const TextStyle(fontSize: 12),
        ),
      );
    }
    return const SizedBox.shrink();
  }

  // Show customer name on X-axis
  Widget _bottomTitlesWidget(double value, TitleMeta meta) {
    final idx = value.toInt();
    if (idx < 0 || idx >= data.length) {
      return const SizedBox.shrink();
    }
    final label = (data[idx]['customercode'] ?? '').toString().trim();
    final isSelected = touchedIndex == idx;

    // Truncate to 5 characters and add ellipsis if needed
    final displayLabel =
        label.length > 5 ? '${label.substring(0, 5)}...' : label;

    return GestureDetector(
      onTap: () => onTouched(idx),
      child: Padding(
        padding: const EdgeInsets.only(top: 8.0),
        child: Transform.rotate(
          angle: -0.95,
          child: Text(
            displayLabel,
            style: TextStyle(
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected ? Colors.blueAccent[700] : Colors.black87,
              fontSize: 12,
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
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
    final item = data[groupIndex];
    return BarTooltipItem(
      'Customer Code: ${item['customercode']}\n'
      'Customer: ${(item['customername'] ?? '').toString()}\n'
      'Amount: ${intl.NumberFormat.currency(locale: 'en_IN', symbol: "").format(item['amount'] ?? 0)}',
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
            drawBelowEverything: true,
            axisNameSize: 25,
            axisNameWidget: Text(
              data.isNotEmpty ? 'Amount (in Lakhs)' : 'No Data Available',
            ),
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: yAxisReservedSize,
              getTitlesWidget: _leftTitlesWidget,
            ),
          ),
          bottomTitles: AxisTitles(
            axisNameSize: 60,
            axisNameWidget: const Text('Customer Name'),
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
        barGroups: List.generate(data.length, (idx) {
          final amount = (data[idx]['amount'] ?? 0).toDouble();
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
