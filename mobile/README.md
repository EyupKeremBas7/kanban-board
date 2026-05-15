# Kanban Board Mobile

Flutter mobile client for the Kanban Board project.

## Local API targets

The app reads `API_URL` in this order:

1. `--dart-define=API_URL=...`
2. `mobile/.env`
3. Default emulator URL: `http://10.0.2.2:8000/api/v1`

For Android emulator:

```bash
flutter run --dart-define=API_URL=http://10.0.2.2:8000/api/v1
```

For a physical phone on the same Wi-Fi/LAN as the computer:

```bash
flutter build apk --release --dart-define=API_URL=http://<PC_IP>:8000/api/v1
```

The APK output is created at:

```text
build/app/outputs/flutter-apk/app-release.apk
```
