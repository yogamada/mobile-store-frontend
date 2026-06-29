import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'blocs/auth/auth_bloc.dart';
import 'blocs/auth/auth_event.dart';
import 'blocs/auth/auth_state.dart';
import 'blocs/product/product_bloc.dart';
import 'blocs/cart/cart_bloc.dart';
import 'blocs/order/order_bloc.dart';
import 'data/api_service.dart';
import 'screens/login_screen.dart';
import 'screens/customer/customer_home_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final apiService = ApiService();

    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(
          create: (_) => AuthBloc(apiService: apiService)..add(AppStarted()),
        ),
        BlocProvider<ProductBloc>(
          create: (_) => ProductBloc(apiService: apiService),
        ),
        BlocProvider<CartBloc>(
          create: (_) => CartBloc(),
        ),
        BlocProvider<OrderBloc>(
          create: (_) => OrderBloc(apiService: apiService),
        ),
      ],
      child: MaterialApp(
        title: 'MobileStore - Toko HP',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          brightness: Brightness.light,
          textTheme: GoogleFonts.plusJakartaSansTextTheme(
            ThemeData.light().textTheme,
          ),
          colorScheme: const ColorScheme.light(
            primary: Color(0xFFD97757),
            secondary: Color(0xFFE8C99A),
            surface: Color(0xFFFFFFFF),
            error: Color(0xFFEF4444),
          ),
          scaffoldBackgroundColor: const Color(0xFFF5F0EB),
          snackBarTheme: SnackBarThemeData(
            backgroundColor: const Color(0xFFFFFFFF),
            contentTextStyle: GoogleFonts.plusJakartaSans(color: const Color(0xFF1A1A2E)),
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(12)),
            ),
            behavior: SnackBarBehavior.floating,
          ),
          dialogTheme: const DialogThemeData(
            backgroundColor: Color(0xFFFFFFFF),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(20)),
            ),
          ),
        ),
        home: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            if (state is AuthLoading || state is AuthInitial) {
              return Scaffold(
                backgroundColor: const Color(0xFFF5F0EB),
                body: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.phone_android_rounded,
                        size: 64,
                        color: Color(0xFFD97757),
                      ),
                      const SizedBox(height: 24),
                      const CircularProgressIndicator(
                        color: Color(0xFFD97757),
                        strokeWidth: 2,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'MobileStore',
                        style: GoogleFonts.plusJakartaSans(
                          color: const Color(0xFF1A1A2E).withValues(alpha: 0.6),
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }

            if (state is AuthAuthenticated) {
              final role = state.user['role'] as String;
              if (role == 'customer' || role == 'admin') {
                return const CustomerHomeScreen();
              }
            }

            // AuthError atau AuthUnauthenticated → tampilkan LoginScreen
            // (LoginScreen sudah punya BlocConsumer listener untuk menampilkan error)
            return const LoginScreen();
          },
        ),
      ),
    );
  }
}
