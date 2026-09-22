import 'package:flutter/material.dart';
import 'models/product.dart';
import 'widgets/category_tag.dart';
import 'widgets/product_card.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: namaToko, // Menggunakan namaToko dari product.dart
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const TokoKitaHomePage(),
    );
  }
}

class TokoKitaHomePage extends StatefulWidget {
  const TokoKitaHomePage({super.key});

  @override
  State<TokoKitaHomePage> createState() => _TokoKitaHomePageState();
}

class _TokoKitaHomePageState extends State<TokoKitaHomePage> {
  // Salinan daftar produk dari data dummy di product.dart
  late List<Product> _allProducts;
  String _selectedCategory = 'Semua';

  @override
  void initState() {
    super.initState();
    _allProducts = List<Product>.from(dummyProducts);
  }

  // Daftar produk yang ditampilkan (mendukung filter kategori)
  List<Product> get _displayedProducts {
    if (_selectedCategory == 'Semua') {
      return _allProducts;
    }
    return _allProducts
        .where((p) => p.category.toLowerCase() == _selectedCategory.toLowerCase())
        .toList();
  }

  void _resetProducts() {
    setState(() {
      _allProducts = List<Product>.from(dummyProducts);
      _selectedCategory = 'Semua';
    });
  }

  void _removeProduct(int productId) {
    setState(() {
      _allProducts.removeWhere((p) => p.id == productId);
    });
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'elektronik':
        return Colors.indigo;
      case 'fashion':
        return Colors.pink;
      case 'makanan':
        return Colors.teal;
      default:
        return Colors.deepPurple;
    }
  }

  @override
  Widget build(BuildContext context) {
    final displayedList = _displayedProducts;

    return Scaffold(
      appBar: AppBar(
        // Sinkron dengan variabel namaToko dari product.dart
        title: const Text(namaToko),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Reset Daftar Produk',
            onPressed: _resetProducts,
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Banner Kategori (Menggunakan kategoriList langsung dari product.dart)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: Colors.deepPurple.shade50,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Kategori Produk:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        color: Colors.deepPurple,
                      ),
                    ),
                    Text(
                      'Pilih untuk memfilter',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      // Opsi Semua
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedCategory = 'Semua';
                          });
                        },
                        child: Opacity(
                          opacity: _selectedCategory == 'Semua' ? 1.0 : 0.5,
                          child: const CategoryTag(
                            category: 'Semua',
                            customColor: Colors.deepPurple,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),

                      // Kategori dinamis dari kategoriList di product.dart
                      ...kategoriList.map((kat) {
                        final isSelected = _selectedCategory.toLowerCase() == kat.toLowerCase();
                        return Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedCategory = isSelected ? 'Semua' : kat;
                              });
                            },
                            child: Opacity(
                              opacity: isSelected || _selectedCategory == 'Semua' ? 1.0 : 0.45,
                              child: CategoryTag(
                                category: kat,
                                customColor: _getCategoryColor(kat),
                              ),
                            ),
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Header Informasi Daftar Produk
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _selectedCategory == 'Semua'
                      ? 'Semua Produk'
                      : 'Kategori: $_selectedCategory',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${displayedList.length} item',
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),

          // Daftar Produk dengan ProductCard
          Expanded(
            child: displayedList.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.inbox, size: 64, color: Colors.grey),
                        const SizedBox(height: 12),
                        Text(
                          'Tidak ada produk untuk kategori "$_selectedCategory"',
                          style: const TextStyle(color: Colors.grey),
                        ),
                        const SizedBox(height: 12),
                        ElevatedButton.icon(
                          onPressed: _resetProducts,
                          icon: const Icon(Icons.refresh),
                          label: const Text('Tampilkan Semua Produk'),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: displayedList.length,
                    itemBuilder: (context, index) {
                      final product = displayedList[index];
                      return ProductCard(
                        key: ValueKey(product.id),
                        product: product,
                        onDelete: () => _removeProduct(product.id),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}