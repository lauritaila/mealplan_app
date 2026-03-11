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
    if (location.startsWith('/profile')) {
      return 4;
    }
    return 0;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: child,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
          color: const Color(0xFF5A7258), // Dark green background from screenshot
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
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
                context.go('/profile');
                break;
            }
          },
          backgroundColor: Colors.transparent, // Let the container's color show
          elevation: 0,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: Colors.white,
          unselectedItemColor: const Color(0xFF9CB099), // Light green for unselected
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 12),
          items: [
            BottomNavigationBarItem(
              icon: const Padding(
                padding: EdgeInsets.only(bottom: 4),
                child: Icon(Icons.home_filled, size: 28),
              ),
              label: AppLocalizations.of(context).homeTitle,
            ),
            BottomNavigationBarItem(
              icon: const Padding(
                padding: EdgeInsets.only(bottom: 4),
                child: Icon(Icons.calendar_month, size: 26),
              ),
              label: AppLocalizations.of(context).mealPlanTitle,
            ),
            BottomNavigationBarItem(
              icon: const Padding(
                padding: EdgeInsets.only(bottom: 4),
                child: Icon(Icons.restaurant, size: 26),
              ),
              label: AppLocalizations.of(context).recipesTitle,
            ),
            BottomNavigationBarItem(
              icon: const Padding(
                padding: EdgeInsets.only(bottom: 4),
                child: Icon(Icons.shopping_cart, size: 26),
              ),
              label: AppLocalizations.of(context).groceryTitle,
            ),
            BottomNavigationBarItem(
              icon: const Padding(
                padding: EdgeInsets.only(bottom: 4),
                child: Icon(Icons.person, size: 28),
              ),
              label: AppLocalizations.of(context).profileTitle,
            ),
          ],
        ),
      ),
    );
  }
}
