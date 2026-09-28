import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/constants/app_constants.dart';
import '../domain/models/user_profile.dart';

class SupabaseService {
  static final SupabaseService _instance = SupabaseService._internal();
  factory SupabaseService() => _instance;
  SupabaseService._internal();

  SupabaseClient? _client;
  bool _isMockMode = false;
  UserProfile? _mockProfile;
  final StreamController<AuthState> _mockAuthStream =
      StreamController<AuthState>.broadcast();

  bool get isMockMode => _isMockMode;
  SupabaseClient get client {
    if (_client == null) {
      throw StateError('Supabase has not been initialized. Call initialize() first.');
    }
    return _client!;
  }

  Future<void> initialize() async {
    const url = AppConstants.supabaseUrl;
    const anonKey = AppConstants.supabaseAnonKey;

    final isPlaceholder = url.contains('placeholder') || anonKey.contains('placeholder');

    if (isPlaceholder) {
      debugPrint('[SupabaseService] Running in Dev/Demo mode (placeholder credentials detected)');
      _isMockMode = true;
      await _loadLocalMockSession();
      return;
    }

    try {
      await Supabase.initialize(
        url: url,
        // ignore: deprecated_member_use
        anonKey: anonKey,
        authOptions: const FlutterAuthClientOptions(
          authFlowType: AuthFlowType.pkce,
        ),
      );
      _client = Supabase.instance.client;
      debugPrint('[SupabaseService] Supabase initialized successfully!');
    } catch (e) {
      debugPrint('[SupabaseService] Supabase init failed: $e. Falling back to Dev mode.');
      _isMockMode = true;
      await _loadLocalMockSession();
    }
  }

  Stream<AuthState> get authStateChanges {
    if (_isMockMode || _client == null) {
      return _mockAuthStream.stream;
    }
    return _client!.auth.onAuthStateChange;
  }

  User? get currentUser {
    if (_isMockMode) {
      if (_mockProfile != null) {
        return User(
          id: _mockProfile!.id,
          appMetadata: {},
          userMetadata: {
            'full_name': _mockProfile!.fullName,
            'phone': _mockProfile!.phoneNumber,
          },
          aud: 'authenticated',
          createdAt: _mockProfile!.createdAt?.toIso8601String() ??
              DateTime.now().toIso8601String(),
        );
      }
      return null;
    }
    return _client?.auth.currentUser;
  }

  bool get isAuthenticated => currentUser != null;

  // Send OTP to Phone
  Future<void> sendPhoneOtp(String phoneNumber) async {
    if (_isMockMode || _client == null) {
      debugPrint('[Dev Mode] OTP sent to $phoneNumber (Use OTP: 123456 to test)');
      return;
    }

    await _client!.auth.signInWithOtp(
      phone: phoneNumber,
    );
  }

  // Send OTP or Magic Link to Email
  Future<void> sendEmailOtp(String email) async {
    if (_isMockMode || _client == null) {
      debugPrint('[Dev Mode] OTP sent to $email (Use OTP: 123456 to test)');
      return;
    }

    await _client!.auth.signInWithOtp(
      email: email,
    );
  }

  // Verify Phone OTP
  Future<AuthResponse> verifyPhoneOtp({
    required String phone,
    required String token,
  }) async {
    if (_isMockMode || _client == null) {
      if (token == '123456' || token.length == 6) {
        final mockUser = User(
          id: 'dev-user-${phone.replaceAll(RegExp(r'\D'), '')}',
          appMetadata: {},
          userMetadata: {'phone': phone},
          aud: 'authenticated',
          createdAt: DateTime.now().toIso8601String(),
        );
        _mockProfile = UserProfile(
          id: mockUser.id,
          phoneNumber: phone,
          fullName: 'Sadhak Bhakt',
          createdAt: DateTime.now(),
        );
        await _saveLocalMockSession(_mockProfile!);
        return AuthResponse(
          session: Session(
            accessToken: 'mock-token',
            tokenType: 'bearer',
            user: mockUser,
          ),
          user: mockUser,
        );
      } else {
        throw const AuthException('Invalid OTP. For testing, please enter 123456.');
      }
    }

    return await _client!.auth.verifyOTP(
      phone: phone,
      token: token,
      type: OtpType.sms,
    );
  }

