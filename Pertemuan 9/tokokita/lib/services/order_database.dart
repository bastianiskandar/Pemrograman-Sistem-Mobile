// ignore_for_file: avoid_print

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';

import '../models/order.dart';

/// Helper class OrderDatabase untuk inisialisasi database SQLite dan pembuatan
/// tabel orders (Langkah 3 Butir 2: kolom id, tanggal, daftarItem, totalHarga, status).
///
/// Menyediakan mekanisme fallback otomatis ke Local Storage (SharedPreferences) jika
/// dijalankan di lingkungan Web (Chrome/Edge) atau lingkungan tanpa dukungan native SQLite,
/// sehingga aplikasi tidak mengalami macet/hang (stuck loading).
class OrderDatabase {
  static final OrderDatabase instance = OrderDatabase._init();

  static Database? _database;
  static bool _useFallback = false;
  static const String _fallbackStorageKey = 'tokokita_sqlite_orders_fallback';

  OrderDatabase._init();

  /// Mendapatkan instance database SQLite, jika belum ada maka dilakukan inisialisasi.
  /// Jika platform tidak mendukung (misal Web), beralih ke fallback tanpa menyebabkan freeze.
  Future<Database?> get database async {
    if (kIsWeb) {
      _useFallback = true;
      return null;
    }
    if (_useFallback) return null;
    if (_database != null) return _database!;

    try {
      _database = await _initDB('tokokita_orders.db').timeout(
        const Duration(seconds: 3),
        onTimeout: () {
          print('[OrderDatabase] Timeout inisialisasi SQLite native, beralih ke fallback storage.');
          _useFallback = true;
          return null as dynamic;
        },
      );
      return _database;
    } catch (e) {
      print('[OrderDatabase] SQLite native tidak tersedia pada platform ini ($e). Menggunakan persistent fallback.');
      _useFallback = true;
      return null;
    }
  }

  /// Inisialisasi database SQLite dan lokasi file database
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
    final db = await database;
    if (db != null) {
      try {
        return await db.insert(
          'orders',
          order.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      } catch (e) {
        print('[OrderDatabase] Error SQLite insert: $e. Menyimpan via fallback.');
      }
    }
    return await _fallbackInsertOrder(order);
  }

  /// Langkah 4 Butir 2: Mengambil seluruh riwayat pesanan (diurutkan terbaru lebih dulu)
  Future<List<Order>> getAllOrders() async {
    final db = await database;
    if (db != null) {
      try {
        final result = await db.query(
          'orders',
          orderBy: 'id DESC',
        );
        return result.map((json) => Order.fromMap(json)).toList();
      } catch (e) {
        print('[OrderDatabase] Error SQLite getAll: $e. Membaca via fallback.');
      }
    }
    return await _fallbackGetAllOrders();
  }

  /// Langkah 4 Butir 3: Mengubah status pesanan (misal: 'Diproses' -> 'Selesai')
  Future<int> updateOrderStatus(int id, String newStatus) async {
    final db = await database;
    if (db != null) {
      try {
        return await db.update(
          'orders',
          {'status': newStatus},
          where: 'id = ?',
          whereArgs: [id],
        );
      } catch (e) {
        print('[OrderDatabase] Error SQLite update: $e. Mengupdate via fallback.');
      }
    }
    return await _fallbackUpdateStatus(id, newStatus);
  }

  /// Langkah 4 Butir 4: Menghapus salah satu pesanan berdasarkan ID
  Future<int> deleteOrder(int id) async {
    final db = await database;
    if (db != null) {
      try {
        return await db.delete(
          'orders',
          where: 'id = ?',
          whereArgs: [id],
        );
      } catch (e) {
        print('[OrderDatabase] Error SQLite delete: $e. Menghapus via fallback.');
      }
    }
    return await _fallbackDeleteOrder(id);
  }

