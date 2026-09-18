import '../services/hostinger_remote_config_service.dart';

class FeatureGates {
  FeatureGates._();

  static final DateTime _april28_2026 = DateTime(2026, 4, 28);
  static final DateTime _may14_2026 = DateTime(2026, 5, 14);
  static final DateTime _may16_2026 = DateTime(2026, 5, 16);
  static final DateTime _may19_2026 = DateTime(2026, 5, 19);

  static HostingerRemoteConfigService get _remoteConfig =>
      HostingerRemoteConfigService.instance;

  static bool get showApril28Features => _remoteConfig.boolValue(
        'show_april_28_features',
        fallback: _isOnOrAfter(_april28_2026),
      );

  static bool get showMay14Features => _remoteConfig.boolValue(
        'show_may_14_features',
        fallback: _isOnOrAfter(_may14_2026),
      );

  static bool get showMay16Features => _remoteConfig.boolValue(
        'show_may_16_features',
        fallback: _isOnOrAfter(_may16_2026),
      );

  static bool get showMay19Features => _remoteConfig.boolValue(
        'show_may_19_features',
        fallback: _isOnOrAfter(_may19_2026),
      );

  static bool _isOnOrAfter(DateTime date) {
    final today = _dateOnly(DateTime.now());
    final target = _dateOnly(date);
    return !today.isBefore(target);
  }

  static DateTime _dateOnly(DateTime dt) => DateTime(dt.year, dt.month, dt.day);
}
