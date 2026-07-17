import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;
  bool _googleSignInInitialized = false;

  final FirebaseAuth _auth = FirebaseAuth.instance;

  Stream<User?> get usuarioStatus => _auth.authStateChanges();
  User? get usuarioAtual => _auth.currentUser;

  Future<User?> entrarAnonimamente() async => (await _auth.signInAnonymously()).user;

  Future<User?> entrarComEmailESenha(String email, String senha) async =>
      (await _auth.signInWithEmailAndPassword(email: email, password: senha)).user;

  Future<User?> cadastrarComEmailESenha(String email, String senha) async {
    final cred = await _auth.createUserWithEmailAndPassword(email: email, password: senha);
    await cred.user?.updateDisplayName(null);
    return cred.user;
  }

  Future<void> _garantirInicializacaoGoogle() async {
    if (_googleSignInInitialized) return;

    await _googleSignIn.initialize();
    _googleSignInInitialized = true;
  }

  Future<UserCredential?> entrarComGoogle() async {
    try {
      if (kIsWeb) {
        final GoogleAuthProvider googleProvider = GoogleAuthProvider();
        googleProvider.addScope('email');
        googleProvider.addScope('profile');
        return await _auth.signInWithPopup(googleProvider);
      }

      await _garantirInicializacaoGoogle();

      final GoogleSignInAccount account = await _googleSignIn.authenticate();
      final GoogleSignInAuthentication auth = await account.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        idToken: auth.idToken,
      );

      return await _auth.signInWithCredential(credential);
    } catch (e) {
      debugPrint("Erro no Google Sign-In: $e");
      return null;
    }
  }

  Future<void> atualizarDadosBasicos({String? displayName, String? photoURL}) async {
    await _auth.currentUser?.updateDisplayName(displayName);
    await _auth.currentUser?.updatePhotoURL(photoURL);
  }

  Future<void> atualizarPerfilUsuario(String perfil) async {}
  
  Future<void> enviarEmailRecuperacao(String email) async => await _auth.sendPasswordResetEmail(email: email);
  
  Future<void> sair() async { 
    await _googleSignIn.signOut(); 
    await _auth.signOut(); 
  }

  Future<void> excluirConta() async => await _auth.currentUser?.delete();
}