// import 'dart:math' as math;

// import 'package:fl_chart/fl_chart.dart';
// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart' as intl;

// class BestSellingBySalesAmountChart extends StatelessWidget {
//   final List<Map<String, dynamic>> chartData;
//   const BestSellingBySalesAmountChart({super.key, required this.chartData});

//   @override
//   Widget build(BuildContext context) {
//     return _BestSellingBySalesAmountChartContent(chartData: chartData);
//   }
// }

// class _BestSellingBySalesAmountChartContent extends StatefulWidget {
//   const _BestSellingBySalesAmountChartContent({required this.chartData});
//   final List<Map<String, dynamic>> chartData;

//   @override
//   State<_BestSellingBySalesAmountChartContent> createState() =>
//       _BestSellingBySalesAmountChartContentState();
// }

// class _BestSellingBySalesAmountChartContentState
//     extends State<_BestSellingBySalesAmountChartContent> {
//   int? touchedIndex;

//   late final List<Map<String, dynamic>> sortedData;
//   late final double maxY;
//   late final double yAxisReservedSize;

//   @override
//   void initState() {
//     super.initState();

//     // Sort item data by amount descending
//     sortedData = List<Map<String, dynamic>>.from(
//       widget.chartData,
//     )..sort((a, b) => (b['amount'] as double).compareTo(a['amount'] as double));

//     // Calculate max Y for chart
//     maxY =
//         sortedData
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
//       child: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // const _ChartTitle(),
//             const SizedBox(height: 16),
//             AspectRatio(
//               aspectRatio: 1.0,
//               child: _BarChart(
//                 sortedData: sortedData,
//                 maxY: maxY,
//                 yAxisReservedSize: yAxisReservedSize,
//                 touchedIndex: touchedIndex,
//                 onTouched: _updateTouchedIndex,
//               ),
//             ),
//             SizedBox(height: 8),
//           ],
//         ),
//       ),
//     );
//   }
// }

// class _BarChart extends StatelessWidget {
//   final List<Map<String, dynamic>> sortedData;
//   final double maxY;
//   final double yAxisReservedSize;
//   final int? touchedIndex;
//   final Function(int?) onTouched;

//   const _BarChart({
//     required this.sortedData,
//     required this.maxY,
//     required this.yAxisReservedSize,
//     required this.touchedIndex,
//     required this.onTouched,
//   });

//   Widget _leftTitlesWidget(double value, TitleMeta meta) {
//     if (value == 0) {
//       return SideTitleWidget(meta: meta, space: 8, child: const Text('0'));
//     }
//     if (value % 100000 == 0) {
//       return SideTitleWidget(
//         meta: meta,
//         space: 8,
//         child: Text(
//           (value / 100000).toStringAsFixed(0),
//           style: const TextStyle(fontSize: 12),
//         ),
//       );
//     }
//     return SideTitleWidget(
//       meta: meta,
//       space: 8,
//       child: const SizedBox.shrink(),
//     );
//   }

//   Widget _bottomTitlesWidget(double value, TitleMeta meta) {
//     final idx = value.toInt();
//     if (idx < 0 || idx >= sortedData.length) {
//       return const SizedBox.shrink();
//     }
//     final label = sortedData[idx]['itemcode'] as String;
//     final isSelected = touchedIndex == idx;

//     final displayLabel =
//         label.length > 4 ? '${label.substring(0, 4)}...' : label;

