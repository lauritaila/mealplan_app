import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:meal_plan_app/config/theme/app_theme.dart';
import 'package:meal_plan_app/l10n/app_localizations.dart';

class ReusePlanSheet extends StatefulWidget {
  final String? initialName;

  const ReusePlanSheet({
    super.key,
    this.initialName,
  });

  @override
  State<ReusePlanSheet> createState() => _ReusePlanSheetState();
}

class _ReusePlanSheetState extends State<ReusePlanSheet> {
  DateTime? _selectedDate;
  late TextEditingController _nameController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_nameController.text.isEmpty) {
      final l10n = AppLocalizations.of(context);
      _nameController.text = widget.initialName != null 
          ? '${widget.initialName} (${l10n.copySuffix})' 
          : '';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final customColors = theme.extension<AppCustomColors>()!;
    final textTheme = theme.textTheme;
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).toString();

    return Container(
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              24,
              12,
              24,
              24 + MediaQuery.of(context).viewInsets.bottom,
            ),
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
                  l10n.reusePlanSheetTitle,
                  style: textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: customColors.textDarkBlue,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.configurePlanSubtitle,
                  style: textTheme.bodyMedium?.copyWith(
                    color: customColors.slateGrey,
                  ),
                ),
                const SizedBox(height: 24),
                
                // Date Picker Interaction
                InkWell(
                  onTap: () => _showDatePicker(context),
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: customColors.chartTabBackground,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: _selectedDate == null 
                          ? Colors.transparent 
                          : (customColors.darkSage ?? AppTheme.primarySage).withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.calendar_today_rounded,
                          color: customColors.darkSage,
                          size: 24,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                l10n.reusePlanStartDateLabel,
                                style: textTheme.labelSmall?.copyWith(
                                  color: customColors.slateGrey,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _selectedDate == null
                                    ? l10n.reusePlanSelectDate
                                    : DateFormat('EEEE, d MMMM yyyy', locale)
                                        .format(_selectedDate!),
                                style: textTheme.bodyLarge?.copyWith(
                                  fontWeight: FontWeight.w800,
                                  color: customColors.textDarkBlue,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (_selectedDate != null)
                          Icon(
                            Icons.check_circle,
                            color: customColors.darkSage,
                            size: 20,
                          ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // New Name Field (Optional)
                Text(
                  l10n.reusePlanNameLabel,
                  style: textTheme.labelLarge?.copyWith(
                    color: customColors.textDarkBlue,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    hintText: l10n.reusePlanNameHint,
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.all(20),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(color: customColors.slateGrey!.withValues(alpha: 0.1)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(color: (customColors.slateGrey ?? const Color(0xFF64748B)).withValues(alpha: 0.1)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(color: customColors.darkSage ?? AppTheme.primarySage, width: 2),
                    ),
                  ),
                ),
                
                const SizedBox(height: 32),
                FilledButton(
                  onPressed: _selectedDate == null ? null : _onConfirm,
                  style: FilledButton.styleFrom(
                    backgroundColor: customColors.darkSage,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    l10n.reusePlanSheetTitle.toUpperCase(),
                    style: const TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.1),
                  ),
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    l10n.cancel.toUpperCase(),
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      color: customColors.slateGrey,
                      letterSpacing: 1.1,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _showDatePicker(BuildContext context) async {
    final customColors = Theme.of(context).extension<AppCustomColors>()!;
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: customColors.darkSage!,
              onPrimary: Colors.white,
              onSurface: customColors.textDarkBlue!,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  void _onConfirm() {
    if (_selectedDate == null) return;
    
    // Normalize date to YYYY-MM-DD
    final dateStr = DateFormat('yyyy-MM-dd').format(_selectedDate!);
    
    Navigator.of(context).pop((
      startDate: dateStr,
      name: _nameController.text.trim().isEmpty
          ? null
          : _nameController.text.trim(),
    ));
  }
}
