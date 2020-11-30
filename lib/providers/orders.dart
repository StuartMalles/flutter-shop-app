import 'package:flutter/foundation.dart';
import './cart.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

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
  final String authToken;
  final String userId;
  Orders(this.authToken, this.userId, this._orders);

  List<OrderItem> get orders {
    return [..._orders];
  }

  Future<void> fetchAndSetOrders() async {
    final url = 'https://learnflutterndart-course.firebaseio.com/orders/$userId.json?auth=$authToken';
    final response = await http.get(url);
    //print(json.decode(response.body));

    final List<OrderItem> loadedOrders = [];
    final extractedData = json.decode(response.body) as Map<String, dynamic>;

    if (extractedData == null) {
      return;
    }

    extractedData.forEach((orderId, orderData) {
      loadedOrders.add(OrderItem(
          orderid: orderId,
          amount: orderData['amount'],
          dateTime: DateTime.parse(orderData['datetime']),
          products: (orderData['products'] as List<dynamic>)
              .map((item) => CartItem(
                  cartid: item['id'],
                  productid: item['productid'],
                  price: item['price'],
                  quantity: item['quantity'],
                  title: item['title']))
              .toList()));
    });

    _orders = loadedOrders.reversed.toList();
    notifyListeners();
  }

  Future<void> addOrder(List<CartItem> cartProducts, double total) async {
    final url = 'https://learnflutterndart-course.firebaseio.com/orders/$userId.json?auth=$authToken';
    final timestamp = DateTime.now();
    final response = await http.post(url,
        body: json.encode(
          {
            'amount': total,
            'datetime': timestamp.toIso8601String(),
            'products': cartProducts
                .map((cp) => {
                      'id': cp.cartid,
                      'productid': cp.productid,
                      'title': cp.title,
                      'quantity': cp.quantity,
                      'price': cp.price,
                    })
                .toList(),
          },
        ));

    _orders.insert(
        0,
        OrderItem(
          orderid: json.decode(response.body)['name'],
          amount: total,
          dateTime: timestamp,
          products: cartProducts,
        ));

    notifyListeners();
  }
}
