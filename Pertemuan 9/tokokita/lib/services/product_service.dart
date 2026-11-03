// ignore_for_file: avoid_print

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../models/product.dart';

/// ProductService — Layanan networking HTTP untuk berkomunikasi dengan REST API.
/// Menangani pengambilan data produk secara asynchronous dari Fake Store API.
class ProductService {
  /// Base URL endpoint REST API publik untuk praktikum Pertemuan 7
  static const String baseUrl = 'https://fakestoreapi.com';

  /// URL simulasi kegagalan untuk menguji penanganan error (Langkah 5)
  static const String errorUrl = 'https://fakestoreapi.com/invalid_endpoint_error';

  /// Client HTTP yang dapat diganti untuk keperluan mocking atau pengujian
  static http.Client client = http.Client();

  /// Data produk tiruan untuk lingkungan pengujian widget test (offline)
  static List<Product>? mockProducts;

  // ===========================================================================
  // LANGKAH 2, LANGKAH 3, & LANGKAH 5: FETCH ALL PRODUCTS
  // ===========================================================================
  /// Mengambil daftar semua produk dari REST API (GET /products).
  ///
  /// - [customUrl]: Mengizinkan penggunaan URL kustom untuk keperluan testing/simulasi.
  /// - [simulateError]: Jika bernilai true, akan menembak endpoint yang salah atau
  ///   memunculkan error simulasi untuk mendemonstrasikan penanganan error (Langkah 5).
  static Future<List<Product>> fetchProducts({
    String? customUrl,
    bool simulateError = false,
    http.Client? httpClient,
  }) async {
    // Dukungan mock data untuk widget test jika diset
    if (mockProducts != null && !simulateError) {
      print('[ProductService] Menggunakan mockProducts untuk pengujian.');
      return List<Product>.from(mockProducts!);
    }

    final endpoint = simulateError
        ? errorUrl
        : (customUrl ?? '$baseUrl/products');

    print('------------------------------------------------------------');
    print('[ProductService] Mengirim HTTP GET ke: $endpoint');

    try {
      final activeClient = httpClient ?? client;

      // LANGKAH 2 BUTIR 1: Request GET menggunakan package http
      // Menggunakan async/await dengan timeout 15 detik untuk antisipasi koneksi lambat
      final response = await activeClient
          .get(Uri.parse(endpoint))
          .timeout(const Duration(seconds: 15));

      // LANGKAH 2 BUTIR 2: Mencetak status code dan response body ke console
      print('[ProductService] Response StatusCode: ${response.statusCode}');
      final bodyPreview = response.body.length > 200
          ? '${response.body.substring(0, 200)}... (total ${response.body.length} karakter)'
          : response.body;
      print('[ProductService] Response Body Preview:\n$bodyPreview');

      // LANGKAH 5: Pemeriksaan response.statusCode sebelum data diproses lebih lanjut
      if (response.statusCode == 200) {
        // LANGKAH 3 BUTIR 2: Mengubah JSON string menjadi struktur data Dart (jsonDecode)
        final List<dynamic> jsonList = jsonDecode(response.body);

        // Memetakan List<Map> menjadi List<Product> menggunakan Product.fromJson
        final List<Product> products = jsonList
            .map((item) => Product.fromJson(item as Map<String, dynamic>))
            .toList();

        print('[ProductService] Berhasil mem-parsing ${products.length} produk dari API.');
        print('------------------------------------------------------------');
        return products;
      } else {
        // Jika server mengembalikan status code selain 200 (misalnya 404, 500)
        throw HttpException(
          'Server mengembalikan respons error dengan Status Code: ${response.statusCode}',
        );
      }
    } on SocketException catch (e) {
      // Penanganan jika perangkat tidak memiliki koneksi internet / DNS gagal
      print('[ProductService ERROR] SocketException (Tidak ada koneksi internet): $e');
      throw Exception('Tidak dapat terhubung ke server. Periksa koneksi internet Anda.');
    } on TimeoutException catch (e) {
      // Penanganan jika request melebihi batas waktu (latency tinggi)
      print('[ProductService ERROR] TimeoutException: $e');
      throw Exception('Waktu tunggu koneksi habis (timeout). Silakan coba lagi.');
    } on FormatException catch (e) {
      // Penanganan jika data yang diterima bukan format JSON valid
      print('[ProductService ERROR] FormatException (Format JSON tidak valid): $e');
      throw Exception('Format data dari server tidak dikenali.');
    } catch (e) {
      // Penanganan error umum lainnya
      print('[ProductService ERROR] Terjadi kesalahan tidak terduga: $e');
      throw Exception('Gagal memuat produk: ${e.toString().replaceAll('Exception: ', '')}');
    }
  }

  // ===========================================================================
  // TUGAS MANDIRI 1: FETCH DETAIL SATU PRODUK BERDASARKAN ID
  // ===========================================================================
  /// Mengambil data detail satu produk dari endpoint /products/{id}.
  /// Digunakan pada ProductDetailPage sebagai alternatif data yang dikirim lewat navigasi.
  static Future<Product> fetchProductDetail(
    int id, {
    String? customUrl,
    bool simulateError = false,
    http.Client? httpClient,
  }) async {
    if (mockProducts != null && !simulateError) {
      return mockProducts!.firstWhere(
        (p) => p.id == id,
        orElse: () => mockProducts!.first,
      );
    }

    final endpoint = simulateError
        ? '$errorUrl/$id'
        : (customUrl ?? '$baseUrl/products/$id');

    print('------------------------------------------------------------');
    print('[ProductService] Mengambil Detail Produk #$id dari: $endpoint');

    try {
      final activeClient = httpClient ?? client;
      final response = await activeClient
          .get(Uri.parse(endpoint))
          .timeout(const Duration(seconds: 15));

      print('[ProductService] Detail Produk #$id - StatusCode: ${response.statusCode}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonMap = jsonDecode(response.body);
        final Product product = Product.fromJson(jsonMap);

        print('[ProductService] Berhasil memuat detail: ${product.name}');
        print('------------------------------------------------------------');
        return product;
      } else {
        throw HttpException(
          'Gagal memuat detail produk #$id (Status Code: ${response.statusCode})',
        );
      }
    } on SocketException catch (e) {
      print('[ProductService ERROR] Detail Produk SocketException: $e');
      throw Exception('Koneksi internet bermasalah. Gagal mengambil detail produk.');
    } on TimeoutException catch (e) {
      print('[ProductService ERROR] Detail Produk TimeoutException: $e');
      throw Exception('Waktu tunggu habis saat memuat detail produk.');
    } catch (e) {
      print('[ProductService ERROR] Detail Produk Error: $e');
      throw Exception('Gagal memuat detail produk: ${e.toString().replaceAll('Exception: ', '')}');
    }
  }
}
