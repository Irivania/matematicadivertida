# 🎓 Matemática Divertida

[![Flutter](https://img.shields.io/badge/Flutter-3.10+-02569B?logo=flutter)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.10+-0175C2?logo=dart)](https://dart.dev)
[![Firebase](https://img.shields.io/badge/Firebase-Latest-FFA500?logo=firebase)](https://firebase.google.com)
[![License](https://img.shields.io/badge/License-MIT-green)](/LICENSE)

Aplicativo de matemática gamificada desenvolvido com Flutter e Firebase. O projeto reúne desafios interativos, progressão de fases, autenticação e uma experiência de aprendizado dinâmica e acessível para diferentes perfis de usuários.

> Status: Concluído / Em evolução | Plataformas: Android, iOS e Web

## ✨ Funcionalidades Principais

- **Perfis Personalizados:** Perguntas adaptadas dinamicamente para os perfis **Criança**, **Adulto** e **Professor**.
- **Modos de Jogo:** Sistema de fases por níveis (de Bronze a Mestre) e **Modo Disputa** com ranking global.
- **Acessibilidade e Interação por Voz:** 
  - **Text-to-Speech (TTS):** Leitura automática ou manual das perguntas pelo app.
  - **Speech-to-Text (STT):** Reconhecimento de voz para que o usuário possa responder falando.
- **Estatísticas e Progresso:** Acompanhamento detalhado de recordes locais e desempenho nas abas de progresso.
- **Autenticação:** Suporte a login com Google e integração completa com o Firebase Authentication.

## 🚀 Como executar

```bash
git clone [https://github.com/Irivania/matematicadivertida.git](https://github.com/Irivania/matematicadivertida.git)
cd matematicadivertida
flutter pub get

Web
Bash
flutter run -d chrome --web-port=5000 --web-browser-flag="--disable-web-security"
Android
Bash
flutter run -d android
🔧 Requisitos
Flutter 3.10+

Dart 3.10+

Firebase configurado para o projeto

Conta Google Cloud com OAuth habilitado para autenticação

📁 Estrutura do projeto
Plaintext
lib/
├── core/         # Configurações globais, temas e enums
├── data/         # Serviços (voz, áudio, fluxo, perguntas), repositórios e modelos
├── domain/       # Regras e entidades do negócio
└── presentation/ # Telas (ranking, jogo, perfis), widgets e controllers
🤝 Contribuindo
Contribuições são bem-vindas! Sinta-se à vontade para fazer um fork, abrir uma issue ou enviar um pull request com melhorias.

📝 Licença
Este projeto está licenciado sob a licença MIT. Consulte o arquivo LICENSE para detalhes.




