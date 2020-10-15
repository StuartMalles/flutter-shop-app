import 'package:flutter/foundation.dart';

class CartItem {
  final String cartid;
  final String productid;
  final String title;
  final int quantity;
  final double price;

  CartItem({
    @required this.cartid,
    @required this.productid,
    @required this.title,
    @required this.quantity,
    @required this.price,
  });
}

class Cart with ChangeNotifier {
  Map<String, CartItem> _items = {};

  Map<String, CartItem> get items {
    return {..._items};
  }

  int get itemCount {
    return _items.length;
  }

  double get totalAmount {
    var total = 0.0;

    _items.forEach((key, value) {
      total += value.price * value.quantity;
    });

    return total;
  }

  void addItem(String productid, double price, String title) {
    if (_items.containsKey(productid)) {
      _items.update(
          productid,
          (existingCartItem) => CartItem(
                cartid: existingCartItem.cartid,
                productid: existingCartItem.productid,
                title: existingCartItem.title,
                price: existingCartItem.price,
                quantity: existingCartItem.quantity + 1,
              ));
    } else {
      _items.putIfAbsent(
          productid,
          () => CartItem(
                cartid: DateTime.now().toString(),
                productid: productid,
                title: title,
                price: price,
                quantity: 1,
              ));
    }

    notifyListeners();
  }

  void removeItem(String productid) {
    _items.remove(productid);
    notifyListeners();
  }

  void removeSingleItem(String productid) {
    if (!_items.containsKey(productid)) {
      return;
    }

    if (_items[productid].quantity > 1) {
      _items.update(
          productid,
          (existingCartItem) => CartItem(
                cartid: existingCartItem.cartid,
                productid: existingCartItem.productid,
                title: existingCartItem.title,
                price: existingCartItem.price,
                quantity: existingCartItem.quantity - 1,
              ));
    } else {
      removeItem(productid);
    }

    notifyListeners();
  }

  void clear() {
    _items = {};
    notifyListeners();
  }
}
