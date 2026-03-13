# 🥗 Meal Plan AI Flutter App

This is a modern Flutter application that serves as a frontend to a NestJS/Supabase backend. It leverages AI to provide an intelligent meal planning and cooking assistant experience.

The app uses Riverpod with code generation for robust state management and follows a clean architecture pattern.

## Features

- **Meal Planning:** Generate, store, and modify your weekly meal plans with AI assistance.
- **Recipes & Cooking Assistant:** Browse recipes, read detailed instructions, and use a step-by-step cooking assistant.
- **Grocery List:** Track inventory, automatically add recipe ingredients to your list, and manage a digital pantry.
- **Nutrition Tracking:** View macros and detailed nutritional info for meals.
- **Authentication:** Passwordless email OTP and Google Sign-in.
- **Dynamic Theming & Localization:** Seamlessly switch between light/dark mode and multiple languages.
- **Realtime Feedback:** Visual indicators (`awesome_snackbar_content`) while the app processes requests.

## Requirements

- **Flutter SDK:** ^3.8.1
- **Backend (NestJS / Supabase):** Make sure the backend and database are running.
- **API URL / Supabase Config:** Access to your backend endpoint and Supabase project.

## Installation

1. Clone the repository:

```bash
git clone https://github.com/lauritaila/meal_plan_app.git
cd meal_plan_app
```

2. Environment configuration:

- Create a `.env` file in the project root (ensure it matches the assets definition in `pubspec.yaml`):

```
SUPABASE_URL=your_supabase_url
SUPABASE_ANON_KEY=your_supabase_anon_key
API_URL=http://your-backend-ip:3000/api
```

3. Install dependencies:

```bash
flutter pub get
```

4. Generate Riverpod classes (build runner):

```bash
dart run build_runner build --delete-conflicting-outputs
# Or to watch for changes during development:
dart run build_runner watch
```

5. Run the app:

```bash
flutter run
```

## Project Structure

The project is organized in layers following a feature-first clean architecture approach:

```
lib/
 ┣ config/                 # Router, theme, and API configuration
 ┣ core/                   # Shared core functionality (e.g., Supabase client)
 ┣ features/               # Feature modules
 ┃ ┣ auth/                 # Authentication (Login, Signup, OTP)
 ┃ ┣ grocery_list/         # Pantry and Grocery lists
 ┃ ┣ home/                 # Dashboard/Home screen
 ┃ ┣ meal_plan/            # Meal planning logic and UI
 ┃ ┣ recipes/              # Recipe browsing and cooking assistant
 ┃ ┣ profile/              # User settings and profile management
 ┃ ┗ shared/               # Shared widgets and utilities
 ┣ l10n/                   # Localization files (ARB)
 ┗ main.dart               # Entry point with ProviderScope
```

## Key Dependencies

- **State:** `flutter_riverpod`, `riverpod_annotation`
- **Navigation:** `go_router`
- **Network & DB:** `dio`, `supabase_flutter`
- **Form Validation:** `formz`
- **UI & Feedback:** `awesome_snackbar_content`, `fl_chart`, `confetti`
- **Utilities:** `flutter_dotenv`, `shared_preferences`, `intl`

## Contributing

Contributions are welcome! If you find a bug or have a suggestion, please open an issue or submit a pull request.
