import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class DispatchAmountByMonthsChart extends StatefulWidget {
  const DispatchAmountByMonthsChart({
    super.key,
    required this.chartdata,
    required this.seriesdata,
  });

  final List<Map<String, dynamic>> chartdata;
  final List<Map<String, dynamic>> seriesdata;

  @override
  State<DispatchAmountByMonthsChart> createState() =>
      _DispatchAmountByMonthsChartState();
}

class _DispatchAmountByMonthsChartState
    extends State<DispatchAmountByMonthsChart> {
  final List<Color> seriesColors = [Colors.blue, Colors.orange, Colors.green];

  int? touchedIndex;
  int? touchedRodIndex;
  Set<String> visibleSeries = {};

  @override
  void initState() {
    super.initState();
    visibleSeries =
        widget.seriesdata.map((e) => e['dataField'] as String).toSet();
  }

  double parseAmount(dynamic value) {
    if (value == null) return 0;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString()) ?? 0;
  }

  double getMaxY() {
    double maxY = 0;
    for (var month in widget.chartdata) {
      for (var i = 0; i < widget.seriesdata.length; i++) {
        final key = widget.seriesdata[i]['dataField'];
        if (!visibleSeries.contains(key)) continue;
        final value = parseAmount(month[key]);
        if (value > maxY) maxY = value;
      }
    }
    maxY *= 1.1;
    if (maxY == 0) maxY = 1;
    return maxY;
  }

  double getYAxisReservedSize(double maxY) {
    final maxLabelValue = (maxY / 10000000).ceil(); // in Crores
    final maxLabelString = '$maxLabelValue Cr';

    final textPainter = TextPainter(
      text: TextSpan(
        text: maxLabelString,
        style: const TextStyle(fontSize: 12),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    return textPainter.width + 12; // add padding
  }

  @override
  Widget build(BuildContext context) {
    final maxY = getMaxY();
    final yAxisReservedSize = getYAxisReservedSize(maxY);

    return Card(
      margin: const EdgeInsets.all(8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: const [
                Text(
                  'Dispatch Amount By Months',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            AspectRatio(
              aspectRatio: 0.6,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: BarChart(
                  BarChartData(
                    alignment: BarChartAlignment.spaceBetween,
                    maxY: maxY,
                    barGroups: List.generate(widget.chartdata.length, (
                      groupIndex,
                    ) {
                      final month = widget.chartdata[groupIndex];
                      final rods = <BarChartRodData>[];
                      for (
                        int seriesIndex = 0;
                        seriesIndex < widget.seriesdata.length;
                        seriesIndex++
                      ) {
                        final key = widget.seriesdata[seriesIndex]['dataField'];
                        if (!visibleSeries.contains(key)) continue;
                        final value = parseAmount(month[key]);
                        rods.add(
                          BarChartRodData(
                            toY: value,
                            color: seriesColors[seriesIndex],
                            width: 12,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        );
                      }
                      return BarChartGroupData(
                        x: groupIndex,
                        barRods: rods,
                        barsSpace: 1,
                        showingTooltipIndicators:
                            touchedIndex == groupIndex
                                ? [touchedRodIndex ?? 0]
                                : [],
                      );
                    }),
                    titlesData: FlTitlesData(
                      show: true,
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: yAxisReservedSize,
                          getTitlesWidget: (value, meta) {
                            if (value == 0) return const Text('0');
                            if (value % 10000000 == 0 && value != 0) {
                              return Text(
                                '${(value / 10000000).toStringAsFixed(1)} Cr',
                                style: const TextStyle(fontSize: 12),
                              );
                            } else if (value % 100000 == 0 && value != 0) {
                              return Text(
                                '${(value / 100000).toStringAsFixed(1)} L',
                                style: const TextStyle(fontSize: 12),
                              );
                            } else if (value % 1000 == 0 && value != 0) {
                              return Text(
                                value.toStringAsFixed(0),
                                style: const TextStyle(fontSize: 12),
                              );
                            }
                            return const SizedBox.shrink();
                          },
                        ),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 40,
                          getTitlesWidget: (value, meta) {
                            final index = value.toInt();
                            if (index < 0 || index >= widget.chartdata.length) {
                              return const SizedBox.shrink();
                            }
                            return SideTitleWidget(
                              meta: meta,
                              child: Text(
                                widget.chartdata[index]['month'] ?? '',
                                style: const TextStyle(fontSize: 10),
                              ),
                            );
                          },
                        ),
                      ),
                      rightTitles: const AxisTitles(),
                      topTitles: const AxisTitles(),
                    ),
                    gridData: FlGridData(
                      show: true,
                      drawVerticalLine: false,
                      getDrawingHorizontalLine:
                          (value) => FlLine(
                            color: Colors.grey.withValues(alpha: (0.2 * 255)),
                            strokeWidth: 1,
                          ),
                    ),
                    borderData: FlBorderData(
                      show: true,
                      border: const Border(
                        left: BorderSide(color: Colors.black12),
                        bottom: BorderSide(color: Colors.black12),
                      ),
                    ),
                    barTouchData: BarTouchData(
                      enabled: true,
                      handleBuiltInTouches: false,
                      touchTooltipData: BarTouchTooltipData(
                        fitInsideVertically: true,
                        getTooltipColor: (group) => Colors.white,
                        tooltipPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        tooltipRoundedRadius: 8,
                        tooltipBorder: BorderSide.none,
                        getTooltipItem: (group, groupIndex, rod, rodIndex) {
                          final data = widget.chartdata[group.x.toInt()];
                          List<String> lines = [];
                          for (int i = 0; i < widget.seriesdata.length; i++) {
                            final key = widget.seriesdata[i]['dataField'];
                            if (!visibleSeries.contains(key)) continue;
                            final value = parseAmount(data[key]);
                            if (value > 0) {
                              lines.add(
                                '${widget.seriesdata[i]['displayText']}: ${value.toStringAsFixed(2)}',
                              );
                            }
                          }
                          if (lines.isEmpty) {
                            lines.add('No data');
                          }
                          return BarTooltipItem(
                            '${data['month']}\n${lines.join('\n')}',
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
                            touchedRodIndex =
                                response.spot!.touchedRodDataIndex;
                          } else if (event is FlTapUpEvent) {
                            touchedIndex = null;
                            touchedRodIndex = null;
                          }
                        });
                      },
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Wrap(
                alignment: WrapAlignment.center,
                spacing: 16,
                runSpacing: 8,
                children: List.generate(widget.seriesdata.length, (i) {
                  final key = widget.seriesdata[i]['dataField'];
                  final isActive = visibleSeries.contains(key);
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        if (isActive) {
                          if (visibleSeries.length > 1) {
                            visibleSeries.remove(key);
                          }
                        } else {
                          visibleSeries.add(key);
                        }
                        touchedIndex = null;
                        touchedRodIndex = null;
                      });
                    },
                    child: Opacity(
                      opacity: isActive ? 1.0 : 0.4,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 16,
                            height: 16,
                            decoration: BoxDecoration(
                              color: seriesColors[i],
                              border: Border.all(
                                color:
                                    isActive
                                        ? Colors.black
                                        : Colors.grey.shade400,
                                width: 2,
                              ),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            widget.seriesdata[i]['displayText'],
                            style: const TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
