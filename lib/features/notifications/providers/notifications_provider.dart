import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/notification_service.dart';
import '../../../core/services/preferences_provider.dart';

class PushTopic {
  const PushTopic({
    required this.id,
    required this.title,
    required this.description,
  });

  final String id;
  final String title;
  final String description;
}

const pushTopics = [
  PushTopic(
    id: 'pedidos',
    title: 'Pedidos',
    description: 'Avisos cuando tu compra o pedido fue realizado',
  ),
  PushTopic(
    id: 'ofertas',
    title: 'Ofertas',
    description: 'Promociones en insumos veterinarios',
  ),
  PushTopic(
    id: 'avisos',
    title: 'Avisos generales',
    description: 'Noticias y comunicados de la hacienda',
  ),
];

final notificationServiceProvider =
    Provider<NotificationService>((ref) => NotificationService());

/// Temas a los que está suscrito el usuario (se guarda en el dispositivo).
class TopicSubscriptionsNotifier extends Notifier<Set<String>> {
  static const _key = 'fcm_topics';
  static const _initKey = 'fcm_topics_initialized';

  @override
  Set<String> build() {
    final saved = ref.read(sharedPreferencesProvider).getStringList(_key);
    return (saved ?? const <String>[]).toSet();
  }

  /// Primera vez: suscribe por defecto al tema de pedidos.
  Future<void> syncOnLogin() async {
    final prefs = ref.read(sharedPreferencesProvider);
    if (prefs.getBool(_initKey) == true) return;
    final ok = await setSubscribed('pedidos', true);
    if (ok) await prefs.setBool(_initKey, true);
  }

  /// Devuelve false si no se pudo cambiar (por ejemplo, sin conexión).
  Future<bool> setSubscribed(String topic, bool subscribed) async {
    if (!supportsPushNotifications) return false;
    try {
      final service = ref.read(notificationServiceProvider);
      if (subscribed) {
        await service.subscribe(topic);
      } else {
        await service.unsubscribe(topic);
      }
    } catch (_) {
      return false;
    }

    final next = {...state};
    if (subscribed) {
      next.add(topic);
    } else {
      next.remove(topic);
    }
    state = next;
    await ref.read(sharedPreferencesProvider).setStringList(_key, next.toList());
    return true;
  }
}

final topicSubscriptionsProvider =
    NotifierProvider<TopicSubscriptionsNotifier, Set<String>>(
  TopicSubscriptionsNotifier.new,
);