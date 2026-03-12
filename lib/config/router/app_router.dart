import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:meal_plan_app/features/auth/auth.dart';
import 'package:meal_plan_app/features/home/home.dart';
import 'package:meal_plan_app/features/profile/profile.dart';
import 'package:meal_plan_app/features/recipes/recipes.dart';
import 'package:meal_plan_app/features/auth/presentation/provider/provider.dart';
import 'package:meal_plan_app/features/shared/screens/main_layout.dart';
import 'package:meal_plan_app/features/shared/shared.dart';

import 'package:meal_plan_app/features/grocery_list/grocery_list.dart';
import 'package:meal_plan_app/features/nutrition/nutrition.dart';

import '../../features/meal_plan/meal_plan.dart';
import 'package:meal_plan_app/features/meal_plan/domain/domain.dart';
import 'package:meal_plan_app/features/meal_plan/presentation/screens/loading_meal_plan_screen.dart';
import 'package:meal_plan_app/features/meal_plan/presentation/screens/meal_plan_list_screen.dart';
import 'package:meal_plan_app/features/meal_plan/presentation/screens/meal_plan_entries_screen.dart';


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
            usePantry: (extra['usePantry'] as bool?) ?? true,
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
                path: 'history',
                builder: (context, state) => const MealPlanListScreen(),
              ),
              GoRoute(
                path: ':id',
                builder: (context, state) {
                  final planId = int.tryParse(
                    state.pathParameters['id'] ?? '',
                  );
                  if (planId == null || planId <= 0) {
                    return const MealPlanDayScreen();
                  }
                  final extra = state.extra as Map<String, dynamic>?;
                  final planName = extra?['planName'] as String?;
                  return MealPlanEntriesScreen(
                    planId: planId,
                    planName: planName,
                  );
                },
              ),
            ],
          ),
          GoRoute(
            path: '/recipes',
            builder: (context, state) => const RecipesListScreen(),
            routes: [
              GoRoute(
                path: 'favorites',
                builder: (context, state) => const FavoriteRecipesScreen(),
              ),
              GoRoute(
                path: ':id',
                builder: (context, state) {
                  final idParam = state.pathParameters['id'];
                  final queryParams = state.uri.queryParameters;
                  final entryIdParam = queryParams['entryId'];
                  final status = queryParams['status'];
                  final parsedId = int.tryParse(idParam ?? '');
                  final entryId = int.tryParse(entryIdParam ?? '');
                  
                  if (parsedId == null || parsedId <= 0) {
                    // Invalid ID: show recipes list or error screen
                    return const RecipesListScreen();
                  }
                  return RecipeDetailScreen(
                    recipeId: parsedId,
                    entryId: entryId,
                    status: status,
                  );
                },
                routes: [
                  GoRoute(
                    path: 'assistant',
                    builder: (context, state) {
                      final idParam = state.pathParameters['id'];
                      final parsedId = int.tryParse(idParam ?? '');
                      if (parsedId == null || parsedId <= 0) {
                        return const RecipesListScreen();
                      }
                      return CookingAssistantScreen(recipeId: parsedId);
                    },
                  ),
                ],
              ),
            ],
          ),
          GoRoute(
            path: '/grocery-list',
            builder: (context, state) => const GroceryListsScreen(),
            routes: [
              GoRoute(
                path: 'pantry',
                builder: (context, state) => const PantryScreen(),
              ),
              GoRoute(
                path: ':id',
                builder: (context, state) {
                  final idParam = state.pathParameters['id'];
                  final parsedId = int.tryParse(idParam ?? '');
                  if (parsedId == null || parsedId <= 0) {
                    return const GroceryListsScreen();
                  }
                  return GroceryListDetailScreen(listId: parsedId);
                },
              ),
            ],
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
          return '/init';
        }
      }
      return null;
    },
    errorBuilder: (context, state) => ErrorScreen(error: state.error),
  );
});
