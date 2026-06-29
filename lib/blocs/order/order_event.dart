abstract class OrderEvent {}

class PlaceOrder extends OrderEvent {
  final List<Map<String, dynamic>> items;

  PlaceOrder(this.items);
}

class FetchOrderHistory extends OrderEvent {}
