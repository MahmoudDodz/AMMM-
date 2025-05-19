import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ChooseProductsPage extends StatelessWidget {
  const ChooseProductsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            // Main content
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SvgPicture.asset('Images/Get Your Order.svg', height: 400),
                  const SizedBox(height: 32),
                  const Text(
                    'Choose Products',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Montserrat',
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Choose your favorite products from our wide range of options.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.black54,
                      fontSize: 14,
                      fontFamily: 'Montserrat',
                    ),
                  ),
                ],
              ),
            ),

            // Skip button
            Positioned(
              top: 16,
              right: 16,
              child: TextButton(
                onPressed: () {
                  Navigator.pushReplacementNamed(context, '/login');
                },
                child: const Text(
                  'Skip',
                  style: TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 16,
                    color: Color(0xFFFE4F28),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
