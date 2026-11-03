import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tokokita/models/order.dart';
import 'package:tokokita/services/order_database.dart';
import 'package:tokokita/services/wishlist_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Pengujian Pertemuan 9 — Local Storage (SharedPreferences & SQLite)', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('Langkah 1: SharedPreferences — Simpan dan Muat Daftar ID Wishlist', () async {
      // Pastikan awal kosong
      var ids = await WishlistService.getWishlistIds();
      expect(ids, isEmpty);

      // Tambah produk ID 101 ke wishlist
      final isFav101 = await WishlistService.toggleFavorite(101);
      expect(isFav101, isTrue);

      ids = await WishlistService.getWishlistIds();
      expect(ids, contains('101'));
      expect(await WishlistService.isFavorite(101), isTrue);

      // Tambah produk ID 102
      await WishlistService.toggleFavorite(102);
      ids = await WishlistService.getWishlistIds();
      expect(ids.length, 2);
      expect(ids, contains('102'));

      // Hapus produk ID 101 dari wishlist (Langkah 2 Butir 2)
      await WishlistService.removeFromWishlist(101);
      ids = await WishlistService.getWishlistIds();
      expect(ids, isNot(contains('101')));
      expect(ids, contains('102'));
      expect(await WishlistService.isFavorite(101), isFalse);
    });

    test('Langkah 3 & 4: Model Order untuk SQLite — toMap, fromMap, dan copyWith', () {
      final order = Order(
        id: 1,
        tanggal: '03/11/2026 21:30',
        daftarItem: 'Mouse Wireless (x2), Keyboard Mechanical (x1)',
        totalHarga: 450000.0,
        status: 'Diproses',
      );

      final map = order.toMap();
      expect(map['id'], 1);
      expect(map['tanggal'], '03/11/2026 21:30');
      expect(map['daftarItem'], 'Mouse Wireless (x2), Keyboard Mechanical (x1)');
      expect(map['totalHarga'], 450000.0);
      expect(map['status'], 'Diproses');

      final orderFromMap = Order.fromMap(map);
      expect(orderFromMap.id, 1);
      expect(orderFromMap.tanggal, order.tanggal);
      expect(orderFromMap.daftarItem, order.daftarItem);
      expect(orderFromMap.totalHarga, order.totalHarga);
      expect(orderFromMap.status, 'Diproses');

      final updatedOrder = orderFromMap.copyWith(status: 'Selesai');
      expect(updatedOrder.status, 'Selesai');
      expect(updatedOrder.id, 1);
    });

    test('Langkah 4 & Tugas Mandiri 3: Operasi CRUD OrderDatabase & Pencarian WHERE', () async {
      // 1. Insert Order
      final order1 = Order(
        tanggal: '03/11/2026 22:00',
        daftarItem: 'Sepatu Running (x1)',
        totalHarga: 350000.0,
        status: 'Diproses',
      );
      final id1 = await OrderDatabase.instance.insertOrder(order1);
      expect(id1, greaterThan(0));

      final order2 = Order(
        tanggal: '03/11/2026 22:30',
        daftarItem: 'Kemeja Flannel (x2)',
        totalHarga: 200000.0,
        status: 'Selesai',
      );
      final id2 = await OrderDatabase.instance.insertOrder(order2);
      expect(id2, greaterThan(id1));

      // 2. Read All
      final orders = await OrderDatabase.instance.getAllOrders();
      expect(orders.length, 2);

      // 3. Search / Filter WHERE status = 'Diproses'
      final diproses = await OrderDatabase.instance.searchOrders(status: 'Diproses');
      expect(diproses.length, 1);
      expect(diproses.first.daftarItem, contains('Sepatu Running'));

      // 4. Search / Filter WHERE keyword LIKE '%Flannel%'
      final searchFlannel = await OrderDatabase.instance.searchOrders(keyword: 'Flannel');
      expect(searchFlannel.length, 1);
      expect(searchFlannel.first.status, 'Selesai');

      // 5. Update Status
      final updateResult = await OrderDatabase.instance.updateOrderStatus(id1, 'Selesai');
      expect(updateResult, greaterThan(0));
      final updatedOrders = await OrderDatabase.instance.searchOrders(status: 'Selesai');
      expect(updatedOrders.length, 2);

      // 6. Delete Order
      final deleteResult = await OrderDatabase.instance.deleteOrder(id1);
      expect(deleteResult, greaterThan(0));
      final remaining = await OrderDatabase.instance.getAllOrders();
      expect(remaining.length, 1);
      expect(remaining.first.id, id2);
    });
  });
}

