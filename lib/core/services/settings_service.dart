import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_constants.dart';

class SettingsService {
  static final SettingsService _instance = SettingsService._internal();
  factory SettingsService() => _instance;
  SettingsService._internal();

  double _fontSize = 1.0; // Scale factor: 0.8 small, 1.0 medium, 1.2 large
  bool _notificationsEnabled = true;
  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;
    final prefs = await SharedPreferences.getInstance();
    _fontSize = prefs.getDouble(AppConstants.keyFontSize) ?? 1.0;
    _notificationsEnabled = prefs.getBool('notifications_enabled') ?? true;
    _initialized = true;
  }

  double get fontSize => _fontSize;
  bool get notificationsEnabled => _notificationsEnabled;

  Future<void> setNotificationsEnabled(bool enabled) async {
    _notificationsEnabled = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notifications_enabled', enabled);
  }

  Future<void> setFontSize(double size) async {
    _fontSize = size;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(AppConstants.keyFontSize, size);
  }

  Future<void> clearAllData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    _fontSize = 1.0;
  }
}
