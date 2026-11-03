import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:tokokita/controllers/cart_controller.dart';
import 'package:tokokita/main.dart';
import 'package:tokokita/models/product.dart';
import 'package:tokokita/screens/cart_page.dart';
import 'package:tokokita/screens/checkout_page.dart';
import 'package:tokokita/screens/home_page.dart';
import 'package:tokokita/screens/main_page.dart';
import 'package:tokokita/screens/product_detail_page.dart';
import 'package:tokokita/services/product_service.dart';
import 'package:tokokita/widgets/product_card.dart';

/// MockHttpClient untuk pengujian unit networking deterministik tanpa ketergantungan internet
class MockHttpClient extends http.BaseClient {
  final http.Response Function(http.Request request) handler;
  MockHttpClient(this.handler);

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    final response = handler(request as http.Request);
    return http.StreamedResponse(
      Stream.value(response.bodyBytes),
      response.statusCode,
      headers: response.headers,
    );
  }
}

void main() {
  setUp(() {
    Get.reset();
    Get.put(CartController());
    ProductService.mockProducts = List<Product>.from(dummyProducts);
  });

  tearDown(() {
    ProductService.mockProducts = null;
  });

  // ===========================================================================
  // MODUL PENGUJIAN PERTEMUAN 7 (HTTP NETWORKING & KONSUMSI REST API)
  // ===========================================================================
  group('Pengujian TokoKita Pertemuan 7 (HTTP Networking & REST API)', () {
    test('Langkah 3: Parsing JSON Fake Store API ke Model Product via fromJson & toJson', () {
      final fakeStoreJson = {
        'id': 1,
        'title': 'Fjallraven - Foldsack No. 1 Backpack',
        'price': 109.95,
        'description': 'Your perfect pack for everyday use',
        'category': "men's clothing",
        'image': 'https://fakestoreapi.com/img/81fPKd-2AYL._AC_SL1500_t.png',
        'rating': {'rate': 3.9, 'count': 120},
      };

      final product = Product.fromJson(fakeStoreJson);

      // Verifikasi pemetaan field
      expect(product.id, 1);
      expect(product.name, 'Fjallraven - Foldsack No. 1 Backpack');
      // Konversi dollar ke rupiah (109.95 * 15000 = 1649250)
      expect(product.price, 1649250.0);
      // Normalisasi kategori "men's clothing" -> "Fashion"
      expect(product.category, 'Fashion');
      // Stock diambil dari rating count
      expect(product.stock, 120);
      expect(product.imageUrl, 'https://fakestoreapi.com/img/81fPKd-2AYL._AC_SL1500_t.png');
      expect(product.description, 'Your perfect pack for everyday use');
      expect(product.getStatusStok(), 'Tersedia');

      // Uji serialisasi toJson
      final jsonOutput = product.toJson();
      expect(jsonOutput['id'], 1);
      expect(jsonOutput['title'], 'Fjallraven - Foldsack No. 1 Backpack');
      expect(jsonOutput['category'], 'Fashion');
    });

    test('Langkah 2: ProductService.fetchProducts() GET Request & Parsing', () async {
      ProductService.mockProducts = null;

      final mockClient = MockHttpClient((request) {
        expect(request.url.path, '/products');
        return http.Response(
          jsonEncode([
            {
              'id': 1,
              'title': 'Fjallraven Backpack',
              'price': 109.95,
              'description': 'Tas ransel laptop',
              'category': "men's clothing",
              'image': 'https://fakestoreapi.com/img/1.jpg',
              'rating': {'rate': 4.5, 'count': 50},
            },
            {
              'id': 2,
              'title': 'Mens Casual Slim Fit',
              'price': 22.3,
              'description': 'Kemeja pria kasual',
              'category': "men's clothing",
              'image': 'https://fakestoreapi.com/img/2.jpg',
              'rating': {'rate': 4.1, 'count': 25},
            },
          ]),
          200,
          headers: {'content-type': 'application/json; charset=utf-8'},
        );
      });

      final products = await ProductService.fetchProducts(httpClient: mockClient);

      expect(products, isNotEmpty);
      expect(products.length, 2);
      expect(products.first.id, 1);
      expect(products.first.name, 'Fjallraven Backpack');
      expect(products.first.category, 'Fashion');
    });

    test('Tugas Mandiri 1: ProductService.fetchProductDetail(id) GET Request', () async {
      ProductService.mockProducts = null;

      final mockClient = MockHttpClient((request) {
        expect(request.url.path, '/products/1');
        return http.Response(
          jsonEncode({
            'id': 1,
            'title': 'Fjallraven Backpack',
            'price': 109.95,
            'description': 'Tas ransel laptop',
            'category': "men's clothing",
            'image': 'https://fakestoreapi.com/img/1.jpg',
            'rating': {'rate': 4.5, 'count': 50},
          }),
          200,
          headers: {'content-type': 'application/json; charset=utf-8'},
        );
      });

      final product = await ProductService.fetchProductDetail(1, httpClient: mockClient);

      expect(product.id, 1);
      expect(product.name, 'Fjallraven Backpack');
      expect(product.category, 'Fashion');
      expect(product.imageUrl, 'https://fakestoreapi.com/img/1.jpg');
    });

    test('Langkah 5 & Tugas Mandiri 5: Pengecekan Status Code != 200 & Exception', () async {
      ProductService.mockProducts = null;

      final mockErrorClient = MockHttpClient((request) {
        return http.Response('Internal Server Error', 500);
      });

      expect(
        () async => await ProductService.fetchProducts(httpClient: mockErrorClient),
        throwsA(isA<Exception>()),
      );
    });

    testWidgets('Langkah 4: FutureBuilder di HomePage Menampilkan Loading & Kartu Produk', (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();

      expect(find.byType(HomePage), findsOneWidget);
      expect(find.byType(FutureBuilder<List<Product>>), findsOneWidget);
      expect(find.byType(ProductCard), findsWidgets);
      expect(find.text('REST API'), findsOneWidget);
    });

    testWidgets('Langkah 5: Tampilan Error Ramah Pengguna & Tombol Coba Lagi di HomePage', (WidgetTester tester) async {
      // Siapkan mock client yang mengembalikan error saat diminta simulateError
      ProductService.mockProducts = null;
      final mockClient = MockHttpClient((request) {
        if (request.url.path.contains('error')) {
          return http.Response('Not Found', 404);
        }
        return http.Response(
          jsonEncode([
            {
              'id': 1,
              'title': 'Produk Sukses',
              'price': 100.0,
              'description': 'Deskripsi',
              'category': 'Elektronik',
              'image': null,
              'rating': {'rate': 5.0, 'count': 10},
            }
          ]),
          200,
        );
      });
      ProductService.client = mockClient;

      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();

      // Klik tombol bug/simulasi error di header
      final errorSimBtn = find.byTooltip('Simulasikan Error REST API (Langkah 5)');
      expect(errorSimBtn, findsOneWidget);
      await tester.tap(errorSimBtn);
      await tester.pump();
      // Konsumsi exception yang sengaja dimunculkan untuk simulasi error
      tester.takeException();
      await tester.pumpAndSettle();

      // Memastikan pesan error ramah pengguna muncul
      expect(find.text('Gagal Memuat Produk'), findsOneWidget);
      final cobaLagiBtn = find.text('Coba Lagi');
      expect(cobaLagiBtn, findsOneWidget);

      // Klik tombol 'Coba Lagi' (Langkah 5 Butir 3)
      await tester.tap(cobaLagiBtn);
      await tester.pumpAndSettle();

      // Aplikasi kembali menampilkan produk dengan normal
      expect(find.byType(ProductCard), findsWidgets);

      // Reset client
      ProductService.client = http.Client();
    });

    testWidgets('Tugas Mandiri 1: Navigasi ke ProductDetailPage dengan productId Saja', (WidgetTester tester) async {
      await tester.pumpWidget(
        GetMaterialApp(
          home: const ProductDetailPage(productId: 1),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(ProductDetailPage), findsOneWidget);
      expect(find.text('Detail Produk'), findsOneWidget);
      expect(find.byIcon(Icons.sync_rounded), findsOneWidget); // Tombol refresh API
    });

    testWidgets('Tugas Mandiri 2: Verifikasi Widget RefreshIndicator pada HomePage', (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();

      expect(find.byType(RefreshIndicator), findsOneWidget);
    });
  });

  // ===========================================================================
  // MODUL PENGUJIAN PERTEMUAN 6 (STATE MANAGEMENT DENGAN GETX)
  // ===========================================================================
  group('Pengujian TokoKita Pertemuan 6 (State Management dengan GetX)', () {
    test('Langkah 2: CartController Unit Test (addToCart, removeFromCart, totalItem, totalHarga)', () {
      final controller = CartController();
      final product1 = Product(
        id: 1,
        name: 'Mouse',
        price: 100000,
        category: 'Elektronik',
        stock: 10,
      );
      final product2 = Product(
        id: 2,
        name: 'Baju',
        price: 50000,
        category: 'Fashion',
        stock: 5,
      );

      expect(controller.totalItem, 0);
      expect(controller.totalHarga, 0.0);
      expect(controller.isEmpty, true);

      // Tambah item 1
      controller.addToCart(product1, 2);
      expect(controller.totalItem, 2);
      expect(controller.totalHarga, 200000.0);
      expect(controller.items.length, 1);

      // Tambah item 2
      controller.addToCart(product2, 1);
      expect(controller.totalItem, 3);
      expect(controller.totalHarga, 250000.0);
      expect(controller.items.length, 2);

      // Ubah kuantitas (Tugas Mandiri 1)
      controller.increaseQuantity(product2);
      expect(controller.totalItem, 4);
      expect(controller.totalHarga, 300000.0);

      controller.decreaseQuantity(product1);
      expect(controller.totalItem, 3);
      expect(controller.totalHarga, 200000.0);

      // Hapus item (Langkah 5 Butir 2)
      controller.removeFromCart(product1);
      expect(controller.items.length, 1);
      expect(controller.totalItem, 2);
      expect(controller.totalHarga, 100000.0);

      // Kosongkan keranjang (Tugas Mandiri 2)
      controller.clearCart();
      expect(controller.items.isEmpty, true);
      expect(controller.totalItem, 0);
      expect(controller.totalHarga, 0.0);
    });

    testWidgets(
      'Langkah 1 & 2: GetMaterialApp, CartController Get.put & Get.find',
      (WidgetTester tester) async {
        await tester.pumpWidget(const MyApp());
        await tester.pumpAndSettle();

        expect(find.byType(GetMaterialApp), findsOneWidget);
        expect(find.byType(MainPage), findsOneWidget);

        final controller = Get.find<CartController>();
        expect(controller, isNotNull);
        expect(controller.totalItem, 0);
      },
    );

    testWidgets(
      'Langkah 3 & 4: Obx Badge Reaktif, Navigasi Get.to & Get.back',
      (WidgetTester tester) async {
        await tester.pumpWidget(const MyApp());
        await tester.pumpAndSettle();

        final controller = Get.find<CartController>();

        // Buka detail produk pertama dengan Get.to()
        expect(find.byType(ProductCard), findsWidgets);
        await tester.tap(find.byType(ProductCard).first);
        await tester.pumpAndSettle();

        expect(find.byType(ProductDetailPage), findsOneWidget);

        // Tambah produk ke keranjang via tombol di ProductDetailPage (Langkah 3 Butir 3)
        final addBtn = find.textContaining('Tambah ke Keranjang');
        expect(addBtn, findsOneWidget);
        await tester.tap(addBtn);
        await tester.pumpAndSettle();

        // Controller dan badge berubah tanpa setState
        expect(controller.totalItem, 1);

        // Kembali dengan Get.back() (Langkah 4 Butir 2)
        final backBtn = find.byTooltip('Kembali');
        await tester.tap(backBtn);
        await tester.pumpAndSettle();

        expect(find.byType(HomePage), findsOneWidget);
      },
    );

    testWidgets(
      'Langkah 5 & Tugas Mandiri: CartPage, Ubah Kuantitas, Hapus Item, & Get.off ke CheckoutPage',
      (WidgetTester tester) async {
        await tester.pumpWidget(const MyApp());
        await tester.pumpAndSettle();

        final controller = Get.find<CartController>();
        final dummy = dummyProducts.first;
        controller.addToCart(dummy, 2);
        await tester.pumpAndSettle();

        // Pindah ke tab keranjang
        await tester.tap(find.text('Keranjang'));
        await tester.pumpAndSettle();

        expect(find.byType(CartPage), findsOneWidget);
        expect(find.textContaining(dummy.name), findsOneWidget);
        expect(find.text('2'), findsWidgets);

        // Uji tombol Checkout yang memanggil Get.off(() => const CheckoutPage())
        final checkoutBtn = find.text('Checkout');
        expect(checkoutBtn, findsOneWidget);
        await tester.tap(checkoutBtn);
        await tester.pumpAndSettle();

        expect(find.byType(CheckoutPage), findsOneWidget);
        expect(find.text('Checkout Pesanan'), findsOneWidget);
      },
    );
  });

  // ===========================================================================
  // MODUL PENGUJIAN MODEL & HELPER TOKOKITA (PERTEMUAN 1-5)
  // ===========================================================================
  group('Pengujian Model & Helper TokoKita', () {
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
