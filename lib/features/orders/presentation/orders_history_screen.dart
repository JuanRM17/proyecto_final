import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/formatters.dart';
import '../../../core/utils/responsive.dart';
import '../providers/orders_provider.dart';

class OrdersHistoryScreen extends ConsumerWidget {
  const OrdersHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orders = ref.watch(ordersProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Mis pedidos')),
      body: orders.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => const Center(
          child: Text('No se pudieron cargar tus pedidos.'),
        ),
        data: (list) {
          if (list.isEmpty) {
            return const Center(child: Text('Aún no tienes pedidos.'));
          }
          return ResponsiveCenter(
            maxWidth: 720,
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: list.length,
              separatorBuilder: (_, _) => const SizedBox(height: 8),
              itemBuilder: (context, i) {
                final o = list[i];
                final shortId = o.id.length > 6
                    ? o.id.substring(o.id.length - 6).toUpperCase()
                    : o.id.toUpperCase();

                return Card(
                  margin: EdgeInsets.zero,
                  child: ExpansionTile(
                    title: Text('Pedido #$shortId · ${formatMoney(o.total)}'),
                    subtitle: Text(
                      '${formatDateTime(o.createdAt)} · ${o.status}',
                    ),
                    childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    expandedCrossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      for (final item in o.items)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 2),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text('${item.quantity} × ${item.name}'),
                              ),
                              Text(formatMoney(item.price * item.quantity)),
                            ],
                          ),
                        ),
                      const Divider(),
                      Text('Entrega: ${o.address}'),
                      Text('Pago: ${o.paymentBrand} •••• ${o.paymentLast4}'),
                    ],
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}