# M-Hike Flutter Tech Stack

## What We're Using

### Core
- **Flutter** - Cross-platform framework
- **Dart** - Programming language
- **Material Design** - UI components

### Database
- **SQLite** (via `sqflite` package) - Local data storage
- Single table: `hikes`
- No cloud sync needed

### State Management
- **Provider** - Simple state management
- Why: Official Flutter recommendation for simple apps
- Alternative: Can use `setState()` if you prefer even simpler

### Key Packages
```yaml
dependencies:
  sqflite: ^2.3.0      # SQLite database
  path: ^1.8.3         # File path handling
  provider: ^6.1.1     # State management
  intl: ^0.18.1        # Date formatting
```

### Project Structure
```
lib/
├── models/          # Data classes
├── database/        # Database helper
├── providers/       # State management
├── screens/         # UI screens
└── main.dart        # App entry point
```

### Screens (Just 3)
1. **List Screen** - Shows all hikes
2. **Form Screen** - Create/Edit hike
3. **Detail Screen** - View single hike

### Features
- Create hike
- Read/List hikes
- Update hike
- Delete hike
- Reset database
- Form validation
- Local persistence

### What We're NOT Using
- ❌ Firebase/Cloud services
- ❌ Complex architecture patterns (BLoC, Redux, etc.)
- ❌ Code generation
- ❌ Dependency injection
- ❌ Navigation 2.0
- ❌ Custom themes
- ❌ Internationalization
- ❌ Analytics
- ❌ Crash reporting

### Platform Requirements
- Android: API 21+ (Android 5.0)
- iOS: 11.0+
- No special permissions needed

### Development Time
- ~13 hours total
- Can be built in 5 days working part-time
- Or 2 days full-time

### Why This Stack?
- **Simple** - No unnecessary complexity
- **Standard** - Uses Flutter's recommended patterns
- **Fast** - Quick to develop and iterate
- **Maintainable** - Easy to understand and modify
- **Reliable** - Well-tested packages

That's the entire tech stack. Simple CRUD, simple stack.