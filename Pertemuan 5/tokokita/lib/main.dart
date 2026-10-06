import 'package:flutter/material.dart';

import 'models/product.dart';
import 'screens/cart_page.dart';
import 'screens/main_page.dart';
import 'screens/product_detail_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
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
      // =======================================================================
      // LANGKAH 2 & LANGKAH 5 BUTIR 3: Definisi Named Routes pada MaterialApp
      // '/'       -> MainPage (Bottom Navigation: Beranda, Keranjang, Profil)
      // '/detail' -> ProductDetailPage (menerima Product via arguments)
      // '/cart'   -> CartPage (Halaman Keranjang Belanja)
      // =======================================================================
      initialRoute: '/',
      routes: {
        '/': (context) => const MainPage(),
        '/detail': (context) => const ProductDetailPage(),
        '/cart': (context) => const CartPage(),
      },
    );
  }
}
