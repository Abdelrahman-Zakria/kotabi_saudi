import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:in_app_purchase_storekit/in_app_purchase_storekit.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:get_it/get_it.dart';
import 'package:alarm/alarm.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:kotabi_saudi/firebase_options.dart';
import 'package:kotabi_saudi/core/theme/app_theme.dart';
import 'package:kotabi_saudi/core/services/local_storage_service.dart';
import 'package:kotabi_saudi/core/services/notification_service.dart';
import 'package:kotabi_saudi/core/services/fcm_service.dart';
import 'package:kotabi_saudi/core/services/ad_service.dart';
import 'package:kotabi_saudi/core/services/iap_service.dart';
import 'package:kotabi_saudi/core/services/review_service.dart';

// New UI & Logic Imports
import 'package:provider/provider.dart';
import 'package:kotabi_saudi/core/providers/books_provider.dart';
import 'package:kotabi_saudi/core/providers/favorites_provider.dart';
import 'package:kotabi_saudi/core/providers/premium_provider.dart';
import 'package:kotabi_saudi/core/providers/reader_library_provider.dart';
import 'package:kotabi_saudi/core/providers/settings_provider.dart';
import 'package:kotabi_saudi/core/services/hostinger_remote_config_service.dart';
import 'package:kotabi_saudi/features/new_ui/screens/main/main_shell.dart';
import 'package:kotabi_saudi/features/new_ui/widgets/app_ad_banner.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'package:kotabi_saudi/features/home/domain/repositories/educational_repository.dart';
import 'package:kotabi_saudi/features/home/data/repositories/educational_repository_impl.dart';
import 'package:kotabi_saudi/features/tahderi/domain/repositories/tahderi_repository.dart';
import 'package:kotabi_saudi/features/tahderi/data/repositories/tahderi_repository_impl.dart';
import 'package:kotabi_saudi/features/tahderi/data/repositories/tahderi_repository_impl.dart';

final sl = GetIt.instance;
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

// 1. Top-level background message handler
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  if (message.notification != null) {
    final prefs = await SharedPreferences.getInstance();
    final historyKey = 'notifications_history';
    final List<String> list = prefs.getStringList(historyKey) ?? [];

    final newItem = json.encode({
      'title': message.notification?.title ?? '',
      'body': message.notification?.body ?? '',
      'timestamp': DateTime.now().toIso8601String(),
    });

    list.insert(0, newItem);
    if (list.length > 50) list.removeLast();

    await prefs.setStringList(historyKey, list);
  }

  debugPrint("Handling a background message: ${message.messageId}");
}

void main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: SystemUiOverlay.values);
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  if (Platform.isIOS) {
    InAppPurchaseStoreKitPlatform.enableStoreKit1();
  }

  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    // 2. Register background handler
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);



    final prefs = await SharedPreferences.getInstance();
    sl.registerLazySingleton(() => LocalStorageService(prefs));

    final notificationService = NotificationService();
    sl.registerLazySingleton(() => notificationService);

    final fcmService = FcmService();
    sl.registerLazySingleton(() => fcmService);

    final iapService = IapService();
    await iapService.init();
    sl.registerLazySingleton(() => iapService);

    final adService = AdService();
    adService.navigatorKey = navigatorKey;
    sl.registerLazySingleton(() => adService);

    final reviewService = ReviewService();
    reviewService.navigatorKey = navigatorKey;
    // Initial initialization moved to sequenced sequence
    sl.registerLazySingleton(() => reviewService);

    sl.registerLazySingleton<EducationalRepository>(
      () => EducationalRepositoryImpl(FirebaseFirestore.instance),
    );

    sl.registerLazySingleton<TahderiRepository>(
      () => TahderiRepositoryImpl(FirebaseFirestore.instance),
    );

    await Alarm.init();
    
    // Initialize Remote Config
    await HostingerRemoteConfigService.instance.initialize();

    // Initial initialization of services that don't show UI prompts immediately
    await notificationService.init();
    await fcmService.init();

    // 3. Start background initialization sequence after a delay to handle permissions correctly
    _initializeSequencedServices(notificationService, adService, reviewService);

  } catch (e) {
    debugPrint("Initialization Error: $e");
  } finally {
    FlutterNativeSplash.remove();
  }

  runApp(const MyApp());
}

Future<void> _initializeSequencedServices(
  NotificationService notificationService,
  AdService adService,
  ReviewService reviewService,
) async {
  // Wait for the app UI to be ready
  await Future.delayed(const Duration(milliseconds: 1000));

  // 1. Request Notification Permissions first (via both services to be sure)
  debugPrint("Requesting Notification Permissions...");
  await notificationService.requestPermissions();
  if (sl.isRegistered<FcmService>()) {
    await sl<FcmService>().requestPermissions();
  }

  // 2. Wait for the user to interact with the notification dialog
  await Future.delayed(const Duration(milliseconds: 1500));

  // 3. Initialize Ads (which includes App Tracking Transparency prompt on iOS)
  debugPrint("Initializing Ads and ATT...");
  await adService.init();
  
  // 4. Initialize Review Service
  await reviewService.init();
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Small delay to prevent conflict with notification-triggered navigation
      Future.delayed(const Duration(milliseconds: 1000), () {
        if (mounted && sl.isRegistered<AdService>()) {
          sl<AdService>().showAppOpenAdIfAvailable();
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<EducationalRepository>(
          create: (context) => sl<EducationalRepository>(),
        ),
      ],
      child: MultiProvider(
        providers: [
          ChangeNotifierProvider(
            create: (_) => SettingsProvider()..initialize(),
          ),
          ChangeNotifierProvider(
            create: (_) => FavoritesProvider()..initialize(),
          ),
          ChangeNotifierProvider(create: (_) => BooksProvider()),
          ChangeNotifierProvider(
            create: (_) => ReaderLibraryProvider()..initialize(),
          ),
          ChangeNotifierProvider(create: (_) => PremiumProvider()..initialize()),
        ],
        child: MaterialApp(
          navigatorKey: navigatorKey,
          title: 'كتبي السعودية',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          // RTL Arabic Support
          locale: const Locale('ar', 'SA'),
          supportedLocales: const [
            Locale('ar', 'SA'),
          ],
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          builder: (context, child) {
            return Directionality(
              textDirection: TextDirection.rtl,
              child: child ?? const SizedBox.shrink(),
            );
          },
          home: const MainShell(),
        ),
      ),
    );
  }
}
