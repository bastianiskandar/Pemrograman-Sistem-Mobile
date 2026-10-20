import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/cart_controller.dart';
import '../models/product.dart';
import 'checkout_page.dart';
import 'main_page.dart';

/// CartPage — Halaman Keranjang Belanja TokoKita.
/// Menggunakan GetX (Get.find, Obx, RxList) untuk reaktivitas penuh.
/// Menggantikan placeholder dari Pertemuan 5 (Langkah 5 & Tugas Mandiri 1, 2, 3).
class CartPage extends StatelessWidget {
  final VoidCallback? onBrowseProducts;

  const CartPage({
    super.key,
    this.onBrowseProducts,
  });

  // Helper ikon kategori
  IconData _getProductIcon(Product p) {
    final name = p.name.toLowerCase();
    if (name.contains('laptop')) return Icons.laptop_mac;
    if (name.contains('smartphone')) return Icons.smartphone;
    if (name.contains('headphone')) return Icons.headphones;
    if (name.contains('sepatu')) return Icons.skateboarding;
    if (name.contains('jaket') ||
        name.contains('kemeja') ||
        name.contains('celana') ||
        name.contains('kaos') ||
        name.contains('topi')) {
      return Icons.checkroom;
    }
    if (name.contains('kopi') || name.contains('teh')) return Icons.coffee;
    if (name.contains('nasi') ||
        name.contains('mie') ||
        name.contains('roti') ||
        name.contains('burger')) {
      return Icons.fastfood;
    }
    if (name.contains('keyboard') ||
        name.contains('mouse') ||
        name.contains('smartwatch') ||
        name.contains('powerbank')) {
      return Icons.devices;
    }

    switch (p.category.toLowerCase()) {
      case 'elektronik':
        return Icons.devices;
      case 'fashion':
        return Icons.shopping_bag;
      case 'makanan':
        return Icons.restaurant;
      default:
        return Icons.inventory_2;
    }
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'elektronik':
        return const Color(0xFF1976D2);
      case 'fashion':
        return const Color(0xFFE91E63);
      case 'makanan':
        return const Color(0xFFFF5722);
      default:
        return const Color(0xFF7C4DFF);
    }
  }

  @override
  Widget build(BuildContext context) {
    // =========================================================================
    // LANGKAH 3 BUTIR 1: Mengambil instance CartController dengan Get.find()
    // =========================================================================
    final CartController cartController = Get.find<CartController>();

    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      appBar: AppBar(
        title: const Text(
          'Keranjang Belanja',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1E293B),
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0.5,
        actions: [
          // ===================================================================
          // TUGAS MANDIRI 2: Tombol 'Kosongkan Keranjang' beserta dialog konfirmasi
          // ===================================================================
          Obx(() {
            if (cartController.items.isEmpty) return const SizedBox.shrink();
            return TextButton.icon(
              onPressed: () => cartController.confirmClearCart(context),
              icon: const Icon(Icons.delete_sweep_outlined, size: 20, color: Color(0xFFDC2626)),
              label: const Text(
                'Kosongkan',
                style: TextStyle(
                  color: Color(0xFFDC2626),
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
            );
          }),
        ],
      ),
      // =======================================================================
      // LANGKAH 5 BUTIR 1 & TUGAS MANDIRI 1:
      // Tampilan nyata daftar item dari CartController menggunakan Obx dan ListView.builder
      // =======================================================================
      body: SafeArea(
        child: Obx(() {
          if (cartController.items.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 28.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: const Color(0xFF1976D2).withAlpha(16),
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.shopping_cart_outlined,
                          size: 52,
                          color: Color(0xFF1976D2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Keranjang Belanja Masih Kosong',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Pilih produk favorit Anda dari beranda dan tambahkan ke keranjang untuk mulai berbelanja.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13.5,
                        color: Color(0xFF64748B),
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () {
                        if (onBrowseProducts != null) {
                          onBrowseProducts!();
                        } else {
                          Get.offAll(() => const MainPage());
                        }
                      },
                      icon: const Icon(Icons.storefront_outlined, size: 18),
                      label: const Text('Mulai Belanja Sekarang'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1976D2),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          final items = cartController.items;

          return Column(
            children: [
              // Header Ringkasan Jumlah Item
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                color: Colors.white,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Daftar Belanjaan (${cartController.totalItem} barang)',
                      style: const TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF334155),
                      ),
                    ),
                    Text(
                      '${items.length} jenis produk',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1, thickness: 1, color: Color(0xFFE2E8F0)),

              // ===============================================================
              // LANGKAH 5 BUTIR 1: ListView.builder untuk menampilkan seluruh item
              // ===============================================================
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final item = items[index];
                    final product = item.product;
                    final categoryColor = _getCategoryColor(product.category);

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 1.5,
                      color: Colors.white,
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Thumbnail / Icon Produk
                                Container(
                                  width: 64,
                                  height: 64,
                                  decoration: BoxDecoration(
                                    color: categoryColor.withAlpha(20),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Center(
                                    child: Icon(
                                      _getProductIcon(product),
                                      color: categoryColor,
                                      size: 32,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),

                                // Detail Informasi Produk
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        product.name,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w700,
                                          fontSize: 14.5,
                                          color: Color(0xFF1E293B),
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: categoryColor.withAlpha(25),
                                              borderRadius: BorderRadius.circular(4),
                                            ),
                                            child: Text(
                                              product.category,
                                              style: TextStyle(
                                                fontSize: 11,
                                                fontWeight: FontWeight.w600,
                                                color: categoryColor,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            'Stok: ${product.stock}',
                                            style: const TextStyle(
                                              fontSize: 11.5,
                                              color: Color(0xFF64748B),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        formatRupiah(item.unitPrice),
                                        style: const TextStyle(
                                          fontSize: 13.5,
                                          fontWeight: FontWeight.w700,
                                          color: Color(0xFF1565C0),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                // =============================================
                                // LANGKAH 5 BUTIR 2: Tombol hapus pada setiap item
                                // memanggil removeFromCart
                                // =============================================
                                IconButton(
                                  icon: const Icon(
                                    Icons.delete_outline_rounded,
                                    color: Color(0xFFEF4444),
                                    size: 22,
                                  ),
                                  tooltip: 'Hapus dari Keranjang',
                                  onPressed: () {
                                    cartController.removeFromCart(product);
                                    Get.snackbar(
                                      'Item Dihapus',
                                      '${product.name} telah dihapus dari keranjang.',
                                      snackPosition: SnackPosition.BOTTOM,
                                      backgroundColor: const Color(0xFF334155),
                                      colorText: Colors.white,
                                      margin: const EdgeInsets.all(12),
                                      borderRadius: 8,
                                      duration: const Duration(seconds: 1),
                                    );
                                  },
                                ),
                              ],
                            ),

                            const Divider(height: 18, color: Color(0xFFF1F5F9)),

                            // =================================================
                            // TUGAS MANDIRI 1: Fitur Ubah Jumlah (Quantity) Per Item
                            // Mengatur kuantitas dengan tombol - dan +
                            // Total harga otomatis menyesuaikan menggunakan Obx
                            // =================================================
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    const Text(
                                      'Subtotal: ',
                                      style: TextStyle(
                                        fontSize: 12.5,
                                        color: Color(0xFF64748B),
                                      ),
                                    ),
                                    Text(
                                      formatRupiah(item.subtotal),
                                      style: const TextStyle(
                                        fontSize: 13.5,
                                        fontWeight: FontWeight.w800,
                                        color: Color(0xFF0F172A),
                                      ),
                                    ),
                                  ],
                                ),

                                // Pengatur kuantitas (- [qty] +)
                                Container(
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF8FAFC),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: const Color(0xFFE2E8F0)),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.remove, size: 16),
                                        color: const Color(0xFF334155),
                                        constraints: const BoxConstraints(
                                          minWidth: 32,
                                          minHeight: 32,
                                        ),
                                        padding: EdgeInsets.zero,
                                        tooltip: 'Kurangi',
                                        onPressed: () => cartController.decreaseQuantity(product),
                                      ),
                                      Container(
                                        constraints: const BoxConstraints(minWidth: 28),
                                        alignment: Alignment.center,
                                        child: Text(
                                          '${item.quantity}',
                                          style: const TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w800,
                                            color: Color(0xFF0F172A),
                                          ),
                                        ),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.add, size: 16),
                                        color: item.quantity < product.stock
                                            ? const Color(0xFF334155)
                                            : const Color(0xFFCBD5E1),
                                        constraints: const BoxConstraints(
                                          minWidth: 32,
                                          minHeight: 32,
                                        ),
                                        padding: EdgeInsets.zero,
                                        tooltip: 'Tambah',
                                        onPressed: item.quantity < product.stock
                                            ? () => cartController.increaseQuantity(product)
                                            : null,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        }),
      ),

      // =======================================================================
      // LANGKAH 5 BUTIR 3 & TUGAS MANDIRI 3:
      // Tampilkan totalHarga di bagian bawah & tombol Checkout dengan Get.off()
      // =======================================================================
      bottomNavigationBar: Obx(() {
        if (cartController.items.isEmpty) return const SizedBox.shrink();

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(15),
                blurRadius: 10,
                offset: const Offset(0, -3),
              ),
            ],
          ),
          child: SafeArea(
            child: Row(
              children: [
                // Total Harga Reaktif
                Expanded(
                  flex: 5,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Total Harga (${cartController.totalItem} item):',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF64748B),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        formatRupiah(cartController.totalHarga),
                        style: const TextStyle(
                          fontSize: 16.5,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF1565C0),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 12),

                // Tombol Checkout Berpindah menggunakan Get.off() (Tugas Mandiri 3)
                Expanded(
                  flex: 5,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.arrow_forward_rounded, size: 18),
                    label: const Text(
                      'Checkout',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1976D2),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 2,
                    ),
                    onPressed: () {
                      // =======================================================
                      // TUGAS MANDIRI 3: Berpindah ke CheckoutPage dari CartPage
                      // menggunakan Get.off()
                      // =======================================================
                      Get.off(() => const CheckoutPage());
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
}
