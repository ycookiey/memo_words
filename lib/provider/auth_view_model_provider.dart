import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:memo_words/repository/auth_repository.dart';
import 'package:memo_words/view_model/auth_view_model.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(FirebaseAuth.instance);
});

final authViewModelProvider =
    StateNotifierProvider<AuthViewModel, User?>((ref) {
  return AuthViewModel(ref.read(authRepositoryProvider));
});
