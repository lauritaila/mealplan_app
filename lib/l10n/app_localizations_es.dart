// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'Plan de comidas';

  @override
  String get genericError => 'Algo salió mal. Inténtalo de nuevo.';

  @override
  String get errorFieldRequired => 'Este campo es obligatorio.';

  @override
  String get errorEmailInvalid => 'Ingresa un correo válido.';

  @override
  String get errorPasswordMinLength => 'Mínimo 6 caracteres.';

  @override
  String get errorPasswordFormat =>
      'Debe incluir mayúscula, minúscula y un número.';

  @override
  String get errorAuthInvalidCredentials =>
      'Credenciales inválidas. Revisa tu correo y contraseña.';

  @override
  String get errorAuthEmailNotVerified =>
      'Tu correo no ha sido verificado. Revisa tu bandeja de entrada.';

  @override
  String get errorAuthUserNotFound => 'Usuario no encontrado.';

  @override
  String get errorAuthEmailInUse => 'Este correo ya está registrado.';

  @override
  String get errorAuthPasswordResetFailed =>
      'No se pudo restablecer la contraseña. Inténtalo más tarde.';

  @override
  String get errorAuthResendVerificationFailed =>
      'No se pudo reenviar el correo de verificación.';

  @override
  String get errorAuthInvalidOtp => 'El código ingresado es inválido o expiró.';

  @override
  String get errorAuthUnexpected =>
      'Ocurrió un error inesperado de autenticación.';

  @override
  String get errorAuthGoogleSignInFailed =>
      'Ocurrió un error inesperado al iniciar sesión con Google.';

  @override
  String get errorAuthSendOtpFailed =>
      'No se pudo enviar el OTP. Inténtalo de nuevo.';

  @override
  String get errorNetworkTimeout =>
      'La solicitud tardó demasiado. Revisa tu conexión.';

  @override
  String get errorNetworkNoConnection =>
      'Sin conexión a internet. Conéctate e inténtalo de nuevo.';

  @override
  String get errorNetworkServer => 'Error del servidor. Inténtalo más tarde.';

  @override
  String get errorNetworkBadResponse => 'Respuesta inesperada del servidor.';

  @override
  String get errorNetworkUnreachableHost =>
      'No se puede llegar al servidor. Revisa host, puerto o VPN.';

  @override
  String get errorNetworkSsl => 'Falló la conexión segura (SSL/TLS).';

  @override
  String get errorNetworkRateLimit =>
      'Demasiadas solicitudes. Espera e inténtalo de nuevo.';

  @override
  String get errorNetworkBadRequest =>
      'La solicitud fue rechazada por el servidor.';

  @override
  String get errorDataNotFound => 'No se encontró la información solicitada.';

  @override
  String get errorDataInvalid => 'Datos inválidos.';

  @override
  String get errorDataCreationFailed => 'No se pudo crear la información.';

  @override
  String get errorDataUpdateFailed => 'No se pudo actualizar la información.';

  @override
  String get errorDataFetchFailed => 'No se pudo obtener la información.';

  @override
  String get errorDataSerializationFailed =>
      'No se pudo procesar la información.';

  @override
  String get errorDataEmptyResponse => 'La respuesta llegó vacía.';

  @override
  String get errorPermissionUnauthorized =>
      'No autorizado. Inicia sesión nuevamente.';

  @override
  String get errorPermissionForbidden =>
      'No tienes permisos para realizar esta acción.';

  @override
  String get errorConfigMissing => 'Falta configuración.';

  @override
  String get errorConfigInvalid => 'La configuración es inválida.';

  @override
  String get errorMealPlanNotAuthenticated => 'Inicia sesión para continuar.';

  @override
  String get errorMealPlanDaysNotAllowed =>
      'La cantidad de días seleccionada no está permitida.';

  @override
  String get errorMealPlanTypesNotAllowed =>
      'Algunos tipos de comida no están permitidos.';

  @override
  String get errorMealPlanGenerateFailed =>
      'No se pudo generar el plan. Inténtalo de nuevo.';

  @override
  String get errorMealPlanQuotaReached =>
      'Has agotado las generaciones de planes esta semana.';

  @override
  String get approvePlanTitle => 'Aprobar plan';

  @override
  String get noPlanDataReceived => 'No se recibieron datos del plan.';

  @override
  String get done => 'Listo';

  @override
  String get graceWelcomeTitle => '¡Te extrañábamos! Gracias por volver.';

  @override
  String get graceWelcomeMessage =>
      'Toda tu información sigue guardada y lista para continuar.';

  @override
  String get continueLabel => 'Continuar';

  @override
  String mealsCount(Object count) {
    return '$count comidas';
  }

  @override
  String caloriesKcal(Object calories) {
    return '$calories kcal';
  }

  @override
  String servingsLabel(Object count) {
    return 'Raciones: $count';
  }

  @override
  String prepMinutesLabel(Object minutes) {
    return 'Prep: $minutes min';
  }

  @override
  String cookMinutesLabel(Object minutes) {
    return 'Cocción: $minutes min';
  }

  @override
  String proteinLabel(Object grams) {
    return 'Proteína: $grams g';
  }

  @override
  String carbsLabel(Object grams) {
    return 'Carbohidratos: $grams g';
  }

  @override
  String fatsLabel(Object grams) {
    return 'Grasas: $grams g';
  }

  @override
  String get preparingPlanTitle => 'Preparando tu plan';

  @override
  String get loadingMessageCookbook => 'Revisando el recetario de la abuela...';

  @override
  String get loadingMessageRecipes => 'Quitando el polvo a las recetas...';

  @override
  String get loadingMessageAunts => 'Preguntando a las tías sus secretos...';

  @override
  String get loadingMessageFridge => 'Mirando en la nevera...';

  @override
  String get loadingMessageKnives => 'Afilando cuchillos imaginarios...';

  @override
  String get loadingMessageTablespoons => 'Midiendo cucharadas al ojo...';

  @override
  String get cookingCombosMessage =>
      'Preparando combinaciones ricas y saludables para ti...';

  @override
  String get cancelAndGoBack => 'Cancelar y volver';

  @override
  String get planLimitReachedTitle => 'Límite de planes alcanzado';

  @override
  String get planLimitReachedMessage =>
      'Has agotado las generaciones de planes esta semana.';

  @override
  String get newPlanTitle => 'Nuevo plan';

  @override
  String get clear => 'Limpiar';

  @override
  String get configurePlanTitle => 'Configura tu plan';

  @override
  String get configurePlanSubtitle =>
      'Define duración, personas y comidas base.';

  @override
  String get durationTitle => 'Duración';

  @override
  String daysLabel(Object days) {
    return '$days días';
  }

  @override
  String get dinersTitle => 'Comensales';

  @override
  String peopleCount(Object count) {
    return '$count personas';
  }

  @override
  String get mealTypesTitle => 'Tipos de comida';

  @override
  String get mealTypeBreakfast => 'Desayuno';

  @override
  String get mealTypeLunch => 'Almuerzo';

  @override
  String get mealTypeSnack => 'Merienda';

  @override
  String get mealTypeDinner => 'Cena';

  @override
  String get mealTypeBreakfastSubtitle => 'Energía para el día';

  @override
  String get mealTypeLunchSubtitle => 'Comida principal';

  @override
  String get mealTypeSnackSubtitle => 'Algo ligero';

  @override
  String get mealTypeDinnerSubtitle => 'Ligero y nutritivo';

  @override
  String get notesOptionalTitle => 'Notas (opcional)';

  @override
  String get notesHint => 'Ej.: Sin lactosa, más proteínas...';

  @override
  String get usePantryLabel => 'Usar ingredientes de la despensa';

  @override
  String get usePantrySubtitle =>
      'La IA priorizará recetas con lo que ya tienes';

  @override
  String get mealsOfDayTitle => 'Comidas del día';

  @override
  String get skipMealAction => 'Saltar comida';

  @override
  String get unskipMealAction => 'Quitar salto';

  @override
  String get mealSkippedLabel => 'Saltada';

  @override
  String get skipMealDialogTitle => 'Comida saltada';

  @override
  String get skipMealDialogMessage =>
      'No pasa nada por saltar una comida. Puedes continuar con tu plan cuando quieras.';

  @override
  String get viewRecipeDetails => 'Ver receta';

  @override
  String get categoriesTitle => 'Categorías';

  @override
  String get metricCalories => 'Cal';

  @override
  String get metricServings => 'Raciones';

  @override
  String get metricFat => 'Grasa';

  @override
  String get metricCarbs => 'Carbs';

  @override
  String get metricProtein => 'Proteína';

  @override
  String get metricKcal => 'Kcal';

  @override
  String get descriptionTitle => 'Descripción';

  @override
  String get instructionsTitle => 'Instrucciones';

  @override
  String get ingredientsTitle => 'Ingredientes';

  @override
  String get noInstructions => 'Sin instrucciones.';

  @override
  String get noIngredients => 'Sin ingredientes.';

  @override
  String get retry => 'Reintentar';

  @override
  String get noMealsLoggedToday => 'No hay comidas registradas para hoy.';

  @override
  String get weekdayMonShort => 'Lun';

  @override
  String get weekdayTueShort => 'Mar';

  @override
  String get weekdayWedShort => 'Mié';

  @override
  String get weekdayThuShort => 'Jue';

  @override
  String get weekdayFriShort => 'Vie';

  @override
  String get weekdaySatShort => 'Sáb';

  @override
  String get weekdaySunShort => 'Dom';

  @override
  String get homeTitle => 'Inicio';

  @override
  String get generateNewPlan => 'Generar nuevo plan';

  @override
  String get logout => 'Cerrar sesión';

  @override
  String get deleteAccount => 'Eliminar cuenta';

  @override
  String get profileNotificationsTitle => 'Notificaciones';

  @override
  String get profileTermsTitle => 'Términos y condiciones';

  @override
  String unableToLoadPlanStatus(Object error) {
    return 'No se pudo cargar el estado del plan: $error';
  }

  @override
  String plansLeftThisWeek(Object remaining, Object total) {
    return 'Quedan $remaining de $total planes esta semana';
  }

  @override
  String get goPremiumUnlockMorePlans =>
      'Pásate a premium para desbloquear más planes.';

  @override
  String get goPremiumTitle => 'Hazte Premium';

  @override
  String get freePlanLimitedGenerations =>
      'Tu plan gratuito tiene generaciones limitadas de planes.';

  @override
  String get goPremiumKeepGenerating =>
      'Hazte premium para seguir generando planes.';

  @override
  String get goToHome => 'Ir a Inicio';

  @override
  String get recipesTitle => 'Recetas';

  @override
  String get favoriteRecipesTitle => 'Recetas favoritas';

  @override
  String get favoriteUpdateFailed =>
      'No se pudo actualizar favoritos. Inténtalo de nuevo.';

  @override
  String get favoritesTooltip => 'Favoritas';

  @override
  String get noRecipesAvailable => 'No hay recetas disponibles';

  @override
  String get noFavoriteRecipes => 'No tienes recetas favoritas';

  @override
  String get recipeDetailTitle => 'Detalle de receta';

  @override
  String get errorTitle => 'Error';

  @override
  String errorOccurred(Object error) {
    return 'Ocurrió un error: $error';
  }

  @override
  String get login => 'Iniciar sesión';

  @override
  String get register => 'Registrarse';

  @override
  String get signUp => 'Registrarse';

  @override
  String get email => 'Correo electrónico';

  @override
  String get name => 'Nombre';

  @override
  String get sendOtp => 'Enviar OTP';

  @override
  String get sendVerificationCodeOtp => 'Enviar código de verificación OTP';

  @override
  String get signInWithGoogle => 'Continuar con Google';

  @override
  String get dontHaveAccount => '¿No tienes una cuenta?';

  @override
  String get doYouHaveAccount => '¿Ya tienes una cuenta?';

  @override
  String get verificationCodeSentEmail =>
      'Se ha enviado un código de verificación a tu correo.';

  @override
  String get otpEnterTitle => 'Ingresa el código de verificación';

  @override
  String get otpEnterSubtitle => 'Ingresa el código de 6 dígitos enviado a:';

  @override
  String get otpVerificationCodeLabel => 'Código de verificación';

  @override
  String get otpResend => '¿No recibiste un código? Enviar de nuevo';

  @override
  String get otpVerifySignIn => 'Verificar e iniciar sesión';

  @override
  String get otpSentSnack => '¡Código de verificación enviado!';

  @override
  String get preferencesSaved => 'Preferencias guardadas correctamente';

  @override
  String get errorSavePreferencesRollbackFailed =>
      'No se pudieron guardar las preferencias y también falló la reversión. La app puede quedar en un estado inconsistente.';

  @override
  String get unknownError => 'Ocurrió un error desconocido';

  @override
  String get wizardPrevious => 'Anterior';

  @override
  String get wizardNext => 'Siguiente';

  @override
  String get wizardFinish => 'Finalizar';

  @override
  String stepOf(Object current, Object total) {
    return 'Paso $current de $total';
  }

  @override
  String get dietaryTitle => 'Preferencias y restricciones alimentarias';

  @override
  String get allergiesTitle => 'Alergias';

  @override
  String get allergiesOtherTitle => 'Otras alergias';

  @override
  String get allergiesOtherHint => 'Indica otras alergias...';

  @override
  String get foodPreferencesTitle => 'Preferencias de alimentos';

  @override
  String get dislikedFoodsTitle => 'Alimentos que no te gustan';

  @override
  String get dislikedFoodsHint =>
      'Lista los alimentos que no te gustan o quieres evitar...';

  @override
  String get likedFoodsTitle => 'Alimentos que te gustan';

  @override
  String get likedFoodsHint =>
      'Lista tus alimentos e ingredientes favoritos...';

  @override
  String get goalsTitle => 'Objetivos y elecciones alimentarias';

  @override
  String get cookingDetailsTitle => 'Detalles de cocina';

  @override
  String get cookingSkillTitle => 'Nivel de cocina';

  @override
  String get timeAvailabilityTitle => 'Disponibilidad de tiempo';

  @override
  String get householdSizeTitle => 'Tamaño del hogar';

  @override
  String get dietVegetarian => 'Vegetariano';

  @override
  String get dietVegan => 'Vegano';

  @override
  String get dietPescatarian => 'Pescetariano';

  @override
  String get dietKeto => 'Keto';

  @override
  String get dietPaleo => 'Paleo';

  @override
  String get dietMediterranean => 'Mediterránea';

  @override
  String get dietLowCarb => 'Baja en carbohidratos';

  @override
  String get dietLowFat => 'Baja en grasa';

  @override
  String get dietGlutenFree => 'Sin gluten';

  @override
  String get dietDairyFree => 'Sin lácteos';

  @override
  String get dietNutFree => 'Sin frutos secos';

  @override
  String get dietHalal => 'Halal';

  @override
  String get dietKosher => 'Kosher';

  @override
  String get allergyNuts => 'Frutos secos';

  @override
  String get allergyDairy => 'Lácteos';

  @override
  String get allergyEggs => 'Huevos';

  @override
  String get allergySoy => 'Soja';

  @override
  String get allergyWheat => 'Trigo';

  @override
  String get allergyFish => 'Pescado';

  @override
  String get allergyShellfish => 'Mariscos';

  @override
  String get allergySesame => 'Sésamo';

  @override
  String get goalWeightLoss => 'Pérdida de peso';

  @override
  String get goalWeightGain => 'Aumento de peso';

  @override
  String get goalMuscleBuilding => 'Ganar músculo';

  @override
  String get goalHeartHealth => 'Salud cardiovascular';

  @override
  String get goalDiabetesManagement => 'Control de diabetes';

  @override
  String get goalHighProtein => 'Alta en proteína';

  @override
  String get goalLowSodium => 'Baja en sodio';

  @override
  String get goalAntiInflammatory => 'Antiinflamatoria';

  @override
  String get skillBeginner => 'Principiante';

  @override
  String get skillIntermediate => 'Intermedio';

  @override
  String get skillAdvanced => 'Avanzado';

  @override
  String get time15Min => '15 min';

  @override
  String get time30Min => '30 min';

  @override
  String get time1HourPlus => '1+ hora';

  @override
  String get profileTitle => 'Perfil';

  @override
  String get settingsTitle => 'Configuración';

  @override
  String get profileGuestName => 'Invitado';

  @override
  String get profilePreferencesTitle => 'Preferencias';

  @override
  String get profileDietarySpecsLabel => 'Especificaciones dietéticas';

  @override
  String get profileHideNutritionLabel => 'Ocultar valores nutricionales';

  @override
  String get profileSecurityTitle => 'Seguridad';

  @override
  String get profileChangeEmailLabel => 'Cambiar correo';

  @override
  String get profileLanguageTitle => 'Idioma';

  @override
  String get profileLanguageLabel => 'Idioma de la app';

  @override
  String get profileLanguageEnglish => 'Inglés';

  @override
  String get profileLanguageSpanish => 'Español';

  @override
  String get profilePaymentsTitle => 'Pagos';

  @override
  String get profilePaymentsEmpty => 'Todavía no hay pagos para mostrar.';

  @override
  String get profileSubscriptionTitle => 'Suscripción';

  @override
  String get profileSubscriptionCurrentLabel => 'Plan actual';

  @override
  String get profileSubscriptionIncludesLabel => 'Incluye';

  @override
  String get profileSubscriptionFree => 'Gratis';

  @override
  String get profileNoIncludes => 'Aún no hay beneficios listados.';

  @override
  String get profileSavePreferences => 'Guardar preferencias';

  @override
  String get mealPlanTitle => 'Plan de comidas';

  @override
  String get groceryTitle => 'Compras';

  @override
  String get nutritionTitle => 'Nutrición';

  @override
  String get profileFarewell =>
      'Lamentamos tu partida.\nGuardaremos tu cocina y tus playlists por 30 días por si decides volver. Después de eso, limpiaremos la mesa para siempre.';

  @override
  String confirmDeleteWithEmail(Object email) {
    return '¿Estás seguro? Escribe tu correo para confirmar: $email';
  }

  @override
  String get emailPlaceholder => 'correo@ejemplo.com';

  @override
  String get deletePlanTooltip => 'Eliminar plan';

  @override
  String get deleteMealDialogTitle => '¿Eliminar esta comida?';

  @override
  String get deleteMealDialogMessage =>
      'Esta receta se eliminará del plan. Esta acción no se puede deshacer.';

  @override
  String get deleteAction => 'Eliminar';

  @override
  String get changeMealDateAction => 'Cambiar fecha de comida';

  @override
  String get swapFavoriteAction => 'Cambiar por favorita';

  @override
  String get regenerateRecipeAction => 'Regenerar receta';

  @override
  String get genericMoveError =>
      'No se pudo mover la comida. Inténtalo de nuevo.';

  @override
  String get genericDeleteError => 'No se pudo eliminar. Inténtalo de nuevo.';

  @override
  String get genericRegenerateError =>
      'No se pudo regenerar la receta. Inténtalo de nuevo.';

  @override
  String get dragDropHint =>
      'Mantén presionada una receta para arrastrarla a otro día o usa el menú para cambiar fecha.';

  @override
  String get dragDropTooltip =>
      'Tip: puedes mover comidas arrastrando entre días o desde el menú “Cambiar fecha de comida”.';

  @override
  String get emptyDayDropText => 'Suelta una comida aquí';

  @override
  String get viewDetailsLabel => 'Ver detalle';

  @override
  String get hideDetailsLabel => 'Ocultar detalle';

  @override
  String get regenerateSheetSubtitle =>
      'Cuéntanos qué cambiar o déjalo en blanco para que la IA elija.';

  @override
  String get regenerateSheetNotesLabel => 'Descripción (opcional)';

  @override
  String get regenerateSheetNotesHint => 'Ej: Algo más ligero, sin gluten...';

  @override
  String get regenerateSheetMaxPrepTimeLabel => 'Tiempo máximo de preparación';

  @override
  String get regenerateSheetButton => 'Regenerar';

  @override
  String get deletePlanSheetTitle => 'Eliminar plan de comidas';

  @override
  String get deletePlanSheetWarning =>
      'Eliminar este plan igual se cuenta en tu límite de generación de planes. Esta acción no se puede deshacer.';

  @override
  String get deletePlanSheetReasonLabel =>
      '¿Por qué eliminás el plan? (opcional)';

  @override
  String get deletePlanSheetReasonHint => 'Ej: No me gustaron las recetas...';

  @override
  String get deletePlanSheetConfirmAction => 'Sí, eliminar plan';

  @override
  String minutesShortWithPlaceholder(Object minutes) {
    return '$minutes min';
  }

  @override
  String ingredientSubstitutesTitle(Object ingredient) {
    return 'Sustitutos de $ingredient';
  }

  @override
  String get ingredientSubstitutesTooltip => 'Buscar sustitutos';

  @override
  String get loadingSubstitutes => 'Cargando sustitutos...';

  @override
  String get noSubstitutesAvailable => 'No hay sustitutos disponibles.';

  @override
  String substituteDetails(Object ratio, Object reason, Object category) {
    return 'Proporción: $ratio | $reason | $category';
  }

  @override
  String get substituteConfirmTitle => 'Confirmar sustituto';

  @override
  String get substituteConfirmMessage =>
      'Cambiar un ingrediente puede cambiar significativamente el sabor.';

  @override
  String get substituteConfirmNutritionWarning =>
      'Este cambio también puede afectar los valores nutricionales de la receta.';

  @override
  String get applySubstituteAction => 'Aplicar sustituto';

  @override
  String get applyingSubstitute => 'Aplicando sustituto...';

  @override
  String get substituteMissingIngredientId =>
      'No se puede aplicar un sustituto para este ingrediente.';

  @override
  String get openCookingAssistant => 'Abrir ayudante de cocina';

  @override
  String get cookingAssistantTitle => 'Ayudante de cocina';

  @override
  String get cookingAssistantDisclaimer =>
      'Los tiempos son estimados y pueden cambiar.';

  @override
  String cookingAssistantStepLabel(Object step) {
    return 'Paso $step';
  }

  @override
  String get cookingAssistantIngredientsTitle => 'Ingredientes en este paso';

  @override
  String get cookingAssistantToolsTitle => 'Herramientas necesarias';

  @override
  String get noCookingSteps => 'No hay pasos disponibles.';

  @override
  String get noToolsNeeded => 'No hay herramientas listadas.';

  @override
  String estimatedTimeLabel(Object time) {
    return 'Tiempo estimado: $time';
  }

  @override
  String get startTimer => 'Iniciar';

  @override
  String get pauseTimer => 'Pausar';

  @override
  String get resetTimer => 'Reiniciar';

  @override
  String get noTimerAvailable => 'No hay temporizador para este paso.';

  @override
  String get cancel => 'Cancelar';

  @override
  String get save => 'Guardar';

  @override
  String get create => 'Crear';

  @override
  String get error => 'Error';

  @override
  String get errorLoadingConfiguration =>
      'Error al cargar la configuración. Inténtalo de nuevo.';

  @override
  String get errorEmailConfirmationMismatch =>
      'El correo no coincide con tu cuenta.';

  @override
  String get myPlansTitle => 'Mis planes';

  @override
  String get newPlan => 'Nuevo plan';

  @override
  String get noSavedPlans => 'No tienes planes guardados';

  @override
  String get createFirstPlan => 'Crea tu primer plan de comidas.';

  @override
  String get menuViewEntries => 'Ver entradas';

  @override
  String get menuSaveIngredients => 'Guardar ingredientes';

  @override
  String get menuReusePlan => 'Reutilizar plan';

  @override
  String get saveIngredientsSheetTitle => 'Guardar ingredientes del plan';

  @override
  String savedIngredientsSuccess(Object name) {
    return 'Ingredientes guardados en \"$name\"';
  }

  @override
  String get savedIngredientsFailed => 'No se pudo guardar los ingredientes';

  @override
  String planReusedSuccess(Object name, Object count) {
    return '¡Plan reutilizado! \"$name\" con $count comidas.';
  }

  @override
  String get planReusedView => 'Ver';

  @override
  String get planReusedFailed => 'No se pudo reutilizar el plan';

  @override
  String get deletePlanDialogTitle => '¿Eliminar plan?';

  @override
  String get deletePlanDialogMessage => 'Esta acción no se puede deshacer.';

  @override
  String get deletePlanAlsoRemoveGrocery =>
      'Eliminar también de la lista de la compra';

  @override
  String get planDeletedSuccess => 'Plan eliminado';

  @override
  String get planDeleteFailed => 'No se pudo eliminar el plan';

  @override
  String get reusePlanSheetTitle => 'Reutilizar plan';

  @override
  String get reusePlanStartDateLabel => 'Fecha de inicio (requerida)';

  @override
  String get reusePlanSelectDate => 'Seleccionar fecha';

  @override
  String get reusePlanNameLabel => 'Nombre del nuevo plan (opcional)';

  @override
  String get reusePlanNameHint => 'Ej: Semana del 17 de marzo';

  @override
  String get noEntriesInPlan => 'No hay entradas en este plan.';

  @override
  String get planEntriesTitle => 'Entradas del plan';

  @override
  String get menuViewRecipe => 'Ver receta';

  @override
  String get menuAddToGrocery => 'Agregar a lista de compras';

  @override
  String get menuMarkComplete => 'Marcar como completada';

  @override
  String get addRecipeToListTitle => 'Agregar receta a lista';

  @override
  String recipeAddedToList(Object name) {
    return 'Receta agregada a \"$name\"';
  }

  @override
  String get recipeAddFailed => 'No se pudo agregar la receta';

  @override
  String get markCompleteDialogTitle => 'Marcar como completada';

  @override
  String markCompleteQuestion(Object name) {
    return '¿Completaste \"$name\"?';
  }

  @override
  String get markCompleteDeductInfo =>
      'Los ingredientes de esta receta se descontarán automáticamente de tu despensa.';

  @override
  String get completeAction => 'Completar';

  @override
  String allIngredientsDeducted(Object count) {
    return '✅ ¡Listo! $count ingredientes descontados.';
  }

  @override
  String someIngredientsMissing(Object count) {
    return '✅ Completado. $count ingredientes no estaban en tu despensa.';
  }

  @override
  String get alsoRemoveFromGrocery =>
      'Eliminar también de la lista de la compra';

  @override
  String get noRecipeForEntry => 'Esta entrada no tiene receta asociada';

  @override
  String get datesUpdatedSuccess => 'Fechas actualizadas correctamente';

  @override
  String get saveToGroceryList => 'Guardar en lista de compras';

  @override
  String get usePantryIngredientsLabel => 'Usar ingredientes de mi despensa';

  @override
  String get alsoRemoveGroceryList => 'También eliminar la lista de la compra';

  @override
  String get markCompleteRecipeButton => 'Marcar como completada';

  @override
  String get completeRecipeButton => 'Completar receta';

  @override
  String get aiLabel => 'IA';

  @override
  String get pantryTitle => 'Mi despensa';

  @override
  String get pantryEmptyTitle => 'La despensa está vacía';

  @override
  String get pantryEmptySubtitle => 'Agrega ingredientes que ya tienes en casa';

  @override
  String get pantryAddTooltip => 'Agregar a la despensa';

  @override
  String get pantryOtherCategory => 'Otros';

  @override
  String get pantryNoDate => 'Sin fecha';

  @override
  String pantryEditTitle(Object name) {
    return 'Editar $name';
  }

  @override
  String get pantryQuantityLabel => 'Cantidad';

  @override
  String get pantryExpiryLabel => 'Vence';

  @override
  String get pantryDeleteDialogTitle => 'Eliminar de la despensa';

  @override
  String pantryDeleteDialogMessage(Object name) {
    return '¿Eliminar \"$name\"?';
  }

  @override
  String get groceryListsTitle => 'Mis listas';

  @override
  String get groceryListsSectionHeader => 'Listas de compras';

  @override
  String get groceryListsEmptyTitle => 'No hay listas aún';

  @override
  String get groceryListsEmptySubtitle => 'Crea una nueva lista con el botón +';

  @override
  String get groceryListsNewListLabel => 'Nueva lista';

  @override
  String get groceryListsErrorLoading => 'Error al cargar listas';

  @override
  String get pantryCardTitle => 'Mi despensa';

  @override
  String get pantryCardSubtitle => 'Ingredientes que ya tienes en casa';

  @override
  String get createListDialogTitle => 'Nueva lista de compras';

  @override
  String get createListErrorCreate => 'Error al crear la lista';

  @override
  String get groceryDetailError => 'Error';

  @override
  String get editQuantityDialogTitle => 'Editar cantidad';

  @override
  String get addItemTitlePantry => 'Agregar a la despensa';

  @override
  String get addItemTitleGrocery => 'Agregar ingrediente';

  @override
  String get addItemIngredientNameLabel => 'Nombre del ingrediente';

  @override
  String get addItemIngredientNameRequired => 'Ingresa el nombre';

  @override
  String get addItemQuantityLabel => 'Cantidad';

  @override
  String get addItemQuantityRequired => 'Requerido';

  @override
  String get addItemQuantityInvalid => 'Número inválido';

  @override
  String get addItemUnitLabel => 'Unidad';

  @override
  String get addItemCategoryLabel => 'Categoría (opcional)';

  @override
  String get addItemExpiryLabel => 'Fecha de vencimiento (opcional)';

  @override
  String get addItemErrorAdding => 'Error al agregar el ingrediente';

  @override
  String get addItemButton => 'Agregar';

  @override
  String get deleteGroceryListDialogTitle => 'Eliminar lista';

  @override
  String deleteGroceryListDialogMessage(Object name) {
    return '¿Eliminar \"$name\"?';
  }

  @override
  String get selectGroceryListNewList => 'Nueva lista';

  @override
  String get recipeCompleteDialogTitle => 'Completar receta';

  @override
  String get recipeCompleteDialogMessage =>
      '¿Marcar esta receta como completada y descontar los ingredientes de tu despensa?';

  @override
  String recipeCompletedSuccess(Object success, Object missing) {
    return '¡Receta completada! $success ingredientes descontados. $missing';
  }

  @override
  String recipeCompletedMissingNote(Object count) {
    return '$count no encontrados.';
  }

  @override
  String get markAsCompleteLabel => 'Marcar como completada';

  @override
  String get cookingAssistantBack => 'Atrás';

  @override
  String get cookingAssistantNext => 'Siguiente';

  @override
  String get cookingAssistantComplete => 'Completar receta';

  @override
  String get cookingAssistantCompleteAction => 'Completar';
}
