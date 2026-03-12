import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meal_plan_app/config/theme/app_theme.dart';
import 'package:meal_plan_app/features/grocery_list/domain/entities/entities.dart';
import 'package:meal_plan_app/features/grocery_list/presentation/providers/grocery_actions_provider.dart';
import 'package:meal_plan_app/features/grocery_list/presentation/providers/grocery_lists_provider.dart';
import 'package:meal_plan_app/l10n/app_localizations.dart';

/// Shows a bottom sheet for selecting an existing grocery list or creating a
/// new one on the fly. Returns the chosen [GroceryList], or null if dismissed.
Future<GroceryList?> showSelectOrCreateGroceryListSheet({
  required BuildContext context,
  required String title,
}) {
  return showModalBottomSheet<GroceryList?>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
    ),
    builder: (_) => _SelectGroceryListSheet(title: title),
  );
}

class _SelectGroceryListSheet extends ConsumerStatefulWidget {
  final String title;
  const _SelectGroceryListSheet({required this.title});

  @override
  ConsumerState<_SelectGroceryListSheet> createState() =>
      _SelectGroceryListSheetState();
}

class _SelectGroceryListSheetState
    extends ConsumerState<_SelectGroceryListSheet> {
  bool _creating = false;
  final _nameController = TextEditingController();
  String? _createError;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final customColors = theme.extension<AppCustomColors>()!;
    final textTheme = theme.textTheme;
    final listsAsync = ref.watch(groceryListsProvider);

    return Container(
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        left: 24,
        right: 24,
        top: 16,
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle
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
            const SizedBox(height: 32),
            Text(
              widget.title,
              textAlign: TextAlign.center,
              style: textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w900,
                color: customColors.textDarkBlue,
              ),
            ),
            const SizedBox(height: 24),

            // Existing lists
            listsAsync.when(
              data: (lists) {
                if (lists.isEmpty && !_creating) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      AppLocalizations.of(context).selectGroceryListEmpty,
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                  );
                }
                return Column(
                  children: lists
                      .map(
                        (list) => Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          decoration: BoxDecoration(
                            color: customColors.chartTabBackground,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                            leading: Icon(Icons.shopping_cart_outlined, color: customColors.darkSage),
                            title: Text(
                              list.name,
                              style: textTheme.bodyLarge?.copyWith(
                                fontWeight: FontWeight.w700,
                                color: customColors.textDarkBlue,
                              ),
                            ),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            onTap: () => Navigator.of(context).pop(list),
                          ),
                        ),
                      )
                      .toList(),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Text(
                AppLocalizations.of(context).groceryListsErrorLoading,
                style: TextStyle(color: theme.colorScheme.error),
              ),
            ),

            const SizedBox(height: 8),
            Divider(color: customColors.slateGrey?.withValues(alpha: 0.1)),
            const SizedBox(height: 8),

            // Create new section
            if (!_creating)
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: customColors.darkSage!.withValues(alpha: 0.2)),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  leading: Icon(Icons.add_rounded, color: customColors.darkSage),
                  title: Text(
                    AppLocalizations.of(context).selectGroceryListNewList,
                    style: textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: customColors.darkSage,
                    ),
                  ),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  onTap: () => setState(() => _creating = true),
                ),
              )
            else ...[
              TextField(
                controller: _nameController,
                autofocus: true,
                style: textTheme.bodyLarge?.copyWith(color: customColors.textDarkBlue),
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context).listNameLabel,
                  labelStyle: TextStyle(color: customColors.slateGrey),
                  errorText: _createError,
                  filled: true,
                  fillColor: customColors.chartTabBackground,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: customColors.darkSage!, width: 2),
                  ),
                ),
                onSubmitted: (_) => _createAndReturn(),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: customColors.slateGrey,
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        side: BorderSide(color: customColors.slateGrey!.withValues(alpha: 0.2)),
                      ),
                      onPressed: () => setState(() {
                        _creating = false;
                        _createError = null;
                        _nameController.clear();
                      }),
                      child: Text(
                        AppLocalizations.of(context).cancel.toUpperCase(),
                        style: const TextStyle(fontWeight: FontWeight.w800, letterSpacing: 1.1),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: customColors.darkSage,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        elevation: 0,
                      ),
                      onPressed: _createAndReturn,
                      child: Text(
                        AppLocalizations.of(context).create.toUpperCase(),
                        style: const TextStyle(fontWeight: FontWeight.w800, letterSpacing: 1.1),
                      ),
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Future<void> _createAndReturn() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      if (!mounted) return;
      setState(() => _createError = AppLocalizations.of(context).listNameEmptyError);
      return;
    }
    setState(() => _createError = null);
    try {
      final result = await ref
          .read(groceryActionsProvider.notifier)
          .createList(name: name);
      if (!mounted) return;
      if (result != null) {
        Navigator.of(context).pop(result);
      } else {
        setState(() => _createError = AppLocalizations.of(context).createListErrorCreate);
      }
    } catch (_) {
      if (!mounted) return;
      setState(() => _createError = AppLocalizations.of(context).createListErrorCreate);
    }
  }
}
