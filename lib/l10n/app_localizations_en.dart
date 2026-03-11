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
  String get dislikedFoodsHint => 'Olives, cilantro, mushrooms...';

  @override
  String get likedFoodsTitle => 'Liked Foods';

  @override
  String get likedFoodsHint => 'Avocado, grilled salmon, kale chips...';

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

  @override
  String get saveIngredientsSheetTitle => 'Save Ingredients';

  @override
  String get saveIngredientsDialogContent =>
      'Do you want to save the ingredients of this plan to a grocery list?';

  @override
  String get yesSaveAction => 'Yes, Save';

  @override
  String get notNowAction => 'Not Now';

  @override
  String get selectListTitle => 'Select List';

  @override
  String get selectListSubtitle => 'Choose where to save your items';

  @override
  String savedIngredientsSuccess(Object listName) {
    return 'Ingredients saved to $listName';
  }

  @override
  String get savedIngredientsFailed => 'Failed to save ingredients';

  @override
  String get deletePlanAlsoRemoveGrocery =>
      'Also remove ingredients from grocery list';

  @override
  String planReusedSuccess(Object planName, Object count) {
    return 'Plan \'$planName\' reused with $count entries';
  }

  @override
  String get planReusedView => 'View';

  @override
  String get planReusedFailed => 'Failed to reuse plan';

  @override
  String get reusePlanSheetTitle => 'Reuse Plan';

  @override
  String get reusePlanStartDateLabel => 'Start Date';

  @override
  String get reusePlanSelectDate => 'Select Date';

  @override
  String get reusePlanNameLabel => 'Name (Optional)';

  @override
  String get reusePlanNameHint => 'E.g., Next week\'s plan';

  @override
  String get menuReusePlan => 'Reuse plan';

  @override
  String get menuSaveIngredients => 'Save ingredients';

  @override
  String get menuViewEntries => 'View entries';

  @override
  String get planActionsTitle => 'Plan Actions';

  @override
  String get datesUpdatedSuccess => 'Dates updated successfully';

  @override
  String get noRecipeAssociated => 'No recipe associated with this meal.';

  @override
  String get addRecipeToListTitle => 'Add Recipe to Grocery List';

  @override
  String recipeAddedToList(Object listName) {
    return 'Recipe ingredients added to $listName';
  }

  @override
  String get recipeAddFailed => 'Failed to add recipe to list.';

  @override
  String get markCompleteDialogTitle => 'Mark as Complete';

  @override
  String markCompleteQuestion(Object mealName) {
    return 'Did you complete $mealName?';
  }

  @override
  String get markCompleteDeductInfo =>
      'Ingredients will be deducted from your pantry if available.';

  @override
  String get completeAction => 'Complete';

  @override
  String mealCompletedSuccess(Object count) {
    return 'Meal completed! Deducted $count ingredients from pantry.';
  }

  @override
  String mealCompletedMissing(Object count) {
    return 'Meal completed. $count ingredients were missing from pantry.';
  }

  @override
  String get mealCompletedError => 'Failed to complete meal.';

  @override
  String get alsoRemoveFromGrocery => 'Also remove from grocery list';

  @override
  String get menuAddToGrocery => 'Add to grocery list';

  @override
  String get mealCompletedLabel => 'Completed';

  @override
  String get usePantryTitle => 'Use Pantry';

  @override
  String get usePantrySubtitle =>
      'Deduct ingredients from pantry when generating.';

  @override
  String get usePantryLabel => 'Use Pantry Ingredients';

  @override
  String get edit => 'Edit';

  @override
  String get createNewListAction => 'Create New List';

  @override
  String get addCustomName => 'Custom Name';

  @override
  String get existingListsLabel => 'Existing Lists';

  @override
  String get noExistingLists => 'No existing lists found.';

  @override
  String savedRecipesCount(Object count) {
    return '$count saved recipes';
  }

  @override
  String get createListErrorCreate => 'Failed to create grocery list.';

  @override
  String get createListBottomSheetTitle => 'Create List';

  @override
  String get createListBottomSheetSubtitle => 'Create a new grocery list.';

  @override
  String get listNameLabel => 'List Name';

  @override
  String get listNameHint => 'E.g., Weekly Groceries';

  @override
  String get listNameEmptyError => 'List name cannot be empty.';

  @override
  String get create => 'Create';

  @override
  String get deletePlanSheetQuotaNote => 'This action cannot be undone.';

  @override
  String get regenerateRecipePromptTitle => 'Regenerate Recipe';

  @override
  String get regenerateRecipePromptSubtitle =>
      'Are you sure you want to regenerate this recipe?';

  @override
  String get regenerateRecipeNotePrefix => 'Note: ';

  @override
  String get regenerateRecipeNoteText =>
      'This will consume a generation quota.';

  @override
  String get regenerateNotesHint =>
      'Any specific requests? (e.g., more protein)';

  @override
  String get regenerateRecipeButtonTitle => 'Regenerate';

  @override
  String get selectDatesTitle => 'Select Dates';

  @override
  String get selectDatesSubtitle => 'Choose the dates for your meal plan.';

  @override
  String get confirmSelectionAction => 'Confirm Selection';

  @override
  String get pantryOtherCategory => 'Other';

  @override
  String get pantryAddTooltip => 'Add to Pantry';

  @override
  String get pantryEmptyTitle => 'Your pantry is empty.';

  @override
  String get pantryEmptySubtitle =>
      'Add items to keep track of your ingredients.';

  @override
  String get addItemQuantityInvalid => 'Invalid quantity entered.';

  @override
  String get pantryNoDate => 'No expiration date';

  @override
  String pantryEditTitle(Object ingredientName) {
    return 'Edit $ingredientName';
  }

  @override
  String get pantryQuantityLabel => 'Quantity';

  @override
  String get pantryExpiryLabel => 'Expiry Date';

  @override
  String get save => 'Save';

  @override
  String get pantryItemExpired => 'Expired';

  @override
  String get pantryStockLow => 'Low stock';

  @override
  String get pantryStockNormal => 'Adequate stock';

  @override
  String get pantryDeleteDialogTitle => 'Delete Item';

  @override
  String pantryDeleteDialogMessage(Object ingredientName) {
    return 'Are you sure you want to delete $ingredientName from your pantry?';
  }

  @override
  String get addItemDefaultUnit => 'pieces';

  @override
  String get addItemErrorAdding => 'Failed to add item.';

  @override
  String get addItemTitlePantry => 'Add to Pantry';

  @override
  String get addItemTitleGrocery => 'Add to Grocery List';

  @override
  String get addItemIngredientNameLabel => 'Item Name';

  @override
  String get addItemIngredientNamePantryHint => 'E.g., Milk';

  @override
  String get addItemIngredientNameGroceryHint => 'E.g., Bread';

  @override
  String get addItemIngredientNameRequired => 'Item name is required.';

  @override
  String get addItemQuantityLabel => 'Quantity';

  @override
  String get addItemQuantityRequired => 'Quantity is required.';

  @override
  String get addItemUnitLabel => 'Unit';

  @override
  String get addItemUnitHint => 'E.g., kg, liters';

  @override
  String get addItemCategoryLabel => 'Category';

  @override
  String get addItemCategoryHint => 'Select a category';

  @override
  String get addItemExpiryLabel => 'Expiry Date';

  @override
  String get addItemButtonPantry => 'Add to Pantry';

  @override
  String get addItemButtonGrocery => 'Add to Grocery List';

  @override
  String pantryCountLabel(Object count) {
    return '$count items in pantry';
  }

  @override
  String get groceryListDetailPendingHeader => 'Pending Items';

  @override
  String get groceryListDetailCompletedHeader => 'Completed Items';

  @override
  String get groceryListDetailEmptyTitle => 'This list is empty.';

  @override
  String get groceryListDetailEmptySubtitle => 'Add items using the + button.';

  @override
  String get groceryItemInPantry => 'In Pantry';

  @override
  String get groceryItemEditTooltip => 'Edit Item';

  @override
  String get editQuantityDialogTitle => 'Edit Quantity';

  @override
  String get grocerySectionTitle => 'Grocery';

  @override
  String get groceryListsTab => 'Lists';

  @override
  String get pantryTab => 'Pantry';

  @override
  String get groceryListsErrorLoading => 'Failed to load lists.';

  @override
  String get groceryListsEmptyTitle => 'No lists found.';

  @override
  String get groceryListsEmptySubtitle => 'Create your first grocery list.';

  @override
  String get deleteGroceryListDialogTitle => 'Delete List';

  @override
  String deleteGroceryListDialogMessage(Object listName) {
    return 'Are you sure you want to delete $listName?';
  }

  @override
  String get profilePlanFreeBadge => 'Free Plan';

  @override
  String get homeWeekLabel => 'This Week';

  @override
  String greeting(Object name) {
    return 'Hi, $name!';
  }

  @override
  String get homeTodayPlanReady => 'Your plan for today is ready.';

  @override
  String get homeViewRecipeShort => 'View';

  @override
  String get homeEatOutAction => 'Eat Out';

  @override
  String get homeSkipMealQuestion => 'Skip Meal?';

  @override
  String get homeSkipMealDescription =>
      'Are you sure you want to skip this meal?';

  @override
  String get homeConfirmAction => 'Confirm';

  @override
  String get homeFavoritesAction => 'Favorites';

  @override
  String get homeProgressAction => 'Progress';

  @override
  String get homeEmptyPlanTitle => 'No plans for today.';

  @override
  String get homeEmptyPlanMessage =>
      'Create a new plan or enjoy your free day!';

  @override
  String get averageAbbr => 'avg';

  @override
  String get selectGroceryListEmpty =>
      'You have no grocery lists. Create a new one.';

  @override
  String get selectGroceryListNewList => 'Create New List';

  @override
  String get mealPlanHistory => 'History';

  @override
  String get planEntriesTitle => 'Plan Entries';

  @override
  String get noEntriesInPlan => 'No entries found in this plan.';

  @override
  String get myPlansTitle => 'My Plans';

  @override
  String get createNewPlanTooltip => 'Create new plan';

  @override
  String get noPlansAddedTitle => 'No plans yet.';

  @override
  String get noPlansAddedMessage =>
      'Start your journey by generating a new meal plan.';

  @override
  String get tryAgain => 'Try Again';

  @override
  String days(Object count) {
    return '$count days';
  }

  @override
  String get approvePlanEndDate => 'End date is unknown';

  @override
  String get nutritionFilterDaily => 'Daily';

  @override
  String get nutritionFilterWeekly => 'Weekly';

  @override
  String get nutritionFilterMonthly => 'Monthly';

  @override
  String get nutritionErrorLoading => 'Failed to load nutrition data.';

  @override
  String get achievementsTitle => 'Achievements';

  @override
  String get weeklyActivityTitle => 'Weekly Activity';

  @override
  String get mondayToSundayLabel => 'MON - SUN';

  @override
  String get mealPlanActionViewDetails => 'View Details';

  @override
  String get planDeletedSuccess => 'Plan obliterated.';

  @override
  String get planBadgeAI => 'GENERATED WITH AI';

  @override
  String get planBadgeCustom => 'CUSTOMIZED';

  @override
  String get cookingProgress => 'RECIPE PROGRESS';

  @override
  String stepOfTotal(Object current, Object total) {
    return 'Step $current of $total';
  }

  @override
  String percentCompleted(Object percent) {
    return '$percent% completed';
  }

  @override
  String get neededForThisStep => 'Needed for this step';

  @override
  String get mainIngredientSubtitle => 'Main ingredient';

  @override
  String get neededToolSubtitle => 'Required tool';

  @override
  String get nextStepAction => 'Next step';

  @override
  String get finishRecipeAction => 'Finish recipe';

  @override
  String get recipeCompletedSnack =>
      'Recipe completed and deducted from pantry!';

  @override
  String recipeCompletedMissingSnack(Object count) {
    return 'Recipe completed. $count ingredients were missing from pantry.';
  }

  @override
  String get timerLabel => 'TIMER';

  @override
  String get checkYourInbox => 'Check your inbox';

  @override
  String get otpVerificationMessage =>
      'We\'ve sent a 6-digit verification code to your new email address. Please enter it below to complete the change.';

  @override
  String get otpRequestMessage =>
      'Enter your new email address. We\'ll send a verification code to ensure it\'s you.';

  @override
  String get newEmailAddressLabel => 'New Email Address';

  @override
  String get newEmailPlaceholder => 'name@example.com';

  @override
  String get didntReceiveCode => 'Didn\'t receive the code?';

  @override
  String get resendAction => 'Resend';

  @override
  String get secureVerificationNote =>
      'Secure verification powered by SageAuth';

  @override
  String get saveSelectionAction => 'Save selection';

  @override
  String get premiumLearnMore => 'Learn more';

  @override
  String get swapFavoriteTitle => 'Swap for Favorite';

  @override
  String get myFavoriteRecipes => 'MY FAVORITE RECIPES';

  @override
  String get servingsShortLabel => 'serv';

  @override
  String get peopleLabel => 'People';

  @override
  String get likedFoodsLabel => 'Liked Foods';

  @override
  String get dislikedFoodsLabel => 'Disliked Foods';

  @override
  String get addLabel => 'Add';

  @override
  String get kcalLabel => 'Kcal';

  @override
  String get metricCarbsShort => 'Carbs';

  @override
  String get timeLabelUpper => 'TIME';

  @override
  String get servingsLabelUpper => 'SERVINGS';

  @override
  String get caloriesLabelUpper => 'CALORIES';

  @override
  String get nutritionPerServing => 'Nutrition per serving';

  @override
  String itemsCount(Object count) {
    return '$count items';
  }

  @override
  String get servingShort => 'serving';

  @override
  String get organizeFavoritesSubtitle =>
      'Organize your favorite recipes and ingredients';
}
