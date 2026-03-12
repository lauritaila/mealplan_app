import 'package:meal_plan_app/features/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:meal_plan_app/features/grocery_list/presentation/providers/provider.dart';
import 'package:meal_plan_app/l10n/app_localizations.dart';
import 'package:meal_plan_app/config/theme/app_theme.dart';

/// Bottom sheet to add an item to a grocery list or the pantry.
///
/// [listId] — null when adding to the pantry.
class AddItemBottomSheet extends ConsumerStatefulWidget {
  final int? listId; // null = pantry mode
  const AddItemBottomSheet({super.key, this.listId});

  @override
  ConsumerState<AddItemBottomSheet> createState() => _AddItemBottomSheetState();
}

class _AddItemBottomSheetState extends ConsumerState<AddItemBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _quantityCtrl = TextEditingController();
  final _unitCtrl = TextEditingController();
  final _categoryCtrl = TextEditingController();
  DateTime? _expiryDate;

  bool _loading = false;

  bool get _isPantryMode => widget.listId == null;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _quantityCtrl.dispose();
    _unitCtrl.dispose();
    _categoryCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _loading = true);

    final l10n = AppLocalizations.of(context);
    final name = _nameCtrl.text.trim();
    final qty = double.tryParse(_quantityCtrl.text.trim()) ?? 1.0;
    final unit = _unitCtrl.text.trim().ifEmpty(l10n.addItemDefaultUnit);

    bool ok = false;
    if (_isPantryMode) {
      final expiresAt = _expiryDate?.toIso8601String().split('T').first;
      final category = _categoryCtrl.text.trim().isEmpty
          ? null
          : _categoryCtrl.text.trim();
      final result = await ref
          .read(pantryActionsProvider.notifier)
          .addItem(
            ingredientName: name,
            quantity: qty,
            unit: unit,
            category: category,
            expiresAt: expiresAt,
          );
      ok = result != null;
    } else {
      final result = await ref
          .read(groceryActionsProvider.notifier)
          .addItem(
            widget.listId!,
            ingredientName: name,
            quantity: qty,
            unit: unit,
          );
      ok = result != null;
    }

    if (!mounted) return;
    setState(() => _loading = false);
    if (ok) {
      Navigator.pop(context, true);
    } else {
      CustomSnackbar.showInfo(context, l10n.addItemErrorAdding);
    }
  }

  Future<void> _pickDate() async {
    final theme = Theme.of(context);
    final customColors = theme.extension<AppCustomColors>()!;
    final picked = await showDatePicker(
      context: context,
      initialDate: _expiryDate ?? DateTime.now().add(const Duration(days: 7)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
      builder: (context, child) {
        return Theme(
          data: theme.copyWith(
            colorScheme: theme.colorScheme.copyWith(
              primary: customColors.darkSage,
              onPrimary: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && mounted) setState(() => _expiryDate = picked);
  }

  InputDecoration _inputDecoration(String hint, BuildContext context, {IconData? prefixIcon, Widget? suffixIcon}) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final customColors = theme.extension<AppCustomColors>()!;
    
    return InputDecoration(
      hintText: hint,
      hintStyle: textTheme.bodyLarge?.copyWith(
        color: customColors.slateGrey?.withValues(alpha: 0.3),
      ),
      prefixIcon: prefixIcon != null ? Icon(prefixIcon, color: customColors.darkSage, size: 20) : null,
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: customColors.chartTabBackground,
      contentPadding: const EdgeInsets.all(20),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: BorderSide(color: customColors.darkSage!, width: 2),
      ),
    );
  }

  Widget _buildLabel(String text, BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final customColors = theme.extension<AppCustomColors>()!;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0, left: 4.0),
      child: Text(
        text.toUpperCase(),
        style: textTheme.labelSmall?.copyWith(
          fontWeight: FontWeight.w900,
          letterSpacing: 1.2,
          color: customColors.slateGrey?.withValues(alpha: 0.6),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final customColors = theme.extension<AppCustomColors>()!;
    final l10n = AppLocalizations.of(context);
    
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 40),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Center(
                  child: Container(
                    width: 48,
                    height: 5,
                    margin: const EdgeInsets.only(bottom: 32),
                    decoration: BoxDecoration(
                      color: customColors.slateGrey?.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                Text(
                  _isPantryMode ? l10n.addItemTitlePantry : l10n.addItemTitleGrocery,
                  style: textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: customColors.textDarkBlue,
                  ),
                ),
                const SizedBox(height: 32),
                
                _buildLabel(l10n.addItemIngredientNameLabel, context),
                TextFormField(
                  controller: _nameCtrl,
                  textCapitalization: TextCapitalization.sentences,
                  style: textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
                  decoration: _inputDecoration(
                    _isPantryMode ? l10n.addItemIngredientNamePantryHint : l10n.addItemIngredientNameGroceryHint,
                    context,
                    prefixIcon: _isPantryMode ? Icons.restaurant_outlined : Icons.shopping_basket_outlined,
                  ),
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? l10n.addItemIngredientNameRequired
                      : null,
                ),
                const SizedBox(height: 24),
                
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 1,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLabel(l10n.addItemQuantityLabel, context),
                          TextFormField(
                            controller: _quantityCtrl,
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            style: textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
                            decoration: _inputDecoration('0', context),
                            validator: (v) {
                              if (v == null || v.trim().isEmpty) {
                                return l10n.addItemQuantityRequired;
                              }
                              if (double.tryParse(v.trim()) == null) {
                                return l10n.addItemQuantityInvalid;
                              }
                              return null;
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      flex: 1,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLabel(l10n.addItemUnitLabel, context),
                          TextFormField(
                            controller: _unitCtrl,
                            textCapitalization: TextCapitalization.none,
                            style: textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
                            decoration: _inputDecoration(
                              l10n.addItemUnitHint,
                              context,
                              suffixIcon: Icon(Icons.keyboard_arrow_down, color: customColors.darkSage),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                
                if (_isPantryMode) ...[
                  const SizedBox(height: 24),
                  _buildLabel(l10n.addItemCategoryLabel, context),
                  TextFormField(
                    controller: _categoryCtrl,
                    textCapitalization: TextCapitalization.sentences,
                    style: textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
                    decoration: _inputDecoration(
                      l10n.addItemCategoryHint,
                      context,
                      suffixIcon: Icon(Icons.keyboard_arrow_down, color: customColors.darkSage),
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  _buildLabel(l10n.addItemExpiryLabel, context),
                  InkWell(
                    onTap: _pickDate,
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      decoration: BoxDecoration(
                        color: customColors.chartTabBackground,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                      child: Row(
                        children: [
                          Icon(Icons.calendar_today_outlined, color: customColors.darkSage, size: 20),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _expiryDate != null
                                      ? _formatDate(_expiryDate!, context)
                                      : 'mm/dd/yyyy',
                                  style: textTheme.bodyLarge?.copyWith(
                                    color: _expiryDate != null ? customColors.textDarkBlue : customColors.slateGrey?.withValues(alpha: 0.3),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(
                            _expiryDate != null ? Icons.clear : Icons.arrow_forward_ios,
                            color: customColors.slateGrey?.withValues(alpha: 0.3),
                            size: 16,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 48),
                
                SizedBox(
                  width: double.infinity,
                  height: 64,
                  child: FilledButton(
                    onPressed: _loading ? null : _submit,
                    style: FilledButton.styleFrom(
                      backgroundColor: customColors.darkSage,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      elevation: 2,
                    ),
                    child: _loading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(strokeWidth: 3, color: Colors.white),
                          )
                        : Text(
                            _isPantryMode ? l10n.addItemButtonPantry : l10n.addItemButtonGrocery,
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime d, BuildContext context) {
    return DateFormat('MM/dd/yyyy', Localizations.localeOf(context).toString()).format(d);
  }
}

extension on String {
  String ifEmpty(String fallback) => isEmpty ? fallback : this;
}
