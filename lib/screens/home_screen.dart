import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../widgets/search_bar.dart';
import '../widgets/product_item.dart';
import '../services/api_service.dart';
import '../models/product.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Product> products = [];
  String searchQuery = '';
  String selectedCategory = 'All';
  bool isLoading = true;

  List<String> get categories {
    final api = products.map((p) => p.category).toSet().toList();
    api.sort();
    return api;
  }

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    try {
      final fetchedProducts = await ApiService.fetchProducts();
      print('Products fetched: ${fetchedProducts.length}');
      setState(() {
        products = fetchedProducts;
        isLoading = false;
      });
    } catch (e) {
      print('Error fetching products: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  List<Product> get filteredProducts {
    if (searchQuery.isNotEmpty && searchQuery.length < 3) {
      return products
          .where((product) =>
              selectedCategory == 'All' || product.category == selectedCategory)
          .toList();
    }

    return products.where((product) {
      final matchesSearch =
          product.title.toLowerCase().contains(searchQuery.toLowerCase());
      final matchesCategory =
          selectedCategory == 'All' || product.category == selectedCategory;
      return matchesSearch && matchesCategory;
    }).toList();
  }

  Future<void> _handleSearch(String value) async {
    if (value.length < 3 && value.isNotEmpty) {
      return;
    }
    setState(() {
      isLoading = true;
      searchQuery = value;
    });
    await Future.delayed(const Duration(seconds: 1));
    setState(() {
      isLoading = false;
    });
  }

  Widget _buildCategoryDropdown() {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Container(
          height: 36,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade400),
            borderRadius: BorderRadius.circular(20),
            color: selectedCategory != 'All'
                ? Colors.grey.shade200
                : Colors.transparent,
          ),
          child: PopupMenuButton<String>(
            onSelected: (value) {
              setState(() {
                selectedCategory = value;
                searchQuery = ''; // clear search on category change
              });
            },
            position: PopupMenuPosition.under,
            constraints: BoxConstraints(
              minWidth: constraints.maxWidth,
              maxWidth: constraints.maxWidth,
              maxHeight: 250,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            itemBuilder: (BuildContext context) {
              List<PopupMenuEntry<String>> items = [];
              for (String category in categories) {
                items.add(
                  PopupMenuItem<String>(
                    value: category,
                    child: Row(
                      children: [
                        if (selectedCategory == category)
                          Icon(Icons.check, color: Colors.deepOrange, size: 16)
                        else
                          const SizedBox(width: 16),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            category.isNotEmpty
                                ? category[0].toUpperCase() +
                                    category.substring(1)
                                : category,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }
              return items;
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      selectedCategory == 'All'
                          ? 'Select Category'
                          : (selectedCategory.isNotEmpty
                              ? selectedCategory[0].toUpperCase() +
                                  selectedCategory.substring(1)
                              : selectedCategory),
                      style: TextStyle(
                        color: selectedCategory == 'All'
                            ? Colors.grey.shade600
                            : Colors.grey.shade800,
                        fontSize: 14,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Icon(
                    Icons.arrow_drop_down,
                    color: Colors.grey.shade600,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Modern header section with search and filters
            Container(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  SearchBarWidget(
                    onSearch: (value) {
                      _handleSearch(value);
                    },
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      ChoiceChip(
                        label: const Text('All Categories'),
                        selected: selectedCategory == 'All',
                        onSelected: (selected) {
                          if (selected) {
                            setState(() {
                              selectedCategory = 'All';
                              searchQuery =
                                  ''; // clear search when selecting all categories
                            });
                          }
                        },
                        selectedColor: Colors.grey.shade200,
                        backgroundColor: Colors.transparent,
                        shape: StadiumBorder(
                          side: BorderSide(
                            color: selectedCategory == 'All'
                                ? Colors.grey.shade600
                                : Colors.grey.shade400,
                          ),
                        ),
                        labelStyle: TextStyle(
                          color: selectedCategory == 'All'
                              ? Colors.grey.shade800
                              : Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildCategoryDropdown(),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: isLoading
                  ? Padding(
                      padding: const EdgeInsets.only(top: 20),
                      child: Lottie.asset(
                        'assets/lottie/loading.json',
                        width: 300,
                        height: 300,
                        repeat: true,
                      ),
                    )
                  : filteredProducts.isEmpty
                      ? Padding(
                          padding: const EdgeInsets.only(top: 20),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Lottie.asset(
                                'assets/lottie/empty.json',
                                repeat: true,
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                'Oops!! This product is missing...',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        )
                      : GridView.builder(
                          padding: const EdgeInsets.all(20),
                          itemCount: filteredProducts.length,
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                            childAspectRatio: 0.75,
                          ),
                          itemBuilder: (context, index) {
                            final product = filteredProducts[index];
                            return ProductItem(
                              title: product.title,
                              price: product.price.toString(),
                              rating: product.rating.toString(),
                              imageUrl: product.thumbnail,
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}
