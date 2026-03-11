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

  double _getAvgValue() {
    if (widget.dailyTotals.isEmpty) return 0;
    double sum = 0;
    for (final day in widget.dailyTotals) {
      switch (_selectedMetric) {
        case NutritionMetric.calories:
          sum += day.calories;
          break;
        case NutritionMetric.protein:
          sum += day.protein;
          break;
        case NutritionMetric.carbs:
          sum += day.carbs;
          break;
        case NutritionMetric.fats:
          sum += day.fats;
          break;
      }
    }
    return sum / widget.dailyTotals.length;
  }

  @override
  Widget build(BuildContext context) {
    if (widget.dailyTotals.isEmpty) {
      return const SizedBox.shrink();
    }

    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).toString();
    final maxVal = _getMaxValue();
    final avgVal = _getAvgValue();
    
    String unitLabel = 'g';
    if (_selectedMetric == NutritionMetric.calories) {
      unitLabel = 'kcal';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              l10n.weeklyActivityTitle,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF001B3A),
              ),
            ),
            Text(
              l10n.mondayToSundayLabel,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
                color: Colors.blueGrey.shade300,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (!widget.hideNutritionValues) ...[
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFFF4F7F4),
              borderRadius: BorderRadius.circular(24),
            ),
            padding: const EdgeInsets.all(4),
            child: Row(
              children: [
                _buildTab(_abbreviate(l10n.metricCalories, 3), NutritionMetric.calories),
                _buildTab(_abbreviate(l10n.metricProtein, 3), NutritionMetric.protein),
                _buildTab(_abbreviate(l10n.metricCarbs, 3), NutritionMetric.carbs),
                _buildTab(_abbreviate(l10n.metricFat, 3), NutritionMetric.fats),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],
        Container(
          height: 280,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    avgVal.toStringAsFixed(0),
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF001B3A),
                      letterSpacing: -1,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '$unitLabel ${l10n.averageAbbr}',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.blueGrey.shade400,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Expanded(
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
                            
                            // Abbreviated standalone day name
                            final text = DateFormat.E(locale).format(date).characters.first.toUpperCase();

                            return Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Text(
                                text,
                                style: const TextStyle(
                                  color: Color(0xFF7BA082),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 10,
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
                    gridData: const FlGridData(show: false),
                    borderData: FlBorderData(show: false),
                    barGroups: widget.dailyTotals.asMap().entries.map((e) {
                      final index = e.key;
                      final data = e.value;
                      double val = 0;
                      Color color = const Color(0xFF7BA082); // Muted green for all bars

                      switch (_selectedMetric) {
                        case NutritionMetric.calories:
                          val = data.calories;
                          break;
                        case NutritionMetric.protein:
                          val = data.protein;
                          break;
                        case NutritionMetric.carbs:
                          val = data.carbs;
                          break;
                        case NutritionMetric.fats:
                          val = data.fats;
                          break;
                      }

                      return BarChartGroupData(
                        x: index,
                        barRods: [
                          BarChartRodData(
                            toY: val,
                            color: color,
                            width: widget.dailyTotals.length > 10 ? 8 : 12,
                            borderRadius: BorderRadius.circular(10), // Fully rounded ends
                          ),
                        ],
                      );
                    }).toList(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTab(String label, NutritionMetric metric) {
    final isSelected = _selectedMetric == metric;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedMetric = metric;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    )
                  ]
                : null,
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                color: isSelected ? const Color(0xFF4C6B4F) : Colors.blueGrey.shade400,
              ),
            ),
          ),
        ),
      ),
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
