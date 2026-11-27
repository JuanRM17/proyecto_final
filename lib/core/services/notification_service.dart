import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

import '../../firebase_options.dart';

/// FCM solo en móvil (firebase_messaging no soporta Windows).
bool get supportsPushNotifications =>
    !kIsWeb &&
    (defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS);

/// Se ejecuta con la app en segundo plano o cerrada. Debe ser una función
/// de nivel superior. Si el mensaje trae "notification", el sistema ya la
/// muestra por su cuenta; aquí solo se inicializa Firebase.
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  debugPrint('FCM (segundo plano): ${message.messageId}');
}

class NotificationService {
  /// Pide permiso de notificaciones y muestra el token en consola
  /// (sirve para enviar mensajes de prueba a este dispositivo).
  Future<void> init() async {
    final messaging = FirebaseMessaging.instance;
    await messaging.requestPermission();
    // ignore: deprecated_member_use
    debugPrint('FCM token: ${await messaging.getToken()}');
  }

  Future<void> subscribe(String topic) =>
      FirebaseMessaging.instance.subscribeToTopic(topic);

  Future<void> unsubscribe(String topic) =>
      FirebaseMessaging.instance.unsubscribeFromTopic(topic);
}