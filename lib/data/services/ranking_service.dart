import 'package:cloud_firestore/cloud_firestore.dart';

class RankingService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Salvar ou atualizar o recorde do usuário na nuvem
  Future<void> salvarPontuacaoGlobal({
    required String uid,
    required String nome,
    required String nivel,
    required int tempo,
  }) async {
    try {
      final docRef = _db.collection('ranking').doc('${uid}_$nivel');
      
      // Verifica se já existe um recorde melhor antes de substituir
      final docSnapshot = await docRef.get();
      if (docSnapshot.exists) {
        int tempoAnterior = docSnapshot.data()?['tempo'] ?? 999999;
        if (tempo >= tempoAnterior) return; // Se o anterior for melhor, não faz nada
      }

      await docRef.set({
        'uid': uid,
        'nome': nome,
        'nivel': nivel,
        'tempo': tempo,
        'data': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print("Erro ao salvar ranking global: $e");
    }
  }

  // Buscar o ranking global ordenado por menor tempo
  Future<List<Map<String, dynamic>>> buscarRankingGlobal() async {
    try {
      final querySnapshot = await _db
          .collection('ranking')
          .orderBy('tempo', descending: false)
          .limit(10) // Pega os top 10
          .get();

      return querySnapshot.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      print("Erro ao buscar ranking: $e");
      return [];
    }
  }
}