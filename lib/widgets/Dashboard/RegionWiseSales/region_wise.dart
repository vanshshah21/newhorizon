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
    final double maxTooltipWidth = screenWidth * 0.3;

    return Container(
      constraints: BoxConstraints(maxWidth: maxTooltipWidth, maxHeight: 60),
      child: Card(
        color: Colors.white,
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
          child: Text(
            'Region: $name\nTotal: ${intl.NumberFormat.currency(locale: 'en_IN', symbol: "").format(value)}',
            textAlign: TextAlign.center,
            softWrap: true,
            overflow: TextOverflow.ellipsis,
            maxLines: 10,
            style: const TextStyle(
              color: Colors.black87,
              fontWeight: FontWeight.bold,
              fontSize: 10,
            ),
          ),
        ),
      ),
    );
  }

  // @override
  // Widget build(BuildContext context) {
  //   final chartData = sortedRegions;

  //   return Container(
  //     decoration: BoxDecoration(
  //       gradient: LinearGradient(
  //         begin: Alignment.topLeft,
  //         end: Alignment.bottomRight,
  //         colors: [Colors.white, Colors.grey.shade50],
  //       ),
  //       borderRadius: BorderRadius.circular(20),
  //       boxShadow: [
  //         BoxShadow(
  //           color: Colors.grey.withOpacity(0.15),
  //           spreadRadius: 0,
  //           blurRadius: 20,
  //           offset: const Offset(0, 4),
  //         ),
  //       ],
  //       border: Border.all(color: Colors.grey.shade200, width: 1),
  //     ),
  //     child: Padding(
  //       padding: const EdgeInsets.all(24),
  //       child: Column(
  //         crossAxisAlignment: CrossAxisAlignment.start,
  //         children: [
  //           // Header Section
  //           Container(
  //             padding: const EdgeInsets.only(bottom: 16),
  //             decoration: BoxDecoration(
  //               border: Border(
  //                 bottom: BorderSide(color: Colors.grey.shade200, width: 1),
  //               ),
  //             ),
  //             child: Row(
  //               children: [
  //                 Container(
  //                   padding: const EdgeInsets.all(8),
  //                   decoration: BoxDecoration(
  //                     color: Colors.blue.shade50,
  //                     borderRadius: BorderRadius.circular(12),
  //                   ),
  //                   child: Icon(
  //                     Icons.pie_chart,
  //                     color: Colors.blue.shade600,
  //                     size: 24,
  //                   ),
  //                 ),
  //                 const SizedBox(width: 12),
  //                 const Expanded(
  //                   child: Text(
  //                     'Region List',
  //                     style: TextStyle(
  //                       fontSize: 22,
  //                       fontWeight: FontWeight.bold,
  //                       color: Colors.black87,
  //                     ),
  //                   ),
  //                 ),
  //                 Container(
  //                   padding: const EdgeInsets.symmetric(
  //                     horizontal: 12,
  //                     vertical: 6,
  //                   ),
  //                   decoration: BoxDecoration(
  //                     color: Colors.green.shade50,
  //                     borderRadius: BorderRadius.circular(20),
  //                     border: Border.all(
  //                       color: Colors.green.shade200,
  //                       width: 1,
  //                     ),
  //                   ),
  //                   child: Text(
  //                     '${chartData.length} Regions',
  //                     style: TextStyle(
  //                       fontSize: 12,
  //                       fontWeight: FontWeight.w600,
  //                       color: Colors.green.shade700,
  //                     ),
  //                   ),
  //                 ),
  //               ],
  //             ),
  //           ),
  //           const SizedBox(height: 20),
  //           // Chart Section
  //           Container(
  //             padding: const EdgeInsets.all(16),
  //             decoration: BoxDecoration(
  //               color: Colors.white,
  //               borderRadius: BorderRadius.circular(16),
  //               boxShadow: [
  //                 BoxShadow(
  //                   color: Colors.grey.withOpacity(0.08),
  //                   spreadRadius: 0,
  //                   blurRadius: 10,
  //                   offset: const Offset(0, 2),
  //                 ),
  //               ],
  //             ),
  //             child: GestureDetector(
  //               // Tapping outside the chart will clear the highlight
  //               onTap: () {
  //                 setState(() {
  //                   touchedIndex = null;
  //                 });
  //               },
  //               child: AspectRatio(
  //                 aspectRatio: 1.5,
  //                 child: PieChart(
  //                   PieChartData(
  //                     sectionsSpace: 1,
  //                     centerSpaceRadius: 40,
  //                     pieTouchData: PieTouchData(
  //                       touchCallback: (FlTouchEvent event, pieTouchResponse) {
  //                         setState(() {
  //                           if (event is FlTapUpEvent &&
  //                               pieTouchResponse != null &&
  //                               pieTouchResponse.touchedSection != null) {
  //                             touchedIndex =
  //                                 pieTouchResponse
  //                                     .touchedSection!
  //                                     .touchedSectionIndex;
  //                           } else if (event is FlTapUpEvent) {
  //                             touchedIndex = null;
  //                           }
  //                         });
  //                       },
  //                     ),
  //                     sections: List.generate(chartData.length, (i) {
  //                       final isTouched = i == touchedIndex;
  //                       final double fontSize = isTouched ? 15 : 12;
  //                       final double radius = isTouched ? 60 : 50;
  //                       final region = chartData[i];
  //                       final value = region.totalInvoiceValue;
  //                       // Hide zero-value sections
  //                       if (value == 0) {
  //                         return PieChartSectionData(
  //                           color: Colors.transparent,
  //                           value: 0,
  //                           title: '',
  //                           radius: 0,
  //                         );
  //                       }
  //                       return PieChartSectionData(
  //                         color: sectionColors[i % sectionColors.length],
  //                         value: value,
  //                         title: '',
  //                         radius: radius,
  //                         titleStyle: TextStyle(
  //                           fontSize: fontSize,
  //                           fontWeight: FontWeight.bold,
  //                           color: Colors.white,
  //                         ),
  //                         badgeWidget:
  //                             isTouched
  //                                 ? _buildTooltip(region.region, value)
  //                                 : null,
  //                         badgePositionPercentageOffset: 0.9,
  //                       );
  //                     }),
  //                   ),
  //                 ),
  //               ),
  //             ),
  //           ),
  //           const SizedBox(height: 24),
  //           // Legends Section
  //           Container(
  //             padding: const EdgeInsets.all(16),
  //             decoration: BoxDecoration(
  //               color: Colors.grey.shade50,
  //               borderRadius: BorderRadius.circular(16),
  //               border: Border.all(color: Colors.grey.shade200, width: 1),
  //             ),
  //             child: Column(
  //               crossAxisAlignment: CrossAxisAlignment.start,
  //               children: [
  //                 Text(
  //                   'Legend',
  //                   style: TextStyle(
  //                     fontSize: 16,
  //                     fontWeight: FontWeight.w600,
  //                     color: Colors.grey.shade700,
  //                   ),
  //                 ),
  //                 const SizedBox(height: 12),
  //                 Wrap(
  //                   spacing: 12,
  //                   runSpacing: 8,
  //                   children: List.generate(chartData.length, (i) {
  //                     final region = chartData[i];
  //                     final isHighlighted = touchedIndex == i;
  //                     return GestureDetector(
  //                       onTap: () {
  //                         setState(() {
  //                           // Toggle highlight: tap again to unselect
  //                           touchedIndex = isHighlighted ? null : i;
  //                         });
  //                       },
  //                       child: AnimatedContainer(
  //                         duration: const Duration(milliseconds: 200),
  //                         padding: const EdgeInsets.symmetric(
  //                           horizontal: 12,
  //                           vertical: 8,
  //                         ),
  //                         decoration: BoxDecoration(
  //                           color:
  //                               isHighlighted
  //                                   ? sectionColors[i % sectionColors.length]
  //                                       .withOpacity(0.15)
  //                                   : Colors.white,
  //                           borderRadius: BorderRadius.circular(12),
  //                           border: Border.all(
  //                             color:
  //                                 isHighlighted
  //                                     ? sectionColors[i % sectionColors.length]
  //                                     : Colors.grey.shade300,
  //                             width: isHighlighted ? 2 : 1,
  //                           ),
  //                           boxShadow:
  //                               isHighlighted
  //                                   ? [
  //                                     BoxShadow(
  //                                       color: sectionColors[i %
  //                                               sectionColors.length]
  //                                           .withOpacity(0.2),
  //                                       spreadRadius: 0,
  //                                       blurRadius: 8,
  //                                       offset: const Offset(0, 2),
  //                                     ),
  //                                   ]
  //                                   : null,
  //                         ),
  //                         child: Row(
  //                           mainAxisSize: MainAxisSize.min,
  //                           children: [
  //                             Container(
  //                               width: 16,
  //                               height: 16,
  //                               decoration: BoxDecoration(
  //                                 shape: BoxShape.circle,
  //                                 color:
  //                                     sectionColors[i % sectionColors.length],
  //                                 boxShadow: [
  //                                   BoxShadow(
  //                                     color: sectionColors[i %
  //                                             sectionColors.length]
  //                                         .withOpacity(0.3),
  //                                     spreadRadius: 0,
  //                                     blurRadius: 4,
  //                                     offset: const Offset(0, 1),
  //                                   ),
  //                                 ],
  //                               ),
  //                             ),
  //                             const SizedBox(width: 8),
  //                             Flexible(
  //                               child: Column(
  //                                 crossAxisAlignment: CrossAxisAlignment.start,
  //                                 mainAxisSize: MainAxisSize.min,
  //                                 children: [
  //                                   Text(
  //                                     region.region,
  //                                     style: TextStyle(
  //                                       fontWeight:
  //                                           isHighlighted
  //                                               ? FontWeight.bold
  //                                               : FontWeight.w500,
  //                                       color:
  //                                           isHighlighted
  //                                               ? Colors.black
  //                                               : Colors.grey[800],
  //                                       fontSize: 13,
  //                                     ),
  //                                   ),
  //                                   Text(
  //                                     intl.NumberFormat.currency(
  //                                       locale: 'en_IN',
  //                                       symbol: "₹",
  //                                     ).format(region.totalInvoiceValue),
  //                                     style: TextStyle(
  //                                       color: Colors.grey[600],
  //                                       fontSize: 11,
  //                                       fontWeight: FontWeight.w400,
  //                                     ),
  //                                   ),
  //                                 ],
  //                               ),
  //                             ),
  //                           ],
  //                         ),
  //                       ),
  //                     );
  //                   }),
  //                 ),
  //               ],
  //             ),
  //           ),
  //         ],
  //       ),
  //     ),
  //   );
  // }

  // Widget _buildTooltip(String name, double value) {
  //   return Container(
  //     constraints: const BoxConstraints(maxWidth: 200, maxHeight: 80),
  //     child: Container(
  //       padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
  //       decoration: BoxDecoration(
  //         color: Colors.white,
  //         borderRadius: BorderRadius.circular(12),
  //         boxShadow: [
  //           BoxShadow(
  //             color: Colors.black.withOpacity(0.15),
  //             spreadRadius: 0,
  //             blurRadius: 10,
  //             offset: const Offset(0, 4),
  //           ),
  //         ],
  //         border: Border.all(color: Colors.grey.shade200, width: 1),
  //       ),
  //       child: Column(
  //         mainAxisSize: MainAxisSize.min,
  //         children: [
  //           Text(
  //             name,
  //             textAlign: TextAlign.center,
  //             overflow: TextOverflow.ellipsis,
  //             style: const TextStyle(
  //               color: Colors.black87,
  //               fontWeight: FontWeight.bold,
  //               fontSize: 12,
  //             ),
  //           ),
  //           const SizedBox(height: 4),
  //           Text(
  //             intl.NumberFormat.currency(
  //               locale: 'en_IN',
  //               symbol: "₹",
  //             ).format(value),
  //             textAlign: TextAlign.center,
  //             style: TextStyle(
  //               color: Colors.grey[700],
  //               fontWeight: FontWeight.w500,
  //               fontSize: 11,
  //             ),
  //           ),
  //         ],
  //       ),
  //     ),
  //   );
  // }
}
