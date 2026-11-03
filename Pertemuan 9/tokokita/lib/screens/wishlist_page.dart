import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../models/product.dart';
import '../services/product_service.dart';
import '../services/wishlist_service.dart';
import '../widgets/category_tag.dart';
import '../widgets/price_label.dart';
import 'product_detail_page.dart';

/// WishlistPage — Halaman untuk menampilkan daftar produk favorit yang tersimpan
/// secara lokal di SharedPreferences (Pertemuan 9 — Langkah 2).
class WishlistPage extends StatefulWidget {
  const WishlistPage({super.key});

  @override
  State<WishlistPage> createState() => _WishlistPageState();
}

class _WishlistPageState extends State<WishlistPage> {
  bool _isLoading = true;
  List<String> _wishlistIds = [];
  List<Product> _allProducts = [];
  List<Product> _wishlistProducts = [];

  @override
  void initState() {
    super.initState();
    _loadWishlistData();
  }

  /// Memuat daftar ID dari SharedPreferences dan mencocokkan dengan data produk
  Future<void> _loadWishlistData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // 1. Ambil ID dari SharedPreferences
      final ids = await WishlistService.getWishlistIds();
      _wishlistIds = ids;

      // 2. Ambil data produk (dari API atau mock)
      List<Product> products = [];
      try {
        products = await ProductService.fetchProducts();
      } catch (_) {
        // Fallback ke dummyProducts jika offline
        products = List<Product>.from(dummyProducts);
      }
      _allProducts = products;

      // 3. Filter produk yang ID-nya ada di wishlist
      _wishlistProducts = _allProducts
          .where((p) => _wishlistIds.contains(p.id.toString()))
          .toList();
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  /// Langkah 2 Butir 2: Menghapus produk dari wishlist dan memperbarui tampilan
  Future<void> _removeItem(Product product) async {
    await WishlistService.removeFromWishlist(product.id);
    setState(() {
      _wishlistIds.remove(product.id.toString());
      _wishlistProducts.removeWhere((p) => p.id == product.id);
    });

    if (mounted) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${product.name} dihapus dari wishlist'),
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
          action: SnackBarAction(
            label: 'Batal',
            textColor: Colors.amber,
            onPressed: () async {
              await WishlistService.toggleFavorite(product.id);
              _loadWishlistData();
            },
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          'Wishlist Saya',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1E293B),
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          color: const Color(0xFF1E293B),
          onPressed: () => Get.back(),
        ),
      ),
      body: _isLoading
          ? const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 12),
                  Text(
                    'Memuat wishlist dari penyimpanan lokal...',
                    style: TextStyle(
                      fontSize: 13,
                      color: Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            )
          : _wishlistProducts.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: const Color(0xFFEFF6FF),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.favorite_border_rounded,
                            size: 40,
                            color: Color(0xFF1976D2),
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Wishlist Anda Masih Kosong',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1E293B),
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Simpan produk yang Anda sukai dengan menekan ikon hati di kartu produk.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 13.5,
                            color: Color(0xFF64748B),
                          ),
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton.icon(
                          onPressed: () => Get.back(),
                          icon: const Icon(Icons.shopping_bag_outlined, size: 18),
                          label: const Text('Jelajahi Produk'),
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
                )
              : RefreshIndicator(
                  onRefresh: _loadWishlistData,
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                    itemCount: _wishlistProducts.length,
                    itemBuilder: (context, index) {
                      final product = _wishlistProducts[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withAlpha(6),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Material(
                          color: Colors.transparent,
                          borderRadius: BorderRadius.circular(14),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(14),
                            onTap: () async {
                              await Get.to(
                                () => ProductDetailPage(product: product),
                              );
                              // Refresh setelah kembali jika status favorit berubah
                              _loadWishlistData();
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Row(
                                children: [
                                  // Gambar / Placeholder
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: Container(
                                      width: 70,
                                      height: 70,
                                      color: const Color(0xFFF1F5F9),
                                      child: product.imageUrl != null &&
                                              product.imageUrl!.isNotEmpty
                                          ? Image.network(
                                              product.imageUrl!,
                                              fit: BoxFit.contain,
                                              errorBuilder: (context, error, stackTrace) => const Icon(
                                                Icons.image_not_supported_outlined,
                                                color: Color(0xFF94A3B8),
                                              ),
                                            )
                                          : const Icon(
                                              Icons.inventory_2_outlined,
                                              color: Color(0xFF1976D2),
                                            ),
                                    ),
                                  ),
                                  const SizedBox(width: 14),

                                  // Detail Produk
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        CategoryTag(category: product.category),
                                        const SizedBox(height: 4),
                                        Text(
                                          product.name,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            fontSize: 14.5,
                                            fontWeight: FontWeight.w700,
                                            color: Color(0xFF1E293B),
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        PriceLabel(price: product.price),
                                      ],
                                    ),
                                  ),

                                  // Tombol Hapus dari Wishlist (Langkah 2 Butir 2)
                                  IconButton(
                                    icon: const Icon(
                                      Icons.delete_outline_rounded,
                                      color: Color(0xFFEF4444),
                                      size: 22,
                                    ),
                                    tooltip: 'Hapus dari Wishlist',
                                    onPressed: () => _removeItem(product),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}
