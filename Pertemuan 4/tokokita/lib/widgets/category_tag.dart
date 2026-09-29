import 'package:flutter/material.dart';

/// Widget custom baru (Tugas Mandiri Butir 3) untuk menampilkan kategori produk.
/// Merupakan StatelessWidget yang dapat digunakan ulang di berbagai tempat.
class CategoryTag extends StatelessWidget {
  final String category;
  final Color? customColor;

  const CategoryTag({
    super.key,
    required this.category,
    this.customColor,
  });

  IconData _getCategoryIcon() {
    switch (category.toLowerCase()) {
      case 'elektronik':
        return Icons.devices;
      case 'fashion':
        return Icons.checkroom;
      case 'makanan':
        return Icons.restaurant;
      default:
        return Icons.category;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = customColor ?? const Color(0xFF1976D2);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
      decoration: BoxDecoration(
        color: color.withAlpha(20),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withAlpha(60), width: 0.8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _getCategoryIcon(),
            size: 13,
            color: color,
          ),
          const SizedBox(width: 4),
          Text(
            category,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
