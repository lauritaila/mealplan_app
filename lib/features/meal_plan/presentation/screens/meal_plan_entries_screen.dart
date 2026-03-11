import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:meal_plan_app/config/errors/app_errors.dart';
import 'package:meal_plan_app/features/auth/domain/entities/user.dart';
import 'package:meal_plan_app/features/auth/presentation/provider/provider.dart';
import 'package:meal_plan_app/features/grocery_list/presentation/providers/grocery_actions_provider.dart';
import 'package:meal_plan_app/features/grocery_list/presentation/widgets/select_grocery_list_sheet.dart';
import 'package:meal_plan_app/features/meal_plan/domain/domain.dart';
import 'package:meal_plan_app/features/meal_plan/presentation/providers/provider.dart';
import 'package:meal_plan_app/features/shared/utils/app_error_localizations.dart';
import 'package:meal_plan_app/l10n/app_localizations.dart';

class MealPlanEntriesScreen extends ConsumerWidget {
  final int planId;
  final String? planName;

  const MealPlanEntriesScreen({super.key, required this.planId, this.planName});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entriesAsync = ref.watch(mealPlanEntriesProvider(planId));
    final actionsState = ref.watch(mealPlanEntryActionsProvider);
    final authState = ref.watch(authProvider);
    final l10n = AppLocalizations.of(context);
    final hideNutritionValues =
        authState is AuthenticatedAuthState &&
        authState.user.configurations?['hideNutritionValues'] == true;
    final userPermissions = authState is AuthenticatedAuthState
        ? authState.user.permissions?.permissions
        : null;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8FAFC),
        elevation: 0,
        centerTitle: true,
        title: Column(
          children: [
            Text(
              planName ?? l10n.planEntriesTitle,
              style: const TextStyle(
                color: Color(0xFF0F172A),
                fontWeight: FontWeight.w900,
                fontSize: 18,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert, color: Color(0xFF5C7861)),
            onPressed: () => _showPlanActionsSheet(context, ref, planId, l10n),
          ),
        ],
      ),
      body: entriesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 12),
              Text(
                localizeErrorCode(l10n, error is AppError ? error.code : null),
              ),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: () =>
                    ref.invalidate(mealPlanEntriesProvider(planId)),
                child: Text(l10n.retry),
              ),
            ],
          ),
        ),
        data: (entries) {
          if (entries.isEmpty) {
            return Center(child: Text(l10n.noEntriesInPlan));
          }

          // Group entries by date
          final grouped = <DateTime, List<DayMealEntry>>{};
          for (final e in entries) {
            final date = e.mealDate != null
                ? DateTime(e.mealDate!.year, e.mealDate!.month, e.mealDate!.day)
                : DateTime(2000);
            grouped.putIfAbsent(date, () => []).add(e);
          }
          final sortedDates = grouped.keys.toList()..sort();

          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
            itemCount: sortedDates.length + 1, // +1 for the top header
            itemBuilder: (context, index) {
              if (index == 0) {
                // Return top header
                return Padding(
                  padding: const EdgeInsets.only(bottom: 32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Expanded(
                            child: Text(
                              '5 - 11 de Marzo', // Ideally dynamic based on dates, mocked for design
                              style: const TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.w900,
                                color: Color(0xFF0F172A),
                                height: 1.1,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE8EFEA),
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Tu plan nutricional personalizado para reducir la inflamación.', // Dynamic based on plan description ideally
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFF64748B),
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                );
              }

              final di = index - 1;
              final date = sortedDates[di];
              final dayEntries = grouped[date]!;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _DateHeader(date: date),
                  const SizedBox(height: 16),
                  ...dayEntries.map(
                    (entry) => Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: _PlanEntryCard(
                        entry: entry,
                        hideNutritionValues: hideNutritionValues,
                        isUpdating:
                            actionsState.status ==
                            MealPlanEntryActionStatus.loading,
                        userPermissions: userPermissions,
                        planId: planId,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              );
            },
          );
        },
      ),
    );
  }
  Future<void> _showPlanActionsSheet(
    BuildContext context,
    WidgetRef ref,
    int planId,
    AppLocalizations l10n,
  ) async {
    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 32),
                _ActionRow(
                  icon: Icons.refresh_rounded,
                  label: l10n.retry, // localized refresh essentially
                  iconBgColor: const Color(0xFFF4F7F5),
                  iconColor: const Color(0xFF576F5F),
                  onTap: () {
                    Navigator.pop(context);
                    ref.invalidate(mealPlanEntriesProvider(planId));
                  },
                ),
                const Divider(color: Color(0xFFF1F1F1)),
                _ActionRow(
                  icon: Icons.shopping_cart_outlined,
                  label: l10n.menuSaveIngredients,
                  iconBgColor: const Color(0xFFF4F7F5),
                  iconColor: const Color(0xFF576F5F),
                  onTap: () async {
                    Navigator.pop(context);
                    final messenger = ScaffoldMessenger.of(context);
                    final selected = await showSelectOrCreateGroceryListSheet(
                      context: context,
                      title: l10n.saveIngredientsSheetTitle, // Or similar string
                    );
                    if (selected == null) return;
                    final ok = await ref
                        .read(groceryActionsProvider.notifier)
                        .importMealPlan(selected.id, planId);
                    if (context.mounted) {
                      messenger.showSnackBar(
                        SnackBar(
                          content: Text(
                              ok
                                ? l10n.savedIngredientsSuccess(selected.name)
                                : l10n.savedIngredientsFailed, // Or corresponding strings
                          ),
                        ),
                      );
                    }
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _DateHeader extends StatelessWidget {
  final DateTime date;
  const _DateHeader({required this.date});

  @override
  Widget build(BuildContext context) {
    if (date.year == 2000) return const SizedBox.shrink();
    final df = DateFormat('EEEE, d MMMM', Localizations.localeOf(context).toString());
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            df.format(date).toUpperCase(),
            style: const TextStyle(
              color: Color(0xFF5C7861),
              fontWeight: FontWeight.w800,
              fontSize: 13,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            height: 1,
            color: const Color(0xFFE2E8F0),
            width: double.infinity,
          ),
        ],
      ),
    );
  }
}
class _PlanEntryCard extends ConsumerWidget {
  final DayMealEntry entry;
  final bool hideNutritionValues;
  final bool isUpdating;
  final PermissionDetails? userPermissions;
  final int planId;

