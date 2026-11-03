import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../models/cart_item.dart';
import '../models/product.dart';

/// CartController — Mengelola state keranjang belanja TokoKita secara reaktif menggunakan GetX.
/// Memisahkan business logic dari antarmuka tampilan (UI).
class CartController extends GetxController {
  // ===========================================================================
  // LANGKAH 2 BUTIR 1: Variabel reaktif RxList untuk menyimpan item keranjang
  // ===========================================================================
  final RxList<CartItem> items = <CartItem>[].obs;

  // ===========================================================================
  // LANGKAH 2 BUTIR 3: Getter reaktif untuk menghitung totalItem dan totalHarga
  // ===========================================================================

  /// Menghitung total jumlah barang (akumulasi kuantitas seluruh item) di keranjang.
  int get totalItem => items.fold(0, (sum, item) => sum + item.quantity);

  /// Menghitung total nominal harga seluruh item belanjaan di keranjang.
  double get totalHarga => items.fold(0.0, (sum, item) => sum + item.subtotal);

  /// Mengetahui apakah keranjang dalam keadaan kosong.
  bool get isEmpty => items.isEmpty;

  /// Daftar produk murni untuk kemudahan integrasi jika diperlukan.
  List<Product> get products => items.map((item) => item.product).toList();

  // ===========================================================================
  // LANGKAH 2 BUTIR 2: Method addToCart & removeFromCart
  // ===========================================================================

  /// Menambahkan produk ke dalam keranjang.
  /// Jika produk sudah ada, kuantitasnya akan ditambahkan.
  void addToCart(Product product, [int quantity = 1]) {
    final existingIndex = items.indexWhere((item) => item.product.id == product.id);

    if (existingIndex >= 0) {
      final existingItem = items[existingIndex];
      final newQuantity = existingItem.quantity + quantity;

      // Cek batas stok produk
      if (newQuantity <= product.stock) {
        existingItem.quantity = newQuantity;
        items.refresh();
      } else {
        existingItem.quantity = product.stock;
        items.refresh();
        Get.snackbar(
          'Pemberitahuan Stok',
          'Jumlah item telah disesuaikan dengan batas stok maksimal (${product.stock}).',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFFF59E0B),
          colorText: Colors.white,
          margin: const EdgeInsets.all(12),
          borderRadius: 8,
          duration: const Duration(seconds: 2),
        );
      }
    } else {
      final addQty = quantity > product.stock ? product.stock : quantity;
      items.add(CartItem(product: product, quantity: addQty));
    }
  }

  /// Menghapus produk dari keranjang belanja secara penuh.
  void removeFromCart(Product product) {
    items.removeWhere((item) => item.product.id == product.id);
  }

  // ===========================================================================
  // TUGAS MANDIRI 1: Fitur ubah jumlah (quantity) per item
  // ===========================================================================

  /// Menambah kuantitas produk sebanyak 1 unit.
  void increaseQuantity(Product product) {
    final existingIndex = items.indexWhere((item) => item.product.id == product.id);
    if (existingIndex >= 0) {
      final item = items[existingIndex];
      if (item.quantity < product.stock) {
        item.quantity++;
        items.refresh();
      } else {
        Get.snackbar(
          'Stok Terbatas',
          'Kuantitas maksimal produk "${product.name}" adalah ${product.stock} unit.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFFEF4444),
          colorText: Colors.white,
          margin: const EdgeInsets.all(12),
          borderRadius: 8,
          duration: const Duration(seconds: 2),
        );
      }
    }
  }

  /// Mengurangi kuantitas produk sebanyak 1 unit.
  /// Jika kuantitas tersisa 1 dan dikurangi, produk akan dihapus dari keranjang.
  void decreaseQuantity(Product product) {
    final existingIndex = items.indexWhere((item) => item.product.id == product.id);
    if (existingIndex >= 0) {
      final item = items[existingIndex];
      if (item.quantity > 1) {
        item.quantity--;
        items.refresh();
      } else {
        removeFromCart(product);
      }
    }
  }

  // ===========================================================================
  // TUGAS MANDIRI 2: Fitur kosongkan keranjang beserta dialog konfirmasi
  // ===========================================================================

  /// Mengosongkan seluruh item dari keranjang.
  void clearCart() {
    items.clear();
  }

  /// Menampilkan dialog konfirmasi sebelum benar-benar mengosongkan keranjang.
  void confirmClearCart(BuildContext context) {
    if (items.isEmpty) return;

    Get.defaultDialog(
      title: 'Kosongkan Keranjang?',
      titleStyle: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: Color(0xFF1E293B),
      ),
      middleText: 'Apakah Anda yakin ingin menghapus semua barang dari keranjang belanja?',
      middleTextStyle: const TextStyle(
        fontSize: 14,
        color: Color(0xFF64748B),
      ),
      textConfirm: 'Ya, Kosongkan',
      textCancel: 'Batal',
      confirmTextColor: Colors.white,
      buttonColor: const Color(0xFFDC2626),
      cancelTextColor: const Color(0xFF64748B),
      radius: 12,
      onConfirm: () {
        clearCart();
        Get.back(); // Tutup dialog
        Get.snackbar(
          'Keranjang Dikosongkan',
          'Semua item berhasil dihapus dari keranjang belanja.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFF1976D2),
          colorText: Colors.white,
          margin: const EdgeInsets.all(12),
          borderRadius: 8,
          duration: const Duration(seconds: 2),
        );
      },
    );
  }
}
