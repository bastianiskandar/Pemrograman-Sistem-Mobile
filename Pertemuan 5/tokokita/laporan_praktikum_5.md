# LAPORAN PRAKTIKUM PEMROGRAMAN MOBILE
## Pertemuan 5 — Navigasi & Routing

---

### Informasi Mahasiswa
- **Mata Kuliah** : Pemrograman Mobile
- **Pertemuan**   : Pertemuan 5
- **Topik**       : Navigasi & Routing (Navigator, Named Routes, Bottom Navigation, & Alternatif go_router)
- **Studi Kasus** : TokoKita — Navigasi ke Halaman Detail Produk & Bottom Navigation
- **Framework**   : Flutter (Dart)

---

## A. Ringkasan Implementasi Langkah Kerja

### 1. Langkah 1 — Halaman Detail Produk & Navigator Dasar (`lib/screens/product_detail_page.dart`)
- Membuat berkas baru `lib/screens/product_detail_page.dart` yang menerima data objek `Product`.
- Menampilkan informasi lengkap produk meliputi nama produk, harga (lengkap dengan perlakuan harga diskon/coret jika bertipe `DiscountedProduct`), tag kategori (`CategoryTag`), status stok (`StockBadge` dan jumlah unit), serta deskripsi produk.
- Menambahkan tombol *back* pada `AppBar` yang memanggil `Navigator.pop(context)` untuk kembali ke halaman sebelumnya (`HomePage`).
- Menambahkan parameter callback `onTap` pada `ProductCard` (`lib/widgets/product_card.dart`) yang dibungkus dengan `Material` dan `InkWell` untuk mendeteksi sentuhan pengguna dengan efek riak air (*ink splash*).

### 2. Langkah 2 — Named Routes untuk TokoKita (`lib/main.dart`)
- Mendefinisikan pemetaan rute terpusat (*named routes*) pada properti `routes` di `MaterialApp`:
  ```dart
  initialRoute: '/',
  routes: {
    '/': (context) => const MainPage(),
    '/detail': (context) => const ProductDetailPage(),
    '/cart': (context) => const CartPage(),
  },
  ```
- Mengubah navigasi langsung berbasis `MaterialPageRoute` menjadi navigasi deklaratif berbasis nama rute menggunakan:
  ```dart
  Navigator.pushNamed(
    context,
    '/detail',
    arguments: product,
  );
  ```
- Pada `ProductDetailPage`, data produk diekstrak secara dinamis melalui `ModalRoute.of(context)?.settings.arguments as Product?` dengan *fallback* ke parameter konstruktor langsung.

### 3. Langkah 3 — Mengirim & Menerima Data Produk Antar Halaman
- Memastikan objek `Product` yang dipilih pada `HomePage` terkirim secara utuh ke `ProductDetailPage` melalui *route arguments*.
- Menambahkan tombol **"Tambah ke Keranjang"** pada `ProductDetailPage` yang mengembalikan data jumlah item (`_quantity`) ke `HomePage` melalui perintah:
  ```dart
  Navigator.pop(context, _quantity);
  ```
- Pada `HomePage`, nilai kembalian ditangkap secara *asynchronous* menggunakan `await` pada pemanggilan `Navigator.pushNamed`, kemudian menampilkan notifikasi mengambang (`SnackBar`) berwarna biru khas TokoKita:
  ```dart
  final result = await Navigator.pushNamed(context, '/detail', arguments: product);
  if (result != null && result is int && context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Berhasil menambahkan $result item "${product.name}" ke keranjang!'),
      ),
    );
  }
  ```

### 4. Langkah 4 — Pengantar go_router
- Mengamati arsitektur deklaratif modern menggunakan package `go_router` yang berjalan di atas Flutter Navigator 2.0 (Router API).
- Mempelajari struktur konfigurasi `GoRouter` yang mendefinisikan URL/path berbasis URI seperti `/`, `/products/:id`, sub-routes, serta parameter `builder: (context, state)`.
- Mengidentifikasi perbedaan konseptual antara Navigator 1.0 (imperatif: stack push/pop manual) dengan `go_router` (deklaratif: sinkronisasi state aplikasi dan URL secara otomatis, dukungan deep linking, dan penanganan parameter URL yang terstruktur).

### 5. Langkah 5 — Kerangka Bottom Navigation TokoKita (`lib/screens/main_page.dart`)
- Membuat berkas baru `lib/screens/main_page.dart` sebagai kerangka utama aplikasi yang memiliki `BottomNavigationBar` dengan 3 tab menu:
  1. **Beranda** (ikon `Icons.home_outlined` / `Icons.home_rounded`) -> Terhubung ke `HomePage`.
  2. **Keranjang** (ikon `Icons.shopping_cart_outlined` / `Icons.shopping_cart_rounded`) -> Terhubung ke `CartPage`.
  3. **Profil** (ikon `Icons.person_outline_rounded` / `Icons.person_rounded`) -> Terhubung ke `ProfilePage`.
