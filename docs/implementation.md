# M-Hike Flutter Implementation Plan

## Quick Start (Day 1)

### Step 1: Create Project
```bash
flutter create m_hike --org com.example
cd m_hike
```

### Step 2: Add Dependencies
```yaml
# pubspec.yaml
dependencies:
  flutter:
    sdk: flutter
  sqflite: ^2.3.0
  path: ^1.8.3
  provider: ^6.1.1
  intl: ^0.18.1

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^3.0.0
```

### Step 3: Create Folder Structure
```
lib/
├── models/
│   └── hike.dart
├── database/
│   └── database_helper.dart
├── screens/
│   ├── hike_list_screen.dart
│   ├── hike_form_screen.dart
│   └── hike_detail_screen.dart
├── providers/
│   └── hike_provider.dart
└── main.dart
```

---

## Implementation Steps (Days 2-5)

### Day 2: Core Setup

#### 1. Create Hike Model
```dart
// models/hike.dart
class Hike {
  int? id;
  String name;
  String location;
  DateTime date;
  double length;
  String difficulty;
  bool parkingAvailable;
  String? description;
  DateTime? createdAt;
  DateTime? updatedAt;

  Hike({
    this.id,
    required this.name,
    required this.location,
    required this.date,
    required this.length,
    required this.difficulty,
    required this.parkingAvailable,
    this.description,
    this.createdAt,
    this.updatedAt,
  });

  // Convert to/from Map for database
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'location': location,
      'date': date.millisecondsSinceEpoch,
      'length': length,
      'difficulty': difficulty,
      'parkingAvailable': parkingAvailable ? 1 : 0,
      'description': description,
      'createdAt': createdAt?.millisecondsSinceEpoch ?? DateTime.now().millisecondsSinceEpoch,
      'updatedAt': updatedAt?.millisecondsSinceEpoch ?? DateTime.now().millisecondsSinceEpoch,
    };
  }

  factory Hike.fromMap(Map<String, dynamic> map) {
    return Hike(
      id: map['id'],
      name: map['name'],
      location: map['location'],
      date: DateTime.fromMillisecondsSinceEpoch(map['date']),
      length: map['length'],
      difficulty: map['difficulty'],
      parkingAvailable: map['parkingAvailable'] == 1,
      description: map['description'],
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt']),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updatedAt']),
    );
  }
}
```

#### 2. Create Database Helper
```dart
// database/database_helper.dart
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/hike.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('hikes.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE hikes (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        location TEXT NOT NULL,
        date INTEGER NOT NULL,
        length REAL NOT NULL,
        difficulty TEXT NOT NULL,
        parkingAvailable INTEGER NOT NULL,
        description TEXT,
        createdAt INTEGER NOT NULL,
        updatedAt INTEGER NOT NULL
      )
    ''');
  }

  // CRUD Operations
  Future<int> createHike(Hike hike) async {
    final db = await database;
    return await db.insert('hikes', hike.toMap());
  }

  Future<List<Hike>> getAllHikes() async {
    final db = await database;
    final result = await db.query('hikes', orderBy: 'createdAt DESC');
    return result.map((map) => Hike.fromMap(map)).toList();
  }

  Future<Hike?> getHike(int id) async {
    final db = await database;
    final maps = await db.query(
      'hikes',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return Hike.fromMap(maps.first);
    }
    return null;
  }

  Future<int> updateHike(Hike hike) async {
    final db = await database;
    hike.updatedAt = DateTime.now();
    return await db.update(
      'hikes',
      hike.toMap(),
      where: 'id = ?',
      whereArgs: [hike.id],
    );
  }

  Future<int> deleteHike(int id) async {
    final db = await database;
    return await db.delete(
      'hikes',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> resetDatabase() async {
    final db = await database;
    await db.delete('hikes');
  }
}
```

### Day 3: State Management & List Screen

#### 3. Create Provider
```dart
// providers/hike_provider.dart
import 'package:flutter/material.dart';
import '../models/hike.dart';
import '../database/database_helper.dart';

class HikeProvider extends ChangeNotifier {
  List<Hike> _hikes = [];
  bool _isLoading = false;

  List<Hike> get hikes => _hikes;
  bool get isLoading => _isLoading;

  Future<void> loadHikes() async {
    _isLoading = true;
    notifyListeners();

    _hikes = await DatabaseHelper.instance.getAllHikes();

    _isLoading = false;
    notifyListeners();
  }

  Future<void> addHike(Hike hike) async {
    await DatabaseHelper.instance.createHike(hike);
    await loadHikes();
  }

  Future<void> updateHike(Hike hike) async {
    await DatabaseHelper.instance.updateHike(hike);
    await loadHikes();
  }

  Future<void> deleteHike(int id) async {
    await DatabaseHelper.instance.deleteHike(id);
    await loadHikes();
  }

  Future<void> resetDatabase() async {
    await DatabaseHelper.instance.resetDatabase();
    await loadHikes();
  }
}
```

