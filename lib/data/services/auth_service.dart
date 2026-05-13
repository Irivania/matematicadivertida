import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart';
import '../../core/constants/app_constants.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static final GoogleSignIn _googleSignIn = GoogleSignIn(
    clientId: '5577210485-0ul1lhb99g08rsq15kk0v4r6uf54vkg8.apps.googleusercontent.com',
    scopes: ['email', 'https://www.googleapis.com/auth/userinfo.profile'],
  );

  Stream<User?> get usuarioStatus => _auth.authStateChanges();
  User? get usuarioAtual => _auth.currentUser;

  /// NOVO MÉTODO: Resolve o erro do AuthController
  /// Realiza o login anônimo para permitir que o usuário jogue sem Google de imediato
  Future<UserCredential?> entrarNoJogo() async {
    try {
      final UserCredential userCredential = await _auth.signInAnonymously();
      
      if (userCredential.user != null) {
        await _syncUserToFirestore(userCredential.user!);
      }
      return userCredential;
    } catch (e) {
      debugPrint('Erro ao entrar no jogo (Anônimo): $e');
      return null;
    }
  }

  Future<UserCredential?> entrarComGoogleCredential(AuthCredential credential) async {
    return await _auth.signInWithCredential(credential);
  }

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

      final UserCredential? userCredential = await entrarComGoogleCredential(credential);
      
      if (userCredential?.user != null) {
        await _syncUserToFirestore(userCredential!.user!);
      }
      return userCredential;
    } catch (e) {
      debugPrint('Erro no Login Google: $e');
      rethrow;
    }
  }

  Future<void> _syncUserToFirestore(User user) async {
    final userRef = _firestore.collection(AppConstants.colUsuarios).doc(user.uid);
    await userRef.set({
      'uid': user.uid,
      'email': user.email ?? 'anonimo@jogo.com',
      'nome': user.displayName ?? 'Jogador Visitante',
      'fotoUrl': user.photoURL,
      'data_ultima_entrada': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> atualizarPerfilUsuario(String perfilEscolhido) async {
    final User? user = _auth.currentUser;
    if (user == null) throw Exception("Sessão expirada.");

    final String tipoConta = (perfilEscolhido == 'professor') ? 'professor' : 'aluno';

    await _firestore.collection(AppConstants.colUsuarios).doc(user.uid).update({
      'perfil': perfilEscolhido,
      'tipo': tipoConta,
      'atualizado_em': FieldValue.serverTimestamp(),
      'fase_atual': FieldValue.increment(0),
      'nivel_atual': "Bronze", 
    });
  }

  Future<void> sair() async {
    try {
      await _googleSignIn.signOut();
    } catch (_) {}
    await _auth.signOut();
  }
}