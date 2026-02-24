abstract class AppError implements Exception {
  final String message;
  final String? code;

  const AppError(this.message, {this.code});

  @override
  String toString() =>
      '$runtimeType: $message${code != null ? ' (Code: $code)' : ''}';
}

/// Exception for errors related to authentication.
class AuthAppError extends AppError {
  const AuthAppError(super.message, {super.code});

  const AuthAppError.invalidCredentials()
    : super(
        'Invalid credentials. Please check your email and password.',
        code: 'AUTH_INVALID_CREDENTIALS',
      );
  const AuthAppError.emailNotVerified()
    : super(
        'Your email has not been verified. Please check your inbox.',
        code: 'AUTH_EMAIL_NOT_VERIFIED',
      );
  const AuthAppError.userNotFound()
    : super('User not found.', code: 'AUTH_USER_NOT_FOUND');
  const AuthAppError.emailAlreadyInUse()
    : super('This email is already registered.', code: 'AUTH_EMAIL_IN_USE');
  const AuthAppError.passwordResetFailed()
    : super(
        'Could not reset password. Please try again later.',
        code: 'AUTH_PASSWORD_RESET_FAILED',
      );
  const AuthAppError.resendVerificationFailed()
    : super(
        'Could not resend verification email.',
        code: 'AUTH_RESEND_VERIFICATION_FAILED',
      );
  const AuthAppError.invalidOtp()
    : super(
        'The code you entered is invalid or has expired.',
        code: 'AUTH_INVALID_OTP',
      );
  const AuthAppError.unexpected({String? message})
    : super(
        message ?? 'An unexpected authentication error occurred.',
        code: 'AUTH_UNEXPECTED',
      );
  const AuthAppError.emailConfirmationMismatch()
    : super(
        'Email confirmation does not match.',
        code: 'AUTH_EMAIL_CONFIRMATION_MISMATCH',
      );
}

/// Exception for errors related to the network.
class NetworkAppError extends AppError {
  const NetworkAppError(super.message, {super.code});

  const NetworkAppError.timeout()
    : super(
        'The request timed out. Please check your internet connection.',
        code: 'NETWORK_TIMEOUT',
      );
  const NetworkAppError.noConnection()
    : super(
        'No internet connection. Please connect and try again.',
        code: 'NETWORK_NO_CONNECTION',
      );
  const NetworkAppError.serverError()
    : super(
        'Server error. Please try again later.',
        code: 'NETWORK_SERVER_ERROR',
      );
  const NetworkAppError.badResponse({String? details})
    : super(
        'Unexpected response from the server${details != null ? ': $details' : ''}.',
        code: 'NETWORK_BAD_RESPONSE',
      );
  const NetworkAppError.unreachableHost()
    : super(
        'Cannot reach the server. Check the host, port, or VPN.',
        code: 'NETWORK_UNREACHABLE_HOST',
      );
  const NetworkAppError.sslError()
    : super('Secure connection failed (SSL/TLS).', code: 'NETWORK_SSL_ERROR');
  const NetworkAppError.tooManyRequests()
    : super(
        'Too many requests. Please wait and try again.',
        code: 'NETWORK_RATE_LIMIT',
      );
  const NetworkAppError.badRequest({String? details})
    : super(
        'Request rejected by server${details != null ? ': $details' : ''}.',
        code: 'NETWORK_BAD_REQUEST',
      );
}

/// Exception for errors related to data handling.
class DataAppError extends AppError {
  const DataAppError(super.message, {super.code});

  const DataAppError.notFound(String entity)
    : super('$entity not found.', code: 'DATA_NOT_FOUND');
  const DataAppError.invalidData(String details)
    : super('Invalid data: $details', code: 'DATA_INVALID');
  const DataAppError.creationFailed(String entity)
    : super('Failed to create $entity.', code: 'DATA_CREATION_FAILED');
  const DataAppError.updateFailed(String entity)
    : super('Failed to update $entity.', code: 'DATA_UPDATE_FAILED');
  const DataAppError.fetchFailed(String entity)
    : super('Failed to fetch $entity.', code: 'DATA_FETCH_FAILED');
  const DataAppError.serializationFailed(String entity)
    : super('Failed to parse $entity data.', code: 'DATA_SERIALIZATION_FAILED');
  const DataAppError.emptyResponse(String entity)
    : super('$entity response was empty.', code: 'DATA_EMPTY_RESPONSE');
  const DataAppError.uniqueViolation(String entity)
    : super('Unique violation in $entity.', code: 'DATA_UNIQUE_VIOLATION');
  const DataAppError.queryError()
    : super('Database query failed.', code: 'DATA_QUERY_ERROR');
  const DataAppError.mappingError()
    : super('Error mapping data.', code: 'DATA_MAPPING_ERROR');
}

/// Exception for errors related to permissions.
class PermissionAppError extends AppError {
  const PermissionAppError(super.message, {super.code});

  const PermissionAppError.unauthorized()
    : super(
        'Unauthorized. Please sign in again.',
        code: 'PERMISSION_UNAUTHORIZED',
      );
  const PermissionAppError.forbidden()
    : super(
        'You do not have permission to perform this action.',
        code: 'PERMISSION_FORBIDDEN',
      );
}

/// Exception for configuration issues (env vars, keys, etc.).
class ConfigAppError extends AppError {
  const ConfigAppError(super.message, {super.code});

  const ConfigAppError.missing(String key)
    : super('Configuration missing: $key is not set.', code: 'CONFIG_MISSING');
  const ConfigAppError.invalid(String key)
    : super(
        'Configuration invalid: $key value is not valid.',
        code: 'CONFIG_INVALID',
      );
}

/// Exception for errors related to meal plan rules and generation.
class MealPlanAppError extends AppError {
  const MealPlanAppError(super.message, {super.code});

  const MealPlanAppError.notAuthenticated()
    : super('User not authenticated.', code: 'MEAL_PLAN_NOT_AUTHENTICATED');
  const MealPlanAppError.daysNotAllowed()
    : super('Number of days not allowed.', code: 'MEAL_PLAN_DAYS_NOT_ALLOWED');
  const MealPlanAppError.typesNotAllowed()
    : super('Meal types not allowed.', code: 'MEAL_PLAN_TYPES_NOT_ALLOWED');
  const MealPlanAppError.generateFailed()
    : super(
        'Could not generate the plan. Please try again.',
        code: 'MEAL_PLAN_GENERATE_FAILED',
      );
  const MealPlanAppError.quotaReached()
    : super(
        'You have run out of plan generations this week.',
        code: 'MEAL_PLAN_QUOTA_REACHED',
      );
}
