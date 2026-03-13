import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:meal_plan_app/config/theme/app_theme.dart';
import 'package:meal_plan_app/features/grocery_list/domain/entities/pantry_item.dart';
import 'package:meal_plan_app/features/grocery_list/presentation/providers/provider.dart';
import 'package:meal_plan_app/features/shared/shared.dart';
import 'package:meal_plan_app/l10n/app_localizations.dart';

class EditPantryItemDialog extends ConsumerStatefulWidget {
  final PantryItem item;
  const EditPantryItemDialog({super.key, required this.item});

  @override
  ConsumerState<EditPantryItemDialog> createState() => _EditPantryItemDialogState();
}

class _EditPantryItemDialogState extends ConsumerState<EditPantryItemDialog> {
  late final TextEditingController _quantityCtrl;
  DateTime? _expiryDate;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    final q = widget.item.quantity;
    _quantityCtrl = TextEditingController(
      text: q == q.roundToDouble()
          ? q.toInt().toString()
          : q.toStringAsFixed(1),
    );
    _expiryDate = widget.item.expiresAt;
  }

  @override
  void dispose() {
    _quantityCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final l10n = AppLocalizations.of(context);
    final qty = double.tryParse(_quantityCtrl.text.trim());
    if (qty == null || qty <= 0) {
      CustomSnackbar.showInfo(context, l10n.addItemQuantityInvalid);
      return;
    }
    setState(() => _loading = true);
    final expiresAt = _expiryDate?.toIso8601String().split('T').first;
    try {
      await ref
          .read(pantryActionsProvider.notifier)
          .updateItem(widget.item.id, quantity: qty, expiresAt: expiresAt);
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        setState(() => _loading = false);
        CustomSnackbar.showInfo(context, e.toString());
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _expiryDate ?? DateTime.now().add(const Duration(days: 7)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: Theme.of(context).extension<AppCustomColors>()!.darkSage,
              onPrimary: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) setState(() => _expiryDate = picked);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final customColors = theme.extension<AppCustomColors>()!;
    final l10n = AppLocalizations.of(context);
    final dateLabel = _expiryDate != null
        ? DateFormat.yMMMMd(Localizations.localeOf(context).toString()).format(_expiryDate!)
        : l10n.pantryNoDate;

    return AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      title: Text(
        l10n.pantryEditTitle(widget.item.ingredientName),
        style: textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w900,
          color: customColors.textDarkBlue,
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _quantityCtrl,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            style: textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
            decoration: InputDecoration(
              labelText: l10n.pantryQuantityLabel,
              labelStyle: TextStyle(color: customColors.slateGrey, fontWeight: FontWeight.w600),
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
          ),
          const SizedBox(height: 16),
          InkWell(
            onTap: _pickDate,
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: customColors.chartTabBackground,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Icon(Icons.calendar_today_outlined, size: 20, color: customColors.darkSage),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.pantryExpiryLabel,
                          style: textTheme.labelSmall?.copyWith(
                            color: customColors.slateGrey,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          dateLabel,
                          style: textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: customColors.textDarkBlue,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (_expiryDate != null)
                    IconButton(
                      icon: Icon(Icons.clear, size: 18, color: customColors.slateGrey),
                      onPressed: () => setState(() => _expiryDate = null),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            l10n.cancel,
            style: TextStyle(color: customColors.slateGrey, fontWeight: FontWeight.bold),
          ),
        ),
        FilledButton(
          onPressed: _loading ? null : _save,
          style: FilledButton.styleFrom(
            backgroundColor: customColors.darkSage,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
          child: _loading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 3, color: Colors.white),
                )
              : Text(l10n.save, style: const TextStyle(fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }
}
