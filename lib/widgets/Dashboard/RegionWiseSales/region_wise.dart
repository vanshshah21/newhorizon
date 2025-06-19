// import 'package:fl_chart/fl_chart.dart';
// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart' as intl;

// // --- Region Model ---
// class RegionData {
//   final String code;
//   final String region;
//   final double totalInvoiceValue;

//   RegionData({
//     required this.code,
//     required this.region,
//     required this.totalInvoiceValue,
//   });

//   factory RegionData.fromMap(Map<String, dynamic> map) {
//     return RegionData(
//       code: (map['code'] ?? '').toString(),
//       region: (map['region'] ?? '').toString(),
//       totalInvoiceValue: (map['totalinvoicevalue'] ?? 0).toDouble(),
//     );
//   }
// }

// // --- Main Widget ---
// class RegionPieChartCard extends StatefulWidget {
//   final List<RegionData> regions;
//   const RegionPieChartCard({super.key, required this.regions});

//   @override
//   State<RegionPieChartCard> createState() => _RegionPieChartCardState();
// }

// class _RegionPieChartCardState extends State<RegionPieChartCard> {
//   int? touchedIndex;

//   final List<Color> sectionColors = [
//     Colors.blue,
//     Colors.red,
//     Colors.green,
//     Colors.orange,
//     Colors.purple,
//     Colors.teal,
//     Colors.brown,
//     Colors.pink,
//     Colors.indigo,
//     // Add more if needed
//   ];

//   // Sorted list getter (by value descending)
//   List<RegionData> get sortedRegions {
//     final sorted = List<RegionData>.from(widget.regions)
//       ..sort((a, b) => b.totalInvoiceValue.compareTo(a.totalInvoiceValue));
//     return sorted;
//   }

//   @override
//   Widget build(BuildContext context) {
//     final chartData = sortedRegions;
//     // final double totalValue = chartData.fold(
//     //   0,
//     //   (sum, item) => sum + item.totalInvoiceValue,
//     // );

