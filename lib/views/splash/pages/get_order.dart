import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class GetOrderPage extends StatelessWidget {
  const GetOrderPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SvgPicture.asset('Images/Order Delivered.svg', height: 400),
          const SizedBox(height: 0),
          const Text(
            'Get Your Order',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          const Text(
            'Get your order delivered to your doorstep with our fast and reliable delivery service.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.black54, fontSize: 14),
          ),
          const SizedBox(height: 40),
          ElevatedButton(
            onPressed: () {
              Navigator.pushReplacementNamed(context, '/login');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFFFE4F28),
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Get Started',
              style: TextStyle(color: Colors.white, fontFamily: 'Montserrat'),
            ),
          ),
        ],
      ),
    );
  }
}
