abstract class ProductState {}

class ProductInitial extends ProductState {}

class ProductLoading extends ProductState {}

class ProductsLoaded extends ProductState {
  final List<dynamic> products;

  ProductsLoaded(this.products);
}

class ProductDetailLoaded extends ProductState {
  final Map<String, dynamic> product;

  ProductDetailLoaded(this.product);
}

class ProductError extends ProductState {
  final String message;

  ProductError(this.message);
}
