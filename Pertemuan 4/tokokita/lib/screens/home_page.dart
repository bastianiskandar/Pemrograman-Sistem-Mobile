import 'package:flutter/material.dart';

import '../models/product.dart';
import '../widgets/product_card.dart';

/// HomePage — Halaman utama aplikasi TokoKita.
/// Menggabungkan Row, Column, Container, Stack, ListView.builder, dan Expanded.
/// Mempertahankan pengujian lifecycle dispose() dengan aksi hapus produk.
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Salinan daftar produk dari data dummy di product.dart (minimal 15, tersedia 20)
  late List<Product> _productList;

  // Kategori yang sedang dipilih untuk filter ('Semua' = tampilkan semua)
  String _selectedCategory = 'Semua';

  @override
  void initState() {
    super.initState();
    _productList = List<Product>.from(dummyProducts);
  }

  void _removeProduct(int productId) {
    setState(() {
      _productList.removeWhere((p) => p.id == productId);
    });
  }

  void _resetProducts() {
    setState(() {
      _productList = List<Product>.from(dummyProducts);
    });
  }

  // Daftar produk yang sudah difilter berdasarkan kategori terpilih
  List<Product> get _filteredProducts {
    if (_selectedCategory == 'Semua') return _productList;
    return _productList.where((p) => p.category == _selectedCategory).toList();
  }

  // Ikon untuk setiap kategori
  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Semua':
        return Icons.home_rounded;
      case 'Elektronik':
        return Icons.laptop_mac;
      case 'Fashion':
        return Icons.checkroom;
      case 'Makanan':
        return Icons.restaurant;
      default:
        return Icons.category;
    }
  }

  // Warna untuk setiap kategori
  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Semua':
        return const Color(0xFF7C4DFF); // Ungu
      case 'Elektronik':
        return const Color(0xFF1976D2); // Biru
      case 'Fashion':
        return const Color(0xFFE91E63); // Pink
      case 'Makanan':
        return const Color(0xFFFF5722); // Oranye
      default:
        return const Color(0xFF7C4DFF);
    }
  }

  @override
  Widget build(BuildContext context) {
    final categories = ['Semua', ...kategoriList];
    final filtered = _filteredProducts;

    return Scaffold(
      backgroundColor: const Color(0xFFF3E5F5), // Lavender background
      body: SafeArea(
        child: Column(
          children: [
            // =================================================================
            // LANGKAH 1: Header Halaman Menggunakan Row & Column
            // 1. Row dengan mainAxisAlignment.spaceBetween untuk memisahkan
            //    nama toko di sisi kiri dan ikon keranjang di sisi kanan.
            // 2. Column dengan crossAxisAlignment.start untuk menyusun judul
            //    dan subjudul toko secara vertikal dan rata kiri.
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
                  // Judul dan subjudul menggunakan Column
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        namaToko,
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF1565C0),
                          letterSpacing: -0.3,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Belanja jadi lebih mudah',
                        style: TextStyle(
                          fontSize: 12.5,
                          color: Color(0xFF64748B),
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),

                  // Aksi Header: Reset (jika ada produk yang dihapus) & Ikon Keranjang Belanja
                  Row(
                    children: [
                      if (_productList.length < dummyProducts.length)
                        IconButton(
                          icon: const Icon(Icons.refresh, color: Color(0xFF1976D2)),
                          tooltip: 'Reset Produk',
                          onPressed: _resetProducts,
                        ),
                      IconButton(
                        icon: const Icon(
                          Icons.shopping_cart_outlined,
                          color: Color(0xFF1976D2),
                          size: 26,
                        ),
                        tooltip: 'Keranjang Belanja',
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Keranjang belanja ditekan'),
                              duration: Duration(seconds: 1),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // =================================================================
            // LANGKAH 2: Filter Kategori Produk — Row of Chips
            // Menggunakan Row di dalam SingleChildScrollView horizontal
            // agar chip dapat di-scroll jika kategori banyak.
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
                          color: Colors.grey.shade600,
                        ),
                      ),
                      Text(
                        'Pilih untuk memFilter',
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
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),

            // =================================================================
            // LANGKAH 3: Header Kategori Aktif — menampilkan nama kategori
            // dan jumlah item yang tampil.
            // =================================================================
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Kategori: $_selectedCategory',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF37474F),
                    ),
                  ),
                  Text(
                    '${filtered.length} item',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            ),

            // =================================================================
            // LANGKAH 4: Menampilkan Daftar Produk dengan ListView.builder
            // Menggunakan Expanded agar ListView.builder dapat mengisi sisa ruang
            // vertikal layar dan memanfaatkan lazy-loading untuk efisiensi memori.
            // =================================================================
            Expanded(
              child: filtered.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.inbox_rounded, size: 56, color: Colors.grey.shade400),
                          const SizedBox(height: 8),
                          Text(
                            'Tidak ada produk di kategori ini',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade500,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      itemCount: filtered.length,
                      itemBuilder: (context, index) {
                        final product = filtered[index];
                        // Me-render satu ProductCard untuk setiap item pada List
                        return ProductCard(
                          key: ValueKey(product.id),
                          product: product,
                          onDelete: () => _removeProduct(product.id),
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
