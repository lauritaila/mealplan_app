import '../../domain/entities/daily_total.dart';
import '../../domain/entities/nutrition_summary.dart';
import '../../domain/entities/weekly_average.dart';
import '../dto/nutrition_summary_response_dto.dart';

class NutritionMapper {
  static NutritionSummary dtoToEntity(NutritionSummaryResponseDto dto) {
    final dailyTotals = dto.dailyTotals
        .map((e) => _dailyTotalDtoToEntity(e))
        .toList();

    // Ensure they are chronologically sorted for the chart
    dailyTotals.sort((a, b) => a.date.compareTo(b.date));

    return NutritionSummary(
      todaySummary: dto.todaySummary != null
          ? _dailyTotalDtoToEntity(dto.todaySummary!)
          : null,
      dailyTotals: dailyTotals,
      weeklyAverage: _weeklyAverageDtoToEntity(dto.weeklyAverage),
    );
  }

  static DailyTotal _dailyTotalDtoToEntity(DailyTotalDto dto) {
    DateTime? parsedDate;
    try {
      parsedDate = DateTime.parse(dto.date);
    } catch (e) {
      // ignore: avoid_print
      print('Error parsing date: ${dto.date}. Error: $e');
      rethrow;
    }

    return DailyTotal(
      date: parsedDate,
      calories: dto.calories.toDouble(),
      protein: dto.protein.toDouble(),
      carbs: dto.carbs.toDouble(),
      fats: dto.fats.toDouble(),
    );
  }

  static WeeklyAverage _weeklyAverageDtoToEntity(WeeklyAverageDto dto) {
    return WeeklyAverage(
      calories: dto.calories.toDouble(),
      protein: dto.protein.toDouble(),
      carbs: dto.carbs.toDouble(),
      fats: dto.fats.toDouble(),
      consistencyScore: dto.consistencyScore.toDouble(),
    );
  }
}
