import 'package:flutter/material.dart';
import 'app/app.dart';
import 'package:provider/provider.dart';
import 'providers/cart_provider.dart';
import 'providers/payment_provider.dart';
import 'providers/wishlist_provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => PaymentProvider()),
        ChangeNotifierProvider(create: (_) => WishlistProvider()),
      ],
      child: const MyApp(),
    ),
  );
}
