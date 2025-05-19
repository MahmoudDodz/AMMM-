import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import '/providers/cart_provider.dart';
import '/providers/payment_provider.dart';
import 'payment_method_page.dart';

class CartPage extends StatefulWidget {
  final VoidCallback onBackToHome;
  static const Color themeColor = Color(0xFFFE4F28);

  const CartPage({super.key, required this.onBackToHome});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  static const Color themeColor = Color(0xFFFE4F28);
  static const double shipping = 10.0;

  String deliveryAddress = "Faculty of Science, SIM";
  String contact = "01067129594";

  @override
  Widget build(BuildContext context) {
    final cartProvider = context.watch<CartProvider>();
    final paymentProvider = context.watch<PaymentProvider>();
    final cartItems = cartProvider.items;

    double orderTotal = cartItems.fold(
      0.0,
      (sum, item) =>
          sum + ((item['price'] as double) * (item['quantity'] ?? 1)),
    );
    double total = orderTotal + shipping;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text("Checkout", style: TextStyle(color: Colors.black)),
        centerTitle: true,
        leading: IconButton(
          icon: SvgPicture.asset('Images/Back SVG Icons.svg', height: 32),
          onPressed: widget.onBackToHome,
        ),
        elevation: 1,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Text(
              "Delivery Address",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(color: Colors.black12, blurRadius: 4),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Address:",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(deliveryAddress),
                        Text("Contact: $contact"),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                GestureDetector(
                  onTap: _editAddress,
                  child: Container(
                    height: 60,
                    width: 60,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(color: Colors.black12, blurRadius: 4),
                      ],
                    ),
                    child: Center(
                      child: SvgPicture.asset(
                        'Images/Plus SVG Icons.svg',
                        height: 24,
                        width: 24,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            const Text(
              "Shopping List",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            if (cartItems.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 48),
                  child: Text(
                    "Your cart is empty.",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                  ),
                ),
              ),
            ...cartItems.map((item) => _buildCartItem(item, context)).toList(),
            const SizedBox(height: 16),
            const Divider(thickness: 1, color: Colors.black12),
            if (cartItems.isNotEmpty) ...[
              _buildPriceRow("Order", orderTotal),
              _buildPriceRow("Shipping", shipping),
              _buildPriceRow("Total", total, isTotal: true),
            ],
            const SizedBox(height: 20),
            const Text(
              "Payment",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 12),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const PaymentMethodPage()),
                );
              },
              child: _buildPaymentTile(
                paymentProvider.hasCardSelected
                    ? "Card: **** ${paymentProvider.cardNumber!.substring(paymentProvider.cardNumber!.length - 4)}"
                    : "No payment method selected. Tap to add one",
                paymentProvider.hasCardSelected,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 55,
              width: double.infinity,
              child: GestureDetector(
                onTap: () {
                  if (cartItems.isEmpty) {
                    _showCustomMessage(context, "Your cart is empty.");
                  } else if (!paymentProvider.hasCardSelected) {
                    _showCustomMessage(
                      context,
                      "Please select a payment method.",
                    );
                  } else {
                    final overlay = Overlay.of(context);
                    final overlayEntry = OverlayEntry(
                      builder:
                          (context) => Stack(
                            children: [
                              BackdropFilter(
                                filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
                                child: Container(
                                  color: Colors.black.withOpacity(0.4),
                                ),
                              ),
                              Center(
                                child: Material(
                                  color: Colors.transparent,
                                  child: Container(
                                    margin: const EdgeInsets.symmetric(
                                      horizontal: 24,
                                    ),
                                    padding: const EdgeInsets.all(24),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(24),
                                      boxShadow: const [
                                        BoxShadow(
                                          color: Colors.black26,
                                          blurRadius: 12,
                                          offset: Offset(0, 6),
                                        ),
                                      ],
                                    ),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        SvgPicture.asset(
                                          'Images/Edit SVG Color Online.svg',
                                          height: 72,
                                          width: 72,
                                        ),
                                        const SizedBox(height: 16),
                                        const Text(
                                          "Order placed successfully!",
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                    );

                    overlay.insert(overlayEntry);

                    Future.delayed(const Duration(seconds: 3), () {
                      overlayEntry.remove();
                      Provider.of<CartProvider>(context, listen: false).clear();
                      widget.onBackToHome();
                    });
                  }
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: themeColor,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 6,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  alignment: Alignment.center,
                  child: const Text(
                    "Place Order",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      fontFamily: 'Montserrat',
                      shadows: [Shadow(offset: Offset(0, 1), blurRadius: 1.0)],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildCartItem(Map item, BuildContext context) {
    final String title = item['title'] ?? '';
    final String image = item['image'] ?? '';
    final double price = item['price'] ?? 0.0;
    final double oldPrice = item['oldPrice'] ?? 0.0;
    final int quantity = item['quantity'] ?? 1;
    final List variations = item['variations'] ?? [];

    final cartProvider = Provider.of<CartProvider>(context, listen: false);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6)],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              image,
              height: 90,
              width: 90,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                if (variations.isNotEmpty)
                  Wrap(
                    spacing: 8,
                    children:
                        variations
                            .map<Widget>((v) => Chip(label: Text(v.toString())))
                            .toList(),
                  ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        IconButton(
                          icon: SvgPicture.asset(
                            'Images/Minus Duotone Icon.svg',
                            height: 24,
                          ),
                          onPressed:
                              () => cartProvider.decreaseQuantity(
                                item as Map<String, dynamic>,
                              ),
                        ),
                        Text("Qty: $quantity"),
                        IconButton(
                          icon: SvgPicture.asset(
                            'Images/Plus Duotone Icon.svg',
                            height: 24,
                          ),
                          onPressed:
                              () => cartProvider.increaseQuantity(
                                item as Map<String, dynamic>,
                              ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          "EGP ${(price * quantity).toStringAsFixed(2)}",
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          "EGP ${oldPrice.toStringAsFixed(2)}",
                          style: const TextStyle(
                            decoration: TextDecoration.lineThrough,
                            color: Colors.red,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceRow(String label, double amount, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style:
                isTotal
                    ? const TextStyle(fontWeight: FontWeight.bold)
                    : const TextStyle(color: Colors.grey),
          ),
          Text(
            "EGP ${amount.toStringAsFixed(2)}",
            style:
                isTotal ? const TextStyle(fontWeight: FontWeight.bold) : null,
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentTile(String label, [bool selected = false]) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: selected ? Border.all(color: Colors.redAccent, width: 2) : null,
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          selected
              ? SvgPicture.asset(
                'Images/Visa SVG Icon.svg',
                height: 24,
                width: 40,
              )
              : SvgPicture.asset(
                'Images/Right Chevron Icon.svg',
                height: 24,
                width: 24,
              ),
        ],
      ),
    );
  }

  void _editAddress() {
    final addressController = TextEditingController(text: deliveryAddress);
    final contactController = TextEditingController(text: contact);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (_) => Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    "Edit Delivery Info",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: addressController,
                    decoration: const InputDecoration(labelText: "Address"),
                  ),
                  TextField(
                    controller: contactController,
                    decoration: const InputDecoration(labelText: "Contact"),
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: themeColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {
                      setState(() {
                        deliveryAddress = addressController.text;
                        contact = contactController.text;
                      });
                      Navigator.of(context).pop();
                    },
                    child: const Text(
                      "Save",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ),
    );
  }

  void _showCustomMessage(BuildContext context, String message) {
    final overlay = Overlay.of(context);
    final overlayEntry = OverlayEntry(
      builder:
          (context) => Stack(
            children: [
              BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
                child: Container(color: Colors.black.withOpacity(0.4)),
              ),
              Center(
                child: Material(
                  color: Colors.transparent,
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 40),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 16,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 10,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Text(
                      message,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
    );

    overlay.insert(overlayEntry);
    Future.delayed(const Duration(seconds: 1), () => overlayEntry.remove());
  }
}
