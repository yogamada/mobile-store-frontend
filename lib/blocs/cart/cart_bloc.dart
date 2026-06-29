import 'package:flutter_bloc/flutter_bloc.dart';
import 'cart_event.dart';
import 'cart_state.dart';

class CartBloc extends Bloc<CartEvent, CartState> {
  CartBloc() : super(CartState(items: {})) {
    on<AddToCart>(_onAddToCart);
    on<RemoveFromCart>(_onRemoveFromCart);
    on<UpdateQuantity>(_onUpdateQuantity);
    on<ClearCart>(_onClearCart);
  }

  void _onAddToCart(AddToCart event, Emitter<CartState> emit) {
    final updatedItems = Map<int, CartItem>.from(state.items);
    final productId = event.product['id'] as int;

    if (updatedItems.containsKey(productId)) {
      final currentItem = updatedItems[productId]!;
      updatedItems[productId] = currentItem.copyWith(
        quantity: currentItem.quantity + 1,
      );
    } else {
      updatedItems[productId] = CartItem(product: event.product, quantity: 1);
    }

    emit(CartState(items: updatedItems));
  }

  void _onRemoveFromCart(RemoveFromCart event, Emitter<CartState> emit) {
    final updatedItems = Map<int, CartItem>.from(state.items);
    updatedItems.remove(event.productId);
    emit(CartState(items: updatedItems));
  }

  void _onUpdateQuantity(UpdateQuantity event, Emitter<CartState> emit) {
    final updatedItems = Map<int, CartItem>.from(state.items);
    final productId = event.productId;

    if (updatedItems.containsKey(productId)) {
      if (event.quantity <= 0) {
        updatedItems.remove(productId);
      } else {
        updatedItems[productId] = updatedItems[productId]!.copyWith(
          quantity: event.quantity,
        );
      }
    }

    emit(CartState(items: updatedItems));
  }

  void _onClearCart(ClearCart event, Emitter<CartState> emit) {
    emit(CartState(items: {}));
  }
}
