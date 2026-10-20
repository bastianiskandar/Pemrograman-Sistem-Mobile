# LAPORAN PRAKTIKUM PEMROGRAMAN MOBILE
## Pertemuan 6 — State Management dengan GetX

---

### Informasi Mahasiswa
- **Mata Kuliah** : Pemrograman Mobile
- **Pertemuan**   : Pertemuan 6
- **Topik**       : State Management dengan GetX (GetxController, Obx, Variabel Reaktif Rx, Dependency Injection Get.put & Get.find, serta Routing GetX)
- **Studi Kasus** : TokoKita — Mengelola State Keranjang Belanja dengan GetX
- **Framework**   : Flutter (Dart) — GetX

---

## A. Ringkasan Implementasi Langkah Kerja

### 1. Langkah 1 — Instalasi & Konfigurasi GetX (`pubspec.yaml` & `lib/main.dart`)
- Menambahkan dependensi package `get` pada berkas `pubspec.yaml` dan menjalankan `flutter pub get`:
  ```yaml
  dependencies:
    flutter:
      sdk: flutter
    cupertino_icons: ^1.0.8
    http: ^1.6.0
    get: ^4.7.3
  ```
- Mengubah widget root aplikasi dari `MaterialApp` menjadi `GetMaterialApp` pada `lib/main.dart`:
  ```dart
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: namaToko,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(...),
      initialRoute: '/',
      getPages: [
        GetPage(name: '/', page: () => const MainPage()),
        GetPage(name: '/detail', page: () => const ProductDetailPage()),
        GetPage(name: '/cart', page: () => const CartPage()),
        GetPage(name: '/checkout', page: () => const CheckoutPage()),
      ],
    );
  }
  ```
- Verifikasi membuktikan seluruh aplikasi tetap berjalan normal, sekaligus mengaktifkan fitur routing tanpa `BuildContext`, overlay snackbar, dan dialog GetX di seluruh pohon widget.

---

### 2. Langkah 2 — CartController & Variabel Reaktif (`lib/controllers/cart_controller.dart`)
- Membuat berkas baru `lib/controllers/cart_controller.dart` yang meng-extends `GetxController`.
- Membuat model pendukung `lib/models/cart_item.dart` untuk membungkus objek `Product` dan atribut `quantity`.
- Mendefinisikan variabel reaktif `RxList<CartItem>` dengan ekstensi `.obs`:
  ```dart
  final RxList<CartItem> items = <CartItem>[].obs;
  ```
- Mengimplementasikan method mutasi data `addToCart(Product product, [int quantity = 1])` dan `removeFromCart(Product product)`. Jika produk sudah ada di keranjang, kuantitasnya akan ditambahkan secara dinamis dengan tetap memvalidasi sisa stok.
- Membuat getter reaktif untuk menghitung total akumulasi barang dan nominal belanja secara terpusat:
  ```dart
  int get totalItem => items.fold(0, (sum, item) => sum + item.quantity);
  double get totalHarga => items.fold(0.0, (sum, item) => sum + item.subtotal);
  ```
- Mendaftarkan instansiasi tunggal controller ke dalam memori aplikasi menggunakan **Dependency Injection** `Get.put(CartController())` pada awal aplikasi di `MainPage` (`lib/screens/main_page.dart`):
  ```dart
  final CartController _cartController = Get.put(CartController());
  ```

---

### 3. Langkah 3 — Obx & Reaktivitas Tampilan (`HomePage` & `ProductDetailPage`)
- Mengambil instance `CartController` secara global menggunakan `Get.find<CartController>()` pada `HomePage`, `ProductDetailPage`, dan `CartPage` tanpa perlu mengoper data manual melalui parameter widget.
- Membungkus ikon keranjang pada header `HomePage` dan `ProductDetailPage` dengan widget `Obx`:
  ```dart
  Obx(() {
    final total = _cartController.totalItem;
    return IconButton(
      icon: Badge(
        isLabelVisible: total > 0,
        label: Text('$total'),
        backgroundColor: const Color(0xFFE53935),
        child: const Icon(Icons.shopping_cart_outlined),
      ),
      onPressed: () => Get.to(() => const CartPage()),
    );
  })
  ```
