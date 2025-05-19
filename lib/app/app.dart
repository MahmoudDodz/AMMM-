import 'package:flutter/material.dart';
import '../views/splash/splash_screen.dart';
import '../views/splash/onboarding_screen.dart';
import '../views/auth/login_screen.dart';
import '../views/auth/register_screen.dart';
import '../views/auth/forgot_password_screen.dart';
import '../views/home/home_screen.dart';
import '../views/home/ProductDetailsScreen.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AMMM!',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        primaryColor: const Color(0xFFFE4F28),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFFE4F28),
          primary: const Color(0xFFFE4F28),
          secondary: const Color(0xFFFE4F28),
        ),
        scaffoldBackgroundColor: Colors.white,
        textTheme: ThemeData.light().textTheme.apply(fontFamily: 'Montserrat'),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFFE4F28),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/onboarding': (context) => const OnboardingScreen(),
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/forgot-password': (context) => const ForgotPasswordScreen(),
        '/home': (context) {
          final args = ModalRoute.of(context)?.settings.arguments;
          final email = args is String ? args : 'guest@example.com';
          return HomeScreen(email: email);
        },
        '/product-details': (context) {
          final args = ModalRoute.of(context)?.settings.arguments;
          if (args is Map<String, dynamic>) {
            return ProductDetailsScreen(product: args);
          }
          return const Scaffold(
            body: Center(child: Text('No product data found')),
          );
        },
      },
    );
  }
}
