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

// import 'dart:math' as math;

// import 'package:fl_chart/fl_chart.dart';
// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart' as intl;

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
//   List<Map<String, dynamic>> displayedData = [];
//   double maxY = 1;
//   double yAxisReservedSize = 32;

//   @override
//   void didChangeDependencies() {
//     super.didChangeDependencies();
//     _initializeChartData();
//   }

//   void _initializeChartData() {
//     // Use as is, do not sort
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

//     // Call setState to update the UI if needed
//     if (mounted) setState(() {});
//   }

//   double _computeYAxisLabelWidth(double maxY) {
//     final maxLabelValue = (maxY / 100000).ceil(); // in Lakhs
//     final maxLabelString = maxLabelValue.toString();

//     final textPainter = TextPainter(
//       text: TextSpan(
//         text: maxLabelString,
//         style: const TextStyle(fontSize: 12),
//       ),
//       // textDirection: TextDirection.ltr,
//       textDirection: TextDirection.ltr,
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
//               aspectRatio: 1.3,
//               child: _BarChart(
//                 displayedData: displayedData,
//                 maxY: maxY,
//                 yAxisReservedSize: yAxisReservedSize,
//                 touchedIndex: touchedIndex,
//                 onTouched: _updateTouchedIndex,
//               ),
//             ),
//             const SizedBox(height: 8),
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
//       return SideTitleWidget(
//         meta: meta,
//         space: 4,
//         child: Text('0', style: const TextStyle(fontSize: 12)),
//       );
//     } else if (value % 100000 == 0 && value != 0) {
//       return SideTitleWidget(
//         meta: meta,
//         space: 4,
//         child: Text(
//           (value / 100000).toStringAsFixed(0),
//           style: const TextStyle(fontSize: 12),
//         ),
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
//     return SideTitleWidget(
//       meta: meta,
//       space: 8,
//       child: GestureDetector(
//         onTap: () => onTouched(idx),
//         child: Transform.rotate(
//           angle: -(math.pi / 3),
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
//       'Amount: ${intl.NumberFormat.currency(locale: 'en_IN', symbol: '').format(month['amount'] ?? 0)}',
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
//               'Amount (in Lakhs)',
//               style: TextStyle(fontSize: 12),
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

// import 'dart:math' as math;

// import 'package:fl_chart/fl_chart.dart';
// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart' as intl;

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
//   List<Map<String, dynamic>> displayedData = [];
//   double maxY = 1;
//   double yAxisReservedSize = 40;

//   @override
//   void didChangeDependencies() {
//     super.didChangeDependencies();
//     _initializeChartData();
//   }

//   void _initializeChartData() {
//     // Use as is, do not sort
//     displayedData = List<Map<String, dynamic>>.from(widget.purchaseAmountData);

//     // Calculate max Y for chart with better spacing
//     if (displayedData.isNotEmpty) {
//       final maxValue =
//           displayedData
//               .map((e) => (e['amount'] ?? 0) as num)
//               .reduce((a, b) => a > b ? a : b)
//               .toDouble();

//       // Round up to nearest 100000 (1 lakh) and add some padding
//       maxY = ((maxValue / 100000).ceil() + 1) * 100000.0;
//     } else {
//       maxY = 100000; // Default 1 lakh
//     }

//     // Pre-calculate Y-axis label width
//     yAxisReservedSize = _computeYAxisLabelWidth(maxY);

//     // Call setState to update the UI if needed
//     if (mounted) setState(() {});
//   }

//   double _computeYAxisLabelWidth(double maxY) {
//     final maxLabelValue = (maxY / 100000).ceil(); // in Lakhs
//     final maxLabelString = '${maxLabelValue}L';

//     final textPainter = TextPainter(
//       text: TextSpan(
//         text: maxLabelString,
//         style: const TextStyle(fontSize: 12),
//       ),
//       textDirection: TextDirection.ltr,
//     )..layout();

