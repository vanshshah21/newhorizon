// import 'package:fl_chart/fl_chart.dart';
// import 'package:flutter/material.dart';

// class CustomerPurchaseBarChartCard extends StatelessWidget {
//   final List<Map<String, dynamic>> customerData;
//   const CustomerPurchaseBarChartCard({super.key, required this.customerData});

//   @override
//   Widget build(BuildContext context) {
//     return _CustomerPurchaseBarChartCardContent(customerData: customerData);
//   }
// }

// class _CustomerPurchaseBarChartCardContent extends StatefulWidget {
//   const _CustomerPurchaseBarChartCardContent({required this.customerData});

//   final List<Map<String, dynamic>> customerData;

//   @override
//   State<_CustomerPurchaseBarChartCardContent> createState() =>
//       _CustomerPurchaseBarChartCardContentState();
// }

// class _CustomerPurchaseBarChartCardContentState
//     extends State<_CustomerPurchaseBarChartCardContent> {
//   int? touchedIndex;

//   late final List<Map<String, dynamic>> sortedData;
//   late final double maxY;
//   late final double yAxisReservedSize;

//   @override
//   void initState() {
//     super.initState();

//     // Sort customer data by amount descending
//     sortedData = List<Map<String, dynamic>>.from(
//       widget.customerData,
//     )..sort((a, b) => (b['amount'] as double).compareTo(a['amount'] as double));

//     // Calculate max Y for chart
//     maxY =
//         sortedData
//             .map((e) => e['amount'] as double)
//             .reduce((a, b) => a > b ? a : b) *
//         1.2;

//     // Pre-calculate Y-axis label width
//     yAxisReservedSize = _computeYAxisLabelWidth();
//   }

//   double _computeYAxisLabelWidth() {
//     final maxLabelValue = (maxY / 10000000).ceil(); // in Crores
//     final maxLabelString = '$maxLabelValue Cr';

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
//                 sortedData: sortedData,
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

// // class _ChartTitle extends StatelessWidget {
// //   const _ChartTitle();

// //   @override
// //   Widget build(BuildContext context) {
// //     return const Padding(
// //       padding: EdgeInsets.only(bottom: 16, top: 16),
// //       child: Text(
// //         'Customer-wise Purchase Amounts',
// //         style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
// //       ),
// //     );
// //   }
// // }

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

//   @override
//   Widget build(BuildContext context) {
//     return BarChart(
//       BarChartData(
//         alignment: BarChartAlignment.spaceAround,
//         maxY: maxY,
//         barTouchData: BarTouchData(
//           enabled: true,
//           touchTooltipData: BarTouchTooltipData(
//             getTooltipColor: (group) => Colors.black,
//             tooltipPadding: const EdgeInsets.symmetric(
//               horizontal: 12,
//               vertical: 8,
//             ),
//             tooltipRoundedRadius: 8,
//             tooltipBorder: BorderSide.none,
//             getTooltipItem: (group, groupIndex, rod, rodIndex) {
//               final customer = sortedData[groupIndex];
//               return BarTooltipItem(
//                 'Name: ${customer['customername'].toString().trim()}\nAmount: ${(customer['amount'] as double).toStringAsFixed(2)}',
//                 const TextStyle(
//                   color: Colors.white,
//                   fontWeight: FontWeight.bold,
//                   fontSize: 14,
//                   shadows: [
//                     Shadow(
//                       color: Colors.black54,
//                       blurRadius: 4,
//                       offset: Offset(1, 2),
//                     ),
//                   ],
//                 ),
//               );
//             },
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
//               getTitlesWidget: (value, meta) {
//                 if (value == 0) {
//                   return const Text('0');
//                 }
//                 if (value % 1000000000 == 0) {
//                   return Text(
//                     '${(value / 10000000).toStringAsFixed(0)} Cr',
//                     style: const TextStyle(fontSize: 12),
//                   );
//                 }
//                 return const SizedBox.shrink();
//               },
//             ),
//           ),
//           bottomTitles: AxisTitles(
//             sideTitles: SideTitles(
//               showTitles: true,
//               getTitlesWidget: (value, meta) {
//                 final idx = value.toInt();
//                 if (idx < 0 || idx >= sortedData.length) {
//                   return const SizedBox.shrink();
//                 }
//                 final label = sortedData[idx]['customercode'] as String;
//                 final isSelected = touchedIndex == idx;
//                 return GestureDetector(
//                   onTap: () => onTouched(idx),
//                   child: Padding(
//                     padding: const EdgeInsets.only(top: 8.0),
//                     child: Text(
//                       label.trim(),
//                       style: TextStyle(
//                         fontWeight:
//                             isSelected ? FontWeight.bold : FontWeight.normal,
//                         color:
//                             isSelected
//                                 ? Colors.blueAccent[700]
//                                 : Colors.black87,
//                         fontSize: 12,
//                       ),
//                     ),
//                   ),
//                 );
//               },
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
//                 width: 22,
//                 borderRadius: BorderRadius.circular(6),
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

