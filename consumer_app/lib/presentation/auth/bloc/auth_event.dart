import 'package:equatable/equatable.dart';
import '../../../domain/models/user_profile.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class CheckAuthStatusEvent extends AuthEvent {
  const CheckAuthStatusEvent();
}

class SendPhoneOtpEvent extends AuthEvent {
  final String phoneNumber;
  const SendPhoneOtpEvent(this.phoneNumber);

  @override
  List<Object?> get props => [phoneNumber];
}

class SendEmailOtpEvent extends AuthEvent {
  final String email;
  const SendEmailOtpEvent(this.email);

  @override
  List<Object?> get props => [email];
}

class VerifyPhoneOtpEvent extends AuthEvent {
  final String phoneNumber;
  final String token;
  const VerifyPhoneOtpEvent({required this.phoneNumber, required this.token});

  @override
  List<Object?> get props => [phoneNumber, token];
}

class VerifyEmailOtpEvent extends AuthEvent {
  final String email;
  final String token;
  const VerifyEmailOtpEvent({required this.email, required this.token});

  @override
  List<Object?> get props => [email, token];
}

class SignInWithPasswordEvent extends AuthEvent {
  final String email;
  final String password;
  const SignInWithPasswordEvent({required this.email, required this.password});

  @override
  List<Object?> get props => [email, password];
}

class SignUpWithEmailEvent extends AuthEvent {
  final String email;
  final String password;
  const SignUpWithEmailEvent({required this.email, required this.password});

  @override
  List<Object?> get props => [email, password];
}

class SignInWithGoogleEvent extends AuthEvent {
  const SignInWithGoogleEvent();
}

class SaveProfileEvent extends AuthEvent {
  final UserProfile profile;
  const SaveProfileEvent(this.profile);

  @override
  List<Object?> get props => [profile];
}

class SignOutEvent extends AuthEvent {
  const SignOutEvent();
}

class AuthSessionChangedEvent extends AuthEvent {
  final dynamic session;
  final dynamic user;
  const AuthSessionChangedEvent({this.session, this.user});

  @override
  List<Object?> get props => [session, user];
}
