import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../features/home/domain/entities/educational_node.dart';

class LocalStorageService {
  final SharedPreferences prefs;

  LocalStorageService(this.prefs);

  static const String _favoritesKey = 'favorites';
  static const String _libraryKey = 'library';
  static const String _timersKey = 'timers';
  static const String _notificationsHistoryKey = 'notifications_history';

  // Favorites
  List<EducationalNode> getFavorites() {
    final List<String> list = prefs.getStringList(_favoritesKey) ?? [];
    return list.map((e) => EducationalNode.fromMap('', json.decode(e))).toList();
  }

  Future<void> toggleFavorite(EducationalNode node) async {
    final favorites = getFavorites();
    final index = favorites.indexWhere((e) => e.url == node.url);
    if (index >= 0) {
      favorites.removeAt(index);
    } else {
      favorites.add(node);
    }
    await prefs.setStringList(_favoritesKey, favorites.map((e) => json.encode(e.toMap())).toList());
  }

  bool isFavorite(String url) {
    final favorites = getFavorites();
    return favorites.any((e) => e.url == url);
  }

  // Library (Downloads)
  List<EducationalNode> getLibrary() {
    final List<String> list = prefs.getStringList(_libraryKey) ?? [];
    return list.map((e) => EducationalNode.fromMap('', json.decode(e))).toList();
  }

  Future<void> addToLibrary(EducationalNode node) async {
    final library = getLibrary();
    if (!library.any((e) => e.url == node.url)) {
      library.add(node);
      await prefs.setStringList(_libraryKey, library.map((e) => json.encode(e.toMap())).toList());
    }
  }

  // Study Timers
  List<Map<String, dynamic>> getTimers() {
    final List<String> list = prefs.getStringList(_timersKey) ?? [];
    return list.map((e) => Map<String, dynamic>.from(json.decode(e))).toList();
  }

  Future<void> saveTimer(Map<String, dynamic> timer) async {
    final timers = getTimers();
    timers.add(timer);
    await prefs.setStringList(_timersKey, timers.map((e) => json.encode(e)).toList());
  }

  Future<void> deleteTimer(int index) async {
    final timers = getTimers();
    if (index >= 0 && index < timers.length) {
      timers.removeAt(index);
      await prefs.setStringList(_timersKey, timers.map((e) => json.encode(e)).toList());
    }
  }

  // Notifications History
  List<Map<String, dynamic>> getNotificationsHistory() {
    final List<String> list = prefs.getStringList(_notificationsHistoryKey) ?? [];
    return list.map((e) => Map<String, dynamic>.from(json.decode(e))).toList();
  }

  Future<void> saveNotification(String title, String body) async {
    final history = getNotificationsHistory();
    history.insert(0, {
      'title': title,
      'body': body,
      'timestamp': DateTime.now().toIso8601String(),
    });
    // Keep only last 50
    if (history.length > 50) history.removeLast();
    await prefs.setStringList(_notificationsHistoryKey, history.map((e) => json.encode(e)).toList());
  }

  Future<void> clearNotificationsHistory() async {
    await prefs.remove(_notificationsHistoryKey);
  }
}
