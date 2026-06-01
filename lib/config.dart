// Environment-backed configuration values.
// Set at build time with `--dart-define`, e.g. `--dart-define=WS_URL=wss://...`

/// WebSocket server URL. Use `--dart-define=WS_URL=...` when building for web.
const String kWsUrl = String.fromEnvironment(
  'WS_URL',
);
