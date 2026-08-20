# 🎓 Matemática Divertida

[![Flutter](https://img.shields.io/badge/Flutter-3.10+-02569B?logo=flutter)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.10+-0175C2?logo=dart)](https://dart.dev)
[![Firebase](https://img.shields.io/badge/Firebase-Latest-FFA500?logo=firebase)](https://firebase.google.com)
[![License](https://img.shields.io/badge/License-MIT-green)](/LICENSE)

Aplicativo de matemática gamificada de alta performance desenvolvido com Flutter e Firebase. O projeto utiliza arquitetura reativa para oferecer desafios interativos, progressão de fases, suporte multilíngue e uma experiência de aprendizado dinâmica e acessível.

---

## 🚀 Funcionalidades Principais

- **Gamificação Estruturada:** Progressão de níveis, economia interna, mascote interativo (Cal) e itens desbloqueáveis na loja.
- **Acessibilidade & Voz:** Suporte via `Text-to-Speech` (leitura de perguntas) e reconhecimento de respostas faladas.
- **Internacionalização (i18n):** Suporte nativo em Português (`pt_BR`) e Inglês (`en`) com alteração dinâmica em tempo real.
- **Dados & Ranking:** Sincronização em tempo real via Firebase Firestore, acompanhamento de desempenho analítico e gráficos interativos.
- **Autenticação:** Fluxo seguro integrado com Firebase Auth (E-mail/Senha e Google Sign-In).

---

## 🛠️ Qualidade e Testes Automatizados

O projeto segue rigorosas práticas de engenharia de software, contando com **Testes Unitários Automatizados** voltados para validar regras de negócio críticas (como formatação de tempo, normalização de respostas faladas e integridade de estado).

> **Status dos Testes:** `✅ Todos os testes unitários aprovados com sucesso.`

Para rodar os testes localmente:
```bash
flutter test

📁 Arquitetura do Projeto
A base de código segue uma separação limpa de responsabilidades:

lib/
├── core/         # Configurações globais, temas (AppColors) e utilitários
├── data/         # Models, Repositories e Services (Auth, Voz, Game)
├── domain/       # Casos de uso e regras centrais
└── presentation/ # Telas (Screens), Widgets modulares e Controllers

📱 Galeria do AplicativoConfira algumas das telas que compõem a experiência do Matemática Divertida:Tela de LoginTela Inicial (Home)Modo InglêsAutenticação segura via E-mail ou GooglePainel principal com missões diárias e modosSuporte completo a múltiplos idiomas (i18n)Seleção de PerfilLoja do CalTela de JogoEscolha de avatares imersivos e dinâmicosLoja de itens, mascote e vidas extrasResolução de problemas com suporte de vozRanking GlobalProgresso e DesempenhoAcompanhamento de posições em tempo realCurva de desempenho analítica por fase🚀 Como Executar o ProjetoClone o repositório em sua máquina.Certifique-se de ter o Flutter 3.10+ instalado.Instale as dependências executando:Bashflutter pub get
Execute os testes unitários para validar o ambiente:Bashflutter test
Inicie a aplicação:Bashflutter run
📝 LicençaEste projeto está licenciado sob a licença MIT.

---

Basta substituir o conteúdo do arquivo `README.md` do seu projeto por este texto, salvar, e em seguida rodar os comandos de commit para atualizar o seu portfólio no GitHub!