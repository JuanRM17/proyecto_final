import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/firebase_providers.dart';
import '../data/product_repository.dart';
import '../models/product.dart';

final productRepositoryProvider = Provider<ProductRepository>(
  (ref) => ProductRepository(ref.watch(firebaseDatabaseProvider)),
);

final productsProvider = StreamProvider.autoDispose<List<Product>>(
  (ref) => ref.watch(productRepositoryProvider).watchProducts(),
);

class ProductCategoryNotifier extends Notifier<String?> {
  @override
  String? build() => null;

  void select(String? category) => state = category;
}

final productCategoryProvider =
    NotifierProvider<ProductCategoryNotifier, String?>(
  ProductCategoryNotifier.new,
);

final filteredProductsProvider =
    Provider.autoDispose<AsyncValue<List<Product>>>((ref) {
  final category = ref.watch(productCategoryProvider);
  return ref.watch(productsProvider).whenData(
        (list) => category == null
            ? list
            : list.where((p) => p.category == category).toList(),
      );
});