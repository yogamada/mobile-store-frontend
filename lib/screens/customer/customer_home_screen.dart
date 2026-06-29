import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/auth/auth_event.dart';
import '../../blocs/auth/auth_state.dart';
import '../../blocs/product/product_bloc.dart';
import '../../blocs/product/product_event.dart';
import '../../blocs/product/product_state.dart';
import '../../blocs/cart/cart_bloc.dart';
import '../../blocs/cart/cart_event.dart';
import '../../blocs/cart/cart_state.dart';
import '../../blocs/order/order_bloc.dart';
import '../../blocs/order/order_event.dart';
import '../../blocs/order/order_state.dart';
import '../login_screen.dart';
import 'cart_screen.dart';
import 'product_detail_screen.dart';

// ─── Color palette (Aligned with MoboAdmin) ─────────────────────────────────
const _kBg       = Color(0xFFF5F0EB);
const _kSurface  = Color(0xFFFFFFFF);
const _kCard     = Color(0xFFFFFFFF);
const _kBorder   = Color(0xFFEDE7DF);
const _kPrimary  = Color(0xFFD97757);
const _kGreen    = Color(0xFF22C55E);
const _kText     = Color(0xFF1A1A2E);
const _kTextMuted= Color(0xFF6B7280);

class CustomerHomeScreen extends StatefulWidget {
  const CustomerHomeScreen({super.key});

  @override
  State<CustomerHomeScreen> createState() => _CustomerHomeScreenState();
}