//     return SideTitleWidget(
//       meta: meta,
//       space: 8,
//       child: GestureDetector(
//         onTap: () => onTouched(idx),
//         child: Transform.rotate(
//           angle: -(math.pi / 3),
//           child: Text(
//             displayLabel.trim(),
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
//     final item = sortedData[groupIndex];
//     return BarTooltipItem(
//       'Name: ${item['itemname'].toString().trim()}\nCode: ${item['itemcode'].toString().trim()}\nAmount: ${intl.NumberFormat.currency(locale: 'en_IN', symbol: "").format(item['amount'])}',
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
//             axisNameWidget: const Text(
//               'Amount in Lakhs',
//               style: TextStyle(fontSize: 12),
//             ),
//             sideTitles: SideTitles(
//               showTitles: true,
//               reservedSize: yAxisReservedSize,
//               getTitlesWidget: _leftTitlesWidget,
//             ),
//           ),
//           bottomTitles: AxisTitles(
//             axisNameSize: 40,
//             axisNameWidget: const Text(
//               'Item Code',
//               style: TextStyle(fontSize: 12),
//             ),
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
//         barGroups: List.generate(sortedData.length, (idx) {
//           final amount = sortedData[idx]['amount'] as double;
//           final isSelected = touchedIndex == idx;
//           return BarChartGroupData(
//             x: idx,
//             barRods: [
//               BarChartRodData(
//                 toY: amount,
//                 color: isSelected ? Colors.blueAccent[700] : Colors.blue,
//                 width: 12,
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

// // import 'dart:math' as math;

// // import 'package:fl_chart/fl_chart.dart';
// // import 'package:flutter/material.dart';
// // import 'package:intl/intl.dart' as intl;

// // class BestSellingBySalesAmountChart extends StatelessWidget {
// //   final List<Map<String, dynamic>> chartData;
// //   const BestSellingBySalesAmountChart({super.key, required this.chartData});

// //   @override
// //   Widget build(BuildContext context) {
// //     return _BestSellingBySalesAmountChartContent(chartData: chartData);
// //   }
// // }

// // class _BestSellingBySalesAmountChartContent extends StatefulWidget {
// //   const _BestSellingBySalesAmountChartContent({required this.chartData});
// //   final List<Map<String, dynamic>> chartData;

// //   @override
// //   State<_BestSellingBySalesAmountChartContent> createState() =>
// //       _BestSellingBySalesAmountChartContentState();
// // }

// // class _BestSellingBySalesAmountChartContentState
// //     extends State<_BestSellingBySalesAmountChartContent> {
// //   int? touchedIndex;

// //   late final List<Map<String, dynamic>> sortedData;
// //   late final double maxY;
// //   late final double yAxisReservedSize;

// //   @override
// //   void initState() {
// //     super.initState();

// //     // Sort item data by amount descending
// //     sortedData = List<Map<String, dynamic>>.from(
// //       widget.chartData,
// //     )..sort((a, b) => (b['amount'] as double).compareTo(a['amount'] as double));

// //     // Calculate max Y for chart
// //     maxY =
// //         sortedData
// //             .map((e) => e['amount'] as double)
// //             .reduce((a, b) => a > b ? a : b) *
// //         1.2;

// //     // Pre-calculate Y-axis label width
// //     yAxisReservedSize = _computeYAxisLabelWidth(maxY);
// //   }

// //   double _computeYAxisLabelWidth(double maxY) {
// //     final maxLabelValue = (maxY / 100000).ceil();
// //     final maxLabelString = '$maxLabelValue';

// //     final textPainter = TextPainter(
// //       text: TextSpan(
// //         text: maxLabelString,
// //         style: const TextStyle(fontSize: 12),
// //       ),
// //       textDirection: TextDirection.ltr,
// //     )..layout();

// //     return textPainter.width + 12;
// //   }

// //   void _updateTouchedIndex(int? index) {
// //     if (mounted) {
// //       setState(() {
// //         touchedIndex = index;
// //       });
// //     }
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     final theme = Theme.of(context);

