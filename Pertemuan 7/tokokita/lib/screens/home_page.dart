import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/cart_controller.dart';
import '../models/product.dart';
import '../services/product_service.dart';
import '../widgets/product_card.dart';
import 'cart_page.dart';
import 'product_detail_page.dart';

/// HomePage — Halaman utama aplikasi TokoKita.
/// Menampilkan data produk langsung dari REST API (Fake Store API) menggunakan FutureBuilder,
/// mendukung pull-to-refresh (RefreshIndicator), penanganan error jaringan, dan simulasi kegagalan.
class HomePage extends StatefulWidget {
  final VoidCallback? onOpenCart;

  const HomePage({super.key, this.onOpenCart});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // ===========================================================================
  // PERTEMUAN 6: Mengambil instance CartController menggunakan Get.find()
  // ===========================================================================
  final CartController _cartController = Get.find<CartController>();

  // ===========================================================================
  // PERTEMUAN 7 — LANGKAH 4 & 5: STATE MANAGEMENT FUTURE & REST API
  // ===========================================================================
  /// Future yang menampung proses request HTTP GET dari Fake Store API
  late Future<List<Product>> _productsFuture;

  /// Cache daftar produk yang berhasil dimuat untuk filter kategori & penghapusan lokal
  List<Product>? _cachedProducts;

  /// Status apakah simulasi error sedang diaktifkan (Langkah 5)
  bool _simulateError = false;

  /// Kategori yang sedang dipilih untuk filter ('Semua' = tampilkan semua)
  String _selectedCategory = 'Semua';

  @override
  void initState() {
    super.initState();
    // LANGKAH 4 BUTIR 1: Inisialisasi pemanggilan fetchProducts() saat widget dimuat
    _loadProducts(simulateError: false);
  }

  /// Memulai pemanggilan fetchProducts() dari ProductService
  void _loadProducts({bool simulateError = false}) {
    setState(() {
      _simulateError = simulateError;
      _cachedProducts = null; // Reset cache agar FutureBuilder menampilkan loading/error
      _productsFuture = ProductService.fetchProducts(simulateError: simulateError);
      // Mendaftarkan error handler agar tidak dianggap unhandled exception di asynchronous zone
      _productsFuture.catchError((_) => <Product>[]);
    });
  }

  /// TUGAS MANDIRI 2: Fungsi refresh untuk RefreshIndicator
  Future<void> _handleRefresh() async {
    _loadProducts(simulateError: false);
    try {
      await _productsFuture;
    } catch (_) {
      // Error akan ditangani secara visual oleh snapshot FutureBuilder
    }
  }

  /// Menghapus produk secara lokal untuk menguji Lifecycle dispose() (Pertemuan 3)
  void _removeProduct(int productId) {
    setState(() {
      _cachedProducts?.removeWhere((p) => p.id == productId);
    });
  }

  /// Mengembalikan daftar produk asli dari API
  void _resetProducts() {
    _loadProducts(simulateError: false);
  }

