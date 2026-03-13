import 'package:flutter/material.dart';
import 'package:meal_plan_app/l10n/app_localizations.dart';

class DateSelectionSheet extends StatefulWidget {
  final DateTime initialStartDate;
  final DateTime initialEndDate;

  const DateSelectionSheet({
    super.key,
    required this.initialStartDate,
    required this.initialEndDate,
  });

  @override
  State<DateSelectionSheet> createState() => _DateSelectionSheetState();
}

class _DateSelectionSheetState extends State<DateSelectionSheet> {
  late DateTime _startDate;
  late DateTime _endDate;

  @override
  void initState() {
    super.initState();
    _startDate = widget.initialStartDate;
    _endDate = widget.initialEndDate;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              l10n.selectDatesTitle,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: Color(0xFF1A1E1B),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.selectDatesSubtitle,
              style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
            ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.chevron_left_rounded),
                ),
                const Text(
                  'Marzo 2026',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                ),
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.chevron_right_rounded),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                DayHeader('LU'),
                DayHeader('MA'),
                DayHeader('MI'),
                DayHeader('JU'),
                DayHeader('VI'),
                DayHeader('SA'),
                DayHeader('DO'),
              ],
            ),
            const SizedBox(height: 12),
            _buildCalendarMock(),
            const SizedBox(height: 32),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF576F5F),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              onPressed: () {
                Navigator.pop(context, {'start': _startDate, 'end': _endDate});
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
              onPressed: () => Navigator.pop(context),
              child: Text(
                l10n.cancel,
                style: const TextStyle(
                  color: Colors.grey,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCalendarMock() {
    return Column(
      children: [
        const CalendarRow(days: [23, 24, 25, 26, 27, 28, 1], isDimmed: true),
        const CalendarRow(days: [2, 3, 4, 5, 6, 7, 8]),
        const CalendarRow(days: [9, 10, 11, 12, 13, 14, 15], selectedDay: 15),
        const CalendarRow(days: [16, 17, 18, 19, 20, 21, 22], isRange: true),
        const CalendarRow(days: [23, 24, 25, 26, 27, 28, 29]),
      ],
    );
  }
}

class DayHeader extends StatelessWidget {
  final String label;
  const DayHeader(this.label, {super.key});
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 40,
      child: Text(
        label,
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: Colors.grey,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class CalendarRow extends StatelessWidget {
  final List<int> days;
  final bool isDimmed;
  final int? selectedDay;
  final bool isRange;

  const CalendarRow({
    super.key,
    required this.days,
    this.isDimmed = false,
    this.selectedDay,
    this.isRange = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: days.map((d) {
          bool isHighlighted = selectedDay == d || (isRange && d >= 16 && d <= 22);
          bool isStart = selectedDay == d || (isRange && d == 16);
          bool isEnd = isRange && d == 22;

          return Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isHighlighted ? const Color(0xFFF4F7F5) : null,
              borderRadius: isStart || isEnd ? BorderRadius.circular(20) : null,
            ),
            child: Center(
              child: Container(
                width: 32,
                height: 32,
                decoration: (selectedDay == d || isEnd)
                    ? const BoxDecoration(
                        color: Color(0xFF576F5F),
                        shape: BoxShape.circle,
                      )
                    : null,
                child: Center(
                  child: Text(
                    '$d',
                    style: TextStyle(
                      color: (selectedDay == d || isEnd)
                          ? Colors.white
                          : (isDimmed ? Colors.grey.shade300 : const Color(0xFF1A1E1B)),
                      fontWeight: (selectedDay == d || isEnd || isRange)
                          ? FontWeight.w800
                          : FontWeight.normal,
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
