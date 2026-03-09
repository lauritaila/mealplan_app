// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'meal_plan_generator_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$availableDurationsHash() =>
    r'a303885f794f7b6740e2b613582a6b05960399db';

/// See also [availableDurations].
@ProviderFor(availableDurations)
final availableDurationsProvider = AutoDisposeProvider<List<int>>.internal(
  availableDurations,
  name: r'availableDurationsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$availableDurationsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AvailableDurationsRef = AutoDisposeProviderRef<List<int>>;
String _$availableMealTypesHash() =>
    r'f507189ecdfad198a7a2a4267339e3b3c1296fcc';

/// See also [availableMealTypes].
@ProviderFor(availableMealTypes)
final availableMealTypesProvider = AutoDisposeProvider<List<String>>.internal(
  availableMealTypes,
  name: r'availableMealTypesProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$availableMealTypesHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AvailableMealTypesRef = AutoDisposeProviderRef<List<String>>;
String _$shouldShowMealTypeSelectionHash() =>
    r'f065e0fc73c6726b65026ab83b06f3a19a192900';

/// See also [shouldShowMealTypeSelection].
@ProviderFor(shouldShowMealTypeSelection)
final shouldShowMealTypeSelectionProvider = AutoDisposeProvider<bool>.internal(
  shouldShowMealTypeSelection,
  name: r'shouldShowMealTypeSelectionProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$shouldShowMealTypeSelectionHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ShouldShowMealTypeSelectionRef = AutoDisposeProviderRef<bool>;
String _$mealPlanGeneratorHash() => r'9806fb62fa7203a3e63fd819e24259c8ec472ed1';

/// See also [MealPlanGenerator].
@ProviderFor(MealPlanGenerator)
final mealPlanGeneratorProvider =
    AutoDisposeNotifierProvider<
      MealPlanGenerator,
      MealPlanGeneratorState
    >.internal(
      MealPlanGenerator.new,
      name: r'mealPlanGeneratorProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$mealPlanGeneratorHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$MealPlanGenerator = AutoDisposeNotifier<MealPlanGeneratorState>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