  // Ikon untuk setiap kategori
  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'semua':
        return Icons.home_rounded;
      case 'elektronik':
        return Icons.laptop_mac;
      case 'fashion':
        return Icons.checkroom;
      case 'makanan':
        return Icons.restaurant;
      default:
        return Icons.category;
    }
  }

  // Warna untuk setiap kategori
  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'semua':
        return const Color(0xFF7C4DFF); // Ungu
      case 'elektronik':
        return const Color(0xFF1976D2); // Biru
      case 'fashion':
        return const Color(0xFFE91E63); // Pink
      case 'makanan':
        return const Color(0xFFFF5722); // Oranye
      default:
        return const Color(0xFF7C4DFF);
    }
  }

  @override
  Widget build(BuildContext context) {
    final categories = ['Semua', ...kategoriList];

    return Scaffold(
      backgroundColor: const Color(0xFFF3E5F5), // Lavender background
      body: SafeArea(
        child: Column(
          children: [
            // =================================================================
            // HEADER TOKOKITA: Judul, Indikator Status API, Tombol Simulasi Error,
            // Reset Produk, dan Ikon Keranjang dengan Badge Reaktif (Obx)
            // =================================================================
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(10),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Judul dan subjudul toko
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Text(
                            namaToko,
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF1565C0),
                              letterSpacing: -0.3,
                            ),
                          ),
                          const SizedBox(width: 8),
                          // Badge penanda REST API aktif
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE3F2FD),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color: const Color(0xFF90CAF9),
                                width: 0.8,
                              ),
                            ),
                            child: const Text(
                              'REST API',
                              style: TextStyle(
                                fontSize: 9.5,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1976D2),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        'Belanja jadi lebih mudah & real-time',
                        style: TextStyle(
                          fontSize: 12.5,
                          color: Color(0xFF64748B),
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),

                  // Aksi Header
                  Row(
                    children: [
                      // LANGKAH 5: Tombol Simulasi Error (Untuk pengamatan skenario 4 & 5)
                      IconButton(
                        icon: Icon(
                          _simulateError
                              ? Icons.error_rounded
                              : Icons.bug_report_outlined,
                          color: _simulateError
                              ? const Color(0xFFE53935)
                              : const Color(0xFF64748B),
                          size: 24,
                        ),
                        tooltip: _simulateError
                            ? 'Matikan Simulasi Error (Kembali Normal)'
                            : 'Simulasikan Error REST API (Langkah 5)',
                        onPressed: () {
                          _loadProducts(simulateError: !_simulateError);
                        },
                      ),

                      // Tombol Muat Ulang / Reset
                      IconButton(
                        icon: const Icon(Icons.refresh, color: Color(0xFF1976D2)),
                        tooltip: 'Muat Ulang Produk',
                        onPressed: _resetProducts,
                      ),

                      // Badge Keranjang Reaktif (Obx) dari Pertemuan 6
                      Obx(() {
                        final total = _cartController.totalItem;
                        return IconButton(
                          icon: Badge(
                            isLabelVisible: total > 0,
                            label: Text(
                              total > 99 ? '99+' : '$total',
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            backgroundColor: const Color(0xFFE53935),
                            child: const Icon(
                              Icons.shopping_cart_outlined,
                              color: Color(0xFF1976D2),
                              size: 26,
                            ),
                          ),
                          tooltip: 'Keranjang Belanja',
                          onPressed: () {
                            if (widget.onOpenCart != null) {
                              widget.onOpenCart!();
                            } else {
                              Get.to(() => const CartPage());
                            }
                          },
                        );
                      }),
                    ],
                  ),
                ],
              ),
            ),

            // =================================================================
            // FILTER KATEGORI PRODUK — Row of Chips
            // =================================================================
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              color: const Color(0xFFF3E5F5),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Kategori Produk:',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade700,
                        ),
                      ),
                      Text(
                        'Pilih untuk memfilter',
                        style: TextStyle(
                          fontSize: 11.5,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: categories.map((cat) {
                        final isSelected = _selectedCategory == cat;
                        final color = _getCategoryColor(cat);
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: FilterChip(
                            avatar: Icon(
                              _getCategoryIcon(cat),
                              size: 16,
                              color: isSelected ? Colors.white : color,
                            ),
                            label: Text(
                              cat,
                              style: TextStyle(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w600,
                                color: isSelected ? Colors.white : color,
                              ),
                            ),
                            selected: isSelected,
                            onSelected: (_) {
                              setState(() {
                                _selectedCategory = cat;
                              });
                            },
                            selectedColor: color,
                            backgroundColor: color.withAlpha(25),
                            side: BorderSide(
                              color: isSelected ? color : color.withAlpha(80),
                              width: 1.2,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            showCheckmark: false,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),

            // =================================================================
            // LANGKAH 4 & 5: FUTUREBUILDER UNTUK MENAMPILKAN DATA ASLI REST API
            // =================================================================
            Expanded(
              child: FutureBuilder<List<Product>>(
                future: _productsFuture,
                builder: (context, snapshot) {
                  // -----------------------------------------------------------
                  // LANGKAH 4 BUTIR 3: Tampilan Loading Indicator
                  // -----------------------------------------------------------
                  if (snapshot.connectionState == ConnectionState.waiting &&
                      _cachedProducts == null) {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const SizedBox(
                            width: 44,
                            height: 44,
                            child: CircularProgressIndicator(
                              strokeWidth: 3.5,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Color(0xFF1976D2),
                              ),
                            ),
                          ),
                          const SizedBox(height: 18),
                          const Text(
                            'Memuat produk dari Fake Store API...',
                            style: TextStyle(
                              fontSize: 14.5,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF334155),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Menghubungkan ke fakestoreapi.com',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  // -----------------------------------------------------------
                  // LANGKAH 5 BUTIR 2 & 3: Tampilan Error Ramah Pengguna & Tombol Coba Lagi
                  // -----------------------------------------------------------
                  if (snapshot.hasError && _cachedProducts == null) {
                    final errorMessage = snapshot.error
                        .toString()
                        .replaceAll('Exception: ', '');

                    return Center(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 32,
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 80,
                              height: 80,
                              decoration: const BoxDecoration(
                                color: Color(0xFFFFEBEE),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.cloud_off_rounded,
                                size: 44,
                                color: Color(0xFFE53935),
                              ),
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'Gagal Memuat Produk',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF1E293B),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              errorMessage.contains('SocketException') ||
                                      errorMessage.contains('koneksi')
                                  ? 'Tidak dapat terhubung ke internet. Periksa koneksi data atau Wi-Fi Anda.'
                                  : errorMessage,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 13,
                                color: Color(0xFF64748B),
                                height: 1.4,
                              ),
                            ),
                            const SizedBox(height: 20),
                            // LANGKAH 5 BUTIR 3: Tombol 'Coba Lagi'
                            ElevatedButton.icon(
                              onPressed: () => _loadProducts(simulateError: false),
                              icon: const Icon(Icons.refresh_rounded, size: 20),
                              label: const Text(
                                'Coba Lagi',
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 14,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF1976D2),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 12,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 2,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  // -----------------------------------------------------------
                  // LANGKAH 4 BUTIR 2: Data Berhasil Dimuat (Success State)
                  // -----------------------------------------------------------
                  if (snapshot.hasData && _cachedProducts == null) {
                    _cachedProducts = List<Product>.from(snapshot.data!);
                  }
                  final allProducts = _cachedProducts ?? snapshot.data ?? [];
                  final filtered = _selectedCategory == 'Semua'
                      ? allProducts
                      : allProducts
                          .where((p) => p.category == _selectedCategory)
                          .toList();

                  return Column(
                    children: [
                      // Sub-header informasi kategori dan jumlah produk yang dimuat dari API
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 6,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Kategori: $_selectedCategory',
                              style: const TextStyle(
                                fontSize: 14.5,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF37474F),
                              ),
                            ),
                            Text(
                              '${filtered.length} produk dari API',
                              style: TextStyle(
                                fontSize: 12.5,
                                color: Colors.grey.shade600,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Daftar Produk menggunakan ListView.builder & ProductCard
                      Expanded(
                        child: filtered.isEmpty
                            ? RefreshIndicator(
                                onRefresh: _handleRefresh,
                                child: ListView(
                                  physics:
                                      const AlwaysScrollableScrollPhysics(),
                                  children: [
                                    SizedBox(
                                      height: 240,
                                      child: Center(
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(
                                              Icons.inbox_rounded,
                                              size: 56,
                                              color: Colors.grey.shade400,
                                            ),
                                            const SizedBox(height: 8),
                                            Text(
                                              'Tidak ada produk di kategori $_selectedCategory',
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: Colors.grey.shade500,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : RefreshIndicator(
                                // TUGAS MANDIRI 2: Pull-to-refresh
                                onRefresh: _handleRefresh,
                                color: const Color(0xFF1976D2),
                                child: ListView.builder(
                                  physics:
                                      const AlwaysScrollableScrollPhysics(),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 4,
                                  ),
                                  itemCount: filtered.length,
                                  itemBuilder: (context, index) {
                                    final product = filtered[index];
                                    return ProductCard(
                                      key: ValueKey(product.id),
                                      product: product,
                                      onDelete: () =>
                                          _removeProduct(product.id),
                                      onTap: () {
                                        Get.to(
                                          () => ProductDetailPage(
                                            product: product,
                                          ),
                                        );
                                      },
                                    );
                                  },
                                ),
                              ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
