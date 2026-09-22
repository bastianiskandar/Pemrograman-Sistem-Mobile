// ignore_for_file: avoid_print

import 'dart:io';

// ============================================================================
// 1. VARIABEL & TIPE DATA (LANGKAH 1)
// ============================================================================
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

// ============================================================================
// 2. HELPER FUNCTIONS & LOGIKA DISKON (LANGKAH 3 & 4, TUGAS MANDIRI 3)
// ============================================================================
// Langkah 4 Butir 3: Arrow function pemformatan mata uang rupiah
String formatRupiah(num harga) =>
    'Rp ${harga.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}';

// Langkah 3 Butir 4: Switch-case penentuan diskon berdasarkan kategori
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

// Langkah 4 Butir 1 & 2: Function dengan named optional parameter & nilai default
double hitungHargaSetelahDiskon(double harga, {double persenDiskon = 0.0}) {
  return harga - (harga * (persenDiskon / 100.0));
}

// Tugas Mandiri 3 & Langkah 3 Butir 2: Perulangan for menghitung total belanja
double hitungTotalBelanja(List<Product> keranjang) {
  double total = 0.0;
  for (var p in keranjang) {
    total += p.price;
  }
  return total;
}

// ============================================================================
// 3. CLASS MODEL, INHERITANCE & NULL SAFETY (LANGKAH 5 & TUGAS MANDIRI 1)
// ============================================================================
class Product {
  int id;
  String name;
  double price;
  String category;
  int stock;
  String? imageUrl; // Nullable: tanda ? mengizinkan null (Langkah 5 Butir 4)
  String? description; // Nullable: tanda ? mengizinkan null

  Product({
    required this.id,
    required this.name,
    required this.price,
    required this.category,
    required this.stock,
    this.imageUrl,
    this.description,
  });

  // Tugas Mandiri 1 & Langkah 3 Butir 1 (if-else penentuan status ketersediaan)
  String getStatusStok() {
    if (stock > 5) return 'Tersedia';
    if (stock > 0) return 'Stok Terbatas';
    return 'Habis';
  }

  String get formattedPrice => formatRupiah(price);
}

// Langkah 5 Butir 2: Inheritance class turunan DiscountedProduct
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

// ============================================================================
// 4. DATA DUMMY (TUGAS MANDIRI 2: MINIMAL 8 PRODUK)
// ============================================================================
final List<Product> dummyProducts = [
  Product(
    id: 1,
    name: 'Laptop ASUS Vivo',
    price: 8500000,
    category: 'Elektronik',
    stock: 10,
    description: 'Core i5 RAM 8GB SSD 512GB',
  ),
  Product(
    id: 2,
    name: 'Smartphone Galaxy',
    price: 4500000,
    category: 'Elektronik',
    stock: 4,
    description: 'Layar AMOLED 120Hz',
  ),
  Product(
    id: 3,
    name: 'Kaos Polos Cotton',
    price: 75000,
    category: 'Fashion',
    stock: 25,
    description: 'Bahan Katun Combed 30s',
  ),
  Product(
    id: 4,
    name: 'Jaket Hoodie Fleece',
    price: 220000,
    category: 'Fashion',
    stock: 3,
    description: 'Bahan Tebal dan Nyaman',
  ),
  Product(
    id: 5,
    name: 'Nasi Goreng Spesial',
    price: 25000,
    category: 'Makanan',
    stock: 15,
    description: 'Porsi Komplit Telur & Ayam',
  ),
  Product(
    id: 6,
    name: 'Kopi Susu Aren',
    price: 18000,
    category: 'Makanan',
    stock: 0,
    description: 'Espresso Susu Segar Aren Asli',
  ),
  Product(
    id: 7,
    name: 'Headphone Wireless',
    price: 350000,
    category: 'Elektronik',
    stock: 8,
    description: 'Koneksi Bluetooth Bass Mantap',
  ),
  Product(
    id: 8,
    name: 'Sepatu Sneakers Casual',
    price: 320000,
    category: 'Fashion',
    stock: 2,
    description: 'Desain Sporty Warna Putih',
  ),
];

