import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/notification_service.dart';
import '../../../core/utils/responsive.dart';
import '../../../core/widgets/app_snackbar.dart';
import '../providers/notifications_provider.dart';

class NotificationSettingsScreen extends ConsumerWidget {
  const NotificationSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subscribed = ref.watch(topicSubscriptionsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Notificaciones')),
      body: !supportsPushNotifications
          ? const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  'Las notificaciones push solo están disponibles en Android e iOS.',
                  textAlign: TextAlign.center,
                ),
              ),
            )
          : ResponsiveCenter(
              maxWidth: 560,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Text(
                    'Elige los temas de los que quieres recibir avisos.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 12),
                  for (final topic in pushTopics)
                    Card(
                      child: SwitchListTile(
                        title: Text(topic.title),
                        subtitle: Text(topic.description),
                        value: subscribed.contains(topic.id),
                        onChanged: (value) async {
                          final ok = await ref
                              .read(topicSubscriptionsProvider.notifier)
                              .setSubscribed(topic.id, value);
                          if (!ok && context.mounted) {
                            showAppSnack(
                              context,
                              'No se pudo actualizar. Revisa tu conexión.',
                            );
                          }
                        },
                      ),
                    ),
                ],
              ),
            ),
    );
  }
}