// ignore_for_file: avoid_print

import 'package:flutter/material.dart';

import '../models/product.dart';
import 'category_tag.dart';
import 'price_label.dart';
import 'stock_badge.dart';

/// ProductCard — Komponen kartu produk untuk menampilkan informasi produk.
/// Menggabungkan Container, Row, Column, Stack, Positioned, Expanded, dan Flexible.
/// Mempertahankan fungsi Lifecycle (initState, build, dispose) dan Event logging dari Pertemuan 3.
class ProductCard extends StatefulWidget {
  final Product product;
  final VoidCallback? onDelete;
  final VoidCallback? onTap;

  const ProductCard({
    super.key,
    required this.product,
    this.onDelete,
    this.onTap,
  });

  @override
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
  // State lokal untuk menandai apakah produk ini dijadikan favorit
  bool isFavorite = false;

  // ==========================================================================
  // PENGAMATAN LIFECYCLE (DARI PERTEMUAN 3)
  // ==========================================================================
  @override
  void initState() {
    super.initState();
    // initState dipanggil satu kali saat widget pertama kali dibuat & dimasukkan ke widget tree
    print('[LIFECYCLE] initState() dipanggil untuk: ${widget.product.name}');
  }

  @override
  void dispose() {
    // dispose dipanggil saat widget dihapus secara permanen dari widget tree
    print('[LIFECYCLE] dispose() dipanggil untuk: ${widget.product.name}');
    super.dispose();
  }

  /// Helper untuk memilih ikon berdasarkan nama / kategori produk
  IconData _getProductIcon(Product p) {
    final name = p.name.toLowerCase();
    if (name.contains('laptop')) return Icons.laptop_mac;
    if (name.contains('smartphone')) return Icons.smartphone;
    if (name.contains('headphone')) return Icons.headphones;
    if (name.contains('sepatu')) return Icons.skateboarding;
    if (name.contains('jaket') || name.contains('kemeja') || name.contains('celana') || name.contains('kaos') || name.contains('topi')) {
      return Icons.checkroom;
    }
    if (name.contains('kopi') || name.contains('teh')) return Icons.coffee;
    if (name.contains('nasi') || name.contains('mie') || name.contains('roti') || name.contains('burger')) {
      return Icons.fastfood;
    }
    if (name.contains('keyboard') || name.contains('mouse') || name.contains('smartwatch') || name.contains('powerbank')) {
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

  /// Helper untuk warna aksen kategori bernuansa Biru dan harmonis
  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'elektronik':
        return const Color(0xFF1976D2); // Biru Utama
      case 'fashion':
        return const Color(0xFF0288D1); // Light Blue / Sky Blue
      case 'makanan':
        return const Color(0xFF00897B); // Teal Blue
      default:
        return const Color(0xFF1565C0);
    }
  }

