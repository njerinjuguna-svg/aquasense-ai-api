import 'package:flutter/material.dart';

class OnboardingProvider extends ChangeNotifier {
  int _currentPage = 0;
  final int totalPages;

  OnboardingProvider({required this.totalPages});

  int get currentPage => _currentPage;

  void setPage(int page) {
   if (page >= 0 && page < totalPages) {
     _currentPage = page;
      notifyListeners();
   }
   
  }

  bool canGoNext() =>  _currentPage < totalPages - 1;
  

  void nextPage() {
    if (canGoNext()) {
      _currentPage++;
      notifyListeners();
    }
  }
}