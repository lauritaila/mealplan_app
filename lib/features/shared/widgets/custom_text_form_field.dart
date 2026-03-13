import 'package:flutter/material.dart';
import 'package:meal_plan_app/config/theme/app_theme.dart';

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
  final TextEditingController? controller;

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
    this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final customColors = theme.extension<AppCustomColors>()!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null)
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 12),
            child: Text(
              label!.toUpperCase(),
              style: textTheme.labelSmall?.copyWith(
                color: customColors.slateGrey?.withValues(alpha: 0.7),
                fontWeight: FontWeight.w900,
                letterSpacing: 1.2,
              ),
            ),
          ),
        TextFormField(
          controller: controller,
          onChanged: onChanged,
          validator: validator,
          onFieldSubmitted: onFieldSubmitted,
          obscureText: obscureText,
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          autofillHints: autofillHints,
          style: textTheme.bodyLarge?.copyWith(
            color: customColors.textDarkBlue,
            fontWeight: FontWeight.w600,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: textTheme.bodyLarge?.copyWith(
              color: customColors.slateGrey?.withValues(alpha: 0.4),
            ),
            filled: true,
            fillColor: customColors.chartTabBackground,
            contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: BorderSide(
                color: customColors.darkSage!,
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: BorderSide(
                color: theme.colorScheme.error.withValues(alpha: 0.5),
                width: 1,
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: BorderSide(
                color: theme.colorScheme.error,
                width: 2,
              ),
            ),
          ),
        ),
        if (errorMessage != null)
          Padding(
            padding: const EdgeInsets.only(top: 8, left: 12),
            child: Text(
              errorMessage!,
              style: textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.error,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
      ],
    );
  }
}
