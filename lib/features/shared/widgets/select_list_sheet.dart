import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meal_plan_app/features/grocery_list/domain/entities/grocery_list.dart';
import 'package:meal_plan_app/features/grocery_list/presentation/providers/provider.dart';
import 'package:meal_plan_app/features/grocery_list/presentation/widgets/create_list_dialog.dart';
import 'package:meal_plan_app/l10n/app_localizations.dart';
import 'package:meal_plan_app/config/theme/app_theme.dart';

class SelectListSheet extends ConsumerStatefulWidget {
  final String title;
  final String? subtitle;

  const SelectListSheet({
    super.key,
    required this.title,
    this.subtitle,
  });

  @override
  ConsumerState<SelectListSheet> createState() => _SelectListSheetState();
}

class _SelectListSheetState extends ConsumerState<SelectListSheet> {
  int? _selectedListId;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final customColors = theme.extension<AppCustomColors>()!;
    final textTheme = theme.textTheme;
    final l10n = AppLocalizations.of(context);
    final listsAsync = ref.watch(groceryListsProvider);

    return Container(
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(24, 12, 24, 24 + MediaQuery.of(context).viewInsets.bottom),
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
                widget.title,
                textAlign: TextAlign.center,
                style: textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: customColors.textDarkBlue,
                ),
              ),
              if (widget.subtitle != null) ...[
                const SizedBox(height: 8),
                Text(
                  widget.subtitle!,
                  textAlign: TextAlign.center,
                  style: textTheme.bodyMedium?.copyWith(
                    color: customColors.slateGrey,
                  ),
                ),
              ],
              const SizedBox(height: 32),

              // "Crear nueva lista" Premium Card
              InkWell(
                onTap: () async {
                  final newList = await showModalBottomSheet<GroceryList?>(
                    context: context,
                    isScrollControlled: true,
                    useSafeArea: true,
                    backgroundColor: theme.scaffoldBackgroundColor,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                    ),
                    builder: (_) => const CreateListDialog(),
                  );
                  if (newList != null && mounted) {
                    setState(() => _selectedListId = newList.id);
                  }
                },
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: customColors.chartTabBackground,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: (customColors.darkSage ?? AppTheme.primarySage).withValues(alpha: 0.1)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: customColors.darkSage,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.add, color: Colors.white, size: 28),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.createNewListAction,
                              style: textTheme.titleMedium?.copyWith(
                                color: customColors.textDarkBlue,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            Text(
                              l10n.addCustomName,
                              style: textTheme.bodySmall?.copyWith(
                                color: customColors.slateGrey,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(Icons.chevron_right_rounded, color: customColors.slateGrey?.withValues(alpha: 0.5)),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 32),
              Text(
                l10n.existingListsLabel.toUpperCase(),
                style: textTheme.labelSmall?.copyWith(
                  color: customColors.slateGrey?.withValues(alpha: 0.6),
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.1,
                ),
              ),
              const SizedBox(height: 16),

              Flexible(
                child: listsAsync.when(
                  data: (lists) {
                    if (lists.isEmpty) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: Text(
                          l10n.noExistingLists,
                          style: textTheme.bodyMedium?.copyWith(color: customColors.slateGrey?.withValues(alpha: 0.5)),
                        ),
                      );
                    }
                    return ConstrainedBox(
                      constraints: BoxConstraints(
                        maxHeight: MediaQuery.of(context).size.height * 0.4,
                      ),
                      child: ListView.separated(
                        shrinkWrap: true,
                        itemCount: lists.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final list = lists[index];
                          final isSelected = _selectedListId == list.id;
                          
                          final icon = index % 3 == 0 ? Icons.folder_rounded : (index % 3 == 1 ? Icons.restaurant_rounded : Icons.bakery_dining_rounded);

                          return InkWell(
                            onTap: () => setState(() => _selectedListId = list.id),
                            borderRadius: BorderRadius.circular(12),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: Row(
                                children: [
                                  Container(
                                    width: 44,
                                    height: 44,
                                    decoration: BoxDecoration(
                                      color: customColors.chartTabBackground,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Icon(icon, color: customColors.darkSage, size: 22),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Text(
                                      list.name,
                                      style: textTheme.titleMedium?.copyWith(
                                        fontWeight: FontWeight.w700,
                                        color: customColors.textDarkBlue,
                                      ),
                                    ),
                                  ),
                                  Container(
                                    width: 24,
                                    height: 24,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: isSelected ? customColors.darkSage : Colors.transparent,
                                      border: Border.all(
                                        color: isSelected 
                                          ? (customColors.darkSage ?? AppTheme.primarySage) 
                                          : (customColors.slateGrey ?? const Color(0xFF64748B)).withValues(alpha: 0.2),
                                        width: 1.5,
                                      ),
                                    ),
                                    child: isSelected ? const Icon(Icons.check, color: Colors.white, size: 16) : null,
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (_, _) => Text(l10n.genericError),
                ),
              ),

              const SizedBox(height: 32),
              FilledButton(
                onPressed: _selectedListId == null
                    ? null
                    : () => Navigator.pop(context, _selectedListId),
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
                  l10n.saveSelectionAction.toUpperCase(),
                  style: const TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.1),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}
