import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../models/order.dart';
import '../models/product.dart';
import '../services/order_database.dart';

/// OrderHistoryPage — Halaman riwayat pesanan yang menyimpan dan menampilkan data
/// transaksi menggunakan basis data SQLite/sqflite (Pertemuan 9 — Langkah 4 & Tugas Mandiri 3).
class OrderHistoryPage extends StatefulWidget {
  const OrderHistoryPage({super.key});

  @override
  State<OrderHistoryPage> createState() => _OrderHistoryPageState();
}

class _OrderHistoryPageState extends State<OrderHistoryPage> {
  bool _isLoading = true;
  List<Order> _orders = [];

  // Filter status aktif ('Semua', 'Diproses', 'Selesai', 'Dibatalkan')
  String _selectedStatus = 'Semua';
  final List<String> _statusOptions = ['Semua', 'Diproses', 'Selesai', 'Dibatalkan'];

  // Controller untuk input pencarian (Tugas Mandiri 3)
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// Langkah 4 Butir 2 & Tugas Mandiri 3: Mengambil riwayat pesanan dari SQLite dengan WHERE clause
  Future<void> _loadOrders() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final statusFilter = _selectedStatus == 'Semua' ? null : _selectedStatus;
      final keyword = _searchController.text.trim();

      final results = await OrderDatabase.instance
          .searchOrders(
            status: statusFilter,
            keyword: keyword.isEmpty ? null : keyword,
          )
          .timeout(const Duration(seconds: 4));

