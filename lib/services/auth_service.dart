import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  User? get currentUser => _auth.currentUser;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  bool get isLoggedIn => currentUser != null;

  Future<String?> getIdToken({bool forceRefresh = false}) async {
    final user = currentUser;
    if (user == null) return null;
    
    try {
      return await user.getIdToken(forceRefresh);
    } catch (e) {
      print('Error getting ID token: $e');
      return null;
    }
  }

  Future<UserCredential> signInAnonymously() async {
    return await _auth.signInAnonymously();
  }

  Future<UserCredential> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    return await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<UserCredential> createUserWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    return await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  String? get displayName => currentUser?.displayName;

  String? get email => currentUser?.email;

  String? get photoURL => currentUser?.photoURL;

  String? get uid => currentUser?.uid;
}

