# QR Generator

A comprehensive Flutter application for generating, scanning, and managing QR codes and barcodes.

## Features

*   **Authentication**: Secure user authentication using Firebase Auth.
*   **QR Generation**: Create various types of QR codes and barcodes.
*   **Scanning**: Built-in scanner to quickly read QR codes and barcodes from the camera or gallery images.
*   **History**: Automatically saves a history of generated and scanned codes for easy access.
*   **File Management**: Manage and organize files related to your QR codes.
*   **Firebase Integration**: Secure cloud storage for data and files using Cloud Firestore and Firebase Storage.

## Tech Stack

*   **Framework**: [Flutter](https://flutter.dev/) (SDK ^3.10.3)
*   **State Management**: [flutter_bloc](https://pub.dev/packages/flutter_bloc)
*   **Dependency Injection**: [get_it](https://pub.dev/packages/get_it)
*   **Navigation**: [go_router](https://pub.dev/packages/go_router)
*   **Backend Support**: Firebase (Authentication, Cloud Firestore, Cloud Storage)
*   **Local Storage**: `sqflite` for local databases, `shared_preferences` for app settings.
*   **QR/Barcode**: `qr_flutter`, `barcode_widget`, `mobile_scanner`

## Project Architecture

This project follows a feature-first architectural pattern to ensure scalability and maintainability.

*   `lib/app/`: Core application setup (routing, theme).
*   `lib/core/`: Shared resources, constants, dependency injection setup, base widgets, and permissions handling.
*   `lib/features/`: Contains the main feature modules of the application:
    *   `auth`: User login and registration.
    *   `home`: Main dashboard/navigation view.
    *   `qr_generator`: Logic and UI for creating codes.
    *   `scanner`: Logic and UI for scanning codes.
    *   `history`: Tracking past generated/scanned items.
    *   `files`: File management capabilities.

## Getting Started

### Prerequisites

*   [Flutter SDK](https://docs.flutter.dev/get-started/install) installed.
*   [CocoaPods](https://guides.cocoapods.org/using/getting-started.html) installed (for iOS).
*   A Firebase project set up. You will need to place your valid `GoogleService-Info.plist` (iOS) and `google-services.json` (Android) in the respective directories.

### Installation

1.  **Clone the repository**:
    ```bash
    git clone <repository-url>
    cd qr_generator
    ```

2.  **Install dependencies**:
    ```bash
    flutter pub get
    ```

3.  **Environment Setup**:
    *   Create a `.env` file in the root directory.
    *   Add required environment variables (e.g., API keys if applicable, though primarily Firebase config is used).

4.  **iOS Setup**:
    ```bash
    cd ios
    pod install --repo-update
    cd ..
    ```

### Running the App

To run the app on an attached device or emulator:

```bash
flutter run
```

## Useful Commands

*   **Analyze code**: `flutter analyze`
*   **Run unit tests**: `flutter test`
*   **Clean build cache**: `flutter clean`