// List dinamis yang digunakan oleh program untuk operasi CRUD dan transaksi
List<Product> products = List<Product>.from(dummyProducts);

// ============================================================================
// 5. FITUR CRUD & TAMPILAN TABEL
// ============================================================================

// [READ] Menampilkan tabel produk secara rapi
void tampilkanTabel(List<Product> list) {
  const garis =
      '+----+-------------------------+---------------+-------+----------------+---------------+';
  print(garis);
  print(
    '| ID | ${'Nama Produk'.padRight(23)} | ${'Kategori'.padRight(13)} | ${'Stok'.padRight(5)} | ${'Harga'.padRight(14)} | ${'Status Stok'.padRight(13)} |',
  );
  print(garis);
  for (var p in list) {
    print(
      '| ${p.id.toString().padRight(2)} | ${p.name.padRight(23)} | ${p.category.padRight(13)} | ${p.stock.toString().padRight(5)} | ${p.formattedPrice.padRight(14)} | ${p.getStatusStok().padRight(13)} |',
    );
  }
  print(garis);
  print('${list.length} produk ditampilkan.\n');
}

// [CREATE] Menambah produk baru ke dalam katalog
void tambahProduk() {
  print('\n--- [CREATE] Tambah Produk Baru ---');
  stdout.write('Nama Produk : ');
  final name = stdin.readLineSync()?.trim() ?? '';
  if (name.isEmpty) {
    print('Error: Nama produk tidak boleh kosong!\n');
    return;
  }

  stdout.write('Kategori (Elektronik/Fashion/Makanan): ');
  final category = stdin.readLineSync()?.trim() ?? 'Umum';

  stdout.write('Harga       : ');
  final price = double.tryParse(stdin.readLineSync()?.trim() ?? '') ?? 0.0;

  stdout.write('Stok Awal   : ');
  final stock = int.tryParse(stdin.readLineSync()?.trim() ?? '') ?? 0;

  stdout.write('Deskripsi (Opsional, Enter jika kosong): ');
  final descInput = stdin.readLineSync()?.trim();
  final String? desc = (descInput == null || descInput.isEmpty)
      ? null
      : descInput;

  final newId = products.isEmpty
      ? 1
      : (products.map((p) => p.id).reduce((a, b) => a > b ? a : b) + 1);
  products.add(
    Product(
      id: newId,
      name: name,
      price: price,
      category: category,
      stock: stock,
      description: desc,
    ),
  );
  print('Sukses: Produk "$name" berhasil ditambahkan dengan ID $newId.\n');
}

// [UPDATE] Mengubah data produk atau menambah/mengedit stok
void ubahProduk() {
  print('\n--- [UPDATE] Ubah Data Produk & Stok ---');
  tampilkanTabel(products);
  stdout.write('Masukkan ID produk yang ingin diedit: ');
  final id = int.tryParse(stdin.readLineSync()?.trim() ?? '') ?? -1;
  final index = products.indexWhere((p) => p.id == id);

  if (index == -1) {
    print('Error: Produk dengan ID $id tidak ditemukan!\n');
    return;
  }

  final p = products[index];
  print(
    '\nMengedit "${p.name}" (Tekan Enter langsung jika tidak ingin mengubah):',
  );

  stdout.write('Nama baru [${p.name}]: ');
  final name = stdin.readLineSync()?.trim();

  stdout.write('Kategori baru [${p.category}]: ');
  final category = stdin.readLineSync()?.trim();

  stdout.write('Harga baru [${p.price.toInt()}]: ');
  final priceStr = stdin.readLineSync()?.trim();

  stdout.write('Stok baru [${p.stock}]: ');
  final stockStr = stdin.readLineSync()?.trim();

  if (name != null && name.isNotEmpty) p.name = name;
  if (category != null && category.isNotEmpty) p.category = category;
  if (priceStr != null && priceStr.isNotEmpty) {
    p.price = double.tryParse(priceStr) ?? p.price;
  }
  if (stockStr != null && stockStr.isNotEmpty) {
    p.stock = int.tryParse(stockStr) ?? p.stock;
  }

  print('Sukses: Data produk ID $id ("${p.name}") berhasil diperbarui.\n');
}

