/// Entry point for the Golf Cart Computer application.
///
/// Initializes SharedPreferences and Hive before running the app,
/// sets up Riverpod ProviderScope with overrides for
/// [preferencesRepositoryProvider] and [cacheRepositoryProvider],
/// configures Material Design 3 theming, and wires navigation routes
/// to all screens.
///
/// Requirements: 13.12, 13.14, 16.2
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'application/app_lifecycle_observer.dart';
import 'application/providers.dart';
import 'data/repositories/cache_repository.dart';
import 'data/repositories/preferences_repository.dart';
import 'presentation/screens/config_screen.dart';
import 'presentation/screens/entertainment_screen.dart';
import 'presentation/screens/main_screen.dart';
import 'presentation/screens/weather_screen.dart';

/// Application route names.
class AppRoutes {
  AppRoutes._();

  /// Main dashboard screen.
  static const String main = '/';

  /// Weather forecast screen.
  static const String weather = '/weather';

  /// Entertainment/venue events screen.
  static const String entertainment = '/entertainment';

  /// Configuration/settings screen.
  static const String config = '/config';
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize SharedPreferences before runApp (Requirement 15.2).
  final sharedPreferences = await SharedPreferences.getInstance();
  final preferencesRepository = SharedPreferencesRepository(sharedPreferences);

  // Initialize Hive for structured cache storage.
  final appDocDir = await getApplicationDocumentsDirectory();
  Hive.init(appDocDir.path);
  final cacheRepository = await HiveCacheRepository.create();

  runApp(
    ProviderScope(
      overrides: [
        preferencesRepositoryProvider.overrideWithValue(preferencesRepository),
        cacheRepositoryProvider.overrideWithValue(cacheRepository),
      ],
      child: const GolfCartComputerApp(),
    ),
  );
}

/// Root application widget with Material Design 3 theming and navigation.
///
/// Requirement 13.12: Material Design 3 theming with platform-adaptive
/// components.
/// Requirement 13.14: Navigation between main, weather, entertainment,
/// and config screens reachable within 2 taps.
class GolfCartComputerApp extends StatelessWidget {
  const GolfCartComputerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Golf Cart Computer',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.green,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.green,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      initialRoute: AppRoutes.main,
      routes: {
        AppRoutes.main: (_) => const _AppStartupWrapper(),
        AppRoutes.weather: (_) => const WeatherScreen(),
        AppRoutes.entertainment: (_) => const EntertainmentScreen(),
        AppRoutes.config: (_) => const ConfigScreen(),
      },
    );
  }
}

/// Wrapper widget that performs one-time startup initialization.
///
/// Initializes [ConnectionNotifier] and plays the startup tone via
/// [AudioService] on first build, then displays the [MainScreen].
class _AppStartupWrapper extends ConsumerStatefulWidget {
  const _AppStartupWrapper();

  @override
  ConsumerState<_AppStartupWrapper> createState() => _AppStartupWrapperState();
}

class _AppStartupWrapperState extends ConsumerState<_AppStartupWrapper> {
  bool _initialized = false;
  AppLifecycleObserver? _lifecycleObserver;

  @override
  void initState() {
    super.initState();
    // Schedule startup tasks after the first frame to ensure providers
    // are available.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _performStartup();
    });
  }

  Future<void> _performStartup() async {
    if (_initialized) return;
    _initialized = true;

    // Initialize ConnectionNotifier to begin connection attempts
    // using persisted device identifiers (Requirement 17.1).
    final connectionNotifier = ref.read(connectionNotifierProvider.notifier);
    await connectionNotifier.initialize();

    // Play startup tone (Requirement 14.1).
    final audioService = ref.read(audioServiceProvider);
    await audioService.playStartupTone();

    // Wire background connectivity and lifecycle observer.
    // Requirement 20.1, 20.2, 20.3, 20.7, 11.7: Start foreground service,
    // observe lifecycle transitions, persist state before background/shutdown,
    // maintain Bluetooth connections when backgrounded.
    final backgroundService = ref.read(backgroundServiceProvider);
    final mainNotifier = ref.read(mainNotifierProvider.notifier);
    _lifecycleObserver = AppLifecycleObserver(
      backgroundService: backgroundService,
      mainNotifier: mainNotifier,
      connectionNotifier: connectionNotifier,
    );
    await _lifecycleObserver!.initialize();
  }

  @override
  void dispose() {
    _lifecycleObserver?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return const MainScreen();
  }
}
