# M-Hike Flutter App

A simple Flutter CRUD application for managing hiking records with local SQLite storage.

## Features
- Create, Read, Update, Delete hikes
- Reset database
- Local SQLite storage
- Form validation
- Works offline

## Tech Stack
- Flutter
- SQLite (sqflite)
- Provider (state management)
- Material Design

## Getting Started

### Prerequisites
- Flutter SDK (3.0.0 or higher)
- Dart SDK

### Installation

1. Clone the repository
2. Install dependencies:
```bash
flutter pub get
```

3. Run the app:
```bash
flutter run
```

### Building for Production

**Android:**
```bash
flutter build apk --release
```

**iOS:**
```bash
flutter build ios --release
```

## Project Structure
```
lib/
├── models/          # Data models (Hike)
├── database/        # SQLite database helper
├── providers/       # State management (Provider)
├── screens/         # UI screens (List, Form, Detail)
└── main.dart        # App entry point
```

## Usage

1. **Add a Hike**: Tap the + button on the main screen
2. **View Details**: Tap any hike card in the list
3. **Edit**: Open hike details and tap "Edit"
4. **Delete**: Open hike details and tap "Delete"
5. **Reset Database**: Use the menu in the top-right corner

## Data Model

Each hike includes:
- Name (required)
- Location (required)
- Date (required)
- Length in km (required)
- Difficulty (Easy/Medium/Hard)
- Parking availability
- Description (optional)