- Menggunakan widget `IndexedStack` pada `body` `MainPage` agar *state* dan posisi *scroll* pada halaman daftar produk `HomePage` tetap terjaga saat pengguna berpindah-pindah tab.
- Menghubungkan ikon keranjang pada header kanan atas `HomePage` (dan `ProductDetailPage`) agar ketika ditekan langsung berpindah secara mulus ke tab Keranjang (`CartPage`), serta mendaftarkan rute named route `'/cart'`.
- Menjadikan `MainPage` sebagai rute awal aplikasi (`initialRoute: '/'`) di `MaterialApp`.

---

## E. Tabel Hasil Pengamatan

| No. | Skenario Navigasi | Hasil/Perilaku yang Diamati | Screenshot (Ya/Tidak) |
|:---:|:---|:---|:---:|
| **1** | Navigasi HomePage ke ProductDetailPage | Saat salah satu kartu `ProductCard` ditekan, layar melakukan transisi halus (*push*) membuka `ProductDetailPage`. Halaman detail menampilkan gambar besar produk, badge diskon, status stok, harga, dan deskripsi sesuai produk yang dipilih. Tombol panah kembali (*back button*) pada `AppBar` berhasil melakukan `pop` kembali ke `HomePage`. | Ya |
| **2** | Navigasi via named routes | Pemanggilan `Navigator.pushNamed(context, '/detail', arguments: product)` berhasil memicu rute `'/detail'` yang terdaftar pada properti `routes` di `MaterialApp`. Transisi dan data yang diterima identik dengan navigasi langsung, namun kode menjadi lebih rapi, terpusat, dan terstruktur. | Ya |
| **3** | Kirim data produk & terima nilai kembalian | Objek `Product` berhasil diterima oleh `ProductDetailPage`. Pengguna dapat menambah/mengurangi kuantitas produk, lalu menekan tombol **"Tambah ke Keranjang"**. Halaman detail ditutup dan mengembalikan angka kuantitas via `Navigator.pop(context, _quantity)`. Di `HomePage`, sebuah `SnackBar` muncul menampilkan pesan konfirmasi jumlah item yang berhasil ditambahkan. | Ya |
| **4** | Perpindahan antar tab bottom navigation | Menekan ikon pada `BottomNavigationBar` mengubah indeks aktif dan memperbarui tampilan layar ke halaman Beranda, Keranjang, atau Profil tanpa *lag*. Penggunaan `IndexedStack` memastikan daftar produk di Beranda tidak ter-*reset* atau memuat ulang dari awal. | Ya |
| **5** | MainPage sebagai halaman awal aplikasi | Saat aplikasi pertama kali dijalankan, rute `'/'` langsung memuat `MainPage` dengan tab Beranda (`HomePage`) aktif secara *default*, lengkap dengan bilah navigasi bawah (*bottom bar*) yang siap digunakan. | Ya |

---

## F. Jawaban Tugas Mandiri

### 1. Lengkapi ProductDetailPage TokoKita dengan tampilan yang lebih rapi (gunakan widget layout dari Pertemuan 4) beserta tombol tambah/kurang jumlah sebelum ditambahkan ke keranjang.
**Jawaban:**
Tampilan `ProductDetailPage` pada berkas `lib/screens/product_detail_page.dart` telah disusun secara komprehensif memanfaatkan widget layout dari Pertemuan 4:
1. **Header Produk (`Stack` & `Positioned`)**:
   - Membungkus kontainer gambar ikon produk dengan `Stack`.
   - Menempatkan **Badge Diskon** di pojok kanan atas menggunakan `Positioned` (otomatis aktif jika produk merupakan instansiasi `DiscountedProduct`).
   - Menempatkan **Badge Status Stok** (`StockBadge`) di pojok kiri bawah menggunakan `Positioned`.
2. **Informasi Produk (`Container`, `Row`, & `Column`)**:
   - Kontainer informasi produk dilengkapi dengan sudut membulat (`borderRadius: 16`), batas halus (*subtle border*), dan bayangan lembut (*boxShadow*).
   - Menampilkan `CategoryTag`, nama produk, pemformatan harga satuan (harga coret jika diskon), status ketersediaan stok, dan deskripsi lengkap.
3. **Pengatur Kuantitas Pesanan (*Quantity Counter*)**:
   - Menggunakan komponen interaktif dengan tombol minus (`-`), tampilan angka kuantitas (`_quantity`), dan tombol plus (`+`).
   - Logika batas stok: tombol minus dinonaktifkan jika jumlah $\le 1$, dan tombol plus memiliki validasi agar kuantitas tidak melebihi sisa stok riil (`product.stock`). Jika stok habis (`stock <= 0`), kuantitas terkunci pada angka 0 dan tombol dinonaktifkan.
   - Bagian bawah menampilkan ringkasan kalkulasi total harga dinamis ($\text{Harga Final} \times \text{Kuantitas}$) secara seketika (*real-time*).