//     return math.max(textPainter.width + 16, 40);
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
//               aspectRatio: 1.4,
//               child: _BarChart(
//                 displayedData: displayedData,
//                 maxY: maxY,
//                 yAxisReservedSize: yAxisReservedSize,
//                 touchedIndex: touchedIndex,
//                 onTouched: _updateTouchedIndex,
//               ),
//             ),
//             const SizedBox(height: 8),
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
//       return SideTitleWidget(
//         meta: meta,
//         space: 4,
//         child: const Text('0', style: TextStyle(fontSize: 12)),
//       );
//     } else if (value % 100000 == 0 && value != 0 && value <= maxY) {
//       final lakhs = (value / 100000).toInt();
//       return SideTitleWidget(
//         meta: meta,
//         space: 4,
//         child: Text('${lakhs}L', style: const TextStyle(fontSize: 12)),
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
//     return SideTitleWidget(
//       meta: meta,
//       space: 4,
//       child: GestureDetector(
//         onTap: () => onTouched(idx),
//         child: Transform.rotate(
//           angle: -(math.pi / 4), // 45 degrees for better readability
//           child: Text(
//             label.trim(),
//             style: TextStyle(
//               fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
//               color: isSelected ? Colors.blueAccent[700] : Colors.black87,
//               fontSize: 11,
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
//       'Amount: ${intl.NumberFormat.currency(locale: 'en_IN', symbol: '₹').format(month['amount'] ?? 0)}',
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
//         minY: 0,
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
//             axisNameWidget: const Padding(
//               padding: EdgeInsets.only(bottom: 8.0),
//               child: Text('Amount (in Lakhs)', style: TextStyle(fontSize: 12)),
//             ),
//             sideTitles: SideTitles(
//               showTitles: true,
//               reservedSize: yAxisReservedSize,
//               getTitlesWidget: _leftTitlesWidget,
//               interval: 100000, // Show labels every 1 lakh
//             ),
//           ),
//           bottomTitles: AxisTitles(
//             sideTitles: SideTitles(
//               showTitles: true,
//               reservedSize: 50,
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
//         borderData: FlBorderData(
//           show: true,
//           border: const Border(
//             bottom: BorderSide(color: Colors.black26, width: 1),
//             left: BorderSide(color: Colors.black26, width: 1),
//           ),
//         ),
//         gridData: FlGridData(
//           show: true,
//           drawVerticalLine: false,
//           drawHorizontalLine: true,
//           horizontalInterval: 100000, // Grid lines every 1 lakh
//           getDrawingHorizontalLine: (value) {
//             if (value == 0) {
//               return const FlLine(color: Colors.black87, strokeWidth: 1.5);
//             }
//             return const FlLine(color: Colors.grey, strokeWidth: 0.5);
//           },
//         ),
//         barGroups: List.generate(displayedData.length, (idx) {
//           final amount = (displayedData[idx]['amount'] ?? 0).toDouble();
//           final isSelected = touchedIndex == idx;
//           return BarChartGroupData(
//             x: idx,
//             barRods: [
//               BarChartRodData(
//                 toY: amount,
//                 color: isSelected ? Colors.blueAccent[700] : Colors.blue,
//                 width: 14,
//                 borderRadius: BorderRadius.circular(2),
//               ),
//             ],
//             showingTooltipIndicators: isSelected ? [0] : [],
//           );
//         }),
//       ),
//     );
//   }
// }

// import 'dart:math' as math;
// import 'package:fl_chart/fl_chart.dart';
// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart' as intl;

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
//     _initializeChartData();
//   }

//   void _initializeChartData() {
//     // Use as is, do not sort
//     displayedData = List<Map<String, dynamic>>.from(widget.purchaseAmountData);

//     // Calculate max Y for chart with better spacing
//     if (displayedData.isNotEmpty) {
//       final maxValue =
//           displayedData
//               .map((e) => (e['amount'] ?? 0) as num)
//               .reduce((a, b) => a > b ? a : b)
//               .toDouble();

//       // Round up to nearest 100000 (1 lakh) and add some padding
//       maxY = ((maxValue / 100000).ceil() + 1) * 100000.0;
//     } else {
//       maxY = 100000; // Default 1 lakh
//     }

//     // Pre-calculate Y-axis label width
//     yAxisReservedSize = _computeYAxisLabelWidth(maxY);
//   }

//   double _computeYAxisLabelWidth(double maxY) {
//     final maxLabelValue = (maxY / 100000).ceil(); // in Lakhs
//     final maxLabelString = '${maxLabelValue}L';

//     final textPainter = TextPainter(
//       text: TextSpan(
//         text: maxLabelString,
//         style: const TextStyle(fontSize: 12),
//       ),
//       textDirection: TextDirection.ltr,
//     )..layout();

