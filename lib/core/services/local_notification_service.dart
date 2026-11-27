import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'notification_service.dart';

/// Notificaciones generadas en el propio dispositivo (sin pasar por FCM),
/// por ejemplo al confirmar un pedido.
class LocalNotificationService {
  final _plugin = FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  static const _ordersChannel = AndroidNotificationDetails(
    'pedidos',
    'Pedidos',
    channelDescription: 'Avisos cuando tu compra o pedido fue realizado',
    importance: Importance.high,
    priority: Priority.high,
  );

  /// [onTap] recibe el "payload" (una ruta de la app) al tocar la notificación.
  Future<void> init({void Function(String? payload)? onTap}) async {
    if (_initialized || !supportsPushNotifications) return;
    await _plugin.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: DarwinInitializationSettings(
          requestAlertPermission: false,
          requestBadgePermission: false,
          requestSoundPermission: false,
        ),
      ),
      onDidReceiveNotificationResponse: (response) =>
          onTap?.call(response.payload),
    );
    _initialized = true;
  }

  Future<void> showOrderPlaced({
    required String orderId,
    required double total,
  }) async {
    if (!supportsPushNotifications) return;
    try {
      await init();
      final shortId =
          orderId.length > 6 ? orderId.substring(orderId.length - 6) : orderId;
      await _plugin.show(
        id: orderId.hashCode & 0x7fffffff,
        title: '¡Pedido realizado!',
        body:
            'Tu pedido #${shortId.toUpperCase()} por \$${total.toStringAsFixed(2)} fue registrado con éxito.',
        notificationDetails: const NotificationDetails(
          android: _ordersChannel,
          iOS: DarwinNotificationDetails(presentAlert: true, presentSound: true),
        ),
        payload: '/orders',
      );
    } catch (e) {
      // Una notificación fallida no debe afectar al pedido.
      debugPrint('Notificación local error: $e');
    }
  }
}
