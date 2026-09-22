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
    final color = customColor ?? Colors.indigo;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withAlpha(25),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _getCategoryIcon(),
            size: 14,
            color: color,
          ),
          const SizedBox(width: 4),
          Text(
            category,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
