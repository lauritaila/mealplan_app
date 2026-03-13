import 'package:flutter/material.dart';
import 'package:meal_plan_app/config/theme/app_theme.dart';

class CustomFilledButton extends StatefulWidget {
  final void Function()? onPressed;
  final String text;
  final Color? buttonColor;
  final Color? textColor;
  final double? width;
  final double height;
  final IconData? icon;

  const CustomFilledButton({
    super.key,
    this.onPressed,
    this.textColor,
    required this.text,
    this.buttonColor,
    this.width,
    this.height = 64,
    this.icon,
  });

  @override
  State<CustomFilledButton> createState() => _CustomFilledButtonState();
}

class _CustomFilledButtonState extends State<CustomFilledButton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
      lowerBound: 0.95,
      upperBound: 1.0,
    );
    _scaleAnimation = _controller.view;
    _controller.value = 1.0;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    if (widget.onPressed != null) _controller.reverse();
  }

  void _onTapUp(TapUpDetails details) {
    if (widget.onPressed != null) _controller.forward();
  }

  void _onTapCancel() {
    if (widget.onPressed != null) _controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final customColors = theme.extension<AppCustomColors>()!;
    
    final style = FilledButton.styleFrom(
      backgroundColor: widget.buttonColor ?? customColors.darkSage,
      foregroundColor: widget.textColor ?? Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      elevation: 0,
      disabledBackgroundColor: customColors.slateGrey?.withValues(alpha: 0.1),
      disabledForegroundColor: customColors.slateGrey?.withValues(alpha: 0.4),
    );

    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: SizedBox(
          width: widget.width ?? double.infinity,
          height: widget.height,
          child: widget.icon != null
              ? FilledButton.icon(
                  style: style,
                  onPressed: widget.onPressed,
                  icon: Icon(widget.icon, size: 24),
                  label: Text(
                    widget.text,
                    style: textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w900,
                      color: widget.onPressed == null 
                          ? customColors.slateGrey?.withValues(alpha: 0.4)
                          : (widget.textColor ?? Colors.white),
                    ),
                  ),
                )
              : FilledButton(
                  style: style,
                  onPressed: widget.onPressed,
                  child: Text(
                    widget.text,
                    style: textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w900,
                      color: widget.onPressed == null 
                          ? customColors.slateGrey?.withValues(alpha: 0.4)
                          : (widget.textColor ?? Colors.white),
                    ),
                  ),
                ),
        ),
      ),
    );
  }
}
