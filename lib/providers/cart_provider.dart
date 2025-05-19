import 'package:flutter/foundation.dart';

class CartProvider extends ChangeNotifier {
  final List<Map<String, dynamic>> _items = [];

  List<Map<String, dynamic>> get items => List.unmodifiable(_items);

  void addItem(Map<String, dynamic> product, int quantity) {
    final String title = product['title'];

    final existingIndex = _items.indexWhere((item) => item['title'] == title);

    final newItem =
        Map<String, dynamic>.from(product)
          ..remove('quantity')
          ..['quantity'] = quantity;

    if (existingIndex != -1) {
      _items[existingIndex]['quantity'] += quantity;
    } else {
      _items.add(newItem);
    }

    notifyListeners();
  }

  void increaseQuantity(Map<String, dynamic> item) {
    final index = _items.indexWhere((i) => i['title'] == item['title']);
    if (index != -1) {
      _items[index]['quantity'] += 1;
      notifyListeners();
    }
  }

  void decreaseQuantity(Map<String, dynamic> item) {
    final index = _items.indexWhere((i) => i['title'] == item['title']);
    if (index != -1) {
      if (_items[index]['quantity'] > 1) {
        _items[index]['quantity'] -= 1;
      } else {
        _items.removeAt(index);
      }
      notifyListeners();
    }
  }

  void clear() {
    _items.clear();
    notifyListeners();
  }
}
