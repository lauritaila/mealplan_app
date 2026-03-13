// ignore_for_file: file_names
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meal_plan_app/features/auth/presentation/provider/provider.dart';
import 'package:meal_plan_app/features/auth/presentation/widgets/widgets_auth.dart';
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
  late final FocusNode _dislikedFocus;
  late final FocusNode _likedFocus;

  @override
  void initState() {
    super.initState();
    final state = ref.read(preferencesWizardProvider);
    _dislikedController = TextEditingController(
      text: state.dislikedFoods.join(', '),
    );
    _likedController = TextEditingController(text: state.likedFoods.join(', '));
    _dislikedFocus = FocusNode()..addListener(_updateFoods);
    _likedFocus = FocusNode()..addListener(_updateFoods);
  }

  @override
  void dispose() {
    _dislikedFocus.dispose();
    _likedFocus.dispose();
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

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Column(
      children: [
        AuthHeader(
          title: l10n.foodPreferencesTitle,
          subtitle: l10n.foodPreferencesSubtitle,
          icon: Icons.restaurant_rounded,
        ),
        const SizedBox(height: 32),
        _PreferenceInputField(
          label: l10n.likedFoodsTitle.toUpperCase(),
          hint: l10n.likedFoodsHint,
          controller: _likedController,
          focusNode: _likedFocus,
          trailingIcon: Icons.sentiment_satisfied_alt_rounded,
        ),
        const SizedBox(height: 24),
        _PreferenceInputField(
          label: l10n.dislikedFoodsTitle.toUpperCase(),
          hint: l10n.dislikedFoodsHint,
          controller: _dislikedController,
          focusNode: _dislikedFocus,
          trailingIcon: Icons.sentiment_dissatisfied_rounded,
        ),
      ],
    );
  }
}

class _PreferenceInputField extends StatelessWidget {
  final String label;
  final String hint;
  final TextEditingController controller;
  final FocusNode focusNode;
  final IconData trailingIcon;

  const _PreferenceInputField({
    required this.label,
    required this.hint,
    required this.controller,
    required this.focusNode,
    required this.trailingIcon,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4),
          child: Text(
            label,
            style: textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: colors.onSurface,
              letterSpacing: 0.5,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: colors.outlineVariant),
          ),
          child: Column(
            children: [
              TextFormField(
                controller: controller,
                focusNode: focusNode,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: hint,
                  hintStyle: TextStyle(color: colors.onSurfaceVariant.withValues(alpha: 0.5)),
                  contentPadding: const EdgeInsets.all(16),
                  border: InputBorder.none,
                ),
                style: textTheme.bodyLarge?.copyWith(color: colors.onSurfaceVariant),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Icon(trailingIcon, color: colors.onSurfaceVariant.withValues(alpha: 0.4), size: 20),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
