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

  /// No description provided for @appTitle.
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

  /// No description provided for @continueLabel.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueLabel;

  /// No description provided for @mealsOfDayTitle.
  ///
  /// In en, this message translates to:
  /// **'Meals of the day'**
  String get mealsOfDayTitle;

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

  /// No description provided for @profileLicensesTitle.
  ///
  /// In en, this message translates to:
  /// **'Licenses'**
  String get profileLicensesTitle;

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
  /// **'List foods you dislike or want to avoid...'**
  String get dislikedFoodsHint;

  /// No description provided for @likedFoodsTitle.
  ///
  /// In en, this message translates to:
  /// **'Liked Foods'**
  String get likedFoodsTitle;

  /// No description provided for @likedFoodsHint.
  ///
  /// In en, this message translates to:
  /// **'List your favorite foods and ingredients...'**
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

  /// No description provided for @recipesTitle.
  ///
  /// In en, this message translates to:
  /// **'Recipes'**
  String get recipesTitle;

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
