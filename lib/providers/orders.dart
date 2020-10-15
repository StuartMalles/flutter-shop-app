import 'package:flutter/foundation.dart';
import './cart.dart';

class OrderItem {
  final String orderid;
  final double amount;
  final List<CartItem> products;
  final DateTime dateTime;

  OrderItem({
    @required this.orderid,
    @required this.amount,
    @required this.products,
    @required this.dateTime,
  });
}

class Orders with ChangeNotifier {
  List<OrderItem> _orders = [];

  List<OrderItem> get orders {
    return [..._orders];
  }

  void addOrder(List<CartItem> cartProducts, double total) {
    _orders.insert(0,
        OrderItem(orderid: DateTime.now().toString(), amount: total, dateTime: DateTime.now(), products: cartProducts));

    notifyListeners();
  }
}
