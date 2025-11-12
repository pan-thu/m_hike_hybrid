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
