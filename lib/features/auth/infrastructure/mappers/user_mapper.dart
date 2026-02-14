import 'package:meal_plan_app/features/auth/domain/domain.dart';

class UserMapper {
  static UserProfile fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] as String,
      email: json['email'] as String,
      name: json['name'] as String?,
      profileData: json['profile_data'] as Map<String, dynamic>?,
      onboardingComplete: json['onboarding_complete'] as bool? ?? false,
      permissions: _parsePermissions(json['permissions']),
      planName: json['plan_name'] as String?,
      configurations: json['configurations'] as Map<String, dynamic>?,
    );
  }

  static Map<String, dynamic> toJson(UserProfile user) {
    return {
      'id': user.id,
      'name': user.name,
      'profile_data': user.profileData,
      'permissions': _serializePermissions(user.permissions),
      'plan_name': user.planName,
    };
  }

  static Permissions? _parsePermissions(dynamic permissionsJson) {
    if (permissionsJson == null || permissionsJson is! Map<String, dynamic>) {
      return null;
    }

    final descJson = permissionsJson['description'] as Map<String, dynamic>?;
    final permJson = permissionsJson['permissions'] as Map<String, dynamic>?;

    final description = <String, List<String>>{};
    if (descJson != null) {
      description['en'] =
          (descJson['en'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [];
      description['es'] =
          (descJson['es'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [];
    }

    final permissionDetails = PermissionDetails(
      mealPlanDays:
          (permJson?['mealPlanDays'] as List<dynamic>?)
              ?.map((e) => e as int)
              .toList() ??
          [],
      mealPlanGenerate: permJson?['mealPlanGenerate'] as int?,
      mealPlanTypeFood:
          (permJson?['mealPlanTypeFood'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
    );

    return Permissions(
      description: description,
      permissions: permissionDetails,
    );
  }

  static Map<String, dynamic>? _serializePermissions(Permissions? permissions) {
    if (permissions == null) return null;

    return {
      'description': permissions.description,
      'permissions': {
        'mealPlanDays': permissions.permissions.mealPlanDays,
        'mealPlanGenerate': permissions.permissions.mealPlanGenerate,
        'mealPlanTypeFood': permissions.permissions.mealPlanTypeFood,
      },
    };
  }
}
