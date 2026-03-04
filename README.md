# CommonGrounds

CommonGrounds is a Flutter-based student task and study management app designed to help students stay organized, manage assignments, plan study sessions, and improve productivity through reminders, AI assistance, and focus tools.

## Team Members - Group 10

| Name | Email | Role |
|------|-------|------|
| **Monina Angela Patiño** | lr.mapatino@mmdc.mcl.edu.ph | Owner |
| **Rick Cabugnason** | lr.rcabugnason@mmdc.mcl.edu.ph | Member |
| **Roxane Myles Andrade** | lr.rmandrade@mmdc.mcl.edu.ph | Member |

## Getting Started

To run this project locally, ensure you have [Flutter](https://flutter.dev/docs/get-started/install) installed on your machine.

### Prerequisites

- Flutter SDK
- Android Studio / Xcode (for mobile simulation)
- VS Code or Android Studio (IDE)

### Installation

1.  **Clone the repository:**
    ```bash
    git clone <repository-url>
    cd Common-GroundsG10MDA
    ```

2.  **Install dependencies:**
    ```bash
    flutter pub get
    ```

### How to Run

You can run the app on an emulator (Android/iOS) or in your web browser.

**Note:** This project supports **Local + Remote Data Management** using **SQLite (sqflite)**, **Firebase Firestore**, and a **REST API**. You can switch between these backends at runtime from the Tasks page.

**Run on Android/iOS Emulator:**
```bash
flutter run
```

**Run on Web:**
```bash
flutter run -d chrome
```

## Configuration

### Local (SQLite) Setup
- No setup required. The app creates a local SQLite database automatically on first run.

### Firebase Setup
1.  Ensure `android/app/google-services.json` is present in your project.
2.  Enable **Cloud Firestore** in your Firebase Console.
3.  Create a collection named `tasks`.

### REST API Setup
1.  Open `lib/config/app_config.dart`.
2.  Set the `restBaseUrl` to your API endpoint (e.g., a MockAPI.io URL).
    ```dart
    static const String restBaseUrl = 'https://your-api-endpoint.com/api/v1';
    ```

## Features

### Milestone 2: Data Management (Sprints 3 & 4)
- **Local + Remote Data Persistence**:
  - **SQLite (sqflite)**: Offline local task storage and CRUD.
  - **Firebase Firestore**: Cloud database integration for tasks.
  - **REST API**: HTTP-based CRUD operations for tasks (configurable endpoint).
- **Repository Pattern**:
  - Abstracted data layer allowing seamless switching between Local (SQLite), Firebase, and REST backends.
  - **Runtime Switching**: Toggle between backends directly from the Tasks page.
- **Data Synchronization**:
  - Create, Read, Update, and Delete (CRUD) operations are fully synchronized with the selected remote backend.
- **Local Fallback**:
  - Graceful handling of connection errors with fallback to local mock data for demonstration purposes.

### Sprint 1: User Input & Touch Events
- **User Input Handling**: 
  - Login form with validation (Email/Password).
  - Task creation form with Title, Subject, Priority, and Status fields.
  - Interactive Date Picker for deadline selection.
- **Touch Event Logic**:
  - `InkWell` and `GestureDetector` implementation for buttons and list items.
  - Interactive "Add Task" button with ripple effects.
  - Status toggling on task cards via tap gestures.

### Sprint 2: Navigation Implementation
- **Main Fragment Navigation**:
  - `BottomNavigationBar` to switch between Dashboard, Tasks, Calendar, Focus Mode, and Profile.
  - State preservation across tab switches.
- **Screen Transitions**:
  - Seamless navigation from Login to Main Dashboard.
  - Modal Bottom Sheets and Dialogs for task details.

## Challenges and Solutions

### 1. Form Validation & User Feedback
- **Challenge**: Providing immediate feedback when users submit empty forms or invalid data.
- **Solution**: Implemented `TextEditingController` to track input and wrapped submission logic with validation checks. Added `ScaffoldMessenger` to display `SnackBar` toasts for success/error messages, ensuring a smooth user experience.

### 2. Date Handling
- **Challenge**: Allowing users to easily select task deadlines without typing manually.
- **Solution**: Integrated Flutter's `showDatePicker` widget, constrained to reasonable date ranges (2020-2030), and formatted the output using the `intl` package for readability.

### 3. Navigation State Management
- **Challenge**: Keeping the Bottom Navigation bar synced with the current page content.
- **Solution**: Used a `StatefulWidget` for the `MainPage` to track the `_currentIndex` and dynamically rebuild the `body` based on the selected tab, ensuring the UI always reflects the active section.

### 4. Dual Backend Integration (Milestone 2)
- **Challenge**: Implementing both Firebase and REST API without duplicating UI logic.
- **Solution**: Adopted the **Repository Pattern**. We created an abstract `TaskRepository` class with `FirebaseTaskRepository` and `RestTaskRepository` implementations. The UI interacts only with the abstract interface, allowing us to swap backends dynamically.

### 5. Data Model Serialization (Milestone 2)
- **Challenge**: Ensuring Dart objects correctly map to both Firestore documents and JSON for REST APIs.
- **Solution**: Enhanced the `DetailedTask` model with robust `fromJson` and `toJson` methods that handle data type conversions (e.g., Dates to ISO strings, Timestamps) and nullable fields.

## Troubleshooting

If you encounter issues with Android licenses, run:
```bash
flutter doctor --android-licenses
```

**Emulator Issues:**
If your Android emulator gets stuck or won't launch:
1. Open **Android Studio > Device Manager**.
2. Click the three dots (⋮) next to your emulator.
3. Select **Wipe Data** and try again.

