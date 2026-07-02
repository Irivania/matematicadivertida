# 🎓 Matemática Divertida

[![Flutter](https://img.shields.io/badge/Flutter-3.10+-02569B?logo=flutter)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.10+-0175C2?logo=dart)](https://dart.dev)
[![Firebase](https://img.shields.io/badge/Firebase-Latest-FFA500?logo=firebase)](https://firebase.google.com)
[![License](https://img.shields.io/badge/License-MIT-green)](/LICENSE)
[![Architecture](https://img.shields.io/badge/Architecture-Clean%20Architecture-blueviolet)](#arquitetura)

Um **jogo educativo de matemática gamificado** desenvolvido em Flutter com arquitetura reativa limpa. Oferece experiências personalizadas para crianças, adultos e professores, com recursos de acessibilidade, sistema de progressão e integração completa com Firebase.

> **Status**: ✅ Em desenvolvimento ativo | **Plataformas**: 📱 Android • 🍎 iOS • 🌐 Web • 🖥️ Windows • 🐧 Linux • 🍏 macOS

---

## 📋 Sumário

- [Visão Geral](#visão-geral)
- [Features](#-features)
- [Requisitos](#-requisitos)
- [Instalação](#-instalação)
- [Como Usar](#-como-usar)
- [Estrutura do Projeto](#-estrutura-do-projeto)
- [Arquitetura](#-arquitetura)
- [Tecnologias](#-tecnologias)
- [Desenvolvimento](#-desenvolvimento)
- [Contribuindo](#-contribuindo)
- [Licença](#-licença)
- [Autor](#-autor)

---

## 👀 Visão Geral

**Matemática Divertida** é uma plataforma de aprendizado baseada em jogos que torna a prática de matemática mais engajante e interativa. Com múltiplos modos de jogo personalizados e um sistema de progressão imersivo, a aplicação oferece:

- ✨ **Gamificação completa** com sistema de pontuação, níveis e rewards
- 🎯 **Múltiplos modos de jogo** adaptados para diferentes públicos
- 📊 **Sistema de ranking** em tempo real
- 🛍️ **Loja integrada** para customização
- ♿ **Acessibilidade avançada** com TTS e reconhecimento de voz
- 🌍 **Multi-plataforma** native e web
- 🔐 **Autenticação segura** com Firebase Auth

---

## 🎯 Features

### 🎮 Modos de Jogo
| Modo | Descrição | Público-Alvo |
|------|-----------|-------------|
| **Criança** | Modo gamificado com recompensas visuais, áudio e confete | 6-12 anos |
| **Adulto** | Desafios matemáticos progressivos e ranking competitivo | 13+ anos |
| **Professor** | Ferramentas para criar e gerenciar turmas e acompanhar alunos | Educadores |

### 💡 Funcionalidades Principais
- 🏆 **Trilha de Aprendizado**: Progressão estruturada através de níveis
- 📈 **Sistema de Níveis**: Desafios crescentes de dificuldade
- 🎖️ **Ranking Global**: Competição saudável entre usuários
- 🛒 **Loja Virtual**: Itens cosméticos e powerups
- 👤 **Perfil Personalizado**: Customização de avatar e preferências
- 🔊 **Áudio e Voz**: TTS para leitura de problemas e microfone para respostas
- 🎨 **QR Code**: Integração com código QR para compartilhamento
- 🎉 **Efeitos Visuais**: Animações de celebração e feedback visual

### 🔐 Autenticação e Segurança
- ✅ Login com Google Sign-In
- ✅ Firebase Authentication
- ✅ Armazenamento seguro com Firestore
- ✅ Sincronização em tempo real

---

## 📦 Requisitos

### Ambiente
- **Flutter**: ≥ 3.10.0
- **Dart**: ≥ 3.10.0
- **Java**: ≥ 11 (para Android)
- **Xcode**: ≥ 15 (para iOS/macOS)
- **Visual Studio**: Community 2022+ (para Windows)
- **CMake**: ≥ 3.10 (para Linux/Windows)

### Contas e Serviços
- 🔥 **Firebase Project** ([criar aqui](https://console.firebase.google.com))
- 🔑 **Google Cloud Console** (para OAuth 2.0)
- ☁️ **Firestore Database** habilitado
- 🔐 **Firebase Authentication** com Google Sign-In

### Hardware Mínimo
| Plataforma | RAM | Espaço | Versão |
|-----------|-----|--------|--------|
| Android | 2GB | 100MB | 8.0+ |
| iOS | 2GB | 150MB | 13.0+ |
| Web | 1GB | - | Chrome 100+ |

---

## 🚀 Instalação

### 1️⃣ Clonar o Repositório

```bash
git clone https://github.com/Irivania/matematicadivertida.git
cd matematicadivertida
```

### 2️⃣ Instalar Dependências

```bash
flutter pub get
```

### 3️⃣ Configurar Firebase

#### Passo 1: Criar projeto no Firebase

1. Acesse [Firebase Console](https://console.firebase.google.com)
2. Clique em "Criar Projeto"
3. Nomeie como "Matemática Divertida"
4. Ative o Google Analytics (opcional)
5. Siga as instruções de setup

#### Passo 2: Conectar o Flutter

```bash
# Instalar CLI do Firebase
npm install -g firebase-tools

# Fazer login
firebase login

# Conectar projeto
flutterfire configure
```

#### Passo 3: Configurar Autenticação Google

1. No Firebase Console → Autenticação → Google
2. Habilitar Google Sign-In
3. No Google Cloud Console → OAuth consent screen
4. Criar credentials de OAuth 2.0 para:
   - **Android**: SHA-1 e SHA-256 do seu app
   - **iOS**: Bundle ID
   - **Web**: URIs autorizados

#### Passo 4: Criar Firestore

1. No Firebase Console → Firestore Database
2. Escolher região mais próxima
3. Iniciar em modo teste (depois mudar para produção)
4. Criar coleções conforme necessário

### 4️⃣ Variáveis de Ambiente (Opcional)

Crie um arquivo `.env` na raiz:

```env
FIREBASE_PROJECT_ID=seu-project-id
FIREBASE_REGION=us-central1
```

### 5️⃣ Executar o App

```bash
# Debug
flutter run

# Android
flutter run -d android

# iOS
flutter run -d ios

# Web
flutter run -d web

# Desktop (Windows)
flutter run -d windows

# Desktop (macOS)
flutter run -d macos

# Desktop (Linux)
flutter run -d linux
```

---

## 📱 Como Usar

### Primeira Execução

1. **Iniciar App** → Tela de login aparecerá
2. **Login com Google** → Clique no botão "Entrar com Google"
3. **Selecionar Modo** → Escolha entre Criança, Adulto ou Professor
4. **Começar** → Selecione a primeira trilha

### Navegação Principal

```
Home Screen
├── 🎮 Jogar Agora (Continua trilha atual)
├── 📊 Ranking
├── 🛍️ Loja
├── 👤 Perfil
└── ⚙️ Configurações
```

### Modo Jogo

- **Problema**: Apareça na tela (TTS pode ler)
- **Responder**: Digite ou use o microfone
- **Enviar**: Clique em "Verificar"
- **Resultado**: Feedback imediato com pontos e efeitos

### Loja Virtual

- Compre temas, avatares e powerups
- Use moedas obtidas ao jogar
- Customizar seu perfil

---

## 📸 Capturas de Tela

Para exibir imagens das telas do jogo no `README.md` siga estes passos:

- Coloque os arquivos de imagem em `assets/images/screenshots/` (crie a pasta se necessário).
- Use marcação Markdown para inserir as imagens:

```markdown
![Tela inicial](assets/images/screenshots/home.svg)
![Tela do jogo](assets/images/screenshots/game.svg)
```

- Para controlar largura use HTML:

```html
<img src="assets/images/screenshots/game.svg" width="700" />
```

- Exemplos rápidos de captura:

```bash
# Capturar do dispositivo Android com adb
adb exec-out screencap -p > assets/images/screenshots/game.png

# Depois adicionar ao git e enviar
git add assets/images/screenshots/*
git commit -m "docs: add screenshots"
git push
```

As imagens precisam estar no repositório (commit + push) para aparecerem no GitHub.

---

## 📂 Estrutura do Projeto

```
lib/
├── core/                      # Configurações globais
│   ├── config/               # Configuração Firebase e constantes
│   ├── theme/                # Tema Material Design
│   └── utils/                # Utilitários gerais
│
├── data/                      # Camada de Dados (Data Layer)
│   ├── models/               # Modelos de dados (GameState, User, etc)
│   ├── repositories/         # Implementação de repositórios
│   ├── services/             # Serviços de API e Firebase
│   └── datasources/          # Fontes de dados (local/remoto)
│
├── domain/                    # Camada de Domínio (Business Logic)
│   ├── entities/             # Entidades puras (sem dependências)
│   ├── repositories/         # Interfaces de repositórios (abstrações)
│   └── usecases/             # Casos de uso (regras de negócio)
│
├── presentation/             # Camada de Apresentação (UI)
│   ├── auth/                 # Telas de autenticação
│   ├── screens/              # Telas principais
│   │   ├── home_screen.dart              # Home
│   │   ├── jogo_screen.dart              # Tela do jogo
│   │   ├── crianca_game.dart             # Modo criança
│   │   ├── adulto_game.dart              # Modo adulto
│   │   ├── professor_game.dart           # Modo professor
│   │   ├── trilha_screen.dart            # Seleção de trilhas
│   │   ├── nivel_screen.dart             # Seleção de níveis
│   │   ├── ranking_screen.dart           # Ranking
│   │   ├── loja_screen.dart              # Loja
│   │   └── perfil_screen.dart            # Perfil do usuário
│   ├── widgets/              # Widgets reutilizáveis
│   ├── controllers/          # Controllers (Provider)
│   │   ├── auth_controller.dart          # Autenticação
│   │   └── jogo_controller.dart          # Lógica do jogo
│   └── routes/               # Definição de rotas
│
├── assets/                    # Recursos
│   ├── images/               # Imagens
│   ├── sons/                 # Áudios e efeitos sonoros
│   └── icons/                # Ícones
│
└── main.dart                 # Ponto de entrada
```

---

## 🏗️ Arquitetura

### Clean Architecture + Provider Pattern

O projeto segue a **Clean Architecture** com 3 camadas distintas:

```
┌─────────────────────────────────────────────────────┐
│          PRESENTATION (UI)                          │
│  Screens, Widgets, Controllers (Provider)           │
└──────────────────┬──────────────────────────────────┘
                   │
                   ↓
┌─────────────────────────────────────────────────────┐
│          DOMAIN (Business Logic)                    │
│  Entities, Repositories (Interfaces), Use Cases     │
└──────────────────┬──────────────────────────────────┘
                   │
                   ↓
┌─────────────────────────────────────────────────────┐
│          DATA (Implementation)                      │
│  Models, Repository Implementations, Services       │
└─────────────────────────────────────────────────────┘
```

### Fluxo de Dados com Provider

```
User Interaction
    ↓
Presentation Layer (Widget/Screen)
    ↓
Provider (ChangeNotifier)
    ↓
Use Case (Domain)
    ↓
Repository Implementation (Data)
    ↓
Firebase Service / Local Service
    ↓
Data Update → Notify Listeners
    ↓
Widget Rebuilds
```

### Diagrama de Injeção de Dependência

```
MultiProvider
├── AuthService (Singleton)
├── IAuthRepository (ProxyProvider de AuthService)
├── AuthController (ChangeNotifierProxyProvider de IAuthRepository)
├── GameState (ChangeNotifierProvider)
└── JogoController (ChangeNotifierProvider)
```

---

## 🛠️ Tecnologias

### Framework & SDK
- **Flutter**: Framework UI multiplataforma
- **Dart**: Linguagem de programação

### Estado e Reatividade
- **Provider**: Gerenciamento de estado
- **ChangeNotifier**: Notificação de mudanças

### Backend e Dados
- **Firebase Core**: Inicialização Firebase
- **Firebase Auth**: Autenticação de usuários
- **Cloud Firestore**: Banco de dados em tempo real
- **Google Sign-In**: Autenticação com Google

### UI e UX
- **Material Design 3**: Sistema de design
- **Cupertino Icons**: Ícones iOS
- **Google Fonts**: Tipografia customizada
- **Confetti**: Efeitos de celebração

### Acessibilidade e Áudio
- **Flutter TTS**: Text-to-Speech
- **Speech to Text**: Reconhecimento de voz
- **AudioPlayers**: Reprodução de áudio

### Recursos Adicionais
- **QR Flutter**: Geração de QR codes
- **SharedPreferences**: Armazenamento local
- **Intl**: Internacionalização e localização

### Qualidade de Código
- **Dart Lints**: Análise estática (Flutter recommended)
- **Flutter Test**: Framework de testes

---

## 💻 Desenvolvimento

### Executar Testes

```bash
# Testes unitários e widget
flutter test

# Cobertura de testes
flutter test --coverage

# Testes específicos
flutter test test/widget_test.dart
```

### Análise Estática

```bash
# Verificar código
flutter analyze

# Com relatório detalhado
dart analyze lib/
```

### Formatar Código

```bash
# Formatar todos os arquivos
dart format lib/ test/

# Verificar formatação
dart format --set-exit-if-changed lib/ test/
```

### Build para Produção

#### Android
```bash
flutter build apk --release
# ou
flutter build appbundle --release
```

#### iOS
```bash
flutter build ios --release
```

#### Web
```bash
flutter build web --release
```

#### Windows
```bash
flutter build windows --release
```

#### macOS
```bash
flutter build macos --release
```

#### Linux
```bash
flutter build linux --release
```

### Debug

```bash
# Modo debug com hot reload
flutter run -d <device> --debug

# Profile (performance)
flutter run -d <device> --profile

# Release
flutter run -d <device> --release

# DevTools
flutter pub global activate devtools
devtools
```

---

## 🤝 Contribuindo

Contribuições são bem-vindas! Por favor, siga os passos abaixo:

### 1. Fork o Projeto
```bash
git clone https://github.com/Irivania/matematicadivertida.git
cd matematicadivertida
```

### 2. Criar uma Branch
```bash
git checkout -b feature/sua-feature
```

### 3. Fazer Mudanças
- Siga o padrão de Clean Architecture
- Escreva testes para novas features
- Execute `flutter analyze` e `dart format`
- Atualize a documentação

### 4. Commit
```bash
git add .
git commit -m "feat: descrição clara da sua feature"
# Usar conventional commits:
# feat: nova feature
# fix: correção de bug
# docs: documentação
# test: testes
# refactor: refatoração
```

### 5. Push e Pull Request
```bash
git push origin feature/sua-feature
```
Crie um Pull Request descrevendo suas mudanças

### Padrões de Código
- ✅ Usar Clean Architecture
- ✅ Interfaces para abstrações
- ✅ Testes unitários obrigatórios
- ✅ Documentação com dartdoc
- ✅ Cobertura de testes > 80%

### Checklist antes de submeter
- [ ] Código formatado com `dart format`
- [ ] Sem erros em `flutter analyze`
- [ ] Testes passando com `flutter test`
- [ ] Commits seguem conventional commits
- [ ] README atualizado se necessário

---

## 📝 Licença

Este projeto está licenciado sob a **MIT License** - veja o arquivo [LICENSE](/LICENSE) para detalhes.

```
MIT License

Copyright (c) 2026 Irivânia Maria de Melo

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:
...
```

---

## 👨‍💻 Autor

**Irivânia Maria de Melo**

- GitHub: [@Irivania](https://github.com/Irivania)
- Email: contato@matematicadivertida.com
- LinkedIn: [Irivânia Maria de Melo](https://linkedin.com/in/irivania-maria-de-melo)

---

## 📚 Recursos Adicionais

### Documentação Oficial
- [Flutter Docs](https://flutter.dev/docs)
- [Dart Docs](https://dart.dev/guides)
- [Firebase Docs](https://firebase.google.com/docs)
- [Provider Package](https://pub.dev/packages/provider)

### Tutoriais
- [Clean Architecture em Flutter](https://resocoder.com/flutter-clean-architecture)
- [Firebase com Flutter](https://firebase.google.com/codelabs/firebase-get-to-know-firebase-for-flutter)
- [State Management com Provider](https://pub.dev/packages/provider#tutorials)

### Comunidade
- [Flutter Community](https://flutter.dev/community)
- [StackOverflow - Flutter](https://stackoverflow.com/questions/tagged/flutter)
- [Reddit - r/Flutter](https://reddit.com/r/Flutter)

---

## 🐛 Reportar Issues

Encontrou um bug? [Abra uma issue](https://github.com/Irivania/matematicadivertida/issues/new)

**Template para reportar:**
```markdown
## Descrição do Bug
[Descrição clara do problema]

## Como Reproduzir
1. Passo 1
2. Passo 2
3. Passo 3

## Comportamento Esperado
[O que deveria acontecer]

## Comportamento Atual
[O que acontece]

## Logs/Screenshots
[Se possível, anexe logs ou screenshots]

## Ambiente
- Flutter version: 
- Dart version:
- Plataforma: 
- Dispositivo:
```

---

## ⭐ Se este projeto foi útil para você

Por favor, considere dar uma ⭐ no [repositório](https://github.com/Irivania/matematicadivertida)!

---

<div align="center">

**Feito com ❤️ por [Irivânia Maria de Melo](#autor)**

[⬆ Voltar ao topo](#-matemática-divertida)

</div>