#### 4. Create List Screen
```dart
// screens/hike_list_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/hike_provider.dart';
import 'hike_form_screen.dart';
import 'hike_detail_screen.dart';

class HikeListScreen extends StatefulWidget {
  @override
  _HikeListScreenState createState() => _HikeListScreenState();
}

class _HikeListScreenState extends State<HikeListScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() =>
      Provider.of<HikeProvider>(context, listen: false).loadHikes()
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Hikes'),
        actions: [
          PopupMenuButton(
            onSelected: (value) {
              if (value == 'reset') {
                _showResetDialog(context);
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'reset',
                child: Text('Reset Database'),
              ),
            ],
          ),
        ],
      ),
      body: Consumer<HikeProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return Center(child: CircularProgressIndicator());
          }

          if (provider.hikes.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.hiking, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('No hikes yet', style: TextStyle(fontSize: 18)),
                  SizedBox(height: 8),
                  Text('Tap + to add your first hike'),
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: provider.hikes.length,
            itemBuilder: (context, index) {
              final hike = provider.hikes[index];
              return Card(
                margin: EdgeInsets.all(8),
                child: ListTile(
                  title: Text(hike.name),
                  subtitle: Text(
                    '${hike.location} • ${DateFormat('MMM dd, yyyy').format(hike.date)}'
                  ),
                  trailing: Chip(
                    label: Text(
                      hike.difficulty.toUpperCase(),
                      style: TextStyle(color: Colors.white, fontSize: 12),
                    ),
                    backgroundColor: _getDifficultyColor(hike.difficulty),
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => HikeDetailScreen(hikeId: hike.id!),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => HikeFormScreen()),
          );
        },
        child: Icon(Icons.add),
      ),
    );
  }

  Color _getDifficultyColor(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'easy':
        return Colors.green;
      case 'medium':
        return Colors.orange;
      case 'hard':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  void _showResetDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Reset Database?'),
        content: Text('This will delete all hikes. This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Provider.of<HikeProvider>(context, listen: false).resetDatabase();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Database reset successfully')),
              );
            },
            child: Text('Reset', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
```

### Day 4: Form Screen

#### 5. Create Form Screen
```dart
// screens/hike_form_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/hike.dart';
import '../providers/hike_provider.dart';

class HikeFormScreen extends StatefulWidget {
  final Hike? hike; // null for create, existing hike for edit

  HikeFormScreen({this.hike});

  @override
  _HikeFormScreenState createState() => _HikeFormScreenState();
}

class _HikeFormScreenState extends State<HikeFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _locationController;
  late TextEditingController _lengthController;
  late TextEditingController _descriptionController;
  late DateTime _selectedDate;
  String _selectedDifficulty = 'easy';
  bool _parkingAvailable = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.hike?.name ?? '');
    _locationController = TextEditingController(text: widget.hike?.location ?? '');
    _lengthController = TextEditingController(text: widget.hike?.length.toString() ?? '');
    _descriptionController = TextEditingController(text: widget.hike?.description ?? '');
    _selectedDate = widget.hike?.date ?? DateTime.now();
    _selectedDifficulty = widget.hike?.difficulty ?? 'easy';
    _parkingAvailable = widget.hike?.parkingAvailable ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.hike != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Edit Hike' : 'New Hike'),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Name *',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Name is required';
                  }
                  if (value.length < 3) {
                    return 'Name must be at least 3 characters';
                  }
                  if (value.length > 100) {
                    return 'Name must be less than 100 characters';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _locationController,
                decoration: InputDecoration(
                  labelText: 'Location *',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Location is required';
                  }
                  if (value.length < 3) {
                    return 'Location must be at least 3 characters';
                  }
                  if (value.length > 200) {
                    return 'Location must be less than 200 characters';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              InkWell(
                onTap: () => _selectDate(context),
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: 'Date *',
                    border: OutlineInputBorder(),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(DateFormat('MMM dd, yyyy').format(_selectedDate)),
                      Icon(Icons.calendar_today),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _lengthController,
                decoration: InputDecoration(
                  labelText: 'Length (km) *',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Length is required';
                  }
                  final length = double.tryParse(value);
                  if (length == null) {
                    return 'Please enter a valid number';
                  }
                  if (length < 0 || length > 1000) {
                    return 'Length must be between 0 and 1000 km';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedDifficulty,
                decoration: InputDecoration(
                  labelText: 'Difficulty *',
                  border: OutlineInputBorder(),
                ),
                items: ['easy', 'medium', 'hard'].map((difficulty) {
                  return DropdownMenuItem(
                    value: difficulty,
                    child: Text(difficulty.toUpperCase()),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedDifficulty = value!;
                  });
                },
              ),
              SizedBox(height: 16),
              SwitchListTile(
                title: Text('Parking Available'),
                value: _parkingAvailable,
                onChanged: (value) {
                  setState(() {
                    _parkingAvailable = value;
                  });
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                validator: (value) {
                  if (value != null && value.length > 2000) {
                    return 'Description must be less than 2000 characters';
                  }
                  return null;
                },
              ),
              SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text('Cancel'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey,
                    ),
                  ),
                  ElevatedButton(
                    onPressed: _saveHike,
                    child: Text('Save'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _saveHike() async {
    if (_formKey.currentState!.validate()) {
      final hike = Hike(
        id: widget.hike?.id,
        name: _nameController.text,
        location: _locationController.text,
        date: _selectedDate,
        length: double.parse(_lengthController.text),
        difficulty: _selectedDifficulty,
        parkingAvailable: _parkingAvailable,
        description: _descriptionController.text.isEmpty ? null : _descriptionController.text,
        createdAt: widget.hike?.createdAt,
        updatedAt: DateTime.now(),
      );

      final provider = Provider.of<HikeProvider>(context, listen: false);

      if (widget.hike != null) {
        await provider.updateHike(hike);
      } else {
        await provider.addHike(hike);
      }

      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(widget.hike != null ? 'Hike updated' : 'Hike created')),
      );
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _locationController.dispose();
    _lengthController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}
```

