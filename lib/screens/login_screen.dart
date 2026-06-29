import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/auth/auth_bloc.dart';
import '../blocs/auth/auth_event.dart';
import '../blocs/auth/auth_state.dart';
import 'customer/customer_home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  bool _isRegisterMode = false;
  bool _obscurePassword = true;
  final FocusNode _emailFocus = FocusNode();
  final FocusNode _passFocus = FocusNode();

  late final AnimationController _slideCtrl;
  late final Animation<Offset> _slideAnim;
  late final Animation<double> _fadeAnim;
  late final AnimationController _waveCtrl;

  @override
  void initState() {
    super.initState();
    _slideCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..forward();
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.12),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideCtrl, curve: Curves.easeOutCubic));
    _fadeAnim = CurvedAnimation(parent: _slideCtrl, curve: Curves.easeOut);

    _waveCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat();
  }

  @override
  void dispose() {
    _slideCtrl.dispose();
    _waveCtrl.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    _emailFocus.dispose();
    _passFocus.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      if (_isRegisterMode) {
        BlocProvider.of<AuthBloc>(context).add(
          RegisterSubmitted(
            name: _nameController.text.trim(),
            email: _emailController.text.trim(),
            password: _passwordController.text,
          ),
        );
      } else {
        BlocProvider.of<AuthBloc>(context).add(
          LoginSubmitted(
            email: _emailController.text.trim(),
            password: _passwordController.text,
          ),
        );
      }
    }
  }

  void _toggleMode() {
    _slideCtrl.reset();
    setState(() => _isRegisterMode = !_isRegisterMode);
    _slideCtrl.forward();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F0EB),
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthAuthenticated) {
            final role = state.user['role'] as String;
            if (role == 'customer' || role == 'admin') {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (_) => const CustomerHomeScreen()),
              );
            }
          } else if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: const Color(0xFFD97757),
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            );
          }
        },
        builder: (context, state) {
          return Stack(
            children: [
              // ── Top ilustrasi organik ──────────────────────────────────────
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: AnimatedBuilder(
                  animation: _waveCtrl,
                  builder: (_, __) => CustomPaint(
                    size: Size(size.width, size.height * 0.42),
                    painter: _TopShapePainter(_waveCtrl.value),
                  ),
                ),
              ),

              // ── Dekorasi lingkaran kecil ───────────────────────────────────
              Positioned(
                top: 60,
                right: 28,
                child: _FloatingDot(size: 10, color: const Color(0xFFE8C99A)),
              ),
              Positioned(
                top: 110,
                right: 60,
                child: _FloatingDot(size: 6, color: const Color(0xFFA8C5A0)),
              ),
              Positioned(
                top: 40,
                left: 40,
                child: _FloatingDot(size: 8, color: const Color(0xFFD4A8C7)),
              ),

              // ── Konten utama ───────────────────────────────────────────────
              SafeArea(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      SizedBox(height: size.height * 0.25),
                      // Header section
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32),
                        child: FadeTransition(
                          opacity: _fadeAnim,
                          child: SlideTransition(
                            position: _slideAnim,
                            child: _buildHeader(),
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                      // Form card
                      FadeTransition(
                        opacity: _fadeAnim,
                        child: SlideTransition(
                          position: _slideAnim,
                          child: _buildFormCard(state),
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Brand chip
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFFD97757).withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: const Color(0xFFD97757).withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 7,
                height: 7,
                decoration: const BoxDecoration(
                  color: Color(0xFFD97757),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 7),
              const Text(
                'MobileStore',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFFD97757),
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Text(
          _isRegisterMode ? 'Buat\nAkun Baru' : 'Halo,\nSelamat Datang!',
          style: const TextStyle(
            fontSize: 36,
            fontWeight: FontWeight.w800,
            color: Color(0xFF1A1A2E),
            height: 1.15,
            letterSpacing: -0.8,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          _isRegisterMode
              ? 'Daftar untuk mulai belanja HP favoritmu'
              : 'Masuk ke akunmu dan mulai belanja',
          style: const TextStyle(
            fontSize: 14,
            color: Color(0xFF6B7280),
            fontWeight: FontWeight.w400,
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildFormCard(AuthState state) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1A1A2E).withValues(alpha: 0.08),
            blurRadius: 40,
            offset: const Offset(0, 16),
          ),
          BoxShadow(
            color: const Color(0xFF1A1A2E).withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
      child: Form(
        key: _formKey,
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 320),
          transitionBuilder: (child, anim) => FadeTransition(
            opacity: anim,
            child: child,
          ),
          child: _isRegisterMode
              ? _buildRegisterFields(state, key: const ValueKey('r'))
              : _buildLoginFields(state, key: const ValueKey('l')),
        ),
      ),
    );
  }

  Widget _buildLoginFields(AuthState state, {Key? key}) {
    return Column(
      key: key,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildField(
          controller: _emailController,
          label: 'Email',
          hint: 'kamu@email.com',
          icon: Icons.alternate_email_rounded,
          keyboardType: TextInputType.emailAddress,
          focusNode: _emailFocus,
          nextFocus: _passFocus,
          validator: (val) {
            if (val == null || val.trim().isEmpty) return 'Email wajib diisi';
            if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(val)) {
              return 'Format email tidak valid';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        _buildField(
          controller: _passwordController,
          label: 'Kata Sandi',
          hint: 'Minimal 6 karakter',
          icon: Icons.key_rounded,
          obscure: _obscurePassword,
          focusNode: _passFocus,
          toggleObscure: () =>
              setState(() => _obscurePassword = !_obscurePassword),
          validator: (val) {
            if (val == null || val.isEmpty) return 'Kata sandi wajib diisi';
            if (val.length < 6) return 'Minimal 6 karakter';
            return null;
          },
        ),
        const SizedBox(height: 8),
        Align(
          alignment: Alignment.centerRight,
          child: Text(
            'Lupa sandi?',
            style: TextStyle(
              fontSize: 12.5,
              color: const Color(0xFFD97757).withValues(alpha: 0.8),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(height: 24),
        _buildSubmitButton(state),
        const SizedBox(height: 20),
        _buildDivider(),
        const SizedBox(height: 16),
        _buildToggleButton(),
      ],
    );
  }

  Widget _buildRegisterFields(AuthState state, {Key? key}) {
    return Column(
      key: key,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildField(
          controller: _nameController,
          label: 'Nama Lengkap',
          hint: 'Nama kamu',
          icon: Icons.badge_outlined,
          validator: (val) {
            if (val == null || val.trim().isEmpty) return 'Nama wajib diisi';
            return null;
          },
        ),
        const SizedBox(height: 16),
        _buildField(
          controller: _emailController,
          label: 'Email',
          hint: 'kamu@email.com',
          icon: Icons.alternate_email_rounded,
          keyboardType: TextInputType.emailAddress,
          validator: (val) {
            if (val == null || val.trim().isEmpty) return 'Email wajib diisi';
            if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(val)) {
              return 'Format email tidak valid';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        _buildField(
          controller: _passwordController,
          label: 'Kata Sandi',
          hint: 'Minimal 6 karakter',
          icon: Icons.key_rounded,
          obscure: _obscurePassword,
          toggleObscure: () =>
              setState(() => _obscurePassword = !_obscurePassword),
          validator: (val) {
            if (val == null || val.isEmpty) return 'Kata sandi wajib diisi';
            if (val.length < 6) return 'Minimal 6 karakter';
            return null;
          },
        ),
        const SizedBox(height: 28),
        _buildSubmitButton(state),
        const SizedBox(height: 20),
        _buildDivider(),
        const SizedBox(height: 16),
        _buildToggleButton(),
      ],
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    bool obscure = false,
    VoidCallback? toggleObscure,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    FocusNode? focusNode,
    FocusNode? nextFocus,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12.5,
            fontWeight: FontWeight.w700,
            color: Color(0xFF374151),
            letterSpacing: 0.2,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          focusNode: focusNode,
          style: const TextStyle(
            color: Color(0xFF1A1A2E),
            fontSize: 15,
            fontWeight: FontWeight.w500,
          ),
          obscureText: obscure,
          keyboardType: keyboardType,
          validator: validator,
          onFieldSubmitted: nextFocus != null
              ? (_) => FocusScope.of(context).requestFocus(nextFocus)
              : null,
          cursorColor: const Color(0xFFD97757),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(
              color: Color(0xFFBDBDBD),
              fontSize: 14,
              fontWeight: FontWeight.w400,
            ),
            prefixIcon: Container(
              margin: const EdgeInsets.all(10),
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: const Color(0xFFF5F0EB),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: const Color(0xFFD97757), size: 18),
            ),
            suffixIcon: toggleObscure != null
                ? GestureDetector(
                    onTap: toggleObscure,
                    child: Container(
                      margin: const EdgeInsets.all(10),
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5F0EB),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        obscure
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        color: const Color(0xFF9CA3AF),
                        size: 18,
                      ),
                    ),
                  )
                : null,
            filled: true,
            fillColor: const Color(0xFFFAFAFA),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Color(0xFFE5E7EB), width: 1.5),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide:
                  const BorderSide(color: Color(0xFFD97757), width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Color(0xFFEF4444), width: 1.5),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Color(0xFFEF4444), width: 2),
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            errorStyle: const TextStyle(
              color: Color(0xFFEF4444),
              fontSize: 11.5,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton(AuthState state) {
    final isLoading = state is AuthLoading;
    return GestureDetector(
      onTap: isLoading ? null : _submit,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        height: 54,
        decoration: BoxDecoration(
          color: isLoading
              ? const Color(0xFFD97757).withValues(alpha: 0.5)
              : const Color(0xFFD97757),
          borderRadius: BorderRadius.circular(16),
          boxShadow: isLoading
              ? []
              : [
                  BoxShadow(
                    color: const Color(0xFFD97757).withValues(alpha: 0.35),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
        ),
        child: Center(
          child: isLoading
              ? const SizedBox(
                  height: 22,
                  width: 22,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2.5,
                  ),
                )
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _isRegisterMode ? 'Buat Akun' : 'Masuk',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        letterSpacing: 0.2,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(Icons.arrow_forward_rounded,
                        color: Colors.white, size: 18),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 1,
            color: const Color(0xFFE5E7EB),
          ),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 14),
          child: Text(
            'atau',
            style: TextStyle(
              fontSize: 12,
              color: Color(0xFF9CA3AF),
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          child: Container(
            height: 1,
            color: const Color(0xFFE5E7EB),
          ),
        ),
      ],
    );
  }

  Widget _buildToggleButton() {
    return GestureDetector(
      onTap: _toggleMode,
      child: Center(
        child: RichText(
          text: TextSpan(
            style: const TextStyle(fontSize: 13.5, color: Color(0xFF6B7280)),
            children: [
              TextSpan(
                text: _isRegisterMode
                    ? 'Sudah punya akun? '
                    : 'Belum punya akun? ',
              ),
              const TextSpan(
                text: 'Daftar sekarang',
                style: TextStyle(
                  color: Color(0xFFD97757),
                  fontWeight: FontWeight.w700,
                  decoration: TextDecoration.underline,
                  decorationColor: Color(0xFFD97757),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Floating dot dekorasi ──────────────────────────────────────────────────────
class _FloatingDot extends StatelessWidget {
  final double size;
  final Color color;
  const _FloatingDot({required this.size, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}

// ── Top organic shape painter ──────────────────────────────────────────────────
class _TopShapePainter extends CustomPainter {
  final double t;
  _TopShapePainter(this.t);

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Layer 1 – area utama hangat
    final paint1 = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          const Color(0xFFE8855A),
          const Color(0xFFD97757),
          const Color(0xFFC4603A),
        ],
      ).createShader(Rect.fromLTWH(0, 0, w, h));

    final path1 = Path();
    path1.moveTo(0, 0);
    path1.lineTo(w, 0);
    path1.lineTo(w, h * 0.72);
    // Kurva organik di bawah
    final waveOff = math.sin(t * math.pi * 2) * 18;
    path1.cubicTo(
      w * 0.75, h * (0.82 + 0.04 * math.cos(t * math.pi * 2)),
      w * 0.40, h * (0.68 + 0.03 * math.sin(t * math.pi * 2 + 1)),
      0, h * 0.78 + waveOff,
    );
    path1.close();
    canvas.drawPath(path1, paint1);

    // Layer 2 – aksen lebih terang di kiri atas
    final paint2 = Paint()
      ..color = const Color(0xFFEF9B75).withValues(alpha: 0.45)
      ..style = PaintingStyle.fill;

    final path2 = Path();
    path2.moveTo(0, 0);
    path2.lineTo(w * 0.55, 0);
    path2.cubicTo(
      w * 0.45, h * 0.35,
      w * 0.15, h * 0.45,
      0, h * 0.52,
    );
    path2.close();
    canvas.drawPath(path2, paint2);

    // Layer 3 – lingkaran dekorasi kanan bawah shape
    final paintCircle = Paint()
      ..color = Colors.white.withValues(alpha: 0.08);
    canvas.drawCircle(
      Offset(w * 0.85, h * 0.55 + math.sin(t * math.pi * 2) * 10),
      w * 0.22,
      paintCircle,
    );
    final paintCircle2 = Paint()
      ..color = Colors.white.withValues(alpha: 0.05);
    canvas.drawCircle(
      Offset(w * 0.72, h * 0.18),
      w * 0.14,
      paintCircle2,
    );

    // Teks brand di atas (opsional hiasan)
    // Sudut kiri bawah: garis dekoratif
    final paintLine = Paint()
      ..color = Colors.white.withValues(alpha: 0.15)
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;
    canvas.drawLine(
      Offset(24, h * 0.88),
      Offset(w * 0.35, h * 0.88),
      paintLine,
    );
  }

  @override
  bool shouldRepaint(_TopShapePainter old) => old.t != t;
}
