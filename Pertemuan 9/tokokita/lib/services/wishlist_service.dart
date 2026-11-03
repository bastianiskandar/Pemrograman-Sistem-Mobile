import 'package:shared_preferences/shared_preferences.dart';

/// WishlistService — Helper untuk mengelola data wishlist di Local Storage
/// menggunakan SharedPreferences (Langkah 1).
class WishlistService {
  static const String keyWishlist = 'wishlist_ids';

  /// Mengambil daftar ID produk favorit dari SharedPreferences (Langkah 1 Butir 3)
  static Future<List<String>> getWishlistIds() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(keyWishlist) ?? <String>[];
  }

  /// Memeriksa apakah suatu ID produk ada di dalam daftar favorit
  static Future<bool> isFavorite(int productId) async {
    final ids = await getWishlistIds();
    return ids.contains(productId.toString());
  }

  /// Menambahkan atau menghapus produk dari daftar favorit (toggle)
  /// menggunakan SharedPreferences.setStringList (Langkah 1 Butir 2)
  static Future<bool> toggleFavorite(int productId) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> ids = List<String>.from(prefs.getStringList(keyWishlist) ?? <String>[]);
    final idStr = productId.toString();

    final bool isFav;
    if (ids.contains(idStr)) {
      ids.remove(idStr);
      isFav = false;
    } else {
      ids.add(idStr);
      isFav = true;
    }

    await prefs.setStringList(keyWishlist, ids);
    return isFav;
  }

  /// Menghapus ID produk tertentu dari wishlist (Langkah 2 Butir 2)
  static Future<void> removeFromWishlist(int productId) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> ids = List<String>.from(prefs.getStringList(keyWishlist) ?? <String>[]);
    final idStr = productId.toString();

    if (ids.contains(idStr)) {
      ids.remove(idStr);
      await prefs.setStringList(keyWishlist, ids);
    }
  }
}

