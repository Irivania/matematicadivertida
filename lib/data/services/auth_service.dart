import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // Expõe o fluxo do estado de autenticação em tempo real
  Stream<User?> get usuarioStatus => _auth.authStateChanges();

  // Retorna o usuário atual logado no Firebase
  User? get usuarioAtual => _auth.currentUser;

  // Entrada em modo anônimo (Convidado)
  Future<User?> entrarAnonimamente() async {
    final userCredential = await _auth.signInAnonymously();
    return userCredential.user;
  }

  // Login com e-mail e senha tradicional
  Future<User?> entrarComEmailESenha(String email, String senha) async {
    final userCredential = await _auth.signInWithEmailAndPassword(
      email: email, 
      password: senha,
    );
    return userCredential.user;
  }

  // Cadastro de novas credenciais
  Future<User?> cadastrarComEmailESenha(String email, String senha) async {
    final userCredential = await _auth.createUserWithEmailAndPassword(
      email: email, 
      password: senha,
    );
    return userCredential.user;
  }

  // Autenticação rápida com o Google Sign-In
  Future<UserCredential?> entrarComGoogle() async {
    final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
    if (googleUser == null) return null;

    final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
    final OAuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    return await _auth.signInWithCredential(credential);
  }

  // Atualização cadastral básica do Firebase Auth
  Future<void> atualizarDadosBasicos({String? displayName, String? photoURL}) async {
    final user = _auth.currentUser;
    if (user != null) {
      if (displayName != null) await user.updateDisplayName(displayName);
      if (photoURL != null) await user.updatePhotoURL(photoURL);
    }
  }

  // Espaço reservado para atualizar perfis extras (ex: Aluno/Professor)
  Future<void> atualizarPerfilUsuario(String perfil) async {
    // Caso pretenda persistir o perfil pedagógico diretamente no Firestore futuramente,
    // a chamada ou injeção do serviço do banco de dados entrará aqui.
  }

  // Disparo de e-mail para redefinição de credenciais
  Future<void> enviarEmailRecuperacao(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  // Encerramento completo de sessões ativas
  Future<void> sair() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }

  // Exclusão definitiva de conta do usuário
  Future<void> excluirConta() async {
    final user = _auth.currentUser;
    if (user != null) {
      await user.delete();
    }
  }
}