// class CustomerPurchaseBarChartCard extends StatelessWidget {
//   final List<Map<String, dynamic>> customerData;
//   const CustomerPurchaseBarChartCard({super.key, required this.customerData});

//   @override
//   Widget build(BuildContext context) {
//     return _CustomerPurchaseBarChartCardContent(customerData: customerData);
//   }
// }

// class _CustomerPurchaseBarChartCardContent extends StatefulWidget {
//   const _CustomerPurchaseBarChartCardContent({required this.customerData});
//   final List<Map<String, dynamic>> customerData;

//   @override
//   State<_CustomerPurchaseBarChartCardContent> createState() =>
//       _CustomerPurchaseBarChartCardContentState();
// }

// class _CustomerPurchaseBarChartCardContentState
//     extends State<_CustomerPurchaseBarChartCardContent> {
//   int? touchedIndex;

//   late final List<Map<String, dynamic>> sortedData;
//   late final double maxY;
//   late final double yAxisReservedSize;

//   @override
//   void initState() {
//     super.initState();

//     // Sort customer data by amount descending
//     sortedData = List<Map<String, dynamic>>.from(
//       widget.customerData,
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
//     final maxLabelValue = (maxY / 10000000).ceil(); // in Crores
//     final maxLabelString = '$maxLabelValue Cr';

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
//               aspectRatio: 1.2,
//               child: _BarChart(
//                 sortedData: sortedData,
//                 // maxY: maxY,
//                 // yAxisReservedSize: yAxisReservedSize,
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

