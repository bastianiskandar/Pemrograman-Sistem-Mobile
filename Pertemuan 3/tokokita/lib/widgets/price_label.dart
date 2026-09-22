import 'package:flutter/material.dart';
import '../models/product.dart';

/// Widget sederhana untuk menampilkan harga dalam format Rupiah.
/// Merupakan StatelessWidget karena nilai harga tidak berubah secara internal.
class PriceLabel extends StatelessWidget {
  final double price;
  final TextStyle? style;

  const PriceLabel({
    super.key,
    required this.price,
    this.style,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      formatRupiah(price),
      style: style ??
          const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: Colors.green,
          ),
    );
  }
}
