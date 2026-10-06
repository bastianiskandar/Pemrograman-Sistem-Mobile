import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tokokita/main.dart';
import 'package:tokokita/models/product.dart';
import 'package:tokokita/screens/cart_page.dart';
import 'package:tokokita/screens/home_page.dart';
import 'package:tokokita/screens/main_page.dart';
import 'package:tokokita/screens/profile_page.dart';
import 'package:tokokita/screens/product_detail_page.dart';
import 'package:tokokita/widgets/category_tag.dart';
import 'package:tokokita/widgets/price_label.dart';
import 'package:tokokita/widgets/product_card.dart';
import 'package:tokokita/widgets/stock_badge.dart';

void main() {
  group('Pengujian TokoKita Pertemuan 5 (Navigasi, Routing, & Bottom Navigation)', () {
    testWidgets('Langkah 5: Kerangka Bottom Navigation & Pergantian Tab', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();

      // Memastikan MainPage & HomePage aktif sebagai rute awal '/'
      expect(find.byType(MainPage), findsOneWidget);
      expect(find.byType(HomePage), findsOneWidget);
      expect(find.byType(BottomNavigationBar), findsOneWidget);

      // Memastikan 3 menu pada BottomNavigationBar ada
      expect(find.text('Beranda'), findsOneWidget);
      expect(find.text('Keranjang'), findsOneWidget);
      expect(find.text('Profil'), findsOneWidget);

      // Berpindah ke tab Keranjang
      await tester.tap(find.text('Keranjang'));
      await tester.pumpAndSettle();
      expect(find.byType(CartPage), findsOneWidget);
      expect(find.text('Keranjang Belanja Masih Kosong'), findsOneWidget);

      // Berpindah ke tab Profil
      await tester.tap(find.text('Profil'));
      await tester.pumpAndSettle();
      expect(find.byType(ProfilePage), findsOneWidget);
      expect(find.text('Profil Saya'), findsOneWidget);
      expect(find.text('Mahasiswa Pemrograman Mobile'), findsOneWidget);

      // Kembali ke tab Beranda
      await tester.tap(find.text('Beranda'));
      await tester.pumpAndSettle();
      expect(find.byType(HomePage), findsOneWidget);

      // Menguji tombol keranjang di header atas HomePage (berpindah ke tab Keranjang)
      final headerCartBtn = find.byTooltip('Keranjang Belanja');
      expect(headerCartBtn, findsOneWidget);
      await tester.tap(headerCartBtn);
      await tester.pumpAndSettle();
      expect(find.byType(CartPage), findsOneWidget);

      // Kembali ke tab Beranda via tombol aksi 'Jelajahi Produk Sekarang'
      final browseBtn = find.text('Jelajahi Produk Sekarang');
      expect(browseBtn, findsOneWidget);
      await tester.tap(browseBtn);
      await tester.pumpAndSettle();
      expect(find.byType(HomePage), findsOneWidget);
    });

    testWidgets('Langkah 1, 2, 3 & Tugas Mandiri 1: Navigasi Detail, Counter, & Nilai Balik', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();

      // Memastikan daftar ProductCard muncul
      expect(find.byType(ProductCard), findsWidgets);
      final firstCard = find.byType(ProductCard).first;

      // Klik kartu produk pertama untuk navigasi ke ProductDetailPage via named route '/detail'
      await tester.tap(firstCard);
      await tester.pumpAndSettle();

      // Verifikasi bahwa ProductDetailPage tampil
      expect(find.byType(ProductDetailPage), findsOneWidget);
      expect(find.text('Detail Produk'), findsOneWidget);
      expect(find.text('Deskripsi Produk'), findsOneWidget);

      // Verifikasi fitur counter kuantitas (Tugas Mandiri 1)
      expect(find.text('Atur Jumlah'), findsOneWidget);
      expect(find.text('1'), findsWidgets); // Nilai awal quantity

      // Tambah jumlah dengan tombol '+'
      await tester.ensureVisible(find.byIcon(Icons.add));
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();
      expect(find.text('2'), findsWidgets);

      // Tekan tombol 'Tambah ke Keranjang (2)' (Langkah 3 Butir 2)
      final addToCartBtn = find.textContaining('Tambah ke Keranjang');
      expect(addToCartBtn, findsOneWidget);
      await tester.tap(addToCartBtn);
      await tester.pumpAndSettle();

      // Verifikasi kembali ke HomePage
      expect(find.byType(HomePage), findsOneWidget);

      // Verifikasi SnackBar notifikasi muncul (Langkah 3 Butir 3)
      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.textContaining('Berhasil menambahkan 2 item'), findsOneWidget);
    });

    testWidgets('Langkah 1 Butir 4: Tombol Back pada ProductDetailPage', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();

      // Buka detail produk
      await tester.tap(find.byType(ProductCard).first);
      await tester.pumpAndSettle();
      expect(find.byType(ProductDetailPage), findsOneWidget);

      // Tekan tombol back di AppBar
      final backButton = find.byTooltip('Kembali');
      expect(backButton, findsOneWidget);
      await tester.tap(backButton);
      await tester.pumpAndSettle();

      // Verifikasi kembali ke HomePage tanpa SnackBar
      expect(find.byType(HomePage), findsOneWidget);
      expect(find.byType(SnackBar), findsNothing);
    });

    testWidgets('Pengujian Helper Widgets (PriceLabel, StockBadge, CategoryTag)', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                PriceLabel(price: 150000),
                StockBadge(status: 'Tersedia'),
                StockBadge(status: 'Stok Terbatas'),
                StockBadge(status: 'Habis'),
                CategoryTag(category: 'Elektronik'),
              ],
            ),
          ),
        ),
      );

      expect(find.text('Rp 150.000'), findsOneWidget);
      expect(find.text('Tersedia'), findsOneWidget);
      expect(find.text('Stok Terbatas'), findsOneWidget);
      expect(find.text('Habis'), findsOneWidget);
      expect(find.text('Elektronik'), findsOneWidget);
    });
  });

  group('Pengujian Model & Data Dummy TokoKita', () {
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

    test('Data Dummy Minimal 15 Produk', () {
      expect(dummyProducts.length, greaterThanOrEqualTo(15));
      final total = hitungTotalBelanja(dummyProducts);
      expect(total, greaterThan(0));
    });
  });
}