// // class _ChartTitle extends StatelessWidget {
// //   const _ChartTitle();
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     return const Padding(
// //       padding: EdgeInsets.only(bottom: 16, top: 16),
// //       child: Text(
// //         'Customer-wise Purchase Amounts',
// //         style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
// //       ),
// //     );
// //   }
// // }

// class _BarChart extends StatelessWidget {
//   final List<Map<String, dynamic>> sortedData;
//   // final double maxY;
//   // final double yAxisReservedSize;
//   final int? touchedIndex;
//   final Function(int?) onTouched;

//   const _BarChart({
//     required this.sortedData,
//     // required this.maxY,
//     // required this.yAxisReservedSize,
//     required this.touchedIndex,
//     required this.onTouched,
//   });

//   Widget _leftTitlesWidget(double value, TitleMeta meta) {
//     if (value == 0) {
//       return SideTitleWidget(meta: meta, child: const Text('0'));
//     }
//     if (value % 100000 == 0) {
//       return SideTitleWidget(
//         space: 4,
//         meta: meta,
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
//     if (idx < 0 || idx >= sortedData.length) {
//       return const SizedBox.shrink();
//     }
//     final label = sortedData[idx]['customercode'] as String;
//     final isSelected = touchedIndex == idx;
//     return SideTitleWidget(
//       space: 8,
//       meta: meta,
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
//     final customer = sortedData[groupIndex];
//     return BarTooltipItem(
//       'Name: ${customer['customername'].toString().trim()}\nCode: ${customer['customercode'].toString().trim()}\nAmount: ${intl.NumberFormat.currency(locale: 'en_IN', symbol: "").format(customer['amount'])}',
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
//         // maxY: maxY,
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
//             axisNameWidget: Text("Amount (in Lakhs)"),
//             sideTitles: SideTitles(
//               showTitles: true,
//               // reservedSize: yAxisReservedSize,
//               getTitlesWidget: _leftTitlesWidget,
//             ),
//           ),
//           bottomTitles: AxisTitles(
//             axisNameSize: 40,
//             axisNameWidget: const Text("Customer Code"),
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

// import 'dart:math' as math;

// import 'package:fl_chart/fl_chart.dart';
// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart' as intl;

// class CustomerPurchaseBarChartCard extends StatelessWidget {
//   final List<Map<String, dynamic>> customerData;
//   const CustomerPurchaseBarChartCard({super.key, required this.customerData});

//   @override
//   Widget build(BuildContext context) {
//     return _CustomerPurchaseBarChartCardContent(customerData: customerData);
//   }
// }

// class _CustomerPurchaseBarChartCardContent extends StatefulWidget {
//   const _CustomerPurchaseBarChartCardContent({required this.customerData});
//   final List<Map<String, dynamic>> customerData;

//   @override
//   State<_CustomerPurchaseBarChartCardContent> createState() =>
//       _CustomerPurchaseBarChartCardContentState();
// }

// class _CustomerPurchaseBarChartCardContentState
//     extends State<_CustomerPurchaseBarChartCardContent> {
//   int? touchedIndex;

//   late final List<Map<String, dynamic>> sortedData;
//   late final double maxY;
//   late final double yAxisReservedSize;

//   @override
//   void initState() {
//     super.initState();

//     // Sort customer data by amount descending
//     sortedData = List<Map<String, dynamic>>.from(
//       widget.customerData,
//     )..sort((a, b) => (b['amount'] as double).compareTo(a['amount'] as double));

//     // Calculate max Y for chart (adding 20% padding on top)
//     maxY =
//         sortedData
//             .map((e) => e['amount'] as double)
//             .reduce((a, b) => a > b ? a : b) *
//         1.2;

//     // Pre-calculate Y-axis label width via a helper function
//     yAxisReservedSize = _computeYAxisLabelWidth(maxY);
//   }

//   double _computeYAxisLabelWidth(double maxY) {
//     final maxLabelValue = (maxY / 10000000).ceil(); // in Crores
//     final maxLabelString = '$maxLabelValue Cr';

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
//             // Uncomment below if you wish to show chart title
//             // const _ChartTitle(),
//             const SizedBox(height: 16),
//             AspectRatio(
//               aspectRatio: 1.2,
//               child: _BarChart(
//                 sortedData: sortedData,
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

// // Optional chart title widget
// // class _ChartTitle extends StatelessWidget {
// //   const _ChartTitle();
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     return const Padding(
// //       padding: EdgeInsets.only(bottom: 16, top: 16),
// //       child: Text(
// //         'Customer-wise Purchase Amounts',
// //         style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
// //       ),
// //     );
// //   }
// // }

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
//       return SideTitleWidget(meta: meta, child: const Text('0'));
//     }
//     // Show label for values divisible by 100000
//     if (value % 100000 == 0) {
//       return SideTitleWidget(
//         space: 4,
//         meta: meta,
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
//     if (idx < 0 || idx >= sortedData.length) {
//       return const SizedBox.shrink();
//     }
//     final label = sortedData[idx]['customercode'] as String;
//     final isSelected = touchedIndex == idx;
//     return SideTitleWidget(
//       space: 8,
//       meta: meta,
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
//     final customer = sortedData[groupIndex];
//     return BarTooltipItem(
//       'Name: ${customer['customername'].toString().trim()}\n'
//       'Code: ${customer['customercode'].toString().trim()}\n'
//       'Amount: ${intl.NumberFormat.currency(locale: 'en_IN', symbol: "").format(customer['amount'])}',
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
//         maxY: maxY, // Set the maximum y-axis value computed earlier
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
//             axisNameWidget: const Text("Amount (in Lakhs)"),
//             sideTitles: SideTitles(
//               showTitles: true,
//               reservedSize: yAxisReservedSize, // Set reserved size
//               getTitlesWidget: _leftTitlesWidget,
//             ),
//           ),
//           bottomTitles: AxisTitles(
//             axisNameSize: 40,
//             axisNameWidget: const Text("Customer Code"),
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

// import 'dart:math' as math;

// import 'package:fl_chart/fl_chart.dart';
// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart' as intl;

// class CustomerPurchaseBarChartCard extends StatelessWidget {
//   final List<Map<String, dynamic>> customerData;
//   const CustomerPurchaseBarChartCard({super.key, required this.customerData});

//   @override
//   Widget build(BuildContext context) {
//     return _CustomerPurchaseBarChartCardContent(customerData: customerData);
//   }
// }

// class _CustomerPurchaseBarChartCardContent extends StatefulWidget {
//   const _CustomerPurchaseBarChartCardContent({required this.customerData});
//   final List<Map<String, dynamic>> customerData;

//   @override
//   State<_CustomerPurchaseBarChartCardContent> createState() =>
//       _CustomerPurchaseBarChartCardContentState();
// }

// class _CustomerPurchaseBarChartCardContentState
//     extends State<_CustomerPurchaseBarChartCardContent> {
//   int? touchedIndex;

//   late final List<Map<String, dynamic>> sortedData;
//   late final double maxY;
//   late final double yAxisReservedSize;

//   @override
//   void initState() {
//     super.initState();

//     // Sort customer data by amount descending.
//     sortedData = List<Map<String, dynamic>>.from(
//       widget.customerData,
//     )..sort((a, b) => (b['amount'] as double).compareTo(a['amount'] as double));

//     // Extract the raw maximum amount.
//     final double rawMax = sortedData
//         .map((e) => e['amount'] as double)
//         .reduce(math.max);

//     // Convert to lakhs.
//     final double rawInLakhs = rawMax / 100000;

//     // Round up to the next multiple of 10; this gives one extra label.
//     // For example, 42.5 becomes 50.
//     final double roundedMaxInLakhs = (rawInLakhs / 10).ceil() * 10;

//     // Now, the adjusted maxY in rupees.
//     maxY = roundedMaxInLakhs * 100000;

//     // Pre-calculate Y-axis label width using the adjusted maxY.
//     yAxisReservedSize = _computeYAxisLabelWidth(maxY);
//   }

//   double _computeYAxisLabelWidth(double maxY) {
//     // Convert maxY to label text (in lakhs) as an integer.
//     final maxLabelString = (maxY / 100000).toStringAsFixed(0);
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
//             // Uncomment below if you wish to display chart title.
//             // const _ChartTitle(),
//             const SizedBox(height: 16),
//             AspectRatio(
//               aspectRatio: 1.2,
//               child: _BarChart(
//                 sortedData: sortedData,
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

// // Optionally, a chart title widget can be used.
// // class _ChartTitle extends StatelessWidget {
// //   const _ChartTitle();
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     return const Padding(
// //       padding: EdgeInsets.only(bottom: 16, top: 16),
// //       child: Text(
// //         'Customer-wise Purchase Amounts',
// //         style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
// //       ),
// //     );
// //   }
// // }

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

//   // Left titles: always show label in "lakhs" as a rounded integer.
//   Widget _leftTitlesWidget(double value, TitleMeta meta) {
//     return SideTitleWidget(
//       meta: meta,
//       child: Text(
//         (value / 100000).toStringAsFixed(0), // rounded integer in lakhs
//         style: const TextStyle(fontSize: 12),
//       ),
//     );
//   }

//   Widget _bottomTitlesWidget(double value, TitleMeta meta) {
//     final idx = value.toInt();
//     if (idx < 0 || idx >= sortedData.length) {
//       return const SizedBox.shrink();
//     }
//     final label = sortedData[idx]['customercode'] as String;
//     final isSelected = touchedIndex == idx;
//     return SideTitleWidget(
//       space: 8,
//       meta: meta,
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
//     final customer = sortedData[groupIndex];
//     return BarTooltipItem(
//       'Name: ${customer['customername'].toString().trim()}\n'
//       'Code: ${customer['customercode'].toString().trim()}\n'
//       'Amount: ${intl.NumberFormat.currency(locale: 'en_IN', symbol: "").format(customer['amount'])}',
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
//     // Use 5 intervals so that the labels and grid lines are evenly spaced.
//     final double interval = maxY / 5;
//     return BarChart(
//       BarChartData(
//         alignment: BarChartAlignment.spaceAround,
//         maxY: maxY,
//         barTouchData: BarTouchData(
//           enabled: true,
//           touchTooltipData: BarTouchTooltipData(
//             fitInsideHorizontally: true,
//             fitInsideVertically: true,
//             getTooltipColor: (_) => Colors.black,
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
//             axisNameWidget: const Text("Amount (in Lakhs)"),
//             sideTitles: SideTitles(
//               showTitles: true,
//               reservedSize: yAxisReservedSize,
//               interval: interval,
//               getTitlesWidget: _leftTitlesWidget,
//             ),
//           ),
//           bottomTitles: AxisTitles(
//             axisNameSize: 40,
//             axisNameWidget: const Text("Customer Code"),
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
//           horizontalInterval: interval,
//           checkToShowHorizontalLine: (value) => true, // force every interval
//         ),
//         barGroups: List.generate(sortedData.length, (idx) {
//           final amount = sortedData[idx]['amount'] as double;
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

import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart' as intl;

class CustomerPurchaseBarChartCard extends StatelessWidget {
  final List<Map<String, dynamic>> customerData;
  const CustomerPurchaseBarChartCard({super.key, required this.customerData});

  @override
  Widget build(BuildContext context) {
    return _CustomerPurchaseBarChartCardContent(customerData: customerData);
  }
}

class _CustomerPurchaseBarChartCardContent extends StatefulWidget {
  const _CustomerPurchaseBarChartCardContent({required this.customerData});
  final List<Map<String, dynamic>> customerData;

  @override
  State<_CustomerPurchaseBarChartCardContent> createState() =>
      _CustomerPurchaseBarChartCardContentState();
}

class _CustomerPurchaseBarChartCardContentState
    extends State<_CustomerPurchaseBarChartCardContent> {
  int? touchedIndex;

  late final List<Map<String, dynamic>> sortedData;
  late final double maxY;
  late final double yAxisReservedSize;

  @override
  void initState() {
    super.initState();

    // Sort customer data by amount descending.
    sortedData = List<Map<String, dynamic>>.from(widget.customerData)..sort(
      (a, b) =>
          ((b['amount'] as num?) ?? 0).compareTo((a['amount'] as num?) ?? 0),
    );

    // Extract the raw maximum amount.
    final double rawMax =
        sortedData.isNotEmpty
            ? sortedData
                .map((e) => (e['amount'] as num?)?.toDouble() ?? 0.0)
                .reduce(math.max)
            : 0.0;

    // Convert to lakhs.
    final double rawInLakhs = rawMax / 100000;

    // Round up to the next multiple of 10; this gives one extra label.
    // For example, 42.5 becomes 50.
    final double roundedMaxInLakhs = (rawInLakhs / 10).ceil() * 10;

    // Now, the adjusted maxY in rupees.
    maxY = roundedMaxInLakhs * 100000;

    // Pre-calculate Y-axis label width using the adjusted maxY.
    yAxisReservedSize = _computeYAxisLabelWidth(maxY);
  }

  double _computeYAxisLabelWidth(double maxY) {
    // Convert maxY to label text (in lakhs) as an integer.
    final maxLabelString = (maxY / 100000).toStringAsFixed(0);
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
            // Uncomment below if you wish to display chart title.
            // const _ChartTitle(),
            const SizedBox(height: 16),
            AspectRatio(
              aspectRatio: 1.2,
              child: _BarChart(
                sortedData: sortedData,
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

// Optionally, a chart title widget can be used.
// class _ChartTitle extends StatelessWidget {
//   const _ChartTitle();
//
//   @override
//   Widget build(BuildContext context) {
//     return const Padding(
//       padding: EdgeInsets.only(bottom: 16, top: 16),
//       child: Text(
//         'Customer-wise Purchase Amounts',
//         style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//       ),
//     );
//   }
// }

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

  // Left titles: show label in "lakhs" as a rounded integer, only at interval points.
  Widget _leftTitlesWidget(double value, TitleMeta meta) {
    if (value == 0) {
      return SideTitleWidget(
        meta: meta,
        child: const Text('0', style: TextStyle(fontSize: 12)),
      );
    }
    if (value % (maxY / 5) == 0 && value <= maxY) {
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

  Widget _bottomTitlesWidget(double value, TitleMeta meta) {
    final idx = value.toInt();
    if (idx < 0 || idx >= sortedData.length) {
      return const SizedBox.shrink();
    }
    final label = (sortedData[idx]['customercode'] ?? '').toString();
    final isSelected = touchedIndex == idx;
    // Truncate to 5 chars and add ellipsis if needed
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
    final customer = sortedData[groupIndex];
    return BarTooltipItem(
      'Name: ${customer['customername'].toString().trim()}\n'
      'Code: ${customer['customercode'].toString().trim()}\n'
      'Amount: ${intl.NumberFormat.currency(locale: 'en_IN', symbol: "").format(customer['amount'])}',
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
    // Use 5 intervals so that the labels and grid lines are evenly spaced.
    final double interval = maxY > 0 ? maxY / 5 : 1;
    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: maxY,
        barTouchData: BarTouchData(
          enabled: true,
          touchTooltipData: BarTouchTooltipData(
            fitInsideHorizontally: true,
            fitInsideVertically: true,
            getTooltipColor: (_) => Colors.black,
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
              interval: interval,
              getTitlesWidget: _leftTitlesWidget,
            ),
          ),
          bottomTitles: AxisTitles(
            axisNameSize: 40,
            axisNameWidget: const Text("Customer Code"),
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
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: interval,
          checkToShowHorizontalLine: (value) => true, // force every interval
        ),
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