  // ===========================================================================
  // TUGAS MANDIRI 3: Pencarian / Filter dengan Klausa WHERE
  // ===========================================================================
  /// Mencari atau memfilter pesanan menggunakan query SQL dengan klausa WHERE
  Future<List<Order>> searchOrders({String? status, String? keyword}) async {
    final db = await database;
    if (db != null) {
      try {
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
      } catch (e) {
        print('[OrderDatabase] Error SQLite search: $e. Mencari via fallback.');
      }
    }

    // Eksekusi filter WHERE pada fallback storage
    final all = await _fallbackGetAllOrders();
    return all.where((order) {
      final matchStatus = status == null ||
          status.isEmpty ||
          status.toLowerCase() == 'semua' ||
          order.status.toLowerCase() == status.toLowerCase();

      final matchKeyword = keyword == null ||
          keyword.trim().isEmpty ||
          order.daftarItem.toLowerCase().contains(keyword.toLowerCase()) ||
          order.tanggal.toLowerCase().contains(keyword.toLowerCase());

      return matchStatus && matchKeyword;
    }).toList();
  }

  /// Menutup koneksi database (opsional untuk lifecycle cleanup)
  Future<void> close() async {
    final db = _database;
    if (db != null) {
      await db.close();
      _database = null;
    }
  }

  // ===========================================================================
  // PERSISTENT FALLBACK STORAGE (MEMASTIKAN WEB / CHROME TIDAK STUCK)
  // ===========================================================================

  Future<List<Order>> _fallbackGetAllOrders() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final rawList = prefs.getStringList(_fallbackStorageKey) ?? [];
      final orders = rawList.map((str) {
        final Map<String, dynamic> map = jsonDecode(str);
        return Order.fromMap(map);
      }).toList();
      orders.sort((a, b) => (b.id ?? 0).compareTo(a.id ?? 0));
      return orders;
    } catch (e) {
      print('[OrderDatabase Fallback] Error reading orders: $e');
      return [];
    }
  }

  Future<int> _fallbackInsertOrder(Order order) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final rawList = prefs.getStringList(_fallbackStorageKey) ?? [];
      final orders = rawList.map((str) {
        final Map<String, dynamic> map = jsonDecode(str);
        return Order.fromMap(map);
      }).toList();

      int nextId = 1;
      if (orders.isNotEmpty) {
        final maxId = orders.map((o) => o.id ?? 0).reduce((a, b) => a > b ? a : b);
        nextId = maxId + 1;
      }

      final newOrder = order.copyWith(id: nextId);
      orders.add(newOrder);

      final encodedList = orders.map((o) => jsonEncode(o.toMap())).toList();
      await prefs.setStringList(_fallbackStorageKey, encodedList);
      return nextId;
    } catch (e) {
      print('[OrderDatabase Fallback] Error inserting order: $e');
      return 1;
    }
  }

  Future<int> _fallbackUpdateStatus(int id, String newStatus) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final rawList = prefs.getStringList(_fallbackStorageKey) ?? [];
      final orders = rawList.map((str) {
        final Map<String, dynamic> map = jsonDecode(str);
        return Order.fromMap(map);
      }).toList();

      final index = orders.indexWhere((o) => o.id == id);
      if (index >= 0) {
        orders[index] = orders[index].copyWith(status: newStatus);
        final encodedList = orders.map((o) => jsonEncode(o.toMap())).toList();
        await prefs.setStringList(_fallbackStorageKey, encodedList);
        return 1;
      }
      return 0;
    } catch (e) {
      print('[OrderDatabase Fallback] Error updating order: $e');
      return 0;
    }
  }

  Future<int> _fallbackDeleteOrder(int id) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final rawList = prefs.getStringList(_fallbackStorageKey) ?? [];
      final orders = rawList.map((str) {
        final Map<String, dynamic> map = jsonDecode(str);
        return Order.fromMap(map);
      }).toList();

      final initialLength = orders.length;
      orders.removeWhere((o) => o.id == id);
      if (orders.length < initialLength) {
        final encodedList = orders.map((o) => jsonEncode(o.toMap())).toList();
        await prefs.setStringList(_fallbackStorageKey, encodedList);
        return 1;
      }
      return 0;
    } catch (e) {
      print('[OrderDatabase Fallback] Error deleting order: $e');
      return 0;
    }
  }
}
