// import 'package:fl_chart/fl_chart.dart';
// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart' as intl;

// // --- Salesperson Model ---
// class SalespersonData {
//   final String code;
//   final String name;
//   final double totalInvoiceValue;

//   SalespersonData({
//     required this.code,
//     required this.name,
//     required this.totalInvoiceValue,
//   });

//   factory SalespersonData.fromMap(Map<String, dynamic> map) {
//     return SalespersonData(
//       code: (map['salesmanCode'] ?? '').toString(),
//       name: (map['salesperson'] ?? '').toString(),
//       totalInvoiceValue: (map['totalinvoicevalue'] ?? 0).toDouble(),
//     );
//   }
// }

// // --- Main Widget ---
// class SalespersonPieChartCard extends StatefulWidget {
//   final List<SalespersonData> salespeople;
//   const SalespersonPieChartCard({super.key, required this.salespeople});

//   @override
//   State<SalespersonPieChartCard> createState() =>
//       _SalespersonPieChartCardState();
// }

// class _SalespersonPieChartCardState extends State<SalespersonPieChartCard> {
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
//     Colors.cyan,
//     Colors.amber,
//     Colors.deepOrange,
//     Colors.lime,
//     Colors.deepPurple,
//     Colors.lightBlue,
//     Colors.lightGreen,
//     Colors.yellow,
//     Colors.grey,
//     Colors.blueGrey,
//     Colors.black,
//     // Add more if needed
//   ];

//   // Sorted list getter (by value descending)
//   List<SalespersonData> get sortedSalespeople {
//     final sorted = List<SalespersonData>.from(widget.salespeople)
//       ..sort((a, b) => b.totalInvoiceValue.compareTo(a.totalInvoiceValue));
//     return sorted;
//   }

//   @override
//   Widget build(BuildContext context) {
//     final chartData = sortedSalespeople;

//     return Card(
//       child: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             const Padding(
//               padding: EdgeInsets.only(bottom: 4, top: 4),
//               child: Text(
//                 'Salesperson List',
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
//                     final salesperson = chartData[i];
//                     final value = salesperson.totalInvoiceValue;
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
//                               ? _buildTooltip(salesperson.name, value)
//                               : null,
//                       badgePositionPercentageOffset: 1.15,
//                     );
//                   }),
//                 ),
//               ),
//             ),
//             // Add more space between chart and legends to avoid overlap
//             const SizedBox(height: 24),
//             // Legends
//             Wrap(
//               spacing: 8,
//               runSpacing: 4,
//               children: List.generate(chartData.length, (i) {
//                 final salesperson = chartData[i];
//                 final isHighlighted = touchedIndex == i;
//                 return GestureDetector(
//                   onTap: () {
//                     setState(() {
//                       // Toggle highlight: tap again to unselect
//                       touchedIndex = isHighlighted ? null : i;
//                     });
//                   },
//                   child: AnimatedContainer(
//                     duration: const Duration(milliseconds: 150),
//                     padding: const EdgeInsets.all(2.0),
//                     decoration: BoxDecoration(
//                       color:
//                           isHighlighted
//                               ? sectionColors[i % sectionColors.length]
//                                   .withOpacity(0.15)
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
//                           salesperson.name,
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
//                           '(${intl.NumberFormat.currency(locale: 'en_IN', symbol: "").format(salesperson.totalInvoiceValue)})',
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
//       child: ConstrainedBox(
//         constraints: BoxConstraints(maxWidth: maxTooltipWidth),
//         child: Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//           child: Text(
//             'Sales Person: $name\nTotal Invoice Value: ${intl.NumberFormat.currency(locale: 'en_IN', symbol: "").format(value)}',
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

// --- Salesperson Model ---
class SalespersonData {
  final String code;
  final String name;
  final double totalInvoiceValue;

  SalespersonData({
    required this.code,
    required this.name,
    required this.totalInvoiceValue,
  });

  factory SalespersonData.fromMap(Map<String, dynamic> map) {
    return SalespersonData(
      code: (map['salesmanCode'] ?? '').toString(),
      name: (map['salesperson'] ?? '').toString(),
      totalInvoiceValue: (map['totalinvoicevalue'] ?? 0).toDouble(),
    );
  }
}

// --- Main Widget ---
class SalespersonPieChartCard extends StatefulWidget {
  final List<SalespersonData> salespeople;
  const SalespersonPieChartCard({super.key, required this.salespeople});

  @override
  State<SalespersonPieChartCard> createState() =>
      _SalespersonPieChartCardState();
}

class _SalespersonPieChartCardState extends State<SalespersonPieChartCard> {
  int? touchedIndex;

  // Dropdown options
  final List<int?> _limitOptions = [10, 20, null]; // null = All
  int? _selectedLimit = 10;

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
    Colors.cyan,
    Colors.amber,
    Colors.deepOrange,
    Colors.lime,
    Colors.deepPurple,
    Colors.lightBlue,
    Colors.lightGreen,
    Colors.yellow,
    Colors.grey,
    Colors.blueGrey,
    Colors.black,
    // Add more if needed
  ];

  // Sorted list getter (by value descending)
  List<SalespersonData> get sortedSalespeople {
    final sorted = List<SalespersonData>.from(widget.salespeople)
      ..sort((a, b) => b.totalInvoiceValue.compareTo(a.totalInvoiceValue));
    if (_selectedLimit != null && _selectedLimit! < sorted.length) {
      return sorted.take(_selectedLimit!).toList();
    }
    return sorted;
  }

  @override
  Widget build(BuildContext context) {
    final chartData = sortedSalespeople;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Dropdown and Title Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Salesperson List',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                DropdownButton<int?>(
                  value: _selectedLimit,
                  items: [
                    DropdownMenuItem(value: 10, child: const Text('Top 10')),
                    DropdownMenuItem(value: 20, child: const Text('Top 20')),
                    DropdownMenuItem(value: null, child: const Text('All')),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedLimit = value;
                      touchedIndex = null; // Reset highlight on filter change
                    });
                  },
                  underline: Container(),
                  style: const TextStyle(fontSize: 14, color: Colors.black),
                ),
              ],
            ),
            AspectRatio(
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
                    final salesperson = chartData[i];
                    final value = salesperson.totalInvoiceValue;
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
                              ? _buildTooltip(salesperson.name, value)
                              : null,
                      badgePositionPercentageOffset: 1.15,
                    );
                  }),
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Legends
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: List.generate(chartData.length, (i) {
                final salesperson = chartData[i];
                final isHighlighted = touchedIndex == i;
                return GestureDetector(
                  onTap: () {
                    setState(() {
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
                          salesperson.name,
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
                          '(${intl.NumberFormat.currency(locale: 'en_IN', symbol: "").format(salesperson.totalInvoiceValue)})',
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
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxTooltipWidth),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Text(
            'Sales Person: $name\nTotal Invoice Value: ${intl.NumberFormat.currency(locale: 'en_IN', symbol: "").format(value)}',
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
