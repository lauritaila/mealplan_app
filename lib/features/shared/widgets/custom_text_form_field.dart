import 'package:flutter/material.dart';

class CustomTextFormField extends StatelessWidget {
  final String? label;
  final String? hint;
  final String? errorMessage;
  final bool obscureText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final List<String>? autofillHints;
  final Function(String)? onChanged;
  final String? Function(String?)? validator;
  final Function(String)? onFieldSubmitted;

  const CustomTextFormField({
    super.key,
    this.label,
    this.hint,
    this.errorMessage,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.textInputAction,
    this.autofillHints,
    this.onChanged,
    this.validator,
    this.onFieldSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    final border = OutlineInputBorder(
      borderSide: BorderSide(color: colors.primary.withOpacity(0.35), width: 1.5),
      borderRadius: BorderRadius.circular(12),
    );

    final focusBorder = OutlineInputBorder(
      borderSide: BorderSide(color: colors.primary, width: 2),
      borderRadius: BorderRadius.circular(12),
    );

    const borderRadius = Radius.circular(12);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 10),
          child: Text(
            label ?? '',
            style: TextStyle(
              fontSize: 14,
              color: colors.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.all(borderRadius),
          ),
          child: TextFormField(
            onChanged: onChanged,
            validator: validator,
            onFieldSubmitted: onFieldSubmitted,
            obscureText: obscureText,
            keyboardType: keyboardType,
            textInputAction: textInputAction,
            autofillHints: autofillHints,
            style: TextStyle(fontSize: 14, color: colors.primary),
            decoration: InputDecoration(
              filled: true,
              fillColor: Theme.of(context).brightness == Brightness.light 
                  ? Colors.white 
                  : const Color(0xFF252A26),
              enabledBorder: border,
              focusedBorder: focusBorder,
              errorBorder: border.copyWith(
                borderSide: BorderSide(color: Colors.red.shade900, width: 1.5),
              ),
              focusedErrorBorder: focusBorder.copyWith(
                borderSide: BorderSide(color: Colors.red.shade900, width: 2),
              ),
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              hintText: hint,
              hintStyle: TextStyle(color: colors.onSurfaceVariant.withOpacity(0.5)),
            ),
          ),
        ),
        const SizedBox(height: 10),
        errorMessage != null
            ? Text(
                errorMessage!,
                style: TextStyle(color: Colors.red[900], fontSize: 12),
              )
            : const SizedBox.shrink(),
      ],
    );
  }
}
