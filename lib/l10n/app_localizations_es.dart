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
  String get profilePrivacyTitle => 'Política de privacidad';

  @override
  String get lastUpdatedLabel => 'Última actualización';

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
  String get noDescriptionProvided => 'No se proporcionó descripción';

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
  String otpEnterSubtitle(Object email) {
    return 'Ingresa el código de 6 dígitos enviado a: $email';
  }

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
  String get dislikedFoodsHint => 'Aceitunas, cilantro, champiñones...';

  @override
  String get likedFoodsTitle => 'Alimentos que te gustan';

  @override
  String get likedFoodsHint => 'Aguacate, salmón, col rizada...';

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
  String get profileLanguageDescription =>
      'Selecciona tu idioma de preferencia para la interfaz de la aplicación.';

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
  String get errorLoadingConfiguration =>
      'Error al cargar la configuración. Inténtalo de nuevo.';

  @override
  String get errorEmailConfirmationMismatch =>
      'El correo no coincide con tu cuenta.';

  @override
  String get saveIngredientsSheetTitle => 'Guardar Ingredientes';

  @override
  String get saveIngredientsDialogContent =>
      '¿Quieres guardar los ingredientes de este plan en una lista de compras?';

  @override
  String get yesSaveAction => 'Sí, Guardar';

  @override
  String get notNowAction => 'Ahora No';

  @override
  String get selectListTitle => 'Seleccionar Lista';

  @override
  String get selectListSubtitle => 'Elige dónde guardar tus artículos';

  @override
  String savedIngredientsSuccess(Object listName) {
    return 'Ingredientes guardados en $listName';
  }

  @override
  String get savedIngredientsFailed => 'Error al guardar ingredientes';

  @override
  String get deletePlanAlsoRemoveGrocery =>
      'También eliminar ingredientes de la lista de compras';

  @override
  String get copySuffix => 'Copia';

  @override
  String planReusedSuccess(Object planName, Object count) {
    return 'Plan \'$planName\' reutilizado con $count recetas';
  }

  @override
  String get planReusedView => 'Ver';

  @override
  String get planReusedFailed => 'Error al reutilizar el plan';

  @override
  String get reusePlanSheetTitle => 'Reutilizar Plan';

  @override
  String get reusePlanStartDateLabel => 'Fecha de inicio';

  @override
  String get reusePlanSelectDate => 'Seleccionar Fecha';

  @override
  String get reusePlanNameLabel => 'Nombre (Opcional)';

  @override
  String get reusePlanNameHint => 'Ej. Plan de la próxima semana';

  @override
  String get menuReusePlan => 'Reutilizar plan';

  @override
  String get menuSaveIngredients => 'Guardar ingredientes';

  @override
  String get menuViewEntries => 'Ver recetas';

  @override
  String get planActionsTitle => 'Acciones del Plan';

  @override
  String get datesUpdatedSuccess => 'Fechas actualizadas correctamente';

  @override
  String get noRecipeAssociated => 'No hay receta asociada a esta comida.';

  @override
  String get addRecipeToListTitle => 'Agregar Receta a la Lista';

  @override
  String recipeAddedToList(Object listName) {
    return 'Ingredientes de la receta agregados a $listName';
  }

  @override
  String get recipeAddFailed => 'Error al agregar receta a la lista.';

  @override
  String get markCompleteDialogTitle => 'Marcar como Completado';

  @override
  String markCompleteQuestion(Object mealName) {
    return '¿Has completado $mealName?';
  }

  @override
  String get markCompleteDeductInfo =>
      'Los ingredientes se descontarán de tu despensa si están disponibles.';

  @override
  String get completeAction => 'Completar';

  @override
  String mealCompletedSuccess(Object count) {
    return '¡Comida completada! Se descontaron $count ingredientes de la despensa.';
  }

  @override
  String mealCompletedMissing(Object count) {
    return 'Comida completada. Faltaron $count ingredientes de la despensa.';
  }

  @override
  String get mealCompletedError => 'Error al completar la comida.';

  @override
  String get alsoRemoveFromGrocery => 'También retirar de la lista de compras';

  @override
  String get menuAddToGrocery => 'Agregar a lista de compras';

  @override
  String get mealCompletedLabel => 'Completado';

  @override
  String get usePantryTitle => 'Usar Despensa';

  @override
  String get usePantrySubtitle =>
      'Descontar ingredientes de la despensa al generar.';

  @override
  String get usePantryLabel => 'Usar Ingredientes de la Despensa';

  @override
  String get edit => 'Editar';

  @override
  String get createNewListAction => 'Crear Nueva Lista';

  @override
  String get addCustomName => 'Nombre Personalizado';

  @override
  String get existingListsLabel => 'Listas Existentes';

  @override
  String get noExistingLists => 'No se encontraron listas existentes.';

  @override
  String savedRecipesCount(Object count) {
    return '$count recetas guardadas';
  }

  @override
  String get createListErrorCreate => 'Error al crear la lista de compras.';

  @override
  String get createListBottomSheetTitle => 'Crear Lista';

  @override
  String get createListBottomSheetSubtitle =>
      'Crear una nueva lista de compras.';

  @override
  String get listNameLabel => 'Nombre de la Lista';

  @override
  String get listNameHint => 'Ej. Compras Mensuales';

  @override
  String get listNameEmptyError =>
      'El nombre de la lista no puede estar vacío.';

  @override
  String get create => 'Crear';

  @override
  String get deletePlanSheetQuotaNote => 'Esta acción no se puede deshacer.';

  @override
  String get regenerateRecipePromptTitle => 'Regenerar Receta';

  @override
  String get regenerateRecipePromptSubtitle =>
      '¿Estás seguro de que deseas regenerar esta receta?';

  @override
  String get regenerateRecipeNotePrefix => 'Nota: ';

  @override
  String get regenerateRecipeNoteText =>
      'Esto consumirá tu cuota de generación.';

  @override
  String get regenerateNotesHint =>
      '¿Algún requerimiento especial? (ej. mas proteína)';

  @override
  String get regenerateRecipeButtonTitle => 'Regenerar';

  @override
  String get selectDatesTitle => 'Seleccionar Fechas';

  @override
  String get selectDatesSubtitle => 'Elige las fechas para tu plan de comidas.';

  @override
  String get confirmSelectionAction => 'Confirmar Selección';

  @override
  String get pantryOtherCategory => 'Otros';

  @override
  String get pantryAddTooltip => 'Agregar a Despensa';

  @override
  String get pantryEmptyTitle => 'Tu despensa está vacía.';

  @override
  String get pantryEmptySubtitle => 'Agrega artículos para llevar registro.';

  @override
  String get addItemQuantityInvalid => 'Cantidad ingresada inválida.';

  @override
  String get pantryNoDate => 'Sin fecha de caducidad';

  @override
  String pantryEditTitle(Object ingredientName) {
    return 'Editar $ingredientName';
  }

  @override
  String get pantryQuantityLabel => 'Cantidad';

  @override
  String get pantryExpiryLabel => 'Fecha de Caducidad';

  @override
  String get save => 'Guardar';

  @override
  String get pantryItemExpired => 'Caducado';

  @override
  String get pantryExpiringSoon => 'Próximo a vencer';

  @override
  String get pantryStatusValid => 'Vigente';

  @override
  String get pantryDeleteDialogTitle => 'Eliminar Artículo';

  @override
  String pantryDeleteDialogMessage(Object ingredientName) {
    return '¿Estás seguro de que deseas eliminar $ingredientName de tu despensa?';
  }

  @override
  String get addItemDefaultUnit => 'piezas';

  @override
  String get addItemErrorAdding => 'Error al agregar el artículo.';

  @override
  String get addItemTitlePantry => 'Agregar a Despensa';

  @override
  String get addItemTitleGrocery => 'Agregar a Lista de Compras';

  @override
  String get addItemIngredientNameLabel => 'Nombre del Artículo';

  @override
  String get addItemIngredientNamePantryHint => 'Ej. Leche';

  @override
  String get addItemIngredientNameGroceryHint => 'Ej. Pan';

  @override
  String get addItemIngredientNameRequired =>
      'El nombre del artículo es requerido.';

  @override
  String get addItemQuantityLabel => 'Cantidad';

  @override
  String get addItemQuantityRequired => 'La cantidad es requerida.';

  @override
  String get addItemUnitLabel => 'Unidad';

  @override
  String get addItemUnitHint => 'Ej. kg, litros';

  @override
  String get addItemCategoryLabel => 'Categoría';

  @override
  String get addItemCategoryHint => 'Seleccionar categoría';

  @override
  String get addItemExpiryLabel => 'Fecha de Caducidad';

  @override
  String get addItemButtonPantry => 'Agregar a Despensa';

  @override
  String get addItemButtonGrocery => 'Agregar a Lista de Compras';

  @override
  String pantryCountLabel(Object count) {
    return '$count artículos en despensa';
  }

  @override
  String get groceryListDetailPendingHeader => 'Artículos Pendientes';

  @override
  String get groceryListDetailCompletedHeader => 'Artículos Completados';

  @override
  String get groceryListDetailEmptyTitle => 'Esta lista está vacía.';

  @override
  String get groceryListDetailEmptySubtitle =>
      'Agrega artículos con el botón +.';

  @override
  String get groceryItemInPantry => 'En Despensa';

  @override
  String get groceryItemEditTooltip => 'Editar Artículo';

  @override
  String get editQuantityDialogTitle => 'Editar Cantidad';

  @override
  String get grocerySectionTitle => 'Compras';

  @override
  String get groceryListsTab => 'Listas';

  @override
  String get pantryTab => 'Despensa';

  @override
  String get groceryListsErrorLoading => 'Error al cargar las listas.';

  @override
  String get groceryListsEmptyTitle => 'No se encontraron listas.';

  @override
  String get groceryListsEmptySubtitle => 'Crea tu primera lista de compras.';

  @override
  String get deleteGroceryListDialogTitle => 'Eliminar Lista';

  @override
  String deleteGroceryListDialogMessage(Object listName) {
    return '¿Estás seguro de que deseas eliminar $listName?';
  }

  @override
  String get profilePlanFreeBadge => 'Plan Gratis';

  @override
  String get homeWeekLabel => 'Esta Semana';

  @override
  String greeting(Object name) {
    return '¡Hola, $name!';
  }

  @override
  String get homeTodayPlanReady => 'Tu plan del día está listo.';

  @override
  String get homeViewRecipeShort => 'Ver';

  @override
  String get homeEatOutAction => 'Comer Fuera';

  @override
  String get homeSkipMealQuestion => '¿Saltar Comida?';

  @override
  String get homeSkipMealDescription =>
      '¿Estás seguro de que deseas saltar esta comida?';

  @override
  String get homeConfirmAction => 'Confirmar';

  @override
  String get homeFavoritesAction => 'Favoritos';

  @override
  String get homeProgressAction => 'Progreso';

  @override
  String get homeEmptyPlanTitle => 'No hay planes para hoy.';

  @override
  String get homeEmptyPlanMessage =>
      '¡Crea un nuevo plan o disfruta tu día libre!';

  @override
  String get averageAbbr => 'prom';

  @override
  String get selectGroceryListEmpty =>
      'No tienes listas de compras. Crea una nueva.';

  @override
  String get selectGroceryListNewList => 'Crear Nueva Lista';

  @override
  String get mealPlanHistory => 'Historial';

  @override
  String get planEntriesTitle => 'Entradas del Plan';

  @override
  String get noEntriesInPlan => 'No se encontraron entradas en este plan.';

  @override
  String get myPlansTitle => 'Mis Planes';

  @override
  String get createNewPlanTooltip => 'Crear nuevo plan';

  @override
  String get noPlansAddedTitle => 'Aún no hay planes.';

  @override
  String get noPlansAddedMessage =>
      'Comienza tu viaje generando un nuevo plan de comidas.';

  @override
  String get tryAgain => 'Intentar de nuevo';

  @override
  String days(Object count) {
    return '$count días';
  }

  @override
  String get approvePlanEndDate => 'Fecha de fin desconocida';

  @override
  String get nutritionFilterDaily => 'Diario';

  @override
  String get nutritionFilterWeekly => 'Semanal';

  @override
  String get nutritionFilterMonthly => 'Mensual';

  @override
  String get nutritionErrorLoading => 'Error al cargar datos nutricionales.';

  @override
  String get achievementsTitle => 'Logros';

  @override
  String get weeklyActivityTitle => 'Actividad Semanal';

  @override
  String get dailyTotalsTitle => 'Totales Diarios';

  @override
  String get mondayToSundayLabel => 'LUN - DOM';

  @override
  String get mealPlanActionViewDetails => 'Ver Detalles';

  @override
  String get planDeletedSuccess => 'Plan eliminado.';

  @override
  String get planBadgeAI => 'GENERADO CON IA';

  @override
  String get planBadgeCustom => 'PERSONALIZADO';

  @override
  String get cookingProgress => 'PROGRESO DE LA RECETA';

  @override
  String stepOfTotal(Object current, Object total) {
    return 'Paso $current de $total';
  }

  @override
  String percentCompleted(Object percent) {
    return '$percent% completado';
  }

  @override
  String get neededForThisStep => 'Necesitas para este paso';

  @override
  String get mainIngredientSubtitle => 'Ingrediente principal';

  @override
  String get neededToolSubtitle => 'Utensilio necesario';

  @override
  String get nextStepAction => 'Siguiente paso';

  @override
  String get finishRecipeAction => 'Finalizar receta';

  @override
  String get recipeCompletedSnack =>
      '¡Receta completada y descontada de la despensa!';

  @override
  String recipeCompletedMissingSnack(Object count) {
    return 'Receta completada. Faltaron $count ingredientes en la despensa.';
  }

  @override
  String get timerLabel => 'TEMPORIZADOR';

  @override
  String get checkYourInbox => 'Revisa tu bandeja de entrada';

  @override
  String get otpVerificationMessage =>
      'Hemos enviado un código de verificación de 6 dígitos a tu nueva dirección de correo electrónico. Por favor, ingrésalo a continuación para completar el cambio.';

  @override
  String get otpRequestMessage =>
      'Ingresa tu nueva dirección de correo electrónico. Te enviaremos un código de verificación para asegurarnos de que eres tú.';

  @override
  String get newEmailAddressLabel => 'Nueva cuenta de correo';

  @override
  String get newEmailPlaceholder => 'nombre@ejemplo.com';

  @override
  String get didntReceiveCode => '¿No recibiste el código?';

  @override
  String get resendAction => 'Reenviar';

  @override
  String get secureVerificationNote => 'Verificación segura mediante SageAuth';

  @override
  String get saveSelectionAction => 'Guardar selección';

  @override
  String get premiumLearnMore => 'Saber más';

  @override
  String get swapFavoriteTitle => 'Cambiar por Favorita';

  @override
  String get myFavoriteRecipes => 'MIS RECETAS FAVORITAS';

  @override
  String get servingsShortLabel => 'serv';

  @override
  String get peopleLabel => 'Personas';

  @override
  String get likedFoodsLabel => 'Comidas que te gustan';

  @override
  String get dislikedFoodsLabel => 'Comidas que no te gustan';

  @override
  String get addLabel => 'Añadir';

  @override
  String get kcalLabel => 'Kcal';

  @override
  String get metricCarbsShort => 'Carbohidratos';

  @override
  String get timeLabelUpper => 'TIEMPO';

  @override
  String get servingsLabelUpper => 'PORCIONES';

  @override
  String get caloriesLabelUpper => 'CALORÍAS';

  @override
  String get nutritionPerServing => 'Nutrición por porción';

  @override
  String itemsCount(Object count) {
    return '$count ingredientes';
  }

  @override
  String get servingShort => 'porción';

  @override
  String get organizeFavoritesSubtitle =>
      'Organiza tus recetas e ingredientes favoritos';

  @override
  String get medicalDisclaimer =>
      'Esta aplicación no constituye un consejo médico profesional. La IA puede cometer errores en las recetas y el usuario es responsable de verificar los ingredientes frente a sus alergias.';

  @override
  String get authWelcomeTitle => 'Bienvenido a tu nueva alimentación';

  @override
  String get authWelcomeSubtitle =>
      'Nutrición personalizada y planificación de comidas simple para un estilo de vida saludable.';

  @override
  String get authLegalConsent =>
      'Al continuar, aceptas nuestros Términos de Servicio y Política de Privacidad.';

  @override
  String get authSignUpSubtitle =>
      'Introduce tus datos para comenzar tu plan nutricional personalizado';

  @override
  String get authLoginSubtitle =>
      'Tu camino hacia una mejor nutrición comienza aquí';

  @override
  String get authLoginDivider => 'O USA TU CORREO';

  @override
  String get authVerifyAccountTitle => 'Verifica tu cuenta';

  @override
  String get authWelcome => 'Bienvenido';

  @override
  String get authWelcomeBackTitle => 'Bienvenido de nuevo';

  @override
  String get authResendCode => 'Enviar de nuevo';

  @override
  String get otpVerifyNotReceived => '¿No recibiste el código?';

  @override
  String get dietarySubtitle =>
      'Selecciona tu estilo de alimentación principal para que podamos adaptar tus recetas.';

  @override
  String get allergiesSubtitle =>
      'Cuéntanos sobre cualquier alergia o intolerancia que debamos evitar.';

  @override
  String get foodPreferencesSubtitle =>
      'Cuéntanos sobre tus gustos para que podamos personalizar tu experiencia culinaria.';

  @override
  String get goalsSubtitle =>
      'Selecciona tus principales objetivos nutricionales para optimizar tu plan de comidas.';

  @override
  String get cookingDetailsSubtitle =>
      'Cuéntanos sobre tu estilo de cocina y el tamaño de tu hogar.';

  @override
  String get namePlaceholder => 'Tu nombre completo';

  @override
  String get monthJan => 'Ene';

  @override
  String get monthFeb => 'Feb';

  @override
  String get monthMar => 'Mar';

  @override
  String get monthApr => 'Abr';

  @override
  String get monthMay => 'May';

  @override
  String get monthJun => 'Jun';

  @override
  String get monthJul => 'Jul';

  @override
  String get monthAug => 'Ago';

  @override
  String get monthSep => 'Sep';

  @override
  String get monthOct => 'Oct';

  @override
  String get monthNov => 'Nov';

  @override
  String get monthDec => 'Dic';

  @override
  String get breakdownTabCreate => 'Crear';
}
