import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import './providers/auth.dart';
import './providers/cart.dart';
import './providers/products_provider.dart';
import './providers/orders.dart';

import './screens/cart_screen.dart';
import './screens/product_detail_screen.dart';
import './screens/products_overview_screen.dart';
import './screens/splash_screen.dart';
import './screens/orders_screen.dart';
import './screens/user_products_screen.dart';
import './screens/edit_product_screen.dart';
import './screens/auth_screen.dart';
import './helpers/custom_route.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: Auth()),
        ChangeNotifierProvider.value(value: Cart()),
        ChangeNotifierProxyProvider<Auth, Orders>(
            create: null,
            update: (ctx, auth, previousOrders) =>
                Orders(auth.token, auth.userid, previousOrders == null ? [] : previousOrders.orders)),
        ChangeNotifierProxyProvider<Auth, ProductsProvider>(
            create: null,
            update: (ctx, auth, previousProducts) =>
                ProductsProvider(auth.token, auth.userid, previousProducts == null ? [] : previousProducts.items)),
      ],
      child: Consumer<Auth>(
        builder: (ctx, auth, _) => MaterialApp(
            title: 'MyShop',
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
                primarySwatch: Colors.purple,
                accentColor: Colors.deepOrange,
                fontFamily: 'Lato',
                pageTransitionsTheme: PageTransitionsTheme(builders: {
                  TargetPlatform.android: CustomPageTransitionBuilder(),
                  TargetPlatform.iOS: CustomPageTransitionBuilder()
                })),
            home: auth.isAuth
                ? ProductsOverviewScreen()
                : FutureBuilder(
                    future: auth.tryAutoLogin(),
                    builder: (ctx, authResultShapshot) =>
                        authResultShapshot.connectionState == ConnectionState.waiting ? SplashScreen() : AuthScreen()),
            routes: {
              ProductDetailScreen.routeName: (context) => ProductDetailScreen(),
              CartScreen.routeName: (context) => CartScreen(),
              OrdersScreen.routeName: (context) => OrdersScreen(),
              UserProductsScreen.routeName: (context) => UserProductsScreen(),
              EditProductScreen.routeName: (context) => EditProductScreen(),
            }),
      ),
    );
  }
}
