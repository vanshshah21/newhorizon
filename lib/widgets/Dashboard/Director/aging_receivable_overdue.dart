import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart' as intl;

class AgingReceivableStackedBarChartCard extends StatefulWidget {
  const AgingReceivableStackedBarChartCard({
    super.key,
    required this.chartData,
  });

  final List<Map<String, dynamic>> chartData;

  @override
  State<AgingReceivableStackedBarChartCard> createState() =>
      _AgingReceivableStackedBarChartCardState();
}

class _AgingReceivableStackedBarChartCardState
    extends State<AgingReceivableStackedBarChartCard> {
  final Map<String, Color> stackColors = {
    "P": Colors.blue,
    "O": Colors.orange,
    "V": Colors.green,
  };
  final Map<String, String> stackLabels = {
    "P": "Product Spare",
    "O": "Others",
    "V": "Services",
  };

  Set<String> visibleStacks = {"P", "O", "V"};
  int? touchedIndex;

  double parseAmount(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    return double.tryParse(value.toString()) ?? 0.0;
  }

  double getMaxY() {
    double maxY = 0;
    for (final data in widget.chartData) {
      double sum = 0;
      for (final key in stackColors.keys) {
        if (visibleStacks.contains(key)) {
          sum += parseAmount(data[key]);
        }
      }
      if (sum > maxY) maxY = sum;
    }
    return maxY * 1.2;
  }

  double getYAxisReservedSize(double maxY) {
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

  Widget buildLegend() {
    final stackKeys = stackColors.keys.toList();
    return Padding(
      padding: const EdgeInsets.only(top: 16.0),
      child: Center(
        child: Wrap(
          alignment: WrapAlignment.center,
          spacing: 24,
          runSpacing: 8,
          children:
              stackKeys
                  .map(
                    (key) => GestureDetector(
                      onTap: () {
                        setState(() {
                          if (visibleStacks.contains(key)) {
                            if (visibleStacks.length > 1) {
                              visibleStacks.remove(key);
                            }
                          } else {
                            visibleStacks.add(key);
                          }
                        });
                      },
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 16,
                            height: 16,
                            decoration: BoxDecoration(
                              color:
                                  visibleStacks.contains(key)
                                      ? stackColors[key]
                                      : stackColors[key]!.withValues(
                                        alpha: (0.2 * 255),
                                      ),
                              border: Border.all(
                                color: stackColors[key]!,
                                width: 2,
                              ),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            stackLabels[key]!,
                            style: TextStyle(
                              fontWeight:
                                  visibleStacks.contains(key)
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                              color:
                                  visibleStacks.contains(key)
                                      ? Colors.black
                                      : Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                  .toList(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final stackKeys = stackColors.keys.toList();
    final maxY = getMaxY();
    final yAxisReservedSize = getYAxisReservedSize(maxY);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.only(bottom: 16, top: 16),
              child: Text(
                'Aging Receivable Overdue',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 340,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: maxY == 0 ? 1 : maxY,
                  barTouchData: BarTouchData(
                    enabled: true,
                    touchTooltipData: BarTouchTooltipData(
                      fitInsideHorizontally: true,
                      fitInsideVertically: true,
                      getTooltipColor: (group) => Colors.white,
                      tooltipPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      tooltipRoundedRadius: 8,
                      tooltipBorder: BorderSide.none,
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        final data = widget.chartData[group.x.toInt()];
                        List<String> lines = [];
                        for (final key in stackKeys) {
                          if (!visibleStacks.contains(key)) continue;
                          final value = parseAmount(data[key]);
                          if (value > 0) {
                            lines.add(
                              '${stackLabels[key]}: ${intl.NumberFormat.currency(locale: 'en_IN', symbol: "").format(value)} ',
                            );
                          }
                        }
                        if (lines.isEmpty) {
                          lines.add('No data');
                        }
                        return BarTooltipItem(
                          'Day Range: ${data['dayrange']}\n${lines.join('\n')}',
                          const TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        );
                      },
                    ),
                    touchCallback: (event, response) {
                      setState(() {
                        if (event is FlTapUpEvent &&
                            response != null &&
                            response.spot != null) {
                          touchedIndex = response.spot!.touchedBarGroupIndex;
                        } else if (event is FlTapUpEvent) {
                          touchedIndex = null;
                        }
                      });
                    },
                  ),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      axisNameSize: 40,
                      axisNameWidget: Text(
                        'Amount in Lakhs',
                        style: TextStyle(fontSize: 12, color: Colors.black87),
                      ),
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: yAxisReservedSize,
                        getTitlesWidget: (value, meta) {
                          if (value == 0) {
                            return SideTitleWidget(
                              meta: meta,
                              child: Text('0'),
                            );
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
                        },
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      axisNameSize: 35,
                      axisNameWidget: const Text(
                        'Day Range',
                        style: TextStyle(fontSize: 12),
                      ),
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          final idx = value.toInt();
                          if (idx < 0 || idx >= widget.chartData.length) {
                            return const SizedBox.shrink();
                          }
                          final label =
                              widget.chartData[idx]['dayrange'] as String? ??
                              '';
                          final isSelected = touchedIndex == idx;
                          return SideTitleWidget(
                            space: 8,
                            meta: meta,
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  touchedIndex = idx;
                                });
                              },
                              child: Text(
                                label,
                                style: TextStyle(
                                  fontWeight:
                                      isSelected
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                  color:
                                      isSelected
                                          ? Colors.blueAccent[700]
                                          : Colors.black87,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          );
                        },
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
                  barGroups: List.generate(widget.chartData.length, (idx) {
                    final data = widget.chartData[idx];
                    double runningTotal = 0;
                    final isSelected = touchedIndex == idx;
                    List<BarChartRodStackItem> stacks = [];
                    for (final key in stackKeys) {
                      if (!visibleStacks.contains(key)) continue;
                      final value = parseAmount(data[key]);
                      if (value > 0) {
                        stacks.add(
                          BarChartRodStackItem(
                            runningTotal,
                            runningTotal + value,
                            stackColors[key]!,
                          ),
                        );
                        runningTotal += value;
                      }
                    }
                    if (stacks.isEmpty) {
                      return BarChartGroupData(
                        x: idx,
                        barRods: [
                          BarChartRodData(
                            toY: 0,
                            rodStackItems: [],
                            width: 22,
                            borderRadius: BorderRadius.circular(0),
                            backDrawRodData: BackgroundBarChartRodData(
                              show: true,
                              toY: 0,
                              color: Colors.grey[200],
                            ),
                          ),
                        ],
                        showingTooltipIndicators: [],
                      );
                    }
                    return BarChartGroupData(
                      x: idx,
                      barRods: [
                        BarChartRodData(
                          toY: runningTotal,
                          rodStackItems: stacks,
                          width: 22,
                          borderRadius: BorderRadius.circular(0),
                          backDrawRodData: BackgroundBarChartRodData(
                            show: true,
                            toY: 0,
                            color: Colors.grey[200],
                          ),
                        ),
                      ],
                      showingTooltipIndicators: isSelected ? [0] : [],
                    );
                  }),
                ),
              ),
            ),
            buildLegend(),
          ],
        ),
      ),
    );
  }
}
