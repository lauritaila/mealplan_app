import 'package:meal_plan_app/config/errors/app_errors.dart';
import 'package:meal_plan_app/l10n/app_localizations.dart';

String localizeAppError(
  AppLocalizations l10n,
  AppError error, {
  String? fallback,
}) {
  return localizeErrorCode(
    l10n,
    error.code,
    fallback: fallback ?? error.message,
  );
}

String localizeErrorCode(
  AppLocalizations l10n,
  String? code, {
  String? fallback,
}) {
  switch (code) {
    case 'AUTH_INVALID_CREDENTIALS':
      return l10n.errorAuthInvalidCredentials;
    case 'AUTH_EMAIL_NOT_VERIFIED':
      return l10n.errorAuthEmailNotVerified;
    case 'AUTH_USER_NOT_FOUND':
      return l10n.errorAuthUserNotFound;
    case 'AUTH_EMAIL_IN_USE':
      return l10n.errorAuthEmailInUse;
    case 'AUTH_PASSWORD_RESET_FAILED':
      return l10n.errorAuthPasswordResetFailed;
    case 'AUTH_RESEND_VERIFICATION_FAILED':
      return l10n.errorAuthResendVerificationFailed;
    case 'AUTH_INVALID_OTP':
      return l10n.errorAuthInvalidOtp;
    case 'AUTH_UNEXPECTED':
      return l10n.errorAuthUnexpected;
    case 'AUTH_GOOGLE_SIGN_IN_FAILED':
      return l10n.errorAuthGoogleSignInFailed;
    case 'AUTH_SEND_OTP_FAILED':
      return l10n.errorAuthSendOtpFailed;
    case 'NETWORK_TIMEOUT':
      return l10n.errorNetworkTimeout;
    case 'NETWORK_NO_CONNECTION':
      return l10n.errorNetworkNoConnection;
    case 'NETWORK_SERVER_ERROR':
      return l10n.errorNetworkServer;
    case 'NETWORK_BAD_RESPONSE':
      return l10n.errorNetworkBadResponse;
    case 'NETWORK_UNREACHABLE_HOST':
      return l10n.errorNetworkUnreachableHost;
    case 'NETWORK_SSL_ERROR':
      return l10n.errorNetworkSsl;
    case 'NETWORK_RATE_LIMIT':
      return l10n.errorNetworkRateLimit;
    case 'NETWORK_BAD_REQUEST':
      return l10n.errorNetworkBadRequest;
    case 'DATA_NOT_FOUND':
      return l10n.errorDataNotFound;
    case 'DATA_INVALID':
      return l10n.errorDataInvalid;
    case 'DATA_CREATION_FAILED':
      return l10n.errorDataCreationFailed;
    case 'DATA_UPDATE_FAILED':
      return l10n.errorDataUpdateFailed;
    case 'DATA_FETCH_FAILED':
      return l10n.errorDataFetchFailed;
    case 'DATA_SERIALIZATION_FAILED':
      return l10n.errorDataSerializationFailed;
    case 'DATA_EMPTY_RESPONSE':
      return l10n.errorDataEmptyResponse;
    case 'PERMISSION_UNAUTHORIZED':
      return l10n.errorPermissionUnauthorized;
    case 'PERMISSION_FORBIDDEN':
      return l10n.errorPermissionForbidden;
    case 'CONFIG_MISSING':
      return l10n.errorConfigMissing;
    case 'CONFIG_INVALID':
      return l10n.errorConfigInvalid;
    case 'MEAL_PLAN_NOT_AUTHENTICATED':
      return l10n.errorMealPlanNotAuthenticated;
    case 'MEAL_PLAN_DAYS_NOT_ALLOWED':
      return l10n.errorMealPlanDaysNotAllowed;
    case 'MEAL_PLAN_TYPES_NOT_ALLOWED':
      return l10n.errorMealPlanTypesNotAllowed;
    case 'MEAL_PLAN_GENERATE_FAILED':
      return l10n.errorMealPlanGenerateFailed;
    case 'MEAL_PLAN_QUOTA_REACHED':
      return l10n.errorMealPlanQuotaReached;
    case 'ERROR_SAVE_PREFERENCES_ROLLBACK_FAILED':
      return l10n.errorSavePreferencesRollbackFailed;
    default:
      return fallback ?? l10n.genericError;
  }
}
