// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Meal Plan App';

  @override
  String get genericError => 'Something went wrong. Please try again.';

  @override
  String get errorFieldRequired => 'This field is required.';

  @override
  String get errorEmailInvalid => 'Enter a valid email address.';

  @override
  String get errorPasswordMinLength => 'Minimum 6 characters.';

  @override
  String get errorPasswordFormat =>
      'Must include an uppercase letter, lowercase letter, and a number.';

  @override
  String get errorAuthInvalidCredentials =>
      'Invalid credentials. Please check your email and password.';

  @override
  String get errorAuthEmailNotVerified =>
      'Your email has not been verified. Please check your inbox.';

  @override
  String get errorAuthUserNotFound => 'User not found.';

  @override
  String get errorAuthEmailInUse => 'This email is already registered.';

  @override
  String get errorAuthPasswordResetFailed =>
      'Could not reset password. Please try again later.';

  @override
  String get errorAuthResendVerificationFailed =>
      'Could not resend verification email.';

  @override
  String get errorAuthInvalidOtp =>
      'The code you entered is invalid or has expired.';

  @override
  String get errorAuthUnexpected =>
      'An unexpected authentication error occurred.';

  @override
  String get errorAuthGoogleSignInFailed =>
      'An unexpected error occurred during Google Sign-In.';

  @override
  String get errorAuthSendOtpFailed => 'Failed to send OTP. Please try again.';

  @override
  String get errorNetworkTimeout =>
      'The request timed out. Please check your internet connection.';

  @override
  String get errorNetworkNoConnection =>
      'No internet connection. Please connect and try again.';

  @override
  String get errorNetworkServer => 'Server error. Please try again later.';

  @override
  String get errorNetworkBadResponse => 'Unexpected response from the server.';

  @override
  String get errorNetworkUnreachableHost =>
      'Cannot reach the server. Check the host, port, or VPN.';

  @override
  String get errorNetworkSsl => 'Secure connection failed (SSL/TLS).';

  @override
  String get errorNetworkRateLimit =>
      'Too many requests. Please wait and try again.';

  @override
  String get errorNetworkBadRequest => 'Request rejected by server.';

  @override
  String get errorDataNotFound => 'Requested data was not found.';

  @override
  String get errorDataInvalid => 'Invalid data.';

  @override
  String get errorDataCreationFailed => 'Failed to create data.';

  @override
  String get errorDataUpdateFailed => 'Failed to update data.';

  @override
  String get errorDataFetchFailed => 'Failed to fetch data.';

  @override
  String get errorDataSerializationFailed => 'Failed to parse data.';

  @override
  String get errorDataEmptyResponse => 'The response was empty.';

  @override
  String get errorPermissionUnauthorized =>
      'Unauthorized. Please sign in again.';

  @override
  String get errorPermissionForbidden =>
      'You do not have permission to perform this action.';

  @override
  String get errorConfigMissing => 'Configuration is missing.';

  @override
  String get errorConfigInvalid => 'Configuration is invalid.';

  @override
  String get errorMealPlanNotAuthenticated => 'Please sign in to continue.';

  @override
  String get errorMealPlanDaysNotAllowed =>
      'The selected number of days is not allowed.';

  @override
  String get errorMealPlanTypesNotAllowed =>
      'Some selected meal types are not allowed.';

  @override
  String get errorMealPlanGenerateFailed =>
      'Could not generate the plan. Please try again.';

  @override
  String get errorMealPlanQuotaReached =>
      'You have run out of plan generations this week.';

  @override
  String get approvePlanTitle => 'Approve plan';

  @override
  String get noPlanDataReceived => 'No plan data received.';

  @override
  String get done => 'Done';

  @override
  String get graceWelcomeTitle => 'We missed you! Welcome back.';

  @override
  String get graceWelcomeMessage =>
      'All your information is saved and ready to continue.';

  @override
  String get continueLabel => 'Continue';

  @override
  String mealsCount(Object count) {
    return '$count meals';
  }

  @override
  String caloriesKcal(Object calories) {
    return '$calories kcal';
  }

  @override
  String servingsLabel(Object count) {
    return 'Servings: $count';
  }

  @override
  String prepMinutesLabel(Object minutes) {
    return 'Prep: $minutes min';
  }

  @override
  String cookMinutesLabel(Object minutes) {
    return 'Cook: $minutes min';
  }

  @override
  String proteinLabel(Object grams) {
    return 'Protein: $grams g';
  }

  @override
  String carbsLabel(Object grams) {
    return 'Carbs: $grams g';
  }

  @override
  String fatsLabel(Object grams) {
    return 'Fats: $grams g';
  }

  @override
  String get preparingPlanTitle => 'Preparing your plan';

  @override
  String get loadingMessageCookbook => 'Checking grandma\'s cookbook...';

  @override
  String get loadingMessageRecipes => 'Dusting off the old recipes...';

  @override
  String get loadingMessageAunts => 'Asking the aunts for their secrets...';

  @override
  String get loadingMessageFridge => 'Peeking into the fridge...';

  @override
  String get loadingMessageKnives => 'Sharpening imaginary knives...';

  @override
  String get loadingMessageTablespoons => 'Measuring tablespoons by eye...';

  @override
  String get cookingCombosMessage =>
      'Cooking up tasty, healthy combos for you...';

  @override
  String get cancelAndGoBack => 'Cancel and go back';

  @override
  String get planLimitReachedTitle => 'Plan limit reached';

  @override
  String get planLimitReachedMessage =>
      'You have run out of plan generations this week.';

  @override
  String get newPlanTitle => 'New Plan';

  @override
  String get clear => 'Clear';

  @override
  String get configurePlanTitle => 'Configure your plan';

  @override
  String get configurePlanSubtitle => 'Define duration, people and base meals.';

  @override
  String get durationTitle => 'Duration';

  @override
  String daysLabel(Object days) {
    return '$days days';
  }

  @override
  String get dinersTitle => 'Diners';

  @override
  String peopleCount(Object count) {
    return '$count people';
  }

  @override
  String get mealTypesTitle => 'Meal types';

  @override
  String get mealTypeBreakfast => 'Breakfast';

  @override
  String get mealTypeLunch => 'Lunch';

  @override
  String get mealTypeSnack => 'Snack';

  @override
  String get mealTypeDinner => 'Dinner';

  @override
  String get mealTypeBreakfastSubtitle => 'Energy for the day';

  @override
  String get mealTypeLunchSubtitle => 'Main meal';

  @override
  String get mealTypeSnackSubtitle => 'Something light';

  @override
  String get mealTypeDinnerSubtitle => 'Light and nutritious';

  @override
  String get notesOptionalTitle => 'Notes (optional)';

  @override
  String get notesHint => 'E.g.: Lactose-free, more proteins...';

  @override
  String get mealsOfDayTitle => 'Meals of the day';

  @override
  String get skipMealAction => 'Skip meal';

  @override
  String get unskipMealAction => 'Unskip meal';

  @override
  String get mealSkippedLabel => 'Skipped';

  @override
  String get skipMealDialogTitle => 'Meal skipped';

  @override
  String get skipMealDialogMessage =>
      'It\'s okay to skip a meal sometimes. You can continue with your plan whenever you\'re ready.';

  @override
  String get viewRecipeDetails => 'View recipe';

  @override
  String get categoriesTitle => 'Categories';

  @override
  String get metricCalories => 'Cal';

  @override
  String get metricServings => 'Servings';

  @override
  String get metricFat => 'Fat';

  @override
  String get metricCarbs => 'Carbs';

  @override
  String get metricProtein => 'Protein';

  @override
  String get metricKcal => 'Kcal';

  @override
  String get descriptionTitle => 'Description';

  @override
  String get instructionsTitle => 'Instructions';

  @override
  String get ingredientsTitle => 'Ingredients';

  @override
  String get noInstructions => 'No instructions.';

  @override
  String get noIngredients => 'No ingredients.';

  @override
  String get retry => 'Retry';

  @override
  String get noMealsLoggedToday => 'No meals logged for today.';

  @override
  String get weekdayMonShort => 'Mon';

  @override
  String get weekdayTueShort => 'Tue';

  @override
  String get weekdayWedShort => 'Wed';

  @override
  String get weekdayThuShort => 'Thu';

  @override
  String get weekdayFriShort => 'Fri';

  @override
  String get weekdaySatShort => 'Sat';

  @override
  String get weekdaySunShort => 'Sun';

  @override
  String get homeTitle => 'Home';

  @override
  String get generateNewPlan => 'Generate New Plan';

  @override
  String get logout => 'Logout';

  @override
  String get deleteAccount => 'Delete account';

  @override
  String get profileNotificationsTitle => 'Notifications';

  @override
  String get profileTermsTitle => 'Terms and Conditions';

  @override
  String unableToLoadPlanStatus(Object error) {
    return 'Unable to load plan status: $error';
  }

  @override
  String plansLeftThisWeek(Object remaining, Object total) {
    return '$remaining of $total plans left this week';
  }

  @override
  String get goPremiumUnlockMorePlans =>
      'Go premium to unlock more meal plans.';

  @override
  String get goPremiumTitle => 'Go Premium';

  @override
  String get freePlanLimitedGenerations =>
      'Your free plan has limited meal plan generations.';

  @override
  String get goPremiumKeepGenerating =>
      'Go premium to keep generating meal plans.';

  @override
  String get goToHome => 'Go to Home';

  @override
  String get recipesTitle => 'Recipes';

  @override
  String get favoriteRecipesTitle => 'Favorite Recipes';

  @override
  String get favoriteUpdateFailed =>
      'Failed to update favorite. Please try again.';

  @override
  String get favoritesTooltip => 'Favorites';

  @override
  String get noRecipesAvailable => 'No recipes available';

  @override
  String get noFavoriteRecipes => 'You don\'t have favorite recipes';

  @override
  String get recipeDetailTitle => 'Recipe Detail';

  @override
  String get errorTitle => 'Error';

  @override
  String errorOccurred(Object error) {
    return 'An error occurred: $error';
  }

  @override
  String get login => 'Login';

  @override
  String get register => 'Register';

  @override
  String get signUp => 'Sign Up';

  @override
  String get email => 'Email';

  @override
  String get name => 'Name';

  @override
  String get sendOtp => 'Send OTP';

  @override
  String get sendVerificationCodeOtp => 'Send Verification Code OTP';

  @override
  String get signInWithGoogle => 'Sign in with Google';

  @override
  String get dontHaveAccount => 'Don\'t have an account?';

  @override
  String get doYouHaveAccount => 'Do you have an account?';

  @override
  String get verificationCodeSentEmail =>
      'A verification code has been sent to your email.';

  @override
  String get otpEnterTitle => 'Enter Verification Code';

  @override
  String get otpEnterSubtitle => 'Enter the 6-digit code sent to:';

  @override
  String get otpVerificationCodeLabel => 'Verification Code';

  @override
  String get otpResend => 'Didn\'t receive a code? Send again';

  @override
  String get otpVerifySignIn => 'Verify & Sign In';

  @override
  String get otpSentSnack => 'Verification code sent!';

  @override
  String get preferencesSaved => 'Preferences saved successfully';

  @override
  String get errorSavePreferencesRollbackFailed =>
      'Failed to save preferences and rollback also failed. The app may be in an inconsistent state.';

  @override
  String get unknownError => 'An unknown error occurred';

  @override
  String get wizardPrevious => 'Previous';

  @override
  String get wizardNext => 'Next';

  @override
  String get wizardFinish => 'Finish';

  @override
  String stepOf(Object current, Object total) {
    return 'Step $current of $total';
  }

  @override
  String get dietaryTitle => 'Dietary Preferences & Restrictions';

  @override
  String get allergiesTitle => 'Allergies';

  @override
  String get allergiesOtherTitle => 'Other allergies';

  @override
  String get allergiesOtherHint => 'Please specify any other allergies...';

  @override
  String get foodPreferencesTitle => 'Food Preferences';

  @override
  String get dislikedFoodsTitle => 'Disliked Foods';

  @override
  String get dislikedFoodsHint => 'List foods you dislike or want to avoid...';

  @override
  String get likedFoodsTitle => 'Liked Foods';

  @override
  String get likedFoodsHint => 'List your favorite foods and ingredients...';

  @override
  String get goalsTitle => 'Dietary Choices & Goals';

  @override
  String get cookingDetailsTitle => 'Cooking Details';

  @override
  String get cookingSkillTitle => 'Cooking Skill';

  @override
  String get timeAvailabilityTitle => 'Time Availability';

  @override
  String get householdSizeTitle => 'Household Size';

  @override
  String get dietVegetarian => 'Vegetarian';

  @override
  String get dietVegan => 'Vegan';

  @override
  String get dietPescatarian => 'Pescatarian';

  @override
  String get dietKeto => 'Keto';

  @override
  String get dietPaleo => 'Paleo';

  @override
  String get dietMediterranean => 'Mediterranean';

  @override
  String get dietLowCarb => 'Low Carb';

  @override
  String get dietLowFat => 'Low Fat';

  @override
  String get dietGlutenFree => 'Gluten Free';

  @override
  String get dietDairyFree => 'Dairy Free';

  @override
  String get dietNutFree => 'Nut Free';

  @override
  String get dietHalal => 'Halal';

  @override
  String get dietKosher => 'Kosher';

  @override
  String get allergyNuts => 'Nuts';

  @override
  String get allergyDairy => 'Dairy';

  @override
  String get allergyEggs => 'Eggs';

  @override
  String get allergySoy => 'Soy';

  @override
  String get allergyWheat => 'Wheat';

  @override
  String get allergyFish => 'Fish';

  @override
  String get allergyShellfish => 'Shellfish';

  @override
  String get allergySesame => 'Sesame';

  @override
  String get goalWeightLoss => 'Weight Loss';

  @override
  String get goalWeightGain => 'Weight Gain';

  @override
  String get goalMuscleBuilding => 'Muscle Building';

  @override
  String get goalHeartHealth => 'Heart Health';

  @override
  String get goalDiabetesManagement => 'Diabetes Management';

  @override
  String get goalHighProtein => 'High Protein';

  @override
  String get goalLowSodium => 'Low Sodium';

  @override
  String get goalAntiInflammatory => 'Anti-Inflammatory';

  @override
  String get skillBeginner => 'Beginner';

  @override
  String get skillIntermediate => 'Intermediate';

  @override
  String get skillAdvanced => 'Advanced';

  @override
  String get time15Min => '15 min';

  @override
  String get time30Min => '30 min';

  @override
  String get time1HourPlus => '1+ hour';

  @override
  String get profileTitle => 'Profile';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get profileGuestName => 'Guest';

  @override
  String get profilePreferencesTitle => 'Preferences';

  @override
  String get profileDietarySpecsLabel => 'Dietary specifications';

  @override
  String get profileHideNutritionLabel => 'Hide nutritional values';

  @override
  String get profileSecurityTitle => 'Security';

  @override
  String get profileChangeEmailLabel => 'Change email';

  @override
  String get profileLanguageTitle => 'Language';

  @override
  String get profileLanguageLabel => 'App language';

  @override
  String get profileLanguageEnglish => 'English';

  @override
  String get profileLanguageSpanish => 'Spanish';

  @override
  String get profilePaymentsTitle => 'Payments';

  @override
  String get profilePaymentsEmpty => 'No payments to show yet.';

  @override
  String get profileSubscriptionTitle => 'Subscription';

  @override
  String get profileSubscriptionCurrentLabel => 'Current plan';

  @override
  String get profileSubscriptionIncludesLabel => 'Includes';

  @override
  String get profileSubscriptionFree => 'Free';

  @override
  String get profileNoIncludes => 'No benefits listed yet.';

  @override
  String get profileSavePreferences => 'Save preferences';

  @override
  String get mealPlanTitle => 'Meal Plan';

  @override
  String get groceryTitle => 'Grocery';

  @override
  String get nutritionTitle => 'Nutrition';

  @override
  String get profileFarewell =>
      'We\'re sorry to see you go. We\'ll keep your kitchen and playlists for 30 days in case you decide to return. After that, we\'ll clear the table forever.';

  @override
  String confirmDeleteWithEmail(Object email) {
    return 'Are you sure? Type your email to confirm: $email';
  }

  @override
  String get emailPlaceholder => 'email@example.com';

  @override
  String get deletePlanTooltip => 'Delete plan';

  @override
  String get deleteMealDialogTitle => 'Delete this meal?';

  @override
  String get deleteMealDialogMessage =>
      'This recipe will be removed from the plan. This action cannot be undone.';

  @override
  String get deleteAction => 'Delete';

  @override
  String get changeMealDateAction => 'Change meal date';

  @override
  String get swapFavoriteAction => 'Swap with favorite';

  @override
  String get regenerateRecipeAction => 'Regenerate recipe';

  @override
  String get genericMoveError => 'Couldn\'t move the meal. Please try again.';

  @override
  String get genericDeleteError => 'Couldn\'t delete. Please try again.';

  @override
  String get genericRegenerateError =>
      'Couldn\'t regenerate the recipe. Please try again.';

  @override
  String get dragDropHint =>
      'Long press a recipe to drag it to another day or use the menu to change date.';

  @override
  String get dragDropTooltip =>
      'Tip: you can move meals by dragging between days or from the “Change meal date” menu.';

  @override
  String get emptyDayDropText => 'Drop a meal here';

  @override
  String get viewDetailsLabel => 'View details';

  @override
  String get hideDetailsLabel => 'Hide details';

  @override
  String get regenerateSheetSubtitle =>
      'Tell us what to change or leave it blank so AI can choose.';

  @override
  String get regenerateSheetNotesLabel => 'Description (optional)';

  @override
  String get regenerateSheetNotesHint =>
      'E.g.: Something lighter, gluten-free...';

  @override
  String get regenerateSheetMaxPrepTimeLabel => 'Maximum prep time';

  @override
  String get regenerateSheetButton => 'Regenerate';

  @override
  String get deletePlanSheetTitle => 'Delete meal plan';

  @override
  String get deletePlanSheetWarning =>
      'Deleting this plan still counts toward your meal plan generation limit. This action cannot be undone.';

  @override
  String get deletePlanSheetReasonLabel =>
      'Why are you deleting the plan? (optional)';

  @override
  String get deletePlanSheetReasonHint => 'E.g.: I didn\'t like the recipes...';

  @override
  String get deletePlanSheetConfirmAction => 'Yes, delete plan';

  @override
  String minutesShortWithPlaceholder(Object minutes) {
    return '$minutes min';
  }

  @override
  String ingredientSubstitutesTitle(Object ingredient) {
    return 'Substitutes for $ingredient';
  }

  @override
  String get ingredientSubstitutesTooltip => 'Find substitutes';

  @override
  String get loadingSubstitutes => 'Loading substitutes...';

  @override
  String get noSubstitutesAvailable => 'No substitutes available.';

  @override
  String substituteDetails(Object ratio, Object reason, Object category) {
    return 'Ratio: $ratio | $reason | $category';
  }

  @override
  String get substituteConfirmTitle => 'Confirm substitute';

  @override
  String get substituteConfirmMessage =>
      'Changing an ingredient can significantly change the flavor.';

  @override
  String get substituteConfirmNutritionWarning =>
      'This change can also affect the recipe\'s nutrition values.';

  @override
  String get applySubstituteAction => 'Apply substitute';

  @override
  String get applyingSubstitute => 'Applying substitute...';

  @override
  String get substituteMissingIngredientId =>
      'Substitute cannot be applied for this ingredient.';

  @override
  String get openCookingAssistant => 'Open cooking assistant';

  @override
  String get cookingAssistantTitle => 'Cooking assistant';

  @override
  String get cookingAssistantDisclaimer =>
      'Times are estimates and can change.';

  @override
  String cookingAssistantStepLabel(Object step) {
    return 'Step $step';
  }

  @override
  String get cookingAssistantIngredientsTitle => 'Ingredients in this step';

  @override
  String get cookingAssistantToolsTitle => 'Tools needed';

  @override
  String get noCookingSteps => 'No cooking steps available.';

  @override
  String get noToolsNeeded => 'No tools listed.';

  @override
  String estimatedTimeLabel(Object time) {
    return 'Estimated time: $time';
  }

  @override
  String get startTimer => 'Start';

  @override
  String get pauseTimer => 'Pause';

  @override
  String get resetTimer => 'Reset';

  @override
  String get noTimerAvailable => 'No timer available for this step.';

  @override
  String get cancel => 'Cancel';

  @override
  String get errorLoadingConfiguration =>
      'Error loading configuration. Please try again.';

  @override
  String get errorEmailConfirmationMismatch =>
      'The email does not match your account.';
}
