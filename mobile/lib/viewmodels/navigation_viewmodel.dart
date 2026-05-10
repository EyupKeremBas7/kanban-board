import 'package:flutter/material.dart';

class NavigationViewModel extends ChangeNotifier {
  int _currentIndex = 0;
  String? _selectedWorkspaceId;

  int get currentIndex => _currentIndex;
  String? get selectedWorkspaceId => _selectedWorkspaceId;

  void setIndex(int index) {
    _currentIndex = index;
    notifyListeners();
  }

  void navigateToWorkspaceBoards(String workspaceId) {
    _selectedWorkspaceId = workspaceId;
    _currentIndex = 0; // Boards tab
    notifyListeners();
  }

  void clearWorkspaceFilter() {
    _selectedWorkspaceId = null;
    notifyListeners();
  }
}
