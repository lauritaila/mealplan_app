import 'daily_total.dart';
import 'weekly_average.dart';

class NutritionSummary {
  final DailyTotal? todaySummary;
  final List<DailyTotal> dailyTotals;
  final WeeklyAverage weeklyAverage;

  NutritionSummary({
    this.todaySummary,
    required this.dailyTotals,
    required this.weeklyAverage,
  });
}
