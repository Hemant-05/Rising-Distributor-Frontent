part of 'auth_bloc.dart';

abstract class UserEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class AppStarted extends UserEvent {}

class UserLoggedIn extends UserEvent {
  final AppUser user;
  UserLoggedIn(this.user);
  @override
  List<Object?> get props => [user];
}

class UserLocation extends UserEvent {
  final String uid;
  UserLocation(this.uid);
}

class AddLocation extends UserEvent{
  final Map<String,dynamic> model;
  AddLocation({required this.model});
}

class DeleteLocation extends UserEvent{
  final int addressId;
  DeleteLocation({required this.addressId});
}

class GetLocationList extends UserEvent{}

class UserLoggedOut extends UserEvent {}

class SendVerificationCode extends UserEvent {
  final String email;
  SendVerificationCode(this.email);
  @override
  List<Object?> get props => [email];
}

class ResetPassword extends UserEvent {
  final String email, password, confirmPassword,code;
  ResetPassword({
    required this.code,
    required this.email,
    required this.password,
    required this.confirmPassword,
  });
  @override
  List<Object?> get props => [email, password, confirmPassword];
}

class UserSignUp extends UserEvent {
  final String name, email, password,confirmPassword;
  final String role;
  UserSignUp({
    required this.name,
    required this.email,
    required this.password,
    required this.confirmPassword,
    required this.role,
  });
  @override
  List<Object?> get props => [name, email, password, role];
}

class UserSignIn extends UserEvent {
  final String email, password;
  final bool rememberMe;
  UserSignIn(this.email, this.password, this.rememberMe);
  @override
  List<Object?> get props => [email, password];
}

class RegisterNumber extends UserEvent{
  final String number;
  RegisterNumber(this.number);
}

class VerifyOtp extends UserEvent{
  final dynamic otp;
  final String verificationId;
  final String phoneNumber;
  VerifyOtp(this.otp,this.verificationId,this.phoneNumber);
}

class UserGoogleSignIn extends UserEvent {}
