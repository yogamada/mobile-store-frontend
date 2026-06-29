abstract class ProductEvent {}

class FetchProducts extends ProductEvent {
  final String? search;

  FetchProducts({this.search});
}

class FetchProductDetail extends ProductEvent {
  final int id;

  FetchProductDetail(this.id);
}
