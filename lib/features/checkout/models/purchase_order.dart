class OrderItem {
  const OrderItem({
    required this.productId,
    required this.name,
    required this.price,
    required this.quantity,
  });

  final String productId;
  final String name;
  final double price;
  final int quantity;

  Map<String, Object> toMap() => {
        'productId': productId,
        'name': name,
        'price': price,
        'quantity': quantity,
      };

  factory OrderItem.fromMap(Map<String, dynamic> map) => OrderItem(
        productId: map['productId'] as String? ?? '',
        name: map['name'] as String? ?? '',
        price: (map['price'] as num?)?.toDouble() ?? 0,
        quantity: (map['quantity'] as num?)?.toInt() ?? 1,
      );
}

class PurchaseOrder {
  const PurchaseOrder({
    required this.id,
    required this.items,
    required this.total,
    required this.address,
    required this.status,
    required this.paymentBrand,
    required this.paymentLast4,
    required this.createdAt,
  });

  final String id;
  final List<OrderItem> items;
  final double total;
  final String address;
  final String status;
  final String paymentBrand;
  final String paymentLast4;
  final DateTime createdAt;

  factory PurchaseOrder.fromMap(String id, Map<String, dynamic> map) {
    final rawItems = map['items'];
    return PurchaseOrder(
      id: id,
      items: rawItems is List
          ? rawItems
              .whereType<Map>()
              .map((e) => OrderItem.fromMap(Map<String, dynamic>.from(e)))
              .toList()
          : const [],
      total: (map['total'] as num?)?.toDouble() ?? 0,
      address: map['address'] as String? ?? '',
      status: map['status'] as String? ?? '',
      paymentBrand: map['paymentBrand'] as String? ?? '',
      paymentLast4: map['paymentLast4'] as String? ?? '',
      createdAt: DateTime.fromMillisecondsSinceEpoch(
        (map['createdAt'] as num?)?.toInt() ?? 0,
      ),
    );
  }
}