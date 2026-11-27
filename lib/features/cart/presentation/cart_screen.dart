import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/utils/formatters.dart';
import '../../../core/utils/responsive.dart';
import '../../../core/widgets/app_network_image.dart';
import '../providers/cart_provider.dart';

class CartScreen extends ConsumerWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = ref.watch(cartProvider).values.toList();
    final total = ref.watch(cartTotalProvider);
    final cart = ref.read(cartProvider.notifier);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Mi carrito')),
      body: items.isEmpty
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.shopping_cart_outlined,
                      size: 72, color: theme.colorScheme.outline),
                  const SizedBox(height: 12),
                  const Text('Tu carrito está vacío'),
                  TextButton(
                    onPressed: () => context.pop(),
                    child: const Text('Ver insumos'),
                  ),
                ],
              ),
            )
          : ResponsiveCenter(
              maxWidth: 720,
              child: Column(
                children: [
                  Expanded(
                    child: ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: items.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 8),
                      itemBuilder: (context, i) {
                        final item = items[i];
                        return Dismissible(
                          key: ValueKey(item.productId),
                          direction: DismissDirection.endToStart,
                          onDismissed: (_) => cart.remove(item.productId),
                          background: Container(
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.only(right: 24),
                            color: theme.colorScheme.error,
                            child: Icon(Icons.delete,
                                color: theme.colorScheme.onError),
                          ),
                          child: Card(
                            margin: EdgeInsets.zero,
                            child: ListTile(
                              leading: SizedBox(
                                width: 56,
                                height: 56,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: AppNetworkImage(url: item.imageUrl),
                                ),
                              ),
                              title: Text(item.name,
                                  maxLines: 2, overflow: TextOverflow.ellipsis),
                              subtitle: Text(
                                  formatMoney(item.price * item.quantity)),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.remove_circle_outline),
                                    onPressed: () =>
                                        cart.decrement(item.productId),
                                  ),
                                  Text('${item.quantity}'),
                                  IconButton(
                                    icon: const Icon(Icons.add_circle_outline),
                                    onPressed: () =>
                                        cart.increment(item.productId),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Total', style: theme.textTheme.titleLarge),
                            Text(formatMoney(total),
                                style: theme.textTheme.titleLarge),
                          ],
                        ),
                        const SizedBox(height: 12),
                        FilledButton(
                          onPressed: () => context.push('/checkout'),
                          child: const Text('Continuar al pago'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}