import 'package:firebase_auth/firebase_auth.dart';

/// Interface para o Repositório de Autenticação.
/// Define as regras de negócio de login e logout.
abstract class IAuthRepository {
  Stream<User?> get userState;
  Future<UserCredential?> signInWithGoogle();
  Future<void> signOut();
  Future<void> updateProfileRole(String role);
}