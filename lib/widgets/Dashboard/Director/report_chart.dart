import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart' as intl;

// --- Status Model ---
class ReportData {
  final String code;
  final int total;
  final double amount;

  ReportData({required this.code, required this.total, required this.amount});

  factory ReportData.fromMap(Map<String, dynamic> map) {
    return ReportData(
      code: (map['code'] ?? '').toString(),
      total: (map['total'] ?? 0) as int,
      amount: (map['amount'] ?? 0) as double,
    );
  }
}

// --- Main Widget ---
class ReportPieChartCard extends StatefulWidget {
  final List<ReportData> statuses;
  const ReportPieChartCard({super.key, required this.statuses});

  @override
  State<ReportPieChartCard> createState() => _ReportPieChartCardState();
}

class _ReportPieChartCardState extends State<ReportPieChartCard> {
  int? touchedIndex;

  final List<Color> sectionColors = [
    Colors.blue,
    Colors.red,
    Colors.green,
    Colors.orange,
    // Add more if needed
  ];

  // Sorted list getter (by total descending)
  List<ReportData> get sortedStatuses {
    final sorted = List<ReportData>.from(widget.statuses)
      ..sort((a, b) => b.total.compareTo(a.total));
    return sorted;
  }

  @override
  Widget build(BuildContext context) {
    final chartData = sortedStatuses;
    // final double totalAmount = chartData.fold(
    //   0,
    //   (sum, item) => sum + item.amount,
    // );

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
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
                    final status = chartData[i];
                    final value = status.total;
                    // Hide zero-amount sections
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
                      value: value.toDouble(),
                      title: '',
                      radius: radius,
                      titleStyle: TextStyle(
                        fontSize: fontSize,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      badgeWidget:
                          isTouched
                              ? _buildTooltip(
                                status.code,
                                value.toDouble(),
                                status.amount,
                              )
                              : null,
                    );
                  }),
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Legends
            // Wrap(
            //   spacing: 8,
            //   runSpacing: 4,
            //   children: List.generate(chartData.length, (i) {
            //     final status = chartData[i];
            //     final isHighlighted = touchedIndex == i;
            //     return GestureDetector(
            //       onTap: () {
            //         setState(() {
            //           touchedIndex = i;
            //         });
            //       },
            //       child: AnimatedContainer(
            //         duration: const Duration(milliseconds: 150),
            //         padding: const EdgeInsets.all(2.0),
            //         decoration: BoxDecoration(
            //           color:
            //               isHighlighted
            //                   ? sectionColors[i % sectionColors.length]
            //                       .withValues(alpha: (0.15 * 255))
            //                   : Colors.transparent,
            //           borderRadius: BorderRadius.circular(8),
            //         ),
            //         child: Row(
            //           mainAxisSize: MainAxisSize.min,
            //           mainAxisAlignment: MainAxisAlignment.center,
            //           children: [
            //             Container(
            //               width: 14,
            //               height: 14,
            //               decoration: BoxDecoration(
            //                 shape: BoxShape.circle,
            //                 color: sectionColors[i % sectionColors.length],
            //                 border: Border.all(
            //                   color:
            //                       isHighlighted
            //                           ? Colors.black
            //                           : Colors.transparent,
            //                   width: 1.5,
            //                 ),
            //               ),
            //             ),
            //             const SizedBox(width: 4),
            //             Text(
            //               status.code,
            //               style: TextStyle(
            //                 fontWeight:
            //                     isHighlighted
            //                         ? FontWeight.bold
            //                         : FontWeight.normal,
            //                 color:
            //                     isHighlighted ? Colors.black : Colors.grey[800],
            //                 fontSize: 12,
            //               ),
            //             ),
            //             const SizedBox(width: 2),
            //             Text(
            //               '(${intl.NumberFormat.currency(locale: 'en_IN', symbol: "").format(status.total)})',
            //               style: TextStyle(
            //                 color: Colors.grey[600],
            //                 fontSize: 10,
            //               ),
            //             ),
            //           ],
            //         ),
            //       ),
            //     );
            //   }),
            // ),
            // ...existing code...
            const SizedBox(height: 24),
            // Legends Section - Updated to match sales_person style
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
                          region.code,
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
                          '(${intl.NumberFormat.currency(locale: 'en_IN', symbol: "").format(region.total)})',
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
            // ...existing code...
          ],
        ),
      ),
    );
  }

  Widget _buildTooltip(String name, double value, double amount) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double maxTooltipWidth = screenWidth * 0.4;

    return Card(
      color: Colors.white,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxTooltipWidth),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Text(
            'Code: $name\nValue: $value\nAmount: ${intl.NumberFormat.currency(locale: 'en_IN', symbol: "").format(amount)}',
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
