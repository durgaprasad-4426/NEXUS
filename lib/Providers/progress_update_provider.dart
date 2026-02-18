import 'package:flutter/widgets.dart';

class ProgressUpdateProvider extends ChangeNotifier{
  bool _scrollUpdatedProgress = false;

  bool get scrollUpdateProgress => _scrollUpdatedProgress;

  void toggleScrollProgress(){
    _scrollUpdatedProgress = !_scrollUpdatedProgress;
  }
}