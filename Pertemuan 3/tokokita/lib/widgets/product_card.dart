// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import '../models/product.dart';
import 'category_tag.dart';
import 'price_label.dart';
import 'stock_badge.dart';

/// Widget ProductCard bertipe StatefulWidget.
/// Memiliki state lokal `isFavorite` serta implementasi lifecycle (initState, build, dispose).
class ProductCard extends StatefulWidget {
  final Product product;
  final VoidCallback? onDelete;

  const ProductCard({
    super.key,
    required this.product,
    this.onDelete,
  });

  @override
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
  // State lokal untuk menandai apakah produk ini dijadikan favorit
  bool isFavorite = false;

  // ==========================================================================
  // PENGAMATAN LIFECYCLE (LANGKAH 2)
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

  /// Mendapatkan ikon yang sesuai dengan jenis produk
  IconData _getProductIcon(Product p) {
    final name = p.name.toLowerCase();
    if (name.contains('laptop')) return Icons.laptop_mac;
    if (name.contains('smartphone')) return Icons.smartphone;
    if (name.contains('headphone')) return Icons.headphones;
    if (name.contains('sepatu')) return Icons.skateboarding;
    if (name.contains('jaket')) return Icons.style;
    if (name.contains('kaos')) return Icons.checkroom;
    if (name.contains('kopi')) return Icons.coffee;
    if (name.contains('nasi')) return Icons.restaurant;

    switch (p.category.toLowerCase()) {
      case 'elektronik':
        return Icons.devices;
      case 'fashion':
        return Icons.shopping_bag;
      case 'makanan':
        return Icons.fastfood;
      default:
        return Icons.inventory_2;
    }
  }

  /// Mendapatkan warna tema berdasarkan kategori dari product.dart
  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'elektronik':
        return Colors.indigo;
      case 'fashion':
        return Colors.pink;
      case 'makanan':
        return Colors.teal;
      default:
        return Colors.deepPurple;
    }
  }

  @override
  Widget build(BuildContext context) {
    // build dipanggil setiap kali widget perlu digambar ulang (misal setelah setState)
    print(
      '[LIFECYCLE] build() dipanggil untuk: ${widget.product.name} | isFavorite: $isFavorite',
    );

    final categoryColor = _getCategoryColor(widget.product.category);
    final diskonKategori = hitungDiskonKategori(widget.product.category);

    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Placeholder ikon / gambar produk yang sinkron dengan nama & kategori
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                color: categoryColor.withAlpha(25),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: categoryColor.withAlpha(80)),
              ),
              child: Icon(
                _getProductIcon(widget.product),
                size: 36,
                color: categoryColor,
              ),
            ),
            const SizedBox(width: 12),

            // Informasi produk dari product.dart: Nama, Kategori, Deskripsi, Harga, Stok
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Nama Produk
                  Text(
                    widget.product.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  // Deskripsi Produk (dari field description di product.dart)
                  if (widget.product.description != null &&
                      widget.product.description!.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      widget.product.description!,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  const SizedBox(height: 6),

                  // Baris Tag Kategori & Diskon Kategori (dari product.dart)
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: [
                      CategoryTag(
                        category: widget.product.category,
                        customColor: categoryColor,
                      ),
                      if (diskonKategori > 0)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.orange.withAlpha(35),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: Colors.orange, width: 0.8),
                          ),
                          child: Text(
                            'Diskon ${diskonKategori.toInt()}%',
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: Colors.deepOrange,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Baris: Label Harga & Status Stok (menggunakan getStatusStok() dan stock)
                  Row(
                    children: [
                      PriceLabel(price: widget.product.price),
                      const Spacer(),
                      Text(
                        'Stok: ${widget.product.stock}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade700,
                        ),
                      ),
                      const SizedBox(width: 6),
                      StockBadge(status: widget.product.getStatusStok()),
                    ],
                  ),
                ],
              ),
            ),

            // Kolom Aksi: Tombol Favorit (Stateful) & Tombol Hapus (untuk tes dispose)
            Column(
              children: [
                // Tombol Favorit (Langkah 2: setState)
                IconButton(
                  icon: Icon(
                    isFavorite ? Icons.favorite : Icons.favorite_border,
                    color: isFavorite ? Colors.red : Colors.grey,
                  ),
                  tooltip: isFavorite ? 'Hapus Favorit' : 'Tambah Favorit',
                  onPressed: () {
                    setState(() {
                      isFavorite = !isFavorite;
                    });
                    print(
                      '[EVENT] Tombol favorit ditekan! ${widget.product.name} -> isFavorite: $isFavorite',
                    );
                  },
                ),

                // Tombol Hapus opsional (mempermudah observasi pemanggilan dispose())
                if (widget.onDelete != null)
                  IconButton(
                    icon: const Icon(
                      Icons.delete_outline,
                      size: 20,
                      color: Colors.grey,
                    ),
                    tooltip: 'Hapus dari daftar (Uji dispose)',
                    onPressed: widget.onDelete,
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
