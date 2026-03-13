import 'package:flutter/material.dart';
import 'package:meal_plan_app/l10n/app_localizations.dart';

class DragDropHint extends StatelessWidget {
  const DragDropHint({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF4F7F5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE9EFEB)),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.touch_app_outlined,
            size: 20,
            color: Color(0xFF576F5F),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              l10n.dragDropHint,
              style: const TextStyle(
                color: Color(0xFF576F5F),
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
