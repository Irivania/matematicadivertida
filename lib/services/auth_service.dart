import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Ajustado: Instância com escopos explícitos para evitar erros de construtor
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: [
      'email',
      'https://www.googleapis.com/auth/userinfo.profile',
    ],
  );

  // 1. Login com Google
  Future<bool> entrarComGoogle() async {
    try {
      // Inicia o processo de login no navegador/janela
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        print("Login cancelado pelo usuário.");
        return false;
      }

      // Obtém os tokens de autenticação
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // Cria a credencial para o Firebase usando os tokens obtidos
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Autentica no Firebase
      UserCredential userCredential = await _auth.signInWithCredential(credential);
      User? user = userCredential.user;

      if (user != null) {
        // Salva ou atualiza os dados básicos no Firestore
        // SetOptions(merge: true) impede que o campo 'perfil' seja apagado ao relogar
        await _firestore.collection('usuarios').doc(user.uid).set({
          'uid': user.uid,
          'nome': user.displayName ?? "Jogador",
          'email': user.email,
          'fotoUrl': user.photoURL,
          'data_ultima_entrada': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));

        return true;
      }
      return false;
    } catch (e) {
      print("Erro detalhado no AuthService (Google): $e");
      return false;
    }
  }

  // 2. Atualiza o Perfil (Chamada na PerfilScreen após o login)
  Future<void> atualizarPerfilUsuario(String perfilEscolhido) async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        // Define se é professor ou aluno com base na escolha do Card
        String tipoConta = (perfilEscolhido == 'professor') ? 'professor' : 'aluno';

        await _firestore.collection('usuarios').doc(user.uid).update({
          'perfil': perfilEscolhido,
          'tipo': tipoConta,
          // Garante que o campo de pontuação existe sem resetar se já houver valor
          'pontuacao_total': FieldValue.increment(0),
        });
        print("Perfil salvo: $perfilEscolhido como $tipoConta");
      }
    } catch (e) {
      print("Erro ao salvar perfil no Firestore: $e");
      rethrow;
    }
  }

  // 3. Logout Completo
  Future<void> sair() async {
    try {
      await _googleSignIn.signOut();
      await _auth.signOut();
      print("Usuário desconectado com sucesso.");
    } catch (e) {
      print("Erro ao sair: $e");
    }
  }
}