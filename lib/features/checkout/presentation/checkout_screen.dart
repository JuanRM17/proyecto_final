import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/utils/formatters.dart';
import '../../../core/utils/input_formatters.dart';
import '../../../core/utils/responsive.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/app_snackbar.dart';
import '../../cart/providers/cart_provider.dart';
import '../data/payment_simulator.dart';
import '../models/card_data.dart';
import '../providers/checkout_provider.dart';

class CheckoutScreen extends ConsumerStatefulWidget {
  const CheckoutScreen({super.key});

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  final _address = TextEditingController();
  final _holder = TextEditingController();
  final _number = TextEditingController();
  final _expiry = TextEditingController();
  final _cvv = TextEditingController();

  @override
  void dispose() {
    _address.dispose();
    _holder.dispose();
    _number.dispose();
    _expiry.dispose();
    _cvv.dispose();
    super.dispose();
  }

  Future<void> _pay() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();

    final card = CardData(
      holder: _holder.text.trim(),
      number: _number.text,
      expiry: _expiry.text,
      cvv: _cvv.text,
    );

    final orderId = await ref
        .read(checkoutControllerProvider.notifier)
        .pay(address: _address.text.trim(), card: card);
    if (!mounted) return;

    if (orderId != null) {
      context.go('/order-success/$orderId');
    } else {
      final error = ref.read(checkoutControllerProvider).error;
      showAppSnack(
        context,
        error is PaymentException
            ? error.message
            : 'No se pudo completar el pedido. Revisa tu conexión e intenta de nuevo.',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final items = ref.watch(cartProvider).values.toList();
    final total = ref.watch(cartTotalProvider);
    final loading = ref.watch(checkoutControllerProvider).isLoading;
    final theme = Theme.of(context);

    if (items.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Pago')),
        body: const Center(child: Text('Tu carrito está vacío')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Pago')),
      body: ResponsiveCenter(
        maxWidth: 560,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        for (final i in items)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 2),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text('${i.quantity} × ${i.name}',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis),
                                ),
                                Text(formatMoney(i.price * i.quantity)),
                              ],
                            ),
                          ),
                        const Divider(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Total', style: theme.textTheme.titleMedium),
                            Text(formatMoney(total),
                                style: theme.textTheme.titleMedium),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Text('Entrega', style: theme.textTheme.titleLarge),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _address,
                  minLines: 2,
                  maxLines: 3,
                  textCapitalization: TextCapitalization.sentences,
                  validator: (v) =>
                      Validators.required(v, 'La dirección de entrega'),
                  decoration: const InputDecoration(
                    labelText: 'Dirección de entrega',
                    prefixIcon: Icon(Icons.location_on_outlined),
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 24),
                Text('Datos de la tarjeta', style: theme.textTheme.titleLarge),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _holder,
                  textCapitalization: TextCapitalization.characters,
                  validator: Validators.cardHolder,
                  decoration: const InputDecoration(
                    labelText: 'Nombre del titular',
                    prefixIcon: Icon(Icons.person_outline),
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _number,
                  keyboardType: TextInputType.number,
                  inputFormatters: [CardNumberFormatter()],
                  validator: Validators.cardNumber,
                  decoration: const InputDecoration(
                    labelText: 'Número de tarjeta',
                    prefixIcon: Icon(Icons.credit_card),
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _expiry,
                        keyboardType: TextInputType.number,
                        inputFormatters: [ExpiryFormatter()],
                        validator: Validators.expiry,
                        decoration: const InputDecoration(
                          labelText: 'Vence (MM/AA)',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        controller: _cvv,
                        keyboardType: TextInputType.number,
                        obscureText: true,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(4),
                        ],
                        validator: Validators.cvv,
                        decoration: const InputDecoration(
                          labelText: 'CVV',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  'Pago simulado: no se realiza ningún cargo real. '
                  'Prueba con 4242 4242 4242 4242 (aprobada) o '
                  '4000 0000 0000 0002 (rechazada).',
                  style: theme.textTheme.bodySmall,
                ),
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: loading ? null : _pay,
                  child: loading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text('Pagar ${formatMoney(total)}'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}