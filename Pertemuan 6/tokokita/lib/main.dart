import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'models/product.dart';
import 'screens/cart_page.dart';
import 'screens/checkout_page.dart';
import 'screens/main_page.dart';
import 'screens/product_detail_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // =========================================================================
    // LANGKAH 1 BUTIR 2: Mengubah root MaterialApp menjadi GetMaterialApp
    // Memungkinkan penggunaan navigasi, dialog, dan snackbar GetX tanpa BuildContext
    // =========================================================================
    return GetMaterialApp(
      title: namaToko,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1976D2),
          primary: const Color(0xFF1976D2),
        ),
        scaffoldBackgroundColor: const Color(0xFFF1F5F9),
        useMaterial3: true,
      ),
      initialRoute: '/',
      getPages: [
        GetPage(name: '/', page: () => const MainPage()),
        GetPage(name: '/detail', page: () => const ProductDetailPage()),
        GetPage(name: '/cart', page: () => const CartPage()),
        GetPage(name: '/checkout', page: () => const CheckoutPage()),
      ],
    );
  }
}

