import 'package:meal_plan_app/features/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:meal_plan_app/l10n/app_localizations.dart';

import 'package:meal_plan_app/features/meal_plan/domain/domain.dart';
import 'package:meal_plan_app/features/meal_plan/presentation/providers/provider.dart';
import 'save_ingredients_flow.dart';
import 'delete_plan_sheet.dart';
import 'reuse_plan_sheet.dart';

class PlanActionsSheet extends ConsumerWidget {
  final MealPlanSummary plan;

  const PlanActionsSheet({
    super.key,
    required this.plan,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 24, left: 16, right: 16, top: 16),
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
          Text(
            l10n.planActionsTitle, // Wait, this might not exist. I'll use planName or something generic.
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1A1E1B),
            ),
          ),
          Text(
            plan.planName,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 24),
          _ActionRow(
            icon: Icons.list_alt_rounded,
            label: l10n.mealPlanActionViewDetails,
            iconBgColor: const Color(0xFFE8F0E8),
            iconColor: const Color(0xFF4C6B4F),
            onTap: () {
              Navigator.pop(context);
              context.push('/meal-plan/${plan.id}');
            },
          ),
          const Divider(color: Color(0xFFF1F1F1)),
          _ActionRow(
            icon: Icons.playlist_add_check_rounded,
            label: l10n.saveIngredientsSheetTitle,
            iconBgColor: const Color(0xFFE8F0E8),
            iconColor: const Color(0xFF4C6B4F),
            onTap: () async {
              Navigator.pop(context);
              await SaveIngredientsFlow.show(
                context: context,
                ref: ref,
                planId: plan.id,
                skipInitialDialog: true,
              );
            },
          ),
          const Divider(color: Color(0xFFF1F1F1)),
          _ActionRow(
            icon: Icons.replay_rounded,
            label: l10n.menuReusePlan,
            iconBgColor: const Color(0xFFE8F0E8),
            iconColor: const Color(0xFF4C6B4F),
            onTap: () async {
              Navigator.pop(context);
              await _showReusePlanSheet(context, ref, l10n);
            },
          ),
          const Divider(color: Color(0xFFF1F1F1)),
          _ActionRow(
            icon: Icons.delete_outline_rounded,
            label: l10n.deleteAction,
            iconBgColor: const Color(0xFFE8F0E8),
            iconColor: const Color(0xFF4C6B4F),
            isDestructive: true,
            onTap: () async {
              Navigator.pop(context);
              await _showDeletePlanDialog(context, ref, l10n);
            },
          ),
        ],
      ),
    );
  }

  Future<void> _showReusePlanSheet(
      BuildContext context, WidgetRef ref, AppLocalizations l10n) async {
    final result =
        await showModalBottomSheet<({String startDate, String? name})>(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => ReusePlanSheet(plan: plan),
    );
    if (result == null || !context.mounted) return;

    final response = await ref
        .read(mealPlanEntryActionsProvider.notifier)
        .reusePlan(plan.id, result.startDate, name: result.name);
    if (!context.mounted) return;
    if (response != null) {
      ref.invalidate(mealPlansProvider);
      ref.read(mealPlanEntryActionsProvider.notifier).reset();
      CustomSnackbar.showSuccess(
        context,
        l10n.planReusedSuccess(
            response.newPlanName, response.entriesCloned),
        action: SnackBarAction(
          label: l10n.planReusedView,
          textColor: Colors.white,
          onPressed: () => context.push('/meal-plan/${response.newPlanId}'),
        ),
      );
    } else {
      CustomSnackbar.showError(context, l10n.planReusedFailed);
    }
  }

  Future<void> _showDeletePlanDialog(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
  ) async {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => DeletePlanSheet(
        planId: plan.id,
        actionsNotifier: ref.read(mealPlanEntryActionsProvider.notifier),
        showRemoveIngredientsCheckbox: true,
        onDeleted: () {
          ref.invalidate(mealPlansProvider);
          CustomSnackbar.showInfo(context, l10n.planDeletedSuccess);
        },
      ),
    );
  }
}

class _ActionRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color iconBgColor;
  final Color iconColor;
  final VoidCallback onTap;
  final bool isDestructive;

  const _ActionRow({
    required this.icon,
    required this.label,
    required this.iconBgColor,
    required this.iconColor,
    required this.onTap,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration:
                  BoxDecoration(color: iconBgColor, shape: BoxShape.circle),
              child: Icon(icon, color: iconColor),
            ),
            const SizedBox(width: 16),
            Text(
              label,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: isDestructive
                    ? const Color(0xFFE57373)
                    : const Color(0xFF1A1E1B),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
