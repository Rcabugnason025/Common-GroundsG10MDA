# CommonGrounds

CommonGrounds is a Flutter app for students who want one place to plan tasks, track deadlines, and stay consistent with study routines.

## Team Members - Group 10

| Name | Email | Role |
|------|-------|------|
| **Monina Angela Patiño** | lr.mapatino@mmdc.mcl.edu.ph | Owner |
| **Rick Cabugnason** | lr.rcabugnason@mmdc.mcl.edu.ph | Member |
| **Roxane Myles Andrade** | lr.rmandrade@mmdc.mcl.edu.ph | Member |

## Getting Started

Make sure you have [Flutter](https://flutter.dev/docs/get-started/install) installed.

### Prerequisites

- Flutter SDK
- Android Studio (for Android emulator) or Xcode (for iOS simulator)
- VS Code or Android Studio

### Installation

1.  **Clone the repository**
    ```bash
    git clone <repository-url>
    cd Common-GroundsG10MDA
    ```

2.  **Install dependencies**
    ```bash
    flutter pub get
    ```

### How to Run

Run on an emulator/device:
```bash
flutter run
```

Run on Windows desktop:
```bash
flutter run -d windows
```

Run on Web (Chrome):
```bash
flutter run -d chrome
```

## Configuration

### Local Database (SQLite)
No setup needed. The app creates a local database automatically on first run.

### Firebase (Cloud Firestore)
Firebase is already wired in via:
- `android/app/google-services.json`
- `lib/firebase_options.dart`

To test Firestore saving, make sure Cloud Firestore is enabled in the Firebase Console.

### REST API
If you want to demo the REST backend, set your API base URL here: `lib/config/app_config.dart`

Example:
```dart
class AppConfig {
  static const String restBaseUrl = 'https://your-api-endpoint.com/api/v1';
}
```

## Features

### Milestone 2 (Data Management)
- Tasks support CRUD using three backends: SQLite (local), Firebase Firestore, and REST.
- The Tasks page lets you switch the backend at runtime so it’s easy to demo.

### Sign Up Flow
After creating an account, the app shows a short Welcome screen, then you can continue to the dashboard.

## Troubleshooting

If you encounter issues with Android licenses, run:
```bash
flutter doctor --android-licenses
```

If builds fail, this usually helps:
```bash
flutter clean
flutter pub get
```

