import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/firebase_providers.dart';
import '../../auth/providers/auth_provider.dart';
import '../../cart/providers/cart_provider.dart';
import '../data/order_repository.dart';
import '../data/payment_simulator.dart';
import '../models/card_data.dart';
import '../models/purchase_order.dart';

final orderRepositoryProvider = Provider<OrderRepository>(
  (ref) => OrderRepository(ref.watch(firebaseDatabaseProvider)),
);

class CheckoutController extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  /// Cobra (simulado), guarda el pedido y vacía el carrito.
  /// Devuelve el id del pedido, o null si algo falló.
  Future<String?> pay({required String address, required CardData card}) async {
    final user = ref.read(sessionProvider);
    final cartItems = ref.read(cartProvider).values.toList();
    final total = ref.read(cartTotalProvider);
    if (user == null || cartItems.isEmpty) return null;

    state = const AsyncLoading();
    String? orderId;

    state = await AsyncValue.guard(() async {
      final result = await PaymentSimulator.charge(card: card, amount: total);
      orderId = await ref.read(orderRepositoryProvider).placeOrder(
            uid: user.uid,
            items: cartItems
                .map((i) => OrderItem(
                      productId: i.productId,
                      name: i.name,
                      price: i.price,
                      quantity: i.quantity,
                    ))
                .toList(),
            total: total,
            address: address,
            paymentBrand: card.brand,
            paymentLast4: card.last4,
            paymentRef: result.reference,
          );
      ref.read(cartProvider.notifier).clear();
    });

    return state.hasError ? null : orderId;
  }
}

final checkoutControllerProvider =
    AsyncNotifierProvider<CheckoutController, void>(CheckoutController.new);