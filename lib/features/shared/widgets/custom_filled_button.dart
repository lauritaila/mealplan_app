import 'package:flutter/material.dart';

class CustomFilledButton extends StatelessWidget {
  final void Function()? onPressed;
  final String text;
  final Color? buttonColor;
  final Color? textColor;

  const CustomFilledButton({
    super.key,
    this.onPressed,
    this.textColor,
    required this.text,
    this.buttonColor,
  });

  @override
  Widget build(BuildContext context) {
    const radius = Radius.circular(10);
    final Color effectiveButtonColor =
        buttonColor ?? Theme.of(context).colorScheme.primary;
    final Color effectiveTextColor =
        textColor ??
        (effectiveButtonColor.computeLuminance() > 0.5
            ? Colors.black
            : Colors.white);

    return FilledButton(
      style: FilledButton.styleFrom(
        backgroundColor: effectiveButtonColor,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(radius),
        ),
      ),
      onPressed: onPressed,
      autofocus: false,

      child: Text(
        text,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: effectiveTextColor,
        ),
      ),
    );
  }
}
