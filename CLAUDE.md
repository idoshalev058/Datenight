# DateNight

Flutter app. This file defines the framework, architecture, and libraries Claude
should use when working in this repo.

## Stack

- **Flutter** (Dart SDK `^3.12.2`), Material 3, dark theme by default.
- **State management:** none — plain `StatefulWidget` + `setState`. Do not add
  `provider`, `riverpod`, `bloc`, or similar packages unless explicitly asked.
- **Navigation:** plain `Navigator.push` / `MaterialPageRoute`. No routing package.
- **Linting:** `flutter_lints`, configured via `analysis_options.yaml` using the
  default `package:flutter_lints/flutter.yaml` rule set (no custom rules unless needed).

## Project structure

```
lib/
  main.dart          # app entry point, MaterialApp + theme
  models/             # plain Dart data classes / enums
  screens/            # one file per screen, StatefulWidget or StatelessWidget
  services/           # plain classes wrapping I/O (storage, sensors, audio, etc.)
```

- Screens live in `lib/screens/`, one class per file, named `<Thing>Screen`.
- Services live in `lib/services/`, one class per file, named `<Thing>Service`.
  Services are instantiated directly inside the widgets that use them (no DI
  container). Methods that touch I/O are `async` and awaited by callers.
- Small private helper widgets stay in the same file as the screen that uses
  them (prefixed with `_`), rather than being split into separate files.
- Large `build()` methods are broken into private `_buildXxx()` methods on the
  same `State` class rather than extracted into new widget classes, unless the
  sub-widget needs its own state or is reused elsewhere.

## Libraries (add only what's needed)

Default/core:
- `cupertino_icons` — icon set
- `shared_preferences` — local key-value persistence

Add on demand:
- `sensors_plus` / `proximity_sensor` — device sensors
- `audioplayers`, `flutter_tts` — sound / speech
- `screenshot`, `share_plus` — capture and share content

Don't add a package "just in case" — pull it in only when a feature actually
needs it.

## Style

- Comments are sparse — only for non-obvious rationale (a workaround, a UX
  constraint, a subtle invariant). Never comment on what the code visibly does.
- Theme colors are dark-mode hex literals defined once in `main.dart`'s
  `ThemeData` and reused as `Color(0xFF...)` literals where needed, not pulled
  from a separate theme/constants file.
- No backend — all persistence is local (`shared_preferences`) unless the user
  asks for a server/API.
