// lib/data/services/ranking_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RankingService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> salvarPontuacaoGlobal({
    required String uid,
    required String nome,
    required String nivel,
    required String perfil, // <--- Adicionado parâmetro do perfil
    required int tempo,
  }) async {
    try {
      final docRef = _db.collection('ranking').doc('${uid}_$nivel');
      
      final docSnapshot = await docRef.get();
      if (docSnapshot.exists) {
        int tempoAnterior = docSnapshot.data()?['tempo'] ?? 999999;
        if (tempo >= tempoAnterior) return; 
      }

      await docRef.set({
        'uid': uid,
        'nome': nome,
        'nivel': nivel,
        'perfil': perfil, // <--- Salvando o perfil no Firestore
        'tempo': tempo,
        'data': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print("Erro ao salvar ranking global: $e");
    }
  }

  Future<List<Map<String, dynamic>>> buscarRankingGlobal() async {
    try {
      final querySnapshot = await _db
          .collection('ranking')
          .orderBy('tempo', descending: false)
          .limit(10)
          .get();

      return querySnapshot.docs.map((doc) {
        var data = doc.data();
        data['isMe'] = (FirebaseAuth.instance.currentUser?.uid != null) && 
                       (data['uid'].toString().contains(FirebaseAuth.instance.currentUser!.uid));
        
        // Garante que o campo perfil venha mapeado (ou vazio caso seja um registro antigo)
        data['perfil'] = data['perfil'] ?? ''; 
        
        return data;
      }).toList();
    } catch (e) {
      print("Erro ao buscar ranking: $e");
      return [];
    }
  }
}