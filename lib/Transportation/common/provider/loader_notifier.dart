import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

class LoaderNotifier extends ChangeNotifier {
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  /// Show loader
  void showLoader() {
    if (_isLoading) return;
    _isLoading = true;
    _notifySafely();
  }

  /// Hide loader
  void hideLoader() {
    if (!_isLoading) return;
    _isLoading = false;
    _notifySafely();
  }

  void _notifySafely() {
    if (SchedulerBinding.instance.schedulerPhase == SchedulerPhase.idle) {
      notifyListeners();
      return;
    }

    SchedulerBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });
  }
}