// //     return Column(
// //       crossAxisAlignment: CrossAxisAlignment.start,
// //       children: [
// //         // Chart Container
// //         Container(
// //           decoration: BoxDecoration(
// //             color: Colors.white,
// //             borderRadius: BorderRadius.circular(16),
// //             border: Border.all(color: Colors.grey.shade200),
// //             boxShadow: [
// //               BoxShadow(
// //                 color: Colors.black.withOpacity(0.04),
// //                 blurRadius: 10,
// //                 offset: const Offset(0, 2),
// //               ),
// //             ],
// //           ),
// //           padding: const EdgeInsets.all(20),
// //           child: AspectRatio(
// //             aspectRatio: 1.0,
// //             child: _BarChart(
// //               sortedData: sortedData,
// //               maxY: maxY,
// //               yAxisReservedSize: yAxisReservedSize,
// //               touchedIndex: touchedIndex,
// //               onTouched: _updateTouchedIndex,
// //             ),
// //           ),
// //         ),
// //         const SizedBox(height: 16),
// //         // Legend/Info
// //         if (touchedIndex != null) ...[
// //           Container(
// //             padding: const EdgeInsets.all(16),
// //             decoration: BoxDecoration(
// //               gradient: LinearGradient(
// //                 colors: [
// //                   Colors.blue.shade50,
// //                   Colors.blue.shade100.withOpacity(0.5),
// //                 ],
// //               ),
// //               borderRadius: BorderRadius.circular(12),
// //               border: Border.all(color: Colors.blue.shade200),
// //             ),
// //             child: Row(
// //               children: [
// //                 Container(
// //                   width: 4,
// //                   height: 40,
// //                   decoration: BoxDecoration(
// //                     color: Colors.blue.shade600,
// //                     borderRadius: BorderRadius.circular(2),
// //                   ),
// //                 ),
// //                 const SizedBox(width: 12),
// //                 Expanded(
// //                   child: Column(
// //                     crossAxisAlignment: CrossAxisAlignment.start,
// //                     children: [
// //                       Text(
// //                         'Selected Item Details',
// //                         style: TextStyle(
// //                           fontSize: 12,
// //                           color: Colors.blue.shade700,
// //                           fontWeight: FontWeight.w600,
// //                         ),
// //                       ),
// //                       const SizedBox(height: 4),
// //                       Text(
// //                         '${sortedData[touchedIndex!]['itemname']}',
// //                         style: const TextStyle(
// //                           fontSize: 14,
// //                           fontWeight: FontWeight.bold,
// //                         ),
// //                         maxLines: 1,
// //                         overflow: TextOverflow.ellipsis,
// //                       ),
// //                       Text(
// //                         'Code: ${sortedData[touchedIndex!]['itemcode']} • Amount: ₹${intl.NumberFormat.currency(locale: 'en_IN', symbol: "").format(sortedData[touchedIndex!]['amount'])}',
// //                         style: TextStyle(
// //                           fontSize: 12,
// //                           color: Colors.grey.shade600,
// //                         ),
// //                       ),
// //                     ],
// //                   ),
// //                 ),
// //               ],
// //             ),
// //           ),
// //         ] else ...[
// //           Container(
// //             padding: const EdgeInsets.all(16),
// //             decoration: BoxDecoration(
// //               color: Colors.grey.shade50,
// //               borderRadius: BorderRadius.circular(12),
// //               border: Border.all(color: Colors.grey.shade200),
// //             ),
// //             child: Row(
// //               children: [
// //                 Icon(
// //                   Icons.touch_app_rounded,
// //                   color: Colors.grey.shade500,
// //                   size: 20,
// //                 ),
// //                 const SizedBox(width: 8),
// //                 Text(
// //                   'Tap on any bar to view item details',
// //                   style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
// //                 ),
// //               ],
// //             ),
// //           ),
// //         ],
// //       ],
// //     );
// //   }
// // }

// // class _BarChart extends StatelessWidget {
// //   final List<Map<String, dynamic>> sortedData;
// //   final double maxY;
// //   final double yAxisReservedSize;
// //   final int? touchedIndex;
// //   final Function(int?) onTouched;

// //   const _BarChart({
// //     required this.sortedData,
// //     required this.maxY,
// //     required this.yAxisReservedSize,
// //     required this.touchedIndex,
// //     required this.onTouched,
// //   });

