import 'package:flutter/material.dart';
import 'ProductDetailsScreen.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SearchScreen extends StatefulWidget {
  final List products;

  const SearchScreen({Key? key, required this.products}) : super(key: key);

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  List filtered = [];

  @override
  void initState() {
    super.initState();
    filtered = widget.products;
  }

  void updateSearch(String query) {
    setState(() {
      filtered =
          widget.products.where((product) {
            final title = product['title'].toString().toLowerCase();
            return title.contains(query.toLowerCase());
          }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Search")),
      body: Column(
        children: [
          const SizedBox(height: 80),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Center(
              child: TextField(
                onChanged: updateSearch,
                decoration: InputDecoration(
                  hintText: 'Search products...',
                  prefixIcon: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: SvgPicture.asset(
                      'Images/Orange Search Vector Icon.svg',
                    ),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Expanded(
            child:
                filtered.isEmpty
                    ? const Center(child: Text("No products found."))
                    : ListView.builder(
                      itemCount: filtered.length,
                      itemBuilder: (context, index) {
                        final product = filtered[index];
                        return ListTile(
                          leading: Image.network(
                            product['thumbnail'],
                            width: 50,
                          ),
                          title: Text(product['title']),
                          subtitle: Text("EGP ${product['price']}"),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (_) =>
                                        ProductDetailsScreen(product: product),
                              ),
                            );
                          },
                        );
                      },
                    ),
          ),
        ],
      ),
    );
  }
}
