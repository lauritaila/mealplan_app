import 'package:flutter/material.dart';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';

class CustomSnackbar {
  static void show({
    required BuildContext context,
    required String title,
    required String message,
    required ContentType contentType,
  }) {
    final snackBar = SnackBar(
      elevation: 0,
      behavior: SnackBarBehavior.floating,
      backgroundColor: Colors.transparent,
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

  static void showSuccess(BuildContext context, String message, {String title = 'Success'}) {
    show(
      context: context,
      title: title,
      message: message,
      contentType: ContentType.success,
    );
  }

  static void showError(BuildContext context, String message, {String title = 'Error'}) {
    show(
      context: context,
      title: title,
      message: message,
      contentType: ContentType.failure,
    );
  }

  static void showWarning(BuildContext context, String message, {String title = 'Warning'}) {
    show(
      context: context,
      title: title,
      message: message,
      contentType: ContentType.warning,
    );
  }

  static void showInfo(BuildContext context, String message, {String title = 'Info'}) {
    show(
      context: context,
      title: title,
      message: message,
      contentType: ContentType.help,
    );
  }
}
