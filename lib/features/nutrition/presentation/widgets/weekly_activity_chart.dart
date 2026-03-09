import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/daily_total.dart';

enum NutritionMetric { calories, protein, carbs, fats }

class WeeklyActivityChart extends StatefulWidget {
  final List<DailyTotal> dailyTotals;
  final bool hideNutritionValues;

  const WeeklyActivityChart({
    required this.dailyTotals,
    required this.hideNutritionValues,
    super.key,
  });

  @override
  State<WeeklyActivityChart> createState() => _WeeklyActivityChartState();
}

class _WeeklyActivityChartState extends State<WeeklyActivityChart> {
  NutritionMetric _selectedMetric = NutritionMetric.calories;

  @override
  void initState() {
    super.initState();
    if (widget.hideNutritionValues) {
      _selectedMetric = NutritionMetric.protein;
    }
  }

  @override
  void didUpdateWidget(WeeklyActivityChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.hideNutritionValues && !oldWidget.hideNutritionValues) {
      setState(() {
        _selectedMetric = NutritionMetric.protein;
      });
    }
  }

  String _abbreviate(String text, int maxLength) {
    if (text.length <= maxLength) return text;
    return text.substring(0, maxLength);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.dailyTotals.isEmpty) {
      return const SizedBox.shrink();
    }

    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).toString();
    final maxVal = _getMaxValue();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              l10n.weeklyActivityTitle,
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (!widget.hideNutritionValues) ...[
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SegmentedButton<NutritionMetric>(
              segments: [
                ButtonSegment(
                  value: NutritionMetric.calories,
                  label: Text(_abbreviate(l10n.metricCalories, 3)),
                  icon: const Icon(Icons.local_fire_department, size: 16),
                ),
                ButtonSegment(
                  value: NutritionMetric.protein,
                  label: Text(_abbreviate(l10n.metricProtein, 3)),
                  icon: const Icon(Icons.fitness_center, size: 16),
                ),
                ButtonSegment(
                  value: NutritionMetric.carbs,
                  label: Text(_abbreviate(l10n.metricCarbs, 3)),
                  icon: const Icon(Icons.grass, size: 16),
                ),
                ButtonSegment(
                  value: NutritionMetric.fats,
                  label: Text(_abbreviate(l10n.metricFat, 3)),
                  icon: const Icon(Icons.water_drop, size: 16),
                ),
              ],
              selected: {_selectedMetric},
              onSelectionChanged: (Set<NutritionMetric> newSelection) {
                setState(() {
                  _selectedMetric = newSelection.first;
                });
              },
              showSelectedIcon: false,
              style: SegmentedButton.styleFrom(
                visualDensity: VisualDensity.compact,
                textStyle: const TextStyle(fontSize: 12),
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
        Container(
          height: 250,
          padding: const EdgeInsets.only(
            top: 24,
            right: 16,
            left: 0,
            bottom: 8,
          ),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: BarChart(
            BarChartData(
              alignment: BarChartAlignment.spaceAround,
              maxY: maxVal == 0 ? 10 : maxVal * 1.2,
              barTouchData: BarTouchData(
                touchTooltipData: BarTouchTooltipData(
                  getTooltipColor: (_) => Colors.black87,
                  tooltipPadding: const EdgeInsets.all(8),
                  tooltipMargin: 8,
                  getTooltipItem: (group, groupIndex, rod, rodIndex) {
                    if (group.x < 0 || group.x >= widget.dailyTotals.length) {
                      return null;
                    }
                    final data = widget.dailyTotals[group.x];
                    final dateStr = DateFormat.yMMMd(locale).format(data.date);

                    String metricLabel = '';
                    String unit = 'g';
                    switch (_selectedMetric) {
                      case NutritionMetric.calories:
                        metricLabel = l10n.metricCalories;
                        unit = l10n.metricKcal;
                        break;
                      case NutritionMetric.protein:
                        metricLabel = l10n.metricProtein;
                        break;
                      case NutritionMetric.carbs:
                        metricLabel = l10n.metricCarbs;
                        break;
                      case NutritionMetric.fats:
                        metricLabel = l10n.metricFat;
                        break;
                    }

                    return BarTooltipItem(
                      '$dateStr\n${rod.toY.toStringAsFixed(0)}$unit $metricLabel',
                      const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    );
                  },
                ),
              ),
              titlesData: FlTitlesData(
                show: true,
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      if (value.toInt() >= widget.dailyTotals.length) {
                        return const SizedBox.shrink();
                      }
                      final date = widget.dailyTotals[value.toInt()].date;

                      final text =
                          widget.dailyTotals.length <= 7
                              ? DateFormat.E(locale).format(date)
                              : DateFormat.Md(locale).format(date);

                      return Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          text,
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontWeight: FontWeight.w600,
                            fontSize: 11,
                          ),
                        ),
                      );
                    },
                  ),
                ),
                leftTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                topTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                rightTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
              ),
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                getDrawingHorizontalLine: (value) => FlLine(
                  color: Colors.grey.shade200,
                  strokeWidth: 1,
                  dashArray: [4, 4],
                ),
              ),
              borderData: FlBorderData(show: false),
              barGroups: widget.dailyTotals.asMap().entries.map((e) {
                final index = e.key;
                final data = e.value;
                double val = 0;
                Color color = Colors.orange.shade300;

                switch (_selectedMetric) {
                  case NutritionMetric.calories:
                    val = data.calories;
                    color = Colors.orange.shade300;
                    break;
                  case NutritionMetric.protein:
                    val = data.protein;
                    color = Colors.red.shade300;
                    break;
                  case NutritionMetric.carbs:
                    val = data.carbs;
                    color = Colors.amber.shade300;
                    break;
                  case NutritionMetric.fats:
                    val = data.fats;
                    color = Colors.blue.shade300;
                    break;
                }

                return BarChartGroupData(
                  x: index,
                  barRods: [
                    BarChartRodData(
                      toY: val,
                      color: color,
                      width: widget.dailyTotals.length > 10 ? 12 : 18,
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  double _getMaxValue() {
    double max = 0;
    for (final day in widget.dailyTotals) {
      double val = 0;
      switch (_selectedMetric) {
        case NutritionMetric.calories:
          val = day.calories;
          break;
        case NutritionMetric.protein:
          val = day.protein;
          break;
        case NutritionMetric.carbs:
          val = day.carbs;
          break;
        case NutritionMetric.fats:
          val = day.fats;
          break;
      }
      if (val > max) max = val;
    }
    return max;
  }
}
