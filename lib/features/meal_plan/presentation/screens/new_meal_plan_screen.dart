import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:meal_plan_app/features/meal_plan/presentation/providers/provider.dart';

class NewMealPlanScreen extends ConsumerStatefulWidget {
  const NewMealPlanScreen({super.key});

  @override
  ConsumerState<NewMealPlanScreen> createState() => _NewMealPlanScreenState();
}

class _NewMealPlanScreenState extends ConsumerState<NewMealPlanScreen> {
  final _descriptionController = TextEditingController();
  final List<int> _durationOptions = [3, 5, 7, 14];
  final Set<String> _selectedMealTypes = {'breakfast', 'lunch', 'dinner'};
  int _selectedDays = 5;
  int _peopleCount = 2;

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  void _resetForm() {
    setState(() {
      _selectedDays = 5;
      _peopleCount = 2;
      _selectedMealTypes
        ..clear()
        ..addAll({'breakfast', 'lunch', 'dinner'});
      _descriptionController.clear();
    });
    ref.read(mealPlanGeneratorProvider.notifier).reset();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(mealPlanGeneratorProvider, (previous, next) {
      if (next.status == MealPlanGeneratorStatus.success) {
        if (next.generatedPlan != null) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              const SnackBar(content: Text('Plan generado con exito')),
            );
          context.push('/meal-plan/approve', extra: next.generatedPlan);
        }
      } else if (next.status == MealPlanGeneratorStatus.error) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(content: Text(next.errorMessage ?? 'An error occurred')),
          );
      }
    });

    final state = ref.watch(mealPlanGeneratorProvider);
    final isLoading = state.status == MealPlanGeneratorStatus.loading;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Nuevo Plan'),
        actions: [
          TextButton(
            onPressed: _resetForm,
            child: const Text(
              'Limpiar',
              style: TextStyle(color: Colors.redAccent),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                const Text(
                  'Configura tu plan',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 4),
                Text(
                  'Define duracion, personas y comidas base.',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 20),
                _Section(
                  title: 'Duracion',
                  child: Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: _durationOptions
                        .map(
                          (days) => _PillOption(
                            label: '$days dias',
                            selected: _selectedDays == days,
                            onTap: () => setState(() => _selectedDays = days),
                          ),
                        )
                        .toList(),
                  ),
                ),
                _Section(
                  title: 'Comensales',
                  child: Row(
                    children: [
                      _IconCircleButton(
                        icon: Icons.remove,
                        onTap: () => setState(
                          () => _peopleCount = (_peopleCount > 1)
                              ? _peopleCount - 1
                              : 1,
                        ),
                      ),
                      Expanded(
                        child: Center(
                          child: Text(
                            '$_peopleCount personas',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      _IconCircleButton(
                        icon: Icons.add,
                        onTap: () => setState(() => _peopleCount += 1),
                      ),
                    ],
                  ),
                ),
                _Section(
                  title: 'Tipos de comida',
                  child: Column(
                    children: [
                      _MealTypeTile(
                        title: 'Desayuno',
                        subtitle: 'Energia para el dia',
                        selected: _selectedMealTypes.contains('breakfast'),
                        onTap: () => _toggleMealType('breakfast'),
                      ),
                      const SizedBox(height: 10),
                      _MealTypeTile(
                        title: 'Almuerzo',
                        subtitle: 'Comida principal',
                        selected: _selectedMealTypes.contains('lunch'),
                        onTap: () => _toggleMealType('lunch'),
                      ),
                      const SizedBox(height: 10),
                      _MealTypeTile(
                        title: 'Cena',
                        subtitle: 'Ligera y nutritiva',
                        selected: _selectedMealTypes.contains('dinner'),
                        onTap: () => _toggleMealType('dinner'),
                      ),
                    ],
                  ),
                ),
                _Section(
                  title: 'Notas (opcional)',
                  child: TextField(
                    controller: _descriptionController,
                    maxLines: 4,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'Ej: Sin lactosa, mas proteinas...',
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : _onGenerate,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text('Continuar'),
                  ),
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
          if (isLoading) const _BlockingLoader(),
        ],
      ),
    );
  }

  void _toggleMealType(String type) {
    setState(() {
      if (_selectedMealTypes.contains(type)) {
        _selectedMealTypes.remove(type);
      } else {
        _selectedMealTypes.add(type);
      }
    });
  }

  void _onGenerate() {
    ref
        .read(mealPlanGeneratorProvider.notifier)
        .generatePlan(
          description: _descriptionController.text.trim(),
          numberOfDays: _selectedDays,
          quantityOfPeople: _peopleCount,
          mealTypes: _selectedMealTypes.toList(),
        );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final Widget child;

  const _Section({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          child,
        ],
      ),
    );
  }
}

class _PillOption extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _PillOption({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: selected ? Colors.red.shade50 : Colors.white,
          border: Border.all(
            color: selected ? Colors.redAccent : Colors.grey.shade300,
            width: 1.3,
          ),
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              offset: const Offset(0, 6),
              blurRadius: 12,
            ),
          ],
        ),
        child: Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: selected ? Colors.redAccent : Colors.black87,
          ),
        ),
      ),
    );
  }
}

class _IconCircleButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _IconCircleButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Colors.grey.shade300, width: 1.2),
          color: Colors.white,
        ),
        child: Icon(icon, size: 20),
      ),
    );
  }
}

class _MealTypeTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;

  const _MealTypeTile({
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? Colors.redAccent : Colors.grey.shade300,
            width: 1.2,
          ),
          color: selected ? Colors.red.shade50 : Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              offset: const Offset(0, 6),
              blurRadius: 12,
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(
              selected ? Icons.check_circle : Icons.radio_button_unchecked,
              color: selected ? Colors.redAccent : Colors.grey,
              size: 24,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(subtitle, style: TextStyle(color: Colors.grey.shade700)),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Colors.black38,
            ),
          ],
        ),
      ),
    );
  }
}

class _BlockingLoader extends StatelessWidget {
  const _BlockingLoader();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withOpacity(0.35),
      child: const Center(
        child: SizedBox(
          height: 42,
          width: 42,
          child: CircularProgressIndicator(color: Colors.white),
        ),
      ),
    );
  }
}
