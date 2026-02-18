import 'package:flutter/material.dart';

class DailyTaskProvider extends ChangeNotifier {
  DateTime? _completedDate;

  bool get isCompletedToday {
    if (_completedDate == null) return false;
    final today = DateTime.now();
    return _completedDate!.year == today.year &&
        _completedDate!.month == today.month &&
        _completedDate!.day == today.day;
  }

  void markCompleted() {
    _completedDate = DateTime.now();
    notifyListeners();
  }

  DateTime? get completedDate => _completedDate;
}
