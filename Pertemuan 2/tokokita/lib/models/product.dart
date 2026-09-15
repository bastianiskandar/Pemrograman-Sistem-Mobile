// ignore_for_file: avoid_print

import 'dart:io';

const String namaToko = 'TokoKita';
final DateTime tanggalDibuat = DateTime.now();
const List<String> kategoriList = ['Elektronik', 'Fashion', 'Makanan'];

final Map<String, dynamic> produkMentah = {
  'id': 101,
  'name': 'Mouse Wireless',
  'price': 125000.0,
  'category': 'Elektronik',
  'stock': 15,
};

String formatRupiah(num harga) => 'Rp ${harga.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}';

double hitungDiskonKategori(String kategori) {
  switch (kategori.toLowerCase()) {
    case 'elektronik':
      return 10.0;
    case 'fashion':
      return 15.0;
    case 'makanan':
      return 5.0;
    default:
      return 0.0;
  }
}

double hitungHargaSetelahDiskon(double harga, {double persenDiskon = 0.0}) {
  return harga - (harga * (persenDiskon / 100.0));
}

double hitungTotalBelanja(List<Product> keranjang) {
  double total = 0.0;
  for (var p in keranjang) {
    total += p.price;
  }
  return total;
}

class Product {
  int id;
  String name;
  double price;
  String category;
  int stock;
  String? imageUrl;
  String? description;

  Product({
    required this.id,
    required this.name,
    required this.price,
    required this.category,
    required this.stock,
    this.imageUrl,
    this.description,
  });

  String getStatusStok() {
    if (stock > 5) return 'Tersedia';
    if (stock > 0) return 'Stok Terbatas';
    return 'Habis';
  }

  String get formattedPrice => formatRupiah(price);
}

class DiscountedProduct extends Product {
  double discountPercent;

  DiscountedProduct({
    required super.id,
    required super.name,
    required super.price,
    required super.category,
    required super.stock,
    super.imageUrl,
    super.description,
    required this.discountPercent,
  });

  double hitungHargaFinal() => price - (price * (discountPercent / 100.0));

  String get formattedFinalPrice => formatRupiah(hitungHargaFinal());
}

final List<Product> dummyProducts = [
  Product(id: 1, name: 'Laptop ASUS', price: 8500000, category: 'Elektronik', stock: 10, description: 'Laptop Core i5'),
  Product(id: 2, name: 'Smartphone Samsung', price: 4500000, category: 'Elektronik', stock: 4, description: 'Layar AMOLED'),
  Product(id: 3, name: 'Kaos Polos', price: 75000, category: 'Fashion', stock: 25, description: 'Bahan Katun'),
  Product(id: 4, name: 'Jaket Hoodie', price: 220000, category: 'Fashion', stock: 3, description: 'Bahan Fleece'),
  Product(id: 5, name: 'Nasi Goreng', price: 25000, category: 'Makanan', stock: 15, description: 'Porsi Telur'),
  Product(id: 6, name: 'Kopi Susu Aren', price: 18000, category: 'Makanan', stock: 0, description: 'Espresso Susu'),
  Product(id: 7, name: 'Headphone Wireless', price: 350000, category: 'Elektronik', stock: 8, description: 'Bluetooth Bass'),
  Product(id: 8, name: 'Sepatu Sneakers', price: 320000, category: 'Fashion', stock: 2, description: 'Warna Putih'),
];

List<Product> products = List<Product>.from(dummyProducts);

void tampilkanTabel(List<Product> list) {
  const garis = '+----+----------------------+---------------+-------+----------------+---------------+';
  print(garis);
  print('| ID | ${'Nama Produk'.padRight(20)} | ${'Kategori'.padRight(13)} | ${'Stok'.padRight(5)} | ${'Harga'.padRight(14)} | ${'Status Stok'.padRight(13)} |');
  print(garis);
  for (var p in list) {
    print('| ${p.id.toString().padRight(2)} | ${p.name.padRight(20)} | ${p.category.padRight(13)} | ${p.stock.toString().padRight(5)} | ${p.formattedPrice.padRight(14)} | ${p.getStatusStok().padRight(13)} |');
  }
  print(garis);
  print('${list.length} row(s) in set\n');
}

void tambahProduk() {
  print('\n--- [CREATE] Tambah Produk Baru ---');
  stdout.write('Nama Produk : ');
  final name = stdin.readLineSync()?.trim() ?? '';
  stdout.write('Kategori    : ');
  final category = stdin.readLineSync()?.trim() ?? 'Umum';
  stdout.write('Harga       : ');
  final price = double.tryParse(stdin.readLineSync()?.trim() ?? '') ?? 0.0;
  stdout.write('Stok        : ');
  final stock = int.tryParse(stdin.readLineSync()?.trim() ?? '') ?? 0;

  final newId = products.isEmpty ? 1 : (products.map((p) => p.id).reduce((a, b) => a > b ? a : b) + 1);
  products.add(Product(id: newId, name: name, price: price, category: category, stock: stock));
  print('Query OK, berhasil menambahkan "$name" (ID: $newId).\n');
}

