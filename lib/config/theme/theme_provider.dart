import 'package:flutter/material.dart';

class ThemeProvider with ChangeNotifier {
  bool _isDarkTheme = false;

  bool get isDarkTheme => _isDarkTheme;

  void toggleTheme() {
    _isDarkTheme = !_isDarkTheme;
    notifyListeners(); // Notifica a todos los widgets dependientes
  }

  ThemeMode get themeMode => _isDarkTheme ? ThemeMode.dark : ThemeMode.light;
}
