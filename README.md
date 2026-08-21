# 🎓 Matemática Divertida

[![Flutter](https://img.shields.io/badge/Flutter-3.10+-02569B?logo=flutter)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.10+-0175C2?logo=dart)](https://dart.dev)
[![Firebase](https://img.shields.io/badge/Firebase-Latest-FFA500?logo=firebase)](https://firebase.google.com)
[![License](https://img.shields.io/badge/License-MIT-green)](/LICENSE)

Aplicativo de matemática gamificada de alta performance desenvolvido com Flutter e Firebase. O projeto utiliza arquitetura reativa para oferecer desafios interativos, progressão de fases e uma experiência de aprendizado dinâmica, acessível e responsiva.

🌐 **Teste o app online agora:** [https://matematica-divertida-b285a.web.app](https://matematica-divertida-b285a.web.app)

---

## 🚀 Funcionalidades Principais

- **Gamificação Estruturada:** Progressão de níveis (Bronze a Mestre), sistema de economia e trajes desbloqueáveis para o mascote.
- **Acessibilidade:** Suporte completo via `Text-to-Speech` (leitura de perguntas) e `Speech-to-Text` (respostas por voz).
- **Multilíngue:** Suporte nativo em Português (`pt_BR`) e Inglês (`en`).
- **Dados & Ranking:** Sincronização em tempo real via Firebase Firestore com visualização de desempenho em gráficos.
- **Autenticação:** Fluxo seguro com Firebase Auth (E-mail e Google Sign-In).

---

## 🛠️ Qualidade e Testes

O projeto segue rigorosas práticas de engenharia de software, contando com uma **suíte completa de testes unitários automatizados** para validar regras de negócio críticas, como cálculos de pontuação e formatação de tempo.

> **Status dos Testes:** `✅ Todos os testes unitários aprovados com sucesso.`

Para rodar os testes localmente:
```bash
flutter test

📁 Arquitetura do Projeto
A base de código segue uma separação limpa de responsabilidades:

Plaintext
lib/
├── core/         # Configurações globais, temas e utilitários
├── data/         # Models, Repositories e Services (Auth, Voz, Game)
├── domain/       # Casos de uso e regras de negócio centrais
└── presentation/ # Telas (Screens), Widgets modulares e Controllers
🚀 Como Executar
Clone o repositório:

Bash
git clone [https://github.com/Irivania/matematicadivertida.git](https://github.com/Irivania/matematicadivertida.git)

Entre na pasta e instale as dependências:

Bash
cd matematicadivertida
flutter pub get

Execute os testes:

Bash
flutter test
Inicie a aplicação:

Bash
flutter run
👩‍💻 Autoria
Desenvolvido por Irivânia Maria de Melo como parte da jornada de aprendizado em Gestão da Tecnologia da Informação e Desenvolvimento de Software.

📝 Licença
Este projeto está licenciado sob a licença MIT.


### Para atualizar o GitHub agora:
1. Copie todo o código acima.
2. Cole no seu arquivo `README.md` no VS Code e salve.
3. No terminal, digite:
   ```bash
   git add README.md
   git commit -m "docs: atualiza README com link do deploy e informações finais"
   git push origin main