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

**Run on Android/iOS Emulator:**
```bash
flutter run
```

**Run on Web:**
```bash
flutter run -d chrome
```

## Features

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

