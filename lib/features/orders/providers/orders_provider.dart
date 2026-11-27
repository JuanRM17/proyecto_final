import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/providers/auth_provider.dart';
import '../../checkout/models/purchase_order.dart';
import '../../checkout/providers/checkout_provider.dart';

final ordersProvider = StreamProvider.autoDispose<List<PurchaseOrder>>((ref) {
  final uid = ref.watch(sessionProvider.select((u) => u?.uid));
  if (uid == null) return Stream.value(const <PurchaseOrder>[]);
  return ref.watch(orderRepositoryProvider).watchOrders(uid);
});