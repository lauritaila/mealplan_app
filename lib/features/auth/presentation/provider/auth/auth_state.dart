import 'package:meal_plan_app/features/auth/domain/domain.dart';
import 'package:equatable/equatable.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

class InitialAuthState extends AuthState {
  const InitialAuthState();
}

class LoadingAuthState extends AuthState {
  final String? message;
  const LoadingAuthState({this.message});
  @override
  List<Object?> get props => [message];
}

class AuthenticatedAuthState extends AuthState {
  final UserProfile user;
  final bool showGraceWelcome;
  const AuthenticatedAuthState(this.user, {this.showGraceWelcome = false});
  @override
  List<Object?> get props => [user, showGraceWelcome];
}

class UnauthenticatedAuthState extends AuthState {
  const UnauthenticatedAuthState();
}

class ErrorAuthState extends AuthState {
  final String? message;
  final String? code;
  const ErrorAuthState({this.message, this.code});
  @override
  List<Object?> get props => [message, code];
}

class MessageAuthState extends AuthState {
  final String message;
  const MessageAuthState(this.message);
  @override
  List<Object?> get props => [message];
}

class AwaitingEmailVerificationAuthState extends AuthState {
  final String email;
  const AwaitingEmailVerificationAuthState(this.email);
  @override
  List<Object?> get props => [email];
}

class AwaitingOtpInputState extends AuthState {
  final String email;
  final String? errorMessage;
  final String? errorCode;
  final bool cameFromGracePeriod;
  const AwaitingOtpInputState(
    this.email, {
    this.errorMessage,
    this.errorCode,
    this.cameFromGracePeriod = false,
  });
  @override
  List<Object?> get props => [
    email,
    errorMessage,
    errorCode,
    cameFromGracePeriod,
  ];
}
