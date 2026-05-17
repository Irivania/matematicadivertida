import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart';
import '../../core/constants/app_constants.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Gerenciamento centralizado do Google Sign-In
  static final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
  );

  // Streams e Getters para monitoramento de estado
  Stream<User?> get usuarioStatus => _auth.authStateChanges();
  User? get usuarioAtual => _auth.currentUser;

  /// Login Anônimo
  Future<User?> entrarAnonimamente() async {
    try {
      final UserCredential userCredential = await _auth.signInAnonymously();
      
      if (userCredential.user != null) {
        await _initializeUserRecord(userCredential.user!);
      }
      return userCredential.user;
    } on FirebaseAuthException {
      rethrow;
    }
  }

  /// Autenticação via Google
  Future<UserCredential?> entrarComGoogle() async {
    try {
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

  // =========================================================================
  // MÓDULO DE E-MAIL E SENHA CORRIGIDO (APIS OFICIAIS DO FIREBASE)
  // =========================================================================

  /// Realiza login utilizando e-mail e senha no Firebase Auth.
  Future<User?> entrarComEmailESenha(String email, String senha) async {
    try {
      // CORREÇÃO: Ajustado de 'senha:' para 'password:' (padrão da biblioteca)
      final UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: senha,
      );

      if (userCredential.user != null) {
        await _initializeUserRecord(userCredential.user!);
      }
      return userCredential.user;
    } on FirebaseAuthException {
      rethrow; // Repassa para o AuthRepositoryImpl tratar as mensagens de UI
    }
  }

  /// Cadastra um novo registro de usuário com e-mail e senha no Firebase Auth.
  Future<User?> cadastrarComEmailESenha(String email, String senha) async {
    try {
      // CORREÇÃO: Ajustado para o nome de método oficial 'createUserWithEmailAndPassword'
      // CORREÇÃO: Ajustado de 'senha:' para 'password:'
      final UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: senha,
      );

      if (userCredential.user != null) {
        await _initializeUserRecord(userCredential.user!);
      }
      return userCredential.user;
    } on FirebaseAuthException {
      rethrow;
    }
  }

  /// Dispara o e-mail oficial de redefinição de senha do Firebase.
  Future<void> enviarEmailRecuperacao(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException {
      rethrow;
    }
  }

  // =========================================================================
  // LOGICA DE SINCRONIZAÇÃO E METADADOS DO FIRESTORE
  // =========================================================================

  /// Inicialização no Firestore com merge para preservar dados de gamificação
  Future<void> _initializeUserRecord(User user) async {
    final userRef = _firestore.collection(AppConstants.colUsuarios).doc(user.uid);
    
    await userRef.set({
      'uid': user.uid,
      'email': user.email,
      'displayName': user.displayName,
      'is_anonymous': user.isAnonymous,
      'metadata': {
        'last_login': FieldValue.serverTimestamp(),
      }
    }, SetOptions(merge: true));
  }

  /// Método para atualização de dados básicos (Exigido pelo Repository)
  Future<void> atualizarDadosBasicos({String? displayName, String? photoURL}) async {
    final User? user = _auth.currentUser;
    if (user == null) return;

    // Atualiza no Firebase Auth
    if (displayName != null) await user.updateDisplayName(displayName);
    if (photoURL != null) await user.updatePhotoURL(photoURL);

    // Sincroniza com o Firestore
    await _firestore.collection(AppConstants.colUsuarios).doc(user.uid).update({
      'displayName': displayName ?? user.displayName,
      'fotoUrl': photoURL ?? user.photoURL,
      'metadata.last_update': FieldValue.serverTimestamp(),
    });
  }

  /// Método específico para trocar perfil (Professor/Aluno)
  Future<void> atualizarPerfilUsuario(String perfilEscolhido) async {
    final User? user = _auth.currentUser;
    if (user == null) throw Exception("Sessão inválida.");

    await _firestore.collection(AppConstants.colUsuarios).doc(user.uid).update({
      'perfil': perfilEscolhido,
      'config.setup_complete': true,
      'config.atualizado_em': FieldValue.serverTimestamp(),
    });
  }

  /// Exclusão de conta (Exigido pelo Repository)
  Future<void> excluirConta() async {
    final User? user = _auth.currentUser;
    if (user == null) return;

    // Remove do Firestore antes de deletar a Auth
    await _firestore.collection(AppConstants.colUsuarios).doc(user.uid).delete();
    await user.delete();
  }

  /// Logout
  Future<void> sair() async {
    try {
      await _googleSignIn.signOut();
      await _auth.signOut();
    } catch (e) {
      debugPrint('Erro ao encerrar sessão: $e');
    }
  }
}