abstract class AuthEvent {}

class AppStarted extends AuthEvent {}

class LoginSubmitted extends AuthEvent {
  final String email;
  final String password;

  LoginSubmitted({required this.email, required this.password});
}

class RegisterSubmitted extends AuthEvent {
  final String name;
  final String email;
  final String password;

  RegisterSubmitted({required this.name, required this.email, required this.password});
}

class LoggedOut extends AuthEvent {}
