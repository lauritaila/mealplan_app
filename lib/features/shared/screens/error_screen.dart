import 'package:flutter/material.dart';
import 'package:meal_plan_app/l10n/app_localizations.dart';

class ErrorScreen extends StatelessWidget {
  final Exception? error;
  const ErrorScreen({super.key, this.error});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.errorTitle)),
      body: Center(
        child: Text(l10n.errorOccurred(error?.toString() ?? l10n.genericError)),
      ),
    );
  }
}
