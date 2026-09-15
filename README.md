# mekenetinsurance Mobile - Enterprise Flutter App

Enterprise-grade insurance management mobile application built with Flutter, following Clean Architecture principles.

## 🏗️ Architecture

**Clean Architecture** with four layers:
- **Domain**: Entities, repositories (interfaces), and use cases
- **Data**: Repository implementations, data sources (remote/local), and DTOs
- **Presentation**: Pages, widgets, and Riverpod providers
- **Core**: Shared utilities, config, error handling, networking

## 🚀 Features

### Core Functionality
- ✅ JWT Authentication (login, register, session management)
- ✅ Multi-language support (English, Amharic)
- ✅ Dark/Light theme with Material 3
- ✅ Biometric & PIN login
- ✅ Offline-first architecture with caching
- ✅ Auto-retry failed requests
- ✅ Connectivity detection

### Insurance Features
- 📋 Browse and apply for policies
- 🛡️ View active policies with digital card
- 📝 Submit and track claims
- 💳 Payment history with receipt upload
- 📄 Document management
- 🔔 Push notifications
- 👤 Profile management
- 💬 Support and FAQ

## 📦 Tech Stack

| Category | Package |
|----------|---------|
| **State Management** | Riverpod 2.x (riverpod_generator) |
| **Routing** | GoRouter 14.x |
| **Networking** | Dio 5.x with interceptors |
| **Code Generation** | Freezed, json_serializable |
| **DI** | GetIt + Injectable |
| **Local Storage** | Hive, FlutterSecureStorage, SharedPreferences |
| **UI** | Material 3, Google Fonts, Lottie, Shimmer |
| **Localization** | Easy Localization |
| **Charts** | Syncfusion Flutter Charts |

## 🛠️ Setup

### Prerequisites
- Flutter SDK 3.7.2+
- Dart 3.x
- Android Studio / Xcode
- VS Code (recommended)

### Installation

1. **Clone the repository**
   ```bash
   cd D:\ANT\Insurance\mekenetinsurance-Mobile
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run code generation**
   ```bash
   dart run build_runner build --delete-conflicting-outputs
   ```

4. **Update API Base URL**
   
   Edit `lib/core/constants/app_constants.dart`:
   ```dart
   static const String baseUrl = 'http://YOUR_SERVER_IP:9050/api';
   ```

5. **Run the app**
   ```bash
   flutter run
   ```

## 📁 Project Structure

```
lib/
├── core/
│   ├── config/           # DI, routing, app config
│   ├── constants/        # App constants, API endpoints
│   ├── error/            # Failures, exceptions
│   ├── network/          # Dio client, interceptors
│   ├── storage/          # Local storage services
│   └── utils/            # Validators, formatters, helpers
│
├── features/
│   ├── authentication/
│   │   ├── data/
│   │   │   ├── datasources/   # Remote API calls
│   │   │   ├── models/        # DTOs with json_serializable
│   │   │   └── repositories/  # Repository implementations
│   │   ├── domain/
│   │   │   ├── entities/      # Business models
│   │   │   └── repositories/  # Repository interfaces
│   │   └── presentation/
│   │       ├── pages/         # UI screens
│   │       ├── providers/     # Riverpod state
│   │       └── widgets/       # Reusable widgets
│   │
│   ├── dashboard/
│   ├── policies/
│   ├── claims/
│   ├── payments/
│   ├── profile/
│   ├── notifications/
│   ├── documents/
│   ├── settings/
│   └── support/
│
└── shared/
    ├── theme/            # Colors, text styles, themes
    ├── widgets/          # Reusable components
    ├── extensions/       # Dart extensions
    └── pages/            # Generic pages (404, about, etc.)
```

## 🔧 Code Generation

The project uses code generation for:
- **Riverpod providers** (`riverpod_generator`)
- **JSON serialization** (`json_serializable`)
- **Immutable models** (`freezed`)
- **Dependency injection** (`injectable`)
- **Routing** (`go_router`)

Run generation:
```bash
# One-time
dart run build_runner build --delete-conflicting-outputs

# Watch mode (auto-rebuild on file changes)
dart run build_runner watch --delete-conflicting-outputs
```

## 🌍 Localization

Translations are stored in `assets/translations/`:
- `en.json` - English
- `am.json` - Amharic (አማርኛ)

Usage:
```dart
Text('auth.login'.tr())
```

## 🎨 Theming

Themes are defined in `lib/shared/theme/`:
- `app_colors.dart` - Brand colors
- `app_text_styles.dart` - Typography
- `app_theme.dart` - Material 3 themes

Switch theme:
```dart
ref.read(themeModeProvider.notifier).state = 'dark';
```

## 🔐 Authentication Flow

1. User enters email/password
2. App calls `/api/auth/login`
3. Server returns JWT tokens
4. Tokens stored in FlutterSecureStorage
5. AuthInterceptor adds Bearer token to all requests
6. On 401, TokenRefreshService attempts refresh
7. On refresh failure, user is logged out

## 🧪 Testing

```bash
# Run all tests
flutter test

# Run with coverage
flutter test --coverage

# Integration tests
flutter test integration_test
```

## 📱 Build

### Android
```bash
flutter build apk --release
flutter build appbundle --release
```

### iOS
```bash
flutter build ios --release
cd ios && pod install && cd ..
flutter build ipa
```

## 🚀 Deployment

### Android
1. Update `android/app/build.gradle` with signing config
2. Build release: `flutter build appbundle --release`
3. Upload to Google Play Console

### iOS
1. Configure signing in Xcode
2. Build archive: `flutter build ipa`
3. Upload to App Store Connect

## 🐛 Troubleshooting

**Build errors after adding dependencies:**
```bash
flutter clean
flutter pub get
dart run build_runner build --delete-conflicting-outputs
```

**Hive errors:**
```bash
flutter packages pub run build_runner clean
dart run build_runner build --delete-conflicting-outputs
```

**Code generation conflicts:**
```bash
find . -name "*.g.dart" -delete
find . -name "*.freezed.dart" -delete
dart run build_runner build --delete-conflicting-outputs
```

## 📝 Notes

- **API Integration**: All endpoints match the mekenetinsurance backend REST API
- **Multi-tenancy**: The app respects tenant isolation via JWT
- **Offline Support**: Hive caches responses; connectivity detection prevents offline requests
- **Security**: Tokens stored in FlutterSecureStorage with encryption
- **Error Handling**: Uses Either<Failure, Success> pattern instead of throwing exceptions

## 📄 License

Proprietary - mekenetinsurance Enterprise Application

## 👥 Support

For issues or questions:
- Email: support@mekenetinsurance.com
- Documentation: Check the `/documentation` folder in the backend project

---

Built with ❤️ using Flutter & Clean Architecture
