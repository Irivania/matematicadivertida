# Segurança do projeto

## Credenciais e segredos

- Não versionar arquivos com segredos reais.
- Manter valores sensíveis em `android/key.properties` localmente e nunca commitar esse arquivo.
- Para Firebase, usar `--dart-define` ou variáveis de ambiente ao gerar builds.

## Exemplo de uso

```bash
flutter run \
  --dart-define=FIREBASE_ANDROID_API_KEY=SEU_VALOR \
  --dart-define=FIREBASE_ANDROID_APP_ID=SEU_VALOR
```

## Arquivos ignorados

- `android/key.properties`
- `android/app/google-services.json`
- `.env`
