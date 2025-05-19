import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_svg/flutter_svg.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'ProductDetailsScreen.dart';

class GroceriesScreen extends StatefulWidget {
  final Function(List) onProductsLoaded;

  const GroceriesScreen({Key? key, required this.onProductsLoaded})
    : super(key: key);

  @override
  State<GroceriesScreen> createState() => _GroceriesScreenState();
}

class _GroceriesScreenState extends State<GroceriesScreen> {
  List products = [];
  List filteredProducts = [];
  bool isLoading = true;
  bool hasError = false;

  final Color themeColor = const Color(0xFFFE4F28);
  String selectedCategory = "All";

  final List<String> categories = ["All", "Fruits", "Fast-food", "Vegetables"];

  @override
  void initState() {
    super.initState();
    fetchProducts();
  }

  Future<void> fetchProducts() async {
    try {
      final response = await http.get(
        Uri.parse('https://dummyjson.com/products'),
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          products = data['products'];
          isLoading = false;
          applyCategoryFilter();
        });

        widget.onProductsLoaded(data['products']);
      } else {
        setState(() {
          hasError = true;
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        hasError = true;
        isLoading = false;
      });
    }
  }

  void applyCategoryFilter() {
    setState(() {
      if (selectedCategory == 'All') {
        filteredProducts = products;
        return;
      }

      filteredProducts =
          products.where((product) {
            final title = product['title'].toString().toLowerCase();
            switch (selectedCategory) {
              case 'Fruits':
                return title.contains('apple') ||
                    title.contains('banana') ||
                    title.contains('orange') ||
                    title.contains('fruit');
              case 'Fast-food':
                return title.contains('burger') ||
                    title.contains('pizza') ||
                    title.contains('hotdog') ||
                    title.contains('fries') ||
                    title.contains('nuggets') ||
                    title.contains('chicken');
              case 'Vegetables':
                return title.contains('vegetable') ||
                    title.contains('tomato') ||
                    title.contains('carrot') ||
                    title.contains('onion') ||
                    title.contains('cucumber');
              default:
                return true;
            }
          }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? _customLoadingIndicator()
        : hasError
        ? const Center(child: Text("Couldn't load products. Try again."))
        : SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Promo Banner
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: themeColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: themeColor,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Text(
                                "Delivery within 25 min",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
                            const Text(
                              "Free Delivery For\nNext Three Orders",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              "Get fresh groceries delivered to your door. Save time.",
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 10),
                            const Text(
                              "Order Now",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      SvgPicture.asset(
                        'Images/Shopping Bags.svg',
                        width: 90,
                        height: 90,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Categories
                const Text(
                  "Categories",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                const SizedBox(height: 12),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children:
                        categories.map((cat) {
                          return GestureDetector(
                            onTap: () {
                              selectedCategory = cat;
                              applyCategoryFilter();
                            },
                            child: _categoryTab(
                              cat,
                              selectedCategory == cat,
                              themeColor,
                            ),
                          );
                        }).toList(),
                  ),
                ),
                const SizedBox(height: 24),

                // Product Grid
                if (filteredProducts.isEmpty)
                  const Center(child: Text("No products found."))
                else
                  GridView.builder(
                    itemCount: filteredProducts.length,
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    padding: EdgeInsets.zero,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 16,
                          crossAxisSpacing: 16,
                          childAspectRatio: 0.7,
                        ),
                    itemBuilder: (context, index) {
                      final product = filteredProducts[index];
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (_) => ProductDetailsScreen(product: product),
                            ),
                          );
                        },
                        child: _buildProductCard(product, themeColor, index),
                      );
                    },
                  ),
              ],
            ),
          ),
        );
  }

  Widget _customLoadingIndicator() {
    return Center(
      child: LoadingAnimationWidget.twistingDots(
        leftDotColor: themeColor,
        rightDotColor: themeColor.withOpacity(0.5),
        size: 80,
      ),
    );
  }

  Widget _categoryTab(String title, bool isSelected, Color? color) {
    return Container(
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: isSelected ? color?.withOpacity(0.2) : Colors.grey[200],
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        title,
        style: TextStyle(color: isSelected ? color : Colors.black54),
      ),
    );
  }

  Widget _buildProductCard(dynamic product, Color color, int index) {
    final originalPrice = (product['price'] + Random().nextInt(20) + 10)
        .toStringAsFixed(2);
    final saleTag = index % 2 == 0 ? "Best Sale" : "${10 + index * 5}% Off";

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.white,
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 20)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            child: Image.network(
              product['thumbnail'],
              height: 100,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    saleTag,
                    style: const TextStyle(fontSize: 10, color: Colors.white),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  product['title'],
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                const Text(
                  "500gm",
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        "EGP ${product['price']}",
                        style: const TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        "EGP $originalPrice",
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.red,
                          decoration: TextDecoration.lineThrough,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
