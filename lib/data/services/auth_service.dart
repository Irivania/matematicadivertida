// lib/data/services/auth_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart';
import '../../core/constants/app_constants.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Em 2026, usamos variáveis de ambiente ou o GoogleService-Info.plist/json
  // para gerenciar ClientIDs, evitando hardcoding.
  static final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
  );

  Stream<User?> get usuarioStatus => _auth.authStateChanges();
  User? get usuarioAtual => _auth.currentUser;

  /// Login Anônimo com identificação de hardware (opcional para evitar spam)
  Future<UserCredential?> entrarNoJogo() async {
    try {
      final UserCredential userCredential = await _auth.signInAnonymously();
      
      if (userCredential.user != null) {
        // Inicializa apenas dados básicos. Privilégios são via Security Rules.
        await _initializeUserRecord(userCredential.user!);
      }
      return userCredential;
    } on FirebaseAuthException catch (e) {
      debugPrint('Erro Autenticação Anônima: ${e.code}');
      rethrow;
    }
  }

  Future<UserCredential?> entrarComGoogle() async {
    try {
      // No Web, garantir que o estado anterior não interfira
      if (kIsWeb) await _googleSignIn.signOut();

      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null;

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential = await _auth.signInWithCredential(credential);
      
      if (userCredential.user != null) {
        await _initializeUserRecord(userCredential.user!);
      }
      return userCredential;
    } catch (e) {
      debugPrint('Falha Crítica no Login Google: $e');
      rethrow; 
    }
  }

  /// Inicialização Segura: Usa merge para não sobrescrever dados sensíveis
  /// que podem ter sido definidos via Admin SDK ou Cloud Functions.
  Future<void> _initializeUserRecord(User user) async {
    final userRef = _firestore.collection(AppConstants.colUsuarios).doc(user.uid);
    
    // Usamos serverTimestamp() para evitar fraudes de horário local do celular
    await userRef.set({
      'uid': user.uid,
      'email': user.email,
      'is_anonymous': user.isAnonymous,
      'metadata': {
        'last_login': FieldValue.serverTimestamp(),
        'created_at': FieldValue.serverTimestamp(), // Firestore Rules impedirão alteração posterior
      }
    }, SetOptions(merge: true));
  }

  Future<void> atualizarPerfilUsuario(String perfilEscolhido) async {
    final User? user = _auth.currentUser;
    if (user == null) throw Exception("Sessão inválida.");

    // Validação de Domínio no Service
    final allowedProfiles = ['aluno', 'professor'];
    if (!allowedProfiles.contains(perfilEscolhido)) {
      throw Exception("Perfil inválido.");
    }

    await _firestore.collection(AppConstants.colUsuarios).doc(user.uid).update({
      'perfil': perfilEscolhido,
      'config': {
        'atualizado_em': FieldValue.serverTimestamp(),
        'setup_complete': true,
      }
    });
  }

  Future<void> sair() async {
    try {
      if (!kIsWeb) await _googleSignIn.signOut();
      await _auth.signOut();
    } catch (e) {
      debugPrint('Erro ao encerrar sessão: $e');
    }
  }
}