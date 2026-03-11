import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:meal_plan_app/features/grocery_list/presentation/providers/provider.dart';
import 'package:meal_plan_app/l10n/app_localizations.dart';

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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.addItemErrorAdding)),
      );
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _expiryDate ?? DateTime.now().add(const Duration(days: 7)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
    );
    if (picked != null && mounted) setState(() => _expiryDate = picked);
  }

  InputDecoration _inputDecoration(String hint, {IconData? prefixIcon, Widget? suffixIcon}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Color(0xFF9E9E9E), fontSize: 14),
      prefixIcon: prefixIcon != null ? Icon(prefixIcon, color: const Color(0xFF7BA082)) : null,
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFFE8ECE7), width: 1),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFFE8ECE7), width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFF7BA082), width: 1.5),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0, left: 2.0),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: Color(0xFF4A5D4E), // Dark green-grey
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFFF8F6F6),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Handle bar
                Center(
                  child: Container(
                    width: 36,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 24),
                    decoration: BoxDecoration(
                      color: const Color(0xFFC7CEC5),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                // Title and clear button
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _isPantryMode ? l10n.addItemTitlePantry : l10n.addItemTitleGrocery,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF2C392D),
                      ),
                    ),
                    if (!_isPantryMode)
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close, color: Color(0xFF7BA082)),
                      ),
                  ],
                ),
                const SizedBox(height: 20),
                
                // Ingredient Name
                _buildLabel(l10n.addItemIngredientNameLabel),
                TextFormField(
                  controller: _nameCtrl,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: _inputDecoration(
                    _isPantryMode ? l10n.addItemIngredientNamePantryHint : l10n.addItemIngredientNameGroceryHint,
                    prefixIcon: _isPantryMode ? Icons.restaurant_outlined : Icons.shopping_basket_outlined,
                  ),
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? l10n.addItemIngredientNameRequired
                      : null,
                ),
                const SizedBox(height: 16),
                
                // Quantity and Unit Row
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 1,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLabel(l10n.addItemQuantityLabel),
                          TextFormField(
                            controller: _quantityCtrl,
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            decoration: _inputDecoration('0'),
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
                          _buildLabel(l10n.addItemUnitLabel),
                          TextFormField(
                            controller: _unitCtrl,
                            textCapitalization: TextCapitalization.none,
                            decoration: _inputDecoration(
                              l10n.addItemUnitHint,
                              suffixIcon: const Icon(Icons.keyboard_arrow_down, color: Color(0xFF7BA082)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                
                if (_isPantryMode) ...[
                  const SizedBox(height: 16),
                  // Category
                  _buildLabel(l10n.addItemCategoryLabel),
                  TextFormField(
                    controller: _categoryCtrl,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: _inputDecoration(
                      l10n.addItemCategoryHint,
                      suffixIcon: const Icon(Icons.keyboard_arrow_down, color: Color(0xFF7BA082)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Expiry Date
                  _buildLabel(l10n.addItemExpiryLabel),
                  InkWell(
                    onTap: _pickDate,
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFFE8ECE7), width: 1),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      child: Row(
                        children: [
                          const Icon(Icons.calendar_today_outlined, color: Color(0xFF7BA082)),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              _expiryDate != null
                                  ? _formatDate(_expiryDate!, context)
                                  : 'mm/dd/yyyy',
                              style: TextStyle(
                                color: _expiryDate != null ? Colors.black87 : const Color(0xFF9E9E9E),
                                fontSize: 14,
                              ),
                            ),
                          ),
                          Icon(
                            _expiryDate != null ? Icons.clear : Icons.calendar_month,
                            color: const Color(0xFF2C392D),
                            size: 20,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 32),
                
                // Submit Button
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: _loading ? null : _submit,
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF7BA082),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _loading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              if (!_isPantryMode) ...[
                                const Icon(Icons.add_circle, size: 20),
                                const SizedBox(width: 8),
                              ],
                              Text(
                                _isPantryMode ? l10n.addItemButtonPantry : l10n.addItemButtonGrocery,
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                            ],
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
