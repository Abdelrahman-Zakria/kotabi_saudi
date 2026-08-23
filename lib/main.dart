import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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
import 'package:kotabi_saudi/features/home/domain/repositories/educational_repository.dart';
import 'package:kotabi_saudi/features/home/data/repositories/educational_repository_impl.dart';
import 'package:kotabi_saudi/features/tahderi/domain/repositories/tahderi_repository.dart';
import 'package:kotabi_saudi/features/tahderi/data/repositories/tahderi_repository_impl.dart';
import 'package:kotabi_saudi/features/home/presentation/screens/home/home_page.dart';

final sl = GetIt.instance;
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

// 1. Top-level background message handler
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  debugPrint("Handling a background message: ${message.messageId}");
}

class AdNavigationObserver extends NavigatorObserver {
  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    // Don't show on the very first route (usually '/')
    if (previousRoute != null && sl.isRegistered<AdService>()) {
      sl<AdService>().showInterstitialAd(onAdDismissed: () {});
    }
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPop(route, previousRoute);
    if (sl.isRegistered<AdService>()) {
      sl<AdService>().showInterstitialAd(onAdDismissed: () {});
    }
  }
}

void main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  
  try {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
    
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
    await adService.init();
    sl.registerLazySingleton(() => adService);
    
    sl.registerLazySingleton<EducationalRepository>(
      () => EducationalRepositoryImpl(FirebaseFirestore.instance)
    );

    sl.registerLazySingleton<TahderiRepository>(
      () => TahderiRepositoryImpl(FirebaseFirestore.instance)
    );

    await Alarm.init();
    await notificationService.init();
    await fcmService.init();

  } catch (e) {
    debugPrint("Initialization Error: $e");
  } finally {
    FlutterNativeSplash.remove();
  }

  runApp(const MyApp());
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
      if (sl.isRegistered<AdService>()) {
        sl<AdService>().showAppOpenAdIfAvailable();
      }
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
      child: MaterialApp(
        navigatorKey: navigatorKey,
        navigatorObservers: [AdNavigationObserver()],
        title: 'كتبي السعودية',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: const HomePage(),
      ),
    );
  }
}
