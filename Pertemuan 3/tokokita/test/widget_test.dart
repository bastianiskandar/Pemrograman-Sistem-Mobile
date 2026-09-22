import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tokokita/main.dart';
import 'package:tokokita/models/product.dart';
import 'package:tokokita/widgets/category_tag.dart';
import 'package:tokokita/widgets/price_label.dart';
import 'package:tokokita/widgets/stock_badge.dart';

void main() {
  group('Pengujian Widget TokoKita (Pertemuan 3)', () {
    testWidgets('TokoKita UI Smoke Test & ProductCard Rendering', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();

      // Memastikan judul TokoKita tampil di AppBar
      expect(find.text('TokoKita'), findsOneWidget);

      // Memastikan produk pertama tampil
      expect(find.text('Laptop ASUS Vivo'), findsOneWidget);

      // Memastikan tombol favorit dapat ditekan dan mengubah state
      final firstFavoriteIcon = find.byIcon(Icons.favorite_border).first;
      expect(firstFavoriteIcon, findsWidgets);

      await tester.tap(firstFavoriteIcon);
      await tester.pump();

      // Setelah ditekan, harus ada ikon Icons.favorite (love merah)
      expect(find.byIcon(Icons.favorite), findsWidgets);
    });

    testWidgets('Pengujian Widget PriceLabel', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: PriceLabel(price: 150000),
          ),
        ),
      );

      expect(find.text('Rp 150.000'), findsOneWidget);
    });

    testWidgets('Pengujian Widget StockBadge', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                StockBadge(status: 'Tersedia'),
                StockBadge(status: 'Stok Terbatas'),
                StockBadge(status: 'Habis'),
              ],
            ),
          ),
        ),
      );

      expect(find.text('Tersedia'), findsOneWidget);
      expect(find.text('Stok Terbatas'), findsOneWidget);
      expect(find.text('Habis'), findsOneWidget);
    });

    testWidgets('Pengujian Widget CategoryTag', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CategoryTag(category: 'Elektronik'),
          ),
        ),
      );

      expect(find.text('Elektronik'), findsOneWidget);
      expect(find.byIcon(Icons.devices), findsOneWidget);
    });
  });

  group('Pengujian Model & Logika TokoKita (Pertemuan 2)', () {
    test('Format Rupiah Arrow Function', () {
      expect(formatRupiah(8500000), 'Rp 8.500.000');
      expect(formatRupiah(25000), 'Rp 25.000');
    });

    test('Hitung Diskon dengan Named Parameter', () {
      expect(hitungHargaSetelahDiskon(100000), 100000.0);
      expect(hitungHargaSetelahDiskon(100000, persenDiskon: 10), 90000.0);
    });

    test('Status Stok If-Else', () {
      final p1 = Product(
        id: 1,
        name: 'A',
        price: 1000,
        category: 'Elektronik',
        stock: 10,
      );
      final p2 = Product(
        id: 2,
        name: 'B',
        price: 1000,
        category: 'Fashion',
        stock: 3,
      );
      final p3 = Product(
        id: 3,
        name: 'C',
        price: 1000,
        category: 'Makanan',
        stock: 0,
      );

      expect(p1.getStatusStok(), 'Tersedia');
      expect(p2.getStatusStok(), 'Stok Terbatas');
      expect(p3.getStatusStok(), 'Habis');
    });

    test('DiscountedProduct Inheritance', () {
      final dp = DiscountedProduct(
        id: 1,
        name: 'Headphone',
        price: 100000,
        category: 'Elektronik',
        stock: 5,
        discountPercent: 20,
      );

      expect(dp.hitungHargaFinal(), 80000.0);
      expect(dp.formattedFinalPrice, 'Rp 80.000');
    });

    test('Hitung Total Belanja (Tugas Mandiri 3)', () {
      expect(dummyProducts.length, 8);
      final total = hitungTotalBelanja(dummyProducts);
      expect(total, greaterThan(0));
    });
  });
}
