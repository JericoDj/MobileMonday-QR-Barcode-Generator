part of 'auth_bloc.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class AuthCheckRequested extends AuthEvent {}

class AuthLoginRequested extends AuthEvent {
  final String email;
  final String password;

  const AuthLoginRequested({required this.email, required this.password});

  @override
  List<Object?> get props => [email, password];
}

class AuthRegisterRequested extends AuthEvent {
  final String email;
  final String password;
  final String? displayName;

  const AuthRegisterRequested({
    required this.email,
    required this.password,
    this.displayName,
  });

  @override
  List<Object?> get props => [email, password, displayName];
}

class AuthLogoutRequested extends AuthEvent {}

class AuthForgotPasswordRequested extends AuthEvent {
  final String email;

  const AuthForgotPasswordRequested({required this.email});

  @override
  List<Object?> get props => [email];
}

class AuthUpdateProfileRequested extends AuthEvent {
  final String? displayName;
  final String? newPassword;
  final String? avatarFilePath;

  const AuthUpdateProfileRequested({
    this.displayName,
    this.newPassword,
    this.avatarFilePath,
  });

  @override
  List<Object?> get props => [displayName, newPassword, avatarFilePath];
}

class AuthDeleteAccountRequested extends AuthEvent {}
