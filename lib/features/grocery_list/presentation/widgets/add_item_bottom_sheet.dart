import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meal_plan_app/features/grocery_list/presentation/providers/provider.dart';

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

    final name = _nameCtrl.text.trim();
    final qty = double.tryParse(_quantityCtrl.text.trim()) ?? 1.0;
    final unit = _unitCtrl.text.trim().ifEmpty('unidad');

    bool ok = false;
    if (_isPantryMode) {
      final expiresAt = _expiryDate != null
          ? _expiryDate!.toIso8601String().split('T').first
          : null;
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
        const SnackBar(content: Text('Error al agregar el ingrediente')),
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
    if (picked != null) setState(() => _expiryDate = picked);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
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
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.outlineVariant,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Text(
                _isPantryMode ? 'Agregar a la despensa' : 'Agregar ingrediente',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _nameCtrl,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  labelText: 'Nombre del ingrediente',
                  prefixIcon: Icon(Icons.restaurant_outlined),
                ),
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'Ingresa el nombre'
                    : null,
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: TextFormField(
                      controller: _quantityCtrl,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: const InputDecoration(
                        labelText: 'Cantidad',
                        prefixIcon: Icon(Icons.numbers_outlined),
                      ),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) {
                          return 'Requerido';
                        }
                        if (double.tryParse(v.trim()) == null) {
                          return 'Número inválido';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 3,
                    child: TextFormField(
                      controller: _unitCtrl,
                      textCapitalization: TextCapitalization.none,
                      decoration: const InputDecoration(
                        labelText: 'Unidad',
                        hintText: 'g, kg, ml, pcs…',
                        prefixIcon: Icon(Icons.scale_outlined),
                      ),
                    ),
                  ),
                ],
              ),
              if (_isPantryMode) ...[
                const SizedBox(height: 14),
                TextFormField(
                  controller: _categoryCtrl,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: const InputDecoration(
                    labelText: 'Categoría (opcional)',
                    hintText: 'proteína, verdura, lácteo…',
                    prefixIcon: Icon(Icons.label_outline),
                  ),
                ),
                const SizedBox(height: 14),
                InkWell(
                  onTap: _pickDate,
                  borderRadius: BorderRadius.circular(12),
                  child: InputDecorator(
                    decoration: InputDecoration(
                      labelText: 'Fecha de vencimiento (opcional)',
                      prefixIcon: const Icon(Icons.calendar_today_outlined),
                      suffixIcon: _expiryDate != null
                          ? IconButton(
                              icon: const Icon(Icons.clear, size: 18),
                              onPressed: () =>
                                  setState(() => _expiryDate = null),
                            )
                          : null,
                    ),
                    child: Text(
                      _expiryDate != null
                          ? _formatDate(_expiryDate!)
                          : 'Sin fecha',
                      style: theme.textTheme.bodyMedium,
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _loading ? null : _submit,
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: _loading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2.5),
                        )
                      : const Text('Agregar', style: TextStyle(fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime d) {
    final months = [
      'ene',
      'feb',
      'mar',
      'abr',
      'may',
      'jun',
      'jul',
      'ago',
      'sep',
      'oct',
      'nov',
      'dic',
    ];
    return '${d.day} de ${months[d.month - 1]} de ${d.year}';
  }
}

extension on String {
  String ifEmpty(String fallback) => isEmpty ? fallback : this;
}
