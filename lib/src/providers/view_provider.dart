import 'package:flutter/material.dart';

class ViewProvider extends ChangeNotifier {
  int _currentIndex = 0; // 0 = Lista, 1 = Mapa

  int get currentIndex => _currentIndex;

  void changeView(int index) {
    _currentIndex = index;
    notifyListeners(); // Notifica a los widgets que hay un cambio
  }
}
