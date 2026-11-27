import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class OrderSuccessScreen extends StatelessWidget {
  const OrderSuccessScreen({super.key, required this.orderId});

  final String orderId;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final shortId = orderId.length > 6
        ? orderId.substring(orderId.length - 6).toUpperCase()
        : orderId.toUpperCase();

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Icon(Icons.check_circle,
                      size: 96, color: theme.colorScheme.secondary),
                  const SizedBox(height: 24),
                  Text('¡Pedido realizado!',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.headlineMedium),
                  const SizedBox(height: 8),
                  Text('Número de pedido: #$shortId',
                      textAlign: TextAlign.center),
                  const SizedBox(height: 32),
                  FilledButton(
                    onPressed: () => context.go('/orders'),
                    child: const Text('Ver mis pedidos'),
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: () => context.go('/'),
                    child: const Text('Seguir comprando'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}