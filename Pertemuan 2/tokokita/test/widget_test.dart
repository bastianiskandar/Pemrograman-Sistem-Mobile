import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tokokita/main.dart';
import 'package:tokokita/models/product.dart';

void main() {
  testWidgets('TokoKita UI Smoke Test', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    expect(find.text('TokoKita'), findsOneWidget);
    expect(find.byIcon(Icons.add), findsOneWidget);
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
      final p1 = Product(id: 1, name: 'A', price: 1000, category: 'Elektronik', stock: 10);
      final p2 = Product(id: 2, name: 'B', price: 1000, category: 'Fashion', stock: 3);
      final p3 = Product(id: 3, name: 'C', price: 1000, category: 'Makanan', stock: 0);

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
