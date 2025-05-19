import 'package:flutter/material.dart';

class WishlistProvider with ChangeNotifier {
  final List<Map> _wishlistItems = [];

  List<Map> get wishlistItems => _wishlistItems;

  void addToWishlist(Map product) {
    if (!_wishlistItems.any((item) => item['title'] == product['title'])) {
      _wishlistItems.add(product);
      notifyListeners();
    }
  }

  void removeFromWishlist(String title) {
    _wishlistItems.removeWhere((item) => item['title'] == title);
    notifyListeners();
  }

  bool isInWishlist(String title) {
    return _wishlistItems.any((item) => item['title'] == title);
  }
}
