import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meal_plan_app/features/recipes/domain/domain.dart';
import 'package:meal_plan_app/features/recipes/presentation/providers/providers.dart';
import 'package:meal_plan_app/l10n/app_localizations.dart';

class IngredientSubstitutesSheet extends ConsumerWidget {
  final int recipeId;
  final IngredientSubstitutesRequest request;
  final String ingredientName;

  const IngredientSubstitutesSheet({
    super.key,
    required this.recipeId,
    required this.request,
    required this.ingredientName,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final substitutesAsync = ref.watch(
      recipeSubstitutesProvider(recipeId, request),
    );

    return Container(
      padding: EdgeInsets.only(
        top: 16,
        bottom: MediaQuery.of(context).padding.bottom,
      ),
      height: MediaQuery.of(context).size.height * 0.7,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    l10n.ingredientSubstitutesTitle(ingredientName),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),
          const Divider(),
          Expanded(
            child: substitutesAsync.when(
              loading: () => Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CircularProgressIndicator(),
                    const SizedBox(height: 12),
                    Text(l10n.loadingSubstitutes),
                  ],
                ),
              ),
              error: (err, _) =>
                  Center(child: Text(l10n.errorOccurred(err.toString()))),
              data: (substitutes) {
                if (substitutes.isEmpty) {
                  return Center(child: Text(l10n.noSubstitutesAvailable));
                }
                return ListView.separated(
                  itemCount: substitutes.length,
                  separatorBuilder: (context, index) {
                    return const Divider(height: 1);
                  },
                  itemBuilder: (context, index) {
                    final substitute = substitutes[index];
                    return ListTile(
                      title: Text(substitute.name),
                      subtitle: Text(
                        l10n.substituteDetails(
                          substitute.ratio,
                          substitute.reason,
                          substitute.category,
                        ),
                      ),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => Navigator.of(context).pop(substitute),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
