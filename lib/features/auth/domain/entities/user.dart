import 'package:equatable/equatable.dart';

class Permissions extends Equatable {
  final Map<String, List<String>> description;
  final PermissionDetails permissions;

  const Permissions({required this.description, required this.permissions});

  @override
  List<Object?> get props => [description, permissions];
}

class PermissionDetails extends Equatable {
  final List<int> mealPlanDays;
  final List<String> mealPlanTypeFood;
  final int? mealPlanGenerate;
  final List<int> mealPlanTime;
  final int mealPlanGenerateLimit;
  final int substituteLimit;
  final int regenerateRecipeLimit;
  final int recipeAssistantLimit;

  const PermissionDetails({
    required this.mealPlanDays,
    required this.mealPlanTypeFood,
    this.mealPlanGenerate,
    this.mealPlanTime = const [],
    this.mealPlanGenerateLimit = 0,
    this.substituteLimit = 0,
    this.regenerateRecipeLimit = 0,
    this.recipeAssistantLimit = 0,
  });

  factory PermissionDetails.fromJson(Map<String, dynamic> json) =>
      PermissionDetails(
        mealPlanDays: List<int>.from(json['meal_plan_days'] ?? []),
        mealPlanTypeFood: List<String>.from(json['meal_plan_type_food'] ?? []),
        mealPlanGenerate: json['meal_plan_generate'],
        mealPlanTime: List<int>.from(json['meal_plan_time'] ?? []),
        mealPlanGenerateLimit: json['meal_plan_generate_limit'] ?? 0,
        substituteLimit: json['substitute_limit'] ?? 0,
        regenerateRecipeLimit: json['regenerate_recipe_limit'] ?? 0,
        recipeAssistantLimit: json['recipe_assistant_limit'] ?? 0,
      );

  Map<String, dynamic> toJson() => {
        'meal_plan_days': mealPlanDays,
        'meal_plan_type_food': mealPlanTypeFood,
        'meal_plan_generate': mealPlanGenerate,
        'meal_plan_time': mealPlanTime,
        'meal_plan_generate_limit': mealPlanGenerateLimit,
        'substitute_limit': substituteLimit,
        'regenerate_recipe_limit': regenerateRecipeLimit,
        'recipe_assistant_limit': recipeAssistantLimit,
      };

  @override
  List<Object?> get props => [
    mealPlanDays,
    mealPlanTypeFood,
    mealPlanGenerate,
    mealPlanTime,
    mealPlanGenerateLimit,
    substituteLimit,
    regenerateRecipeLimit,
    recipeAssistantLimit,
  ];
}

class UserProfile extends Equatable {
  final String id;
  final String email;
  final String? name;
  final Map<String, dynamic>? profileData;
  final bool onboardingComplete;
  final Permissions? permissions;
  final String? planName;
  final Map<String, dynamic>? configurations;

  const UserProfile({
    required this.onboardingComplete,
    required this.id,
    required this.email,
    this.name,
    this.profileData,
    this.permissions,
    this.planName,
    this.configurations,
  });

  UserProfile copyWith({
    String? id,
    String? email,
    String? name,
    Map<String, dynamic>? profileData,
    bool? onboardingComplete,
    Permissions? permissions,
    String? planName,
    Map<String, dynamic>? configurations,
  }) {
    return UserProfile(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      profileData: profileData ?? this.profileData,
      onboardingComplete: onboardingComplete ?? this.onboardingComplete,
      permissions: permissions ?? this.permissions,
      planName: planName ?? this.planName,
      configurations: configurations ?? this.configurations,
    );
  }

  @override
  List<Object?> get props => [
    id,
    email,
    name,
    profileData,
    onboardingComplete,
    permissions,
    planName,
    configurations,
  ];
}