  const _PlanEntryCard({
    required this.entry,
    required this.hideNutritionValues,
    required this.isUpdating,
    required this.userPermissions,
    required this.planId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isCompleted = entry.status?.toLowerCase() == 'completed';

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF1F5F9), width: 1.5),
        boxShadow: const [
          BoxShadow(
            color: Color(0x04000000),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: entry.recipeId > 0
              ? () => context.push('/recipes/${entry.recipeId}?entryId=${entry.entryId}')
              : null,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    if (entry.mealType != null && entry.mealType!.isNotEmpty)
                      Container(
                        width: 90, // Fixed width to balance the layout
                        alignment: Alignment.centerLeft,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            entry.mealType!.toUpperCase(),
                            style: const TextStyle(
                              color: Color(0xFF5C7861),
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      )
                    else
                      const SizedBox(width: 90),
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.access_time_filled, size: 14, color: Color(0xFF94A3B8)),
                          const SizedBox(width: 6),
                          const Text(
                            '15 min', // Mock for prep time
                            style: TextStyle(
                              color: Color(0xFF94A3B8),
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: 90,
                      alignment: Alignment.centerRight,
                      child: const Icon(Icons.more_vert, size: 20, color: Color(0xFF94A3B8)),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  entry.name,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isCompleted ? const Color(0xFF94A3B8) : const Color(0xFF0F172A),
                    decoration: isCompleted ? TextDecoration.lineThrough : null,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    if (!hideNutritionValues && entry.calories != null)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${entry.calories!.round()} kcal',
                          style: const TextStyle(
                            color: Color(0xFF64748B),
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ...entry.categories.take(3).map((category) => Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF7FBF8),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            category,
                            style: const TextStyle(
                              color: Color(0xFF5C7861),
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        )),
                    if (isCompleted)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.check_circle, size: 14, color: Colors.green),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
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
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(color: iconBgColor, shape: BoxShape.circle),
              child: Icon(icon, color: iconColor),
            ),
            const SizedBox(width: 16),
            Text(
              label,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: isDestructive ? const Color(0xFFE57373) : const Color(0xFF1A1E1B),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

