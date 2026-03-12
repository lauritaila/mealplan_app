import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../config/theme/app_theme.dart';
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

    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final customColors = theme.extension<AppCustomColors>()!;
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).toString();
    final maxVal = _getMaxValue();
    final avgVal = _getAvgValue();
    
    String unitLabel = 'G';
    if (_selectedMetric == NutritionMetric.calories) {
      unitLabel = 'KCAL';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              l10n.weeklyActivityTitle,
              style: textTheme.titleLarge?.copyWith(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                color: customColors.textDarkBlue,
              ),
            ),
            Text(
              l10n.mondayToSundayLabel,
              style: textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.w900,
                letterSpacing: 1.5,
                color: customColors.slateGrey?.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (!widget.hideNutritionValues) ...[
          Container(
            decoration: BoxDecoration(
              color: customColors.chartTabBackground,
              borderRadius: BorderRadius.circular(24),
            ),
            padding: const EdgeInsets.all(4),
            child: Row(
              children: [
                _buildTab(_abbreviate(l10n.metricCalories, 4).toUpperCase(), NutritionMetric.calories),
                _buildTab(_abbreviate(l10n.metricProtein, 4).toUpperCase(), NutritionMetric.protein),
                _buildTab(_abbreviate(l10n.metricCarbs, 4).toUpperCase(), NutritionMetric.carbs),
                _buildTab(_abbreviate(l10n.metricFat, 4).toUpperCase(), NutritionMetric.fats),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],
        if (widget.hideNutritionValues)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: theme.cardTheme.color,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: theme.dividerColor.withValues(alpha: 0.1)),
            ),
            child: Column(
              children: [
                Icon(Icons.visibility_off_rounded, size: 48, color: customColors.slateGrey?.withValues(alpha: 0.3)),
                const SizedBox(height: 16),
                Text(
                  l10n.profileHideNutritionLabel,
                  textAlign: TextAlign.center,
                  style: textTheme.bodyMedium?.copyWith(
                    color: customColors.slateGrey,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          )
        else ...[
          Container(
            height: 300,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: theme.cardTheme.color,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: theme.dividerColor.withValues(alpha: 0.05)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
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
                      style: textTheme.headlineLarge?.copyWith(
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                        color: customColors.textDarkBlue,
                        letterSpacing: -1,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '$unitLabel ${l10n.averageAbbr.toUpperCase()}',
                      style: textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: customColors.slateGrey,
                      ),
                    ),
                  ],
                ),
              const SizedBox(height: 32),
              Expanded(
                child: BarChart(
                  BarChartData(
                    alignment: BarChartAlignment.spaceAround,
                    maxY: maxVal == 0 ? 10 : maxVal * 1.2,
                    barTouchData: BarTouchData(
                      touchTooltipData: BarTouchTooltipData(
                        getTooltipColor: (_) => customColors.textDarkBlue ?? Colors.black,
                        tooltipPadding: const EdgeInsets.all(12),
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
                            '$dateStr\n',
                            textTheme.labelSmall?.copyWith(color: Colors.white, fontWeight: FontWeight.normal) ?? const TextStyle(color: Colors.white),
                            children: [
                              TextSpan(
                                text: '${rod.toY.toStringAsFixed(0)}$unit $metricLabel',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 14,
                                ),
                              ),
                            ],
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
                              padding: const EdgeInsets.only(top: 12.0),
                              child: Text(
                                text,
                                style: textTheme.labelSmall?.copyWith(
                                  color: customColors.darkSage,
                                  fontWeight: FontWeight.w900,
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
                    gridData: const FlGridData(show: false),
                    borderData: FlBorderData(show: false),
                    barGroups: widget.dailyTotals.asMap().entries.map((e) {
                      final index = e.key;
                      final data = e.value;
                      double val = 0;
                      Color barColor = customColors.darkSage!;

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
                            color: barColor,
                            width: widget.dailyTotals.length > 10 ? 8 : 14,
                            borderRadius: BorderRadius.circular(12),
                            backDrawRodData: BackgroundBarChartRodData(
                              show: true,
                              toY: maxVal * 1.2,
                              color: customColors.chartTabBackground,
                            ),
                          ),
                        ],
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildTab(String label, NutritionMetric metric) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final customColors = theme.extension<AppCustomColors>()!;
    final isSelected = _selectedMetric == metric;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedMetric = metric;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? theme.colorScheme.surface : Colors.transparent,
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
              style: textTheme.labelSmall?.copyWith(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w900 : FontWeight.w700,
                color: isSelected ? customColors.darkSage : customColors.slateGrey?.withValues(alpha: 0.6),
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
