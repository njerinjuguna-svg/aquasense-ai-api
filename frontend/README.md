# 💧 AquaSense

**Real-time wastewater monitoring with AI-powered insights.**

AquaSense is a cross-platform Flutter application that helps environmental engineers and facility operators monitor wastewater quality parameters in real time, receive intelligent alerts, and get AI-driven advisory recommendations.

---

## 📸 Screenshots

> _Coming soon — add screenshots to `assets/screenshots/` and reference them here._

---

## ✨ Features

| Feature | Description |
|---------|-------------|
| **Onboarding** | Three-step illustrated walkthrough for first-time users |
| **Authentication** | Email/password sign-up & sign-in with OTP email verification |
| **Session Persistence** | "Remember me" support via SharedPreferences — auto-login on cold start |
| **Home Dashboard** | Welcome banner, scoped search, and recent sensor overview |
| **Sensor Management** | View, add (5-step wizard), edit, and search sensors |
| **Sensor Detail** | Live reading, risk badge, compliance status, trend indicator, and AI advisory card |
| **AI Advisory Chat** | Context-aware conversational assistant per sensor |
| **Alerts** | Filterable alert list (All / Alerts / Anomalies / Compliance) with search |
| **Settings** | Profile card, notification bell, and menu items |

---

## 🏗️ Architecture

The project follows a **layered architecture** with clear separation of concerns:

```
lib/
├── core/                  # App-wide constants and theming
│   ├── constants/
│   │   └── app_routes.dart        # Centralised named route strings
│   └── theme/
│       └── app_theme.dart         # AppColors, AppTextStyles, AppTheme
│
├── models/                # Plain Dart data classes
│   ├── alert_model.dart
│   ├── chat_message.dart
│   ├── onboarding_model.dart
│   ├── sensor_model.dart          # SensorModel, enums, AddSensorForm
│   ├── settings_item.dart
│   └── user_model.dart            # JSON serialisation for persistence
│
├── providers/             # State management (ChangeNotifier + Provider)
│   ├── alert_provider.dart        # Alert list, filter, search
│   ├── auth_provider.dart         # Auth flow, OTP, session restore
│   ├── chat_provider.dart         # Per-sensor AI chat (scoped)
│   ├── onboarding_provider.dart   # Page index tracking
│   └── sensor_provider.dart       # CRUD, wizard, per-screen search
│
├── repositories/          # Data access layer (abstract + mock)
│   └── sensor_repository.dart     # SensorRepository / MockSensorRepository
│
├── screens/               # Full-page route destinations
│   ├── ai_chat/
│   ├── alerts/
│   ├── auth/              # Sign-in, Create Account, OTP, Verified
│   ├── home/              # HomeScreen + MainShell (bottom nav)
│   ├── onboarding/
│   ├── sensors/           # List, Detail, AI Advisory
│   ├── settings/
│   └── splash/
│
├── widgets/               # Reusable UI components (grouped by feature)
│   ├── ai_chat/
│   ├── alerts/
│   ├── auth/
│   ├── common/            # AppButton, AppTextField, AppLogo, etc.
│   ├── home/
│   ├── sensors/           # SensorCard, AddSensorSheet, EditSensorSheet
│   └── settings/
│
└── main.dart              # App entry point, MultiProvider, MaterialApp
```

### Data Flow

```
Screen / Widget
      │  reads via Consumer<T> or context.watch<T>()
      ▼
  Provider (ChangeNotifier)
      │  calls methods on
      ▼
  Repository (abstract interface)
      │  currently implemented by
      ▼
  MockSensorRepository (in-memory sample data)
```

---

## 🛠️ Tech Stack