class _CustomerHomeScreenState extends State<CustomerHomeScreen>
    with TickerProviderStateMixin {
  int _currentIndex = 0;
  final _searchController = TextEditingController();
  String _selectedBrand = 'Semua';
  Timer? _refreshTimer;
  Timer? _debounce;
  int _bannerPage = 0;
  late final PageController _bannerCtrl;
  Timer? _bannerTimer;

  late final AnimationController _fadeCtrl;
  late final Animation<double> _fadeAnim;

  final List<String> _brands = ['Semua', 'Apple', 'Samsung', 'Xiaomi'];

  final List<Map<String, dynamic>> _banners = [
    {
      'title': 'iPhone 15 Series',
      'sub': 'Performa terbaru dari Apple',
      'color': Color(0xFFEDE7DF),
      'accent': Color(0xFFD97757),
      'icon': Icons.phone_iphone_rounded,
      'tag': 'NEW ARRIVAL',
    },
    {
      'title': 'Samsung Galaxy AI',
      'sub': 'Kecerdasan buatan di genggamanmu',
      'color': Color(0xFFEDE7DF),
      'accent': Color(0xFFA8C5A0),
      'icon': Icons.auto_awesome_rounded,
      'tag': 'FEATURED',
    },
    {
      'title': 'Xiaomi 120W Flash',
      'sub': 'Isi penuh dalam 15 menit',
      'color': Color(0xFFEDE7DF),
      'accent': Color(0xFFE8C99A),
      'icon': Icons.bolt_rounded,
      'tag': 'HOT DEAL',
    },
  ];

  @override
  void initState() {
    super.initState();
    _bannerCtrl = PageController(viewportFraction: 0.92);
    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
    _fadeCtrl.forward();

    // Initial fetch
    BlocProvider.of<ProductBloc>(context).add(FetchProducts());
    BlocProvider.of<OrderBloc>(context).add(FetchOrderHistory());

    // Auto-refresh every 30 seconds
    _refreshTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      if (mounted && _searchController.text.isEmpty) {
        BlocProvider.of<ProductBloc>(context).add(FetchProducts());
      }
    });

    // Auto-slide banner every 4 seconds
    _bannerTimer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (mounted && _bannerCtrl.hasClients) {
        final next = (_bannerPage + 1) % _banners.length;
        _bannerCtrl.animateToPage(
          next,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    _bannerTimer?.cancel();
    _debounce?.cancel();
    _bannerCtrl.dispose();
    _fadeCtrl.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onLogout() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: _kCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Keluar Aplikasi',
            style: TextStyle(color: _kText, fontWeight: FontWeight.bold)),
        content: const Text(
          'Apakah Anda yakin ingin keluar dari akun ini?',
          style: TextStyle(color: _kTextMuted),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Batal', style: TextStyle(color: _kTextMuted)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              BlocProvider.of<AuthBloc>(context).add(LoggedOut());
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const LoginScreen()),
                (route) => false,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFDA3633),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Keluar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat.currency(
      locale: 'id',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    return Scaffold(
      backgroundColor: _kBg,
      body: FadeTransition(
        opacity: _fadeAnim,
        child: IndexedStack(
          index: _currentIndex,
          children: [
            _buildCatalogTab(currencyFormatter),
            _buildOrderHistoryTab(currencyFormatter),
            _buildProfileTab(),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  // ── Bottom Navigation ─────────────────────────────────────────────────────
  Widget _buildBottomNav() {
    return Container(
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: _kBorder, width: 1)),
        color: _kSurface,
      ),
      child: SafeArea(
        child: SizedBox(
          height: 60,
          child: Row(
            children: [
              _navItem(0, Icons.storefront_outlined, Icons.storefront, 'Katalog'),
              _navItem(1, Icons.receipt_long_outlined, Icons.receipt_long, 'Riwayat'),
              _navItem(2, Icons.person_outline, Icons.person, 'Profil'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _navItem(int index, IconData icon, IconData activeIcon, String label) {
    final isActive = _currentIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _currentIndex = index),
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isActive ? activeIcon : icon,
              color: isActive ? _kPrimary : _kTextMuted,
              size: 22,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isActive ? _kPrimary : _kTextMuted,
                fontSize: 11,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // CATALOG TAB
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _buildCatalogTab(NumberFormat currencyFormatter) {
    return BlocBuilder<ProductBloc, ProductState>(
      builder: (context, state) {
        List<dynamic> filteredProducts = [];
        if (state is ProductsLoaded) {
          filteredProducts = state.products.where((p) {
            if (_selectedBrand == 'Semua') return true;
            final brand = p['brand']?.toString().toLowerCase() ?? '';
            return brand == _selectedBrand.toLowerCase();
          }).toList();
        }

        return RefreshIndicator(
          color: _kPrimary,
          backgroundColor: _kCard,
          onRefresh: () async {
            BlocProvider.of<ProductBloc>(context)
                .add(FetchProducts(search: _searchController.text.isEmpty ? null : _searchController.text));
          },
          child: CustomScrollView(
            slivers: [
              // ── AppBar ─────────────────────────────────────────────────
              SliverAppBar(
                pinned: true,
                backgroundColor: _kSurface,
                surfaceTintColor: Colors.transparent,
                elevation: 0,
                expandedHeight: 0,
                bottom: PreferredSize(
                  preferredSize: const Size.fromHeight(1),
                  child: Container(height: 1, color: _kBorder),
                ),
                title: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: _kPrimary.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.phone_android_rounded,
                          color: _kPrimary, size: 16),
                    ),
                    const SizedBox(width: 10),
                    const Text(
                      'MobileStore',
                      style: TextStyle(
                        color: _kText,
                        fontWeight: FontWeight.w700,
                        fontSize: 17,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const Spacer(),
                    // Auto-refresh indicator
                    if (state is ProductLoading)
                      const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          color: _kPrimary,
                          strokeWidth: 2,
                        ),
                      )
                    else
                      GestureDetector(
                        onTap: () {
                          BlocProvider.of<ProductBloc>(context)
                              .add(FetchProducts(search: _searchController.text.isEmpty ? null : _searchController.text));
                        },
                        child: const Icon(Icons.refresh_rounded,
                            color: _kTextMuted, size: 20),
                      ),
                    const SizedBox(width: 12),
                    BlocBuilder<CartBloc, CartState>(
                      builder: (context, cartState) {
                        return GestureDetector(
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(
                                builder: (_) => const CartScreen()),
                          ),
                          child: Stack(
                            clipBehavior: Clip.none,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(7),
                                decoration: BoxDecoration(
                                  color: _kCard,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: _kBorder),
                                ),
                                child: const Icon(
                                    Icons.shopping_bag_outlined,
                                    color: _kText,
                                    size: 19),
                              ),
                              if (cartState.totalItemsCount > 0)
                                Positioned(
                                  right: -6,
                                  top: -6,
                                  child: Container(
                                    width: 18,
                                    height: 18,
                                    decoration: const BoxDecoration(
                                      color: Color(0xFFDA3633),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Center(
                                      child: Text(
                                        '${cartState.totalItemsCount}',
                                        style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        );
                      },
                    ),
                    const SizedBox(width: 10),
                    GestureDetector(
                      onTap: _onLogout,
                      child: Container(
                        padding: const EdgeInsets.all(7),
                        decoration: BoxDecoration(
                          color: _kCard,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: _kBorder),
                        ),
                        child: const Icon(Icons.logout_rounded,
                            color: _kTextMuted, size: 19),
                      ),
                    ),
                  ],
                ),
              ),

              // ── Greeting ───────────────────────────────────────────────
              SliverToBoxAdapter(
                child: BlocBuilder<AuthBloc, AuthState>(
                  builder: (ctx, authState) {
                    final name = authState is AuthAuthenticated
                        ? authState.user['name'] ?? 'Pelanggan'
                        : 'Pelanggan';
                    return Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Hai, $name 👋',
                            style: const TextStyle(
                              color: _kText,
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 2),
                          const Text(
                            'Temukan HP impianmu hari ini',
                            style: TextStyle(
                              color: _kTextMuted,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),

              // ── Search bar ─────────────────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
                  child: _buildSearchBar(),
                ),
              ),

              // ── Hero promo banners ─────────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: _buildHeroBanners(),
                ),
              ),

              // ── Brand filter chips ─────────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(0, 16, 0, 0),
                  child: _buildBrandChips(),
                ),
              ),

              // ── Section header ─────────────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                  child: Row(
                    children: [
                      const Text(
                        'Produk',
                        style: TextStyle(
                          color: _kText,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(width: 8),
                      if (state is ProductsLoaded)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: _kPrimary.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${filteredProducts.length}',
                            style: const TextStyle(
                                color: _kPrimary,
                                fontSize: 12,
                                fontWeight: FontWeight.w600),
                          ),
                        ),
                      const Spacer(),
                      if (state is ProductsLoaded)
                        Text(
                          'Diperbarui otomatis',
                          style: const TextStyle(
                              color: _kTextMuted, fontSize: 11),
                        ),
                    ],
                  ),
                ),
              ),

              // ── Divider ────────────────────────────────────────────────
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Divider(color: _kBorder, height: 1),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 12)),

              // ── Product grid ───────────────────────────────────────────
              if (state is ProductLoading)
                const SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(color: _kPrimary, strokeWidth: 2),
                        SizedBox(height: 16),
                        Text('Memuat produk...',
                            style: TextStyle(color: _kTextMuted, fontSize: 14)),
                      ],
                    ),
                  ),
                )
              else if (state is ProductsLoaded) ...[
                if (filteredProducts.isEmpty)
                  const SliverFillRemaining(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.search_off_rounded,
                              color: _kTextMuted, size: 48),
                          SizedBox(height: 12),
                          Text('Produk tidak ditemukan',
                              style: TextStyle(
                                  color: _kText,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600)),
                          SizedBox(height: 4),
                          Text('Coba kata kunci atau filter lain',
                              style:
                                  TextStyle(color: _kTextMuted, fontSize: 13)),
                        ],
                      ),
                    ),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 30),
                    sliver: SliverGrid(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 12,
                        crossAxisSpacing: 12,
                        childAspectRatio: 0.63,
                      ),
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final product =
                              filteredProducts[index] as Map<String, dynamic>;
                          return _buildProductCard(
                              context, product, currencyFormatter);
                        },
                        childCount: filteredProducts.length,
                      ),
                    ),
                  ),
              ] else if (state is ProductError)
                SliverFillRemaining(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.wifi_off_rounded,
                              color: _kTextMuted, size: 48),
                          const SizedBox(height: 12),
                          Text(
                            state.message,
                            style: const TextStyle(
                                color: _kTextMuted, fontSize: 14),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 20),
                          ElevatedButton.icon(
                            onPressed: () {
                              BlocProvider.of<ProductBloc>(context)
                                  .add(FetchProducts());
                            },
                            icon: const Icon(Icons.refresh_rounded, size: 18),
                            label: const Text('Coba Lagi'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _kPrimary,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  // ── Search bar ─────────────────────────────────────────────────────────────
  Widget _buildSearchBar() {
    return TextField(
      controller: _searchController,
      style: const TextStyle(color: _kText, fontSize: 14),
      decoration: InputDecoration(
        hintText: 'Cari handphone...',
        hintStyle: const TextStyle(color: _kTextMuted, fontSize: 14),
        prefixIcon: const Icon(Icons.search_rounded, color: _kTextMuted, size: 20),
        suffixIcon: _searchController.text.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.close_rounded,
                    color: _kTextMuted, size: 18),
                onPressed: () {
                  _searchController.clear();
                  _debounce?.cancel();
                  BlocProvider.of<ProductBloc>(context).add(FetchProducts());
                  setState(() {});
                },
              )
            : null,
        filled: true,
        fillColor: _kCard,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: _kBorder, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: _kBorder, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: _kPrimary, width: 1.5),
        ),
        contentPadding:
            const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      ),
      onChanged: (val) {
        if (_debounce?.isActive ?? false) _debounce!.cancel();
        _debounce = Timer(const Duration(milliseconds: 500), () {
          if (mounted) {
            BlocProvider.of<ProductBloc>(context)
                .add(FetchProducts(search: val.isEmpty ? null : val));
          }
        });
        setState(() {});
      },
    );
  }

  // ── Brand filter chips ─────────────────────────────────────────────────────
  Widget _buildBrandChips() {
    return SizedBox(
      height: 36,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: _brands.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final brand = _brands[index];
          final isSelected = _selectedBrand == brand;
          return GestureDetector(
            onTap: () => setState(() => _selectedBrand = brand),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
              decoration: BoxDecoration(
                color: isSelected
                    ? _kPrimary.withValues(alpha: 0.15)
                    : _kCard,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isSelected ? _kPrimary : _kBorder,
                  width: isSelected ? 1.5 : 1,
                ),
              ),
              child: Text(
                brand,
                style: TextStyle(
                  color: isSelected ? _kPrimary : _kTextMuted,
                  fontSize: 13,
                  fontWeight:
                      isSelected ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // ── Hero promo banners ─────────────────────────────────────────────────────
  Widget _buildHeroBanners() {
    return Column(
      children: [
        SizedBox(
          height: 140,
          child: PageView.builder(
            controller: _bannerCtrl,
            itemCount: _banners.length,
            onPageChanged: (i) => setState(() => _bannerPage = i),
            itemBuilder: (context, index) {
              final banner = _banners[index];
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  color: banner['color'] as Color,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: (banner['accent'] as Color).withValues(alpha: 0.30),
                    width: 1,
                  ),
                ),
                child: Stack(
                  children: [
                    // Big icon background
                    Positioned(
                      right: 16,
                      top: 0,
                      bottom: 0,
                      child: Icon(
                        banner['icon'] as IconData,
                        size: 100,
                        color: (banner['accent'] as Color)
                            .withValues(alpha: 0.12),
                      ),
                    ),
                    // Content
                    Padding(
                      padding: const EdgeInsets.all(18),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: (banner['accent'] as Color)
                                  .withValues(alpha: 0.20),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              banner['tag'] as String,
                              style: TextStyle(
                                color: banner['accent'] as Color,
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.8,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            banner['title'] as String,
                            style: const TextStyle(
                              color: _kText,
                              fontSize: 19,
                              fontWeight: FontWeight.w700,
                              height: 1.2,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            banner['sub'] as String,
                            style: const TextStyle(
                              color: _kTextMuted,
                              fontSize: 12.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 10),
        // Page indicator dots
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(_banners.length, (i) {
            return AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: _bannerPage == i ? 20 : 6,
              height: 6,
              decoration: BoxDecoration(
                color: _bannerPage == i ? _kPrimary : _kBorder,
                borderRadius: BorderRadius.circular(3),
              ),
            );
          }),
        ),
      ],
    );
  }

  // ── Product card ───────────────────────────────────────────────────────────
  Widget _buildProductCard(BuildContext context, Map<String, dynamic> product,
      NumberFormat currencyFormatter) {
    final name = product['name'] ?? '';
    final brand = product['brand'] ?? '';
    final price = double.tryParse(product['price'].toString()) ?? 0.0;
    final stock = product['stock'] as int? ?? 0;
    final imageUrl = product['image_url'] ?? '';
    final hasStock = stock > 0;

    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
              builder: (_) => ProductDetailScreen(product: product)),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: _kCard,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _kBorder, width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Image section ────────────────────────────────────────────
            Expanded(
              flex: 6,
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(11)),
                    child: SizedBox.expand(
                      child: imageUrl.isNotEmpty
                          ? Image.network(
                              imageUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) =>
                                  _imagePlaceholder(),
                            )
                          : _imagePlaceholder(),
                    ),
                  ),

                  // Stock badge
                  if (!hasStock)
                    Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      bottom: 0,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.55),
                          borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(11)),
                        ),
                        child: const Center(
                          child: Text('Stok Habis',
                              style: TextStyle(
                                  color: Colors.white70,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13)),
                        ),
                      ),
                    ),

                  // Brand chip
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 7, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.70),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        brand.toString().toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),

                  // Add to cart button
                  if (hasStock)
                    Positioned(
                      bottom: 8,
                      right: 8,
                      child: GestureDetector(
                        onTap: () {
                          BlocProvider.of<CartBloc>(context)
                              .add(AddToCart(product));
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('$name ditambahkan'),
                              duration: const Duration(seconds: 1),
                              action: SnackBarAction(
                                label: 'Lihat',
                                textColor: _kPrimary,
                                onPressed: () {
                                  Navigator.of(context).push(MaterialPageRoute(
                                      builder: (_) => const CartScreen()));
                                },
                              ),
                            ),
                          );
                        },
                        child: Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: _kPrimary,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.add_rounded,
                              color: Colors.white, size: 18),
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // ── Details section ──────────────────────────────────────────
            Expanded(
              flex: 4,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: _kText,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                        height: 1.3,
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          currencyFormatter.format(price),
                          style: const TextStyle(
                            color: _kGreen,
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          hasStock ? 'Stok: $stock' : 'Habis',
                          style: TextStyle(
                            color: hasStock
                                ? _kTextMuted
                                : const Color(0xFFDA3633),
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _imagePlaceholder() {
    return Container(
      color: _kSurface,
      child: const Center(
        child: Icon(Icons.phone_android_outlined,
            color: _kBorder, size: 36),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // ORDER HISTORY TAB
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _buildOrderHistoryTab(NumberFormat currencyFormatter) {
    return BlocBuilder<OrderBloc, OrderState>(
      builder: (context, state) {
        if (state is OrderLoading) {
          return const Center(
              child: CircularProgressIndicator(color: _kPrimary, strokeWidth: 2));
        } else if (state is OrderHistoryLoaded) {
          final orders = state.orders;

          if (orders.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: _kCard,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: _kBorder),
                    ),
                    child: const Icon(Icons.receipt_long_outlined,
                        color: _kTextMuted, size: 42),
                  ),
                  const SizedBox(height: 16),
                  const Text('Belum ada transaksi',
                      style: TextStyle(
                          color: _kText,
                          fontSize: 17,
                          fontWeight: FontWeight.w600)),
                  const SizedBox(height: 6),
                  const Text('Order kamu akan muncul di sini',
                      style: TextStyle(color: _kTextMuted, fontSize: 13)),
                ],
              ),
            );
          }

          return Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                decoration: const BoxDecoration(
                  color: _kSurface,
                  border: Border(bottom: BorderSide(color: _kBorder)),
                ),
                child: Row(
                  children: [
                    const Text(
                      'Riwayat Transaksi',
                      style: TextStyle(
                        color: _kText,
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: _kPrimary.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${orders.length} pesanan',
                        style: const TextStyle(
                            color: _kPrimary,
                            fontSize: 12,
                            fontWeight: FontWeight.w500),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: RefreshIndicator(
                  color: _kPrimary,
                  backgroundColor: _kCard,
                  onRefresh: () async {
                    BlocProvider.of<OrderBloc>(context)
                        .add(FetchOrderHistory());
                  },
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: orders.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final order =
                          orders[index] as Map<String, dynamic>;
                      final orderId = order['id'];
                      final total = double.tryParse(
                              order['total_amount'].toString()) ??
                          0.0;
                      final dateStr = order['created_at'] != null
                          ? DateFormat('dd MMM yyyy, HH:mm')
                              .format(DateTime.parse(order['created_at']))
                          : '';
                      final items =
                          order['items'] as List<dynamic>? ?? [];

                      return _buildOrderCard(
                          orderId, total, dateStr, items, currencyFormatter);
                    },
                  ),
                ),
              ),
            ],
          );
        } else if (state is OrderError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.wifi_off_rounded,
                    color: _kTextMuted, size: 48),
                const SizedBox(height: 12),
                Text(state.message,
                    style: const TextStyle(color: _kTextMuted, fontSize: 14)),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () => BlocProvider.of<OrderBloc>(context)
                      .add(FetchOrderHistory()),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _kPrimary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text('Coba Lagi'),
                ),
              ],
            ),
          );
        }
        return const SizedBox();
      },
    );
  }

  Widget _buildOrderCard(dynamic orderId, double total, String dateStr,
      List<dynamic> items, NumberFormat currencyFormatter) {
    return Container(
      decoration: BoxDecoration(
        color: _kCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _kBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
            child: Row(
              children: [
                Text(
                  '#ORD-${orderId.toString().padLeft(4, '0')}',
                  style: const TextStyle(
                    color: _kText,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
                const Spacer(),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: _kGreen.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                        color: _kGreen.withValues(alpha: 0.30)),
                  ),
                  child: const Text(
                    'Selesai',
                    style: TextStyle(
                      color: _kGreen,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 0, 14, 10),
            child: Text(dateStr,
                style: const TextStyle(color: _kTextMuted, fontSize: 12)),
          ),
          const Divider(color: _kBorder, height: 1),

          // Items
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              children: [
                ...items.map((item) {
                  final prodName = item['product'] != null
                      ? item['product']['name']
                      : 'Produk Dihapus';
                  final quantity = item['quantity'] ?? 1;
                  final price =
                      double.tryParse(item['price'].toString()) ?? 0.0;

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        Container(
                          width: 4,
                          height: 4,
                          decoration: const BoxDecoration(
                            color: _kPrimary,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(prodName,
                              style: const TextStyle(
                                  color: _kText, fontSize: 13)),
                        ),
                        Text(
                          '${quantity}x  ${currencyFormatter.format(price)}',
                          style: const TextStyle(
                              color: _kTextMuted, fontSize: 12),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),

          // Total footer
          Container(
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: _kBorder)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Total',
                    style:
                        TextStyle(color: _kTextMuted, fontSize: 13)),
                Text(
                  currencyFormatter.format(total),
                  style: const TextStyle(
                    color: _kGreen,
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // PROFILE TAB
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _buildProfileTab() {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is AuthAuthenticated) {
          final user = state.user;
          final name = user['name'] ?? '';
          final email = user['email'] ?? '';
          final role = user['role'] ?? '';
          final initial = name.isNotEmpty ? name[0].toUpperCase() : 'U';

          return SingleChildScrollView(
            child: Column(
              children: [
                // ── Header ────────────────────────────────────────────────
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(20, 48, 20, 24),
                  decoration: const BoxDecoration(
                    color: _kSurface,
                    border: Border(bottom: BorderSide(color: _kBorder)),
                  ),
                  child: Row(
                    children: [
                      // Avatar
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: _kPrimary.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                              color: _kPrimary.withValues(alpha: 0.30)),
                        ),
                        child: Center(
                          child: Text(
                            initial,
                            style: const TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.w700,
                              color: _kPrimary,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              name,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: _kText,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              email,
                              style: const TextStyle(
                                  color: _kTextMuted, fontSize: 13),
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: _kPrimary.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                    color: _kPrimary.withValues(alpha: 0.25)),
                              ),
                              child: Text(
                                role.toString().toUpperCase(),
                                style: const TextStyle(
                                  color: _kPrimary,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.8,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // ── Info Section ───────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(left: 2, bottom: 8),
                        child: Text(
                          'INFORMASI AKUN',
                          style: TextStyle(
                            color: _kTextMuted,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1.0,
                          ),
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: _kCard,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: _kBorder),
                        ),
                        child: Column(
                          children: [
                            _profileTile(
                              icon: Icons.alternate_email_rounded,
                              label: 'Email',
                              value: email,
                            ),
                            const Divider(
                                color: _kBorder, height: 1, indent: 56),
                            _profileTile(
                              icon: Icons.verified_outlined,
                              label: 'Status',
                              value: 'Aktif',
                              valueColor: _kGreen,
                            ),
                            const Divider(
                                color: _kBorder, height: 1, indent: 56),
                            _profileTile(
                              icon: Icons.shield_outlined,
                              label: 'Tipe Akun',
                              value: role.toString()[0].toUpperCase() +
                                  role.toString().substring(1),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // ── Logout Button ──────────────────────────────────
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: OutlinedButton.icon(
                          onPressed: _onLogout,
                          icon: const Icon(Icons.logout_rounded,
                              size: 18, color: Color(0xFFDA3633)),
                          label: const Text(
                            'Keluar dari Akun',
                            style: TextStyle(
                              color: Color(0xFFDA3633),
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(
                              color: Color(0xFFDA3633),
                              width: 1,
                            ),
                            backgroundColor: const Color(0xFFDA3633)
                                .withValues(alpha: 0.06),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ],
            ),
          );
        }
        return const SizedBox();
      },
    );
  }

  Widget _profileTile({
    required IconData icon,
    required String label,
    required String value,
    Color? valueColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      child: Row(
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: _kSurface,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: _kTextMuted, size: 17),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: _kTextMuted,
                    fontSize: 11,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    color: valueColor ?? _kText,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
