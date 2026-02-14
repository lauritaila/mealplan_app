import 'package:flutter/material.dart';
import 'package:meal_plan_app/l10n/app_localizations.dart';

class ViewPaymentsScreen extends StatelessWidget {
  const ViewPaymentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.profilePaymentsTitle)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Card(
          child: Center(
            child: Text(
              l10n.profilePaymentsEmpty,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
