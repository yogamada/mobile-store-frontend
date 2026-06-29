abstract class OrderState {}

class OrderInitial extends OrderState {}

class OrderLoading extends OrderState {}

class OrderCheckoutSuccess extends OrderState {
  final Map<String, dynamic> order;

  OrderCheckoutSuccess(this.order);
}

class OrderHistoryLoaded extends OrderState {
  final List<dynamic> orders;

  OrderHistoryLoaded(this.orders);
}

class OrderError extends OrderState {
  final String message;

  OrderError(this.message);
}