- Menghubungkan tombol **"Tambah ke Keranjang"** pada `ProductDetailPage` langsung dengan method `_cartController.addToCart(product, _quantity)`.
- Mengamati bahwa badge angka keranjang pada `AppBar` dan header langsung bertambah secara instan dan reaktif tanpa pemanggilan `setState()`.

---

### 4. Langkah 4 — Routing dengan GetX (`Get.to`, `Get.back`, & `Get.off`)
- **Navigasi Maju (`Get.to`)**: Menggantikan navigasi `Navigator.pushNamed(context, '/detail')` pada `HomePage` menjadi:
  ```dart
  Get.to(() => ProductDetailPage(product: product));
  ```
- **Navigasi Mundur (`Get.back`)**: Menggantikan tombol panah kembali pada AppBar `ProductDetailPage` dari `Navigator.pop(context)` menjadi:
  ```dart
  Get.back();
  ```
  Navigasi bekerja mulus tanpa memerlukan objek `BuildContext`.
- **Navigasi Ganti Tumpukan (`Get.off`)**:
  - Diterapkan pada saat pengguna menekan tombol **"Checkout"** di `CartPage` menuju `CheckoutPage` (`Get.off(() => const CheckoutPage())`).
  - Diterapkan pada alur konfirmasi pembayaran di `CheckoutPage` menuju `OrderSuccessPage` (`Get.off(() => const OrderSuccessPage())`) untuk mencegah pengguna kembali ke layar transaksi yang telah selesai.

---

### 5. Langkah 5 — Menampilkan Halaman Keranjang dengan CartController (`lib/screens/cart_page.dart`)
- Mengganti tampilan *placeholder* dari Pertemuan 5 dengan antarmuka nyata berbasis `Obx` dan `ListView.builder`.
- Jika keranjang kosong (`cartController.items.isEmpty`), menampilkan ilustrasi grafis informatif dengan tombol ajakan *"Mulai Belanja Sekarang"*.
- Jika keranjang memiliki isi, menampilkan kartu produk yang memuat:
  1. Ikon / thumbnail kategori produk.
  2. Nama produk, label kategori, batas stok, dan harga satuan.
  3. Tombol hapus item (`Icons.delete_outline_rounded`) yang memanggil `cartController.removeFromCart(product)`.
  4. Pengatur kuantitas item (`-` dan `+`).
  5. Subtotal item per baris.
- Menampilkan bilah bawah (*bottom bar*) berisi total akumulasi harga (`cartController.totalHarga`) yang diformat rupiah dan tombol navigasi Checkout.

---

## E. Hasil Pengamatan

Catat hasil pengujian penggunaan GetX pada tabel berikut:

| No. | Fitur GetX yang Diuji | Hasil/Perilaku yang Diamati | Screenshot (Ya/Tidak) |
|:---:|:---|:---|:---:|
| **1** | **Badge keranjang reaktif dengan Obx** | Ketika item produk ditambahkan ke keranjang dari `ProductDetailPage`, badge angka merah pada ikon keranjang (baik di header `HomePage`, AppBar `ProductDetailPage`, maupun `BottomNavigationBar` di `MainPage`) langsung diperbarui secara *real-time* tanpa memicu rebuild seluruh halaman dan tanpa pemanggilan `setState`. | Ya |
| **2** | **`addToCart` & `removeFromCart`** | Method `addToCart` berhasil menambahkan produk baru ke `RxList<CartItem>`, atau menaikkan kuantitas jika produk yang sama sudah ada di keranjang. Method `removeFromCart` berhasil menghapus item yang dipilih dari daftar, dan tampilan keranjang langsung menyusut secara otomatis. | Ya |
| **3** | **`Get.to()` & `Get.back()` ke ProductDetailPage** | Menekan kartu produk di `HomePage` langsung membuka `ProductDetailPage` menggunakan `Get.to(() => ProductDetailPage(product: product))` tanpa memerlukan `BuildContext`. Menekan tombol panah kiri di `AppBar` memanggil `Get.back()` yang sukses kembali ke halaman sebelumnya secara mulus. | Ya |
| **4** | **`Get.find()` lintas halaman (Home, Detail, Keranjang)** | Controller yang didaftarkan sekali di `MainPage` via `Get.put(CartController())` dapat diakses secara konsisten di `HomePage`, `ProductDetailPage`, `CartPage`, dan `CheckoutPage` via `Get.find<CartController>()`. Semua halaman berbagi satu memori *single-instance* yang sama persis (*single source of truth*). | Ya |
| **5** | **Konsistensi `totalHarga` pada halaman Keranjang** | Nilai `totalHarga` yang dihitung melalui getter reaktif selalu sinkron dan konsisten terhadap setiap perubahan: saat produk ditambah, kuantitas dinaikkan/diturunkan, item dihapus, maupun saat keranjang dikosongkan secara keseluruhan. | Ya |

