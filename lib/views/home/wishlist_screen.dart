import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '/providers/wishlist_provider.dart';
import 'ProductDetailsScreen.dart';
import 'package:flutter_svg/flutter_svg.dart';

class WishlistScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final wishlist = Provider.of<WishlistProvider>(context).wishlistItems;

    return Scaffold(
      appBar: AppBar(title: const Text("Your Wishlist")),
      body:
          wishlist.isEmpty
              ? const Center(child: Text("No items in your wishlist"))
              : ListView.builder(
                itemCount: wishlist.length,
                itemBuilder:
                    (ctx, i) => InkWell(
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder:
                                (ctx) =>
                                    ProductDetailsScreen(product: wishlist[i]),
                          ),
                        );
                      },
                      child: ListTile(
                        leading: Image.network(
                          wishlist[i]['image'],
                          width: 50,
                          fit: BoxFit.cover,
                        ),
                        title: Text(wishlist[i]['title']),
                        subtitle: Text("EGP ${wishlist[i]['price']}"),
                        trailing: SvgPicture.asset(
                          'Images/Right Chevron Icon.svg',
                          width: 24,
                          height: 24,
                          color: Theme.of(context).iconTheme.color,
                        ),
                      ),
                    ),
              ),
    );
  }
}
