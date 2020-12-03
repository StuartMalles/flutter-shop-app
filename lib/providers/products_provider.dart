import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/http_exception.dart';
import 'dart:convert';
import './product.dart';

class ProductsProvider with ChangeNotifier {
  List<Product> _items = ProductData().sampleProductList;

  final String authToken;
  final String userId;
  ProductsProvider(this.authToken, this.userId, this._items);

  List<Product> get items {
    return [..._items];
  }

  List<Product> get favoriteItems {
    return _items.where((element) => element.isFavorite).toList();
  }

  Product findById(String id) {
    return _items.firstWhere((product) => product.id == id);
  }

  Future<void> fetchAndSetProducts({bool filterByUser = false}) async {
    final filterString = filterByUser ? '&orderBy="creatorId"&equalTo="$userId"' : '';
    var url = 'https://learnflutterndart-course.firebaseio.com/products.json?auth=$authToken$filterString';

    try {
      final response = await http.get(url);
      //print(json.decode(response.body));

      // {-MFR9jhWqQ4PSemT71p0: {
      //     description:This is a test,
      //     imageUrl   :https://live.staticflickr.com/65535/48954138922_9c42173f08_c.jpg,
      //     isFavorite :false,
      //     price      :12.99,
      //     title      :Test }
      // }

      final extractedData = json.decode(response.body) as Map<String, dynamic>;

      if (extractedData == null) {
        return;
      }

      url = 'https://learnflutterndart-course.firebaseio.com/userFavorites/$userId.json?auth=$authToken';
      final favoriteResponse = await http.get(url);
      final favoriteData = json.decode(favoriteResponse.body);

      final List<Product> loadedProducts = [];
      if (extractedData != null) {
        extractedData.forEach((prodId, prodData) {
          loadedProducts.add(Product(
            id: prodId,
            title: prodData['title'],
            description: prodData['description'],
            price: prodData['price'],
            isFavorite: favoriteData == null ? false : favoriteData[prodId] ?? false,
            imageUrl: prodData['imageUrl'],
          ));
        });
      }

      _items = loadedProducts;
      notifyListeners();
    } catch (error) {
      throw (error);
    }
  }

  Future<void> addProduct(Product product) async {
    final url = 'https://learnflutterndart-course.firebaseio.com/products.json?auth=$authToken';

    try {
      final response = await http.post(url,
          body: json.encode({
            'title': product.title,
            'description': product.description,
            'imageUrl': product.imageUrl,
            'price': product.price,
            'creatorId': userId,
          }));

      final newProduct = Product(
          id: json.decode(response.body)['name'],
          title: product.title,
          description: product.description,
          price: product.price,
          imageUrl: product.imageUrl);

      _items.add(newProduct);
      notifyListeners();
    } catch (error) {
      print(error);
      throw error;
    }
  }

  Future<void> updateProduct(String id, Product newProduct) async {
    final prodIndex = _items.indexWhere((prod) => prod.id == id);
    if (prodIndex >= 0) {
      final url = 'https://learnflutterndart-course.firebaseio.com/products/$id.json?auth=$authToken';

      await http.patch(url,
          body: json.encode({
            'title': newProduct.title,
            'description': newProduct.description,
            'imageUrl': newProduct.imageUrl,
            'price': newProduct.price
          }));

      _items[prodIndex] = newProduct;
      notifyListeners();
    }
  }

  Future<void> deleteProduct(String id) async {
    final url = 'https://learnflutterndart-course.firebaseio.com/products/$id.json?auth=$authToken';
    final existingProductIndex = _items.indexWhere((prod) => prod.id == id);
    var existingProduct = _items[existingProductIndex];

    _items.removeAt(existingProductIndex);
    notifyListeners();

    final response = await http.delete(url);

    if (response.statusCode >= 400) {
      _items.insert(existingProductIndex, existingProduct);
      notifyListeners();
      throw HttpException('Could not delete product.');
    }

    existingProduct = null;
  }
}
