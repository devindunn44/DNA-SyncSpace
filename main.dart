import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'core/theme/app_theme.dart';
import 'core/router/app_router.dart';
import 'data/models/shared_event_model.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Lock to portrait orientation
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Initialize Hive local storage
  await Hive.initFlutter();
  Hive.registerAdapter(SharedEventModelAdapter());
  await Hive.openBox<SharedEventModel>('shared_events');
  await Hive.openBox('settings');
  await Hive.openBox('user_prefs');

  runApp(
    const ProviderScope(
      child: SyncSpaceApp(),
    ),
  );
}

class SyncSpaceApp extends ConsumerWidget {
  const SyncSpaceApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    final themeMode = ref.watch(themeModeProvider);
    final colorScheme = ref.watch(colorSchemeProvider);

    return MaterialApp.router(
      title: 'SyncSpace',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(colorScheme),
      darkTheme: AppTheme.dark(),
      themeMode: themeMode,
      routerConfig: router,
    );
  }
}
