import 'package:flutter/material.dart';
import 'package:meal_plan_app/config/theme/app_theme.dart';
import 'package:meal_plan_app/features/meal_plan/presentation/providers/provider.dart';
import 'package:meal_plan_app/l10n/app_localizations.dart';

class DeleteEntrySheet extends StatefulWidget {
  final int entryId;
  final MealPlanEntryActions actionsNotifier;
  final VoidCallback onDeleted;

  const DeleteEntrySheet({
    super.key,
    required this.entryId,
    required this.actionsNotifier,
    required this.onDeleted,
  });

  @override
  State<DeleteEntrySheet> createState() => _DeleteEntrySheetState();
}

class _DeleteEntrySheetState extends State<DeleteEntrySheet> {
  bool _isLoading = false;
  bool _removeShoppingList = false;
  String? _error;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final customColors = theme.extension<AppCustomColors>()!;
    final textTheme = theme.textTheme;
    final l10n = AppLocalizations.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Center(
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: theme.colorScheme.errorContainer.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.delete_outline_rounded,
                color: theme.colorScheme.error,
                size: 36,
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            l10n.deleteMealDialogTitle,
            textAlign: TextAlign.center,
            style: textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w900,
              color: customColors.textDarkBlue,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            l10n.deleteMealDialogMessage,
            textAlign: TextAlign.center,
            style: textTheme.bodyMedium?.copyWith(
              color: customColors.slateGrey,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 24),
          Container(
            decoration: BoxDecoration(
              color: customColors.chartTabBackground,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: customColors.slateGrey!.withValues(alpha: 0.1)),
            ),
            child: CheckboxListTile(
              value: _removeShoppingList,
              onChanged: (v) => setState(() => _removeShoppingList = v ?? false),
              title: Text(
                l10n.alsoRemoveFromGrocery,
                style: textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: customColors.textDarkBlue,
                ),
              ),
              controlAffinity: ListTileControlAffinity.leading,
              activeColor: customColors.darkSage,
              checkColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
          ),
          const SizedBox(height: 32),
          if (_error != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Text(
                _error!,
                style: const TextStyle(color: Colors.red, fontSize: 13),
                textAlign: TextAlign.center,
              ),
            ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: theme.colorScheme.error,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 20),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              elevation: 0,
            ),
            onPressed: _isLoading ? null : _confirm,
            child: _isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : Text(
                    l10n.deleteAction.toUpperCase(),
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.1,
                    ),
                  ),
          ),
          const SizedBox(height: 16),
          TextButton(
            onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
            child: Text(
              l10n.cancel.toUpperCase(),
              style: TextStyle(
                color: customColors.slateGrey,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.1,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _confirm() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    await widget.actionsNotifier.deleteEntry(
      widget.entryId,
      removeShoppingList: _removeShoppingList,
    );

    // ignore: invalid_use_of_visible_for_testing_member, invalid_use_of_protected_member
    final state = widget.actionsNotifier.state;
    if (state.status == MealPlanEntryActionStatus.success) {
      if (!mounted) return;
      Navigator.of(context).pop();
      widget.onDeleted();
      widget.actionsNotifier.reset();
    } else {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _error = state.errorMessage ?? AppLocalizations.of(context).genericDeleteError;
      });
      widget.actionsNotifier.reset();
    }
  }
}
