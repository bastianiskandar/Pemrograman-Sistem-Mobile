/// Model data Order untuk merepresentasikan satu entitas riwayat pesanan pada TokoKita.
/// Disimpan secara terstruktur ke dalam database relasional SQLite (sqflite).
class Order {
  final int? id;
  final String tanggal;
  final String daftarItem;
  final double totalHarga;
  final String status;

  Order({
    this.id,
    required this.tanggal,
    required this.daftarItem,
    required this.totalHarga,
    required this.status,
  });

  /// Mengonversi instance Order menjadi `Map<String, dynamic>` untuk operasi INSERT/UPDATE SQLite
  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'tanggal': tanggal,
      'daftarItem': daftarItem,
      'totalHarga': totalHarga,
      'status': status,
    };
    if (id != null) {
      map['id'] = id;
    }
    return map;
  }

  /// Membuat instance Order dari Map baris SQLite (SELECT)
  factory Order.fromMap(Map<String, dynamic> map) {
    return Order(
      id: map['id'] as int?,
      tanggal: map['tanggal'] as String? ?? '',
      daftarItem: map['daftarItem'] as String? ?? '',
      totalHarga: (map['totalHarga'] as num?)?.toDouble() ?? 0.0,
      status: map['status'] as String? ?? 'Diproses',
    );
  }

  /// Membuat salinan objek Order dengan properti baru (misal update status)
  Order copyWith({
    int? id,
    String? tanggal,
    String? daftarItem,
    double? totalHarga,
    String? status,
  }) {
    return Order(
      id: id ?? this.id,
      tanggal: tanggal ?? this.tanggal,
      daftarItem: daftarItem ?? this.daftarItem,
      totalHarga: totalHarga ?? this.totalHarga,
      status: status ?? this.status,
    );
  }
}