### Day 5: Detail Screen & Final Setup

#### 6. Create Detail Screen
```dart
// screens/hike_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/hike.dart';
import '../database/database_helper.dart';
import '../providers/hike_provider.dart';
import 'hike_form_screen.dart';

class HikeDetailScreen extends StatelessWidget {
  final int hikeId;

  HikeDetailScreen({required this.hikeId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Hike Details'),
      ),
      body: FutureBuilder<Hike?>(
        future: DatabaseHelper.instance.getHike(hikeId),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          final hike = snapshot.data!;

          return SingleChildScrollView(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Card(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              hike.name,
                              style: Theme.of(context).textTheme.headlineSmall,
                            ),
                            Chip(
                              label: Text(
                                hike.difficulty.toUpperCase(),
                                style: TextStyle(color: Colors.white),
                              ),
                              backgroundColor: _getDifficultyColor(hike.difficulty),
                            ),
                          ],
                        ),
                        SizedBox(height: 16),
                        _buildInfoRow(Icons.location_on, 'Location', hike.location),
                        _buildInfoRow(Icons.calendar_today, 'Date',
                          DateFormat('MMMM dd, yyyy').format(hike.date)),
                        _buildInfoRow(Icons.straighten, 'Length', '${hike.length} km'),
                        _buildInfoRow(Icons.local_parking, 'Parking',
                          hike.parkingAvailable ? 'Available' : 'Not available'),
                        if (hike.description != null) ...[
                          SizedBox(height: 16),
                          Text('Description', style: TextStyle(fontWeight: FontWeight.bold)),
                          SizedBox(height: 8),
                          Text(hike.description!),
                        ],
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => HikeFormScreen(hike: hike),
                          ),
                        ).then((_) {
                          // Refresh the screen when returning from edit
                          (context as Element).markNeedsBuild();
                        });
                      },
                      icon: Icon(Icons.edit),
                      label: Text('Edit'),
                    ),
                    ElevatedButton.icon(
                      onPressed: () => _deleteHike(context, hike),
                      icon: Icon(Icons.delete),
                      label: Text('Delete'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey),
          SizedBox(width: 8),
          Text('$label: ', style: TextStyle(fontWeight: FontWeight.bold)),
          Text(value),
        ],
      ),
    );
  }

  Color _getDifficultyColor(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'easy':
        return Colors.green;
      case 'medium':
        return Colors.orange;
      case 'hard':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  void _deleteHike(BuildContext context, Hike hike) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Hike?'),
        content: Text('Are you sure you want to delete "${hike.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              await Provider.of<HikeProvider>(context, listen: false)
                  .deleteHike(hike.id!);
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Go back to list
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Hike deleted')),
              );
            },
            child: Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
```

#### 7. Setup Main App
```dart
// main.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/hike_provider.dart';
import 'screens/hike_list_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => HikeProvider(),
      child: MaterialApp(
        title: 'M-Hike',
        theme: ThemeData(
          primarySwatch: Colors.green,
          useMaterial3: true,
        ),
        home: HikeListScreen(),
      ),
    );
  }
}
```

---

## Testing Checklist

### Basic Functionality
- [ ] App launches without errors
- [ ] Can create a new hike
- [ ] Form validation works
- [ ] Can view list of hikes
- [ ] Can tap hike to see details
- [ ] Can edit existing hike
- [ ] Can delete hike with confirmation
- [ ] Can reset database with confirmation
- [ ] Data persists after app restart

### Edge Cases
- [ ] Empty state shows when no hikes
- [ ] Very long text is handled properly
- [ ] Date picker works correctly
- [ ] Number input accepts only valid numbers
- [ ] Required fields show errors

---

## Deployment

### Build for Android
```bash
flutter build apk --release
```

### Build for iOS
```bash
flutter build ios --release
```

---

## Total Time Estimate
- **Day 1**: Project setup and dependencies (2 hours)
- **Day 2**: Model and database (3 hours)
- **Day 3**: Provider and list screen (3 hours)
- **Day 4**: Form screen with validation (3 hours)
- **Day 5**: Detail screen and testing (2 hours)

**Total**: ~13 hours of development time

---

## That's It!
You now have a working CRUD app for managing hikes. No over-engineering, just a simple, functional Flutter application.