| Layer | Technology |
|-------|-----------|
| **Framework** | Flutter 3.x (Dart SDK ^3.0.4) |
| **State Management** | [provider](https://pub.dev/packages/provider) ^6.1.1 |
| **Fonts** | [google_fonts](https://pub.dev/packages/google_fonts) ^8.0.2 (DM Sans) |
| **Persistence** | [shared_preferences](https://pub.dev/packages/shared_preferences) ^2.0.15 |
| **UI Extras** | [smooth_page_indicator](https://pub.dev/packages/smooth_page_indicator), [flutter_svg](https://pub.dev/packages/flutter_svg), [cupertino_icons](https://pub.dev/packages/cupertino_icons) |
| **Platforms** | Android, iOS, Linux, Windows, macOS, Web |

---

## 🚀 Getting Started

### Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install) (channel stable, ≥ 3.10)
- Android Studio / Xcode (for emulators) or a physical device
- Git

### Installation

```bash
# 1. Clone the repository
git clone https://github.com/<your-org>/aquasense.git
cd aquasense

# 2. Install dependencies
flutter pub get

# 3. Run the app
flutter run
```

### Running on a specific device

```bash
# List available devices
flutter devices

# Run on a specific device
flutter run -d <device-id>
```

---

## 🔐 Authentication Flow

```
SplashScreen
    │
    ├── restoreSession() succeeds → MainShell (Home)
    │
    └── No saved session
         │
         ├── OnboardingScreen → CreateAccountScreen
         │                          │
         │                          ▼
         │                   EmailVerificationScreen (OTP)
         │                          │
         │                          ▼
         │                   EmailVerifiedScreen → MainShell
         │
         └── SignInScreen
                  │
                  ├── Stored verified session → MainShell (skip OTP)
                  │
                  └── New session → EmailVerificationScreen (OTP)
                                        │
                                        ▼
                                  EmailVerifiedScreen → MainShell
```

**OTP Testing:** During development, the generated OTP is printed to the debug console:
```
AquaSense OTP for user@example.com: 48271
```

---

## 📁 Key Files

| File | Purpose |
|------|---------|
| `lib/main.dart` | App entry point — providers, routes, theme |
| `lib/core/theme/app_theme.dart` | Centralised colours, text styles, and ThemeData |
| `lib/core/constants/app_routes.dart` | All named route strings |
| `lib/providers/auth_provider.dart` | Full auth lifecycle with OTP and session persistence |
| `lib/providers/sensor_provider.dart` | Sensor CRUD, wizard state, per-screen search |
| `lib/repositories/sensor_repository.dart` | Abstract repo + mock implementation |
| `lib/models/sensor_model.dart` | Sensor domain model with enums and form classes |
| `lib/screens/home/main_shell.dart` | Bottom navigation shell with 4 tabs + AI FAB |

---

## 🧪 Testing

> Tests are not yet implemented. To run the test suite once tests are added:

```bash
# Unit and widget tests
flutter test

# Integration tests
flutter test integration_test/
```

---

## 📝 Design Decisions

1. **Provider over Riverpod** — chosen for simplicity and team familiarity; the abstract repository pattern makes migration straightforward if needed.
2. **Mock-first development** — all data sources are mock implementations behind abstract interfaces, allowing UI development to proceed independently of backend work.
3. **Per-screen search scoping** — `SensorSearchScope` enum ensures the Home and Sensors tab searches are independent.
4. **Scoped ChatProvider** — instantiated per `AiChatScreen` session (not global) so each conversation starts fresh.
5. **Centralised theming** — no raw `Color(0x...)` literals in widget files; every colour and text style lives in `app_theme.dart`.

---

## 🗺️ Roadmap

- [ ] Integrate real backend (Firebase / Supabase / custom API)
- [ ] Real-time sensor data via MQTT or WebSockets
- [ ] Charts and historical data visualization
- [ ] Push notifications for threshold breaches
- [ ] Dark mode theme
- [ ] Offline-first caching with local database
- [ ] Export sensor data as CSV/PDF reports
- [ ] Unit, widget, and integration tests
- [ ] CI/CD pipeline (GitHub Actions)

---

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

---

## 📄 License

This project is private and not published to pub.dev. Contact the maintainers for licensing information.

---

## 📬 Contact

For questions or feedback, reach out to the development team.
