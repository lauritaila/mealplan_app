import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meal_plan_app/config/theme/app_theme.dart';
import 'package:meal_plan_app/l10n/app_localizations.dart';
import 'package:meal_plan_app/features/auth/presentation/provider/provider.dart';

class DailyNutritionSummary extends ConsumerWidget {
  final AsyncValue nutritionAsync;
  const DailyNutritionSummary({super.key, required this.nutritionAsync});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final customColors = theme.extension<AppCustomColors>()!;
    final l10n = AppLocalizations.of(context);
    
    final authState = ref.watch(authProvider);
    final hideNutritionValues =
        authState is AuthenticatedAuthState &&
        authState.user.configurations?['hideNutritionValues'] == true;

    if (hideNutritionValues) return const SizedBox.shrink();

    return nutritionAsync.when(
      data: (summary) {
        final today = summary.todaySummary;
        if (today == null) return const SizedBox.shrink();

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Card(
            elevation: 0,
            color: theme.cardTheme.color,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _NutritionColumnItem(
                    icon: Icons.local_fire_department,
                    iconColor: customColors.macroCalories!,
                    label: l10n.metricCalories.toUpperCase(),
                    value: '${today.calories.toInt()} kcal',
                    target: '',
                  ),
                  _NutritionColumnItem(
                    icon: Icons.fitness_center,
                    iconColor: customColors.macroProtein!,
                    label: l10n.metricProtein.toUpperCase(),
                    value: '${today.protein.toInt()}g',
                    target: '',
                  ),
                  _NutritionColumnItem(
                    icon: Icons.grain,
                    iconColor: customColors.macroCarbs!,
                    label: l10n.metricCarbs.toUpperCase(),
                    value: '${today.carbs.toInt()}g',
                    target: '',
                  ),
                  _NutritionColumnItem(
                    icon: Icons.water_drop,
                    iconColor: customColors.macroFat!,
                    label: l10n.metricFat.toUpperCase(),
                    value: '${today.fats.toInt()}g',
                    target: '',
                  ),
                ],
              ),
            ),
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (error, stack) => const SizedBox.shrink(),
    );
  }
}

class _NutritionColumnItem extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;
  final String target;

  const _NutritionColumnItem({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
    required this.target,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final customColors = theme.extension<AppCustomColors>()!;
    
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: customColors.chartTabBackground,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: iconColor, size: 24),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: textTheme.labelSmall?.copyWith(
            fontSize: 10,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.5,
            color: customColors.slateGrey?.withValues(alpha: 0.6),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w900,
            color: customColors.textDarkBlue,
          ),
        ),
      ],
    );
  }
}
