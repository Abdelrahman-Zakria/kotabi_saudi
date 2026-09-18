import 'package:flutter/foundation.dart';
import '../services/settings_service.dart';

class SettingsProvider extends ChangeNotifier {
  final SettingsService _settingsService = SettingsService();
  bool _initialized = false;

  double get fontSize => _settingsService.fontSize;
  bool get notificationsEnabled => _settingsService.notificationsEnabled;
  bool get isInitialized => _initialized;

  Future<void> initialize() async {
    await _settingsService.initialize();
    _initialized = true;
    notifyListeners();
  }

  Future<void> setFontSize(double size) async {
    await _settingsService.setFontSize(size);
    notifyListeners();
  }

  Future<void> setNotificationsEnabled(bool enabled) async {
    await _settingsService.setNotificationsEnabled(enabled);
    notifyListeners();
  }

  Future<void> clearAllData() async {
    await _settingsService.clearAllData();
    notifyListeners();
  }
}
