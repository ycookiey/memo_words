import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:memo_words/repository/auth_repository.dart';

class AuthViewModel extends StateNotifier<User?> {
  final AuthRepository _authRepository;

  AuthViewModel(this._authRepository) : super(null) {
    _authRepository.authStateChanges.listen((user) {
      state = user;
    });
  }
  Future<void> loginOrCreateAccount(String email, String password) async {
    try {
      await _authRepository.signInWithEmailAndPassword(email, password);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        createAccount(email, password);
      } else if (e.code == 'invalid-credential') {
        print('Login warning: $e');
        createAccount(email, password);
      } else {
        print('Login error: $e');
      }
    }
  }

  Future<void> createAccount(String email, String password) async {
    try {
      await _authRepository.createUserWithEmailAndPassword(email, password);
    } catch (e) {
      print('Account creation error: $e');
    }
  }

  Future<void> signOut() async {
    await _authRepository.signOut();
  }
}
