import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // REFORÇO: ClientId inserido diretamente para evitar falhas no Flutter Web
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    clientId: '5577210485-0ul1lhb99g08rsq15kk0v4r6uf54vkg8.apps.googleusercontent.com',
    scopes: [
      'email',
      'https://www.googleapis.com/auth/userinfo.profile',
    ],
  );

  // 1. Login com Google (Ajustado para lidar com o tempo de resposta do celular)
  Future<bool> entrarComGoogle() async {
    try {
      // Tenta primeiro o login silencioso (caso o usuário já tenha logado antes)
      GoogleSignInAccount? googleUser = await _googleSignIn.signInSilently();
      
      // Se não houver sessão ativa, abre o pop-up
      googleUser ??= await _googleSignIn.signIn();

      if (googleUser == null) {
        print("Login cancelado: O usuário fechou a janela ou o tempo expirou.");
        return false;
      }

      // Pequena pausa técnica: Dá tempo ao navegador para processar o retorno do celular
      await Future.delayed(const Duration(milliseconds: 500));

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Autentica no Firebase
      UserCredential userCredential = await _auth.signInWithCredential(credential);
      User? user = userCredential.user;

      if (user != null) {
        // Grava no Firestore (SetOptions permite atualizar sem apagar dados antigos)
        await _firestore.collection('usuarios').doc(user.uid).set({
          'uid': user.uid,
          'nome': user.displayName ?? "Jogador",
          'email': user.email,
          'fotoUrl': user.photoURL,
          'data_ultima_entrada': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));

        print("Usuário autenticado com sucesso: ${user.displayName}");
        return true;
      }
      return false;
    } catch (e) {
      print("ERRO DETALHADO NO LOGIN: $e");
      return false;
    }
  }

  // 2. Atualiza o Perfil (Professor ou Aluno)
  Future<void> atualizarPerfilUsuario(String perfilEscolhido) async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        String tipoConta = (perfilEscolhido == 'professor') ? 'professor' : 'aluno';

        await _firestore.collection('usuarios').doc(user.uid).update({
          'perfil': perfilEscolhido,
          'tipo': tipoConta,
          // FieldValue.increment(0) garante que o campo exista sem resetar a pontuação
          'pontuacao_total': FieldValue.increment(0),
        });
        print("Perfil atualizado: $perfilEscolhido");
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
      print("Usuário desconectado.");
    } catch (e) {
      print("Erro ao sair: $e");
    }
  }
}