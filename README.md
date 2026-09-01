# NEXUS 🚀

NEXUS is a modern Flutter-based learning and productivity app focused on Data Structures and Algorithms (DSA), project-based learning, and AI-assisted guidance. The app combines a personalized learning dashboard, Firebase authentication, Firestore data management, video tutorials, and a Gemini-powered chatbot to help users progress in coding skills.

## Overview

This project is designed for learners who want to:

- Explore DSA topics through structured learning cards
- Track concept progress and daily challenges
- Practice with curated project ideas
- Learn through YouTube-based video resources
- Ask an AI mentor questions through a chatbot
- Maintain a personal profile and streak-based motivation

## Key Features

- User authentication with Firebase
- Personalized learning dashboard and topic tracking
- Concept-based progress monitoring
- Daily challenge and streak tracking
- AI-powered chatbot using Gemini
- Project hub with searchable project cards
- Video learning screen with embedded YouTube player
- Profile management with image uploads via Supabase Storage
- Local persistence using Hive
- Dark-themed modern UI

## Tech Stack

- Flutter + Dart
- Firebase Auth
- Cloud Firestore
- Supabase
- Google Gemini API
- Provider for state management
- Hive for local storage
- YouTube IFrame player
- Iconsax and custom widgets for UI

## Project Structure

```text
NEXUS/
├── android/
├── ios/
├── lib/
│   ├── Models/
│   ├── Providers/
│   ├── Screens/
│   ├── widgets/
│   ├── firebase_options.dart
│   ├── main.dart
│   ├── navigation_bar.dart
│   └── Screens/services.dart
├── assets/
├── linux/
├── macos/
├── web/
├── windows/
├── analysis_options.yaml
├── firebase.json
├── pubspec.yaml
├── README.md
└── ...
```

## Prerequisites

Before running the app, make sure you have:

- Flutter SDK installed
- Dart SDK
- Android Studio / Xcode for device emulation
- Firebase project configured
- Supabase project configured
- Gemini API key

Recommended Flutter version:

```bash
flutter --version
```

This project is configured for Flutter SDK version compatible with the dependency set in `pubspec.yaml`.

## Getting Started

### 1. Clone the repository

```bash
git clone <your-repository-url>
cd NEXUS
```

### 2. Install dependencies

```bash
flutter pub get
```

### 3. Configure Firebase

This project already includes Firebase initialization via `lib/firebase_options.dart` and `lib/main.dart`.

For a fresh setup, run:

```bash
flutterfire configure
```

Then make sure the generated Firebase config is available for your target platform.

> Note: the current project includes a generated `firebase_options.dart`, but platform support may need to be regenerated depending on your environment.

### 4. Configure Supabase

The app initializes Supabase in `lib/main.dart` using credentials stored in `lib/Screens/services.dart`.

```dart
await Supabase.initialize(
  url: Secrets.supabaseUrl,
  anonKey: Secrets.supabaseKey,
);
```

For a production-ready setup, move these keys into environment variables or a secure config file instead of hardcoding them in source.

### 5. Configure Gemini API

The app uses Google Generative AI for recommendations and chatbot responses.

The API key is referenced in `lib/Providers/chart_provider.dart` and the constants file `lib/Screens/services.dart`.

### 6. Run the app

```bash
flutter run
```

To run on a specific device:

```bash
flutter devices
flutter run -d <device-id>
```

## Firebase and App Setup Notes

The app uses:

- Firebase Authentication for login/signup
- Cloud Firestore for user data, concepts, progress, projects, and badges
- Firebase Storage is not directly configured in the visible app entrypoint, but profile image upload flows rely on Supabase Storage

If your Firebase project is different from the one configured in this repo, you will need to:

1. Create a Firebase project
2. Enable Authentication (Email/Password)
3. Enable Firestore Database
4. Add Android app config and update `firebase_options.dart`
5. Download `google-services.json` for Android

## App Features in Detail

### Home Learning Experience

The home screen aggregates concept cards and learning paths based on difficulty and topic categories such as:

- Arrays
- Linked List
- Stack
- Queues
- Trees
- Graphs

### AI Chatbot

The chatbot screen allows users to interact with a Gemini-powered assistant for problem-solving and learning guidance. The conversation flow is managed through a `ChatProvider` and includes status handling for typing, generating, and errors.

### Project Hub

The project hub loads project metadata from Firestore and offers:

- Search by project name or topic
- Difficulty-based filtering
- Category selection
- Animated UI cards

### Video Learning

The app includes a video page and YouTube integration for learning resources via embedded players and metadata fetched from the YouTube Data API.

### Profile & Progress

The profile page offers:

- User stats
- Daily streak tracking
- Progress visuals
- Concept completion data
- Profile image uploads and updates

## Local Storage

The app initializes Hive boxes for:

- `userBox`
- `queryCountsBox`

This is used for user session and lightweight local state persistence.

## Environment Security

This repository currently contains sensitive values in source files, including Firebase and Supabase secrets. For production use, you should:

- Move API keys and project secrets to environment variables
- Add `.env` support or secure platform config
- Ensure keys are not committed to public repositories

## Common Commands

```bash
flutter clean
flutter pub get
flutter run
flutter build apk
flutter build appbundle
```

## Troubleshooting

### Firebase issues

- Run `flutterfire configure` again
- Ensure `google-services.json` exists in `android/app/`
- Verify the app package name matches your Firebase configuration

### Dependency issues

```bash
flutter pub cache repair
flutter pub get
```

### Build issues

```bash
flutter clean
flutter pub get
flutter run
```

## Contribution

Contributions are welcome. If you want to improve the app:

1. Fork the repository
2. Create a feature branch
3. Commit your changes
4. Open a pull request

## Author

Made with ❤️ by [Durga Prasad](https://github.com/durgaprasad-4426)