//     return Card(
//       elevation: 4,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//       child: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             const Padding(
//               padding: EdgeInsets.only(bottom: 4, top: 4),
//               child: Text(
//                 'Region List',
//                 style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//               ),
//             ),
//             AspectRatio(
//               aspectRatio: 1.5,
//               child: PieChart(
//                 PieChartData(
//                   sectionsSpace: 1,
//                   centerSpaceRadius: 40,
//                   pieTouchData: PieTouchData(
//                     touchCallback: (FlTouchEvent event, pieTouchResponse) {
//                       setState(() {
//                         if (event is FlTapUpEvent &&
//                             pieTouchResponse != null &&
//                             pieTouchResponse.touchedSection != null) {
//                           touchedIndex =
//                               pieTouchResponse
//                                   .touchedSection!
//                                   .touchedSectionIndex;
//                         } else if (event is FlTapUpEvent) {
//                           touchedIndex = null;
//                         }
//                       });
//                     },
//                   ),
//                   sections: List.generate(chartData.length, (i) {
//                     final isTouched = i == touchedIndex;
//                     final double fontSize = isTouched ? 15 : 12;
//                     final double radius = isTouched ? 60 : 50;
//                     final region = chartData[i];
//                     final value = region.totalInvoiceValue;
//                     // Hide zero-value sections
//                     if (value == 0) {
//                       return PieChartSectionData(
//                         color: Colors.transparent,
//                         value: 0,
//                         title: '',
//                         radius: 0,
//                       );
//                     }
//                     return PieChartSectionData(
//                       color: sectionColors[i % sectionColors.length],
//                       value: value,
//                       title: '',
//                       radius: radius,
//                       titleStyle: TextStyle(
//                         fontSize: fontSize,
//                         fontWeight: FontWeight.bold,
//                         color: Colors.white,
//                       ),
//                       badgeWidget:
//                           isTouched
//                               ? _buildTooltip(region.region, value)
//                               : null,
//                       badgePositionPercentageOffset: 1.15,
//                     );
//                   }),
//                 ),
//               ),
//             ),
//             const SizedBox(height: 16),
//             // Legends
//             Wrap(
//               spacing: 8,
//               runSpacing: 4,
//               children: List.generate(chartData.length, (i) {
//                 final region = chartData[i];
//                 final isHighlighted = touchedIndex == i;
//                 return GestureDetector(
//                   onTap: () {
//                     setState(() {
//                       touchedIndex = i;
//                     });
//                   },
//                   child: AnimatedContainer(
//                     duration: const Duration(milliseconds: 150),
//                     padding: const EdgeInsets.all(2.0),
//                     decoration: BoxDecoration(
//                       color:
//                           isHighlighted
//                               ? sectionColors[i % sectionColors.length]
//                                   .withValues(alpha: (0.15 * 255))
//                               : Colors.transparent,
//                       borderRadius: BorderRadius.circular(8),
//                     ),
//                     child: Row(
//                       mainAxisSize: MainAxisSize.min,
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         Container(
//                           width: 14,
//                           height: 14,
//                           decoration: BoxDecoration(
//                             shape: BoxShape.circle,
//                             color: sectionColors[i % sectionColors.length],
//                             border: Border.all(
//                               color:
//                                   isHighlighted
//                                       ? Colors.black
//                                       : Colors.transparent,
//                               width: 1.5,
//                             ),
//                           ),
//                         ),
//                         const SizedBox(width: 4),
//                         Text(
//                           region.region,
//                           style: TextStyle(
//                             fontWeight:
//                                 isHighlighted
//                                     ? FontWeight.bold
//                                     : FontWeight.normal,
//                             color:
//                                 isHighlighted ? Colors.black : Colors.grey[800],
//                             fontSize: 12,
//                           ),
//                         ),
//                         const SizedBox(width: 2),
//                         Text(
//                           '(${intl.NumberFormat.currency(locale: 'en_IN', symbol: "").format(region.totalInvoiceValue)})',
//                           style: TextStyle(
//                             color: Colors.grey[600],
//                             fontSize: 10,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 );
//               }),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildTooltip(String name, double value) {
//     final double screenWidth = MediaQuery.of(context).size.width;
//     final double maxTooltipWidth = screenWidth * 0.4;

//     return Card(
//       color: Colors.white,
//       elevation: 4,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
//       child: ConstrainedBox(
//         constraints: BoxConstraints(maxWidth: maxTooltipWidth),
//         child: Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//           child: Text(
//             'Region: $name\nTotal Invoice Value: ${intl.NumberFormat.currency(locale: 'en_IN', symbol: "").format(value)}',
//             textAlign: TextAlign.center,
//             softWrap: true,
//             style: const TextStyle(
//               color: Colors.black87,
//               fontWeight: FontWeight.bold,
//               fontSize: 11,
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart' as intl;

// --- Region Model ---
class RegionData {
  final String code;
  final String region;
  final double totalInvoiceValue;

  RegionData({
    required this.code,
    required this.region,
    required this.totalInvoiceValue,
  });

  factory RegionData.fromMap(Map<String, dynamic> map) {
    return RegionData(
      code: (map['code'] ?? '').toString(),
      region: (map['region'] ?? '').toString(),
      totalInvoiceValue: (map['totalinvoicevalue'] ?? 0).toDouble(),
    );
  }
}

// --- Main Widget ---
class RegionPieChartCard extends StatefulWidget {
  final List<RegionData> regions;
  const RegionPieChartCard({super.key, required this.regions});

  @override
  State<RegionPieChartCard> createState() => _RegionPieChartCardState();
}

class _RegionPieChartCardState extends State<RegionPieChartCard> {
  int? touchedIndex;

  final List<Color> sectionColors = [
    Colors.blue,
    Colors.red,
    Colors.green,
    Colors.orange,
    Colors.purple,
    Colors.teal,
    Colors.brown,
    Colors.pink,
    Colors.indigo,
    // Add more if needed
  ];

  // Sorted list getter (by value descending)
  List<RegionData> get sortedRegions {
    final sorted = List<RegionData>.from(widget.regions)
      ..sort((a, b) => b.totalInvoiceValue.compareTo(a.totalInvoiceValue));
    return sorted;
  }

  @override
  Widget build(BuildContext context) {
    final chartData = sortedRegions;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.only(bottom: 4, top: 4),
              child: Text(
                'Region List',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            GestureDetector(
              // Tapping outside the chart will clear the highlight
              onTap: () {
                setState(() {
                  touchedIndex = null;
                });
              },
              child: AspectRatio(
                aspectRatio: 1.5,
                child: PieChart(
                  PieChartData(
                    sectionsSpace: 1,
                    centerSpaceRadius: 40,
                    pieTouchData: PieTouchData(
                      touchCallback: (FlTouchEvent event, pieTouchResponse) {
                        setState(() {
                          if (event is FlTapUpEvent &&
                              pieTouchResponse != null &&
                              pieTouchResponse.touchedSection != null) {
                            touchedIndex =
                                pieTouchResponse
                                    .touchedSection!
                                    .touchedSectionIndex;
                          } else if (event is FlTapUpEvent) {
                            touchedIndex = null;
                          }
                        });
                      },
                    ),
                    sections: List.generate(chartData.length, (i) {
                      final isTouched = i == touchedIndex;
                      final double fontSize = isTouched ? 15 : 12;
                      final double radius = isTouched ? 60 : 50;
                      final region = chartData[i];
                      final value = region.totalInvoiceValue;
                      // Hide zero-value sections
                      if (value == 0) {
                        return PieChartSectionData(
                          color: Colors.transparent,
                          value: 0,
                          title: '',
                          radius: 0,
                        );
                      }
                      return PieChartSectionData(
                        color: sectionColors[i % sectionColors.length],
                        value: value,
                        title: '',
                        radius: radius,
                        titleStyle: TextStyle(
                          fontSize: fontSize,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        badgeWidget:
                            isTouched
                                ? _buildTooltip(region.region, value)
                                : null,
                        badgePositionPercentageOffset: 1.15,
                      );
                    }),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 36),
            // Legends
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: List.generate(chartData.length, (i) {
                final region = chartData[i];
                final isHighlighted = touchedIndex == i;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      // Toggle highlight: tap again to unselect
                      touchedIndex = isHighlighted ? null : i;
                    });
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    padding: const EdgeInsets.all(2.0),
                    decoration: BoxDecoration(
                      color:
                          isHighlighted
                              ? sectionColors[i % sectionColors.length]
                                  .withOpacity(0.15)
                              : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 14,
                          height: 14,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: sectionColors[i % sectionColors.length],
                            border: Border.all(
                              color:
                                  isHighlighted
                                      ? Colors.black
                                      : Colors.transparent,
                              width: 1.5,
                            ),
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          region.region,
                          style: TextStyle(
                            fontWeight:
                                isHighlighted
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                            color:
                                isHighlighted ? Colors.black : Colors.grey[800],
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(width: 2),
                        Text(
                          '(${intl.NumberFormat.currency(locale: 'en_IN', symbol: "").format(region.totalInvoiceValue)})',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTooltip(String name, double value) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double maxTooltipWidth = screenWidth * 0.4;

    return Card(
      color: Colors.white,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxTooltipWidth),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Text(
            'Region: $name\nTotal Invoice Value: ${intl.NumberFormat.currency(locale: 'en_IN', symbol: "").format(value)}',
            textAlign: TextAlign.center,
            softWrap: true,
            style: const TextStyle(
              color: Colors.black87,
              fontWeight: FontWeight.bold,
              fontSize: 11,
            ),
          ),
        ),
      ),
    );
  }
}
