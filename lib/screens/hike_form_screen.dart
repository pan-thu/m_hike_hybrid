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