---

## F. Jawaban Tugas Mandiri

### 1. Tambahkan fitur ubah jumlah (quantity) per item pada halaman Keranjang TokoKita, dengan totalHarga yang otomatis menyesuaikan menggunakan Obx.
**Jawaban:**
Fitur penyesuaian kuantitas telah diimplementasikan pada `CartController` dan `CartPage`:
- Pada `CartController`:
  ```dart
  void increaseQuantity(Product product) {
    final item = items.firstWhere((i) => i.product.id == product.id);
    if (item.quantity < product.stock) {
      item.quantity++;
      items.refresh(); // Memicu notifikasi perubahan pada Obx
    }
  }

  void decreaseQuantity(Product product) {
    final item = items.firstWhere((i) => i.product.id == product.id);
    if (item.quantity > 1) {
      item.quantity--;
      items.refresh();
    } else {
      removeFromCart(product); // Hapus jika kuantitas berkurang di bawah 1
    }
  }
  ```
- Pada `CartPage`:
  Setiap baris kartu belanjaan memiliki komponen kontrol angka dengan tombol minus (`-`), teks kuantitas (`${item.quantity}`), dan tombol plus (`+`). Karena dibungkus di dalam widget `Obx`, setiap penekanan tombol langsung menghitung ulang `item.subtotal` dan `cartController.totalHarga` seketika tanpa jeda.

---

### 2. Tambahkan tombol 'Kosongkan Keranjang' pada CartController beserta konfirmasi sebelum dijalankan.
**Jawaban:**
Telah ditambahkan method `confirmClearCart(BuildContext context)` pada `CartController` yang memanfaatkan dialog bawaan GetX (`Get.defaultDialog`):
```dart
void confirmClearCart(BuildContext context) {
  if (items.isEmpty) return;

  Get.defaultDialog(
    title: 'Kosongkan Keranjang?',
    titleStyle: const TextStyle(fontWeight: FontWeight.w700),
    middleText: 'Apakah Anda yakin ingin menghapus semua barang dari keranjang belanja?',
    textConfirm: 'Ya, Kosongkan',
    textCancel: 'Batal',
    confirmTextColor: Colors.white,
    buttonColor: const Color(0xFFDC2626),
    onConfirm: () {
      clearCart();
      Get.back(); // Menutup modal dialog
      Get.snackbar(
        'Keranjang Dikosongkan',
        'Semua item berhasil dihapus dari keranjang belanja.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFF1976D2),
        colorText: Colors.white,
      );
    },
  );
}
```
Tombol pemicu diletakkan di sisi kanan atas `AppBar` pada `CartPage` dengan ikon `Icons.delete_sweep_outlined` dan warna merah peringatan. Tombol hanya muncul jika keranjang memiliki item.

---

### 3. Buat halaman Checkout sederhana yang menampilkan ringkasan pesanan dari CartController, dan gunakan Get.off() untuk berpindah ke halaman tersebut dari halaman Keranjang.
**Jawaban:**
Dibuat berkas baru `lib/screens/checkout_page.dart` yang berisi:
1. **Navigasi dari Keranjang (`Get.off`)**:
   Pada `CartPage`, tombol **"Checkout"** memanggil `Get.off(() => const CheckoutPage())`. Penggunaan `Get.off()` menggantikan posisi `CartPage` dalam tumpukan rute sehingga pengguna tidak dapat menekan tombol kembali ke keranjang yang sedang dalam status diproses.
2. **Ringkasan Pesanan (`CheckoutPage`)**:
   - Menampilkan kartu alamat pengiriman pemesan.
   - Mengambil ringkasan item dari `cartController.items` menggunakan `ListView.separated`.
   - Menampilkan rincian pembayaran: Total Harga Produk, Biaya Pengiriman (Gratis Promo), dan Total Tagihan Akhir.
