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
