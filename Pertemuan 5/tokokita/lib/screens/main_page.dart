import 'package:flutter/material.dart';

import 'cart_page.dart';
import 'home_page.dart';
import 'profile_page.dart';

/// MainPage — Kerangka utama aplikasi TokoKita dengan BottomNavigationBar (Langkah 5).
/// Mengatur pergantian antara tiga menu utama:
/// 1. Beranda (HomePage)
/// 2. Keranjang (CartPage)
/// 3. Profil (ProfilePage)
class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  // Index tab yang sedang aktif (0: Beranda, 1: Keranjang, 2: Profil)
  int _currentIndex = 0;

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      HomePage(onOpenCart: () => _onTabTapped(1)),
      CartPage(onBrowseProducts: () => _onTabTapped(0)),
      const ProfilePage(),
    ];
  }

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Menggunakan IndexedStack untuk mempertahankan posisi scroll dan state halaman
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),

      // =======================================================================
      // LANGKAH 5 BUTIR 1: BottomNavigationBar minimal 3 menu
      // Beranda, Keranjang, dan Profil
      // =======================================================================
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(12),
              blurRadius: 10,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: _onTabTapped,
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: const Color(0xFF1976D2),
          unselectedItemColor: const Color(0xFF94A3B8),
          selectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 12,
          ),
          unselectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 12,
          ),
          elevation: 0,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home_rounded),
              label: 'Beranda',
              tooltip: 'Halaman Beranda',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.shopping_cart_outlined),
              activeIcon: Icon(Icons.shopping_cart_rounded),
              label: 'Keranjang',
              tooltip: 'Halaman Keranjang',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline_rounded),
              activeIcon: Icon(Icons.person_rounded),
              label: 'Profil',
              tooltip: 'Halaman Profil',
            ),
          ],
        ),
      ),
    );
  }
}
