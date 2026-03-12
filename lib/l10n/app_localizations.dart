import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es'),
  ];

  /// The title of the application.
  ///
  /// In en, this message translates to:
  /// **'Meal Plan App'**
  String get appTitle;

  /// No description provided for @genericError.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again.'**
  String get genericError;

  /// No description provided for @errorFieldRequired.
  ///
  /// In en, this message translates to:
  /// **'This field is required.'**
  String get errorFieldRequired;

  /// No description provided for @errorEmailInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid email address.'**
  String get errorEmailInvalid;

  /// No description provided for @errorPasswordMinLength.
  ///
  /// In en, this message translates to:
  /// **'Minimum 6 characters.'**
  String get errorPasswordMinLength;

  /// No description provided for @errorPasswordFormat.
  ///
  /// In en, this message translates to:
  /// **'Must include an uppercase letter, lowercase letter, and a number.'**
  String get errorPasswordFormat;

  /// No description provided for @errorAuthInvalidCredentials.
  ///
  /// In en, this message translates to:
  /// **'Invalid credentials. Please check your email and password.'**
  String get errorAuthInvalidCredentials;

  /// No description provided for @errorAuthEmailNotVerified.
  ///
  /// In en, this message translates to:
  /// **'Your email has not been verified. Please check your inbox.'**
  String get errorAuthEmailNotVerified;

  /// No description provided for @errorAuthUserNotFound.
  ///
  /// In en, this message translates to:
  /// **'User not found.'**
  String get errorAuthUserNotFound;

  /// No description provided for @errorAuthEmailInUse.
  ///
  /// In en, this message translates to:
  /// **'This email is already registered.'**
  String get errorAuthEmailInUse;

  /// No description provided for @errorAuthPasswordResetFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not reset password. Please try again later.'**
  String get errorAuthPasswordResetFailed;

  /// No description provided for @errorAuthResendVerificationFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not resend verification email.'**
  String get errorAuthResendVerificationFailed;

  /// No description provided for @errorAuthInvalidOtp.
  ///
  /// In en, this message translates to:
  /// **'The code you entered is invalid or has expired.'**
  String get errorAuthInvalidOtp;

  /// No description provided for @errorAuthUnexpected.
  ///
  /// In en, this message translates to:
  /// **'An unexpected authentication error occurred.'**
  String get errorAuthUnexpected;

  /// No description provided for @errorAuthGoogleSignInFailed.
  ///
  /// In en, this message translates to:
  /// **'An unexpected error occurred during Google Sign-In.'**
  String get errorAuthGoogleSignInFailed;

  /// No description provided for @errorAuthSendOtpFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to send OTP. Please try again.'**
  String get errorAuthSendOtpFailed;

  /// No description provided for @errorNetworkTimeout.
  ///
  /// In en, this message translates to:
  /// **'The request timed out. Please check your internet connection.'**
  String get errorNetworkTimeout;

  /// No description provided for @errorNetworkNoConnection.
  ///
  /// In en, this message translates to:
  /// **'No internet connection. Please connect and try again.'**
  String get errorNetworkNoConnection;

  /// No description provided for @errorNetworkServer.
  ///
  /// In en, this message translates to:
  /// **'Server error. Please try again later.'**
  String get errorNetworkServer;

  /// No description provided for @errorNetworkBadResponse.
  ///
  /// In en, this message translates to:
  /// **'Unexpected response from the server.'**
  String get errorNetworkBadResponse;

  /// No description provided for @errorNetworkUnreachableHost.
  ///
  /// In en, this message translates to:
  /// **'Cannot reach the server. Check the host, port, or VPN.'**
  String get errorNetworkUnreachableHost;

  /// No description provided for @errorNetworkSsl.
  ///
  /// In en, this message translates to:
  /// **'Secure connection failed (SSL/TLS).'**
  String get errorNetworkSsl;

  /// No description provided for @errorNetworkRateLimit.
  ///
  /// In en, this message translates to:
  /// **'Too many requests. Please wait and try again.'**
  String get errorNetworkRateLimit;

  /// No description provided for @errorNetworkBadRequest.
  ///
  /// In en, this message translates to:
  /// **'Request rejected by server.'**
  String get errorNetworkBadRequest;

  /// No description provided for @errorDataNotFound.
  ///
  /// In en, this message translates to:
  /// **'Requested data was not found.'**
  String get errorDataNotFound;

  /// No description provided for @errorDataInvalid.
  ///
  /// In en, this message translates to:
  /// **'Invalid data.'**
  String get errorDataInvalid;

  /// No description provided for @errorDataCreationFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to create data.'**
  String get errorDataCreationFailed;

  /// No description provided for @errorDataUpdateFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to update data.'**
  String get errorDataUpdateFailed;

  /// No description provided for @errorDataFetchFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to fetch data.'**
  String get errorDataFetchFailed;

  /// No description provided for @errorDataSerializationFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to parse data.'**
  String get errorDataSerializationFailed;

  /// No description provided for @errorDataEmptyResponse.
  ///
  /// In en, this message translates to:
  /// **'The response was empty.'**
  String get errorDataEmptyResponse;

  /// No description provided for @errorPermissionUnauthorized.
  ///
  /// In en, this message translates to:
  /// **'Unauthorized. Please sign in again.'**
  String get errorPermissionUnauthorized;

  /// No description provided for @errorPermissionForbidden.
  ///
  /// In en, this message translates to:
  /// **'You do not have permission to perform this action.'**
  String get errorPermissionForbidden;

  /// No description provided for @errorConfigMissing.
  ///
  /// In en, this message translates to:
  /// **'Configuration is missing.'**
  String get errorConfigMissing;

  /// No description provided for @errorConfigInvalid.
  ///
  /// In en, this message translates to:
  /// **'Configuration is invalid.'**
  String get errorConfigInvalid;

  /// No description provided for @errorMealPlanNotAuthenticated.
  ///
  /// In en, this message translates to:
  /// **'Please sign in to continue.'**
  String get errorMealPlanNotAuthenticated;

  /// No description provided for @errorMealPlanDaysNotAllowed.
  ///
  /// In en, this message translates to:
  /// **'The selected number of days is not allowed.'**
  String get errorMealPlanDaysNotAllowed;

  /// No description provided for @errorMealPlanTypesNotAllowed.
  ///
  /// In en, this message translates to:
  /// **'Some selected meal types are not allowed.'**
  String get errorMealPlanTypesNotAllowed;

  /// No description provided for @errorMealPlanGenerateFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not generate the plan. Please try again.'**
  String get errorMealPlanGenerateFailed;

  /// No description provided for @errorMealPlanQuotaReached.
  ///
  /// In en, this message translates to:
  /// **'You have run out of plan generations this week.'**
  String get errorMealPlanQuotaReached;

  /// No description provided for @approvePlanTitle.
  ///
  /// In en, this message translates to:
  /// **'Approve plan'**
  String get approvePlanTitle;

  /// No description provided for @noPlanDataReceived.
  ///
  /// In en, this message translates to:
  /// **'No plan data received.'**
  String get noPlanDataReceived;

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// No description provided for @graceWelcomeTitle.
  ///
  /// In en, this message translates to:
  /// **'We missed you! Welcome back.'**
  String get graceWelcomeTitle;

  /// No description provided for @graceWelcomeMessage.
  ///
  /// In en, this message translates to:
  /// **'All your information is saved and ready to continue.'**
  String get graceWelcomeMessage;

  /// No description provided for @continueLabel.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueLabel;

  /// No description provided for @mealsCount.
  ///
  /// In en, this message translates to:
  /// **'{count} meals'**
  String mealsCount(Object count);

  /// No description provided for @caloriesKcal.
  ///
  /// In en, this message translates to:
  /// **'{calories} kcal'**
  String caloriesKcal(Object calories);

  /// No description provided for @servingsLabel.
  ///
  /// In en, this message translates to:
  /// **'Servings: {count}'**
  String servingsLabel(Object count);

  /// No description provided for @prepMinutesLabel.
  ///
  /// In en, this message translates to:
  /// **'Prep: {minutes} min'**
  String prepMinutesLabel(Object minutes);

  /// No description provided for @cookMinutesLabel.
  ///
  /// In en, this message translates to:
  /// **'Cook: {minutes} min'**
  String cookMinutesLabel(Object minutes);

  /// No description provided for @proteinLabel.
  ///
  /// In en, this message translates to:
  /// **'Protein: {grams} g'**
  String proteinLabel(Object grams);

  /// No description provided for @carbsLabel.
  ///
  /// In en, this message translates to:
  /// **'Carbs: {grams} g'**
  String carbsLabel(Object grams);

  /// No description provided for @fatsLabel.
  ///
  /// In en, this message translates to:
  /// **'Fats: {grams} g'**
  String fatsLabel(Object grams);

  /// No description provided for @preparingPlanTitle.
  ///
  /// In en, this message translates to:
  /// **'Preparing your plan'**
  String get preparingPlanTitle;

  /// No description provided for @loadingMessageCookbook.
  ///
  /// In en, this message translates to:
  /// **'Checking grandma\'s cookbook...'**
  String get loadingMessageCookbook;

  /// No description provided for @loadingMessageRecipes.
  ///
  /// In en, this message translates to:
  /// **'Dusting off the old recipes...'**
  String get loadingMessageRecipes;

  /// No description provided for @loadingMessageAunts.
  ///
  /// In en, this message translates to:
  /// **'Asking the aunts for their secrets...'**
  String get loadingMessageAunts;

  /// No description provided for @loadingMessageFridge.
  ///
  /// In en, this message translates to:
  /// **'Peeking into the fridge...'**
  String get loadingMessageFridge;

  /// No description provided for @loadingMessageKnives.
  ///
  /// In en, this message translates to:
  /// **'Sharpening imaginary knives...'**
  String get loadingMessageKnives;

  /// No description provided for @loadingMessageTablespoons.
  ///
  /// In en, this message translates to:
  /// **'Measuring tablespoons by eye...'**
  String get loadingMessageTablespoons;

  /// No description provided for @cookingCombosMessage.
  ///
  /// In en, this message translates to:
  /// **'Cooking up tasty, healthy combos for you...'**
  String get cookingCombosMessage;

  /// No description provided for @cancelAndGoBack.
  ///
  /// In en, this message translates to:
  /// **'Cancel and go back'**
  String get cancelAndGoBack;

  /// No description provided for @planLimitReachedTitle.
  ///
  /// In en, this message translates to:
  /// **'Plan limit reached'**
  String get planLimitReachedTitle;

  /// No description provided for @planLimitReachedMessage.
  ///
  /// In en, this message translates to:
  /// **'You have run out of plan generations this week.'**
  String get planLimitReachedMessage;

  /// No description provided for @newPlanTitle.
  ///
  /// In en, this message translates to:
  /// **'New Plan'**
  String get newPlanTitle;

  /// No description provided for @clear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get clear;

  /// No description provided for @configurePlanTitle.
  ///
  /// In en, this message translates to:
  /// **'Configure your plan'**
  String get configurePlanTitle;

  /// No description provided for @configurePlanSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Define duration, people and base meals.'**
  String get configurePlanSubtitle;

  /// No description provided for @durationTitle.
  ///
  /// In en, this message translates to:
  /// **'Duration'**
  String get durationTitle;

  /// No description provided for @daysLabel.
  ///
  /// In en, this message translates to:
  /// **'{days} days'**
  String daysLabel(Object days);

  /// No description provided for @dinersTitle.
  ///
  /// In en, this message translates to:
  /// **'Diners'**
  String get dinersTitle;

  /// No description provided for @peopleCount.
  ///
  /// In en, this message translates to:
  /// **'{count} people'**
  String peopleCount(Object count);

  /// No description provided for @mealTypesTitle.
  ///
  /// In en, this message translates to:
  /// **'Meal types'**
  String get mealTypesTitle;

  /// No description provided for @mealTypeBreakfast.
  ///
  /// In en, this message translates to:
  /// **'Breakfast'**
  String get mealTypeBreakfast;

  /// No description provided for @mealTypeLunch.
  ///
  /// In en, this message translates to:
  /// **'Lunch'**
  String get mealTypeLunch;

  /// No description provided for @mealTypeSnack.
  ///
  /// In en, this message translates to:
  /// **'Snack'**
  String get mealTypeSnack;

  /// No description provided for @mealTypeDinner.
  ///
  /// In en, this message translates to:
  /// **'Dinner'**
  String get mealTypeDinner;

  /// No description provided for @mealTypeBreakfastSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Energy for the day'**
  String get mealTypeBreakfastSubtitle;

  /// No description provided for @mealTypeLunchSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Main meal'**
  String get mealTypeLunchSubtitle;

  /// No description provided for @mealTypeSnackSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Something light'**
  String get mealTypeSnackSubtitle;

  /// No description provided for @mealTypeDinnerSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Light and nutritious'**
  String get mealTypeDinnerSubtitle;

  /// No description provided for @notesOptionalTitle.
  ///
  /// In en, this message translates to:
  /// **'Notes (optional)'**
  String get notesOptionalTitle;

  /// No description provided for @notesHint.
  ///
  /// In en, this message translates to:
  /// **'E.g.: Lactose-free, more proteins...'**
  String get notesHint;

  /// No description provided for @mealsOfDayTitle.
  ///
  /// In en, this message translates to:
  /// **'Meals of the day'**
  String get mealsOfDayTitle;

  /// No description provided for @skipMealAction.
  ///
  /// In en, this message translates to:
  /// **'Skip meal'**
  String get skipMealAction;

  /// No description provided for @unskipMealAction.
  ///
  /// In en, this message translates to:
  /// **'Unskip meal'**
  String get unskipMealAction;

  /// No description provided for @mealSkippedLabel.
  ///
  /// In en, this message translates to:
  /// **'Skipped'**
  String get mealSkippedLabel;

  /// No description provided for @skipMealDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Meal skipped'**
  String get skipMealDialogTitle;

  /// No description provided for @skipMealDialogMessage.
  ///
  /// In en, this message translates to:
  /// **'It\'s okay to skip a meal sometimes. You can continue with your plan whenever you\'re ready.'**
  String get skipMealDialogMessage;

  /// No description provided for @viewRecipeDetails.
  ///
  /// In en, this message translates to:
  /// **'View recipe'**
  String get viewRecipeDetails;

  /// No description provided for @categoriesTitle.
  ///
  /// In en, this message translates to:
  /// **'Categories'**
  String get categoriesTitle;

  /// No description provided for @metricCalories.
  ///
  /// In en, this message translates to:
  /// **'Cal'**
  String get metricCalories;

  /// No description provided for @metricServings.
  ///
  /// In en, this message translates to:
  /// **'Servings'**
  String get metricServings;

  /// No description provided for @metricFat.
  ///
  /// In en, this message translates to:
  /// **'Fat'**
  String get metricFat;

  /// No description provided for @metricCarbs.
  ///
  /// In en, this message translates to:
  /// **'Carbs'**
  String get metricCarbs;

  /// No description provided for @metricProtein.
  ///
  /// In en, this message translates to:
  /// **'Protein'**
  String get metricProtein;

  /// No description provided for @metricKcal.
  ///
  /// In en, this message translates to:
  /// **'Kcal'**
  String get metricKcal;

  /// No description provided for @descriptionTitle.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get descriptionTitle;

  /// No description provided for @instructionsTitle.
  ///
  /// In en, this message translates to:
  /// **'Instructions'**
  String get instructionsTitle;

  /// No description provided for @ingredientsTitle.
  ///
  /// In en, this message translates to:
  /// **'Ingredients'**
  String get ingredientsTitle;

  /// No description provided for @noInstructions.
  ///
  /// In en, this message translates to:
  /// **'No instructions.'**
  String get noInstructions;

  /// No description provided for @noIngredients.
  ///
  /// In en, this message translates to:
  /// **'No ingredients.'**
  String get noIngredients;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @noMealsLoggedToday.
  ///
  /// In en, this message translates to:
  /// **'No meals logged for today.'**
  String get noMealsLoggedToday;

  /// No description provided for @weekdayMonShort.
  ///
  /// In en, this message translates to:
  /// **'Mon'**
  String get weekdayMonShort;

  /// No description provided for @weekdayTueShort.
  ///
  /// In en, this message translates to:
  /// **'Tue'**
  String get weekdayTueShort;

  /// No description provided for @weekdayWedShort.
  ///
  /// In en, this message translates to:
  /// **'Wed'**
  String get weekdayWedShort;

  /// No description provided for @weekdayThuShort.
  ///
  /// In en, this message translates to:
  /// **'Thu'**
  String get weekdayThuShort;

  /// No description provided for @weekdayFriShort.
  ///
  /// In en, this message translates to:
  /// **'Fri'**
  String get weekdayFriShort;

  /// No description provided for @weekdaySatShort.
  ///
  /// In en, this message translates to:
  /// **'Sat'**
  String get weekdaySatShort;

  /// No description provided for @weekdaySunShort.
  ///
  /// In en, this message translates to:
  /// **'Sun'**
  String get weekdaySunShort;

  /// No description provided for @homeTitle.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get homeTitle;

  /// No description provided for @generateNewPlan.
  ///
  /// In en, this message translates to:
  /// **'Generate New Plan'**
  String get generateNewPlan;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @deleteAccount.
  ///
  /// In en, this message translates to:
  /// **'Delete account'**
  String get deleteAccount;

  /// No description provided for @profileNotificationsTitle.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get profileNotificationsTitle;

  /// No description provided for @profileTermsTitle.
  ///
  /// In en, this message translates to:
  /// **'Terms and Conditions'**
  String get profileTermsTitle;

  /// No description provided for @unableToLoadPlanStatus.
  ///
  /// In en, this message translates to:
  /// **'Unable to load plan status: {error}'**
  String unableToLoadPlanStatus(Object error);

  /// No description provided for @plansLeftThisWeek.
  ///
  /// In en, this message translates to:
  /// **'{remaining} of {total} plans left this week'**
  String plansLeftThisWeek(Object remaining, Object total);

  /// No description provided for @goPremiumUnlockMorePlans.
  ///
  /// In en, this message translates to:
  /// **'Go premium to unlock more meal plans.'**
  String get goPremiumUnlockMorePlans;

  /// No description provided for @goPremiumTitle.
  ///
  /// In en, this message translates to:
  /// **'Go Premium'**
  String get goPremiumTitle;

  /// No description provided for @freePlanLimitedGenerations.
  ///
  /// In en, this message translates to:
  /// **'Your free plan has limited meal plan generations.'**
  String get freePlanLimitedGenerations;

  /// No description provided for @goPremiumKeepGenerating.
  ///
  /// In en, this message translates to:
  /// **'Go premium to keep generating meal plans.'**
  String get goPremiumKeepGenerating;

  /// No description provided for @goToHome.
  ///
  /// In en, this message translates to:
  /// **'Go to Home'**
  String get goToHome;

  /// No description provided for @recipesTitle.
  ///
  /// In en, this message translates to:
  /// **'Recipes'**
  String get recipesTitle;

  /// No description provided for @favoriteRecipesTitle.
  ///
  /// In en, this message translates to:
  /// **'Favorite Recipes'**
  String get favoriteRecipesTitle;

  /// No description provided for @favoriteUpdateFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to update favorite. Please try again.'**
  String get favoriteUpdateFailed;

  /// No description provided for @favoritesTooltip.
  ///
  /// In en, this message translates to:
  /// **'Favorites'**
  String get favoritesTooltip;

  /// No description provided for @noRecipesAvailable.
  ///
  /// In en, this message translates to:
  /// **'No recipes available'**
  String get noRecipesAvailable;

  /// No description provided for @noFavoriteRecipes.
  ///
  /// In en, this message translates to:
  /// **'You don\'t have favorite recipes'**
  String get noFavoriteRecipes;

  /// No description provided for @recipeDetailTitle.
  ///
  /// In en, this message translates to:
  /// **'Recipe Detail'**
  String get recipeDetailTitle;

  /// No description provided for @errorTitle.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get errorTitle;

  /// No description provided for @errorOccurred.
  ///
  /// In en, this message translates to:
  /// **'An error occurred: {error}'**
  String errorOccurred(Object error);

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// No description provided for @register.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get register;

  /// No description provided for @signUp.
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get signUp;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @name.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get name;

  /// No description provided for @sendOtp.
  ///
  /// In en, this message translates to:
  /// **'Send OTP'**
  String get sendOtp;

  /// No description provided for @sendVerificationCodeOtp.
  ///
  /// In en, this message translates to:
  /// **'Send Verification Code OTP'**
  String get sendVerificationCodeOtp;

  /// No description provided for @signInWithGoogle.
  ///
  /// In en, this message translates to:
  /// **'Sign in with Google'**
  String get signInWithGoogle;

  /// No description provided for @dontHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account?'**
  String get dontHaveAccount;

  /// No description provided for @doYouHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Do you have an account?'**
  String get doYouHaveAccount;

  /// No description provided for @verificationCodeSentEmail.
  ///
  /// In en, this message translates to:
  /// **'A verification code has been sent to your email.'**
  String get verificationCodeSentEmail;

  /// No description provided for @otpEnterTitle.
  ///
  /// In en, this message translates to:
  /// **'Enter Verification Code'**
  String get otpEnterTitle;

  /// No description provided for @otpEnterSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Enter the 6-digit code sent to:'**
  String get otpEnterSubtitle;

  /// No description provided for @otpVerificationCodeLabel.
  ///
  /// In en, this message translates to:
  /// **'Verification Code'**
  String get otpVerificationCodeLabel;

  /// No description provided for @otpResend.
  ///
  /// In en, this message translates to:
  /// **'Didn\'t receive a code? Send again'**
  String get otpResend;

  /// No description provided for @otpVerifySignIn.
  ///
  /// In en, this message translates to:
  /// **'Verify & Sign In'**
  String get otpVerifySignIn;

  /// No description provided for @otpSentSnack.
  ///
  /// In en, this message translates to:
  /// **'Verification code sent!'**
  String get otpSentSnack;

  /// No description provided for @preferencesSaved.
  ///
  /// In en, this message translates to:
  /// **'Preferences saved successfully'**
  String get preferencesSaved;

  /// No description provided for @errorSavePreferencesRollbackFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to save preferences and rollback also failed. The app may be in an inconsistent state.'**
  String get errorSavePreferencesRollbackFailed;

  /// No description provided for @unknownError.
  ///
  /// In en, this message translates to:
  /// **'An unknown error occurred'**
  String get unknownError;

  /// No description provided for @wizardPrevious.
  ///
  /// In en, this message translates to:
  /// **'Previous'**
  String get wizardPrevious;

  /// No description provided for @wizardNext.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get wizardNext;

  /// No description provided for @wizardFinish.
  ///
  /// In en, this message translates to:
  /// **'Finish'**
  String get wizardFinish;

  /// No description provided for @stepOf.
  ///
  /// In en, this message translates to:
  /// **'Step {current} of {total}'**
  String stepOf(Object current, Object total);

  /// No description provided for @dietaryTitle.
  ///
  /// In en, this message translates to:
  /// **'Dietary Preferences & Restrictions'**
  String get dietaryTitle;

  /// No description provided for @allergiesTitle.
  ///
  /// In en, this message translates to:
  /// **'Allergies'**
  String get allergiesTitle;

  /// No description provided for @allergiesOtherTitle.
  ///
  /// In en, this message translates to:
  /// **'Other allergies'**
  String get allergiesOtherTitle;

  /// No description provided for @allergiesOtherHint.
  ///
  /// In en, this message translates to:
  /// **'Please specify any other allergies...'**
  String get allergiesOtherHint;

  /// No description provided for @foodPreferencesTitle.
  ///
  /// In en, this message translates to:
  /// **'Food Preferences'**
  String get foodPreferencesTitle;

  /// No description provided for @dislikedFoodsTitle.
  ///
  /// In en, this message translates to:
  /// **'Disliked Foods'**
  String get dislikedFoodsTitle;

  /// No description provided for @dislikedFoodsHint.
  ///
  /// In en, this message translates to:
  /// **'Olives, cilantro, mushrooms...'**
  String get dislikedFoodsHint;

  /// No description provided for @likedFoodsTitle.
  ///
  /// In en, this message translates to:
  /// **'Liked Foods'**
  String get likedFoodsTitle;

  /// No description provided for @likedFoodsHint.
  ///
  /// In en, this message translates to:
  /// **'Avocado, grilled salmon, kale chips...'**
  String get likedFoodsHint;

  /// No description provided for @goalsTitle.
  ///
  /// In en, this message translates to:
  /// **'Dietary Choices & Goals'**
  String get goalsTitle;

  /// No description provided for @cookingDetailsTitle.
  ///
  /// In en, this message translates to:
  /// **'Cooking Details'**
  String get cookingDetailsTitle;

  /// No description provided for @cookingSkillTitle.
  ///
  /// In en, this message translates to:
  /// **'Cooking Skill'**
  String get cookingSkillTitle;

  /// No description provided for @timeAvailabilityTitle.
  ///
  /// In en, this message translates to:
  /// **'Time Availability'**
  String get timeAvailabilityTitle;

  /// No description provided for @householdSizeTitle.
  ///
  /// In en, this message translates to:
  /// **'Household Size'**
  String get householdSizeTitle;

  /// No description provided for @dietVegetarian.
  ///
  /// In en, this message translates to:
  /// **'Vegetarian'**
  String get dietVegetarian;

  /// No description provided for @dietVegan.
  ///
  /// In en, this message translates to:
  /// **'Vegan'**
  String get dietVegan;

  /// No description provided for @dietPescatarian.
  ///
  /// In en, this message translates to:
  /// **'Pescatarian'**
  String get dietPescatarian;

  /// No description provided for @dietKeto.
  ///
  /// In en, this message translates to:
  /// **'Keto'**
  String get dietKeto;

  /// No description provided for @dietPaleo.
  ///
  /// In en, this message translates to:
  /// **'Paleo'**
  String get dietPaleo;

  /// No description provided for @dietMediterranean.
  ///
  /// In en, this message translates to:
  /// **'Mediterranean'**
  String get dietMediterranean;

  /// No description provided for @dietLowCarb.
  ///
  /// In en, this message translates to:
  /// **'Low Carb'**
  String get dietLowCarb;

  /// No description provided for @dietLowFat.
  ///
  /// In en, this message translates to:
  /// **'Low Fat'**
  String get dietLowFat;

  /// No description provided for @dietGlutenFree.
  ///
  /// In en, this message translates to:
  /// **'Gluten Free'**
  String get dietGlutenFree;

  /// No description provided for @dietDairyFree.
  ///
  /// In en, this message translates to:
  /// **'Dairy Free'**
  String get dietDairyFree;

  /// No description provided for @dietNutFree.
  ///
  /// In en, this message translates to:
  /// **'Nut Free'**
  String get dietNutFree;

  /// No description provided for @dietHalal.
  ///
  /// In en, this message translates to:
  /// **'Halal'**
  String get dietHalal;

  /// No description provided for @dietKosher.
  ///
  /// In en, this message translates to:
  /// **'Kosher'**
  String get dietKosher;

  /// No description provided for @allergyNuts.
  ///
  /// In en, this message translates to:
  /// **'Nuts'**
  String get allergyNuts;

  /// No description provided for @allergyDairy.
  ///
  /// In en, this message translates to:
  /// **'Dairy'**
  String get allergyDairy;

  /// No description provided for @allergyEggs.
  ///
  /// In en, this message translates to:
  /// **'Eggs'**
  String get allergyEggs;

  /// No description provided for @allergySoy.
  ///
  /// In en, this message translates to:
  /// **'Soy'**
  String get allergySoy;

  /// No description provided for @allergyWheat.
  ///
  /// In en, this message translates to:
  /// **'Wheat'**
  String get allergyWheat;

  /// No description provided for @allergyFish.
  ///
  /// In en, this message translates to:
  /// **'Fish'**
  String get allergyFish;

  /// No description provided for @allergyShellfish.
  ///
  /// In en, this message translates to:
  /// **'Shellfish'**
  String get allergyShellfish;

  /// No description provided for @allergySesame.
  ///
  /// In en, this message translates to:
  /// **'Sesame'**
  String get allergySesame;

  /// No description provided for @goalWeightLoss.
  ///
  /// In en, this message translates to:
  /// **'Weight Loss'**
  String get goalWeightLoss;

  /// No description provided for @goalWeightGain.
  ///
  /// In en, this message translates to:
  /// **'Weight Gain'**
  String get goalWeightGain;

  /// No description provided for @goalMuscleBuilding.
  ///
  /// In en, this message translates to:
  /// **'Muscle Building'**
  String get goalMuscleBuilding;

  /// No description provided for @goalHeartHealth.
  ///
  /// In en, this message translates to:
  /// **'Heart Health'**
  String get goalHeartHealth;

  /// No description provided for @goalDiabetesManagement.
  ///
  /// In en, this message translates to:
  /// **'Diabetes Management'**
  String get goalDiabetesManagement;

  /// No description provided for @goalHighProtein.
  ///
  /// In en, this message translates to:
  /// **'High Protein'**
  String get goalHighProtein;

  /// No description provided for @goalLowSodium.
  ///
  /// In en, this message translates to:
  /// **'Low Sodium'**
  String get goalLowSodium;

  /// No description provided for @goalAntiInflammatory.
  ///
  /// In en, this message translates to:
  /// **'Anti-Inflammatory'**
  String get goalAntiInflammatory;

  /// No description provided for @skillBeginner.
  ///
  /// In en, this message translates to:
  /// **'Beginner'**
  String get skillBeginner;

  /// No description provided for @skillIntermediate.
  ///
  /// In en, this message translates to:
  /// **'Intermediate'**
  String get skillIntermediate;

  /// No description provided for @skillAdvanced.
  ///
  /// In en, this message translates to:
  /// **'Advanced'**
  String get skillAdvanced;

  /// No description provided for @time15Min.
  ///
  /// In en, this message translates to:
  /// **'15 min'**
  String get time15Min;

  /// No description provided for @time30Min.
  ///
  /// In en, this message translates to:
  /// **'30 min'**
  String get time30Min;

  /// No description provided for @time1HourPlus.
  ///
  /// In en, this message translates to:
  /// **'1+ hour'**
  String get time1HourPlus;

  /// No description provided for @profileTitle.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profileTitle;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @profileGuestName.
  ///
  /// In en, this message translates to:
  /// **'Guest'**
  String get profileGuestName;

  /// No description provided for @profilePreferencesTitle.
  ///
  /// In en, this message translates to:
  /// **'Preferences'**
  String get profilePreferencesTitle;

  /// No description provided for @profileDietarySpecsLabel.
  ///
  /// In en, this message translates to:
  /// **'Dietary specifications'**
  String get profileDietarySpecsLabel;

  /// No description provided for @profileHideNutritionLabel.
  ///
  /// In en, this message translates to:
  /// **'Hide nutritional values'**
  String get profileHideNutritionLabel;

  /// No description provided for @profileSecurityTitle.
  ///
  /// In en, this message translates to:
  /// **'Security'**
  String get profileSecurityTitle;

  /// No description provided for @profileChangeEmailLabel.
  ///
  /// In en, this message translates to:
  /// **'Change email'**
  String get profileChangeEmailLabel;

  /// No description provided for @profileLanguageTitle.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get profileLanguageTitle;

  /// No description provided for @profileLanguageLabel.
  ///
  /// In en, this message translates to:
  /// **'App language'**
  String get profileLanguageLabel;

  /// No description provided for @profileLanguageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get profileLanguageEnglish;

  /// No description provided for @profileLanguageSpanish.
  ///
  /// In en, this message translates to:
  /// **'Spanish'**
  String get profileLanguageSpanish;

  /// No description provided for @profilePaymentsTitle.
  ///
  /// In en, this message translates to:
  /// **'Payments'**
  String get profilePaymentsTitle;

  /// No description provided for @profilePaymentsEmpty.
  ///
  /// In en, this message translates to:
  /// **'No payments to show yet.'**
  String get profilePaymentsEmpty;

  /// No description provided for @profileSubscriptionTitle.
  ///
  /// In en, this message translates to:
  /// **'Subscription'**
  String get profileSubscriptionTitle;

  /// No description provided for @profileSubscriptionCurrentLabel.
  ///
  /// In en, this message translates to:
  /// **'Current plan'**
  String get profileSubscriptionCurrentLabel;

  /// No description provided for @profileSubscriptionIncludesLabel.
  ///
  /// In en, this message translates to:
  /// **'Includes'**
  String get profileSubscriptionIncludesLabel;

  /// No description provided for @profileSubscriptionFree.
  ///
  /// In en, this message translates to:
  /// **'Free'**
  String get profileSubscriptionFree;

  /// No description provided for @profileNoIncludes.
  ///
  /// In en, this message translates to:
  /// **'No benefits listed yet.'**
  String get profileNoIncludes;

  /// No description provided for @profileSavePreferences.
  ///
  /// In en, this message translates to:
  /// **'Save preferences'**
  String get profileSavePreferences;

  /// No description provided for @mealPlanTitle.
  ///
  /// In en, this message translates to:
  /// **'Meal Plan'**
  String get mealPlanTitle;

  /// No description provided for @groceryTitle.
  ///
  /// In en, this message translates to:
  /// **'Grocery'**
  String get groceryTitle;

  /// No description provided for @nutritionTitle.
  ///
  /// In en, this message translates to:
  /// **'Nutrition'**
  String get nutritionTitle;

  /// Farewell message shown when deleting account.
  ///
  /// In en, this message translates to:
  /// **'We\'re sorry to see you go. We\'ll keep your kitchen and playlists for 30 days in case you decide to return. After that, we\'ll clear the table forever.'**
  String get profileFarewell;

  /// Prompt to confirm account deletion with email entry.
  ///
  /// In en, this message translates to:
  /// **'Are you sure? Type your email to confirm: {email}'**
  String confirmDeleteWithEmail(Object email);

  /// Placeholder for email input field.
  ///
  /// In en, this message translates to:
  /// **'email@example.com'**
  String get emailPlaceholder;

  /// No description provided for @deletePlanTooltip.
  ///
  /// In en, this message translates to:
  /// **'Delete plan'**
  String get deletePlanTooltip;

  /// No description provided for @deleteMealDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete this meal?'**
  String get deleteMealDialogTitle;

  /// No description provided for @deleteMealDialogMessage.
  ///
  /// In en, this message translates to:
  /// **'This recipe will be removed from the plan. This action cannot be undone.'**
  String get deleteMealDialogMessage;

  /// No description provided for @deleteAction.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get deleteAction;

  /// No description provided for @changeMealDateAction.
  ///
  /// In en, this message translates to:
  /// **'Change meal date'**
  String get changeMealDateAction;

  /// No description provided for @swapFavoriteAction.
  ///
  /// In en, this message translates to:
  /// **'Swap with favorite'**
  String get swapFavoriteAction;

  /// No description provided for @regenerateRecipeAction.
  ///
  /// In en, this message translates to:
  /// **'Regenerate recipe'**
  String get regenerateRecipeAction;

  /// No description provided for @genericMoveError.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t move the meal. Please try again.'**
  String get genericMoveError;

  /// No description provided for @genericDeleteError.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t delete. Please try again.'**
  String get genericDeleteError;

  /// No description provided for @genericRegenerateError.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t regenerate the recipe. Please try again.'**
  String get genericRegenerateError;

  /// No description provided for @dragDropHint.
  ///
  /// In en, this message translates to:
  /// **'Long press a recipe to drag it to another day or use the menu to change date.'**
  String get dragDropHint;

  /// No description provided for @dragDropTooltip.
  ///
  /// In en, this message translates to:
  /// **'Tip: you can move meals by dragging between days or from the “Change meal date” menu.'**
  String get dragDropTooltip;

  /// No description provided for @emptyDayDropText.
  ///
  /// In en, this message translates to:
  /// **'Drop a meal here'**
  String get emptyDayDropText;

  /// No description provided for @viewDetailsLabel.
  ///
  /// In en, this message translates to:
  /// **'View details'**
  String get viewDetailsLabel;

  /// No description provided for @hideDetailsLabel.
  ///
  /// In en, this message translates to:
  /// **'Hide details'**
  String get hideDetailsLabel;

  /// No description provided for @regenerateSheetSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Tell us what to change or leave it blank so AI can choose.'**
  String get regenerateSheetSubtitle;

  /// No description provided for @regenerateSheetNotesLabel.
  ///
  /// In en, this message translates to:
  /// **'Description (optional)'**
  String get regenerateSheetNotesLabel;

  /// No description provided for @regenerateSheetNotesHint.
  ///
  /// In en, this message translates to:
  /// **'E.g.: Something lighter, gluten-free...'**
  String get regenerateSheetNotesHint;

  /// No description provided for @regenerateSheetMaxPrepTimeLabel.
  ///
  /// In en, this message translates to:
  /// **'Maximum prep time'**
  String get regenerateSheetMaxPrepTimeLabel;

  /// No description provided for @regenerateSheetButton.
  ///
  /// In en, this message translates to:
  /// **'Regenerate'**
  String get regenerateSheetButton;

  /// No description provided for @deletePlanSheetTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete meal plan'**
  String get deletePlanSheetTitle;

  /// No description provided for @deletePlanSheetWarning.
  ///
  /// In en, this message translates to:
  /// **'Deleting this plan still counts toward your meal plan generation limit. This action cannot be undone.'**
  String get deletePlanSheetWarning;

  /// No description provided for @deletePlanSheetReasonLabel.
  ///
  /// In en, this message translates to:
  /// **'Why are you deleting the plan? (optional)'**
  String get deletePlanSheetReasonLabel;

  /// No description provided for @deletePlanSheetReasonHint.
  ///
  /// In en, this message translates to:
  /// **'E.g.: I didn\'t like the recipes...'**
  String get deletePlanSheetReasonHint;

  /// No description provided for @deletePlanSheetConfirmAction.
  ///
  /// In en, this message translates to:
  /// **'Yes, delete plan'**
  String get deletePlanSheetConfirmAction;

  /// No description provided for @minutesShortWithPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'{minutes} min'**
  String minutesShortWithPlaceholder(Object minutes);

  /// No description provided for @ingredientSubstitutesTitle.
  ///
  /// In en, this message translates to:
  /// **'Substitutes for {ingredient}'**
  String ingredientSubstitutesTitle(Object ingredient);

  /// No description provided for @ingredientSubstitutesTooltip.
  ///
  /// In en, this message translates to:
  /// **'Find substitutes'**
  String get ingredientSubstitutesTooltip;

  /// No description provided for @loadingSubstitutes.
  ///
  /// In en, this message translates to:
  /// **'Loading substitutes...'**
  String get loadingSubstitutes;

  /// No description provided for @noSubstitutesAvailable.
  ///
  /// In en, this message translates to:
  /// **'No substitutes available.'**
  String get noSubstitutesAvailable;

  /// No description provided for @substituteDetails.
  ///
  /// In en, this message translates to:
  /// **'Ratio: {ratio} | {reason} | {category}'**
  String substituteDetails(Object ratio, Object reason, Object category);

  /// No description provided for @substituteConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Confirm substitute'**
  String get substituteConfirmTitle;

  /// No description provided for @substituteConfirmMessage.
  ///
  /// In en, this message translates to:
  /// **'Changing an ingredient can significantly change the flavor.'**
  String get substituteConfirmMessage;

  /// No description provided for @substituteConfirmNutritionWarning.
  ///
  /// In en, this message translates to:
  /// **'This change can also affect the recipe\'s nutrition values.'**
  String get substituteConfirmNutritionWarning;

  /// No description provided for @applySubstituteAction.
  ///
  /// In en, this message translates to:
  /// **'Apply substitute'**
  String get applySubstituteAction;

  /// No description provided for @applyingSubstitute.
  ///
  /// In en, this message translates to:
  /// **'Applying substitute...'**
  String get applyingSubstitute;

  /// No description provided for @substituteMissingIngredientId.
  ///
  /// In en, this message translates to:
  /// **'Substitute cannot be applied for this ingredient.'**
  String get substituteMissingIngredientId;

  /// No description provided for @openCookingAssistant.
  ///
  /// In en, this message translates to:
  /// **'Open cooking assistant'**
  String get openCookingAssistant;

  /// No description provided for @cookingAssistantTitle.
  ///
  /// In en, this message translates to:
  /// **'Cooking assistant'**
  String get cookingAssistantTitle;

  /// No description provided for @cookingAssistantDisclaimer.
  ///
  /// In en, this message translates to:
  /// **'Times are estimates and can change.'**
  String get cookingAssistantDisclaimer;

  /// No description provided for @cookingAssistantStepLabel.
  ///
  /// In en, this message translates to:
  /// **'Step {step}'**
  String cookingAssistantStepLabel(Object step);

  /// No description provided for @cookingAssistantIngredientsTitle.
  ///
  /// In en, this message translates to:
  /// **'Ingredients in this step'**
  String get cookingAssistantIngredientsTitle;

  /// No description provided for @cookingAssistantToolsTitle.
  ///
  /// In en, this message translates to:
  /// **'Tools needed'**
  String get cookingAssistantToolsTitle;

  /// No description provided for @noCookingSteps.
  ///
  /// In en, this message translates to:
  /// **'No cooking steps available.'**
  String get noCookingSteps;

  /// No description provided for @noToolsNeeded.
  ///
  /// In en, this message translates to:
  /// **'No tools listed.'**
  String get noToolsNeeded;

  /// No description provided for @estimatedTimeLabel.
  ///
  /// In en, this message translates to:
  /// **'Estimated time: {time}'**
  String estimatedTimeLabel(Object time);

  /// No description provided for @startTimer.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get startTimer;

  /// No description provided for @pauseTimer.
  ///
  /// In en, this message translates to:
  /// **'Pause'**
  String get pauseTimer;

  /// No description provided for @resetTimer.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get resetTimer;

  /// No description provided for @noTimerAvailable.
  ///
  /// In en, this message translates to:
  /// **'No timer available for this step.'**
  String get noTimerAvailable;

  /// Label for cancel button.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// Shown when configuration fails to load.
  ///
  /// In en, this message translates to:
  /// **'Error loading configuration. Please try again.'**
  String get errorLoadingConfiguration;

  /// Shown when the email entered for confirmation does not match the user's email.
  ///
  /// In en, this message translates to:
  /// **'The email does not match your account.'**
  String get errorEmailConfirmationMismatch;

  /// No description provided for @saveIngredientsSheetTitle.
  ///
  /// In en, this message translates to:
  /// **'Save Ingredients'**
  String get saveIngredientsSheetTitle;

  /// No description provided for @saveIngredientsDialogContent.
  ///
  /// In en, this message translates to:
  /// **'Do you want to save the ingredients of this plan to a grocery list?'**
  String get saveIngredientsDialogContent;

  /// No description provided for @yesSaveAction.
  ///
  /// In en, this message translates to:
  /// **'Yes, Save'**
  String get yesSaveAction;

  /// No description provided for @notNowAction.
  ///
  /// In en, this message translates to:
  /// **'Not Now'**
  String get notNowAction;

  /// No description provided for @selectListTitle.
  ///
  /// In en, this message translates to:
  /// **'Select List'**
  String get selectListTitle;

  /// No description provided for @selectListSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Choose where to save your items'**
  String get selectListSubtitle;

  /// No description provided for @savedIngredientsSuccess.
  ///
  /// In en, this message translates to:
  /// **'Ingredients saved to {listName}'**
  String savedIngredientsSuccess(Object listName);

  /// No description provided for @savedIngredientsFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to save ingredients'**
  String get savedIngredientsFailed;

  /// No description provided for @deletePlanAlsoRemoveGrocery.
  ///
  /// In en, this message translates to:
  /// **'Also remove ingredients from grocery list'**
  String get deletePlanAlsoRemoveGrocery;

  /// No description provided for @planReusedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Plan \'{planName}\' reused with {count} entries'**
  String planReusedSuccess(Object planName, Object count);

  /// No description provided for @planReusedView.
  ///
  /// In en, this message translates to:
  /// **'View'**
  String get planReusedView;

  /// No description provided for @planReusedFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to reuse plan'**
  String get planReusedFailed;

  /// No description provided for @reusePlanSheetTitle.
  ///
  /// In en, this message translates to:
  /// **'Reuse Plan'**
  String get reusePlanSheetTitle;

  /// No description provided for @reusePlanStartDateLabel.
  ///
  /// In en, this message translates to:
  /// **'Start Date'**
  String get reusePlanStartDateLabel;

  /// No description provided for @reusePlanSelectDate.
  ///
  /// In en, this message translates to:
  /// **'Select Date'**
  String get reusePlanSelectDate;

  /// No description provided for @reusePlanNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Name (Optional)'**
  String get reusePlanNameLabel;

  /// No description provided for @reusePlanNameHint.
  ///
  /// In en, this message translates to:
  /// **'E.g., Next week\'s plan'**
  String get reusePlanNameHint;

  /// No description provided for @menuReusePlan.
  ///
  /// In en, this message translates to:
  /// **'Reuse plan'**
  String get menuReusePlan;

  /// No description provided for @menuSaveIngredients.
  ///
  /// In en, this message translates to:
  /// **'Save ingredients'**
  String get menuSaveIngredients;

  /// No description provided for @menuViewEntries.
  ///
  /// In en, this message translates to:
  /// **'View entries'**
  String get menuViewEntries;

  /// No description provided for @planActionsTitle.
  ///
  /// In en, this message translates to:
  /// **'Plan Actions'**
  String get planActionsTitle;

  /// No description provided for @datesUpdatedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Dates updated successfully'**
  String get datesUpdatedSuccess;

  /// No description provided for @noRecipeAssociated.
  ///
  /// In en, this message translates to:
  /// **'No recipe associated with this meal.'**
  String get noRecipeAssociated;

  /// No description provided for @addRecipeToListTitle.
  ///
  /// In en, this message translates to:
  /// **'Add Recipe to Grocery List'**
  String get addRecipeToListTitle;

  /// No description provided for @recipeAddedToList.
  ///
  /// In en, this message translates to:
  /// **'Recipe ingredients added to {listName}'**
  String recipeAddedToList(Object listName);

  /// No description provided for @recipeAddFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to add recipe to list.'**
  String get recipeAddFailed;

  /// No description provided for @markCompleteDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Mark as Complete'**
  String get markCompleteDialogTitle;

  /// No description provided for @markCompleteQuestion.
  ///
  /// In en, this message translates to:
  /// **'Did you complete {mealName}?'**
  String markCompleteQuestion(Object mealName);

  /// No description provided for @markCompleteDeductInfo.
  ///
  /// In en, this message translates to:
  /// **'Ingredients will be deducted from your pantry if available.'**
  String get markCompleteDeductInfo;

  /// No description provided for @completeAction.
  ///
  /// In en, this message translates to:
  /// **'Complete'**
  String get completeAction;

  /// No description provided for @mealCompletedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Meal completed! Deducted {count} ingredients from pantry.'**
  String mealCompletedSuccess(Object count);

  /// No description provided for @mealCompletedMissing.
  ///
  /// In en, this message translates to:
  /// **'Meal completed. {count} ingredients were missing from pantry.'**
  String mealCompletedMissing(Object count);

  /// No description provided for @mealCompletedError.
  ///
  /// In en, this message translates to:
  /// **'Failed to complete meal.'**
  String get mealCompletedError;

  /// No description provided for @alsoRemoveFromGrocery.
  ///
  /// In en, this message translates to:
  /// **'Also remove from grocery list'**
  String get alsoRemoveFromGrocery;

  /// No description provided for @menuAddToGrocery.
  ///
  /// In en, this message translates to:
  /// **'Add to grocery list'**
  String get menuAddToGrocery;

  /// No description provided for @mealCompletedLabel.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get mealCompletedLabel;

  /// No description provided for @usePantryTitle.
  ///
  /// In en, this message translates to:
  /// **'Use Pantry'**
  String get usePantryTitle;

  /// No description provided for @usePantrySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Deduct ingredients from pantry when generating.'**
  String get usePantrySubtitle;

  /// No description provided for @usePantryLabel.
  ///
  /// In en, this message translates to:
  /// **'Use Pantry Ingredients'**
  String get usePantryLabel;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @createNewListAction.
  ///
  /// In en, this message translates to:
  /// **'Create New List'**
  String get createNewListAction;

  /// No description provided for @addCustomName.
  ///
  /// In en, this message translates to:
  /// **'Custom Name'**
  String get addCustomName;

  /// No description provided for @existingListsLabel.
  ///
  /// In en, this message translates to:
  /// **'Existing Lists'**
  String get existingListsLabel;

  /// No description provided for @noExistingLists.
  ///
  /// In en, this message translates to:
  /// **'No existing lists found.'**
  String get noExistingLists;

  /// No description provided for @savedRecipesCount.
  ///
  /// In en, this message translates to:
  /// **'{count} saved recipes'**
  String savedRecipesCount(Object count);

  /// No description provided for @createListErrorCreate.
  ///
  /// In en, this message translates to:
  /// **'Failed to create grocery list.'**
  String get createListErrorCreate;

  /// No description provided for @createListBottomSheetTitle.
  ///
  /// In en, this message translates to:
  /// **'Create List'**
  String get createListBottomSheetTitle;

  /// No description provided for @createListBottomSheetSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Create a new grocery list.'**
  String get createListBottomSheetSubtitle;

  /// No description provided for @listNameLabel.
  ///
  /// In en, this message translates to:
  /// **'List Name'**
  String get listNameLabel;

  /// No description provided for @listNameHint.
  ///
  /// In en, this message translates to:
  /// **'E.g., Weekly Groceries'**
  String get listNameHint;

  /// No description provided for @listNameEmptyError.
  ///
  /// In en, this message translates to:
  /// **'List name cannot be empty.'**
  String get listNameEmptyError;

  /// No description provided for @create.
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get create;

  /// No description provided for @deletePlanSheetQuotaNote.
  ///
  /// In en, this message translates to:
  /// **'This action cannot be undone.'**
  String get deletePlanSheetQuotaNote;

  /// No description provided for @regenerateRecipePromptTitle.
  ///
  /// In en, this message translates to:
  /// **'Regenerate Recipe'**
  String get regenerateRecipePromptTitle;

  /// No description provided for @regenerateRecipePromptSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to regenerate this recipe?'**
  String get regenerateRecipePromptSubtitle;

  /// No description provided for @regenerateRecipeNotePrefix.
  ///
  /// In en, this message translates to:
  /// **'Note: '**
  String get regenerateRecipeNotePrefix;

  /// No description provided for @regenerateRecipeNoteText.
  ///
  /// In en, this message translates to:
  /// **'This will consume a generation quota.'**
  String get regenerateRecipeNoteText;

  /// No description provided for @regenerateNotesHint.
  ///
  /// In en, this message translates to:
  /// **'Any specific requests? (e.g., more protein)'**
  String get regenerateNotesHint;

  /// No description provided for @regenerateRecipeButtonTitle.
  ///
  /// In en, this message translates to:
  /// **'Regenerate'**
  String get regenerateRecipeButtonTitle;

  /// No description provided for @selectDatesTitle.
  ///
  /// In en, this message translates to:
  /// **'Select Dates'**
  String get selectDatesTitle;

  /// No description provided for @selectDatesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Choose the dates for your meal plan.'**
  String get selectDatesSubtitle;

  /// No description provided for @confirmSelectionAction.
  ///
  /// In en, this message translates to:
  /// **'Confirm Selection'**
  String get confirmSelectionAction;

  /// No description provided for @pantryOtherCategory.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get pantryOtherCategory;

  /// No description provided for @pantryAddTooltip.
  ///
  /// In en, this message translates to:
  /// **'Add to Pantry'**
  String get pantryAddTooltip;

  /// No description provided for @pantryEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'Your pantry is empty.'**
  String get pantryEmptyTitle;

  /// No description provided for @pantryEmptySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Add items to keep track of your ingredients.'**
  String get pantryEmptySubtitle;

  /// No description provided for @addItemQuantityInvalid.
  ///
  /// In en, this message translates to:
  /// **'Invalid quantity entered.'**
  String get addItemQuantityInvalid;

  /// No description provided for @pantryNoDate.
  ///
  /// In en, this message translates to:
  /// **'No expiration date'**
  String get pantryNoDate;

  /// No description provided for @pantryEditTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit {ingredientName}'**
  String pantryEditTitle(Object ingredientName);

  /// No description provided for @pantryQuantityLabel.
  ///
  /// In en, this message translates to:
  /// **'Quantity'**
  String get pantryQuantityLabel;

  /// No description provided for @pantryExpiryLabel.
  ///
  /// In en, this message translates to:
  /// **'Expiry Date'**
  String get pantryExpiryLabel;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @pantryItemExpired.
  ///
  /// In en, this message translates to:
  /// **'Expired'**
  String get pantryItemExpired;

  /// No description provided for @pantryStockLow.
  ///
  /// In en, this message translates to:
  /// **'Low stock'**
  String get pantryStockLow;

  /// No description provided for @pantryStockNormal.
  ///
  /// In en, this message translates to:
  /// **'Adequate stock'**
  String get pantryStockNormal;

  /// No description provided for @pantryDeleteDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Item'**
  String get pantryDeleteDialogTitle;

  /// No description provided for @pantryDeleteDialogMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete {ingredientName} from your pantry?'**
  String pantryDeleteDialogMessage(Object ingredientName);

  /// No description provided for @addItemDefaultUnit.
  ///
  /// In en, this message translates to:
  /// **'pieces'**
  String get addItemDefaultUnit;

  /// No description provided for @addItemErrorAdding.
  ///
  /// In en, this message translates to:
  /// **'Failed to add item.'**
  String get addItemErrorAdding;

  /// No description provided for @addItemTitlePantry.
  ///
  /// In en, this message translates to:
  /// **'Add to Pantry'**
  String get addItemTitlePantry;

  /// No description provided for @addItemTitleGrocery.
  ///
  /// In en, this message translates to:
  /// **'Add to Grocery List'**
  String get addItemTitleGrocery;

  /// No description provided for @addItemIngredientNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Item Name'**
  String get addItemIngredientNameLabel;

  /// No description provided for @addItemIngredientNamePantryHint.
  ///
  /// In en, this message translates to:
  /// **'E.g., Milk'**
  String get addItemIngredientNamePantryHint;

  /// No description provided for @addItemIngredientNameGroceryHint.
  ///
  /// In en, this message translates to:
  /// **'E.g., Bread'**
  String get addItemIngredientNameGroceryHint;

  /// No description provided for @addItemIngredientNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Item name is required.'**
  String get addItemIngredientNameRequired;

  /// No description provided for @addItemQuantityLabel.
  ///
  /// In en, this message translates to:
  /// **'Quantity'**
  String get addItemQuantityLabel;

  /// No description provided for @addItemQuantityRequired.
  ///
  /// In en, this message translates to:
  /// **'Quantity is required.'**
  String get addItemQuantityRequired;

  /// No description provided for @addItemUnitLabel.
  ///
  /// In en, this message translates to:
  /// **'Unit'**
  String get addItemUnitLabel;

  /// No description provided for @addItemUnitHint.
  ///
  /// In en, this message translates to:
  /// **'E.g., kg, liters'**
  String get addItemUnitHint;

  /// No description provided for @addItemCategoryLabel.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get addItemCategoryLabel;

  /// No description provided for @addItemCategoryHint.
  ///
  /// In en, this message translates to:
  /// **'Select a category'**
  String get addItemCategoryHint;

  /// No description provided for @addItemExpiryLabel.
  ///
  /// In en, this message translates to:
  /// **'Expiry Date'**
  String get addItemExpiryLabel;

  /// No description provided for @addItemButtonPantry.
  ///
  /// In en, this message translates to:
  /// **'Add to Pantry'**
  String get addItemButtonPantry;

  /// No description provided for @addItemButtonGrocery.
  ///
  /// In en, this message translates to:
  /// **'Add to Grocery List'**
  String get addItemButtonGrocery;

  /// No description provided for @pantryCountLabel.
  ///
  /// In en, this message translates to:
  /// **'{count} items in pantry'**
  String pantryCountLabel(Object count);

  /// No description provided for @groceryListDetailPendingHeader.
  ///
  /// In en, this message translates to:
  /// **'Pending Items'**
  String get groceryListDetailPendingHeader;

  /// No description provided for @groceryListDetailCompletedHeader.
  ///
  /// In en, this message translates to:
  /// **'Completed Items'**
  String get groceryListDetailCompletedHeader;

  /// No description provided for @groceryListDetailEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'This list is empty.'**
  String get groceryListDetailEmptyTitle;

  /// No description provided for @groceryListDetailEmptySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Add items using the + button.'**
  String get groceryListDetailEmptySubtitle;

  /// No description provided for @groceryItemInPantry.
  ///
  /// In en, this message translates to:
  /// **'In Pantry'**
  String get groceryItemInPantry;

  /// No description provided for @groceryItemEditTooltip.
  ///
  /// In en, this message translates to:
  /// **'Edit Item'**
  String get groceryItemEditTooltip;

  /// No description provided for @editQuantityDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit Quantity'**
  String get editQuantityDialogTitle;

  /// No description provided for @grocerySectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Grocery'**
  String get grocerySectionTitle;

  /// No description provided for @groceryListsTab.
  ///
  /// In en, this message translates to:
  /// **'Lists'**
  String get groceryListsTab;

  /// No description provided for @pantryTab.
  ///
  /// In en, this message translates to:
  /// **'Pantry'**
  String get pantryTab;

  /// No description provided for @groceryListsErrorLoading.
  ///
  /// In en, this message translates to:
  /// **'Failed to load lists.'**
  String get groceryListsErrorLoading;

  /// No description provided for @groceryListsEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No lists found.'**
  String get groceryListsEmptyTitle;

  /// No description provided for @groceryListsEmptySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Create your first grocery list.'**
  String get groceryListsEmptySubtitle;

  /// No description provided for @deleteGroceryListDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete List'**
  String get deleteGroceryListDialogTitle;

  /// No description provided for @deleteGroceryListDialogMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete {listName}?'**
  String deleteGroceryListDialogMessage(Object listName);

  /// No description provided for @profilePlanFreeBadge.
  ///
  /// In en, this message translates to:
  /// **'Free Plan'**
  String get profilePlanFreeBadge;

  /// No description provided for @homeWeekLabel.
  ///
  /// In en, this message translates to:
  /// **'This Week'**
  String get homeWeekLabel;

  /// No description provided for @greeting.
  ///
  /// In en, this message translates to:
  /// **'Hi, {name}!'**
  String greeting(Object name);

  /// No description provided for @homeTodayPlanReady.
  ///
  /// In en, this message translates to:
  /// **'Your plan for today is ready.'**
  String get homeTodayPlanReady;

  /// No description provided for @homeViewRecipeShort.
  ///
  /// In en, this message translates to:
  /// **'View'**
  String get homeViewRecipeShort;

  /// No description provided for @homeEatOutAction.
  ///
  /// In en, this message translates to:
  /// **'Eat Out'**
  String get homeEatOutAction;

  /// No description provided for @homeSkipMealQuestion.
  ///
  /// In en, this message translates to:
  /// **'Skip Meal?'**
  String get homeSkipMealQuestion;

  /// No description provided for @homeSkipMealDescription.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to skip this meal?'**
  String get homeSkipMealDescription;

  /// No description provided for @homeConfirmAction.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get homeConfirmAction;

  /// No description provided for @homeFavoritesAction.
  ///
  /// In en, this message translates to:
  /// **'Favorites'**
  String get homeFavoritesAction;

  /// No description provided for @homeProgressAction.
  ///
  /// In en, this message translates to:
  /// **'Progress'**
  String get homeProgressAction;

  /// No description provided for @homeEmptyPlanTitle.
  ///
  /// In en, this message translates to:
  /// **'No plans for today.'**
  String get homeEmptyPlanTitle;

  /// No description provided for @homeEmptyPlanMessage.
  ///
  /// In en, this message translates to:
  /// **'Create a new plan or enjoy your free day!'**
  String get homeEmptyPlanMessage;

  /// No description provided for @averageAbbr.
  ///
  /// In en, this message translates to:
  /// **'avg'**
  String get averageAbbr;

  /// No description provided for @selectGroceryListEmpty.
  ///
  /// In en, this message translates to:
  /// **'You have no grocery lists. Create a new one.'**
  String get selectGroceryListEmpty;

  /// No description provided for @selectGroceryListNewList.
  ///
  /// In en, this message translates to:
  /// **'Create New List'**
  String get selectGroceryListNewList;

  /// No description provided for @mealPlanHistory.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get mealPlanHistory;

  /// No description provided for @planEntriesTitle.
  ///
  /// In en, this message translates to:
  /// **'Plan Entries'**
  String get planEntriesTitle;

  /// No description provided for @noEntriesInPlan.
  ///
  /// In en, this message translates to:
  /// **'No entries found in this plan.'**
  String get noEntriesInPlan;

  /// No description provided for @myPlansTitle.
  ///
  /// In en, this message translates to:
  /// **'My Plans'**
  String get myPlansTitle;

  /// No description provided for @createNewPlanTooltip.
  ///
  /// In en, this message translates to:
  /// **'Create new plan'**
  String get createNewPlanTooltip;

  /// No description provided for @noPlansAddedTitle.
  ///
  /// In en, this message translates to:
  /// **'No plans yet.'**
  String get noPlansAddedTitle;

  /// No description provided for @noPlansAddedMessage.
  ///
  /// In en, this message translates to:
  /// **'Start your journey by generating a new meal plan.'**
  String get noPlansAddedMessage;

  /// No description provided for @tryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try Again'**
  String get tryAgain;

  /// No description provided for @days.
  ///
  /// In en, this message translates to:
  /// **'{count} days'**
  String days(Object count);

  /// No description provided for @approvePlanEndDate.
  ///
  /// In en, this message translates to:
  /// **'End date is unknown'**
  String get approvePlanEndDate;

  /// No description provided for @nutritionFilterDaily.
  ///
  /// In en, this message translates to:
  /// **'Daily'**
  String get nutritionFilterDaily;

  /// No description provided for @nutritionFilterWeekly.
  ///
  /// In en, this message translates to:
  /// **'Weekly'**
  String get nutritionFilterWeekly;

  /// No description provided for @nutritionFilterMonthly.
  ///
  /// In en, this message translates to:
  /// **'Monthly'**
  String get nutritionFilterMonthly;

  /// No description provided for @nutritionErrorLoading.
  ///
  /// In en, this message translates to:
  /// **'Failed to load nutrition data.'**
  String get nutritionErrorLoading;

  /// No description provided for @achievementsTitle.
  ///
  /// In en, this message translates to:
  /// **'Achievements'**
  String get achievementsTitle;

  /// No description provided for @weeklyActivityTitle.
  ///
  /// In en, this message translates to:
  /// **'Weekly Activity'**
  String get weeklyActivityTitle;

  /// No description provided for @mondayToSundayLabel.
  ///
  /// In en, this message translates to:
  /// **'MON - SUN'**
  String get mondayToSundayLabel;

  /// No description provided for @mealPlanActionViewDetails.
  ///
  /// In en, this message translates to:
  /// **'View Details'**
  String get mealPlanActionViewDetails;

  /// No description provided for @planDeletedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Plan obliterated.'**
  String get planDeletedSuccess;

  /// No description provided for @planBadgeAI.
  ///
  /// In en, this message translates to:
  /// **'GENERATED WITH AI'**
  String get planBadgeAI;

  /// No description provided for @planBadgeCustom.
  ///
  /// In en, this message translates to:
  /// **'CUSTOMIZED'**
  String get planBadgeCustom;

  /// No description provided for @cookingProgress.
  ///
  /// In en, this message translates to:
  /// **'RECIPE PROGRESS'**
  String get cookingProgress;

  /// No description provided for @stepOfTotal.
  ///
  /// In en, this message translates to:
  /// **'Step {current} of {total}'**
  String stepOfTotal(Object current, Object total);

  /// No description provided for @percentCompleted.
  ///
  /// In en, this message translates to:
  /// **'{percent}% completed'**
  String percentCompleted(Object percent);

  /// No description provided for @neededForThisStep.
  ///
  /// In en, this message translates to:
  /// **'Needed for this step'**
  String get neededForThisStep;

  /// No description provided for @mainIngredientSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Main ingredient'**
  String get mainIngredientSubtitle;

  /// No description provided for @neededToolSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Required tool'**
  String get neededToolSubtitle;

  /// No description provided for @nextStepAction.
  ///
  /// In en, this message translates to:
  /// **'Next step'**
  String get nextStepAction;

  /// No description provided for @finishRecipeAction.
  ///
  /// In en, this message translates to:
  /// **'Finish recipe'**
  String get finishRecipeAction;

  /// No description provided for @recipeCompletedSnack.
  ///
  /// In en, this message translates to:
  /// **'Recipe completed and deducted from pantry!'**
  String get recipeCompletedSnack;

  /// No description provided for @recipeCompletedMissingSnack.
  ///
  /// In en, this message translates to:
  /// **'Recipe completed. {count} ingredients were missing from pantry.'**
  String recipeCompletedMissingSnack(Object count);

  /// No description provided for @timerLabel.
  ///
  /// In en, this message translates to:
  /// **'TIMER'**
  String get timerLabel;

  /// No description provided for @checkYourInbox.
  ///
  /// In en, this message translates to:
  /// **'Check your inbox'**
  String get checkYourInbox;

  /// No description provided for @otpVerificationMessage.
  ///
  /// In en, this message translates to:
  /// **'We\'ve sent a 6-digit verification code to your new email address. Please enter it below to complete the change.'**
  String get otpVerificationMessage;

  /// No description provided for @otpRequestMessage.
  ///
  /// In en, this message translates to:
  /// **'Enter your new email address. We\'ll send a verification code to ensure it\'s you.'**
  String get otpRequestMessage;

  /// No description provided for @newEmailAddressLabel.
  ///
  /// In en, this message translates to:
  /// **'New Email Address'**
  String get newEmailAddressLabel;

  /// No description provided for @newEmailPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'name@example.com'**
  String get newEmailPlaceholder;

  /// No description provided for @didntReceiveCode.
  ///
  /// In en, this message translates to:
  /// **'Didn\'t receive the code?'**
  String get didntReceiveCode;

  /// No description provided for @resendAction.
  ///
  /// In en, this message translates to:
  /// **'Resend'**
  String get resendAction;

  /// No description provided for @secureVerificationNote.
  ///
  /// In en, this message translates to:
  /// **'Secure verification powered by SageAuth'**
  String get secureVerificationNote;

  /// No description provided for @saveSelectionAction.
  ///
  /// In en, this message translates to:
  /// **'Save selection'**
  String get saveSelectionAction;

  /// No description provided for @premiumLearnMore.
  ///
  /// In en, this message translates to:
  /// **'Learn more'**
  String get premiumLearnMore;

  /// No description provided for @swapFavoriteTitle.
  ///
  /// In en, this message translates to:
  /// **'Swap for Favorite'**
  String get swapFavoriteTitle;

  /// No description provided for @myFavoriteRecipes.
  ///
  /// In en, this message translates to:
  /// **'MY FAVORITE RECIPES'**
  String get myFavoriteRecipes;

  /// No description provided for @servingsShortLabel.
  ///
  /// In en, this message translates to:
  /// **'serv'**
  String get servingsShortLabel;

  /// No description provided for @peopleLabel.
  ///
  /// In en, this message translates to:
  /// **'People'**
  String get peopleLabel;

  /// No description provided for @likedFoodsLabel.
  ///
  /// In en, this message translates to:
  /// **'Liked Foods'**
  String get likedFoodsLabel;

  /// No description provided for @dislikedFoodsLabel.
  ///
  /// In en, this message translates to:
  /// **'Disliked Foods'**
  String get dislikedFoodsLabel;

  /// No description provided for @addLabel.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get addLabel;

  /// No description provided for @kcalLabel.
  ///
  /// In en, this message translates to:
  /// **'Kcal'**
  String get kcalLabel;

  /// No description provided for @metricCarbsShort.
  ///
  /// In en, this message translates to:
  /// **'Carbs'**
  String get metricCarbsShort;

  /// No description provided for @timeLabelUpper.
  ///
  /// In en, this message translates to:
  /// **'TIME'**
  String get timeLabelUpper;

  /// No description provided for @servingsLabelUpper.
  ///
  /// In en, this message translates to:
  /// **'SERVINGS'**
  String get servingsLabelUpper;

  /// No description provided for @caloriesLabelUpper.
  ///
  /// In en, this message translates to:
  /// **'CALORIES'**
  String get caloriesLabelUpper;

  /// No description provided for @nutritionPerServing.
  ///
  /// In en, this message translates to:
  /// **'Nutrition per serving'**
  String get nutritionPerServing;

  /// No description provided for @itemsCount.
  ///
  /// In en, this message translates to:
  /// **'{count} items'**
  String itemsCount(Object count);

  /// No description provided for @servingShort.
  ///
  /// In en, this message translates to:
  /// **'serving'**
  String get servingShort;

  /// No description provided for @organizeFavoritesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Organize your favorite recipes and ingredients'**
  String get organizeFavoritesSubtitle;

  /// No description provided for @medicalDisclaimer.
  ///
  /// In en, this message translates to:
  /// **'This app is not professional medical advice. AI may make errors in recipes, and the user is responsible for verifying ingredients against their allergies.'**
  String get medicalDisclaimer;

  /// No description provided for @authWelcomeTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome to your new nutrition'**
  String get authWelcomeTitle;

  /// No description provided for @authWelcomeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Personalized nutrition and simple meal planning for a healthy lifestyle.'**
  String get authWelcomeSubtitle;

  /// No description provided for @authLegalConsent.
  ///
  /// In en, this message translates to:
  /// **'By continuing, you accept our Terms of Service and Privacy Policy.'**
  String get authLegalConsent;

  /// No description provided for @authSignUpSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Enter your details to start your personalized nutritional plan'**
  String get authSignUpSubtitle;

  /// No description provided for @authLoginSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Your path to better nutrition starts here'**
  String get authLoginSubtitle;

  /// No description provided for @authLoginDivider.
  ///
  /// In en, this message translates to:
  /// **'OR USE YOUR EMAIL'**
  String get authLoginDivider;

  /// No description provided for @authVerifyAccountTitle.
  ///
  /// In en, this message translates to:
  /// **'Verify your account'**
  String get authVerifyAccountTitle;

  /// No description provided for @authWelcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome'**
  String get authWelcome;

  /// No description provided for @authWelcomeBackTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome back'**
  String get authWelcomeBackTitle;

  /// No description provided for @authResendCode.
  ///
  /// In en, this message translates to:
  /// **'Send again'**
  String get authResendCode;

  /// No description provided for @otpVerifyNotReceived.
  ///
  /// In en, this message translates to:
  /// **'Didn\'t receive the code?'**
  String get otpVerifyNotReceived;

  /// No description provided for @dietarySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Select your primary dietary style to help us tailor your recipes.'**
  String get dietarySubtitle;

  /// No description provided for @allergiesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Let us know about any allergies or intolerances we should avoid.'**
  String get allergiesSubtitle;

  /// No description provided for @foodPreferencesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Tell us about your palette so we can personalize your culinary journey.'**
  String get foodPreferencesSubtitle;

  /// No description provided for @goalsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Select your main nutritional goals to optimize your meal plan.'**
  String get goalsSubtitle;

  /// No description provided for @cookingDetailsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Tell us about your cooking style and household size.'**
  String get cookingDetailsSubtitle;

  /// No description provided for @namePlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Your full name'**
  String get namePlaceholder;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'es'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
