import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../models/order.dart';

/// Helper class OrderDatabase untuk inisialisasi database SQLite dan pembuatan
/// tabel orders (Langkah 3 Butir 2: kolom id, tanggal, daftarItem, totalHarga, status).
class OrderDatabase {
  static final OrderDatabase instance = OrderDatabase._init();

  static Database? _database;

  OrderDatabase._init();

  /// Mendapatkan instance database SQLite, jika belum ada maka dilakukan inisialisasi.
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('tokokita_orders.db');
    return _database!;
  }

  /// Inisialisasi database dan lokasi file database
  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    // Buka database dan panggil _createDB saat pertama kali dibuat
    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  /// Membuat tabel `orders` sesuai spesifikasi modul praktikum Pertemuan 9:
  /// kolom: id, tanggal, daftarItem, totalHarga, status
  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE orders (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        tanggal TEXT NOT NULL,
        daftarItem TEXT NOT NULL,
        totalHarga REAL NOT NULL,
        status TEXT NOT NULL
      )
    ''');
  }

  // ===========================================================================
  // LANGKAH 4: OPERASI CRUD RIWAYAT PESANAN
  // ===========================================================================

  /// Langkah 4 Butir 1: Menyimpan data pesanan baru ke tabel orders
  Future<int> insertOrder(Order order) async {
    final db = await instance.database;
    return await db.insert(
      'orders',
      order.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Langkah 4 Butir 2: Mengambil seluruh riwayat pesanan (diurutkan terbaru lebih dulu)
  Future<List<Order>> getAllOrders() async {
    final db = await instance.database;
    final result = await db.query(
      'orders',
      orderBy: 'id DESC',
    );
    return result.map((json) => Order.fromMap(json)).toList();
  }

  /// Langkah 4 Butir 3: Mengubah status pesanan (misal: 'Diproses' -> 'Selesai')
  Future<int> updateOrderStatus(int id, String newStatus) async {
    final db = await instance.database;
    return await db.update(
      'orders',
      {'status': newStatus},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Langkah 4 Butir 4: Menghapus salah satu pesanan berdasarkan ID
  Future<int> deleteOrder(int id) async {
    final db = await instance.database;
    return await db.delete(
      'orders',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ===========================================================================
  // TUGAS MANDIRI 3: Pencarian / Filter dengan Klausa WHERE
  // ===========================================================================
  /// Mencari atau memfilter pesanan menggunakan query SQL dengan klausa WHERE
  Future<List<Order>> searchOrders({String? status, String? keyword}) async {
    final db = await instance.database;

    final List<String> whereClauses = [];
    final List<dynamic> whereArgs = [];

    if (status != null && status.isNotEmpty && status.toLowerCase() != 'semua') {
      whereClauses.add('status = ?');
      whereArgs.add(status);
    }

    if (keyword != null && keyword.trim().isNotEmpty) {
      whereClauses.add('(daftarItem LIKE ? OR tanggal LIKE ?)');
      whereArgs.add('%$keyword%');
      whereArgs.add('%$keyword%');
    }

    final whereString = whereClauses.isNotEmpty ? whereClauses.join(' AND ') : null;

    final result = await db.query(
      'orders',
      where: whereString,
      whereArgs: whereArgs.isNotEmpty ? whereArgs : null,
      orderBy: 'id DESC',
    );

    return result.map((json) => Order.fromMap(json)).toList();
  }

  /// Menutup koneksi database (opsional untuk lifecycle cleanup)
  Future<void> close() async {
    final db = _database;
    if (db != null) {
      await db.close();
      _database = null;
    }
  }
}
