import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:my_firebase_app/core/services/auth_service.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthService _authService;

  AuthBloc(this._authService) : super(AuthInitial()) {
    // Check Authentication Status
    on<AuthCheckRequested>((event, emit) async {
      User? user = _authService.currentUser; // ✅ Corrected line
      if (user != null) {
        emit(AuthSuccess(user));
      } else {
        emit(AuthFailure("User not logged in"));
      }
    });

    // Login
    on<LoginRequested>((event, emit) async {
      emit(AuthLoading());
      User? user = await _authService.signIn(event.email, event.password);
      if (user != null) {
        emit(AuthSuccess(user));
      } else {
        emit(AuthFailure("Invalid email or password"));
      }
    });

    // Logout
    on<LogoutRequested>((event, emit) async {
      await _authService.signOut();
      emit(
          AuthInitial()); // ✅ Ensures AuthWrapper rebuilds and redirects to LoginScreen
    });

    on<SignUpRequested>((event, emit) async {
      emit(AuthLoading());
      try {
        await _authService.signUp(event.email, event.password);
        User? user = _authService.currentUser; // Fetch the newly created user
        if (user != null) {
          emit(AuthSuccess(user));
        } else {
          emit(AuthFailure("User creation failed"));
        }
      } catch (e) {
        emit(AuthFailure(e.toString()));
      }
    });
  }
}