  @override
  Widget build(BuildContext context) {
    // build dipanggil setiap kali widget perlu digambar ulang (misal setelah setState)
    print(
      '[LIFECYCLE] build() dipanggil untuk: ${widget.product.name} | isFavorite: $isFavorite',
    );

    final categoryColor = _getCategoryColor(widget.product.category);
    final isDiscounted = widget.product is DiscountedProduct;

    // =========================================================================
    // LANGKAH 2: Mempercantik ProductCard dengan Container
    // Menggunakan padding, margin antar kartu, warna latar putih, borderRadius,
    // border halus, dan BoxShadow agar terlihat seperti kartu modern terangkat.
    // =========================================================================
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 0.8),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF64748B).withAlpha(16),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
          BoxShadow(
            color: const Color(0xFF64748B).withAlpha(8),
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: widget.onTap,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
          // =====================================================================
          // LANGKAH 3 & TUGAS MANDIRI 2: Stack & Positioned untuk Gambar & Badge
          // 1. Gambar/placeholder dibungkus dengan Stack.
          // 2. Badge Diskon diletakkan di pojok kanan atas dengan Positioned (Langkah 3).
          // 3. Badge Status Stok diletakkan di posisi berbeda (pojok kiri bawah) dengan Positioned (Tugas Mandiri 2).
          // =====================================================================
          Stack(
            children: [
              // Gambar / Placeholder Ikon Produk
              Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFFE2E8F0),
                    width: 0.8,
                  ),
                ),
                child: Center(
                  child: Icon(
                    _getProductIcon(widget.product),
                    size: 38,
                    color: categoryColor,
                  ),
                ),
              ),

              // LANGKAH 3: Badge Diskon (Hanya muncul jika produk bertipe DiscountedProduct)
              if (isDiscounted)
                Positioned(
                  top: 5,
                  right: 5,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 5.5,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE53935),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'Diskon ${(widget.product as DiscountedProduct).discountPercent.toInt()}%',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 9.5,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.1,
                      ),
                    ),
                  ),
                ),

              // TUGAS MANDIRI 2: Badge Status Stok di posisi berbeda (pojok kiri bawah)
              Positioned(
                bottom: 5,
                left: 5,
                child: StockBadge(status: widget.product.getStatusStok()),
              ),
            ],
          ),

          const SizedBox(width: 12),

          // =====================================================================
          // LANGKAH 5 & TUGAS MANDIRI 3: Menata Ruang dengan Expanded & Flexible
          // Column dibungkus Expanded agar mengisi sisa ruang secara dinamis di
          // samping gambar tanpa menyebabkan overflow pada layar sempit.
          // Flexible digunakan pada teks harga di dalam Row agar menyesuaikan ruang.
          // =====================================================================
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Nama Produk
                Text(
                  widget.product.name,
                  style: const TextStyle(
                    fontSize: 15.5,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1E293B),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 3),

                // Deskripsi Produk (jika ada)
                if (widget.product.description != null &&
                    widget.product.description!.isNotEmpty)
                  Text(
                    widget.product.description!,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF64748B),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),

                const SizedBox(height: 6),

                // Tag Kategori
                CategoryTag(
                  category: widget.product.category,
                  customColor: categoryColor,
                ),

                const SizedBox(height: 6),

                // Tampilan Harga (Normal atau Harga Coret jika berdiskon)
                if (isDiscounted) ...[
                  Row(
                    children: [
                      // Harga awal yang dicoret (Flexible agar teks tidak overflow)
                      Flexible(
                        child: Text(
                          widget.product.formattedPrice,
                          style: const TextStyle(
                            fontSize: 11.5,
                            color: Color(0xFF94A3B8),
                            decoration: TextDecoration.lineThrough,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 6),
                      // Harga setelah diskon (Flexible agar teks menyesuaikan)
                      Flexible(
                        child: Text(
                          (widget.product as DiscountedProduct).formattedFinalPrice,
                          style: const TextStyle(
                            fontSize: 14.5,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1565C0), // Biru TokoKita
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ] else ...[
                  PriceLabel(price: widget.product.price),
                ],
              ],
            ),
          ),

          // Kolom Aksi: Tombol Favorit (Stateful) & Tombol Hapus (untuk tes dispose)
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(
                  minWidth: 36,
                  minHeight: 36,
                ),
                icon: Icon(
                  isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: isFavorite ? const Color(0xFFE53935) : const Color(0xFF94A3B8),
                  size: 22,
                ),
                tooltip: isFavorite ? 'Hapus dari favorit' : 'Tambah ke favorit',
                onPressed: () {
                  setState(() {
                    isFavorite = !isFavorite;
                  });
                  print(
                    '[EVENT] Tombol favorit ditekan! ${widget.product.name} -> isFavorite: $isFavorite',
                  );
                },
              ),
              if (widget.onDelete != null) ...[
                const SizedBox(height: 6),
                IconButton(
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(
                    minWidth: 36,
                    minHeight: 36,
                  ),
                  icon: const Icon(
                    Icons.delete_outline,
                    size: 20,
                    color: Color(0xFF94A3B8),
                  ),
                  tooltip: 'Hapus dari daftar (Uji dispose)',
                  onPressed: widget.onDelete,
                ),
              ],
            ],
          ),
        ],
      ),
    ),
  ),
),
);
  }
}
