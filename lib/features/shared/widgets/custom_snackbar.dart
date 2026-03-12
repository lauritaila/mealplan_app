import 'package:flutter/material.dart';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';

class CustomSnackbar {
  static void show({
    required BuildContext context,
    required String title,
    required String message,
    required ContentType contentType,
    SnackBarAction? action,
  }) {
    final snackBar = SnackBar(
      elevation: 0,
      behavior: SnackBarBehavior.floating,
      backgroundColor: Colors.transparent,
      action: action,
      content: AwesomeSnackbarContent(
        title: title,
        message: message,
        contentType: contentType,
      ),
    );

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(snackBar);
  }

  static void showSuccess(BuildContext context, String message, {String title = 'Success', SnackBarAction? action}) {
    show(
      context: context,
      title: title,
      message: message,
      contentType: ContentType.success,
      action: action,
    );
  }

  static void showError(BuildContext context, String message, {String title = 'Error', SnackBarAction? action}) {
    show(
      context: context,
      title: title,
      message: message,
      contentType: ContentType.failure,
      action: action,
    );
  }

  static void showWarning(BuildContext context, String message, {String title = 'Warning', SnackBarAction? action}) {
    show(
      context: context,
      title: title,
      message: message,
      contentType: ContentType.warning,
      action: action,
    );
  }

  static void showInfo(BuildContext context, String message, {String title = 'Info', SnackBarAction? action}) {
    show(
      context: context,
      title: title,
      message: message,
      contentType: ContentType.help,
      action: action,
    );
  }
}
