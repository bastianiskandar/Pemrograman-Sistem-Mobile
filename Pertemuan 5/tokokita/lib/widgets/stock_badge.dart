import 'package:flutter/material.dart';

/// Widget sederhana untuk menampilkan status stok dalam bentuk badge berwarna.
/// Merupakan StatelessWidget karena badge hanya menerima status dan merendernya.
class StockBadge extends StatelessWidget {
  final String status;

  const StockBadge({super.key, required this.status});

  /// Menentukan warna badge berdasarkan status stok dari Pertemuan 2:
  /// - 'Tersedia'      : Hijau
  /// - 'Stok Terbatas' : Oranye
  /// - 'Habis'         : Merah
  Color _getBadgeColor() {
    switch (status) {
      case 'Tersedia':
        return const Color(0xFF2E7D32);
      case 'Stok Terbatas':
        return const Color(0xFFE65100);
      case 'Habis':
        return const Color(0xFFC62828);
      default:
        return const Color(0xFF546E7A);
    }
  }

  Color _getBadgeBgColor() {
    switch (status) {
      case 'Tersedia':
        return const Color(0xFFE8F5E9);
      case 'Stok Terbatas':
        return const Color(0xFFFFF3E0);
      case 'Habis':
        return const Color(0xFFFFEBEE);
      default:
        return const Color(0xFFECEFF1);
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _getBadgeColor();
    final bgColor = _getBadgeBgColor();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withAlpha(90), width: 0.8),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: color,
          fontSize: 9.5,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.1,
        ),
      ),
    );
  }
}
