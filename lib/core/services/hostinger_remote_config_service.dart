import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../constants/app_constants.dart';

class HostingerRemoteConfigService {
  HostingerRemoteConfigService._();

  static final HostingerRemoteConfigService instance =
      HostingerRemoteConfigService._();

  static const Duration _fetchTimeout = Duration(seconds: 5);

  Map<String, dynamic> _config = const {};
  bool _initialized = false;

  bool get isInitialized => _initialized;

  Future<void> initialize() async {
    if (_initialized) return;
    _initialized = true;

    final prefs = await SharedPreferences.getInstance();
    final cachedConfig = prefs.getString(AppConstants.keyHostingerRemoteConfig);
    if (cachedConfig != null && cachedConfig.isNotEmpty) {
      _applyConfigJson(cachedConfig);
    }

    unawaited(fetchAndActivate());
  }

  Future<bool> fetchAndActivate() async {
    final uri = Uri.tryParse(AppConstants.hostingerRemoteConfigUrl);
    if (uri == null || !uri.hasScheme || uri.host.isEmpty) {
      return false;
    }

    try {
      final response = await http.get(uri).timeout(_fetchTimeout);
      if (response.statusCode != 200) return false;

      final decoded = jsonDecode(response.body);
      if (decoded is! Map<String, dynamic>) return false;

      _config = decoded;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        AppConstants.keyHostingerRemoteConfig,
        response.body,
      );
      await prefs.setInt(
        AppConstants.keyHostingerRemoteConfigFetchedAt,
        DateTime.now().millisecondsSinceEpoch,
      );
      return true;
    } catch (_) {
      return false;
    }
  }

  bool boolValue(String key, {required bool fallback}) {
    final value = _valueForKey(key);
    if (value is bool) return value;
    if (value is String) {
      final normalized = value.trim().toLowerCase();
      if (normalized == 'true') return true;
      if (normalized == 'false') return false;
    }
    return fallback;
  }

  int intValue(String key, {required int fallback}) {
    final value = _valueForKey(key);
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value) ?? fallback;
    return fallback;
  }

  String stringValue(String key, {required String fallback}) {
    final value = _valueForKey(key);
    if (value is String && value.trim().isNotEmpty) return value.trim();
    return fallback;
  }

  Object? _valueForKey(String key) {
    if (_config.containsKey(key)) return _config[key];

    final features = _config['features'];
    if (features is Map<String, dynamic> && features.containsKey(key)) {
      return features[key];
    }

    final values = _config['values'];
    if (values is Map<String, dynamic> && values.containsKey(key)) {
      return values[key];
    }

    return null;
  }

  void _applyConfigJson(String json) {
    try {
      final decoded = jsonDecode(json);
      if (decoded is Map<String, dynamic>) {
        _config = decoded;
      }
    } catch (_) {}
  }
}
