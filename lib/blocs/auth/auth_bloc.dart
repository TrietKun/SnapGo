import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:snapgo/blocs/auth/auth_event.dart';
import 'package:snapgo/blocs/auth/auth_state.dart';
import 'package:snapgo/models/user_entity.dart';
import 'package:snapgo/repositories/auth_repositories/auth_repository.dart';
import 'package:snapgo/repositories/auth_repositories/firebase_auth_repository.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _authRepository;
  final UserRepository _userRepository;

  StreamSubscription<UserEntity?>? _userSubscription;

  AuthBloc({
    required AuthRepository authRepository,
    required UserRepository userRepository,
  })  : _authRepository = authRepository,
        _userRepository = userRepository,
        super(const AuthInitial()) {
    on<AuthStarted>(_onAuthStarted);
    on<AuthLoginRequested>(_onLoginRequested);
    on<AuthSignUpRequested>(_onSignUpRequested);
    on<AuthLogoutRequested>(_onLogoutRequested);
    on<AuthUserUpdated>(_onUserUpdated);
  }

  /// Initialize auth state - Check if user is already logged in
  Future<void> _onAuthStarted(
    AuthStarted event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    try {
      // Check if user is already authenticated
      final currentUser = await _authRepository.getCurrentUser();

      if (currentUser == null) {
        emit(const AuthGuest());
        return;
      }

      // Listen to user changes
      await _userSubscription?.cancel();
      _userSubscription =
          _userRepository.getUserStream(currentUser.id).listen((user) {
        if (user != null) {
          add(AuthUserUpdated(user));
        }
      });

      emit(AuthAuthenticated(currentUser));
    } catch (e) {
      emit(AuthError(
        'Failed to initialize authentication',
        e is Exception ? e : null,
      ));
    }
  }

  /// Handle login request
  Future<void> _onLoginRequested(
    AuthLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    try {
      // Validate inputs
      if (!_isValidEmail(event.email)) {
        emit(const AuthError('Please enter a valid email address'));
        return;
      }

      if (event.password.length < 6) {
        emit(const AuthError('Password must be at least 6 characters'));
        return;
      }

      // Attempt login
      final user = await _authRepository.signInWithEmailPassword(
        email: event.email,
        password: event.password,
      );

      if (user == null) {
        emit(const AuthError('Invalid email or password'));
        return;
      }

      // Setup user stream
      await _userSubscription?.cancel();
      _userSubscription =
          _userRepository.getUserStream(user.id).listen((updatedUser) {
        if (updatedUser != null) {
          add(AuthUserUpdated(updatedUser));
        }
      });

      emit(AuthAuthenticated(user));
    } on AuthException catch (e) {
      emit(AuthError(e.message, e));
    } catch (e) {
      emit(AuthError(
        'Login failed. Please try again.',
        e is Exception ? e : null,
      ));
    }
  }

  /// Handle sign up request
  Future<void> _onSignUpRequested(
    AuthSignUpRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    try {
      // Validate inputs
      if (!_isValidEmail(event.email)) {
        emit(const AuthError('Please enter a valid email address'));
        return;
      }

      if (event.password.length < 6) {
        emit(const AuthError('Password must be at least 6 characters'));
        return;
      }

      if (event.displayName.trim().isEmpty) {
        emit(const AuthError('Please enter your display name'));
        return;
      }

      // Attempt sign up
      final user = await _authRepository.signUpWithEmailPassword(
        email: event.email,
        password: event.password,
        displayName: event.displayName,
      );

      if (user == null) {
        emit(const AuthError('Sign up failed. Please try again.'));
        return;
      }

      // Setup user stream
      await _userSubscription?.cancel();
      _userSubscription =
          _userRepository.getUserStream(user.id).listen((updatedUser) {
        if (updatedUser != null) {
          add(AuthUserUpdated(updatedUser));
        }
      });

      emit(AuthAuthenticated(user));
    } on AuthException catch (e) {
      emit(AuthError(e.message, e));
    } catch (e) {
      emit(AuthError(
        'Sign up failed. Please try again.',
        e is Exception ? e : null,
      ));
    }
  }

  /// Handle logout request
  Future<void> _onLogoutRequested(
    AuthLogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    try {
      await _userSubscription?.cancel();
      _userSubscription = null;

      await _authRepository.signOut();

      emit(const AuthGuest());
    } catch (e) {
      emit(AuthError(
        'Logout failed. Please try again.',
        e is Exception ? e : null,
      ));
    }
  }

  /// Handle user data updates
  Future<void> _onUserUpdated(
    AuthUserUpdated event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthAuthenticated(event.user));
  }

  /// Email validation helper
  bool _isValidEmail(String email) {
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(email);
  }

  @override
  Future<void> close() {
    _userSubscription?.cancel();
    return super.close();
  }
}
