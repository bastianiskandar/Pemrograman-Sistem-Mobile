import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:tokokita/controllers/cart_controller.dart';
import 'package:tokokita/main.dart';
import 'package:tokokita/models/product.dart';
import 'package:tokokita/screens/cart_page.dart';
import 'package:tokokita/screens/checkout_page.dart';
import 'package:tokokita/screens/home_page.dart';
import 'package:tokokita/screens/main_page.dart';
import 'package:tokokita/screens/product_detail_page.dart';
import 'package:tokokita/widgets/product_card.dart';

void main() {
  setUp(() {
    Get.reset();
  });

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
