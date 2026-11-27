import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/router/app_router.dart';
import 'core/services/push_listener.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_provider.dart';

class GanaderiApp extends ConsumerWidget {
  const GanaderiApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Mantiene activo el listener global de notificaciones.
    ref.watch(pushListenerProvider);

    final router = ref.watch(routerProvider);
    final themeMode = ref.watch(themeModeProvider);
    final messengerKey = ref.watch(scaffoldMessengerKeyProvider);

    return MaterialApp.router(
      title: 'GanaderiApp',
      debugShowCheckedModeBanner: false,
      scaffoldMessengerKey: messengerKey,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeMode,
      routerConfig: router,
    );
  }
}