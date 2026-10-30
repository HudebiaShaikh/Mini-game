# Mini Games – Schulte Grid

A Flutter app for focus training. Tap the numbers 1 to N in order as fast as you can on a shuffled 4×4, 5×5 or 6×6 grid. Your 10 best times for each size are saved.

## Features
- 3 grid sizes: 4×4, 5×5 and 6×6
- Timer starts on 1 and stops on the last number (MM:SS.hh)
- A wrong tap flashes red and vibrates
- The timer pauses when the app is minimised
- Top-10 leaderboard per grid size, with a "New Personal Best!" badge
- Light / dark mode button (remembered)
- Portrait and landscape layouts
- Works offline on Android, Windows and in web browsers (Edge, Chrome)

## Requirements
- Flutter SDK (stable): https://docs.flutter.dev/get-started/install
- Android: Android Studio + Android SDK
- Windows .exe: Visual Studio 2022 with "Desktop development with C++"
- Run `flutter doctor` and fix anything it reports

## Run
```bash
flutter pub get
flutter run -d edge       # Microsoft Edge
flutter run -d windows    # Windows app
flutter run               # phone / emulator
```

## Build
```bash
flutter build apk --release       # build/app/outputs/flutter-apk/app-release.apk
flutter build windows --release   # build/windows/x64/runner/Release/
flutter build web --release       # build/web/
```

## Test
```bash
flutter analyze
flutter test
```

## Project structure
```
lib/
├── main.dart                  starts the app
├── app.dart                   MaterialApp + light/dark mode
├── models/                    GridSize, ScoreRecord
├── logic/schulte_game.dart    game rules, shuffle, Stopwatch
├── services/                  saving scores and settings (shared_preferences)
├── screens/                   home, start, game, leaderboard
├── widgets/game_card.dart
└── theme/app_theme.dart       colours
```

## Tools
Flutter, Dart, shared_preferences. The screens use `StatefulWidget` and `setState`.

## License
MIT – see LICENSE.
