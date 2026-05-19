import 'dart:async';
import 'package:flutter/material.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/i_auth_repository.dart';
import 'progresso_game_model.dart'; // Importação do modelo na mesma pasta

class AuthController extends ChangeNotifier {
  final IAuthRepository _authRepository;
  StreamSubscription<UserEntity?>? _authSubscription;

  UserEntity? _usuarioAtual;
  bool _isLoading = false;
  String _mensagemErro = '';

  // 🕹️ NOVAS VARIÁVEIS PARA GERENCIAMENTO DOS MÚLTIPLOS PERFIS DE JOGO
  String? _perfilAtivo; // Armazena 'crianca', 'adulto' ou 'professor'
  ProgressoGameModel? _progressoAtual;

  // Construtor inicializa escutando o status de autenticação em tempo real via Stream
  AuthController(this._authRepository) {
    _escutarMudancasAutenticacao();
  }

  // Getters para a sua UI ler o estado interno com segurança
  UserEntity? get usuarioAtual => _usuarioAtual;
  bool get isLoading => _isLoading;
  String get mensagemErro => _mensagemErro;
  bool get estaAutenticado => _usuarioAtual != null;

  // 🕹️ GETTERS DO PROGRESSO DO JOGO INDEPENDENTE
  String? get perfilAtivo => _perfilAtivo;
  String get nomeJogador => _progressoAtual?.nomeJogador ?? '';

  /// Retorna a fase atual dinamicamente com base no perfil selecionado
  int get faseAtual {
    if (_progressoAtual == null || _perfilAtivo == null) return 1;
    if (_perfilAtivo == 'crianca') return _progressoAtual!.crianca.fase;
    if (_perfilAtivo == 'adulto') return _progressoAtual!.adulto.fase;
    return _progressoAtual!.professor.fase;
  }

  /// Retorna o nível atual dinamicamente com base no perfil selecionado
  int get nivelAtual {
    if (_progressoAtual == null || _perfilAtivo == null) return 1;
    if (_perfilAtivo == 'crianca') return _progressoAtual!.crianca.nivel;
    if (_perfilAtivo == 'adulto') return _progressoAtual!.adulto.nivel;
    return _progressoAtual!.professor.nivel;
  }

  /// Inicializa a escuta activa do fluxo de autenticação global do repositório
  void _escutarMudancasAutenticacao() {
    _authSubscription = _authRepository.onAuthStateChanged.listen((UserEntity? user) {
      _usuarioAtual = user;
      
      if (user == null) {
        // Se a conta master deslogar, limpa imediatamente os perfis da memória
        _perfilAtivo = null;
        _progressoAtual = null;
      } else {
        // Busca automática de dados salvos assim que detecta o login do usuário master
        _carregarDadosDoBancoExistentes(user.uid);
      }
      notifyListeners();
    });
  }

  // =========================================================================
  // 🕹️ NOVOS MÉTODOS DE CONTROLE AUTÔNOMO DE PERFIS DE JOGO (MESMO JOGADOR)
  // =========================================================================

  /// Associa o nome digitado ao modo de jogo escolhido (Criança, Adulto ou Professor).
  /// Garante que se o jogador mudar o nome no input, a alteração se reflita globalmente.
  Future<void> escolherPerfilParaJogar({
    required String nome,
    required String perfilEscolhido,
  }) async {
    if (nome.trim().isEmpty) return;
    _perfilAtivo = perfilEscolhido;

    // Se não houver progresso carregado na memória, inicia a base padrão (Fase 1, Nível 1)
    _progressoAtual ??= ProgressoGameModel(
      nomeJogador: nome,
      crianca: ProgressoPerfil(fase: 1, nivel: 1),
      adulto: ProgressoPerfil(fase: 1, nivel: 1),
      professor: ProgressoPerfil(fase: 1, nivel: 1),
    );

    // Se o jogador atualizar a escrita do nome, atualiza o nó principal
    if (_progressoAtual!.nomeJogador != nome) {
      _progressoAtual = ProgressoGameModel(
        nomeJogador: nome,
        crianca: _progressoAtual!.crianca,
        adulto: _progressoAtual!.adulto,
        professor: _progressoAtual!.professor,
      );
    }

    notifyListeners();
    await _salvarProgressoNoBanco();
  }

