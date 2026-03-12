import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meal_plan_app/l10n/app_localizations.dart';
import 'package:meal_plan_app/config/theme/app_theme.dart';
import '../providers/nutrition_provider.dart';

class NutritionFiltersSheet extends ConsumerWidget {
  const NutritionFiltersSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final customColors = theme.extension<AppCustomColors>()!;
    final daysFilter = ref.watch(nutritionDaysFilterProvider);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 48,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 24),
          _FilterRow(
            label: l10n.nutritionFilterDaily,
            isSelected: daysFilter == 1,
            onTap: () {
              ref.read(nutritionDaysFilterProvider.notifier).setDays(1);
              Navigator.pop(context);
            },
          ),
          const Divider(color: Color(0xFFF1F1F1)),
          _FilterRow(
            label: l10n.nutritionFilterWeekly,
            isSelected: daysFilter == 7,
            onTap: () {
              ref.read(nutritionDaysFilterProvider.notifier).setDays(7);
              Navigator.pop(context);
            },
          ),
          const Divider(color: Color(0xFFF1F1F1)),
          _FilterRow(
            label: l10n.nutritionFilterMonthly,
            isSelected: daysFilter == 30,
            onTap: () {
              ref.read(nutritionDaysFilterProvider.notifier).setDays(30);
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}

class _FilterRow extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterRow({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final customColors = theme.extension<AppCustomColors>()!;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: isSelected ? customColors.darkSage : customColors.chartTabBackground,
                shape: BoxShape.circle,
              ),
              child: Icon(
                isSelected ? Icons.check_rounded : Icons.calendar_today_rounded,
                color: isSelected ? Colors.white : customColors.darkSage,
                size: 20,
              ),
            ),
            const SizedBox(width: 16),
            Text(
              label,
              style: TextStyle(
                fontSize: 16,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                color: isSelected ? customColors.textDarkBlue : customColors.slateGrey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
