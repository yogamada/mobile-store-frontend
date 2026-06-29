import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../blocs/cart/cart_bloc.dart';
import '../../blocs/cart/cart_event.dart';
import '../../blocs/cart/cart_state.dart';
import '../../blocs/order/order_bloc.dart';
import '../../blocs/order/order_event.dart';
import '../../blocs/order/order_state.dart';

const _kBg       = Color(0xFFF5F0EB);
const _kSurface  = Color(0xFFFFFFFF);
const _kCard     = Color(0xFFFFFFFF);
const _kBorder   = Color(0xFFEDE7DF);
const _kPrimary  = Color(0xFFD97757);
const _kGreen    = Color(0xFF22C55E);
const _kRed      = Color(0xFFDA3633);
const _kText     = Color(0xFF1A1A2E);
const _kTextMuted= Color(0xFF6B7280);

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat.currency(
      locale: 'id',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    return Scaffold(
      backgroundColor: _kBg,
      appBar: AppBar(
        backgroundColor: _kSurface,
        title: const Text(
          'Keranjang Belanja',
          style: TextStyle(
            color: _kText,
            fontWeight: FontWeight.w700,
            fontSize: 17,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: _kText, size: 18),
          onPressed: () => Navigator.of(context).pop(),
        ),
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: _kBorder),
        ),
      ),
      body: BlocListener<OrderBloc, OrderState>(
        listener: (context, state) {
          if (state is OrderCheckoutSuccess) {
            BlocProvider.of<CartBloc>(context).add(ClearCart());
            BlocProvider.of<OrderBloc>(context).add(FetchOrderHistory());

            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (ctx) => AlertDialog(
                backgroundColor: _kCard,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                title: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: _kGreen.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.check_circle_outline_rounded,
                          color: _kGreen, size: 22),
                    ),
                    const SizedBox(width: 12),
                    const Text('Transaksi Sukses',
                        style: TextStyle(
                            color: _kText,
                            fontWeight: FontWeight.bold,
                            fontSize: 16)),
                  ],
                ),
                content: const Text(
                  'Pembelian Anda berhasil diproses! Terima kasih telah berbelanja di MobileStore.',
                  style: TextStyle(color: _kTextMuted, fontSize: 14, height: 1.5),
                ),
                actions: [
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(ctx).pop();
                        Navigator.of(context).pop();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _kPrimary,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text('Kembali ke Toko',
                          style: TextStyle(
                              color: Colors.white, fontWeight: FontWeight.w600)),
                    ),
                  ),
                ],
              ),
            );
          } else if (state is OrderError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: _kRed,
              ),
            );
          }
        },
        child: BlocBuilder<CartBloc, CartState>(
          builder: (context, cartState) {
            if (cartState.items.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: _kCard,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: _kBorder),
                      ),
                      child: const Icon(Icons.shopping_bag_outlined,
                          color: _kTextMuted, size: 44),
                    ),
                    const SizedBox(height: 16),
                    const Text('Keranjang kosong',
                        style: TextStyle(
                            color: _kText,
                            fontSize: 17,
                            fontWeight: FontWeight.w600)),
                    const SizedBox(height: 6),
                    const Text('Tambahkan produk dari katalog',
                        style: TextStyle(color: _kTextMuted, fontSize: 13)),
                  ],
                ),
              );
            }

            final items = cartState.items.values.toList();

            return Column(
              children: [
                // ── Item count header ──────────────────────────────────────
                Container(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                  color: _kSurface,
                  child: Row(
                    children: [
                      Text(
                        '${items.length} item dipilih',
                        style: const TextStyle(
                            color: _kTextMuted, fontSize: 13),
                      ),
                      const Spacer(),
                      GestureDetector(
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              backgroundColor: _kCard,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14)),
                              title: const Text('Hapus Semua?',
                                  style: TextStyle(
                                      color: _kText,
                                      fontWeight: FontWeight.bold)),
                              content: const Text(
                                  'Semua produk di keranjang akan dihapus.',
                                  style: TextStyle(color: _kTextMuted)),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(ctx),
                                  child: const Text('Batal',
                                      style: TextStyle(color: _kTextMuted)),
                                ),
                                ElevatedButton(
                                  onPressed: () {
                                    BlocProvider.of<CartBloc>(context)
                                        .add(ClearCart());
                                    Navigator.pop(ctx);
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: _kRed,
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(8)),
                                  ),
                                  child: const Text('Hapus',
                                      style:
                                          TextStyle(color: Colors.white)),
                                ),
                              ],
                            ),
                          );
                        },
                        child: const Text(
                          'Hapus Semua',
                          style: TextStyle(color: _kRed, fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                ),

                // ── Cart items list ────────────────────────────────────────
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: items.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final cartItem = items[index];
                      final product = cartItem.product;
                      final id = product['id'] as int;
                      final name = product['name'] ?? '';
                      final brand = product['brand'] ?? '';
                      final price =
                          double.tryParse(product['price'].toString()) ?? 0.0;
                      final qty = cartItem.quantity;
                      final imageUrl = product['image_url'] ?? '';
                      final subtotal = price * qty;

                      return Container(
                        decoration: BoxDecoration(
                          color: _kCard,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: _kBorder),
                        ),
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Product image
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Container(
                                    width: 72,
                                    height: 72,
                                    color: _kSurface,
                                    child: imageUrl.isNotEmpty
                                        ? Image.network(
                                            imageUrl,
                                            fit: BoxFit.cover,
                                            errorBuilder: (_, __, ___) =>
                                                const Icon(
                                                    Icons.image_outlined,
                                                    color: _kBorder,
                                                    size: 28),
                                          )
                                        : const Icon(
                                            Icons.image_outlined,
                                            color: _kBorder,
                                            size: 28),
                                  ),
                                ),
                                const SizedBox(width: 12),

                                // Product info
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Container(
                                            padding:
                                                const EdgeInsets.symmetric(
                                                    horizontal: 6,
                                                    vertical: 2),
                                            decoration: BoxDecoration(
                                              color: _kPrimary
                                                  .withValues(alpha: 0.12),
                                              borderRadius:
                                                  BorderRadius.circular(4),
                                            ),
                                            child: Text(
                                              brand.toString().toUpperCase(),
                                              style: const TextStyle(
                                                color: _kPrimary,
                                                fontSize: 9,
                                                fontWeight: FontWeight.w700,
                                                letterSpacing: 0.5,
                                              ),
                                            ),
                                          ),
                                          const Spacer(),
                                          // Delete button
                                          GestureDetector(
                                            onTap: () {
                                              BlocProvider.of<CartBloc>(
                                                      context)
                                                  .add(RemoveFromCart(id));
                                            },
                                            child: const Icon(
                                                Icons
                                                    .delete_outline_rounded,
                                                color: _kRed,
                                                size: 20),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        name,
                                        style: const TextStyle(
                                          color: _kText,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 14,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        currencyFormatter.format(price),
                                        style: const TextStyle(
                                          color: _kGreen,
                                          fontWeight: FontWeight.w700,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 10),
                            const Divider(color: _kBorder, height: 1),
                            const SizedBox(height: 10),

                            // Qty controls + subtotal
                            Row(
                              children: [
                                const Text('Jumlah:',
                                    style: TextStyle(
                                        color: _kTextMuted, fontSize: 13)),
                                const Spacer(),

                                // Qty controller
                                Container(
                                  decoration: BoxDecoration(
                                    color: _kSurface,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: _kBorder),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      _qtyButton(
                                        icon: Icons.remove_rounded,
                                        onTap: () {
                                          BlocProvider.of<CartBloc>(context)
                                              .add(UpdateQuantity(
                                                  id, qty - 1));
                                        },
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 14),
                                        child: Text(
                                          '$qty',
                                          style: const TextStyle(
                                            color: _kText,
                                            fontWeight: FontWeight.w700,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ),
                                      _qtyButton(
                                        icon: Icons.add_rounded,
                                        onTap: () {
                                          BlocProvider.of<CartBloc>(context)
                                              .add(UpdateQuantity(
                                                  id, qty + 1));
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  currencyFormatter.format(subtotal),
                                  style: const TextStyle(
                                    color: _kText,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),

                // ── Checkout footer ────────────────────────────────────────
                Container(
                  decoration: const BoxDecoration(
                    color: _kSurface,
                    border: Border(top: BorderSide(color: _kBorder)),
                  ),
                  child: SafeArea(
                    top: false,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 14, 16, 20),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Summary rows
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Subtotal',
                                  style: TextStyle(
                                      color: _kTextMuted, fontSize: 13)),
                              Text(
                                currencyFormatter.format(cartState.grandTotal),
                                style: const TextStyle(
                                    color: _kText, fontSize: 13),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Total Bayar',
                                  style: TextStyle(
                                      color: _kText,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700)),
                              Text(
                                currencyFormatter.format(cartState.grandTotal),
                                style: const TextStyle(
                                  color: _kGreen,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 18,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),

                          BlocBuilder<OrderBloc, OrderState>(
                            builder: (context, orderState) {
                              final isLoading = orderState is OrderLoading;

                              return SizedBox(
                                width: double.infinity,
                                height: 50,
                                child: ElevatedButton(
                                  onPressed: isLoading
                                      ? null
                                      : () {
                                          final orderItems = cartState
                                              .items.values
                                              .map((item) => {
                                                    'product_id':
                                                        item.product['id'],
                                                    'quantity': item.quantity,
                                                  })
                                              .toList();
                                          BlocProvider.of<OrderBloc>(context)
                                              .add(PlaceOrder(orderItems));
                                        },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: _kPrimary,
                                    disabledBackgroundColor:
                                        _kPrimary.withValues(alpha: 0.50),
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10)),
                                  ),
                                  child: isLoading
                                      ? const SizedBox(
                                          height: 20,
                                          width: 20,
                                          child: CircularProgressIndicator(
                                              color: Colors.white, strokeWidth: 2),
                                        )
                                      : const Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(Icons.lock_outline_rounded,
                                                color: Colors.white, size: 18),
                                            SizedBox(width: 8),
                                            Text(
                                              'Checkout Sekarang',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.w700,
                                                fontSize: 15,
                                              ),
                                            ),
                                          ],
                                        ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _qtyButton(
      {required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 34,
        height: 34,
        alignment: Alignment.center,
        child: Icon(icon, color: _kTextMuted, size: 18),
      ),
    );
  }
}
