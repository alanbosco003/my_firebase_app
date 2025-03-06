part of 'auth_bloc.dart';

abstract class AuthEvent extends Equatable {
  @override
  List<Object> get props => [];
}

// Login Event
class LoginRequested extends AuthEvent {
  final String email;
  final String password;

  LoginRequested(this.email, this.password);

  @override
  List<Object> get props => [email, password];
}

// Logout Event
class LogoutRequested extends AuthEvent {}

// New: Check Authentication Status Event
class AuthCheckRequested extends AuthEvent {}