### 2. Pastikan seluruh navigasi pada TokoKita (HomePage → Detail → kembali) menggunakan named routes secara konsisten.
**Jawaban:**
Seluruh alur navigasi aplikasi telah distandarisasi menggunakan *named routes*:
- **Pendaftaran Rute**: Pada `lib/main.dart`, didaftarkan dua rute utama:
  ```dart
  initialRoute: '/',
  routes: {
    '/': (context) => const MainPage(),
    '/detail': (context) => const ProductDetailPage(),
  },
  ```
- **Navigasi Maju (Forward)**: Pada `lib/screens/home_page.dart`, kartu produk memicu navigasi menggunakan:
  ```dart
  final result = await Navigator.pushNamed(
    context,
    '/detail',
    arguments: product,
  );
  ```
- **Navigasi Mundur (Backward)**:
  - Tombol *back* di `AppBar` memanggil `Navigator.pop(context)` (kembali tanpa membawa data belanja).
  - Tombol *"Tambah ke Keranjang"* memanggil `Navigator.pop(context, _quantity)` (kembali dengan membawa data nilai kembalian berupa jumlah kuantitas pesanan).

### 3. Buat halaman placeholder Keranjang dan Profil pada bottom navigation agar masing-masing menampilkan judul dan pesan sederhana yang berbeda.
**Jawaban:**
Telah dibuat dua berkas halaman terpisah yang memiliki identitas visual dan pesan kontekstual yang spesifik:
1. **`lib/screens/cart_page.dart` (Halaman Keranjang)**:
   - Judul AppBar: *"Keranjang Belanja"*.
   - Konten: Ilustrasi keranjang belanja dengan latar lingkaran biru lembut, judul *"Keranjang Belanja Masih Kosong"*, serta pesan panduan *"Anda belum memiliki item di keranjang belanja. Buka tab Beranda, pilih produk yang Anda inginkan, lalu tekan 'Tambah ke Keranjang' untuk mulai berbelanja."*.
   - Dilengkapi tombol aksi cepat *"Jelajahi Produk Sekarang"* yang mengalihkan tab kembali ke Beranda, serta *chip* status placeholder Pertemuan 5.
2. **`lib/screens/profile_page.dart` (Halaman Profil)**:
   - Judul AppBar: *"Profil Saya"*.
   - Konten: Kartu profil pengguna berisi `CircleAvatar` dengan badge status verifikasi aktif, nama (*"Mahasiswa Pemrograman Mobile"*), email (*"mahasiswa@tokokita.ac.id"*), dan badge status *Member Aktif*.
   - Dilengkapi daftar menu interaktif (`ListTile`) berupa *"Riwayat Pesanan"*, *"Alamat Pengiriman"*, *"Pengaturan Akun"*, dan *"Bantuan & FAQ"*, serta informasi integrasi fitur pada pertemuan selanjutnya.

### 4. Jelaskan perbedaan antara Navigator.push, Navigator.pushReplacement, dan Navigator.pushAndRemoveUntil beserta contoh kasus penggunaan masing-masing pada konteks aplikasi TokoKita (misalnya alur setelah checkout).
**Jawaban:**

| Metode Navigasi | Cara Kerja pada Stack Halaman | Contoh Kasus Penggunaan pada TokoKita |
|:---|:---|:---|
| **`Navigator.push`** | Menambahkan (*push*) halaman baru ke atas tumpukan (*stack*) tanpa menghapus halaman sebelumnya. Pengguna dapat menekan tombol *back* untuk kembali ke halaman asal. | **Membuka Detail Produk:** Pengguna berada di `HomePage`, kemudian menekan kartu produk untuk membuka `ProductDetailPage`. Halaman detail ditumpuk di atas Beranda, sehingga pengguna bisa menekan tombol kembali untuk melanjutkan melihat katalog produk. |
| **`Navigator.pushReplacement`** | Menggantikan halaman saat ini pada puncak *stack* dengan halaman baru. Halaman lama dihapus (*dispose*) dari *stack*, sehingga tombol *back* pada halaman baru akan kembali ke halaman di bawah halaman yang digantikan. | **Proses Autentikasi / Splash Screen:** Dari `SplashScreen` berpindah ke `LoginPage`, atau setelah pengguna menekan tombol *"Masuk"* pada `LoginPage`, aplikasi melakukan `pushReplacement` menuju `MainPage`. Pengguna tidak boleh kembali ke halaman login saat menekan tombol *back*. |
| **`Navigator.pushAndRemoveUntil`** | Membuka halaman baru sekaligus membersihkan sebagian atau seluruh tumpukan halaman sebelumnya berdasarkan kondisi predikat (*route predicate*). | **Alur Selesai Checkout / Pembayaran:** Setelah pengguna menyelesaikan transaksi belanja pada alur panjang (`HomePage` $\rightarrow$ `Detail` $\rightarrow$ `Keranjang` $\rightarrow$ `Checkout` $\rightarrow$ `PembayaranSuksesPage`), kita memanggil: <br>`Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const MainPage()), (route) => false);`<br> Seluruh riwayat transaksi di-*clear* total dari memori stack, sehingga saat tombol *back* ditekan, pengguna tidak kembali ke form pembayaran yang sudah dibayar melainkan langsung keluar aplikasi atau tetap di Beranda utama. |

