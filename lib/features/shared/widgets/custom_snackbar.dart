import 'package:flutter/material.dart';
import 'package:delightful_toast/delight_toast.dart';
import 'package:delightful_toast/toast/components/toast_card.dart';
import 'package:delightful_toast/toast/utils/enums.dart';

class CustomSnackbar {
  /// Shows a premium error toast using delightful_toast.
  /// As per user request, we only use toasts for errors.
  static void showError(BuildContext context, String message, {String title = 'Error'}) {
    DelightToastBar(
      autoDismiss: true,
      position: DelightSnackbarPosition.top,
      builder: (context) => ToastCard(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.red.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.error_outline_rounded,
            size: 24,
            color: Colors.redAccent,
          ),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 15,
            color: Color(0xFF1A1E1B),
          ),
        ),
        subtitle: Text(
          message,
          style: const TextStyle(
            fontSize: 13,
            color: Color(0xFF5D6B78),
            height: 1.4,
          ),
        ),
      ),
    ).show(context);
  }

  // The following methods are kept as empty stubs to avoid breaking existing code
  // while adhering to the instruction of only using toasts for errors.
  
  static void showSuccess(BuildContext context, String message, {String title = 'Success', dynamic action}) {
    // Hidden: Only errors should show toasts.
  }

  static void showWarning(BuildContext context, String message, {String title = 'Warning', dynamic action}) {
    // Hidden: Only errors should show toasts.
  }

  static void showInfo(BuildContext context, String message, {String title = 'Info', dynamic action}) {
    // Hidden: Only errors should show toasts.
  }

  @Deprecated('Only use showError. Generic show is no longer supported.')
  static void show({
    required BuildContext context,
    required String title,
    required String message,
    required dynamic contentType,
    dynamic action,
  }) {
    // No-op for compatibility
  }
}
