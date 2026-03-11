# Project Audit: Theming & Localization

This audit reviews the current state of the application against the best practices defined in the `flutter-dev` and `flutter-theming` skills. The goal is to centralize visual styling and text.

## 1. Core Guidelines to Enforce

*   **Colors**: **Never** hardcode hex colors (e.g., `Color(0xFF...)`) or use `Colors.*` inline unless explicitly testing. All colors MUST be derived from the application's `ColorScheme` (e.g., `Theme.of(context).colorScheme.primary`).
*   **Typography**: Avoid hardcoded `TextStyle` definitions in individual widgets. Use `Theme.of(context).textTheme` (e.g., `.bodyMedium`, `.titleLarge`) and apply standard font sizes and weights globally.
*   **Strings and Text**: **No** hardcoded text (`Text('My String')`). Every user-facing string must be referenced via `AppLocalizations.of(context)`. 
*   **Component Themes**: Use `ThemeData` configuration blocks (e.g., `CardThemeData`, `FilledButtonThemeData`, `BottomNavigationBarThemeData`) to style components globally rather than decorating each instance.

---

## 2. Hardcoded Colors Audit Findings

A global sweep of the project reveals heavy use of `Color(0xFF...)` and `Colors.*` across the presentation layers. These must be migrated to `Theme.of(context).colorScheme`.

### 📌 Critical Areas (Screens & Layouts)
*   **Main Navigation**: `lib/features/shared/screens/main_layout.dart`
*   **Home Screen**: `lib/features/home/presentation/screens/home_screen.dart`
*   **Profile Module**: 
    *   `profile_screen.dart`, `preferences_details_screen.dart`, `change_email_screen.dart`, `language_settings_screen.dart`
*   **Recipes Module**: 
    *   `recipe_detail_screen.dart`, `recipes_list_screen.dart`, `cooking_assistant_screen.dart`, `favorite_recipes_screen.dart`
*   **Meal Plan Module**:
    *   `meal_plan_day_screen.dart`, `new_meal_plan_screen.dart`, `detail_meal_plan.dart`, `meal_plan_entries_screen.dart`
*   **Grocery List Module**:
    *   `grocery_lists_screen.dart`, `grocery_list_detail_screen.dart`, `pantry_screen.dart`

### 📌 Critical Areas (Widgets & Components)
*   **Shared**: `custom_text_form_field.dart`, `custom_filled_button.dart`, `select_list_sheet.dart`
*   **Nutrition**: Gamification rings, charts, and average cards strongly rely on fixed custom hex colors (`hero_consistency_ring.dart`, `weekly_activity_chart.dart`, `gamification_achievements.dart`).
*   **Meal Plan Actions**: All bottom sheets (`swap_recipe_sheet.dart`, `delete_entry_sheet.dart`, `plan_actions_sheet.dart`, etc.) use hardcoded colors for their headers and buttons.
*   **Grocery/Pantry Cards**: `grocery_item_tile.dart`, `pantry_item_tile.dart`, `create_list_dialog.dart`

---

## 3. Hardcoded Text & Localization Audit Findings

While a major pass for localization was recently completed for principal screens, there is still risk of un-localized text in the following scenarios:
*   **Error Messages & Snackbars**: Verify that exceptions caught and shown via `ScaffoldMessenger` or dialogs are using `l10n`.
*   **Bottom Sheets & Dialogs**: Specifically check the inner widgets of `save_ingredients_flow.dart`, `create_list_dialog.dart`, `regenerate_entry_sheet.dart`.
*   **Empty States**: Ensure labels indicating "No items found" or "No meal plans" in `grocery_lists_screen.dart` and `meal_plan_list_screen.dart` are using localization keys.

---

## 4. Execution Plan & Recommendations

### Step 1: Establish the Global Theme (`lib/config/theme/app_theme.dart`)
1.  Define a robust `ColorScheme.fromSeed` (or `ColorScheme` directly if precise branding is needed).
2.  Map existing custom shades (e.g., the specific Greens used in the app like `Color(0xFF4A614A)`) to standard Material 3 roles (`primary`, `onPrimary`, `primaryContainer`, `surface`, `onSurfaceVariant`, etc.).
3.  Inject component themes (`CardThemeData`, `BottomSheetThemeData`, `InputDecorationThemeData`) here.

### Step 2: Extract Gamification/Custom Colors to `ThemeExtension`
For colors that do not logically map to Material 3 roles (e.g., specific activity chart colors, streak rings, dietary macro colors):
1.  Create a `ThemeExtension` (e.g., `class AppCustomColors extends ThemeExtension<AppCustomColors>`).
2.  Register it in `ThemeData(extensions: [AppCustomColors(...)])`.
3.  Reference it in widgets: `Theme.of(context).extension<AppCustomColors>()!.macroProteinColor`.

### Step 3: Screen-by-Screen Replacement
1.  Iterate through the files listed in Section 2.
2.  Replace instances of `Color(...)` and `TextStyle(...)`.
3.  Instead of passing custom padding/shape/colors to every `FilledButton`, remove inline styles and let the global `ThemeData` handle it.

### Step 4: Final Text Extraction
1. Regex scrape `Text\(['"][A-Za-z]` across `.dart` files.
2. Move any found developer text or internal IDs to `app_en.arb` and `app_es.arb`.

---

## 5. SOLID Principles Audit & Recommendations

Based on the `flutter-dev` skill guidelines, the application should adhere to SOLID principles to maintain a clean, scalable, and testable codebase. Below are actionable recommendations for applying these principles to this project.

### Single Responsibility Principle (SRP)
*A class or widget should have only one reason to change.*
*   **UI Components:** Break down large `build()` methods. If a screen has multiple complex sections (e.g., a header, a list, and a bottom sheet), extract them into smaller, preferably `const`, private `StatelessWidget` classes rather than helper methods returning `Widget`.
*   **State Management:** UI widgets should purely handle presentation. Move complex business logic, data formatting, and API calls entirely into Riverpod `Notifier` or `AsyncNotifier` classes. 

### Open/Closed Principle (OCP)
*Software entities should be open for extension, but closed for modification.*
*   **Reusable Widgets:** Build generic, customizable core widgets (e.g., a base `CustomBottomSheet` or `StandardAppCard`) that accept configurations (like child widgets or styling overrides) rather than copying and modifying specific UI code for every new feature.
*   **Theme Extensions:** By using `ThemeExtension` for custom colors (as recommended above), you can add new color properties without altering the core Material color schema.

### Liskov Substitution Principle (LSP)
*Subtypes must be substitutable for their base types without altering the correctness of the program.*
*   **Widget Inheritance:** Prefer composition over inheritance. When you do extend classes (like `StateNotifier` or custom UI components), ensure the subclass adheres strictly to the expected behavior of the parent without throwing unexpected exceptions for unimplemented methods.

### Interface Segregation Principle (ISP)
*Clients should not be forced to depend on interfaces they do not use.*
*   **Provider Granularity:** Avoid creating massive monolithic Riverpod providers that handle unrelated data. Instead of a single `AppProvider`, use specific providers for specific domains (`mealPlanProvider`, `groceryListProvider`, `userSettingsProvider`) so widgets only rebuild when their specific data changes.

### Dependency Inversion Principle (DIP)
*Depend on abstractions, not concretions.*
*   **Dependency Injection:** Keep relying on Riverpod for dependency injection. Do not instantiate repository classes or API services directly inside UI widgets or other services. Always `ref.watch` or `ref.read` interfaces to ensure components remain testable and mockable later.
