import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/user_entity.dart';

class UserModel extends UserEntity {
  const UserModel({
    required super.uid,
    required super.email,
    super.displayName,
    super.fotoUrl,
    super.perfil,
    super.tipo,
    super.pontuacaoTotal,
    super.nivelAtual,
    super.ultimaEntrada,
  });

  /// Fábrica para converter Firestore Document em Objeto Dart (Data Mapper)
  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>?;

    if (data == null) {
      throw Exception("Dados do usuário não encontrados no documento ${doc.id}");
    }

    return UserModel(
      uid: doc.id,
      email: data['email'] ?? '',
      displayName: data['displayName'] ?? data['nome'], // Suporta ambos os campos durante a transição
      fotoUrl: data['fotoUrl'],
      // Conversão de String do banco para Enum do domínio
      perfil: PerfilUsuario.values.firstWhere(
        (e) => e.name == data['perfil'],
        orElse: () => PerfilUsuario.aluno,
      ),
      tipo: TipoUsuario.values.firstWhere(
        (e) => e.name == data['tipo'],
        orElse: () => TipoUsuario.crianca,
      ),
      pontuacaoTotal: (data['pontuacao_total'] ?? 0) as int,
      nivelAtual: (data['nivel_atual'] ?? 1) as int,
      ultimaEntrada: (data['ultima_entrada'] as Timestamp?)?.toDate(),
    );
  }

  /// Método para converter Objeto Dart em JSON para salvar no Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'email': email,
      'displayName': displayName,
      'fotoUrl': fotoUrl,
      'perfil': perfil.name, // Salva a string do enum
      'tipo': tipo.name,     // Salva a string do enum
      'pontuacao_total': pontuacaoTotal,
      'nivel_atual': nivelAtual,
      'ultima_entrada': ultimaEntrada != null ? Timestamp.fromDate(ultimaEntrada!) : FieldValue.serverTimestamp(),
      'ultima_sincronizacao': FieldValue.serverTimestamp(),
    };
  }

  /// Útil para criar um Model a partir da Entidade de domínio
  factory UserModel.fromEntity(UserEntity entity) {
    return UserModel(
      uid: entity.uid,
      email: entity.email,
      displayName: entity.displayName,
      fotoUrl: entity.fotoUrl,
      perfil: entity.perfil,
      tipo: entity.tipo,
      pontuacaoTotal: entity.pontuacaoTotal,
      nivelAtual: entity.nivelAtual,
      ultimaEntrada: entity.ultimaEntrada,
    );
  }
}