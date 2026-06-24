import 'package:flutter/material.dart';

class LocationProvider extends ChangeNotifier {
  String _city = '';
  String _state = '';
  bool _isLoading = true;
  String _error = '';

  String get city => _city;
  String get state => _state;
  bool get isLoading => _isLoading;
  String get error => _error;

  void setLocation({required String city, required String state}) {
    _city = city;
    _state = state;
    _isLoading = false;
    _error = '';
    notifyListeners();
  }

  void setLoading(bool loading) {
    _isLoading = loading;
    if (loading) {
      _error = '';
    }
    notifyListeners();
  }

  void setError(String err) {
    _error = err;
    _isLoading = false;
    notifyListeners();
  }
}


