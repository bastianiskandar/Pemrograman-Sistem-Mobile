import 'product.dart';

/// Model CartItem — Merepresentasikan item yang ada di dalam keranjang belanja TokoKita.
/// Menyimpan referensi objek [Product] dan jumlah kuantitas ([quantity]).
class CartItem {
  final Product product;
  int quantity;

  CartItem({
    required this.product,
    this.quantity = 1,
  });

  /// Mengambil harga satuan produk dengan mempertimbangkan diskon (jika ada).
  double get unitPrice {
    if (product is DiscountedProduct) {
      return (product as DiscountedProduct).hitungHargaFinal();
    }
    return product.price;
  }

  /// Menghitung subtotal harga untuk item ini (harga satuan x kuantitas).
  double get subtotal => unitPrice * quantity;
}
