import 'dart:async';

class IapService {
  static final IapService _instance = IapService._internal();
  factory IapService() => _instance;
  IapService._internal();

  bool _isAdFree = false;
  bool get isAdFree => _isAdFree;

  Future<void> init() async {
    // Stub for future IAP implementation
    _isAdFree = false;
  }
}
