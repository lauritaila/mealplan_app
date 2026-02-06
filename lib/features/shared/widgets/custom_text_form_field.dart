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
      borderSide: BorderSide(color: Colors.transparent, width: 2),
      borderRadius: BorderRadius.circular(10),
    );

    const borderRadius = Radius.circular(10);

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
          padding: const EdgeInsets.symmetric(vertical: 3),
          decoration: BoxDecoration(
            color: Colors.white,
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
              // floatingLabelStyle: TextStyle(color: colors.primary, fontWeight: FontWeight.bold, fontSize: 14),
              enabledBorder: border,
              focusedBorder: border,
              errorBorder: border,
              focusedErrorBorder: border,
              isDense: true,
              // filled: true,
              // fillColor: Colors.white,
              // label: label != null ? Text(label!) : null,
              hintText: hint,
              // errorText: errorMessage,
              // focusColor: colors.primary,
              // icon: Icon( Icons.supervised_user_circle_outlined, color: colors.primary, )
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
