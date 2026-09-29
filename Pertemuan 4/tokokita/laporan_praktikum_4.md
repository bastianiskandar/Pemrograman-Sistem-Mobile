# LAPORAN PRAKTIKUM PEMROGRAMAN MOBILE
## Pertemuan 4 — Layout & UI (Row, Column, Container, Stack, ListView)

---

### Informasi Mahasiswa
- **Mata Kuliah** : Pemrograman Mobile
- **Pertemuan**   : Pertemuan 4
- **Topik**       : Layout & UI (Row, Column, Container, Stack, ListView)
- **Studi Kasus** : TokoKita — Menyusun Halaman Utama (Daftar Produk)
- **Framework**   : Flutter (Dart)

---

## A. Ringkasan Implementasi Langkah Kerja

### 1. Langkah 1 — App Bar Sederhana dengan Row & Column (`lib/screens/home_page.dart`)
- Membuat berkas baru `lib/screens/home_page.dart`.
- Menggunakan `Row` dengan properti `mainAxisAlignment: MainAxisAlignment.spaceBetween` untuk memposisikan judul toko di sisi kiri dan ikon keranjang belanja di sisi kanan.
- Menggunakan `Column` dengan properti `crossAxisAlignment: CrossAxisAlignment.start` untuk menyusun teks nama toko (`TokoKita`) dan subjudul (`Belanja jadi lebih mudah`) secara vertikal dan rata kiri.

### 2. Langkah 2 — Mempercantik ProductCard dengan Container (`lib/widgets/product_card.dart`)
- Membungkus tampilan kartu produk menggunakan `Container`.
- Memberikan `margin: EdgeInsets.symmetric(horizontal: 14, vertical: 6)` untuk jarak antar kartu.
- Memberikan `padding: EdgeInsets.all(12)` untuk memberi ruang antara konten dan tepi kartu.
- Mengatur `decoration: BoxDecoration` dengan `color: Colors.white`, `borderRadius: BorderRadius.circular(12)`, dan `boxShadow: [BoxShadow(color: Colors.black.withAlpha(15), blurRadius: 6, offset: Offset(0, 3))]` sehingga kartu tampak sedikit terangkat (elevasi halus).

### 3. Langkah 3 & Tugas Mandiri 2 — Badge Diskon & Status Stok dengan Stack & Positioned
- Membungkus gambar/placeholder ikon produk dengan widget `Stack`.
- **Badge Diskon**: Ditempatkan di pojok kanan atas gambar menggunakan `Positioned(top: 4, right: 4, child: ...)`. Hanya ditampilkan jika produk merupakan turunan dari `DiscountedProduct`.
- **Badge Status Stok**: Ditempatkan di posisi berbeda yaitu di pojok kiri bawah gambar menggunakan `Positioned(bottom: 4, left: 4, child: StockBadge(...))` untuk memenuhi Tugas Mandiri 2.

### 4. Langkah 4 — Menampilkan Daftar Produk dengan ListView.builder
- Menggunakan data produk dari `lib/models/product.dart` yang telah diperluas menjadi 20 item produk dummy (kombinasi `Product` dan `DiscountedProduct`).
- Menggunakan `ListView.builder` dengan `itemCount: productList.length` dan `itemBuilder` yang me-render satu `ProductCard` untuk setiap item secara dinamis dan efisien.

### 5. Langkah 5 — Menata Ruang dengan Expanded & Flexible
- Pada baris utama `ProductCard`, kolom teks (nama, deskripsi, tag kategori, harga) dibungkus menggunakan `Expanded`.
- Dengan `Expanded`, kolom teks otomatis menghitung dan mengisi sisa ruang yang tersedia di samping gambar tanpa mendorong elemen keluar layar.
- Menggunakan `TextOverflow.ellipsis` dan `maxLines: 1` pada teks judul untuk memastikan tidak ada overflow pada layar sempit.
- Menjadikan `HomePage` sebagai halaman utama pada `MaterialApp` di `lib/main.dart`:
  ```dart
  home: const HomePage(),
  ```

---

## E. Tabel Hasil Pengamatan

