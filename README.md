# 🎓 Matemática Divertida

[![Flutter](https://img.shields.io/badge/Flutter-3.10+-02569B?logo=flutter)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.10+-0175C2?logo=dart)](https://dart.dev)
[![Firebase](https://img.shields.io/badge/Firebase-Latest-FFA500?logo=firebase)](https://firebase.google.com)
[![License](https://img.shields.io/badge/License-MIT-green)](/LICENSE)

Aplicativo de matemática gamificada desenvolvido com Flutter e Firebase. O projeto reúne jogos, progresso, autenticação e uma experiência de aprendizado mais dinâmica para diferentes perfis de usuários.

> Status: em desenvolvimento | Plataformas: Android, iOS e Web

## ✅ O que foi ajustado recentemente

- Login com Google compatível com a versão 7.x do pacote `google_sign_in`
- Suporte ao fluxo de autenticação na web com Firebase Authentication
- Configuração do Firebase para a plataforma web
- Ajuste na inicialização do app para carregar corretamente as opções do projeto

## 🚀 Como executar

```bash
git clone https://github.com/Irivania/matematicadivertida.git
cd matematicadivertida
flutter pub get
```

### Web

```bash
flutter run -d chrome --web-port=5000 --web-browser-flag="--disable-web-security"
```

### Android

```bash
flutter run -d android
```

## 🔧 Requisitos

- Flutter 3.10+
- Dart 3.10+
- Firebase configurado para o projeto
- Conta Google Cloud com OAuth habilitado para autenticação

## 📁 Estrutura do projeto

```text
lib/
├── core/        # Configurações gerais
├── data/        # Serviços, repositórios e fontes de dados
├── domain/      # Regras e entidades do negócio
└── presentation/# Telas, widgets e controllers
```

## 🤝 Contribuindo

Contribuições são bem-vindas. Faça um fork, crie uma branch e envie um pull request com a sua alteração.

## 📝 Licença

Este projeto está licenciado sob a licença MIT. Consulte o arquivo [LICENSE](/LICENSE) para detalhes.

