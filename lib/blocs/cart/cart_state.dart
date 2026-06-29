class CartItem {
  final Map<String, dynamic> product;
  final int quantity;

  CartItem({required this.product, required this.quantity});

  CartItem copyWith({Map<String, dynamic>? product, int? quantity}) {
    return CartItem(
      product: product ?? this.product,
      quantity: quantity ?? this.quantity,
    );
  }

  double get totalPrice {
    final price = double.tryParse(product['price'].toString()) ?? 0.0;
    return price * quantity;
  }
}

class CartState {
  final Map<int, CartItem> items;

  CartState({required this.items});

  double get grandTotal {
    return items.values.fold(0.0, (sum, item) => sum + item.totalPrice);
  }

  int get totalItemsCount {
    return items.values.fold(0, (sum, item) => sum + item.quantity);
  }
}
