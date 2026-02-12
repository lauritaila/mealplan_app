import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:meal_plan_app/l10n/app_localizations.dart';

class MainLayout extends ConsumerWidget {
  final Widget child;
  const MainLayout({super.key, required this.child});

  // Función para determinar el índice activo basado en la ruta actual
  int _calculateSelectedIndex(BuildContext context) {
    final String location = GoRouterState.of(context).matchedLocation;
    if (location.startsWith('/home')) {
      return 0;
    }
    if (location.startsWith('/meal-plan')) {
      return 1;
    }
    if (location.startsWith('/recipes')) {
      return 2;
    }
    if (location.startsWith('/grocery-list')) {
      return 3;
    }
    if (location.startsWith('/nutrition')) {
      return 4;
    }
    if (location.startsWith('/profile')) {
      return 5;
    }
    return 0;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: child,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _calculateSelectedIndex(context),
        onTap: (int index) {
          switch (index) {
            case 0:
              context.go('/home');
              break;
            case 1:
              context.go('/meal-plan');
              break;
            case 2:
              context.go('/recipes');
              break;
            case 3:
              context.go('/grocery-list');
              break;
            case 4:
              context.go('/nutrition');
              break;
            case 5:
              context.go('/profile');
              break;
          }
        },
        // Es importante definir el tipo como 'fixed' para que se vean más de 3 items
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.home),
            label: AppLocalizations.of(context).homeTitle,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.calendar_today),
            label: AppLocalizations.of(context).mealPlanTitle,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.restaurant_menu),
            label: AppLocalizations.of(context).recipesTitle,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.shopping_cart),
            label: AppLocalizations.of(context).groceryTitle,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.pie_chart),
            label: AppLocalizations.of(context).nutritionTitle,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.person),
            label: AppLocalizations.of(context).profileTitle,
          ),
        ],
      ),
    );
  }
}
