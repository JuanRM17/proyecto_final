import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../products/models/product.dart';
import '../models/cart_item.dart';

class CartNotifier extends Notifier<Map<String, CartItem>> {
  @override
  Map<String, CartItem> build() => {};

  void add(Product p) {
    final current = state[p.id];
    state = {
      ...state,
      p.id: current == null
          ? CartItem(
              productId: p.id,
              name: p.name,
              price: p.price,
              imageUrl: p.imageUrl,
              quantity: 1,
            )
          : current.copyWith(quantity: current.quantity + 1),
    };
  }

  void increment(String id) {
    final c = state[id];
    if (c == null) return;
    state = {...state, id: c.copyWith(quantity: c.quantity + 1)};
  }

  void decrement(String id) {
    final c = state[id];
    if (c == null) return;
    if (c.quantity <= 1) {
      remove(id);
    } else {
      state = {...state, id: c.copyWith(quantity: c.quantity - 1)};
    }
  }

  void remove(String id) {
    final next = {...state}..remove(id);
    state = next;
  }

  void clear() => state = {};
}

final cartProvider =
    NotifierProvider<CartNotifier, Map<String, CartItem>>(CartNotifier.new);

final cartCountProvider = Provider<int>(
  (ref) => ref.watch(cartProvider).values.fold(0, (s, i) => s + i.quantity),
);

final cartTotalProvider = Provider<double>(
  (ref) => ref
      .watch(cartProvider)
      .values
      .fold(0.0, (s, i) => s + i.price * i.quantity),
);