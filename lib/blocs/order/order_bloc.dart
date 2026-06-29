import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/api_service.dart';
import 'order_event.dart';
import 'order_state.dart';

class OrderBloc extends Bloc<OrderEvent, OrderState> {
  final ApiService apiService;

  OrderBloc({required this.apiService}) : super(OrderInitial()) {
    on<PlaceOrder>(_onPlaceOrder);
    on<FetchOrderHistory>(_onFetchOrderHistory);
  }

  Future<void> _onPlaceOrder(PlaceOrder event, Emitter<OrderState> emit) async {
    emit(OrderLoading());
    try {
      final res = await apiService.checkout(event.items);
      if (res['success'] == true) {
        emit(OrderCheckoutSuccess(res['order'] as Map<String, dynamic>));
      } else {
        emit(OrderError(res['message'] ?? 'Checkout gagal.'));
      }
    } catch (e) {
      emit(OrderError('Terjadi kesalahan koneksi saat checkout: $e'));
    }
  }

  Future<void> _onFetchOrderHistory(FetchOrderHistory event, Emitter<OrderState> emit) async {
    emit(OrderLoading());
    try {
      final res = await apiService.getOrderHistory();
      if (res['success'] == true) {
        emit(OrderHistoryLoaded(res['orders'] as List<dynamic>));
      } else {
        emit(OrderError(res['message'] ?? 'Gagal mengambil riwayat transaksi.'));
      }
    } catch (e) {
      emit(OrderError('Terjadi kesalahan koneksi saat mengambil riwayat: $e'));
    }
  }
}
