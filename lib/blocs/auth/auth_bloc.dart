import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/api_service.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final ApiService apiService;

  AuthBloc({required this.apiService}) : super(AuthInitial()) {
    on<AppStarted>(_onAppStarted);
    on<LoginSubmitted>(_onLoginSubmitted);
    on<RegisterSubmitted>(_onRegisterSubmitted);
    on<LoggedOut>(_onLoggedOut);
  }

  Future<void> _onAppStarted(AppStarted event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('access_token');

      if (token != null) {
        final profileRes = await apiService.getProfile();
        if (profileRes['success'] == true) {
          final Map<String, dynamic> user = profileRes['user'] as Map<String, dynamic>;
          emit(AuthAuthenticated(token: token, user: user));
        } else {
          // Token expired or invalid
          await prefs.remove('access_token');
          await prefs.remove('user_role');
          emit(AuthUnauthenticated());
        }
      } else {
        emit(AuthUnauthenticated());
      }
    } catch (e) {
      emit(AuthError('Gagal memproses start-up aplikasi: $e'));
    }
  }

  Future<void> _onLoginSubmitted(LoginSubmitted event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final res = await apiService.login(event.email, event.password);
      if (res['success'] == true) {
        final token = res['access_token'] as String;
        final user = res['user'] as Map<String, dynamic>;

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('access_token', token);
        await prefs.setString('user_role', user['role'] as String);

        emit(AuthAuthenticated(token: token, user: user));
      } else {
        emit(AuthError(res['message'] ?? 'Login gagal. Cek kembali email/password.'));
      }
    } catch (e) {
      emit(AuthError('Terjadi kesalahan koneksi saat login: $e'));
    }
  }

  Future<void> _onRegisterSubmitted(RegisterSubmitted event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final res = await apiService.register(event.name, event.email, event.password);
      if (res['success'] == true) {
        // Automatic login after successful registration
        final loginRes = await apiService.login(event.email, event.password);
        if (loginRes['success'] == true) {
          final token = loginRes['access_token'] as String;
          final user = loginRes['user'] as Map<String, dynamic>;

          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('access_token', token);
          await prefs.setString('user_role', user['role'] as String);

          emit(AuthAuthenticated(token: token, user: user));
        } else {
          emit(AuthError('Registrasi berhasil, tapi login otomatis gagal. Silakan login manual.'));
        }
      } else {
        String errMsg = 'Registrasi gagal.';
        if (res['errors'] != null) {
          final errors = res['errors'] as Map<String, dynamic>;
          errMsg = errors.values.map((e) => e.toString()).join('\n');
        } else if (res['message'] != null) {
          errMsg = res['message'];
        }
        emit(AuthError(errMsg));
      }
    } catch (e) {
      emit(AuthError('Terjadi kesalahan koneksi saat registrasi: $e'));
    }
  }

  Future<void> _onLoggedOut(LoggedOut event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      await apiService.logout();
    } catch (_) {}
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('access_token');
    await prefs.remove('user_role');
    
    emit(AuthUnauthenticated());
  }
}
