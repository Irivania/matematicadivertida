# 🎓 Matemática Divertida

[![Flutter](https://img.shields.io/badge/Flutter-3.10+-02569B?logo=flutter)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.10+-0175C2?logo=dart)](https://dart.dev)
[![Firebase](https://img.shields.io/badge/Firebase-Latest-FFA500?logo=firebase)](https://firebase.google.com)
[![License](https://img.shields.io/badge/License-MIT-green)](/LICENSE)

Aplicativo de matemática gamificada de alta performance desenvolvido com Flutter e Firebase. O projeto utiliza arquitetura reativa para oferecer desafios interativos, progressão de fases e uma experiência de aprendizado dinâmica, acessível e responsiva.

---

## 🚀 Funcionalidades Principais

- **Gamificação Estruturada:** Progressão de níveis (Bronze a Mestre), sistema de economia e trajes desbloqueáveis para o mascote.
- **Acessibilidade:** Suporte completo via `Text-to-Speech` (leitura de perguntas) e `Speech-to-Text` (respostas por voz).
- **Multilíngue:** Suporte nativo em Português (pt_BR) e Inglês (en).
- **Dados & Ranking:** Sincronização em tempo real via Firebase Firestore com visualização de desempenho em gráficos (`fl_chart`).
- **Autenticação:** Fluxo seguro com Firebase Auth (E-mail e Google Sign-In).

## 🛠️ Qualidade e Testes
O projeto segue boas práticas de engenharia de software, incluindo **Testes Unitários Automatizados** para validar regras de negócio críticas, como cálculos de pontuação, formatação de tempo e sanitização de entradas.

> **Status dos Testes:** `✅ Todos os testes unitários passando.`

## 📁 Arquitetura
Seguimos uma organização modular para facilitar a manutenção e escalabilidade:

```text
lib/
├── core/         # Configurações globais, temas e enums
├── data/         # Services (Auth, Voice, Game), Repositories e Models
├── domain/       # Casos de uso e entidades de negócio
└── presentation/ # Telas, Widgets e Controllers
🚀 Como Executar
Clone o repositório.

Certifique-se de ter o Flutter 3.10+ instalado.

Rode flutter pub get.

Execute flutter test para validar as regras de negócio.

Inicie o app com flutter run.

📝 Licença
Este projeto está licenciado sob a licença MIT.
Excelente! Como sua faculdade é em Gestão da Tecnologia da Informação, um portfólio bem documentado é tão importante quanto o código limpo. Para um recrutador ou um professor, o **README** é a "vitrine" que demonstra como você pensa e organiza suas entregas.

Aqui está uma proposta de estrutura profissional para o seu `README.md`. Copie e substitua o conteúdo do seu arquivo atual por este:

---

```markdown
# 🎓 Matemática Divertida

[![Flutter](https://img.shields.io/badge/Flutter-3.10+-02569B?logo=flutter)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.10+-0175C2?logo=dart)](https://dart.dev)
[![Firebase](https://img.shields.io/badge/Firebase-Latest-FFA500?logo=firebase)](https://firebase.google.com)
[![License](https://img.shields.io/badge/License-MIT-green)](/LICENSE)

Aplicativo de matemática gamificada de alta performance desenvolvido com Flutter e Firebase. O projeto utiliza arquitetura reativa para oferecer desafios interativos, progressão de fases e uma experiência de aprendizado dinâmica, acessível e responsiva.

---

## 🚀 Funcionalidades Principais

- **Gamificação Estruturada:** Progressão de níveis (Bronze a Mestre), sistema de economia e trajes desbloqueáveis para o mascote.
- **Acessibilidade:** Suporte completo via `Text-to-Speech` (leitura de perguntas) e `Speech-to-Text` (respostas por voz).
- **Multilíngue:** Suporte nativo em Português (pt_BR) e Inglês (en).
- **Dados & Ranking:** Sincronização em tempo real via Firebase Firestore com visualização de desempenho em gráficos (`fl_chart`).
- **Autenticação:** Fluxo seguro com Firebase Auth (E-mail e Google Sign-In).

## 🛠️ Qualidade e Testes
O projeto segue boas práticas de engenharia de software, incluindo **Testes Unitários Automatizados** para validar regras de negócio críticas, como cálculos de pontuação, formatação de tempo e sanitização de entradas.

> **Status dos Testes:** `✅ Todos os testes unitários passando.`

## 📁 Arquitetura
Seguimos uma organização modular para facilitar a manutenção e escalabilidade:

```text
lib/
├── core/         # Configurações globais, temas e enums
├── data/         # Services (Auth, Voice, Game), Repositories e Models
├── domain/       # Casos de uso e entidades de negócio
└── presentation/ # Telas, Widgets e Controllers

```

## 🚀 Como Executar

1. Clone o repositório.
2. Certifique-se de ter o Flutter 3.10+ instalado.
3. Rode `flutter pub get`.
4. Execute `flutter test` para validar as regras de negócio.
5. Inicie o app com `flutter run`.

---

## 📝 Licença

Este projeto está licenciado sob a licença MIT.

```

---

### Dicas de Ouro para o seu Portfólio (Opção 1 completa):

1.  **Prints/GIFs:** No seu `README.md`, adicione um GIF ou uma imagem do app rodando. Você pode usar um app simples de captura de tela no celular ou o próprio simulador do computador. Recrutadores adoram ver o **resultado visual** antes de ler o código.
2.  **LinkedIn:** Quando postar sobre o projeto no LinkedIn, escreva algo como: *"Acabei de expandir o projeto Matemática Divertida, implementando testes unitários automatizados. Garantir a qualidade do código desde o início da graduação tem sido um desafio gratificante!"*.
3.  **Destaque no Repositório:** Clique na engrenagem ao lado de "About" no seu repositório no GitHub e adicione as tags: `flutter`, `firebase`, `gamification`, `tdd`, `math-app`. Isso ajuda o algoritmo do GitHub a encontrar seu projeto.

**O que você acha de adicionarmos um pequeno GIF na pasta `assets` ou colocar um link de vídeo demonstrando o jogo no seu README?** Isso deixaria o seu perfil com um nível muito superior ao da maioria dos estudantes.

```