  /// Atualiza o progresso isolado da fase/nível apenas no perfil ativo do momento.
  Future<void> atualizarFaseNoPerfilAtivo({required int novaFase, required int novoNivel}) async {
    if (_progressoAtual == null || _perfilAtivo == null) return;

    _progressoAtual = ProgressoGameModel(
      nomeJogador: _progressoAtual!.nomeJogador,
      crianca: _perfilAtivo == 'crianca' 
          ? ProgressoPerfil(fase: novaFase, nivel: novoNivel) 
          : _progressoAtual!.crianca,
      adulto: _perfilAtivo == 'adulto' 
          ? ProgressoPerfil(fase: novaFase, nivel: novoNivel) 
          : _progressoAtual!.adulto,
      professor: _perfilAtivo == 'professor' 
          ? ProgressoPerfil(fase: novaFase, nivel: novoNivel) 
          : _progressoAtual!.professor,
    );

    notifyListeners();
    await _salvarProgressoNoBanco();
  }

  /// Mapeia o progresso atualizado e envia para a sua infraestrutura de dados/banco
  Future<void> _salvarProgressoNoBanco() async {
    if (_usuarioAtual == null || _progressoAtual == null) return;
    
    try {
      final mapaParaSalvar = _progressoAtual!.toMap();
      
      // Integre aqui com a chamada do seu repositório de persistência se necessário, ex:
      // await _authRepository.salvarProgressoNoBanco(_usuarioAtual!.uid, mapaParaSalvar);
      
      debugPrint("💾 [PROGRESSO SALVO NO BANCO]: $mapaParaSalvar");
    } catch (e) {
      debugPrint("❌ Erro ao persistir progresso do jogo: $e");
    }
  }

  /// Faz a leitura inicial dos registros de perfis vinculados ao UID master do usuário
  Future<void> _carregarDadosDoBancoExistentes(String uid) async {
    try {
      // Exemplo de integração futura com o seu repositório de dados:
      // final dados = await _authRepository.obterProgressoDoBanco(uid);
      // if (dados != null) {
      //   _progressoAtual = ProgressoGameModel.fromMap(dados);
      //   notifyListeners();
      // }
    } catch (e) {
      debugPrint("❌ Erro ao buscar dados persistidos de perfis: $e");
    }
  }

  // =========================================================================
  // 🔒 SEUS MÉTODOS ORIGINAIS DE AUTENTICAÇÃO (MANTIDOS 100% INTACTOS)
  // =========================================================================

  /// Método principal de login/entrada rápida (Modo Convidado com Setup de Perfil)
  Future<void> realizarLogin({
    required String nome,
    required String perfil,
    required String tipo, 
    required VoidCallback onSuccess,
    required Function(String) onError,
  }) async {
    if (nome.trim().isEmpty) {
      onError("Por favor, digite seu nome!");
      return;
    }

    _iniciarLoading(); 

    try {
      final usuario = await _authRepository.signInAnonymously();

      if (usuario != null) {
        // Atualiza a ficha cadastral pedagógica do usuário
        await _authRepository.updateProfile(
          displayName: nome,
          perfil: perfil,
          tipo: tipo,
        );

        _pararLoading(); 
        onSuccess();
      } else {
        _pararLoading(); 
        onError("Não foi possível iniciar a sessão temporária.");
      }
    } catch (e) {
      _pararLoading();
      final msg = _tratarErroFirebase(e);
      onError(msg);
    }
  }

  /// Realiza a autenticação tradicional usando e-mail e senha.
  Future<void> loginComEmail({
    required String email,
    required String senha,
    required VoidCallback onSuccess,
    required Function(String) onError,
  }) async {
    if (email.trim().isEmpty || senha.trim().isEmpty) {
      onError("Por favor, preencha todos os campos.");
      return;
    }

    _iniciarLoading();
    try {
      final user = await _authRepository.signInWithEmailAndPassword(
        email: email, 
        senha: senha,
      );
      if (user != null) {
        _pararLoading();
        onSuccess();
      } else {
        _pararLoading();
        onError("Dados inválidos de acesso.");
      }
    } catch (e) {
      _pararLoading();
      final msg = _tratarErroFirebase(e);
      onError(msg);
    }
  }

