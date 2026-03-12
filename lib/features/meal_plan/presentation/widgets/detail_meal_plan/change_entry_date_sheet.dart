import 'package:flutter/material.dart';
import 'package:meal_plan_app/config/theme/app_theme.dart';
import 'package:meal_plan_app/l10n/app_localizations.dart';

class ChangeEntryDateSheet extends StatefulWidget {
  final DateTime initialDate;

  const ChangeEntryDateSheet({
    super.key,
    required this.initialDate,
  });

  @override
  State<ChangeEntryDateSheet> createState() => _ChangeEntryDateSheetState();
}

class _ChangeEntryDateSheetState extends State<ChangeEntryDateSheet> {
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.initialDate;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final customColors = theme.extension<AppCustomColors>()!;
    final textTheme = theme.textTheme;
    final l10n = AppLocalizations.of(context);
    
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: customColors.slateGrey?.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 32),
            Text(
              l10n.changeMealDateAction,
              style: textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w900,
                color: customColors.textDarkBlue,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.selectDatesSubtitle,
              style: textTheme.bodyMedium?.copyWith(
                color: customColors.slateGrey,
              ),
            ),
            const SizedBox(height: 16),
            Theme(
              data: theme.copyWith(
                colorScheme: theme.colorScheme.copyWith(
                  primary: customColors.darkSage,
                  onPrimary: Colors.white,
                  surface: theme.scaffoldBackgroundColor,
                  onSurface: customColors.textDarkBlue,
                ),
              ),
              child: CalendarDatePicker(
                initialDate: widget.initialDate,
                firstDate: DateTime(2000),
                lastDate: DateTime(2100),
                currentDate: DateTime.now(),
                onDateChanged: (date) {
                  setState(() {
                    _selectedDate = date;
                  });
                },
              ),
            ),
            const SizedBox(height: 24),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: customColors.darkSage,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 20),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                elevation: 0,
              ),
              onPressed: () {
                Navigator.pop(context, _selectedDate);
              },
              child: Text(
                l10n.confirmSelectionAction.toUpperCase(),
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.1,
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextButton(
              style: TextButton.styleFrom(
                foregroundColor: customColors.slateGrey,
              ),
              onPressed: () => Navigator.pop(context),
              child: Text(
                l10n.cancel.toUpperCase(),
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.1,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
