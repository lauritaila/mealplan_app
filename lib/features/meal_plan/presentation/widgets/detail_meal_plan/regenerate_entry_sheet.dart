import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meal_plan_app/config/theme/app_theme.dart';
import 'package:meal_plan_app/features/meal_plan/domain/domain.dart';
import 'package:meal_plan_app/features/meal_plan/presentation/providers/provider.dart';
import 'package:meal_plan_app/features/profile/presentation/providers/preferences_details_provider.dart';
import 'package:meal_plan_app/l10n/app_localizations.dart';
import 'package:meal_plan_app/features/auth/domain/entities/user.dart';

class RegenerateEntrySheet extends ConsumerStatefulWidget {
  final int entryId;
  final String mealType;
  final PermissionDetails? userPermissions;
  final MealPlanEntryActions actionsNotifier;

  const RegenerateEntrySheet({
    super.key,
    required this.entryId,
    required this.mealType,
    required this.userPermissions,
    required this.actionsNotifier,
  });

  @override
  ConsumerState<RegenerateEntrySheet> createState() => _RegenerateEntrySheetState();
}

class _RegenerateEntrySheetState extends ConsumerState<RegenerateEntrySheet> {
  final _descController = TextEditingController();
  int _selectedDuration = 1;
  int _diners = 2;
  bool _isLoading = false;
  bool _usePantry = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final preferences = ref.read(preferencesDetailsProvider);
      final prefCount = preferences.householdSize;
      if (mounted) {
        setState(() {
          _diners = prefCount > 0 ? prefCount : 2;
        });
      }
    });
  }

  @override
  void dispose() {
    _descController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final customColors = theme.extension<AppCustomColors>()!;
    final textTheme = theme.textTheme;
    final l10n = AppLocalizations.of(context);

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom + 16,
          top: 16,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
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
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      l10n.regenerateRecipePromptTitle,
                      style: textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w900,
                        color: customColors.textDarkBlue,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l10n.regenerateRecipePromptSubtitle,
                      style: textTheme.bodyMedium?.copyWith(
                        color: customColors.slateGrey,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: customColors.chartTabBackground,
                        border: Border.all(color: customColors.darkSage!.withValues(alpha: 0.1)),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.info_outline, color: customColors.darkSage, size: 20),
                          const SizedBox(width: 12),
                          Expanded(
                            child: RichText(
                              text: TextSpan(
                                children: [
                                  TextSpan(
                                    text: '${l10n.regenerateRecipeNotePrefix} ',
                                    style: textTheme.labelSmall?.copyWith(
                                      color: customColors.darkSage,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                  TextSpan(
                                    text: l10n.regenerateRecipeNoteText,
                                    style: textTheme.bodySmall?.copyWith(
                                      color: customColors.slateGrey,
                                      height: 1.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(l10n.durationTitle, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                    const SizedBox(height: 8),
                    Row(
                      children: [1, 3, 5].map((d) {
                        final isSelected = _selectedDuration == d;
                        return Expanded(
                          child: Padding(
                            padding: EdgeInsets.only(right: d == 5 ? 0 : 8),
                            child: ChoiceChip(
                                label: Center(
                                  child: Text(
                                    l10n.daysLabel(d).toUpperCase(),
                                    style: const TextStyle(fontWeight: FontWeight.w900, letterSpacing: 0.5, fontSize: 12),
                                  ),
                                ),
                                selected: isSelected,
                                onSelected: (_) => setState(() => _selectedDuration = d),
                                selectedColor: customColors.darkSage,
                                backgroundColor: customColors.chartTabBackground,
                                labelStyle: TextStyle(
                                  color: isSelected ? Colors.white : customColors.slateGrey,
                                ),
                              showCheckmark: false,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  side: BorderSide.none,
                                ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 24),
                    Text(l10n.dinersTitle, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFB),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          InkWell(
                            onTap: () => setState(() { if (_diners > 1) _diners--; }),
                            borderRadius: BorderRadius.circular(24),
                            child: Container(
                              width: 40, height: 40,
                              decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white, boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 6, offset: const Offset(0, 2))]),
                              child: const Icon(Icons.remove, size: 22, color: Color(0xFF002140)),
                            ),
                          ),
                          Expanded(
                            child: Center(
                              child: Text(
                                l10n.peopleCount(_diners),
                                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Color(0xFF002140)),
                              ),
                            ),
                          ),
                          InkWell(
                            onTap: () => setState(() => _diners++),
                            borderRadius: BorderRadius.circular(24),
                            child: Container(
                              width: 40, height: 40,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.06),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  )
                                ],
                              ),
                              child: Icon(Icons.add, size: 24, color: customColors.textDarkBlue),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(l10n.notesOptionalTitle, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _descController,
                      maxLines: 4,
                      style: textTheme.bodyLarge?.copyWith(color: customColors.textDarkBlue),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: customColors.chartTabBackground,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
                        hintText: l10n.regenerateNotesHint,
                        hintStyle: textTheme.bodyMedium?.copyWith(color: customColors.slateGrey?.withValues(alpha: 0.6)),
                        contentPadding: const EdgeInsets.all(20),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                l10n.usePantryTitle,
                                style: textTheme.labelLarge?.copyWith(
                                  fontWeight: FontWeight.w900,
                                  color: customColors.textDarkBlue,
                                ),
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
                        Switch(
                          value: _usePantry,
                          onChanged: (val) => setState(() => _usePantry = val),
                          activeThumbColor: Colors.white,
                          activeTrackColor: customColors.darkSage,
                        ),
                      ],
                    ),
                    if (_error != null) ...[
                      const SizedBox(height: 12),
                      Text(_error!, style: const TextStyle(color: Colors.red)),
                    ],
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: customColors.darkSage,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    elevation: 0,
                  ),
                  onPressed: _isLoading ? null : _submit,
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : Text(
                          l10n.regenerateRecipeButtonTitle.toUpperCase(),
                          style: const TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.1),
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submit() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    final request = ChangeMealPlanRecipeRequest(
      description: _descController.text.trim().isEmpty
          ? null
          : _descController.text.trim(),
      mealTypes: [widget.mealType],
      maxTotalTimeMinutes: null,
      usePantry: _usePantry ? true : null,
    );

    final updated = await widget.actionsNotifier.changeRecipe(
      widget.entryId,
      request,
    );

    if (!mounted) return;
    if (updated != null) {
      Navigator.of(context).pop(updated);
    } else {
      setState(() {
        _isLoading = false;
        _error = AppLocalizations.of(context).genericRegenerateError;
      });
    }
  }
}