3. **Simulasi Selesai Pembayaran (`OrderSuccessPage`)**:
   Saat tombol **"Bayar Sekarang"** ditekan, controller mengosongkan keranjang (`cartController.clearCart()`) dan berpindah menggunakan:
   ```dart
   Get.off(() => const OrderSuccessPage());
   ```
   Langkah ini mensimulasikan alur pembayaran e-commerce standar agar pengguna tidak dapat kembali ke halaman checkout untuk menghindari risiko duplikasi pembayaran (*double charging*). Dari halaman sukses, tombol *"Kembali ke Beranda"* menggunakan `Get.offAll(() => const MainPage())` untuk membersihkan riwayat tumpukan rute secara menyeluruh.

---

### 4. Buat tabel perbandingan antara pendekatan setState (yang dipakai pada Pertemuan 3 untuk status favorit) dan GetX (yang dipakai untuk keranjang) mencakup minimal tiga aspek.
**Jawaban:**

| Aspek Perbandingan | Pendekatan `setState` (Lokal - Pertemuan 3) | Pendekatan `GetX` (Global/Terpusat - Pertemuan 6) |
|:---|:---|:---|
| **1. Lingkup State (*Scope*)** | **State Lokal (Ephemeral/UI State)**: State hanya hidup di dalam satu widget turunan `StatefulWidget` tempat variabel dideklarasikan. Data tidak dapat dibagikan langsung ke widget atau halaman lain yang berada di cabang pohon (*widget tree*) yang berbeda tanpa teknik *lifting state up* yang rumit. | **State Global (App/Shared State)**: State disimpan secara terpusat pada `GetxController` di luar pohon widget. Data dapat diakses dan dimutasi dari halaman mana saja (`HomePage`, `ProductDetailPage`, `CartPage`, `CheckoutPage`) melalui `Get.find()`. |
| **2. Efisiensi & Granularitas Rebuild Tampilan** | **Rebuild Luas (Kurang Efisien)**: Pemanggilan `setState()` akan membangun ulang (*re-run build method*) seluruh pohon widget milik `StatefulWidget` tersebut, termasuk widget turunan yang tidak mengalami perubahan data. | **Rebuild Spesifik (Sangat Efisien & Granular)**: Hanya widget kecil yang secara spesifik dibungkus di dalam `Obx` dan mendengarkan variabel reaktif (`Rx`) terkait yang akan di-rebuild. Bagian UI lain di sekitarnya tidak mengalami rebuild sama sekali. |
| **3. Pemisahan Logika (*Separation of Concerns*)** | **Logika Bercampur dengan UI**: Logika manipulasi data, kalkulasi harga, dan mutasi variabel ditulis langsung bercampur di dalam class `State` bersamaan dengan definisi tampilan visual widget. | **Pemisahan Bersih (Arsitektur Terstruktur)**: Seluruh aturan bisnis (*business logic*), kalkulasi harga, diskon, dan manipulasi data diisolasi secara rapi di dalam `GetxController`. Tampilan UI menjadi bersih dan fokus hanya pada rendering tampilan visual. |
| **4. Ketergantungan terhadap `BuildContext`** | Membutuhkan `BuildContext` untuk hampir semua operasi (seperti `Navigator.of(context)`, `ScaffoldMessenger.of(context)`). | **Bebas `BuildContext`**: Navigasi (`Get.to`, `Get.back`, `Get.off`), dialog (`Get.defaultDialog`), dan snackbar (`Get.snackbar`) dapat dijalankan langsung dari controller tanpa memerlukan parameter `BuildContext`. |

---

### 5. Menurut pemahaman Anda, mengapa data keranjang TokoKita lebih tepat dikelola dengan GetX dibandingkan setState biasa, sementara status favorit pada ProductCard masih bisa menggunakan setState?
**Jawaban:**
Perbedaan penentuan pendekatan state management antara keranjang belanja dan status favorit didasarkan pada **karakteristik data**, **jangkauan widget (*scope*)**, dan **siklus hidup data (*lifecycle*)**:

