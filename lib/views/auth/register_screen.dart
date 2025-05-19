import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool _obscurePassword = true;
  String _passwordStrength = '';
  Color _strengthColor = Colors.transparent;
  double _strengthPercent = 0;

  final Color themeColor = const Color(0xFFFE4F28);

  void _togglePasswordVisibility() {
    setState(() => _obscurePassword = !_obscurePassword);
  }

  void _calculatePasswordStrength(String password) {
    if (password.isEmpty) {
      setState(() {
        _passwordStrength = '';
        _strengthColor = Colors.transparent;
        _strengthPercent = 0;
      });
      return;
    }

    String strength = 'Weak';
    Color color = Colors.red;
    double percent = 0.33;

    final hasLetters = RegExp(r'[A-Za-z]').hasMatch(password);
    final hasNumbers = RegExp(r'[0-9]').hasMatch(password);
    final hasUpper = RegExp(r'[A-Z]').hasMatch(password);
    final hasLower = RegExp(r'[a-z]').hasMatch(password);
    final hasSpecial = RegExp(r'[!@#\\$%^&*(),.?":{}|<>]').hasMatch(password);

    if (password.length >= 8 &&
        hasUpper &&
        hasLower &&
        hasNumbers &&
        hasSpecial) {
      strength = 'Strong';
      color = Colors.green;
      percent = 1.0;
    } else if (password.length >= 6 && hasLetters && hasNumbers) {
      strength = 'Medium';
      color = Colors.orange;
      percent = 0.66;
    }

    setState(() {
      _passwordStrength = strength;
      _strengthColor = color;
      _strengthPercent = percent;
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

  bool _isValidEmail(String email) {
    final emailRegex = RegExp(
      r"^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$",
      caseSensitive: false,
    );
    return emailRegex.hasMatch(email);
  }

  Future<void> _handleRegister() async {
    final name = nameController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      _showSnackbar("Please complete all fields.");
      return;
    }

    if (!_isValidEmail(email)) {
      _showSnackbar("Please enter a valid email address.");
      return;
    }

    if (_passwordStrength == 'Weak') {
      _showSnackbar("Password is too weak");
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_${email}_name', name);
    await prefs.setString('user_${email}_password', password);

    _showSnackbar("Registered successfully!");

    Future.delayed(const Duration(seconds: 1), () {
      Navigator.pushReplacementNamed(context, '/login');
    });
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
                'Create\nAccount',
                style: TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 40),
              TextField(
                controller: nameController,
                style: montserrat,
                decoration: InputDecoration(
                  hintText: 'Full Name',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: SvgPicture.asset(
                      'Images/User Duotone Icon.svg',
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
                onChanged: _calculatePasswordStrength,
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
              const SizedBox(height: 10),
              if (_passwordStrength.isNotEmpty)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Stack(
                      children: [
                        Container(
                          height: 10,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 500),
                          curve: Curves.easeInOut,
                          height: 10,
                          width:
                              MediaQuery.of(context).size.width *
                                  _strengthPercent -
                              48,
                          decoration: BoxDecoration(
                            color: _strengthColor,
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Strength: $_passwordStrength',
                      style: TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: 13,
                        color: _strengthColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _handleRegister,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    backgroundColor: themeColor,
                  ),
                  child: const Text(
                    'Sign Up',
                    style: TextStyle(
                      color: Colors.white,
                      fontFamily: "Montserrat",
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
                children: const [
                  SvgSocialButton(svgPath: 'Images/Google Icon.svg'),
                  SizedBox(width: 16),
                  SvgSocialButton(svgPath: 'Images/Apple SVG Icon.svg'),
                  SizedBox(width: 16),
                  SvgSocialButton(svgPath: 'Images/Facebook SVG Icons.svg'),
                ],
              ),
              const Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Already have an account? ", style: montserrat),
                  GestureDetector(
                    onTap: () {
                      Navigator.pushReplacementNamed(context, '/login');
                    },
                    child: Text(
                      'Login',
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

  const SvgSocialButton({super.key, required this.svgPath});

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: 22,
      backgroundColor: Colors.grey.shade200,
      child: SvgPicture.asset(svgPath, width: 24, height: 24),
    );
  }
}