//     return math.max(textPainter.width + 16, 40);
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
//         padding: const EdgeInsets.all(12),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             const Padding(
//               padding: EdgeInsets.only(bottom: 8.0),
//               child: Text(
//                 'Purchase Amount (Month Wise)',
//                 style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
//               ),
//             ),
//             AspectRatio(
//               aspectRatio: 1.4,
//               child: _BarChart(
//                 displayedData: displayedData,
//                 maxY: maxY,
//                 yAxisReservedSize: yAxisReservedSize,
//                 touchedIndex: touchedIndex,
//                 onTouched: _updateTouchedIndex,
//               ),
//             ),
//             const SizedBox(height: 8),
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
//       return SideTitleWidget(
//         meta: meta,
//         space: 4,
//         child: const Text('0', style: TextStyle(fontSize: 12)),
//       );
//     } else if (value % 100000 == 0 && value != 0 && value <= maxY) {
//       final lakhs = (value / 100000).toInt();
//       return SideTitleWidget(
//         meta: meta,
//         space: 4,
//         child: Text('${lakhs}L', style: const TextStyle(fontSize: 12)),
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
//     // Truncate to 5 chars and add ellipsis if needed
//     final displayLabel =
//         label.length > 5 ? '${label.substring(0, 5)}...' : label;
//     return GestureDetector(
//       onTap: () => onTouched(idx),
//       child: Padding(
//         padding: const EdgeInsets.only(top: 8.0),
//         child: Transform.rotate(
//           angle: -0.95,
//           child: Text(
//             displayLabel,
//             style: TextStyle(
//               fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
//               color: isSelected ? Colors.blueAccent[700] : Colors.black87,
//               fontSize: 12,
//             ),
//             overflow: TextOverflow.ellipsis,
//             maxLines: 1,
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
//       'Amount: ${intl.NumberFormat.currency(locale: 'en_IN', symbol: '₹').format(month['amount'] ?? 0)}',
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
//         minY: 0,
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
//             axisNameWidget: const Padding(
//               padding: EdgeInsets.only(bottom: 8.0),
//               child: Text('Amount (in Lakhs)', style: TextStyle(fontSize: 12)),
//             ),
//             sideTitles: SideTitles(
//               showTitles: true,
//               reservedSize: yAxisReservedSize,
//               getTitlesWidget: _leftTitlesWidget,
//               interval: 100000, // Show labels every 1 lakh
//             ),
//           ),
//           bottomTitles: AxisTitles(
//             axisNameSize: 60,
//             axisNameWidget: const Text('Month'),
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
//         gridData: FlGridData(
//           show: true,
//           drawVerticalLine: false,
//           drawHorizontalLine: true,
//           horizontalInterval: 100000, // Grid lines every 1 lakh
//           getDrawingHorizontalLine: (value) {
//             if (value == 0) {
//               return const FlLine(color: Colors.black87, strokeWidth: 1.5);
//             }
//             return const FlLine(color: Colors.grey, strokeWidth: 0.5);
//           },
//         ),
//         barGroups: List.generate(displayedData.length, (idx) {
//           final amount = (displayedData[idx]['amount'] ?? 0).toDouble();
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

import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart' as intl;

class PurchaseAmountBarChartCard extends StatelessWidget {
  final List<Map<String, dynamic>> purchaseAmountData;
  static const int maxBars = 12; // Show only 12 months

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
  late final List<Map<String, dynamic>> displayedData;
  late final double maxY;
  late final double yAxisReservedSize;

  @override
  void initState() {
    super.initState();

    // Use as is, do not sort
    displayedData =
        List<Map<String, dynamic>>.from(
          widget.purchaseAmountData,
        ).take(PurchaseAmountBarChartCard.maxBars).toList();

    // Calculate max Y for chart
    maxY =
        displayedData.isNotEmpty
            ? ((displayedData
                        .map((e) => (e['amount'] ?? 0) as num)
                        .reduce((a, b) => a > b ? a : b)
                        .toDouble() *
                    1.1)
                .ceilToDouble())
            : 1;

    // Pre-calculate Y-axis label width
    yAxisReservedSize = _computeYAxisLabelWidth(maxY);
  }

  double _computeYAxisLabelWidth(double maxY) {
    final maxLabelValue = (maxY / 100000).ceil(); // in Lakhs
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
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.only(bottom: 8.0),
              child: Text(
                'Purchase Amount (Month Wise)',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            AspectRatio(
              aspectRatio: 0.5,
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
    String? label;
    if (value == 0) {
      label = '0';
    } else if (value % 100000 == 0 && value != 0) {
      label = (value / 100000).toStringAsFixed(0);
    }

    return SideTitleWidget(
      meta: meta,
      space: 0, // space between the axis and the label
      child:
          label != null
              ? Text(label, style: const TextStyle(fontSize: 10))
              : const SizedBox.shrink(),
    );
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
      space: 2,
      child: GestureDetector(
        onTap: () => onTouched(idx),
        child: Text(
          label.trim(),
          style: TextStyle(
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected ? Colors.green[300] : Colors.black87,
            fontSize: 8,
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
            axisNameWidget: const Text("Amount (in Lakhs)"),
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: yAxisReservedSize,
              getTitlesWidget: _leftTitlesWidget,
            ),
          ),
          bottomTitles: AxisTitles(
            axisNameWidget: const Text("Month"),
            sideTitles: SideTitles(
              showTitles: true,
              // reservedSize: 36,
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
                color: isSelected ? Colors.green[700] : Colors.green[300],
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
