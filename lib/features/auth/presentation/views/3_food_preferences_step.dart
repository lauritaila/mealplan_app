// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meal_plan_app/features/auth/presentation/provider/provider.dart';
import 'package:meal_plan_app/l10n/app_localizations.dart';

class FoodPreferencesStep extends ConsumerStatefulWidget {
  const FoodPreferencesStep({super.key});

  @override
  ConsumerState<FoodPreferencesStep> createState() => _FoodPreferencesStepState();
}

class _FoodPreferencesStepState extends ConsumerState<FoodPreferencesStep> {
  late final TextEditingController _dislikedController;
  late final TextEditingController _likedController;

  @override
  void initState() {
    super.initState();
    final state = ref.read(preferencesWizardProvider);
    _dislikedController = TextEditingController(text: state.dislikedFoods.join(', '));
    _likedController = TextEditingController(text: state.likedFoods.join(', '));
  }

  @override
  void dispose() {
    _dislikedController.dispose();
    _likedController.dispose();
    super.dispose();
  }
  
  void _updateFoods() {
      final disliked = _dislikedController.text.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
      final liked = _likedController.text.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
      ref.read(preferencesWizardProvider.notifier).updateDislikedFoods(disliked);
      ref.read(preferencesWizardProvider.notifier).updateLikedFoods(liked);
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context);
    
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        children: [
          const Icon(Icons.fastfood_outlined, size: 48, color: Colors.grey),
          const SizedBox(height: 16),
          Text(
            l10n.foodPreferencesTitle,
            style: textTheme.headlineSmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          
          Text(l10n.dislikedFoodsTitle, style: textTheme.titleMedium),
          const SizedBox(height: 8),
          TextFormField(
            controller: _dislikedController,
            decoration: InputDecoration(
              hintText: l10n.dislikedFoodsHint,
              border: const OutlineInputBorder(),
            ),
            maxLines: 4,
            onEditingComplete: _updateFoods,
          ),
          
          const SizedBox(height: 24),
          
          Text(l10n.likedFoodsTitle, style: textTheme.titleMedium),
          const SizedBox(height: 8),
          TextFormField(
            controller: _likedController,
            decoration: InputDecoration(
              hintText: l10n.likedFoodsHint,
              border: const OutlineInputBorder(),
            ),
            maxLines: 4,
            onEditingComplete: _updateFoods,
          ),
        ],
      ),
    );
  }
}
