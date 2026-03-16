import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:meal_plan_app/features/auth/presentation/provider/provider.dart';
import 'package:meal_plan_app/features/meal_plan/presentation/providers/provider.dart';
import 'package:meal_plan_app/l10n/app_localizations.dart';
import 'package:meal_plan_app/features/profile/presentation/providers/preferences_details_provider.dart';
import 'package:meal_plan_app/config/theme/app_theme.dart';

class NewMealPlanScreen extends ConsumerStatefulWidget {
  const NewMealPlanScreen({super.key});

  @override
  ConsumerState<NewMealPlanScreen> createState() => _NewMealPlanScreenState();
}

class _NewMealPlanScreenState extends ConsumerState<NewMealPlanScreen> {
  final _descriptionController = TextEditingController();
  final Set<String> _selectedMealTypes = {
    'breakfast',
    'lunch',
    'dinner',
    'snack',
  };
  int _selectedDays = 5;
  int _peopleCount = 2;
  bool _usePantry = true;
  DateTime? _startDate;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final preferences = ref.read(preferencesDetailsProvider);
      final prefCount = preferences.householdSize;
      setState(() {
        _peopleCount = prefCount > 0 ? prefCount : 2;
      });
    });
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  void _resetForm() {
    final availableDurations = ref.read(availableDurationsProvider);
    final availableMealTypes = ref.read(availableMealTypesProvider);
    final showMealTypeSelection = ref.read(shouldShowMealTypeSelectionProvider);

    setState(() {
      _selectedDays = availableDurations.contains(5)
          ? 5
          : availableDurations.first;
      final preferences = ref.read(preferencesDetailsProvider);
      final prefCount = preferences.householdSize;
      _peopleCount = prefCount > 0 ? prefCount : 2;
      if (showMealTypeSelection) {
        _selectedMealTypes
          ..clear()
          ..addAll(availableMealTypes);
      } else {
        _selectedMealTypes
          ..clear()
          ..add(availableMealTypes.first);
      }
      _descriptionController.clear();
      _usePantry = true;
      _startDate = null;
    });
    ref.read(mealPlanGeneratorProvider.notifier).reset();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _validateSelection();
  }

  void _validateSelection() {
    final availableDurations = ref.read(availableDurationsProvider);
    final availableMealTypes = ref.read(availableMealTypesProvider);
    final showMealTypeSelection = ref.read(shouldShowMealTypeSelectionProvider);

    bool changed = false;
    int newSelectedDays = _selectedDays;
    Set<String> newSelectedMealTypes = Set.from(_selectedMealTypes);

    if (!availableDurations.contains(_selectedDays)) {
      newSelectedDays = availableDurations.isEmpty ? 5 : availableDurations.first;
      changed = true;
    }

    if (showMealTypeSelection) {
      final beforeCount = newSelectedMealTypes.length;
      newSelectedMealTypes.retainWhere((type) => availableMealTypes.contains(type));
      if (newSelectedMealTypes.isEmpty && availableMealTypes.isNotEmpty) {
        newSelectedMealTypes.addAll(availableMealTypes);
      }
      if (newSelectedMealTypes.length != beforeCount) changed = true;
    } else {
      if (newSelectedMealTypes.length != 1 || !newSelectedMealTypes.contains(availableMealTypes.first)) {
        newSelectedMealTypes.clear();
        if (availableMealTypes.isNotEmpty) {
          newSelectedMealTypes.add(availableMealTypes.first);
        }
        changed = true;
      }
    }

    if (changed) {
      setState(() {
        _selectedDays = newSelectedDays;
        _selectedMealTypes.clear();
        _selectedMealTypes.addAll(newSelectedMealTypes);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final customColors = theme.extension<AppCustomColors>() ?? const AppCustomColors();
    final textTheme = theme.textTheme;
    final state = ref.watch(mealPlanGeneratorProvider);
    final isLoading = state.status == MealPlanGeneratorStatus.loading;
    final canGenerateAsync = ref.watch(canGenerateMealPlanProvider);
    final authState = ref.watch(authProvider);

    final bool isPremium = authState is AuthenticatedAuthState &&
        !(authState.user.planName?.toLowerCase().contains('free') ?? true);

    final availableDurations = ref.watch(availableDurationsProvider);
    final availableMealTypes = ref.watch(availableMealTypesProvider);
    final showMealTypeSelection = ref.watch(shouldShowMealTypeSelectionProvider);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          l10n.newPlanTitle,
          style: textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w900,
            color: customColors.textDarkBlue,
          ),
        ),
        centerTitle: true,
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        iconTheme: IconThemeData(color: customColors.textDarkBlue),
        actions: [
          TextButton(
            onPressed: _resetForm,
            child: Text(
              l10n.clear.toUpperCase(),
              style: textTheme.labelLarge?.copyWith(
                color: customColors.darkSage,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.1,
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 12),
                  Text(
                    l10n.configurePlanTitle,
                    style: textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                      color: customColors.textDarkBlue,
                      letterSpacing: -0.5,
                      height: 1.1,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.configurePlanSubtitle,
                    style: textTheme.bodyMedium?.copyWith(
                      color: customColors.slateGrey,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Eligibility quota banner
                  canGenerateAsync.when(
                    data: (canGen) {
                      final remaining = canGen.mealPlanGenerateRemaining;
                      final limit = canGen.mealPlanGenerateLimit;
                      if (remaining <= 0) {
                        return _QuotaBanner(
                          icon: Icons.block_rounded,
                          color: Colors.red,
                          text: l10n.generationLimitReached,
                          onTap: () => context.push('/premium', extra: {
                            'title': l10n.planLimitReachedTitle,
                            'message': l10n.planLimitReachedMessage,
                          }),
                        );
                      }
                      if (remaining <= 1 || (limit > 0 && remaining / limit < 0.4)) {
                        return _QuotaBanner(
                          icon: Icons.warning_amber_rounded,
                          color: Colors.orange,
                          text: l10n.generationsRemainingWarning(remaining, limit),
                          onTap: null,
                        );
                      }
                      return const SizedBox.shrink();
                    },
                    loading: () => const SizedBox.shrink(),
                    error: (error, stack) => const SizedBox.shrink(),
                  ),
                  const SizedBox(height: 8),
                  _Section(
                    title: l10n.durationTitle,
                    child: Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: availableDurations
                          .map(
                            (days) => _PillOption(
                              label: l10n.daysLabel(days),
                              selected: _selectedDays == days,
                              onTap: () => setState(() => _selectedDays = days),
                            ),
                          )
                          .toList(),
                    ),
                  ),
                  _Section(
                    title: l10n.startDateLabel,
                    child: InkWell(
                      onTap: () async {
                        final now = DateTime.now();
                        final firstDate = now;
                        final lastDate = now.add(const Duration(days: 90));
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: _startDate ?? now,
                          firstDate: firstDate,
                          lastDate: lastDate,
                          builder: (context, child) {
                            return Theme(
                              data: theme.copyWith(
                                colorScheme: theme.colorScheme.copyWith(
                                  primary: customColors.darkSage,
                                  onPrimary: Colors.white,
                                  onSurface: customColors.textDarkBlue,
                                ),
                              ),
                              child: child!,
                            );
                          },
                        );
                        if (picked != null) {
                          setState(() => _startDate = picked);
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                        decoration: BoxDecoration(
                          color: customColors.chartTabBackground,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.calendar_today_outlined, color: customColors.darkSage, size: 20),
                            const SizedBox(width: 12),
                            Text(
                              _startDate != null 
                                ? '${_startDate!.day}/${_startDate!.month}/${_startDate!.year}'
                                : l10n.selectDateOptional,
                              style: textTheme.bodyLarge?.copyWith(
                                fontWeight: FontWeight.w700,
                                color: _startDate != null ? customColors.textDarkBlue : customColors.slateGrey,
                              ),
                            ),
                            const Spacer(),
                            if (_startDate != null)
                              IconButton(
                                icon: const Icon(Icons.close, size: 18),
                                onPressed: () => setState(() => _startDate = null),
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  _Section(
                    title: l10n.dinersTitle,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: customColors.chartTabBackground,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          _IconCircleButton(
                            icon: Icons.remove,
                            onTap: () => setState(
                              () => _peopleCount = (_peopleCount > 1)
                                  ? _peopleCount - 1
                                  : 1,
                            ),
                          ),
                          Expanded(
                            child: Center(
                              child: Text(
                                l10n.peopleCount(_peopleCount),
                                style: textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w800,
                                  color: customColors.textDarkBlue,
                                ),
                              ),
                            ),
                          ),
                          _IconCircleButton(
                            icon: Icons.add,
                            onTap: () => setState(() => _peopleCount += 1),
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (showMealTypeSelection)
                    _Section(
                      title: l10n.mealTypesTitle,
                      child: Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: [
                          if (availableMealTypes.contains('breakfast'))
                            _MealTypePill(
                              label: l10n.mealTypeBreakfast,
                              selected: _selectedMealTypes.contains('breakfast'),
                              onTap: () => _toggleMealType('breakfast'),
                            ),
                          if (availableMealTypes.contains('lunch'))
                            _MealTypePill(
                              label: l10n.mealTypeLunch,
                              selected: _selectedMealTypes.contains('lunch'),
                              onTap: () => _toggleMealType('lunch'),
                            ),
                          if (availableMealTypes.contains('dinner'))
                            _MealTypePill(
                              label: l10n.mealTypeDinner,
                              selected: _selectedMealTypes.contains('dinner'),
                              onTap: () => _toggleMealType('dinner'),
                            ),
                          if (availableMealTypes.contains('snack'))
                            _MealTypePill(
                              label: l10n.mealTypeSnack,
                              selected: _selectedMealTypes.contains('snack'),
                              onTap: () => _toggleMealType('snack'),
                            ),
                        ],
                      ),
                    ),
                  _Section(
                    title: l10n.notesOptionalTitle,
                    child: TextField(
                      controller: _descriptionController,
                      maxLines: 4,
                      style: textTheme.bodyLarge?.copyWith(color: customColors.textDarkBlue),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: customColors.chartTabBackground,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: BorderSide.none,
                        ),
                        hintText: l10n.notesHint,
                        hintStyle: textTheme.bodyMedium?.copyWith(
                          color: customColors.slateGrey?.withValues(alpha: 0.5),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  _Section(
                    title: '',
                    child: GestureDetector(
                      onTap: !isPremium ? () => context.push('/premium', extra: {
                        'title': l10n.premiumFeatureTitle,
                        'message': l10n.cookingAssistantPremiumMessage,
                      }) : null,
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: customColors.chartTabBackground,
                          borderRadius: BorderRadius.circular(20),
                          border: !isPremium ? Border.all(
                            color: customColors.darkSage?.withValues(alpha: 0.3) ?? Colors.transparent,
                          ) : null,
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        l10n.usePantryLabel,
                                        style: textTheme.titleSmall?.copyWith(
                                          fontWeight: FontWeight.w800,
                                          color: customColors.textDarkBlue,
                                        ),
                                      ),
                                      if (!isPremium) ...[
                                        const SizedBox(width: 8),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                          decoration: BoxDecoration(
                                            color: customColors.darkSage?.withValues(alpha: 0.1),
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(Icons.workspace_premium_rounded, size: 12, color: customColors.darkSage),
                                              const SizedBox(width: 4),
                                              Text(
                                                'PRO',
                                                style: textTheme.labelSmall?.copyWith(
                                                  color: customColors.darkSage,
                                                  fontWeight: FontWeight.w900,
                                                  fontSize: 10,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    l10n.usePantrySubtitle,
                                    style: textTheme.bodySmall?.copyWith(
                                      color: customColors.slateGrey,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (!isPremium)
                              Icon(Icons.lock_outline_rounded, color: customColors.darkSage, size: 24)
                            else
                              Switch(
                                value: _usePantry,
                                onChanged: (val) {
                                  setState(() {
                                    _usePantry = val;
                                  });
                                },
                                activeThumbColor: Colors.white,
                                activeTrackColor: customColors.darkSage,
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: isLoading ? null : _onGenerate,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: customColors.darkSage,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        elevation: 0,
                        textStyle: textTheme.labelLarge?.copyWith(
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.5,
                        ),
                      ),
                      child: isLoading
                          ? SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                color: theme.colorScheme.onPrimary,
                                strokeWidth: 2,
                              ),
                            )
                          : Text(l10n.continueLabel.toUpperCase()),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _toggleMealType(String type) {
    final availableMealTypes = ref.read(availableMealTypesProvider);
    if (!availableMealTypes.contains(type)) return;
    setState(() {
      if (_selectedMealTypes.contains(type)) {
        _selectedMealTypes.remove(type);
      } else {
        _selectedMealTypes.add(type);
      }
    });
  }

  void _onGenerate() {
    // Check if the user has generations remaining before proceeding
    final canGenerateAsync = ref.read(canGenerateMealPlanProvider);
    final canGenValue = canGenerateAsync.valueOrNull;
    if (canGenValue != null && !canGenValue.canGenerate) {
      final l10n = AppLocalizations.of(context);
      context.push('/premium', extra: {
        'title': l10n.planLimitReachedTitle,
        'message': l10n.planLimitReachedMessage,
      });
      return;
    }

    final peopleCount = _peopleCount;
    context.push(
      '/meal-plan/loading',
      extra: {
        'description': _descriptionController.text.trim(),
        'numberOfDays': _selectedDays,
        'quantityOfPeople': peopleCount,
        'mealTypes': _selectedMealTypes.toList(),
        'usePantry': _usePantry,
        'startDate': _startDate != null 
            ? '${_startDate!.year}-${_startDate!.month.toString().padLeft(2, '0')}-${_startDate!.day.toString().padLeft(2, '0')}' 
            : null,
      },
    );
  }
}

class _QuotaBanner extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String text;
  final VoidCallback? onTap;

  const _QuotaBanner({
    required this.icon,
    required this.color,
    required this.text,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                text,
                style: textTheme.bodyMedium?.copyWith(
                  color: color.withValues(alpha: 0.9),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            if (onTap != null)
              Icon(Icons.chevron_right_rounded, color: color, size: 20),
          ],
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final Widget child;

  const _Section({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    if (title.isEmpty) return Padding(padding: const EdgeInsets.symmetric(vertical: 10), child: child);
    final theme = Theme.of(context);
    final customColors = theme.extension<AppCustomColors>()!;
    final textTheme = theme.textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title.toUpperCase(),
            style: textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.w800,
              color: customColors.darkSage,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}

class _PillOption extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _PillOption({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final customColors = theme.extension<AppCustomColors>()!;
    final textTheme = theme.textTheme;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: selected ? customColors.chartTabBackground : Colors.white,
          border: Border.all(
            color: selected ? (customColors.darkSage ?? Colors.green) : Colors.grey.shade200,
            width: selected ? 1.5 : 1.0,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          label,
          style: textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.w800,
            color: selected ? customColors.darkSage : customColors.textDarkBlue,
          ),
        ),
      ),
    );
  }
}

class _IconCircleButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _IconCircleButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final customColors = theme.extension<AppCustomColors>()!;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 8,
              offset: const Offset(0, 2),
            )
          ]
        ),
        child: Icon(icon, size: 24, color: customColors.textDarkBlue),
      ),
    );
  }
}

class _MealTypePill extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _MealTypePill({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final customColors = theme.extension<AppCustomColors>()!;
    final textTheme = theme.textTheme;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        decoration: BoxDecoration(
          color: selected ? customColors.darkSage : Colors.white,
          border: Border.all(
            color: selected ? (customColors.darkSage ?? Colors.green) : Colors.grey.shade200,
            width: 1.0,
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w800,
            color: selected ? Colors.white : customColors.textDarkBlue,
          ),
        ),
      ),
    );
  }
}
