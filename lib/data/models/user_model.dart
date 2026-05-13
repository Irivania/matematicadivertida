import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/user_entity.dart';

class UserModel extends UserEntity {
  UserModel({
    required super.uid,
    required super.email,
    super.nome,
    super.fotoUrl,
    super.perfil,
    super.tipo,
    super.pontuacaoTotal,
  });

  // Fábrica para converter Firestore Document em Objeto Dart
  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel(
      uid: doc.id,
      email: data['email'] ?? '',
      nome: data['nome'],
      fotoUrl: data['fotoUrl'],
      perfil: data['perfil'],
      tipo: data['tipo'],
      pontuacaoTotal: data['pontuacao_total'] ?? 0,
    );
  }

  // Método para converter Objeto Dart em JSON para salvar no Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'email': email,
      'nome': nome,
      'fotoUrl': fotoUrl,
      'perfil': perfil,
      'tipo': tipo,
      'pontuacao_total': pontuacaoTotal,
    };
  }
}