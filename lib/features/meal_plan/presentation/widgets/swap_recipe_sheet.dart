import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meal_plan_app/config/theme/app_theme.dart';
import 'package:meal_plan_app/features/recipes/presentation/providers/favorite_recipes_provider.dart';
import 'package:meal_plan_app/l10n/app_localizations.dart';

class SwapRecipeSheet extends ConsumerStatefulWidget {
  const SwapRecipeSheet({super.key});

  @override
  ConsumerState<SwapRecipeSheet> createState() => _SwapRecipeSheetState();
}

class _SwapRecipeSheetState extends ConsumerState<SwapRecipeSheet> {
  int? _selectedRecipeId;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final customColors = theme.extension<AppCustomColors>()!;
    final textTheme = theme.textTheme;
    final favoritesAsync = ref.watch(favoriteRecipesProvider);
    final l10n = AppLocalizations.of(context);

    return SafeArea(
      child: Container(
        height: MediaQuery.of(context).size.height * 0.85,
        padding: EdgeInsets.only(
          top: 16,
          bottom: MediaQuery.of(context).viewInsets.bottom + 16,
        ),
        decoration: BoxDecoration(
          color: theme.scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: customColors.slateGrey?.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SizedBox(width: 40),
                  Expanded(
                    child: Text(
                      l10n.swapFavoriteTitle,
                      style: textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w900,
                        color: customColors.textDarkBlue,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close_rounded, color: customColors.slateGrey, size: 24),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                l10n.myFavoriteRecipes.toUpperCase(),
                style: textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: customColors.darkSage,
                  letterSpacing: 1.2,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: favoritesAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, _) => Center(child: Text(l10n.errorOccurred(err.toString()))),
                data: (favorites) {
                  if (favorites.isEmpty) {
                    return Center(child: Text(l10n.noFavoriteRecipes));
                  }
                  return RadioGroup<int>(
                    groupValue: _selectedRecipeId,
                    onChanged: (v) => setState(() => _selectedRecipeId = v),
                    child: ListView.builder(
                      itemCount: favorites.length,
                      itemBuilder: (context, index) {
                        final recipe = favorites[index];
                        final isSelected = _selectedRecipeId == recipe.id;
                        return InkWell(
                          onTap: () => setState(() => _selectedRecipeId = recipe.id),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                            decoration: BoxDecoration(
                              border: Border(bottom: BorderSide(color: customColors.slateGrey!.withValues(alpha: 0.05))),
                              color: isSelected ? customColors.chartTabBackground?.withValues(alpha: 0.5) : Colors.transparent,
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Radio<int>(
                                  value: recipe.id,
                                  activeColor: customColors.darkSage,
                                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        recipe.name,
                                        style: textTheme.bodyLarge?.copyWith(
                                          fontWeight: FontWeight.w800,
                                          color: customColors.textDarkBlue,
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                      Wrap(
                                        spacing: 8,
                                        runSpacing: 4,
                                        children: [
                                          _MacroChip(label: '${recipe.calories?.toStringAsFixed(0) ?? "--"} ${l10n.kcalLabel}', isCalories: true),
                                          _MacroChip(label: 'P: ${recipe.proteinGrams?.toStringAsFixed(0) ?? "-"}g'),
                                          _MacroChip(label: '${l10n.metricCarbsShort[0]}: ${recipe.carbsGrams?.toStringAsFixed(0) ?? "-"}g'),
                                          _MacroChip(label: '${l10n.metricFat[0]}: ${recipe.fatsGrams?.toStringAsFixed(0) ?? "-"}g'),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
              child: FilledButton.icon(
                icon: const Icon(Icons.check_rounded, color: Colors.white, size: 20),
                label: Text(
                  l10n.saveSelectionAction.toUpperCase(),
                  style: const TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.1),
                ),
                style: FilledButton.styleFrom(
                  minimumSize: const Size(double.infinity, 60),
                  backgroundColor: customColors.darkSage,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  elevation: 0,
                ),
                onPressed: _selectedRecipeId == null ? null : () {
                  Navigator.of(context).pop(_selectedRecipeId);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MacroChip extends StatelessWidget {
  final String label;
  final bool isCalories;

  const _MacroChip({required this.label, this.isCalories = false});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final customColors = theme.extension<AppCustomColors>()!;
    final textTheme = theme.textTheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: isCalories 
            ? theme.colorScheme.errorContainer.withValues(alpha: 0.3) 
            : customColors.chartTabBackground,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: textTheme.labelSmall?.copyWith(
          color: isCalories ? theme.colorScheme.error : customColors.darkSage,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}
