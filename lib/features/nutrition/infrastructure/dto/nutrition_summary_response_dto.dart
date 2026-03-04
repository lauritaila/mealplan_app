class NutritionSummaryResponseDto {
  final List<DailyTotalDto> dailyTotals;
  final WeeklyAverageDto weeklyAverage;

  NutritionSummaryResponseDto({
    required this.dailyTotals,
    required this.weeklyAverage,
  });

  factory NutritionSummaryResponseDto.fromJson(Map<String, dynamic> json) {
    return NutritionSummaryResponseDto(
      dailyTotals:
          (json['daily_totals'] as List<dynamic>?)
              ?.map((e) => DailyTotalDto.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      weeklyAverage: WeeklyAverageDto.fromJson(
        json['weekly_average'] as Map<String, dynamic>? ?? {},
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'daily_totals': dailyTotals.map((e) => e.toJson()).toList(),
      'weekly_average': weeklyAverage.toJson(),
    };
  }
}

class DailyTotalDto {
  final String date;
  final num calories;
  final num protein;
  final num carbs;
  final num fats;

  DailyTotalDto({
    required this.date,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fats,
  });

  factory DailyTotalDto.fromJson(Map<String, dynamic> json) {
    return DailyTotalDto(
      date: json['date'] as String? ?? '',
      calories: json['calories'] as num? ?? 0,
      protein: json['protein'] as num? ?? 0,
      carbs: json['carbs'] as num? ?? 0,
      fats: json['fats'] as num? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date,
      'calories': calories,
      'protein': protein,
      'carbs': carbs,
      'fats': fats,
    };
  }
}

class WeeklyAverageDto {
  final num calories;
  final num protein;
  final num carbs;
  final num fats;
  final num consistencyScore;

  WeeklyAverageDto({
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fats,
    required this.consistencyScore,
  });

  factory WeeklyAverageDto.fromJson(Map<String, dynamic> json) {
    return WeeklyAverageDto(
      calories: json['calories'] as num? ?? 0,
      protein: json['protein'] as num? ?? 0,
      carbs: json['carbs'] as num? ?? 0,
      fats: json['fats'] as num? ?? 0,
      consistencyScore: json['consistency_score'] as num? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'calories': calories,
      'protein': protein,
      'carbs': carbs,
      'fats': fats,
      'consistency_score': consistencyScore,
    };
  }
}
