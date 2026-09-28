import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../services/supabase_service.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final SupabaseService _supabaseService;

  AuthBloc({SupabaseService? supabaseService})
      : _supabaseService = supabaseService ?? SupabaseService(),
        super(const AuthInitial()) {
    on<CheckAuthStatusEvent>(_onCheckAuthStatus);
    on<SendPhoneOtpEvent>(_onSendPhoneOtp);
    on<SendEmailOtpEvent>(_onSendEmailOtp);
    on<VerifyPhoneOtpEvent>(_onVerifyPhoneOtp);
    on<VerifyEmailOtpEvent>(_onVerifyEmailOtp);
    on<SignInWithPasswordEvent>(_onSignInWithPassword);
    on<SignUpWithEmailEvent>(_onSignUpWithEmail);
    on<SignInAsGuestEvent>(_onSignInAsGuest);
    on<SaveProfileEvent>(_onSaveProfile);
    on<SignOutEvent>(_onSignOut);
  }

  Future<void> _onCheckAuthStatus(
    CheckAuthStatusEvent event,
    Emitter<AuthState> emit,
  ) async {
    final user = _supabaseService.currentUser;
    if (user == null) {
      emit(const AuthUnauthenticated());
      return;
    }

    try {
      final profile = await _supabaseService.fetchUserProfile(user.id);
      if (profile == null || !profile.isProfileComplete) {
        emit(AuthProfileRequired(
          user: user,
          phoneOrEmail: user.phone ?? user.email,
        ));
      } else {
        emit(AuthAuthenticated(user: user, profile: profile));
      }
    } catch (_) {
      emit(AuthAuthenticated(user: user));
    }
  }

  Future<void> _onSendPhoneOtp(
    SendPhoneOtpEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading(message: 'Sending sacred OTP...'));
    try {
      await _supabaseService.sendPhoneOtp(event.phoneNumber);
      emit(AuthOtpSent(target: event.phoneNumber, isPhone: true));
    } catch (e) {
      emit(AuthError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onSendEmailOtp(
    SendEmailOtpEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading(message: 'Sending OTP link...'));
    try {
      await _supabaseService.sendEmailOtp(event.email);
      emit(AuthOtpSent(target: event.email, isPhone: false));
    } catch (e) {
      emit(AuthError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onVerifyPhoneOtp(
    VerifyPhoneOtpEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading(message: 'Verifying OTP code...'));
    try {
      final response = await _supabaseService.verifyPhoneOtp(
        phone: event.phoneNumber,
        token: event.token,
      );

      final user = response.user ?? _supabaseService.currentUser;
      if (user != null) {
        final profile = await _supabaseService.fetchUserProfile(user.id);
        if (profile == null || !profile.isProfileComplete) {
          emit(AuthProfileRequired(user: user, phoneOrEmail: event.phoneNumber));
        } else {
          emit(AuthAuthenticated(user: user, profile: profile));
        }
      } else {
        emit(const AuthError('Authentication failed. Please try again.'));
      }
    } catch (e) {
      emit(AuthError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onVerifyEmailOtp(
    VerifyEmailOtpEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading(message: 'Verifying token...'));
    try {
      final response = await _supabaseService.verifyEmailOtp(
        email: event.email,
        token: event.token,
      );

      final user = response.user ?? _supabaseService.currentUser;
      if (user != null) {
        final profile = await _supabaseService.fetchUserProfile(user.id);
        if (profile == null || !profile.isProfileComplete) {
          emit(AuthProfileRequired(user: user, phoneOrEmail: event.email));
        } else {
          emit(AuthAuthenticated(user: user, profile: profile));
        }
      } else {
        emit(const AuthError('Authentication failed. Please try again.'));
      }
    } catch (e) {
      emit(AuthError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onSignInWithPassword(
    SignInWithPasswordEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading(message: 'Signing in...'));
    try {
      final response = await _supabaseService.signInWithPassword(
        email: event.email,
        password: event.password,
      );

      final user = response.user ?? _supabaseService.currentUser;
      if (user != null) {
        final profile = await _supabaseService.fetchUserProfile(user.id);
        emit(AuthAuthenticated(user: user, profile: profile));
      } else {
        emit(const AuthError('Invalid credentials.'));
      }
    } catch (e) {
      emit(AuthError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onSignUpWithEmail(
    SignUpWithEmailEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading(message: 'Creating account...'));
    try {
      final response = await _supabaseService.signUpWithEmail(
        email: event.email,
        password: event.password,
      );

      final user = response.user ?? _supabaseService.currentUser;
      if (user != null) {
        emit(AuthProfileRequired(user: user, phoneOrEmail: event.email));
      } else {
        emit(const AuthUnauthenticated(
            message: 'Registration link sent. Please verify your email.'));
      }
    } catch (e) {
      emit(AuthError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onSignInAsGuest(
    SignInAsGuestEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading(message: 'Entering sacred portal...'));
    try {
      await _supabaseService.signInAsGuest();
      final user = _supabaseService.currentUser;
      final profile = user != null ? await _supabaseService.fetchUserProfile(user.id) : null;
      emit(AuthAuthenticated(user: user, profile: profile));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onSaveProfile(
    SaveProfileEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading(message: 'Saving devotional profile...'));
    try {
      final saved = await _supabaseService.saveUserProfile(event.profile);
      emit(AuthAuthenticated(
        user: _supabaseService.currentUser,
        profile: saved,
      ));
    } catch (e) {
      emit(AuthError('Failed to save profile: $e'));
    }
  }

  Future<void> _onSignOut(
    SignOutEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading(message: 'Signing out...'));
    try {
      await _supabaseService.signOut();
      emit(const AuthUnauthenticated());
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }
}