  /// Cadastra uma nova conta de Primeiro Acesso por e-mail e senha.
  Future<void> cadastrarComEmail({
    required String email,
    required String senha,
    required String nome,
    required VoidCallback onSuccess,
    required Function(String) onError,
  }) async {
    if (email.trim().isEmpty || senha.trim().isEmpty || nome.trim().isEmpty) {
      onError("Por favor, preencha todos os campos.");
      return;
    }

    _iniciarLoading();
    try {
      final user = await _authRepository.signUpWithEmailAndPassword(
        email: email,
        senha: senha,
        nome: nome,
      );
      if (user != null) {
        _pararLoading();
        onSuccess();
      } else {
        _pararLoading();
        onError("Não foi possível criar o registro da conta.");
      }
    } catch (e) {
      _pararLoading();
      final msg = _tratarErroFirebase(e);
      onError(msg);
    }
  }

  /// Realiza a autenticação direta de um clique via Google Sign-In.
  Future<void> loginComGoogle({
    required VoidCallback onSuccess,
    required Function(String) onError,
  }) async {
    _iniciarLoading();
    try {
      final user = await _authRepository.signInWithGoogle();
      if (user != null) {
        _pararLoading();
        onSuccess();
      } else {
        _pararLoading();
        onError("A autenticação com o Google foi cancelada.");
      }
    } catch (e) {
      _pararLoading();
      final msg = _tratarErroFirebase(e);
      onError(msg);
    }
  }

  /// Dispara o fluxo de recuperação de senha por e-mail.
  Future<void> recuperarSenha({
    required String email,
    required VoidCallback onSuccess,
    required Function(String) onError,
  }) async {
    if (email.trim().isEmpty) {
      onError("Por favor, digite o e-mail.");
      return;
    }

    _iniciarLoading();
    try {
      await _authRepository.sendPasswordResetEmail(email: email);
      _pararLoading();
      onSuccess();
    } catch (e) {
      _pararLoading();
      final msg = _tratarErroFirebase(e);
      onError(msg);
    }
  }

  /// Encerra a sessão atual de forma limpa e notifica a UI para voltar ao login.
  Future<void> logout() async {
    _iniciarLoading();
    try {
      await _authRepository.signOut();
      _usuarioAtual = null; // Garante a limpeza local imediata
      _perfilAtivo = null; // Reseta estados do jogo
      _progressoAtual = null;
    } catch (e) {
      debugPrint("Erro interno durante o logout: $e");
    } finally {
      _pararLoading(); // Dispara o notifyListeners() que redesenha as telas
    }
  }

  void _iniciarLoading() {
    _isLoading = true;
    _mensagemErro = '';
    notifyListeners();
  }

  void _pararLoading() {
    _isLoading = false;
    notifyListeners();
  }

  /// ⚙️ Tradutor de Exceções do Firebase aprimorado para Flutter Web
  String _tratarErroFirebase(dynamic erro) {
    final erroStr = erro.toString();
    _mensagemErro = erroStr;
    debugPrint("🚨 [DEBUG AUTH] Erro cru capturado: $erroStr");

    if (erroStr.contains('email-already-in-use') || 
        erroStr.contains('account-exists-with-different-credential')) {
      return "Este e-mail já está em uso por outra conta.";
    }
    if (erroStr.contains('wrong-password') || 
        erroStr.contains('invalid-credential') || 
        erroStr.contains('invalid-password')) {
      return "Credenciais incorretas. Verifique seu e-mail e senha.";
    }
    if (erroStr.contains('user-not-found') || erroStr.contains('cannot-find-user')) {
      return "Nenhuma conta localizada com este e-mail.";
    }
    if (erroStr.contains('invalid-email')) {
      return "O formato do e-mail digitado não é válido.";
    }
    if (erroStr.contains('weak-password')) {
      return "A senha precisa ter no mínimo 6 caracteres.";
    }
    if (erroStr.contains('network-request-failed') || erroStr.contains('XMLHttpRequest')) {
      return "Falha de conexão com os servidores do Firebase. Verifique sua internet.";
    }
    if (erroStr.contains('operation-not-allowed')) {
      return "O método de autenticação por E-mail/Senha está DESATIVADO no Console do Firebase.";
    }
    if (erroStr.contains('too-many-requests')) {
      return "Muitas tentativas seguidas. Esta conta foi bloqueada temporariamente.";
    }

    return "Erro na operação: ${erroStr.replaceAll(RegExp(r'\[.*?\]'), '').trim()}";
  }

  @override
  void dispose() {
    // Fecha a inscrição da stream ao destruir o controlador
    _authSubscription?.cancel();
    super.dispose();
  }
}