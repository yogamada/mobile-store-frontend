abstract class CartEvent {}

class AddToCart extends CartEvent {
  final Map<String, dynamic> product;

  AddToCart(this.product);
}

class RemoveFromCart extends CartEvent {
  final int productId;

  RemoveFromCart(this.productId);
}

class UpdateQuantity extends CartEvent {
  final int productId;
  final int quantity;

  UpdateQuantity(this.productId, this.quantity);
}

class ClearCart extends CartEvent {}
