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

  List<OrderItem> get orders {
    return [..._orders];
  }

  // {-MMGoWUPhvB0nO2z967N: {amount: 199.99, datetime: 2020-11-16T09:10:07.987485,
  // products: [{id: 2020-11-16 09:10:01.791792, price: 199.99,
  // productid: -MFVIl3AEq0nYH_iRibu, quantity: 1, title: Rocket Moon Base}]}}

  Future<void> fetchAndSetOrders() async {
    const url = 'https://learnflutterndart-course.firebaseio.com/orders/.json';
    final response = await http.get(url);

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

    // Order the list with most recent on top
    _orders = loadedOrders.reversed.toList();
    notifyListeners();
  }

  Future<void> addOrder(List<CartItem> cartProducts, double total) async {
    const url = 'https://learnflutterndart-course.firebaseio.com/orders/.json';
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