void ubahProduk() {
  print('\n--- [UPDATE] Ubah Data Produk ---');
  tampilkanTabel(products);
  stdout.write('Masukkan ID produk yang mau diedit: ');
  final id = int.tryParse(stdin.readLineSync()?.trim() ?? '') ?? -1;
  final index = products.indexWhere((p) => p.id == id);
  if (index == -1) {
    print('Error: Produk dengan ID $id tidak ditemukan!\n');
    return;
  }
  final p = products[index];
  print('Mengedit "${p.name}" (Tekan Enter jika tidak ingin mengubah)');
  stdout.write('Nama baru [${p.name}]: ');
  final name = stdin.readLineSync()?.trim();
  stdout.write('Harga baru [${p.price.toInt()}]: ');
  final priceStr = stdin.readLineSync()?.trim();
  stdout.write('Stok baru [${p.stock}]: ');
  final stockStr = stdin.readLineSync()?.trim();

  if (name != null && name.isNotEmpty) p.name = name;
  if (priceStr != null && priceStr.isNotEmpty) p.price = double.tryParse(priceStr) ?? p.price;
  if (stockStr != null && stockStr.isNotEmpty) p.stock = int.tryParse(stockStr) ?? p.stock;

  print('Query OK, 1 row affected. Data produk ID $id berhasil diperbarui.\n');
}

void hapusProduk() {
  print('\n--- [DELETE] Hapus Produk ---');
  tampilkanTabel(products);
  stdout.write('Masukkan ID produk yang ingin dihapus: ');
  final id = int.tryParse(stdin.readLineSync()?.trim() ?? '') ?? -1;
  final initialCount = products.length;
  products.removeWhere((p) => p.id == id);
  if (products.length < initialCount) {
    print('Query OK, 1 row affected. Produk ID $id berhasil dihapus.\n');
  } else {
    print('Error: Produk tidak ditemukan!\n');
  }
}

void ujiPraktikum() {
  print('\n=== HASIL MODUL PRAKTIKUM 2 (DASAR DART) ===');
  print('1. Variabel : Toko: $namaToko | Kategori: $kategoriList');
  double h = 50000; int q = 3; int s = 10 - q;
  print('2. Operator : Total ${formatRupiah(h * q)} | Sisa Stok $s | Layak Tampil: ${s > 0 && h > 0}');
  print('3. If-Else  : Stok 10 -> ${dummyProducts[0].getStatusStok()} | Stok 0 -> ${dummyProducts[5].getStatusStok()}');
  print('4. Diskon   : Diskon Elektronik -> ${hitungDiskonKategori("Elektronik")}%');
  print('5. Function : Harga 200.000 diskon 15% -> ${formatRupiah(hitungHargaSetelahDiskon(200000, persenDiskon: 15))}');
  final dp = DiscountedProduct(id: 99, name: 'Smartwatch', price: 500000, category: 'Elektronik', stock: 5, discountPercent: 20);
  print('6. OOP      : ${dp.name} diskon ${dp.discountPercent}% -> Final: ${dp.formattedFinalPrice}');
  print('7. Total    : Total seluruh 8 produk dummy: ${formatRupiah(hitungTotalBelanja(dummyProducts))}\n');
}

void main() {
  while (true) {
    print('============================================');
    print('      SISTEM CRUD TOKOKITA (TERMINAL)       ');
    print('============================================');
    print('[1] Tampilkan Semua Produk (Read / Tabel)');
    print('[2] Tambah Produk Baru (Create)');
    print('[3] Edit / Ubah Produk (Update)');
    print('[4] Hapus Produk (Delete)');
    print('[5] Jalankan Uji Modul Praktikum (Langkah 1-5)');
    print('[0] Keluar');
    stdout.write('Pilih menu [0-5]: ');
    final input = stdin.readLineSync()?.trim();

    if (input == null || input == '0') {
      print('\nKeluar dari program. Terima kasih!');
      break;
    }

    switch (input) {
      case '1':
        tampilkanTabel(products);
        break;
      case '2':
        tambahProduk();
        break;
      case '3':
        ubahProduk();
        break;
      case '4':
        hapusProduk();
        break;
      case '5':
        ujiPraktikum();
        break;
      default:
        print('Pilihan tidak valid!\n');
    }

    stdout.write('Tekan Enter untuk kembali ke menu utama...');
    stdin.readLineSync();
    print('');
  }
}