class UpdateMealPlanDatesResponse {
  final int id;
  final String startDate;
  final String endDate;
  final int shiftedDays;

  UpdateMealPlanDatesResponse({
    required this.id,
    required this.startDate,
    required this.endDate,
    required this.shiftedDays,
  });

  factory UpdateMealPlanDatesResponse.fromJson(Map<String, dynamic> json) {
    return UpdateMealPlanDatesResponse(
      id: json['id'] as int,
      startDate: json['start_date'] as String,
      endDate: json['end_date'] as String,
      shiftedDays: json['shifted_days'] as int,
    );
  }
}
