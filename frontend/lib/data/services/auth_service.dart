import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  AuthService._();

  static final instance = AuthService._();
  FirebaseAuth? get _authOrNull {
    try {
      return FirebaseAuth.instance;
    } catch (_) {
      return null;
    }
  }

  User? get currentUser => _authOrNull?.currentUser;

  Stream<User?> authStateChanges() {
    final auth = _authOrNull;
    if (auth == null) return const Stream<User?>.empty();
    return auth.authStateChanges();
  }

  Future<UserCredential> signIn({
    required String email,
    required String password,
  }) {
    final auth = _authOrNull;
    if (auth == null) {
      throw Exception('Firebase is not configured yet. Run flutterfire configure.');
    }
    return auth.signInWithEmailAndPassword(email: email, password: password);
  }

  Future<UserCredential> signUp({
    required String email,
    required String password,
  }) {
    final auth = _authOrNull;
    if (auth == null) {
      throw Exception('Firebase is not configured yet. Run flutterfire configure.');
    }
    return auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<void> signOut() async {
    final auth = _authOrNull;
    if (auth != null) await auth.signOut();
  }

  Future<String?> getIdToken() async {
    return _authOrNull?.currentUser?.getIdToken();
  }
}
