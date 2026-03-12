import 'package:flutter/material.dart';
import 'package:meal_plan_app/l10n/app_localizations.dart';
import 'package:meal_plan_app/config/theme/app_theme.dart';

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

  InputDecoration _inputDecoration(String hint, BuildContext context, {IconData? prefixIcon}) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final customColors = theme.extension<AppCustomColors>()!;
    
    return InputDecoration(
      hintText: hint,
      hintStyle: textTheme.bodyLarge?.copyWith(
        color: customColors.slateGrey?.withValues(alpha: 0.3),
      ),
      prefixIcon: prefixIcon != null ? Icon(prefixIcon, color: customColors.darkSage, size: 20) : null,
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
                  widget.ingredientName,
                  style: textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: customColors.textDarkBlue,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 32),

                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 2,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLabel(l10n.addItemQuantityLabel, context),
                          TextFormField(
                            controller: _quantityCtrl,
                            autofocus: true,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            style: textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
                            decoration: _inputDecoration('0', context),
                            validator: (v) {
                              if (v == null || v.trim().isEmpty) {
                                return l10n.addItemQuantityRequired;
                              }
                              if (double.tryParse(v.trim()) == null) {
                                {
                                  return l10n.addItemQuantityInvalid;
                                }
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
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: customColors.chartTabBackground,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              widget.unit,
                              style: textTheme.bodyLarge?.copyWith(
                                color: customColors.textDarkBlue,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 48),

                SizedBox(
                  width: double.infinity,
                  height: 64,
                  child: FilledButton(
                    onPressed: _submit,
                    style: FilledButton.styleFrom(
                      backgroundColor: customColors.darkSage,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      elevation: 2,
                    ),
                    child: Text(
                      l10n.save,
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
}
