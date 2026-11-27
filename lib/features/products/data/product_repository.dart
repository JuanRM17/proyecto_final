import 'package:firebase_database/firebase_database.dart';

import '../models/product.dart';

class ProductRepository {
  ProductRepository(this._db);

  final FirebaseDatabase _db;

  Stream<List<Product>> watchProducts() {
    final ref = _db.ref('products');
    try {
      ref.keepSynced(true);
    } catch (_) {}

    return ref.onValue.map((event) {
      final value = event.snapshot.value;
      if (value is! Map) return <Product>[];

      return value.entries
          .where((e) => e.value is Map)
          .map((e) => Product.fromMap(
                e.key.toString(),
                Map<String, dynamic>.from(e.value as Map),
              ))
          .toList()
        ..sort((a, b) => a.name.compareTo(b.name));
    });
  }
}