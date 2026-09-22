import 'package:flutter/material.dart';

/// Widget sederhana untuk menampilkan status stok dalam bentuk badge berwarna.
/// Merupakan StatelessWidget karena badge hanya menerima status dan merendernya.
class StockBadge extends StatelessWidget {
  final String status;

  const StockBadge({
    super.key,
    required this.status,
  });

  /// Menentukan warna badge berdasarkan status stok dari Pertemuan 2:
  /// - 'Tersedia'      : Hijau
  /// - 'Stok Terbatas' : Oranye
  /// - 'Habis'         : Merah
  Color _getBadgeColor() {
    switch (status) {
      case 'Tersedia':
        return Colors.green;
      case 'Stok Terbatas':
        return Colors.orange;
      case 'Habis':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _getBadgeColor();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withAlpha(35),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color, width: 1),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