// //   Widget _leftTitlesWidget(double value, TitleMeta meta) {
// //     if (value == 0) {
// //       return SideTitleWidget(
// //         meta: meta,
// //         space: 12,
// //         child: Text(
// //           '0',
// //           style: TextStyle(
// //             fontSize: 11,
// //             color: Colors.grey.shade600,
// //             fontWeight: FontWeight.w500,
// //           ),
// //         ),
// //       );
// //     }
// //     if (value % 100000 == 0) {
// //       return SideTitleWidget(
// //         meta: meta,
// //         space: 12,
// //         child: Text(
// //           (value / 100000).toStringAsFixed(0),
// //           style: TextStyle(
// //             fontSize: 11,
// //             color: Colors.grey.shade600,
// //             fontWeight: FontWeight.w500,
// //           ),
// //         ),
// //       );
// //     }
// //     return SideTitleWidget(
// //       meta: meta,
// //       space: 12,
// //       child: const SizedBox.shrink(),
// //     );
// //   }

// //   Widget _bottomTitlesWidget(double value, TitleMeta meta) {
// //     final idx = value.toInt();
// //     if (idx < 0 || idx >= sortedData.length) {
// //       return const SizedBox.shrink();
// //     }
// //     final label = sortedData[idx]['itemcode'] as String;
// //     final isSelected = touchedIndex == idx;

// //     final displayLabel =
// //         label.length > 4 ? '${label.substring(0, 4)}...' : label;

// //     return SideTitleWidget(
// //       meta: meta,
// //       space: 12,
// //       child: GestureDetector(
// //         onTap: () => onTouched(idx),
// //         child: Transform.rotate(
// //           angle: -(math.pi / 3),
// //           child: Container(
// //             padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
// //             decoration:
// //                 isSelected
// //                     ? BoxDecoration(
// //                       color: Colors.blue.shade100,
// //                       borderRadius: BorderRadius.circular(4),
// //                     )
// //                     : null,
// //             child: Text(
// //               displayLabel.trim(),
// //               style: TextStyle(
// //                 fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
// //                 color: isSelected ? Colors.blue.shade700 : Colors.grey.shade700,
// //                 fontSize: 11,
// //               ),
// //             ),
// //           ),
// //         ),
// //       ),
// //     );
// //   }

