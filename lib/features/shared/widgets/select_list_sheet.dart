import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meal_plan_app/features/grocery_list/domain/entities/grocery_list.dart';
import 'package:meal_plan_app/features/grocery_list/presentation/providers/provider.dart';
import 'package:meal_plan_app/features/grocery_list/presentation/widgets/create_list_dialog.dart';
import 'package:meal_plan_app/l10n/app_localizations.dart';

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
    final l10n = AppLocalizations.of(context);
    final listsAsync = ref.watch(groceryListsProvider);

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: SafeArea(
        top: false,
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
              const SizedBox(height: 32),
              Text(
                widget.title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF33414B),
                ),
              ),
              if (widget.subtitle != null) ...[
                const SizedBox(height: 8),
                Text(
                  widget.subtitle!,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.blueGrey.shade300,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
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
                    backgroundColor: Colors.white,
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
                    color: const Color(0xFFF7F9F7),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFFEDF2ED)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: const BoxDecoration(
                          color: Color(0xFFA6BCAC),
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
                              style: const TextStyle(
                                color: Color(0xFF33414B),
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Text(
                              l10n.addCustomName,
                              style: TextStyle(
                                color: Colors.blueGrey.shade300,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(Icons.chevron_right_rounded, color: Colors.grey.shade400),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 32),
              Text(
                l10n.existingListsLabel.toUpperCase(),
                style: TextStyle(
                  color: Colors.blueGrey.shade200,
                  fontSize: 11,
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
                          style: TextStyle(color: Colors.grey.shade400, fontSize: 13),
                        ),
                      );
                    }
                    return ConstrainedBox(
                      constraints: BoxConstraints(
                        maxHeight: MediaQuery.of(context).size.height * 0.3,
                      ),
                      child: ListView.separated(
                        shrinkWrap: true,
                        itemCount: lists.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final list = lists[index];
                          final isSelected = _selectedListId == list.id;
                          
                          // Mocking icons/counts for design fidelity
                          final icon = index % 3 == 0 ? Icons.folder_rounded : (index % 3 == 1 ? Icons.restaurant_rounded : Icons.bakery_dining_rounded);
                          final itemCount = (index + 1) * 4;

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
                                      color: const Color(0xFFF2F6F9),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Icon(icon, color: const Color(0xFF5D6B78), size: 22),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          list.name,
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w700,
                                            color: Color(0xFF33414B),
                                          ),
                                        ),
                                        Text(
                                          l10n.savedRecipesCount(itemCount),
                                          style: TextStyle(
                                            color: Colors.blueGrey.shade300,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    width: 24,
                                    height: 24,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: isSelected ? const Color(0xFFA6BCAC) : Colors.white,
                                      border: Border.all(
                                        color: isSelected ? const Color(0xFFA6BCAC) : Colors.grey.shade200,
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
                  error: (_, __) => Text(l10n.genericError),
                ),
              ),

              const SizedBox(height: 32),
              FilledButton(
                onPressed: _selectedListId == null
                    ? null
                    : () => Navigator.pop(context, _selectedListId),
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFFA6BCAC),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  'Guardar selección',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
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
