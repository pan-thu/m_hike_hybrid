# M-Hike Flutter App

## Features
1. **Create Hike** - Add new hike with form validation
2. **List Hikes** - View all hikes in a scrollable list
3. **View Hike** - See full details of a selected hike
4. **Edit Hike** - Update existing hike information
5. **Delete Hike** - Remove hike with confirmation
6. **Reset Database** - Clear all data with confirmation

## Data Model

### Hike Table
```dart
class Hike {
  int? id;                    // Auto-increment
  String name;                // Required (3-100 chars)
  String location;            // Required (3-200 chars)
  DateTime date;              // Required
  double length;              // Required (0-1000 km)
  String difficulty;          // Required (EASY/MEDIUM/HARD)
  bool parkingAvailable;      // Required
  String? description;        // Optional (max 2000 chars)
  DateTime? createdAt;        // Auto-set
  DateTime? updatedAt;        // Auto-set
}
```

## Screen Specifications

### 1. Hike List Screen
- **Purpose**: Home screen showing all hikes
- **Elements**:
  - App bar with title and reset button
  - List of hike cards (name, location, date, difficulty)
  - Floating action button to add new hike
  - Empty state message when no hikes
- **Actions**:
  - Tap card → View details
  - Tap FAB → Create hike
  - Tap reset → Confirm dialog → Clear database

### 2. Create/Edit Hike Screen
- **Purpose**: Form to add or modify hike
- **Fields**:
  - Name (TextField)
  - Location (TextField)
  - Date (DatePicker)
  - Length in km (NumberField)
  - Difficulty (Dropdown: Easy/Medium/Hard)
  - Parking Available (Switch/Checkbox)
  - Description (TextField, multiline)
- **Validation**:
  - Required fields must be filled
  - Name: 3-100 characters
  - Location: 3-200 characters
  - Length: 0-1000 range
  - Description: max 2000 characters
- **Actions**:
  - Save → Validate → Store → Return to list/details
  - Cancel → Discard changes → Go back

### 3. Hike Detail Screen
- **Purpose**: Display full hike information
- **Layout**:
  - All hike fields displayed in readable format
  - Edit and Delete buttons
- **Actions**:
  - Edit → Open edit screen
  - Delete → Confirm dialog → Delete → Return to list
  - Back → Return to list

## Technical Requirements

### Database
- SQLite using sqflite package
- Single table: `hikes`
- Auto-increment ID
- Timestamps for created/updated

### State Management
- Use Provider or setState (keep it simple)
- No complex state patterns needed

### Navigation
- Simple push/pop navigation
- Pass hike ID or object between screens

### UI
- Material Design
- Basic form validation
- Loading indicators for database operations
- Snackbar for success/error messages

## User Flows

### Add First Hike
1. Open app → See empty state
2. Tap FAB → Form opens
3. Fill fields → Tap Save
4. Return to list → See new hike

### Edit Hike
1. Tap hike in list → Details open
2. Tap Edit → Form with current data
3. Modify → Save
4. Return to updated details

### Delete Hike
1. Open hike details
2. Tap Delete → "Are you sure?" dialog
3. Confirm → Hike removed
4. Return to list

### Reset Database
1. On list screen → Tap menu
2. Select Reset → Warning dialog
3. Confirm → All hikes deleted
4. Show empty state

## Success Criteria
- ✅ All CRUD operations work
- ✅ Data persists between app launches
- ✅ Form validation prevents bad data
- ✅ Confirmations prevent accidental deletions
- ✅ App doesn't crash