  // Verify Email OTP
  Future<AuthResponse> verifyEmailOtp({
    required String email,
    required String token,
  }) async {
    if (_isMockMode || _client == null) {
      if (token == '123456' || token.length == 6) {
        final mockUser = User(
          id: 'dev-user-${email.hashCode.abs()}',
          appMetadata: {},
          userMetadata: {'email': email},
          aud: 'authenticated',
          createdAt: DateTime.now().toIso8601String(),
        );
        _mockProfile = UserProfile(
          id: mockUser.id,
          email: email,
          fullName: 'Devotee Guest',
          createdAt: DateTime.now(),
        );
        await _saveLocalMockSession(_mockProfile!);
        return AuthResponse(
          session: Session(
            accessToken: 'mock-token',
            tokenType: 'bearer',
            user: mockUser,
          ),
          user: mockUser,
        );
      } else {
        throw const AuthException('Invalid OTP. For testing, please enter 123456.');
      }
    }

    return await _client!.auth.verifyOTP(
      email: email,
      token: token,
      type: OtpType.email,
    );
  }

  // Email & Password Sign In
  Future<AuthResponse> signInWithPassword({
    required String email,
    required String password,
  }) async {
    if (_isMockMode || _client == null) {
      final mockUser = User(
        id: 'dev-user-${email.hashCode.abs()}',
        appMetadata: {},
        userMetadata: {'email': email},
        aud: 'authenticated',
        createdAt: DateTime.now().toIso8601String(),
      );
      _mockProfile = UserProfile(
        id: mockUser.id,
        email: email,
        fullName: 'Devotee Guest',
        createdAt: DateTime.now(),
      );
      await _saveLocalMockSession(_mockProfile!);
      return AuthResponse(
        session: Session(
          accessToken: 'mock-token',
          tokenType: 'bearer',
          user: mockUser,
        ),
        user: mockUser,
      );
    }

    return await _client!.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  // Email & Password Sign Up
  Future<AuthResponse> signUpWithEmail({
    required String email,
    required String password,
  }) async {
    if (_isMockMode || _client == null) {
      final mockUser = User(
        id: 'dev-user-${email.hashCode.abs()}',
        appMetadata: {},
        userMetadata: {'email': email},
        aud: 'authenticated',
        createdAt: DateTime.now().toIso8601String(),
      );
      _mockProfile = UserProfile(
        id: mockUser.id,
        email: email,
        createdAt: DateTime.now(),
      );
      await _saveLocalMockSession(_mockProfile!);
      return AuthResponse(
        session: Session(
          accessToken: 'mock-token',
          tokenType: 'bearer',
          user: mockUser,
        ),
        user: mockUser,
      );
    }

    return await _client!.auth.signUp(
      email: email,
      password: password,
    );
  }

  // Quick Guest / Demo Devotee Login
  Future<void> signInAsGuest() async {
    final mockUser = User(
      id: 'guest-bhakt-108',
      appMetadata: {},
      userMetadata: {'full_name': 'Guest Bhakt'},
      aud: 'authenticated',
      createdAt: DateTime.now().toIso8601String(),
    );
    _mockProfile = UserProfile(
      id: mockUser.id,
      fullName: 'Darshan Bhakt',
      phoneNumber: '+919876543210',
      gotra: 'Kashyap',
      rashi: 'Mesh (Aries)',
      createdAt: DateTime.now(),
    );
    await _saveLocalMockSession(_mockProfile!);
  }

  // Sign Out
  Future<void> signOut() async {
    if (_isMockMode || _client == null) {
      _mockProfile = null;
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(AppConstants.keyUserProfile);
      return;
    }
    await _client!.auth.signOut();
  }

  // Fetch User Profile from 'profiles' table
  Future<UserProfile?> fetchUserProfile(String userId) async {
    if (_isMockMode || _client == null) {
      return _mockProfile;
    }

    try {
      final data = await _client!
          .from('profiles')
          .select()
          .eq('id', userId)
          .maybeSingle();

      if (data == null) return null;
      return UserProfile.fromJson(data);
    } catch (e) {
      debugPrint('[SupabaseService] Error fetching profile: $e');
      return null;
    }
  }

  // Upsert User Profile
  Future<UserProfile> saveUserProfile(UserProfile profile) async {
    if (_isMockMode || _client == null) {
      _mockProfile = profile;
      await _saveLocalMockSession(profile);
      return profile;
    }

    await _client!.from('profiles').upsert(profile.toJson());
    return profile;
  }

  Future<void> _saveLocalMockSession(UserProfile profile) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.keyUserProfile, profile.id);
  }

  Future<void> _loadLocalMockSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final id = prefs.getString(AppConstants.keyUserProfile);
      if (id != null) {
        _mockProfile = UserProfile(
          id: id,
          fullName: 'Darshan Bhakt',
          phoneNumber: '+919876543210',
          gotra: 'Kashyap',
          rashi: 'Mesh (Aries)',
          createdAt: DateTime.now(),
        );
      }
    } catch (e) {
      debugPrint('[SupabaseService] Could not restore local mock session: $e');
    }
  }
}
