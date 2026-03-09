import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
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
    final listsAsync = ref.watch(groceryListsProvider);

    return Padding(
      padding: EdgeInsets.only(
        bottom:
            MediaQuery.of(context).viewInsets.bottom,
        left: 20,
        right: 20,
        top: 20,
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
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              widget.title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 16),

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
                        (list) => ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: const Icon(Icons.shopping_cart_outlined),
                          title: Text(list.name),
                          onTap: () => Navigator.of(context).pop(list),
                        ),
                      )
                      .toList(),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, __) => Text(
                AppLocalizations.of(context).groceryListsErrorLoading,
                style: TextStyle(color: theme.colorScheme.error),
              ),
            ),

            const Divider(),

            // Create new section
            if (!_creating)
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.add),
                title: Text(AppLocalizations.of(context).selectGroceryListNewList),
                onTap: () => setState(() => _creating = true),
              )
            else ...[
              TextField(
                controller: _nameController,
                autofocus: true,
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context).listNameLabel,
                  errorText: _createError,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onSubmitted: (_) => _createAndReturn(),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => setState(() {
                        _creating = false;
                        _createError = null;
                        _nameController.clear();
                      }),
                      child: Text(AppLocalizations.of(context).cancel),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed: _createAndReturn,
                      child: Text(AppLocalizations.of(context).create),
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
