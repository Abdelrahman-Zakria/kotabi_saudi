import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PremiumProvider extends ChangeNotifier {
  PremiumProvider();

  static const String monthlyProductId = 'kutub_premium_monthly';
  static const String yearlyProductId = 'kutub_premium_yearly';
  static const Set<String> subscriptionProductIds = {
    monthlyProductId,
    yearlyProductId,
  };

  static const String _activeProductKey = 'premium_active_product_id';
  static const String _lastPurchaseTokenKey = 'premium_last_purchase_token';
  static const String _lastUpdatedKey = 'premium_last_updated_ms';

  final InAppPurchase _inAppPurchase = InAppPurchase.instance;

  StreamSubscription<List<PurchaseDetails>>? _purchaseSubscription;
  List<ProductDetails> _products = const [];
  String? _activeProductId;
  String? _message;
  bool _isAvailable = false;
  bool _isLoading = false;
  bool _isPurchasing = false;
  bool _initialized = false;

  bool get isAndroidBillingSupported => Platform.isAndroid;
  bool get isInitialized => _initialized;
  bool get isAvailable => _isAvailable;
  bool get isLoading => _isLoading;
  bool get isPurchasing => _isPurchasing;
  // Everything in the app is free — every user is treated as fully
  // entitled, so no purchase is ever required to unlock content.
  bool get hasActiveSubscription => true;
  String? get activeProductId => _activeProductId;
  String? get message => _message;
  List<ProductDetails> get products => List.unmodifiable(_products);

  ProductDetails? get monthlyProduct => _productById(monthlyProductId);
  ProductDetails? get yearlyProduct => _productById(yearlyProductId);

  Future<void> initialize() async {
    if (_initialized) return;
    _initialized = true;

    await _loadCachedEntitlement();
    _applyAdState();

    if (!isAndroidBillingSupported) {
      _message = 'الاشتراكات متاحة على أندرويد فقط.';
      notifyListeners();
      return;
    }

    _purchaseSubscription = _inAppPurchase.purchaseStream.listen(
      _listenToPurchaseUpdated,
      onDone: () => _purchaseSubscription?.cancel(),
      onError: (_) {
        _message = 'تعذر متابعة حالة الشراء حالياً.';
        _isPurchasing = false;
        notifyListeners();
      },
    );

    await loadProducts();
    unawaited(restorePurchases(silent: true));
  }

  Future<void> loadProducts() async {
    if (!isAndroidBillingSupported || _isLoading) return;

    _isLoading = true;
    _message = null;
    notifyListeners();

    try {
      _isAvailable = await _inAppPurchase.isAvailable();
      if (!_isAvailable) {
        _message = 'خدمة Google Play Billing غير متاحة على هذا الجهاز.';
        return;
      }

      final response = await _inAppPurchase.queryProductDetails(
        subscriptionProductIds,
      );
      _products = response.productDetails.toList()
        ..sort((a, b) {
          const order = [monthlyProductId, yearlyProductId];
          return order.indexOf(a.id).compareTo(order.indexOf(b.id));
        });

      if (response.notFoundIDs.isNotEmpty) {
        _message =
            'لم يتم العثور على بعض الاشتراكات في Google Play Console: ${response.notFoundIDs.join(', ')}';
      }
    } catch (_) {
      _message = 'تعذر تحميل الاشتراكات من Google Play.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> buy(ProductDetails product) async {
    if (!isAndroidBillingSupported) {
      _message = 'الاشتراكات متاحة على أندرويد فقط.';
      notifyListeners();
      return;
    }

    _isPurchasing = true;
    _message = null;
    notifyListeners();

    try {
      final purchaseParam = PurchaseParam(productDetails: product);
      await _inAppPurchase.buyNonConsumable(purchaseParam: purchaseParam);
    } catch (_) {
      _isPurchasing = false;
      _message = 'تعذر بدء عملية الاشتراك.';
      notifyListeners();
    }
  }

  Future<void> restorePurchases({bool silent = false}) async {
    if (!isAndroidBillingSupported) return;

    if (!silent) {
      _isLoading = true;
      _message = null;
      notifyListeners();
    }

    try {
      await _inAppPurchase.restorePurchases();
      if (!silent) {
        _message = 'تم طلب استعادة الاشتراكات من Google Play.';
      }
    } catch (_) {
      if (!silent) {
        _message = 'تعذر استعادة الاشتراكات.';
      }
    } finally {
      if (!silent) {
        _isLoading = false;
        notifyListeners();
      }
    }
  }

  Future<void> _listenToPurchaseUpdated(
    List<PurchaseDetails> purchaseDetailsList,
  ) async {
    for (final purchaseDetails in purchaseDetailsList) {
      if (!subscriptionProductIds.contains(purchaseDetails.productID)) {
        continue;
      }

      switch (purchaseDetails.status) {
        case PurchaseStatus.pending:
          _isPurchasing = true;
          _message = 'عملية الاشتراك قيد المعالجة.';
          notifyListeners();
          break;
        case PurchaseStatus.error:
          _isPurchasing = false;
          _message = purchaseDetails.error?.message ?? 'فشلت عملية الاشتراك.';
          notifyListeners();
          break;
        case PurchaseStatus.purchased:
        case PurchaseStatus.restored:
          await _grantEntitlement(purchaseDetails);
          break;
        case PurchaseStatus.canceled:
          _isPurchasing = false;
          _message = 'تم إلغاء عملية الاشتراك.';
          notifyListeners();
          break;
      }

      if (purchaseDetails.pendingCompletePurchase) {
        await _inAppPurchase.completePurchase(purchaseDetails);
      }
    }
  }

  Future<void> _grantEntitlement(PurchaseDetails purchaseDetails) async {
    _activeProductId = purchaseDetails.productID;
    _isPurchasing = false;
    _message = 'تم تفعيل الاشتراك بنجاح.';
    _applyAdState();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_activeProductKey, purchaseDetails.productID);
    await prefs.setString(
      _lastPurchaseTokenKey,
      purchaseDetails.verificationData.serverVerificationData,
    );
    await prefs.setInt(_lastUpdatedKey, DateTime.now().millisecondsSinceEpoch);

    notifyListeners();
  }

  Future<void> _loadCachedEntitlement() async {
    if (!isAndroidBillingSupported) return;
    final prefs = await SharedPreferences.getInstance();
    final productId = prefs.getString(_activeProductKey);
    if (subscriptionProductIds.contains(productId)) {
      _activeProductId = productId;
    }
  }

  void _applyAdState() {
    return;
  }

  ProductDetails? _productById(String id) {
    for (final product in _products) {
      if (product.id == id) return product;
    }
    return null;
  }

  @override
  void dispose() {
    _purchaseSubscription?.cancel();
    super.dispose();
  }
}