      if (mounted) {
        setState(() {
          _orders = results;
        });
      }
    } catch (e) {
      debugPrint('[OrderHistoryPage] Gagal memuat data pesanan: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  /// Langkah 4 Butir 3: Mengubah status pesanan di SQLite
  Future<void> _updateStatus(Order order, String newStatus) async {
    if (order.id == null) return;
    await OrderDatabase.instance.updateOrderStatus(order.id!, newStatus);
    await _loadOrders();

    if (mounted) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Status Pesanan #${order.id} diperbarui menjadi: $newStatus'),
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  /// Dialog pemilihan status baru
  void _showUpdateStatusDialog(Order order) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(
            'Ubah Status Pesanan #${order.id}',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: ['Diproses', 'Selesai', 'Dibatalkan'].map((status) {
              final isCurrent = order.status == status;
              return ListTile(
                title: Text(status),
                leading: Icon(
                  isCurrent ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                  color: isCurrent ? const Color(0xFF1976D2) : const Color(0xFF94A3B8),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _updateStatus(order, status);
                },
              );
            }).toList(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal'),
            ),
          ],
        );
      },
    );
  }

  /// Langkah 4 Butir 4: Menghapus pesanan dari SQLite dengan konfirmasi
  Future<void> _confirmDeleteOrder(Order order) async {
    if (order.id == null) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Hapus Riwayat Pesanan?',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
        content: Text(
          'Apakah Anda yakin ingin menghapus data pesanan #${order.id}? Data yang dihapus tidak dapat dipulihkan.',
          style: const TextStyle(fontSize: 13.5, color: Color(0xFF64748B)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
              foregroundColor: Colors.white,
            ),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await OrderDatabase.instance.deleteOrder(order.id!);
      await _loadOrders();

      if (mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Pesanan #${order.id} berhasil dihapus dari basis data.'),
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'selesai':
        return const Color(0xFF16A34A); // Hijau
      case 'diproses':
        return const Color(0xFFF59E0B); // Amber / Kuning
      case 'dibatalkan':
        return const Color(0xFFEF4444); // Merah
      default:
        return const Color(0xFF64748B);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          'Riwayat Pesanan',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1E293B),
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          color: const Color(0xFF1E293B),
          onPressed: () => Get.back(),
        ),
      ),
      body: Column(
        children: [
          // ===================================================================
          // TUGAS MANDIRI 3: FORM PENCARIAN & FILTER STATUS (WHERE CLAUSE)
          // ===================================================================
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: Colors.white,
            child: Column(
              children: [
                // Input Pencarian
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Cari barang atau tanggal pesanan...',
                    hintStyle: const TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
                    prefixIcon: const Icon(Icons.search, size: 20, color: Color(0xFF64748B)),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, size: 18),
                            onPressed: () {
                              _searchController.clear();
                              _loadOrders();
                            },
                          )
                        : null,
                    contentPadding: const EdgeInsets.symmetric(vertical: 10),
                    isDense: true,
                    filled: true,
                    fillColor: const Color(0xFFF1F5F9),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  onChanged: (val) {
                    _loadOrders();
                  },
                ),
                const SizedBox(height: 10),

                // Chips Filter Status
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: _statusOptions.map((status) {
                      final isSelected = _selectedStatus == status;
                      final chipColor = status == 'Semua'
                          ? const Color(0xFF1976D2)
                          : _getStatusColor(status);

                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text(
                            status,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: isSelected ? Colors.white : chipColor,
                            ),
                          ),
                          selected: isSelected,
                          selectedColor: chipColor,
                          backgroundColor: chipColor.withAlpha(20),
                          side: BorderSide(
                            color: isSelected ? chipColor : chipColor.withAlpha(60),
                          ),
                          onSelected: (selected) {
                            if (selected) {
                              setState(() {
                                _selectedStatus = status;
                              });
                              _loadOrders();
                            }
                          },
                          showCheckmark: false,
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),

          // ===================================================================
          // LISTVIEW RIWAYAT PESANAN (LANGKAH 4 BUTIR 2)
          // ===================================================================
          Expanded(
            child: _isLoading
                ? const Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 12),
                        Text(
                          'Memuat data pesanan dari SQLite...',
                          style: TextStyle(fontSize: 13, color: Color(0xFF64748B)),
                        ),
                      ],
                    ),
                  )
                : _orders.isEmpty
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF1F5F9),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.receipt_long_outlined,
                                  size: 40,
                                  color: Color(0xFF94A3B8),
                                ),
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                'Tidak Ada Riwayat Pesanan',
                                style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF1E293B),
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                _searchController.text.isNotEmpty || _selectedStatus != 'Semua'
                                    ? 'Tidak ditemukan pesanan dengan kriteria pencarian tersebut.'
                                    : 'Pesanan yang Anda lakukan akan tersimpan secara lokal di sini.',
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: Color(0xFF64748B),
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _loadOrders,
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _orders.length,
                          itemBuilder: (context, index) {
                            final order = _orders[index];
                            final statusColor = _getStatusColor(order.status);

                            return Container(
                              margin: const EdgeInsets.only(bottom: 14),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(color: const Color(0xFFE2E8F0)),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withAlpha(6),
                                    blurRadius: 6,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Baris Atas: ID & Status Badge
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.all(6),
                                              decoration: BoxDecoration(
                                                color: const Color(0xFFEFF6FF),
                                                borderRadius: BorderRadius.circular(6),
                                              ),
                                              child: const Icon(
                                                Icons.receipt_rounded,
                                                size: 16,
                                                color: Color(0xFF1976D2),
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              'Pesanan #${order.id}',
                                              style: const TextStyle(
                                                fontSize: 14.5,
                                                fontWeight: FontWeight.w700,
                                                color: Color(0xFF0F172A),
                                              ),
                                            ),
                                          ],
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 10,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color: statusColor.withAlpha(25),
                                            borderRadius: BorderRadius.circular(20),
                                            border: Border.all(
                                              color: statusColor.withAlpha(80),
                                            ),
                                          ),
                                          child: Text(
                                            order.status,
                                            style: TextStyle(
                                              fontSize: 11.5,
                                              fontWeight: FontWeight.w700,
                                              color: statusColor,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 6),

                                    // Tanggal
                                    Text(
                                      order.tanggal,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Color(0xFF64748B),
                                      ),
                                    ),
                                    const Divider(height: 20, color: Color(0xFFF1F5F9)),

                                    // Daftar Item
                                    Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Icon(
                                          Icons.shopping_bag_outlined,
                                          size: 16,
                                          color: Color(0xFF64748B),
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            order.daftarItem,
                                            style: const TextStyle(
                                              fontSize: 13,
                                              color: Color(0xFF334155),
                                              height: 1.35,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),

                                    // Total & Aksi
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            const Text(
                                              'Total Pembayaran',
                                              style: TextStyle(
                                                fontSize: 11.5,
                                                color: Color(0xFF64748B),
                                              ),
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              formatRupiah(order.totalHarga),
                                              style: const TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.w800,
                                                color: Color(0xFF1565C0),
                                              ),
                                            ),
                                          ],
                                        ),

                                        // Tombol Aksi: Ubah Status & Hapus (Langkah 4 Butir 3 & 4)
                                        Row(
                                          children: [
                                            OutlinedButton.icon(
                                              onPressed: () => _showUpdateStatusDialog(order),
                                              icon: const Icon(Icons.edit_note_rounded, size: 16),
                                              label: const Text('Status'),
                                              style: OutlinedButton.styleFrom(
                                                foregroundColor: const Color(0xFF1976D2),
                                                side: const BorderSide(color: Color(0xFF90CAF9)),
                                                padding: const EdgeInsets.symmetric(
                                                  horizontal: 10,
                                                  vertical: 6,
                                                ),
                                                minimumSize: Size.zero,
                                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            IconButton(
                                              icon: const Icon(
                                                Icons.delete_outline_rounded,
                                                size: 20,
                                                color: Color(0xFFEF4444),
                                              ),
                                              tooltip: 'Hapus Pesanan',
                                              padding: EdgeInsets.zero,
                                              constraints: const BoxConstraints(
                                                minWidth: 32,
                                                minHeight: 32,
                                              ),
                                              onPressed: () => _confirmDeleteOrder(order),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}
