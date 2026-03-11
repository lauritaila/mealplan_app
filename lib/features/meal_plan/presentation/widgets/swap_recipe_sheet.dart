import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
    final favoritesAsync = ref.watch(favoriteRecipesProvider);
    final l10n = AppLocalizations.of(context);

    return SafeArea(
      child: Container(
        height: MediaQuery.of(context).size.height * 0.85,
        padding: EdgeInsets.only(
          top: 16,
          bottom: MediaQuery.of(context).viewInsets.bottom + 16,
        ),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SizedBox(width: 48), // Balance for centering title
                  const Expanded(
                    child: Text(
                      'Cambiar por Favorita',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.grey),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                'MIS RECETAS FAVORITAS',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Colors.grey.shade500, letterSpacing: 1.1),
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
                  return ListView.builder(
                    itemCount: favorites.length,
                    itemBuilder: (context, index) {
                      final recipe = favorites[index];
                      final isSelected = _selectedRecipeId == recipe.id;
                      return InkWell(
                        onTap: () => setState(() => _selectedRecipeId = recipe.id),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                          decoration: BoxDecoration(
                            border: Border(bottom: BorderSide(color: Colors.grey.shade100)),
                            color: isSelected ? const Color(0xFFF4F7F5) : Colors.transparent,
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Radio<int>(
                                value: recipe.id,
                                groupValue: _selectedRecipeId,
                                onChanged: (v) => setState(() => _selectedRecipeId = v),
                                activeColor: const Color(0xFF576F5F),
                                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      recipe.name,
                                      style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: Color(0xFF1A1E1B)),
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        _MacroChip(label: '${recipe.calories?.toStringAsFixed(0) ?? "--"} kcal', isCalories: true),
                                        const SizedBox(width: 8),
                                        _MacroChip(label: 'P: ${recipe.proteinGrams?.toStringAsFixed(0) ?? "-"}g'),
                                        const SizedBox(width: 4),
                                        _MacroChip(label: 'C: ${recipe.carbsGrams?.toStringAsFixed(0) ?? "-"}g'),
                                        const SizedBox(width: 4),
                                        _MacroChip(label: 'G: ${recipe.fatsGrams?.toStringAsFixed(0) ?? "-"}g'),
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
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
              child: FilledButton.icon(
                icon: const Icon(Icons.check, color: Colors.white, size: 20),
                label: const Text('Confirmar Selección', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                style: FilledButton.styleFrom(
                  minimumSize: const Size(double.infinity, 56),
                  backgroundColor: const Color(0xFF576F5F),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isCalories ? const Color(0xFFFDF2F2) : const Color(0xFFF4F7F5),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: isCalories ? const Color(0xFFE57373) : const Color(0xFF576F5F),
          fontSize: 11,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}
