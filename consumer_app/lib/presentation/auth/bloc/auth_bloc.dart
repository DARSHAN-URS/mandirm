import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as sb;
import '../../../domain/models/user_profile.dart';
import '../../../services/api_service.dart';
import '../../../services/supabase_service.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final SupabaseService _supabaseService;
  StreamSubscription<sb.AuthState>? _authSubscription;

  AuthBloc({SupabaseService? supabaseService})
      : _supabaseService = supabaseService ?? SupabaseService(),
        super(const AuthInitial()) {
    on<CheckAuthStatusEvent>(_onCheckAuthStatus);
    on<AuthSessionChangedEvent>(_onAuthSessionChanged);
    on<SendPhoneOtpEvent>(_onSendPhoneOtp);
    on<SendEmailOtpEvent>(_onSendEmailOtp);
    on<VerifyPhoneOtpEvent>(_onVerifyPhoneOtp);
    on<VerifyEmailOtpEvent>(_onVerifyEmailOtp);
    on<SignInWithPasswordEvent>(_onSignInWithPassword);
    on<SignUpWithEmailEvent>(_onSignUpWithEmail);
    on<SignInWithGoogleEvent>(_onSignInWithGoogle);
    on<SaveProfileEvent>(_onSaveProfile);
    on<SignOutEvent>(_onSignOut);

    // Listen to real-time auth changes from Supabase (handles OAuth redirect & session restoration)
    _authSubscription = _supabaseService.authStateChanges.listen((data) {
      final session = data.session;
      final event = data.event;
      if (event == sb.AuthChangeEvent.signedIn ||
          event == sb.AuthChangeEvent.tokenRefreshed ||
          event == sb.AuthChangeEvent.userUpdated) {
        if (session?.user != null) {
          add(AuthSessionChangedEvent(session: session, user: session!.user));
        }
      } else if (event == sb.AuthChangeEvent.signedOut) {
        add(const SignOutEvent());
      }
    });
  }

  @override
  Future<void> close() {
    _authSubscription?.cancel();
    return super.close();
  }

  Future<void> _onCheckAuthStatus(
    CheckAuthStatusEvent event,
    Emitter<AuthState> emit,
  ) async {
    final user = _supabaseService.currentUser;
    final localProfile = _supabaseService.currentProfile;

    if (user == null && localProfile == null) {
      emit(const AuthUnauthenticated());
      return;
    }

    if (user != null) {
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
        emit(AuthAuthenticated(user: user, profile: localProfile));
      }
    } else if (localProfile != null) {
      if (!localProfile.isProfileComplete) {
        emit(AuthProfileRequired(
          phoneOrEmail: localProfile.phoneNumber ?? localProfile.email,
        ));
      } else {
        emit(AuthAuthenticated(profile: localProfile));
      }
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
      emit(AuthError(_cleanErrorMessage(e)));
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
      emit(AuthError(_cleanErrorMessage(e)));
    }
  }

  Future<void> _onVerifyPhoneOtp(
    VerifyPhoneOtpEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading(message: 'Verifying OTP code...'));

    // 1. Try Supabase verification
    try {
      final response = await _supabaseService.verifyPhoneOtp(
        phone: event.phoneNumber,
        token: event.token,
      );

      final user = response.user ?? _supabaseService.currentUser;
      if (user != null) {
        final profile = await _supabaseService.fetchUserProfile(user.id);
        if (profile != null) {
          await _supabaseService.setLocalAuthenticatedUser(
            profile: profile,
            token: response.session?.accessToken,
          );
        }
        if (profile == null || !profile.isProfileComplete) {
          emit(AuthProfileRequired(user: user, phoneOrEmail: event.phoneNumber));
        } else {
          emit(AuthAuthenticated(user: user, profile: profile));
        }
        return;
      }
    } catch (e) {
      debugPrint('[AuthBloc] Supabase verifyPhoneOtp notice: $e');
    }

    // 2. Try Backend OTP verification
    try {
      final backendRes = await ApiService().verifyOtpViaBackend(
        phone: event.phoneNumber,
        otp: event.token,
      );
      if (backendRes != null && backendRes['success'] == true) {
        final userData = backendRes['user'] as Map<String, dynamic>?;
        final token = backendRes['token'] as String?;
        final profile = userData != null
            ? UserProfile.fromJson(Map<String, dynamic>.from(userData))
            : UserProfile(
                id: 'user_${event.phoneNumber.hashCode.abs()}',
                phoneNumber: event.phoneNumber,
                fullName: 'Devotee ${event.phoneNumber}',
                createdAt: DateTime.now(),
              );
        await _supabaseService.setLocalAuthenticatedUser(
          profile: profile,
          token: token,
        );
        emit(AuthAuthenticated(profile: profile));
        return;
      }
    } catch (backendErr) {
      debugPrint('[AuthBloc] Backend verifyPhoneOtp notice: $backendErr');
    }

    // 3. Fallback for test OTP 123456
    if (event.token.trim() == '123456') {
      final formatted = event.phoneNumber.trim();
      final devProfile = UserProfile(
        id: 'dev_${formatted.hashCode.abs()}',
        phoneNumber: formatted,
        fullName: 'Devotee $formatted',
        createdAt: DateTime.now(),
      );
      await _supabaseService.setLocalAuthenticatedUser(
        profile: devProfile,
        token: 'dev_token_${devProfile.id}',
      );
      emit(AuthAuthenticated(profile: devProfile));
      return;
    }

    emit(const AuthError('Incorrect or expired code. Please try again or test with 123456.'));
  }

  Future<void> _onVerifyEmailOtp(
    VerifyEmailOtpEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading(message: 'Verifying token...'));

    // 1. Try Supabase verification
    try {
      final response = await _supabaseService.verifyEmailOtp(
        email: event.email,
        token: event.token,
      );

      final user = response.user ?? _supabaseService.currentUser;
      if (user != null) {
        final profile = await _supabaseService.fetchUserProfile(user.id);
        if (profile != null) {
          await _supabaseService.setLocalAuthenticatedUser(
            profile: profile,
            token: response.session?.accessToken,
          );
        }
        if (profile == null || !profile.isProfileComplete) {
          emit(AuthProfileRequired(user: user, phoneOrEmail: event.email));
        } else {
          emit(AuthAuthenticated(user: user, profile: profile));
        }
        return;
      }
    } catch (e) {
      debugPrint('[AuthBloc] Supabase verifyEmailOtp notice: $e');
    }

    // 2. Try Backend OTP verification
    try {
      final backendRes = await ApiService().verifyOtpViaBackend(
        email: event.email,
        otp: event.token,
      );
      if (backendRes != null && backendRes['success'] == true) {
        final userData = backendRes['user'] as Map<String, dynamic>?;
        final token = backendRes['token'] as String?;
        final profile = userData != null
            ? UserProfile.fromJson(Map<String, dynamic>.from(userData))
            : UserProfile(
                id: 'user_${event.email.hashCode.abs()}',
                email: event.email,
                fullName: event.email.split('@')[0].toUpperCase(),
                createdAt: DateTime.now(),
              );
        await _supabaseService.setLocalAuthenticatedUser(
          profile: profile,
          token: token,
        );
        emit(AuthAuthenticated(profile: profile));
        return;
      }
    } catch (backendErr) {
      debugPrint('[AuthBloc] Backend verifyEmailOtp notice: $backendErr');
    }

    // 3. Fallback for test OTP 123456
    if (event.token.trim() == '123456') {
      final cleanEmail = event.email.trim().toLowerCase();
      final devProfile = UserProfile(
        id: 'dev_${cleanEmail.hashCode.abs()}',
        email: cleanEmail,
        fullName: cleanEmail.split('@')[0].toUpperCase(),
        createdAt: DateTime.now(),
      );
      await _supabaseService.setLocalAuthenticatedUser(
        profile: devProfile,
        token: 'dev_token_${devProfile.id}',
      );
      emit(AuthAuthenticated(profile: devProfile));
      return;
    }

    emit(const AuthError('Incorrect or expired code. Please try again or test with 123456.'));
  }

  String _cleanErrorMessage(dynamic error) {
    final str = error.toString();
    if (str.contains('Error sending magic link email') ||
        str.contains('unexpected_failure')) {
      return 'Email limit reached on Supabase free tier (max 3/hr without custom SMTP). Please sign in with Google or use test OTP 123456.';
    }
    if (str.contains('rate_limit') || str.contains('over_email_send_rate_limit')) {
      return 'Email rate limit reached. Please use Google Sign In or wait a few minutes.';
    }
    if (str.contains('Invalid OTP') || str.contains('otp_expired')) {
      return 'Incorrect or expired code. Please try again or test with 123456.';
    }
    return str
        .replaceAll('AuthRetryableFetchException(message: ', '')
        .replaceAll('AuthException: ', '')
        .replaceAll('Exception: ', '')
        .replaceAll('}', '')
        .replaceAll('{', '')
        .replaceAll('"', '');
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

  Future<void> _onAuthSessionChanged(
    AuthSessionChangedEvent event,
    Emitter<AuthState> emit,
  ) async {
    final user = (event.user as sb.User?) ?? _supabaseService.currentUser;
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

  Future<void> _onSignInWithGoogle(
    SignInWithGoogleEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading(message: 'Connecting to Google with Supabase...'));
    try {
      final launched = await _supabaseService.signInWithGoogle();
      if (!launched) {
        emit(const AuthError('Unable to launch Google Sign-In. Please check your browser.'));
        return;
      }
      final user = _supabaseService.currentUser;
      if (user != null) {
        final profile = await _supabaseService.fetchUserProfile(user.id);
        emit(AuthAuthenticated(user: user, profile: profile));
      }
      // If user is null, the web OAuth view is open in the browser.
      // Once Google signs in, the _authSubscription listener will catch
      // AuthChangeEvent.signedIn and dispatch AuthSessionChangedEvent to complete authentication!
    } catch (e) {
      emit(AuthError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onSaveProfile(
    SaveProfileEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading(message: 'Saving devotional profile...'));
    try {
      final saved = await _supabaseService.saveUserProfile(event.profile);
      await _supabaseService.setLocalAuthenticatedUser(profile: saved);
      emit(AuthAuthenticated(
        user: _supabaseService.currentUser,
        profile: saved,
      ));
    } catch (e) {
      await _supabaseService.setLocalAuthenticatedUser(profile: event.profile);
      emit(AuthAuthenticated(
        user: _supabaseService.currentUser,
        profile: event.profile,
      ));
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
