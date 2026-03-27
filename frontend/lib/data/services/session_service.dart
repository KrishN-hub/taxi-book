class SessionService {
  SessionService._();
  static final SessionService instance = SessionService._();

  String? backendToken;
  String selectedRole = 'passenger';
}
