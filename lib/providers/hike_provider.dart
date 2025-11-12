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
