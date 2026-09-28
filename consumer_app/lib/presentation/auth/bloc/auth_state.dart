import 'package:equatable/equatable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../domain/models/user_profile.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {
  const AuthInitial();
}

class AuthLoading extends AuthState {
  final String? message;
  const AuthLoading({this.message});

  @override
  List<Object?> get props => [message];
}

class AuthUnauthenticated extends AuthState {
  final String? message;
  const AuthUnauthenticated({this.message});

  @override
  List<Object?> get props => [message];
}

class AuthOtpSent extends AuthState {
  final String target; // Phone or Email
  final bool isPhone;

  const AuthOtpSent({required this.target, required this.isPhone});

  @override
  List<Object?> get props => [target, isPhone];
}

class AuthAuthenticated extends AuthState {
  final User? user;
  final UserProfile? profile;

  const AuthAuthenticated({this.user, this.profile});

  @override
  List<Object?> get props => [user?.id, profile?.id];
}

class AuthProfileRequired extends AuthState {
  final User? user;
  final String? phoneOrEmail;

  const AuthProfileRequired({this.user, this.phoneOrEmail});

  @override
  List<Object?> get props => [user?.id, phoneOrEmail];
}

class AuthError extends AuthState {
  final String message;

  const AuthError(this.message);

  @override
  List<Object?> get props => [message];
}
