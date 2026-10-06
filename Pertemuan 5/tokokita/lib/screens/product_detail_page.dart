import 'package:flutter/material.dart';

import '../models/product.dart';
import '../widgets/category_tag.dart';
import '../widgets/stock_badge.dart';

/// ProductDetailPage — Halaman detail produk untuk TokoKita.
///
/// Mendukung dua skenario pengiriman data sesuai modul praktikum:
/// 1. Constructor parameter langsung (Langkah 1).
/// 2. Argument named route `ModalRoute.of(context)!.settings.arguments` (Langkah 2 & 3).
///
/// Menyediakan fitur counter kuantitas produk (Tugas Mandiri 1) dan mengembalikan
/// jumlah item yang dipilih ke halaman sebelumnya via `Navigator.pop(context, jumlah)` (Langkah 3).
class ProductDetailPage extends StatefulWidget {
  final Product? product;

  const ProductDetailPage({
    super.key,
    this.product,
  });

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  // Jumlah kuantitas produk yang ingin dibeli (Tugas Mandiri 1)
  int _quantity = 1;

  // Ikon helper berdasarkan nama atau kategori produk (konsisten dengan ProductCard)
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
        return const Color(0xFF0288D1);
      case 'makanan':
        return const Color(0xFF00897B);
      default:
        return const Color(0xFF1565C0);
    }
  }

  void _incrementQuantity(int maxStock) {
    if (_quantity < maxStock) {
      setState(() {
        _quantity++;
      });
    } else {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Jumlah maksimal sesuai stok tersedia ($maxStock item)'),
          duration: const Duration(seconds: 1),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _decrementQuantity() {
    if (_quantity > 1) {
      setState(() {
        _quantity--;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // LANGKAH 1 & 2: Mendapatkan objek Product dari constructor atau dari Route arguments
    final Product? resolvedProduct = widget.product ??
        (ModalRoute.of(context)?.settings.arguments as Product?);

    if (resolvedProduct == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Detail Produk'),
        ),
        body: const Center(
          child: Text('Data produk tidak ditemukan.'),
        ),
      );
    }

    final product = resolvedProduct;
    final categoryColor = _getCategoryColor(product.category);
    final statusStok = product.getStatusStok();
    final isOutOfStock = product.stock <= 0;

    // Hitung harga satuan final
    final double unitPrice = product is DiscountedProduct
        ? product.hitungHargaFinal()
        : product.price;
    final double totalPrice = unitPrice * _quantity;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      // =======================================================================
      // LANGKAH 1 BUTIR 4: Tombol / AppBar Back menggunakan Navigator.pop
      // =======================================================================
      appBar: AppBar(
        title: const Text(
          'Detail Produk',
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
          tooltip: 'Kembali',
          onPressed: () {
            // LANGKAH 1 BUTIR 4: Kembali ke HomePage tanpa membawa data tambahan
            Navigator.pop(context);
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart_outlined, size: 22),
            color: const Color(0xFF1E293B),
            tooltip: 'Keranjang Belanja',
            onPressed: () {
              Navigator.pushNamed(context, '/cart');
            },
          ),
          IconButton(
            icon: const Icon(Icons.share_outlined, size: 22),
            color: const Color(0xFF64748B),
            tooltip: 'Bagikan',
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Membagikan tautan ${product.name}'),
                  duration: const Duration(seconds: 1),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ===============================================================
              // TUGAS MANDIRI 1: Tampilan Layout Rapi menggunakan Stack & Container
              // Menampilkan gambar placeholder besar dengan badge diskon & stok
              // ===============================================================
              Stack(
                children: [
                  Container(
                    width: double.infinity,
                    height: 220,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: const Color(0xFFE2E8F0),
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF64748B).withAlpha(15),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          color: categoryColor.withAlpha(20),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          _getProductIcon(product),
                          size: 64,
                          color: categoryColor,
                        ),
                      ),
                    ),
                  ),

                  // Badge Diskon (jika ada) di pojok kanan atas
                  if (product is DiscountedProduct)
                    Positioned(
                      top: 14,
                      right: 14,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE53935),
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFE53935).withAlpha(60),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Text(
                          'Diskon ${product.discountPercent.toInt()}%',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.2,
                          ),
                        ),
                      ),
                    ),

                  // Badge Status Stok di pojok kiri bawah
                  Positioned(
                    bottom: 14,
                    left: 14,
                    child: StockBadge(status: statusStok),
                  ),
                ],
              ),

              const SizedBox(height: 18),

              // ===============================================================
              // LANGKAH 1 BUTIR 3 & TUGAS MANDIRI 1: Informasi Lengkap Produk
              // Nama, Kategori, Harga Normal / Coret, Deskripsi, dan Status Stok
              // ===============================================================
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF64748B).withAlpha(12),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Baris Tag Kategori & ID Produk
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        CategoryTag(
                          category: product.category,
                          customColor: categoryColor,
                        ),
                        Text(
                          'ID: #${product.id}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF94A3B8),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 10),

                    // Nama Produk
                    Text(
                      product.name,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF0F172A),
                        height: 1.25,
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Tampilan Harga
                    if (product is DiscountedProduct) ...[
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text(
                            product.formattedFinalPrice,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF1565C0),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            product.formattedPrice,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Color(0xFF94A3B8),
                              decoration: TextDecoration.lineThrough,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ] else ...[
                      Text(
                        product.formattedPrice,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF1565C0),
                        ),
                      ),
                    ],

                    const SizedBox(height: 16),
                    const Divider(color: Color(0xFFF1F5F9), thickness: 1.2),
                    const SizedBox(height: 12),

                    // Rincian Stok dalam bentuk Row
                    Row(
                      children: [
                        const Icon(
                          Icons.inventory_2_outlined,
                          size: 18,
                          color: Color(0xFF64748B),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Sisa Stok:',
                          style: TextStyle(
                            fontSize: 13.5,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '${product.stock} unit ($statusStok)',
                          style: TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w700,
                            color: isOutOfStock
                                ? const Color(0xFFC62828)
                                : const Color(0xFF1E293B),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Deskripsi Produk
                    const Text(
                      'Deskripsi Produk',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      product.description != null &&
                              product.description!.isNotEmpty
                          ? product.description!
                          : 'Tidak ada deskripsi detail untuk produk ini.',
                      style: const TextStyle(
                        fontSize: 13.5,
                        color: Color(0xFF475569),
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 18),

              // ===============================================================
              // TUGAS MANDIRI 1: Tombol Tambah/Kurang Jumlah Pembelian
              // ===============================================================
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Atur Jumlah',
                          style: TextStyle(
                            fontSize: 14.5,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1E293B),
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Pilih kuantitas pesanan',
                          style: TextStyle(
                            fontSize: 12,
                            color: Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),

                    // Tombol Counter (-) [Value] (+)
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFFCBD5E1), width: 0.8),
                      ),
                      child: Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.remove, size: 18),
                            color: _quantity > 1
                                ? const Color(0xFF1E293B)
                                : const Color(0xFF94A3B8),
                            onPressed:
                                (!isOutOfStock && _quantity > 1) ? _decrementQuantity : null,
                            constraints: const BoxConstraints(
                              minWidth: 36,
                              minHeight: 36,
                            ),
                            padding: EdgeInsets.zero,
                          ),
                          Container(
                            constraints: const BoxConstraints(minWidth: 36),
                            alignment: Alignment.center,
                            child: Text(
                              isOutOfStock ? '0' : '$_quantity',
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF0F172A),
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.add, size: 18),
                            color: (!isOutOfStock && _quantity < product.stock)
                                ? const Color(0xFF1E293B)
                                : const Color(0xFF94A3B8),
                            onPressed: !isOutOfStock
                                ? () => _incrementQuantity(product.stock)
                                : null,
                            constraints: const BoxConstraints(
                              minWidth: 36,
                              minHeight: 36,
                            ),
                            padding: EdgeInsets.zero,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 100), // Spacing agar konten tidak tertutup bottom bar
            ],
          ),
        ),
      ),

      // =======================================================================
      // LANGKAH 3 BUTIR 2: Tombol 'Tambah ke Keranjang'
      // Mengembalikan nilai jumlah item ke HomePage menggunakan:
      // Navigator.pop(context, jumlah)
      // =======================================================================
      bottomNavigationBar: Container(
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
              // Ringkasan Subtotal Harga
              Expanded(
                flex: 4,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Total Harga:',
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFF64748B),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      isOutOfStock ? 'Rp 0' : formatRupiah(totalPrice),
                      style: const TextStyle(
                        fontSize: 16,
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

              // Tombol Tambah ke Keranjang
              Expanded(
                flex: 6,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.add_shopping_cart, size: 20),
                  label: Text(
                    isOutOfStock
                        ? 'Stok Habis'
                        : 'Tambah ke Keranjang ($_quantity)',
                    style: const TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isOutOfStock
                        ? const Color(0xFF94A3B8)
                        : const Color(0xFF1976D2),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: isOutOfStock ? 0 : 2,
                  ),
                  onPressed: isOutOfStock
                      ? null
                      : () {
                          // LANGKAH 3 BUTIR 2: Mengembalikan nilai jumlah item
                          Navigator.pop(context, _quantity);
                        },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