### 5. Menurut pemahaman Anda, dalam situasi seperti apa penggunaan go_router lebih menguntungkan dibandingkan Navigator dasar untuk aplikasi sekelas TokoKita yang terus berkembang?
**Jawaban:**
Penggunaan package **`go_router`** jauh lebih menguntungkan dibandingkan Navigator dasar (Navigator 1.0) pada kondisi-kondisi perkembangan aplikasi e-commerce modern sebagai berikut:
1. **Dukungan Deep Linking & URL Dinamis (Web & Mobile)**:
   Pada aplikasi e-commerce yang berkembang, tautan promosi sering dibagikan melalui media sosial, SMS, atau email (misalnya: `tokokita.id/products/101` atau `tokokita.id/promo?code=DISKON10`). Dengan Navigator dasar, menangani parsing URL, query parameters, dan parameter rute dinamis sangat rumit. `go_router` menangani *path parameters* (`/products/:id`) dan *query parameters* secara otomatis dan deklaratif.
2. **Sinkronisasi Otomatis Antara URL Bar dan Tampilan (Flutter Web/Desktop)**:
   Pada platform Web, jika pengguna menekan tombol *Back* atau *Forward* bawaan *browser* atau menyalin tautan di bilah alamat, `go_router` secara bawaan menyelaraskan URL dengan *state* halaman. Navigator 1.0 sering mengalami desinkronisasi URL pada Flutter Web.
3. **Stateful Nested Navigation / ShellRoute untuk Bottom Navigation**:
   Pada aplikasi besar dengan bilah navigasi bawah, pengguna mengharapkan masing-masing tab memiliki riwayat tumpukan halamannya sendiri (*independent navigation stack*). `go_router` menyediakan fitur `StatefulShellRoute` yang sangat elegan untuk mengelola navigasi bertingkat di dalam tab tanpa kode boilerplate yang rumit.
4. **Redirection & Route Guards (Manajemen Autentikasi Terpusat)**:
   Jika TokoKita memiliki halaman khusus member (misal: `/checkout` atau `/profile`), `go_router` menyediakan properti `redirect` terpusat. Sebelum rute dibuka, aplikasi dapat memeriksa apakah pengguna sudah login atau token autentikasi valid. Jika belum, pengguna dialihkan otomatis ke `/login` tanpa perlu menulis logika pengecekan berulang di setiap widget halaman.

---

## G. Panduan Singkat Menjelaskan Kode Saat Responsi / Ujian

Jika ditanya oleh dosen atau asisten laboratorium mengenai alur kode pada Pertemuan 5:
1. **Alur Navigasi Named Route (`main.dart` & `home_page.dart`)**:
   - Jelaskan bahwa semua rute didaftarkan di `main.dart` pada `MaterialApp(routes: {...})`.
   - Navigasi dipanggil dari kartu produk via `Navigator.pushNamed(context, '/detail', arguments: product)`.
   - Data produk diekstrak di `ProductDetailPage` menggunakan `ModalRoute.of(context)!.settings.arguments as Product`.
2. **Alur Pengembalian Nilai (*Return Value*)**:
   - Jelaskan bahwa `Navigator.pushNamed` mengembalikan objek `Future`.
   - Di `ProductDetailPage`, saat tombol *"Tambah ke Keranjang"* ditekan, kita mengeksekusi `Navigator.pop(context, _quantity)`.
   - Nilai kuantitas diterima oleh `await` di `HomePage`, lalu ditampilkan melalui `ScaffoldMessenger.of(context).showSnackBar()`.
3. **Arsitektur Bottom Navigation (`main_page.dart`)**:
   - Jelaskan bahwa `MainPage` memegang *state* `_currentIndex` untuk mengontrol tab aktif pada `BottomNavigationBar`.
   - Penggunaan `IndexedStack` penting untuk mencegah pemuatan ulang (*rebuild*) dan mempertahankan posisi gulir (*scroll position*) pada halaman Beranda saat berpindah tab ke Keranjang atau Profil.
