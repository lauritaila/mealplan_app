import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:meal_plan_app/features/auth/auth.dart';
import 'package:meal_plan_app/features/home/home.dart';
import 'package:meal_plan_app/features/profile/profile.dart';
import 'package:meal_plan_app/features/auth/presentation/provider/provider.dart';
import 'package:meal_plan_app/features/shared/screens/main_layout.dart';
import 'package:meal_plan_app/features/shared/shared.dart';

import '../../features/meal_plan/meal_plan.dart';
import 'package:meal_plan_app/features/meal_plan/domain/domain.dart';
import 'package:meal_plan_app/features/meal_plan/presentation/screens/loading_meal_plan_screen.dart';



// --- Placeholders para las pantallas ---
class RecipesScreen extends StatelessWidget {
  const RecipesScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Recipes')),
    body: Center(child: Text('Recipes Screen')),
  );
}

class GroceryListScreen extends StatelessWidget {
  const GroceryListScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Grocery List')),
    body: Center(child: Text('Grocery List Screen')),
  );
}

class NutritionScreen extends StatelessWidget {
  const NutritionScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Nutrition')),
    body: Center(child: Text('Nutrition Screen')),
  );
}

// --- Configuración del Router ---
class GoRouterNotifier extends ChangeNotifier {
  final Ref _ref;
  GoRouterNotifier(this._ref) {
    _ref.listen<AuthState>(authProvider, (_, _) => notifyListeners());
  }
}

final goRouterNotifierProvider = Provider((ref) {
  return GoRouterNotifier(ref);
});

final appRouterProvider = Provider<GoRouter>((ref) {
  final goRouterNotifier = ref.watch(goRouterNotifierProvider);

  return GoRouter(
    refreshListenable: goRouterNotifier,
    initialLocation: '/init',
    routes: [
      // --- Rutas de Autenticación (Fuera del Shell) ---
      GoRoute(path: '/init', builder: (context, state) => const InitScreen()),
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(
        path: '/signup',
        builder: (context, state) => const SignUpScreen(),
      ),
      GoRoute(
        path: '/preferences-wizard',
        builder: (context, state) => const PreferenceWizardScreen(),
      ),
      GoRoute(
        path: '/verify-otp',
        builder: (context, state) => const OtpVerificationScreen(),
      ),

      // --- Rutas de Generación del Plan (Fuera del Shell) ---
      GoRoute(
        path: '/meal-plan/new',
        builder: (context, state) => const NewMealPlanScreen(),
      ),
      GoRoute(
        path: '/meal-plan/loading',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>? ?? {};
          return LoadingMealPlanScreen(
            description: (extra['description'] as String?) ?? '',
            numberOfDays: (extra['numberOfDays'] as int?) ?? 3,
            quantityOfPeople: (extra['quantityOfPeople'] as int?) ?? 1,
            mealTypes: List<String>.from(
              extra['mealTypes'] as List? ?? const [],
            ),
          );
        },
      ),
      GoRoute(
        path: '/meal-plan/approve',
        builder: (context, state) {
          final generatedPlan = state.extra as MealPlanResponse?;
          return DetailMealPlanScreen(generatedPlan: generatedPlan);
        },
      ),
      GoRoute(
        path: '/premium',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>? ?? {};
          final title = (extra['title'] as String?) ?? 'Premium';
          final message =
              (extra['message'] as String?) ??
              'You have run out of plan generations this week.';
          return PremiumScreen(title: title, message: message);
        },
      ),

      // --- Rutas Principales con Barra de Navegación (ShellRoute) ---
      ShellRoute(
        builder: (context, state, child) {
          return MainLayout(child: child);
        },
        routes: [
          GoRoute(
            path: '/home',
            builder: (context, state) => const HomeScreen(),
          ),
          GoRoute(
            path: '/meal-plan',
            builder: (context, state) => const MealPlanDayScreen(),
            routes: [
              GoRoute(
                path: ':id', // El path es solo el parámetro
                builder: (context, state) {
                  final planId = state.pathParameters['id'] ?? 'no-id';
                  // Aquí iría tu pantalla de detalle del plan
                  return Scaffold(
                    appBar: AppBar(title: Text('Plan $planId')),
                    body: Center(child: Text('Viewing Plan ID: $planId')),
                  );
                },
              ),
            ],
          ),
          GoRoute(
            path: '/recipes',
            builder: (context, state) => const RecipesScreen(),
          ),
          GoRoute(
            path: '/grocery-list',
            builder: (context, state) => const GroceryListScreen(),
          ),
          GoRoute(
            path: '/nutrition',
            builder: (context, state) => const NutritionScreen(),
          ),
          GoRoute(
            path: '/profile',
            builder: (context, state) => const ProfileScreen(),
            routes: [
              GoRoute(
                path: 'preferences',
                builder: (context, state) => const PreferencesDetailsScreen(),
              ),
              GoRoute(
                path: 'language',
                builder: (context, state) => const LanguageSettingsScreen(),
              ),
              GoRoute(
                path: 'change-email',
                builder: (context, state) => const ChangeEmailScreen(),
              ),
              GoRoute(
                path: 'view-payments',
                builder: (context, state) => const ViewPaymentsScreen(),
              ),
              GoRoute(
                path: 'subscription',
                builder: (context, state) => const SubscriptionScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
    redirect: (context, state) {
      final authState = ref.read(authProvider);
      final currentLocation = state.matchedLocation;
      final publicRoutes = ['/login', '/signup', '/init'];

      if (authState is LoadingAuthState || authState is InitialAuthState) {
        return null;
      }
      if (authState is AwaitingOtpInputState) {
        return currentLocation == '/verify-otp' ? null : '/verify-otp';
      }
      if (authState is AuthenticatedAuthState) {
        final onboardingComplete = authState.user.onboardingComplete;
        if (!onboardingComplete) {
          return currentLocation == '/preferences-wizard'
              ? null
              : '/preferences-wizard';
        }
        if (publicRoutes.contains(currentLocation) ||
            currentLocation == '/preferences-wizard' ||
            currentLocation == '/verify-otp') {
          return '/home';
        }
      }
      if (authState is! AuthenticatedAuthState) {
        if (currentLocation == '/verify-otp') {
          return '/login';
        }
        if (!publicRoutes.contains(currentLocation)) {
          return '/login';
        }
      }
      return null;
    },
    errorBuilder: (context, state) => ErrorScreen(error: state.error),
  );
});
