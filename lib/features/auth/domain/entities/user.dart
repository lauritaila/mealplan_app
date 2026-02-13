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
  final int? mealPlanGenerate;
  final List<String> mealPlanTypeFood;

  const PermissionDetails({
    required this.mealPlanDays,
    required this.mealPlanGenerate,
    required this.mealPlanTypeFood,
  });

  @override
  List<Object?> get props => [mealPlanDays, mealPlanGenerate, mealPlanTypeFood];
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
