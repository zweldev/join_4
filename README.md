# frontend

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

## Deploying to Netlify (Flutter Web)

Set your WebSocket endpoint as an environment variable named `WS_URL` in Netlify, then build with `--dart-define` so the value is baked into the web build. Example Netlify build command:

```bash
flutter build web --release --dart-define=WS_URL=$WS_URL
```

On Netlify, add an environment variable `WS_URL` with the WebSocket URL (for example `wss://example.com/ws`). The app reads this value at compile time.

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
