import 'package:flutter/material.dart';
import 'package:meal_plan_app/l10n/app_localizations.dart';

class EditQuantityBottomSheet extends StatefulWidget {
  final double initialQuantity;
  final String ingredientName;
  final String unit;

  const EditQuantityBottomSheet({
    super.key,
    required this.initialQuantity,
    required this.ingredientName,
    required this.unit,
  });

  @override
  State<EditQuantityBottomSheet> createState() => _EditQuantityBottomSheetState();
}

class _EditQuantityBottomSheetState extends State<EditQuantityBottomSheet> {
  late final TextEditingController _quantityCtrl;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _quantityCtrl = TextEditingController(
      text: widget.initialQuantity == widget.initialQuantity.roundToDouble()
          ? widget.initialQuantity.toInt().toString()
          : widget.initialQuantity.toStringAsFixed(1),
    );
  }

  @override
  void dispose() {
    _quantityCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    
    final val = double.tryParse(_quantityCtrl.text.trim());
    if (val != null) {
      Navigator.pop(context, val);
    }
  }

  InputDecoration _inputDecoration(String hint, {IconData? prefixIcon}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Color(0xFF9E9E9E), fontSize: 14),
      prefixIcon: prefixIcon != null ? Icon(prefixIcon, color: const Color(0xFF7BA082)) : null,
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
          color: Color(0xFF4A5D4E),
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
                
                // Title
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        widget.ingredientName,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF2C392D),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close, color: Color(0xFF7BA082)),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Quantity Label and Input Row
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 2,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLabel(l10n.addItemQuantityLabel),
                          TextFormField(
                            controller: _quantityCtrl,
                            autofocus: true,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
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
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: const Color(0xFFE8ECE7), width: 1),
                            ),
                            child: Text(
                              widget.unit,
                              style: const TextStyle(fontSize: 14, color: Color(0xFF4A5D4E)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                // Save Button
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: _submit,
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF7BA082),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      l10n.save,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
}