// [DELETE] Menghapus produk dari sistem
void hapusProduk() {
  print('\n--- [DELETE] Hapus Produk ---');
  tampilkanTabel(products);
  stdout.write('Masukkan ID produk yang ingin dihapus: ');
  final id = int.tryParse(stdin.readLineSync()?.trim() ?? '') ?? -1;
  final initialCount = products.length;
  products.removeWhere((p) => p.id == id);

  if (products.length < initialCount) {
    print('Sukses: Produk dengan ID $id berhasil dihapus.\n');
  } else {
    print('Error: Produk dengan ID $id tidak ditemukan!\n');
  }
}

// ============================================================================
// 6. FITUR TRANSAKSI INTERAKTIF: BELI BARANG, PILIH STOK & DISKON KATEGORI
// ============================================================================
void beliProduk() {
  print('\n--- [TRANSAKSI] Pembelian Produk & Diskon Kategori ---');
  tampilkanTabel(products);

  // 1. Pilih barang mana yang ingin dibeli
  stdout.write('Masukkan ID produk yang ingin dibeli: ');
  final id = int.tryParse(stdin.readLineSync()?.trim() ?? '') ?? -1;
  final index = products.indexWhere((p) => p.id == id);

  if (index == -1) {
    print('Error: Produk dengan ID $id tidak ditemukan!\n');
    return;
  }

  final p = products[index];

  // Cek ketersediaan stok
  if (p.stock <= 0) {
    print(
      'Pemberitahuan: Stok barang "${p.name}" sedang HABIS (${p.getStatusStok()})!\n',
    );
    return;
  }

  // 2. Pilih mau beli berapa stok
  print('\nProduk Dipilih : ${p.name}');
  print('Kategori       : ${p.category}');
  print('Harga Satuan   : ${p.formattedPrice}');
  print('Stok Tersedia  : ${p.stock} item (${p.getStatusStok()})');
  stdout.write('Mau beli berapa stok? (1 - ${p.stock}): ');
  final qty = int.tryParse(stdin.readLineSync()?.trim() ?? '') ?? 0;

  if (qty <= 0) {
    print('Error: Jumlah pembelian harus lebih dari 0!\n');
    return;
  }
  if (qty > p.stock) {
    print(
      'Error: Stok tidak mencukupi! Anda meminta $qty, namun stok hanya tersisa ${p.stock}.\n',
    );
    return;
  }

  // 3. Kalkulasi Diskon Kategori & Pemotongan Stok
  final persenDiskon = hitungDiskonKategori(p.category);
  final subtotal = p.price * qty;
  final hargaSetelahDiskonSatuan = hitungHargaSetelahDiskon(
    p.price,
    persenDiskon: persenDiskon,
  );
  final totalBayar = hargaSetelahDiskonSatuan * qty;
  final hemat = subtotal - totalBayar;

  // Stok berkurang secara realtime di list
  p.stock -= qty;

  // 4. Tampilkan Struk Pembelian
  print('\n================== STRUK PEMBELIAN ==================');
  print('Toko           : $namaToko');
  print('Waktu          : ${DateTime.now().toString().substring(0, 19)}');
  print('-----------------------------------------------------');
  print('Barang Dibeli  : ${p.name}');
  print('Kategori       : ${p.category}');
  print('Harga Satuan   : ${p.formattedPrice}');
  print('Jumlah Beli    : $qty item');
  print('Subtotal       : ${formatRupiah(subtotal)}');
  print('Diskon Kategori: $persenDiskon% (Kategori ${p.category})');
  if (persenDiskon > 0) {
    print('Hemat Diskon   : -${formatRupiah(hemat)}');
  }
  print('-----------------------------------------------------');
  print('TOTAL BAYAR    : ${formatRupiah(totalBayar)}');
  print('SISA STOK KINI : ${p.stock} (${p.getStatusStok()})');
  print('=====================================================');
  print('Transaksi Berhasil! Stok barang telah diperbarui secara realtime.\n');
}

