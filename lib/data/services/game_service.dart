import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/constants/app_constants.dart';

class GameService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // =====================================================
  // 🏆 PERSISTÊNCIA DE PARTIDAS E RANKING
  // =====================================================

  /// Salva o resultado de uma partida no histórico e atualiza a pontuação global.
  Future<void> salvarResultadoPartida({
    required String userId,
    required int acertos,
    required int erros,
    required String dificuldade,
    int? faseConcluida, // Parâmetro opcional para vincular à fase da trilha
  }) async {
    try {
      final historicoRef = _firestore
          .collection(AppConstants.colUsuarios)
          .doc(userId)
          .collection('historico_partidas');

      await historicoRef.add({
        'acertos': acertos,
        'erros': erros,
        'dificuldade': dificuldade,
        'fase': faseConcluida,
        'data_hora': FieldValue.serverTimestamp(),
      });

      // Atualiza a pontuação global (XP)
      await _atualizarPontuacaoGlobal(userId, acertos);
      
      // Se uma fase foi concluída com sucesso, atualiza o status na trilha
      if (faseConcluida != null && acertos > erros) {
        await atualizarFaseAtual(userId, faseConcluida + 1);
      }
    } catch (e) {
      throw Exception("Erro ao salvar resultado: $e");
    }
  }

  /// Incrementa a pontuação total do jogador.
  Future<void> _atualizarPontuacaoGlobal(String userId, int pontosGanhos) async {
    final userRef = _firestore.collection(AppConstants.colUsuarios).doc(userId);
    
    await userRef.update({
      'pontuacao_total': FieldValue.increment(pontosGanhos),
      'ultima_partida_em': FieldValue.serverTimestamp(),
    });
  }

  // =====================================================
  // 🗺️ PROGRESSO NA TRILHA (CONEXÃO COM TRILHASCREEN)
  // =====================================================

  /// Atualiza a fase em que o usuário se encontra na trilha.
  Future<void> atualizarFaseAtual(String userId, int novaFase) async {
    try {
      final userRef = _firestore.collection(AppConstants.colUsuarios).doc(userId);
      
      // Determinamos o nível textual baseando-se na fase (ex: 1-3 Bronze)
      String nivel = _mapearFaseParaNivel(novaFase);

      await userRef.update({
        'fase_atual': novaFase,
        'nivel_atual': nivel,
      });
    } catch (e) {
      throw Exception("Erro ao atualizar fase: $e");
    }
  }

  /// Helper para converter o número da fase no nome do nível para o PerguntaService
  String _mapearFaseParaNivel(int fase) {
    if (fase <= 3) return "Bronze";
    if (fase <= 6) return "Prata";
    if (fase <= 9) return "Ouro";
    if (fase <= 12) return "Platina";
    return "Mestre";
  }

  // =====================================================
  // 🔍 BUSCA DE DADOS E GAMIFICAÇÃO
  // =====================================================

  /// Busca o Ranking Global (Top 10).
  Stream<QuerySnapshot> obterRankingGlobal() {
    return _firestore
        .collection(AppConstants.colUsuarios)
        .orderBy('pontuacao_total', descending: true)
        .limit(10)
        .snapshots();
  }

  /// Recupera o progresso completo do usuário.
  Future<DocumentSnapshot> obterProgressoUsuario(String userId) async {
    return await _firestore
        .collection(AppConstants.colUsuarios)
        .doc(userId)
        .get();
  }

  /// Stream para monitorar mudanças no progresso em tempo real (XP, Nível).
  Stream<DocumentSnapshot> monitorarProgresso(String userId) {
    return _firestore
        .collection(AppConstants.colUsuarios)
        .doc(userId)
        .snapshots();
  }
}