| No. | Widget/Kombinasi yang Diuji | Hasil/Perilaku yang Diamati | Screenshot (Ya/Tidak) |
|:---:|:---|:---|:---:|
| **1** | Header halaman dengan Row & Column | Judul dan subjudul toko tersusun rapi secara vertikal di sisi kiri, sedangkan ikon keranjang belanja berada di sisi kanan dengan jarak maksimal di antaranya berkat `MainAxisAlignment.spaceBetween`. | Ya |
| **2** | ProductCard dengan Container & shadow | Kartu produk memiliki sudut membulat (`borderRadius: 12`), jarak antar kartu yang konsisten (`margin`), dan bayangan lembut (`boxShadow`) yang memberi ilusi kartu terangkat dari latar belakang. | Ya |
| **3** | Badge diskon dengan Stack & Positioned | Badge diskon berwarna merah menempel tepat di pojok kanan atas gambar produk berdiskon tanpa menggeser posisi gambar di bawahnya. | Ya |
| **4** | Daftar produk dengan ListView.builder | Daftar 20 produk ditampilkan secara bergulir (scrollable) dengan halus. Hanya elemen yang masuk area pandang (viewport) yang dirender ke memori (lazy loading). | Ya |
| **5** | Layout ProductCard dengan Expanded | Kolom informasi produk secara fleksibel menyesuaikan lebar layar yang tersisa di samping gambar, sehingga teks tidak terpotong kasar ataupun menyebabkan garis batas kuning-hitam (overflow). | Ya |

---

## F. Jawaban Tugas Mandiri

### 1. Sempurnakan tampilan HomePage TokoKita agar menampilkan minimal 15 produk dummy melalui ListView.builder tanpa terjadi overflow.
**Jawaban:**
Pada berkas `lib/models/product.dart`, daftar `dummyProducts` telah ditambahkan hingga berjumlah **20 produk dummy** dengan data yang variatif, mencakup 3 kategori (`Elektronik`, `Fashion`, `Makanan`), sebagian memiliki diskon (`DiscountedProduct`), serta memiliki variasi stok (Tersedia, Stok Terbatas, dan Habis). Seluruh produk dirender menggunakan `ListView.builder` di `HomePage` dan tidak terjadi render overflow pada resolusi layar apa pun.

### 2. Tambahkan badge status stok (dari Pertemuan 2/3) pada ProductCard menggunakan kombinasi Stack dan Positioned di posisi yang berbeda dari badge diskon.
**Jawaban:**
Pada `lib/widgets/product_card.dart`, bagian gambar/placeholder produk dibungkus dengan widget `Stack`. Dua badge diposisikan secara independen:
1. **Badge Diskon**: `Positioned(top: 4, right: 4, ...)` di pojok kanan atas gambar (hanya untuk produk berdiskon).
2. **Badge Status Stok**: `Positioned(bottom: 4, left: 4, child: StockBadge(status: widget.product.getStatusStok()))` di pojok kiri bawah gambar.
Dengan tata letak ini, kedua informasi penting tampil langsung di atas gambar produk secara rapi tanpa saling bertumpuk.

### 3. Jelaskan perbedaan antara Expanded dan Flexible beserta bagian mana pada ProductCard TokoKita yang menggunakan masing-masing (jika ada).
**Jawaban:**
- **Perbedaan Mendasar:**
  - `Expanded` adalah pembungkus yang memaksa widget anaknya untuk **mengambil seluruh sisa ruang kosong** yang tersedia di sepanjang sumbu utama (main axis) dari `Row` atau `Column`. Sifat bawaannya setara dengan `Flexible(fit: FlexFit.tight)`.
  - `Flexible` memberikan kebebasan kepada widget anak untuk berukuran **sesuai kebutuhan kontennya sendiri**, tetapi tidak boleh melebihi batas ruang yang dialokasikan (`fit: FlexFit.loose` secara default).
