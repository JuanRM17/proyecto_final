import 'package:firebase_database/firebase_database.dart';

import '../models/purchase_order.dart';

class OrderRepository {
  OrderRepository(this._db);

  final FirebaseDatabase _db;

  Future<String> placeOrder({
    required String uid,
    required List<OrderItem> items,
    required double total,
    required String address,
    required String paymentBrand,
    required String paymentLast4,
    required String paymentRef,
  }) async {
    final ref = _db.ref('orders/$uid').push();
    await ref.set({
      'items': items.map((e) => e.toMap()).toList(),
      'total': total,
      'address': address,
      'status': 'Pagado',
      'paymentBrand': paymentBrand,
      'paymentLast4': paymentLast4,
      'paymentRef': paymentRef,
      'createdAt': ServerValue.timestamp,
    }).timeout(const Duration(seconds: 15));
    return ref.key!;
  }

  Stream<List<PurchaseOrder>> watchOrders(String uid) {
    return _db.ref('orders/$uid').onValue.map((event) {
      final value = event.snapshot.value;
      if (value is! Map) return <PurchaseOrder>[];

      return value.entries
          .where((e) => e.value is Map)
          .map((e) => PurchaseOrder.fromMap(
                e.key.toString(),
                Map<String, dynamic>.from(e.value as Map),
              ))
          .toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    });
  }
}