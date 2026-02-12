// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meal_plan_app/features/auth/presentation/provider/provider.dart';
import 'package:meal_plan_app/l10n/app_localizations.dart';

class FoodPreferencesStep extends ConsumerStatefulWidget {
  const FoodPreferencesStep({super.key});

  @override
  ConsumerState<FoodPreferencesStep> createState() =>
      _FoodPreferencesStepState();
}

class _FoodPreferencesStepState extends ConsumerState<FoodPreferencesStep> {
  late final TextEditingController _dislikedController;
  late final TextEditingController _likedController;

  @override
  void initState() {
    super.initState();
    final state = ref.read(preferencesWizardProvider);
    _dislikedController = TextEditingController(
      text: state.dislikedFoods.join(', '),
    );
    _likedController = TextEditingController(text: state.likedFoods.join(', '));
  }

  @override
  void dispose() {
    _dislikedController.dispose();
    _likedController.dispose();
    super.dispose();
  }

  void _updateFoods() {
    final disliked = _dislikedController.text
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
    final liked = _likedController.text
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
    ref.read(preferencesWizardProvider.notifier).updateDislikedFoods(disliked);
    ref.read(preferencesWizardProvider.notifier).updateLikedFoods(liked);
  }

  String _localizedTitle(
    Map<String, String> titles,
    String locale,
    String fallback,
  ) {
    return titles[locale] ?? titles['en'] ?? fallback;
  }

  @override
  Widget build(BuildContext context) {
    final configAsync = ref.watch(preferencesConfigurationProvider);
    final textTheme = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context);
    final localeCode = Localizations.localeOf(context).languageCode;

    return configAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(child: Text(error.toString())),
      data: (config) {
        final showDisliked = config.textFields.foodPreferencesDisliked;
        final showLiked = config.textFields.foodPreferencesLiked;
        final foodPreferencesTitle = _localizedTitle(
          config.foodPreferencesTitles,
          localeCode,
          l10n.foodPreferencesTitle,
        );
        final dislikedTitle = _localizedTitle(
          config.foodPreferencesDislikedTitles,
          localeCode,
          l10n.dislikedFoodsTitle,
        );
        final dislikedHint = _localizedTitle(
          config.foodPreferencesDislikedHints,
          localeCode,
          l10n.dislikedFoodsHint,
        );
        final likedTitle = _localizedTitle(
          config.foodPreferencesLikedTitles,
          localeCode,
          l10n.likedFoodsTitle,
        );
        final likedHint = _localizedTitle(
          config.foodPreferencesLikedHints,
          localeCode,
          l10n.likedFoodsHint,
        );

        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            children: [
              const Icon(Icons.fastfood_outlined, size: 48, color: Colors.grey),
              const SizedBox(height: 16),
              Text(
                foodPreferencesTitle,
                style: textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              if (showDisliked) ...[
                Text(dislikedTitle, style: textTheme.titleMedium),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _dislikedController,
                  decoration: InputDecoration(
                    hintText: dislikedHint,
                    border: const OutlineInputBorder(),
                  ),
                  maxLines: 4,
                  onEditingComplete: _updateFoods,
                ),
              ],
              if (showDisliked && showLiked) const SizedBox(height: 24),
              if (showLiked) ...[
                Text(likedTitle, style: textTheme.titleMedium),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _likedController,
                  decoration: InputDecoration(
                    hintText: likedHint,
                    border: const OutlineInputBorder(),
                  ),
                  maxLines: 4,
                  onEditingComplete: _updateFoods,
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}
