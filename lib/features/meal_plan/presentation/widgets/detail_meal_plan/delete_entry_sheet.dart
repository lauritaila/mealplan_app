import 'package:flutter/material.dart';
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
    final l10n = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Center(
            child: Container(
              width: 72,
              height: 72,
              decoration: const BoxDecoration(
                color: Color(0xFFF4F7F5),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.delete_outline_rounded,
                color: Color(0xFF576F5F),
                size: 32,
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            l10n.deleteMealDialogTitle,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: Color(0xFF1A1E1B),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            l10n.deleteMealDialogMessage,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 15,
              height: 1.5,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 24),
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFB),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: CheckboxListTile(
              value: _removeShoppingList,
              onChanged: (v) => setState(() => _removeShoppingList = v ?? false),
              title: Text(
                l10n.alsoRemoveFromGrocery,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1A1E1B),
                ),
              ),
              controlAffinity: ListTileControlAffinity.leading,
              activeColor: const Color(0xFF576F5F),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
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
              backgroundColor: const Color(0xFF6A8773),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 18),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 4,
              shadowColor: Colors.black.withValues(alpha: 0.2),
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
                    l10n.deleteAction,
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                    ),
                  ),
          ),
          const SizedBox(height: 16),
          TextButton(
            onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
            child: Text(
              l10n.cancel,
              style: const TextStyle(
                color: Color(0xFF576F5F),
                fontWeight: FontWeight.w700,
                fontSize: 16,
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