1. **Mengapa Keranjang Belanja Lebih Tepat Menggunakan GetX?**
   - **Kebutuhan Akses Lintas Halaman (*Cross-Screen State*)**: Data keranjang belanja merupakan informasi global yang harus sinkron di banyak tempat secara bersamaan:
     - Badge jumlah barang pada header `HomePage`.
     - Badge jumlah barang pada bilah navigasi `MainPage` (`BottomNavigationBar`).
     - Badge jumlah barang pada `AppBar` di `ProductDetailPage`.
     - Tombol penambah item di `ProductDetailPage`.
     - Daftar belanjaan dan total nominal pada `CartPage`.
     - Rincian pesanan dan eksekusi pembayaran pada `CheckoutPage`.
   - Jika dikelola menggunakan `setState` biasa, pengembang terpaksa melakukan teknik *lifting state up* hingga ke widget paling atas (`MyApp` atau `MainPage`), lalu mengoper callback dan parameter secara manual menembus belasan lapis widget (*prop drilling*). Hal ini membuat kode sangat rapuh, sulit dirawat, dan memicu *unnecessary rebuild* pada seluruh aplikasi.
   - Dengan **GetX**, `CartController` bertindak sebagai *single source of truth*. Setiap perubahan data (tambah, ubah kuantitas, hapus) langsung menyiarkan pembaruan hanya ke widget yang dibungkus `Obx`, memastikan performa tinggi dan kode yang bersih.

2. **Mengapa Status Favorit pada `ProductCard` Masih Cukup Menggunakan `setState`?**
   - **Karakteristik Data Lokal (*Ephemeral State*)**: Status favorit (*love icon*) pada kartu produk individual merupakan interaksi visual lokal yang hanya berdampak langsung pada satu kartu spesifik tersebut (mengubah warna ikon hati dari abu-abu menjadi merah muda/merah).
   - Perubahan status favorit pada produk di baris ke-5 tidak memerlukan pembaruan pada header halaman, tidak mengubah badge keranjang, dan tidak memengaruhi halaman lain.
   - Menggunakan `setState` pada `ProductCard` (yang merupakan `StatefulWidget`) sudah sangat ideal, sederhana, ringan, dan tidak membutuhkan overhead pengelolaan controller terpisah.

---

## G. Panduan Singkat Menjelaskan Kode Saat Responsi / Ujian

Jika ditanya oleh dosen atau asisten laboratorium mengenai alur kode pada Pertemuan 6:

1. **Tiga Pilar Utama GetX pada TokoKita**:
   - **State Management**: Memisahkan logika keranjang ke `CartController`, membungkus item dengan `RxList.obs`, dan memantau perubahan otomatis dengan widget `Obx`.
   - **Route Management**: Navigasi tanpa `BuildContext` menggunakan `Get.to()` (membuka detail), `Get.back()` (tombol kembali), dan `Get.off()` (berpindah ke checkout/sukses tanpa kembali ke halaman sebelumnya).
   - **Dependency Management**: Mendaftarkan controller sekali di memori dengan `Get.put(CartController())` pada `MainPage`, kemudian memanggilnya kembali kapan pun dibutuhkan menggunakan `Get.find<CartController>()`.

2. **Bagaimana Reaktivitas Obx Bekerja?**:
   - Ketika data reaktif (seperti `items` bertipe `RxList`) dimutasi (misalnya melalui `addToCart` atau `increaseQuantity`), `RxList` mengirimkan notifikasi internal kepada *stream listener*.
   - Widget `Obx` yang membaca properti `totalItem` atau `totalHarga` akan mendeteksi notifikasi tersebut dan secara otomatis memicu metode `build` **hanya** pada blok widget tersebut, tanpa me-rebuild widget induk di sekitarnya.

3. **Perbedaan `Get.to()`, `Get.back()`, `Get.off()`, dan `Get.offAll()`**:
   - `Get.to(Page())`: Menumpuk halaman baru ke atas stack (mirip `Navigator.push`).
   - `Get.back()`: Menutup halaman aktif dan kembali ke halaman sebelumnya (mirip `Navigator.pop`).
   - `Get.off(Page())`: Mengganti halaman aktif saat ini dengan halaman baru (mirip `Navigator.pushReplacement`), digunakan pada tombol Checkout dan Pembayaran Selesai.
   - `Get.offAll(Page())`: Menghapus seluruh tumpukan halaman yang ada dan menjadikan halaman baru sebagai root (mirip `Navigator.pushAndRemoveUntil`), digunakan saat kembali ke Beranda setelah checkout berhasil.
