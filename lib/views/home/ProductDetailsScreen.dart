import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import '/providers/cart_provider.dart';
import '/providers/wishlist_provider.dart';

class ProductDetailsScreen extends StatefulWidget {
  final Map product;

  const ProductDetailsScreen({Key? key, required this.product})
    : super(key: key);

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen>
    with SingleTickerProviderStateMixin {
  int quantity = 0;
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeIn));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void addSingleItemToCart() {
    Provider.of<CartProvider>(context, listen: false).addItem({
      'title': widget.product['title'],
      'image': widget.product['thumbnail'] ?? widget.product['image'],
      'price': widget.product['price'],
      'oldPrice': widget.product['price'] + 20,
      'variations': widget.product['variations'] ?? [],
    }, 1);
  }

  void toggleWishlist() {
    final wishlistProvider = Provider.of<WishlistProvider>(
      context,
      listen: false,
    );
    final isWishlisted = wishlistProvider.isInWishlist(widget.product['title']);

    if (isWishlisted) {
      wishlistProvider.removeFromWishlist(widget.product['title']);
    } else {
      wishlistProvider.addToWishlist({
        'title': widget.product['title'],
        'image': widget.product['thumbnail'] ?? widget.product['image'],
        'price': widget.product['price'],
        'description': widget.product['description'],
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final price = widget.product['price'];
    final image = widget.product['thumbnail'] ?? widget.product['image'];
    final isWishlisted = Provider.of<WishlistProvider>(
      context,
    ).isInWishlist(widget.product['title']);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFFE4F28),
        leading: IconButton(
          icon: SvgPicture.asset('Images/Back SVG Icons.svg', height: 50),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SvgPicture.asset(
                  'Images/Logo.svg',
                  height: 120,
                  colorFilter: const ColorFilter.mode(
                    Colors.white,
                    BlendMode.srcIn,
                  ),
                ),
                const SizedBox(width: 4),
                const Text(
                  'AMMM!',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Image.network(image, height: 200, fit: BoxFit.contain),
            ),
            const SizedBox(height: 20),
            Text(
              widget.product['title'],
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              "EGP $price",
              style: const TextStyle(fontSize: 18, color: Colors.green),
            ),
            const SizedBox(height: 16),
            Text(
              widget.product['description'] ?? 'No description available.',
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 24),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: double.infinity,
                  child:
                      quantity == 0
                          ? InkWell(
                            onTap: () {
                              setState(() {
                                quantity = 1;
                              });
                              addSingleItemToCart();
                            },
                            borderRadius: BorderRadius.circular(12),
                            child: Ink(
                              decoration: BoxDecoration(
                                color: const Color(0xFFFE4F28),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 18),
                              child: const Center(
                                child: Text(
                                  "Add to Cart",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          )
                          : Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFFFE4F28),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 10,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                IconButton(
                                  onPressed: () {
                                    setState(() {
                                      if (quantity > 1) {
                                        quantity--;
                                        Provider.of<CartProvider>(
                                          context,
                                          listen: false,
                                        ).decreaseQuantity({
                                          'title': widget.product['title'],
                                        });
                                      } else {
                                        quantity = 0;
                                        Provider.of<CartProvider>(
                                          context,
                                          listen: false,
                                        ).decreaseQuantity({
                                          'title': widget.product['title'],
                                        });
                                      }
                                    });
                                  },
                                  icon: SvgPicture.asset(
                                    'Images/Minus Duotone Icon.svg',
                                    height: 24,
                                  ),
                                ),
                                Text(
                                  '$quantity',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                IconButton(
                                  onPressed: () {
                                    setState(() {
                                      quantity++;
                                    });
                                    addSingleItemToCart();
                                  },
                                  icon: SvgPicture.asset(
                                    'Images/Plus Duotone Icon.svg',
                                    height: 24,
                                  ),
                                ),
                              ],
                            ),
                          ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    icon: SvgPicture.asset(
                      isWishlisted
                          ? 'Images/Heart 2.svg'
                          : 'Images/Heart 1.svg',
                      height: 20,
                    ),
                    label: Text(
                      isWishlisted ? 'Remove from Wishlist' : 'Add to Wishlist',
                      style: const TextStyle(color: Colors.black87),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.red),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: toggleWishlist,
                  ),
                ),
                const SizedBox(height: 12),
                const Align(
                  alignment: Alignment.center,
                  child: Text(
                    "Thank you for shopping with us!",
                    style: TextStyle(fontSize: 12, color: Colors.black54),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
