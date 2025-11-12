import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/hike.dart';
import '../database/database_helper.dart';
import '../providers/hike_provider.dart';
import 'hike_form_screen.dart';

class HikeDetailScreen extends StatefulWidget {
  final int hikeId;

  HikeDetailScreen({required this.hikeId});

  @override
  _HikeDetailScreenState createState() => _HikeDetailScreenState();
}

class _HikeDetailScreenState extends State<HikeDetailScreen> {
  late Future<Hike?> _hikeFuture;

  @override
  void initState() {
    super.initState();
    _loadHike();
  }

  void _loadHike() {
    setState(() {
      _hikeFuture = DatabaseHelper.instance.getHike(widget.hikeId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Hike Details'),
      ),
      body: FutureBuilder<Hike?>(
        future: _hikeFuture,
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
                            Expanded(
                              child: Text(
                                hike.name,
                                style: Theme.of(context).textTheme.headlineSmall,
                              ),
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
                          _loadHike();
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
          Expanded(child: Text(value)),
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
