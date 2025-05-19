import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool _obscurePassword = true;

  final Color themeColor = const Color(0xFFFE4F28);

  void _togglePasswordVisibility() {
    setState(() {
      _obscurePassword = !_obscurePassword;
    });
  }

  void _showSnackbar(String message) {
    final overlay = Overlay.of(context);
    final overlayEntry = OverlayEntry(
      builder:
          (_) => Positioned(
            bottom: 100,
            left: 40,
            right: 40,
            child: Material(
              color: Colors.transparent,
              child: AnimatedOpacity(
                opacity: 1.0,
                duration: const Duration(milliseconds: 300),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black87,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      message,
                      style: const TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: 14,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
            ),
          ),
    );

    overlay.insert(overlayEntry);
    Future.delayed(const Duration(seconds: 2), () => overlayEntry.remove());
  }

  Future<void> _handleLogin() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (email.isEmpty && password.isEmpty) {
      _showSnackbar("You didn't enter anything");
      return;
    } else if (email.isEmpty) {
      _showSnackbar("Please enter your email");
      return;
    } else if (password.isEmpty) {
      _showSnackbar("Please enter your password");
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final storedPassword = prefs.getString('user_${email}_password');

    if (storedPassword == null) {
      _showSnackbar("Account not found. Please sign up first.");
      return;
    }

    if (password != storedPassword) {
      _showSnackbar("Incorrect password.");
      return;
    }

    await prefs.setBool('isLoggedIn', true);
    await prefs.setString('userEmail', email);

    Navigator.pushReplacementNamed(context, '/home', arguments: email);
  }

  @override
  Widget build(BuildContext context) {
    const montserrat = TextStyle(fontFamily: 'Montserrat');

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 60),
              Text(
                'Welcome\nBack!',
                style: TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 40),
              TextField(
                controller: emailController,
                style: montserrat,
                decoration: InputDecoration(
                  hintText: 'Email Address',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: SvgPicture.asset(
                      'Images/Email Duotone Icon.svg',
                      width: 20,
                      height: 20,
                      colorFilter: ColorFilter.mode(
                        themeColor,
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: passwordController,
                style: montserrat,
                obscureText: _obscurePassword,
                decoration: InputDecoration(
                  hintText: 'Password',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: SvgPicture.asset(
                      'Images/Lock Icon.svg',
                      width: 20,
                      height: 20,
                      colorFilter: ColorFilter.mode(
                        themeColor,
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
                  suffixIcon: IconButton(
                    onPressed: _togglePasswordVisibility,
                    icon: SvgPicture.asset(
                      _obscurePassword
                          ? 'Images/Eye Slash Icon.svg'
                          : 'Images/Eye SVG Icon.svg',
                      width: 20,
                      height: 20,
                      colorFilter: ColorFilter.mode(
                        themeColor,
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
                ),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/forgot-password');
                  },
                  child: Text(
                    'Forgot Password?',
                    style: TextStyle(
                      color: themeColor,
                      fontFamily: 'Montserrat',
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _handleLogin,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    backgroundColor: themeColor,
                  ),
                  child: const Text(
                    'Login',
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const Center(
                child: Text('- OR Continue with -', style: montserrat),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SvgSocialButton(
                    svgPath: 'Images/Google Icon.svg',
                    onTap: () {},
                  ),
                  const SizedBox(width: 16),
                  if (Platform.isIOS)
                    SvgSocialButton(
                      svgPath: 'Images/Apple SVG Icon.svg',
                      onTap: () {},
                    ),
                  const SizedBox(width: 16),
                  SvgSocialButton(
                    svgPath: 'Images/Facebook SVG Icons.svg',
                    onTap: () {},
                  ),
                ],
              ),
              const Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Don't have an account? ", style: montserrat),
                  GestureDetector(
                    onTap: () {
                      Navigator.pushReplacementNamed(context, '/register');
                    },
                    child: Text(
                      'Sign Up',
                      style: TextStyle(
                        color: themeColor,
                        fontFamily: 'Montserrat',
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class SvgSocialButton extends StatelessWidget {
  final String svgPath;
  final VoidCallback onTap;

  const SvgSocialButton({
    super.key,
    required this.svgPath,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: CircleAvatar(
        radius: 22,
        backgroundColor: Colors.grey.shade200,
        child: SvgPicture.asset(
          svgPath,
          width: 24,
          height: 24,
          colorFilter: const ColorFilter.mode(Colors.black87, BlendMode.srcIn),
        ),
      ),
    );
  }
}
