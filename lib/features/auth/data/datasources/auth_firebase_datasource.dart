import 'package:firebase_auth/firebase_auth.dart';
import 'package:games_app/core/error/exceptions.dart';

abstract class AuthFirebaseDataSource {
  Future<User> signInWithEmailAndPassword({
    required String email,
    required String password,
  });

  Future<User> createUserWithEmailAndPassword({
    required String email,
    required String password,
  });

  Future<void> signOut();

  User? getCurrentFirebaseUser();

  Stream<User?> watchAuthState();

  Future<String> getIdToken({bool forceRefresh = false});
}

class AuthFirebaseDataSourceImpl implements AuthFirebaseDataSource {
  final FirebaseAuth firebaseAuth;

  AuthFirebaseDataSourceImpl({required this.firebaseAuth});

  @override
  Future<User> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user == null) {
        throw ServerException('Failed to sign in');
      }

      return credential.user!;
    } on FirebaseAuthException catch (e) {
      throw ServerException(_mapFirebaseAuthError(e));
    } catch (e) {
      throw ServerException('Failed to sign in: ${e.toString()}');
    }
  }

  @override
  Future<User> createUserWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user == null) {
        throw ServerException('Failed to create user');
      }

      return credential.user!;
    } on FirebaseAuthException catch (e) {
      throw ServerException(_mapFirebaseAuthError(e));
    } catch (e) {
      throw ServerException('Failed to create user: ${e.toString()}');
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await firebaseAuth.signOut();
    } catch (e) {
      throw ServerException('Failed to sign out: ${e.toString()}');
    }
  }

  @override
  User? getCurrentFirebaseUser() {
    return firebaseAuth.currentUser;
  }

  @override
  Stream<User?> watchAuthState() {
    return firebaseAuth.authStateChanges();
  }

  @override
  Future<String> getIdToken({bool forceRefresh = false}) async {
    try {
      final user = firebaseAuth.currentUser;
      if (user == null) {
        throw ServerException('No authenticated user');
      }

      final token = await user.getIdToken(forceRefresh);
      if (token == null) {
        throw ServerException('Failed to get ID token');
      }

      return token;
    } catch (e) {
      throw ServerException('Failed to get ID token: ${e.toString()}');
    }
  }

  String _mapFirebaseAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No user found with this email';
      case 'wrong-password':
        return 'Incorrect password';
      case 'email-already-in-use':
        return 'Email is already in use';
      case 'weak-password':
        return 'Password is too weak';
      case 'invalid-email':
        return 'Invalid email address';
      case 'user-disabled':
        return 'This account has been disabled';
      case 'too-many-requests':
        return 'Too many requests. Please try again later';
      case 'operation-not-allowed':
        return 'Operation not allowed';
      default:
        return e.message ?? 'Authentication failed';
    }
  }
}