// ============================================================================
// 7. PENGUJIAN OTOMATIS LANGKAH 1 - 5 (UNTUK LAPORAN PRAKTIKUM)
// ============================================================================
void ujiPraktikum() {
  print('\n============================================================');
  print('        HASIL PENGUJIAN LEMBAR KERJA PRAKTIKUM 2            ');
  print('============================================================');

  // Langkah 1: Variabel & Tipe Data
  print('\n[LANGKAH 1] Variabel & Tipe Data:');
  var namaKasir = 'Bastian';
  int contohStok = 20;
  double contohHarga = 150000.0;
  String contohNama = 'Keyboard Gaming';
  bool statusTersedia = contohStok > 0;
  print('- const (Nama Toko) : $namaToko');
  print('- final (Tgl Buat)  : $tanggalDibuat');
  print('- var   (Kasir)     : $namaKasir');
  print(
    '- int, double, String, bool: $contohNama | Stok: $contohStok | Harga: ${formatRupiah(contohHarga)} | Tersedia: $statusTersedia',
  );
  print('- List kategori     : $kategoriList');
  print('- Map data mentah   : $produkMentah');

  // Langkah 2: Operator Perhitungan Harga & Logika
  print('\n[LANGKAH 2] Operator Perhitungan Harga & Logika:');
  int beliItem = 3;
  double totalAritmatika = contohHarga * beliItem;
  int sisaStok = contohStok - beliItem;
  double rataRata = totalAritmatika / beliItem;
  int sisaBagi = contohStok % beliItem;
  print('- Aritmatika (+, -, *, /, %):');
  print(
    '  * Total $beliItem item: ${formatRupiah(totalAritmatika)} (Operator *)',
  );
  print('  * Sisa stok: $sisaStok (Operator -)');
  print('  * Rata-rata per item: ${formatRupiah(rataRata)} (Operator /)');
  print('  * Modulo stok (20 % 3): $sisaBagi (Operator %)');
  print('- Perbandingan (==, !=, >, <):');
  print('  * Harga > 100.000? ${contohHarga > 100000}');
  print(
    '  * Stok laptop == Stok smartphone? ${dummyProducts[0].stock == dummyProducts[1].stock}',
  );
  print('- Logika (&&, ||, !):');
  bool layakTampil = contohStok > 0 && contohHarga > 0;
  print('  * Layak tampil (stok > 0 && harga > 0): $layakTampil');

  // Langkah 3: Control Flow (if-else, for, while, switch)
  print('\n[LANGKAH 3] Control Flow Toko:');
  print('- if-else (Status Stok):');
  print(
    '  * Stok ${dummyProducts[0].stock} : ${dummyProducts[0].getStatusStok()}',
  );
  print(
    '  * Stok ${dummyProducts[1].stock} : ${dummyProducts[1].getStatusStok()}',
  );
  print(
    '  * Stok ${dummyProducts[5].stock} : ${dummyProducts[5].getStatusStok()}',
  );
  print('- switch-case (Diskon Kategori):');
  for (var k in kategoriList) {
    print('  * Kategori $k -> diskon: ${hitungDiskonKategori(k)}%');
  }
  print(
    '- for loop (Total Belanja Dummy): ${formatRupiah(hitungTotalBelanja(dummyProducts))}',
  );
  print('- while loop (Simulasi pengurangan stok satu per satu hingga habis):');
  int stokSimulasi = 4;
  stdout.write('  Simulasi: ');
  while (stokSimulasi > 0) {
    stdout.write('Stok $stokSimulasi -> ');
    stokSimulasi--;
  }
  print('Stok 0 (Habis)');

  // Langkah 4: Function untuk Logika Produk & Diskon
  print('\n[LANGKAH 4] Function & Arrow Function:');
  double hargaAwal = 250000;
  double hDiskon = hitungHargaSetelahDiskon(hargaAwal, persenDiskon: 20);
  double hTanpaDiskon = hitungHargaSetelahDiskon(hargaAwal); // default optional
  print('- hitungHargaSetelahDiskon (named optional):');
  print('  * Harga Rp 250.000 dengan diskon 20%   : ${formatRupiah(hDiskon)}');
  print(
    '  * Harga Rp 250.000 tanpa argumen diskon : ${formatRupiah(hTanpaDiskon)}',
  );
  print('- arrow function formatRupiah           : ${formatRupiah(1250000)}');

  // Langkah 5: Class Product & Null Safety + OOP Inheritance
  print('\n[LANGKAH 5] Class Product & Null Safety:');
  final pContoh = Product(
    id: 99,
    name: 'Earphone TWS',
    price: 180000,
    category: 'Elektronik',
    stock: 7,
    description: null, // Nullable field (String?)
  );
  print(
    '- Instance Product: ID ${pContoh.id} | ${pContoh.name} | Harga: ${pContoh.formattedPrice} | Status: ${pContoh.getStatusStok()}',
  );
  print(
    '- Null Safety: pContoh.description bernilai null -> "${pContoh.description}" (Diizinkan karena bertipe String?)',
  );

  final dp = DiscountedProduct(
    id: 100,
    name: 'Smartwatch Pro',
    price: 500000,
    category: 'Elektronik',
    stock: 5,
    discountPercent: 25,
  );
  print('- Inheritance DiscountedProduct:');
  print('  * Produk: ${dp.name} | Harga Normal: ${dp.formattedPrice}');
  print(
    '  * Diskon: ${dp.discountPercent}% | Harga Final: ${dp.formattedFinalPrice}',
  );

  print('\n[TUGAS MANDIRI]');
  print(
    '- 1. Method tambahan getStatusStok(): Sukses diimplementasikan pada class Product.',
  );
  print(
    '- 2. List<Product> 8 data dummy: ${dummyProducts.length} produk siap digunakan.',
  );
  print(
    '- 3. Total belanja 8 produk dummy: ${formatRupiah(hitungTotalBelanja(dummyProducts))}',
  );
  print('============================================================\n');
}

