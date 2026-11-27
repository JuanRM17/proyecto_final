import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/auth/providers/auth_provider.dart';
import '../../features/notifications/providers/notifications_provider.dart';
import '../router/app_router.dart';
import 'notification_service.dart';

/// Rutas a las que una notificación puede llevar (campo "route" de los datos).
const _allowedRoutes = {'/orders', '/cart', '/profile', '/notifications'};

final scaffoldMessengerKeyProvider =
    Provider<GlobalKey<ScaffoldMessengerState>>(
  (ref) => GlobalKey<ScaffoldMessengerState>(),
);

final pushListenerProvider = Provider<void>((ref) {
  if (!supportsPushNotifications) return;

  final router = ref.watch(routerProvider);
  final messengerKey = ref.watch(scaffoldMessengerKeyProvider);
  final subscriptions = <StreamSubscription<RemoteMessage>>[];

  String? routeOf(RemoteMessage message) {
    final route = message.data['route'];
    return (route is String && _allowedRoutes.contains(route)) ? route : null;
  }

  void open(RemoteMessage message) {
    final route = routeOf(message);
    if (route != null) router.push(route);
  }

  // 1) Primer plano: aviso dentro de la app.
  subscriptions.add(
    FirebaseMessaging.onMessage.listen((message) {
      final notification = message.notification;
      final title = notification?.title ?? 'GanaderiApp';
      final body = notification?.body ?? '';
      final route = routeOf(message);

      messengerKey.currentState
        ?..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            duration: const Duration(seconds: 6),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
                if (body.isNotEmpty) Text(body),
              ],
            ),
            action: route == null
                ? null
                : SnackBarAction(label: 'Ver', onPressed: () => open(message)),
          ),
        );
    }),
  );

  // 2) Segundo plano: el usuario toca la notificación.
  subscriptions.add(FirebaseMessaging.onMessageOpenedApp.listen(open));

  // 3) Cerrada: la app se abrió al tocar la notificación.
  FirebaseMessaging.instance.getInitialMessage().then((message) {
    if (message != null) {
      Future<void>.delayed(const Duration(seconds: 1), () => open(message));
    }
  }).catchError((_) {});

  // 4) Notificaciones locales (p. ej. "Pedido realizado"): al tocarlas.
  ref.read(localNotificationServiceProvider).init(onTap: (payload) {
    if (payload != null && _allowedRoutes.contains(payload)) {
      router.push(payload);
    }
  }).catchError((Object e) => debugPrint('Notificación local init: $e'));

  // Permiso y suscripción por defecto al iniciar sesión.
  ref.listen(sessionProvider, (previous, next) {
    final wasAllowed = previous?.canAccess ?? false;
    if (next != null && next.canAccess && !wasAllowed) {
      _setup(ref);
    }
  }, fireImmediately: true);

  ref.onDispose(() {
    for (final s in subscriptions) {
      s.cancel();
    }
  });
});

Future<void> _setup(Ref ref) async {
  try {
    await ref.read(notificationServiceProvider).init();
    await ref.read(topicSubscriptionsProvider.notifier).syncOnLogin();
  } catch (e) {
    debugPrint('FCM setup error: $e');
  }
}