import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/api_service.dart';
import 'product_event.dart';
import 'product_state.dart';

class ProductBloc extends Bloc<ProductEvent, ProductState> {
  final ApiService apiService;

  ProductBloc({required this.apiService}) : super(ProductInitial()) {
    on<FetchProducts>(_onFetchProducts);
    on<FetchProductDetail>(_onFetchProductDetail);
  }

  Future<void> _onFetchProducts(FetchProducts event, Emitter<ProductState> emit) async {
    emit(ProductLoading());
    try {
      final res = await apiService.getProducts(search: event.search);
      if (res['success'] == true) {
        emit(ProductsLoaded(res['products'] as List<dynamic>));
      } else {
        emit(ProductError(res['message'] ?? 'Gagal memuat produk.'));
      }
    } catch (e) {
      emit(ProductError('Kesalahan koneksi saat memuat produk: $e'));
    }
  }

  Future<void> _onFetchProductDetail(FetchProductDetail event, Emitter<ProductState> emit) async {
    emit(ProductLoading());
    try {
      final res = await apiService.getProductDetail(event.id);
      if (res['success'] == true) {
        emit(ProductDetailLoaded(res['product'] as Map<String, dynamic>));
      } else {
        emit(ProductError(res['message'] ?? 'Gagal memuat detail produk.'));
      }
    } catch (e) {
      emit(ProductError('Kesalahan koneksi saat memuat detail produk: $e'));
    }
  }
}