// ============================================================================
// 8. PROGRAM UTAMA (CLI INTERAKTIF)
// ============================================================================
void main() {
  while (true) {
    print('============================================');
    print('      SISTEM CRUD & KASIR TOKOKITA          ');
    print('============================================');
    print('[1] Tampilkan Semua Produk (Read / Tabel)');
    print('[2] Beli Produk (Pilih Barang, Stok, & Diskon)');
    print('[3] Tambah Produk Baru (Create)');
    print('[4] Ubah Data Produk / Update Stok (Update)');
    print('[5] Hapus Produk (Delete)');
    print('[6] Jalankan Uji Lengkap Modul Praktikum');
    print('[0] Keluar');
    stdout.write('Pilih menu [0-6]: ');
    final input = stdin.readLineSync()?.trim();

    if (input == null || input == '0') {
      print('\nKeluar dari program. Terima kasih telah menggunakan TokoKita!');
      break;
    }

    switch (input) {
      case '1':
        tampilkanTabel(products);
        break;
      case '2':
        beliProduk();
        break;
      case '3':
        tambahProduk();
        break;
      case '4':
        ubahProduk();
        break;
      case '5':
        hapusProduk();
        break;
      case '6':
        ujiPraktikum();
        break;
      default:
        print('Pilihan tidak valid! Silakan masukkan angka 0-6.\n');
    }

    stdout.write('Tekan Enter untuk kembali ke menu utama...');
    stdin.readLineSync();
    print('');
  }
}
