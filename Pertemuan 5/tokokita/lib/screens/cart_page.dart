import 'package:flutter/material.dart';

/// CartPage — Halaman placeholder untuk menu Keranjang pada BottomNavigationBar
/// (Langkah 5 & Tugas Mandiri 3).
class CartPage extends StatelessWidget {
  final VoidCallback? onBrowseProducts;

  const CartPage({
    super.key,
    this.onBrowseProducts,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
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
      ),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Ilustrasi Ikon Keranjang dengan Container lingkaran
                Container(
                  width: 110,
                  height: 110,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1976D2).withAlpha(18),
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.shopping_cart_outlined,
                      size: 56,
                      color: Color(0xFF1976D2),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Judul Halaman Placeholder
                const Text(
                  'Keranjang Belanja Masih Kosong',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 10),

                // Pesan Sederhana
                const Text(
                  'Anda belum memiliki item di keranjang belanja. Buka tab Beranda, pilih produk yang Anda inginkan, lalu tekan "Tambah ke Keranjang" untuk mulai berbelanja.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF64748B),
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 28),

                // Badge Informasi Placeholder
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.info_outline, size: 16, color: Color(0xFF1976D2)),
                      SizedBox(width: 8),
                      Text(
                        'Placeholder Menu Keranjang — Pertemuan 5',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF475569),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                if (onBrowseProducts != null)
                  ElevatedButton.icon(
                    onPressed: onBrowseProducts,
                    icon: const Icon(Icons.storefront_outlined, size: 18),
                    label: const Text('Jelajahi Produk Sekarang'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1976D2),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
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
        ),
      ),
    );
  }
}