// //   BarTooltipItem _getTooltipItem(
// //     BarChartGroupData group,
// //     int groupIndex,
// //     BarChartRodData rod,
// //     int rodIndex,
// //   ) {
// //     final item = sortedData[groupIndex];
// //     return BarTooltipItem(
// //       'Name: ${item['itemname'].toString().trim()}\nCode: ${item['itemcode'].toString().trim()}\nAmount: ${intl.NumberFormat.currency(locale: 'en_IN', symbol: "").format(item['amount'])}',
// //       const TextStyle(
// //         color: Colors.white,
// //         fontWeight: FontWeight.w600,
// //         fontSize: 13,
// //         height: 1.3,
// //         shadows: [
// //           Shadow(color: Colors.black26, blurRadius: 2, offset: Offset(0, 1)),
// //         ],
// //       ),
// //     );
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     return BarChart(
// //       BarChartData(
// //         alignment: BarChartAlignment.spaceAround,
// //         maxY: maxY,
// //         barTouchData: BarTouchData(
// //           enabled: true,
// //           touchTooltipData: BarTouchTooltipData(
// //             fitInsideHorizontally: true,
// //             fitInsideVertically: true,
// //             getTooltipColor: (group) => Colors.grey.shade800,
// //             tooltipPadding: const EdgeInsets.symmetric(
// //               horizontal: 16,
// //               vertical: 12,
// //             ),
// //             tooltipRoundedRadius: 12,
// //             tooltipBorder: BorderSide.none,
// //             getTooltipItem: _getTooltipItem,
// //             tooltipMargin: 16,
// //           ),
// //           touchCallback: (event, response) {
// //             if (event is FlTapUpEvent &&
// //                 response != null &&
// //                 response.spot != null) {
// //               onTouched(response.spot!.touchedBarGroupIndex);
// //             } else if (event is FlTapUpEvent) {
// //               onTouched(null);
// //             }
// //           },
// //         ),
// //         titlesData: FlTitlesData(
// //           leftTitles: AxisTitles(
// //             axisNameWidget: Container(
// //               child: Text(
// //                 'Amount in Lakhs',
// //                 style: TextStyle(
// //                   fontSize: 12,
// //                   fontWeight: FontWeight.w600,
// //                   color: Colors.grey.shade700,
// //                 ),
// //               ),
// //             ),
// //             sideTitles: SideTitles(
// //               showTitles: true,
// //               reservedSize: yAxisReservedSize,
// //               getTitlesWidget: _leftTitlesWidget,
// //             ),
// //           ),
// //           bottomTitles: AxisTitles(
// //             axisNameSize: 45,
// //             axisNameWidget: Container(
// //               padding: const EdgeInsets.only(top: 8),
// //               child: Text(
// //                 'Item Code',
// //                 style: TextStyle(
// //                   fontSize: 12,
// //                   fontWeight: FontWeight.w600,
// //                   color: Colors.grey.shade700,
// //                 ),
// //               ),
// //             ),
// //             sideTitles: SideTitles(
// //               showTitles: true,
// //               getTitlesWidget: _bottomTitlesWidget,
// //             ),
// //           ),
// //           rightTitles: const AxisTitles(
// //             sideTitles: SideTitles(showTitles: false),
// //           ),
// //           topTitles: const AxisTitles(
// //             sideTitles: SideTitles(showTitles: false),
// //           ),
// //         ),
// //         borderData: FlBorderData(
// //           show: true,
// //           border: Border(
// //             left: BorderSide(color: Colors.grey.shade300, width: 1),
// //             bottom: BorderSide(color: Colors.grey.shade300, width: 1),
// //           ),
// //         ),
// //         gridData: FlGridData(
// //           show: true,
// //           drawVerticalLine: false,
// //           horizontalInterval: 100000,
// //           getDrawingHorizontalLine:
// //               (value) => FlLine(
// //                 color: Colors.grey.shade200,
// //                 strokeWidth: 1,
// //                 dashArray: [4, 4],
// //               ),
// //         ),
// //         barGroups: List.generate(sortedData.length, (idx) {
// //           final amount = sortedData[idx]['amount'] as double;
// //           final isSelected = touchedIndex == idx;
// //           return BarChartGroupData(
// //             x: idx,
// //             barRods: [
// //               BarChartRodData(
// //                 toY: amount,
// //                 gradient:
// //                     isSelected
// //                         ? LinearGradient(
// //                           begin: Alignment.bottomCenter,
// //                           end: Alignment.topCenter,
// //                           colors: [Colors.blue.shade600, Colors.blue.shade400],
// //                         )
// //                         : LinearGradient(
// //                           begin: Alignment.bottomCenter,
// //                           end: Alignment.topCenter,
// //                           colors: [Colors.blue.shade500, Colors.blue.shade300],
// //                         ),
// //                 width: isSelected ? 26 : 22,
// //                 borderRadius: const BorderRadius.vertical(
// //                   top: Radius.circular(4),
// //                 ),
// //                 borderSide:
// //                     isSelected
// //                         ? BorderSide(color: Colors.blue.shade800, width: 2)
// //                         : BorderSide.none,
// //               ),
// //             ],
// //             showingTooltipIndicators: isSelected ? [0] : [],
// //           );
// //         }),
// //       ),
// //     );
// //   }
// // }

import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart' as intl;

class BestSellingBySalesAmountChart extends StatelessWidget {
  final List<Map<String, dynamic>> chartData;
  const BestSellingBySalesAmountChart({super.key, required this.chartData});

  @override
  Widget build(BuildContext context) {
    return _BestSellingBySalesAmountChartContent(chartData: chartData);
  }
}

class _BestSellingBySalesAmountChartContent extends StatefulWidget {
  const _BestSellingBySalesAmountChartContent({required this.chartData});
  final List<Map<String, dynamic>> chartData;

  @override
  State<_BestSellingBySalesAmountChartContent> createState() =>
      _BestSellingBySalesAmountChartContentState();
}

class _BestSellingBySalesAmountChartContentState
    extends State<_BestSellingBySalesAmountChartContent> {
  int? touchedIndex;

  late final List<Map<String, dynamic>> sortedData;
  late final double maxY;
  late final double yAxisReservedSize;

  @override
  void initState() {
    super.initState();

    // Sort item data by amount descending
    sortedData = List<Map<String, dynamic>>.from(widget.chartData)..sort(
      (a, b) =>
          ((b['amount'] as num?) ?? 0).compareTo((a['amount'] as num?) ?? 0),
    );

    // Calculate max Y for chart, handle empty data
    if (sortedData.isNotEmpty) {
      maxY =
          sortedData
              .map((e) => (e['amount'] as num?)?.toDouble() ?? 0.0)
              .reduce((a, b) => a > b ? a : b) *
          1.2;
    } else {
      maxY = 100000;
    }

    // Pre-calculate Y-axis label width (in lakhs)
    yAxisReservedSize = _computeYAxisLabelWidth(maxY);
  }

  double _computeYAxisLabelWidth(double maxY) {
    final maxLabelValue = (maxY / 100000).ceil();
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
            // const _ChartTitle(),
            const SizedBox(height: 16),
            AspectRatio(
              aspectRatio: 1.0,
              child: _BarChart(
                sortedData: sortedData,
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
  final List<Map<String, dynamic>> sortedData;
  final double maxY;
  final double yAxisReservedSize;
  final int? touchedIndex;
  final Function(int?) onTouched;

  const _BarChart({
    required this.sortedData,
    required this.maxY,
    required this.yAxisReservedSize,
    required this.touchedIndex,
    required this.onTouched,
  });

  Widget _leftTitlesWidget(double value, TitleMeta meta) {
    if (value == 0) {
      return SideTitleWidget(meta: meta, space: 8, child: const Text('0'));
    }
    if (value % 100000 == 0) {
      return SideTitleWidget(
        meta: meta,
        space: 8,
        child: Text(
          (value / 100000).toStringAsFixed(0),
          style: const TextStyle(fontSize: 12),
        ),
      );
    }
    return SideTitleWidget(
      meta: meta,
      space: 8,
      child: const SizedBox.shrink(),
    );
  }

  Widget _bottomTitlesWidget(double value, TitleMeta meta) {
    final idx = value.toInt();
    if (idx < 0 || idx >= sortedData.length) {
      return const SizedBox.shrink();
    }
    final label = (sortedData[idx]['itemcode'] ?? '').toString();
    final isSelected = touchedIndex == idx;

    final displayLabel =
        label.length > 4 ? '${label.substring(0, 4)}...' : label;

    return SideTitleWidget(
      meta: meta,
      space: 8,
      child: GestureDetector(
        onTap: () => onTouched(idx),
        child: Transform.rotate(
          angle: -(math.pi / 3),
          child: Text(
            displayLabel.trim(),
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
    final item = sortedData[groupIndex];
    return BarTooltipItem(
      'Name: ${item['itemname'].toString().trim()}\nCode: ${item['itemcode'].toString().trim()}\nAmount: ${intl.NumberFormat.currency(locale: 'en_IN', symbol: "").format(item['amount'])}',
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
              'Amount in Lakhs',
              style: TextStyle(fontSize: 12),
            ),
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: yAxisReservedSize,
              getTitlesWidget: _leftTitlesWidget,
            ),
          ),
          bottomTitles: AxisTitles(
            axisNameSize: 40,
            axisNameWidget: const Text(
              'Item Code',
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
        barGroups: List.generate(sortedData.length, (idx) {
          final amount = (sortedData[idx]['amount'] as num?)?.toDouble() ?? 0.0;
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