- **Penggunaan pada TokoKita:**
  - Pada `ProductCard`, widget `Expanded` digunakan untuk membungkus `Column` informasi produk (nama, deskripsi, tag kategori, harga). Hal ini dilakukan agar kolom tersebut meregang mengisi seluruh sisa lebar ruang horizontal antara gambar di sisi kiri dan tombol aksi di sisi kanan.
  - Widget `Flexible` digunakan pada elemen baris harga di dalam `ProductCard` (harga awal yang dicoret dan harga diskon) agar teks harga dapat menyesuaikan ruang secara proporsional sesuai kontennya tanpa memaksakan ruang penuh (`fit: FlexFit.loose`) dan mencegah overflow pada layar sempit.

### 4. Jelaskan mengapa ListView.builder lebih disarankan dibandingkan ListView biasa untuk menampilkan daftar produk pada TokoKita, dikaitkan dengan konsep lazy loading.
**Jawaban:**
- **ListView biasa (`ListView(children: [...])`)** akan menginisialisasi dan membangun seluruh widget anak sekaligus saat halaman pertama kali dimuat, meskipun item tersebut berada jauh di bawah layar dan belum terlihat oleh pengguna. Jika jumlah produk ada ratusan atau ribuan, ini akan memboroskan memori RAM dan menyebabkan penurunan performa (frame rate drop / lag).
- **ListView.builder** menerapkan konsep **lazy loading (on-demand rendering)**: widget anak hanya akan dibangun (`itemBuilder` dipanggil) ketika item tersebut mendekati atau masuk ke dalam area pandang layar (viewport). Ketika item digulir ke luar layar, widget tersebut dapat didaur ulang. Hal ini membuat aplikasi TokoKita tetap cepat, ringan, dan hemat memori berapa pun jumlah produk yang ada.

### 5. Menurut pengamatan Anda pada Langkah 5, tantangan apa yang paling sering menyebabkan overflow pada ProductCard, dan bagaimana Anda mengatasinya?
**Jawaban:**
- **Penyebab Utama Overflow:**
  Dalam sebuah `Row`, widget teks atau elemen yang lebarnya tidak dibatasi secara alami akan meminta lebar sebesar panjang teksnya. Jika judul produk atau deskripsinya panjang dan gambar sudah mengambil lebar tetap (misalnya 85px), maka lebar total melebihi lebar layar gawai, menghasilkan pesan galat **"A RenderFlex overflowed by ... pixels"** (garis kuning-hitam).
- **Cara Mengatasinya:**
  1. Membungkus `Column` yang memuat teks dengan widget `Expanded` di dalam `Row`, sehingga `Column` dipaksa memiliki batas lebar maksimal sebesar sisa ruang layar.
  2. Memberikan properti `overflow: TextOverflow.ellipsis` dan `maxLines: 1` (atau 2) pada widget `Text`, sehingga jika nama produk terlalu panjang, teks yang melebihi batas akan digantikan dengan tanda titik-titik tiga (`...`) secara anggun tanpa merusak tampilan UI.

---

## G. Panduan Singkat Menjelaskan Kode Saat Responsi / Ujian

Jika ditanya oleh dosen atau asisten laboratorium mengenai alur kode:
1. **Struktur Halaman Utama (`home_page.dart`)**:
   > *"Di `home_page.dart`, kami menggunakan `SafeArea` dan `Column` utama. Bagian atas adalah header kustom menggunakan `Row` dengan `spaceBetween` untuk nama toko dan keranjang belanja. Bagian bawahnya adalah `Expanded` yang memuat `ListView.builder` agar daftar produk dapat digulir dan memanfaatkan lazy loading."*
2. **Struktur Kartu Produk (`product_card.dart`)**:
   > *"Di `product_card.dart`, pembungkus terluar adalah `Container` dengan dekorasi bayangan (`BoxShadow`) dan sudut melengkung. Di dalamnya ada `Row` yang berisi gambar dan `Expanded` kolom teks. Pada gambar produk, kami menggunakan `Stack` dengan dua `Positioned`: pojok kanan atas untuk badge diskon dan pojok kiri bawah untuk badge status stok."*
3. **Mengapa Pakai Expanded**:
   > *"Agar teks nama dan harga produk tidak menyebabkan render overflow ketika dibuka di layar ponsel yang lebih sempit."*
