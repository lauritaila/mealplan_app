import 'daily_total.dart';
import 'weekly_average.dart';

class NutritionSummary {
  final List<DailyTotal> dailyTotals;
  final WeeklyAverage weeklyAverage;

  NutritionSummary({required this.dailyTotals, required this.weeklyAverage});
}
