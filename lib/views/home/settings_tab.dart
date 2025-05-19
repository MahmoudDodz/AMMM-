import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shared_preferences/shared_preferences.dart';

const Color themeColor = Color(0xFFFE4F28);

class SettingsTab extends StatefulWidget {
  final String name;
  final String email;
  final String gender;
  final File? customImage;
  final ValueChanged<bool> onGenderChanged;
  final VoidCallback onPickImage;
  final VoidCallback onRemoveImage;
  final ValueChanged<String> onNameChanged;

  const SettingsTab({
    super.key,
    required this.name,
    required this.email,
    required this.gender,
    required this.customImage,
    required this.onGenderChanged,
    required this.onPickImage,
    required this.onRemoveImage,
    required this.onNameChanged,
  });

  @override
  State<SettingsTab> createState() => _SettingsTabState();
}

class _SettingsTabState extends State<SettingsTab> {
  late TextEditingController _emailController;
  late TextEditingController _passwordController;
  late TextEditingController _nameController;
  bool _obscurePassword = true;
  late String _originalEmail;

  @override
  void initState() {
    super.initState();
    _originalEmail = widget.email;
    _emailController = TextEditingController(text: widget.email);
    _passwordController = TextEditingController();
    _nameController = TextEditingController(text: widget.name);

    _nameController.addListener(() {
      widget.onNameChanged(_nameController.text);
    });

    _loadPassword();
  }

  bool _isValidEmail(String email) {
    final emailRegex = RegExp(
      r"^[\w\.-]+@([\w-]+\.)+[\w-]{2,}$",
      caseSensitive: false,
    );
    return emailRegex.hasMatch(email);
  }

  void _showSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
        backgroundColor: themeColor,
      ),
    );
  }

  Future<void> _loadPassword() async {
    final prefs = await SharedPreferences.getInstance();
    final storedPassword =
        prefs.getString('user_${_originalEmail}_password') ?? '';
    setState(() {
      _passwordController.text = storedPassword;
    });
  }

  Future<void> _saveChanges() async {
    final prefs = await SharedPreferences.getInstance();
    final newEmail = _emailController.text.trim();
    final newPassword = _passwordController.text.trim();
    final newName = _nameController.text.trim();

    if (newName.isEmpty || newEmail.isEmpty || newPassword.isEmpty) {
      _showSnackbar("All fields are required.");
      return;
    }

    if (!_isValidEmail(newEmail)) {
      _showSnackbar("Please enter a valid email address.");
      return;
    }

    final passwordValid =
        newPassword.length >= 8 &&
        RegExp(r'[A-Z]').hasMatch(newPassword) &&
        RegExp(r'[a-z]').hasMatch(newPassword) &&
        RegExp(r'[0-9]').hasMatch(newPassword) &&
        RegExp(r'[!@#\\$%^&*(),.?":{}|<>]').hasMatch(newPassword);

    if (!passwordValid) {
      _showSnackbar(
        "Password must be at least 8 characters long and include upper/lowercase letters, numbers, and special characters.",
      );
      return;
    }

    if (_originalEmail != newEmail &&
        prefs.containsKey('user_${newEmail}_email')) {
      _showSnackbar("Email already in use by another account.");
      return;
    }

    if (_originalEmail != newEmail) {
      await prefs.remove('user_${_originalEmail}_email');
      await prefs.remove('user_${_originalEmail}_password');
      await prefs.remove('user_${_originalEmail}_name');
      await prefs.remove('user_${_originalEmail}_gender');
      await prefs.remove('user_${_originalEmail}_avatarPath');
    }

    await prefs.setString('user_${newEmail}_email', newEmail);
    await prefs.setString('user_${newEmail}_password', newPassword);
    await prefs.setString('user_${newEmail}_name', newName);

    setState(() {
      _originalEmail = newEmail;
    });

    widget.onNameChanged(newName);
    _showSnackbar("Changes saved successfully.");
  }

  void _confirmLogout() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          title: const Text('Logout'),
          content: const Text('Are you sure you want to logout?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: themeColor),
              onPressed: () {
                Navigator.of(
                  context,
                ).pushNamedAndRemoveUntil('/login', (route) => false);
              },
              child: const Text(
                'Logout',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.only(
          bottom: 100,
          left: 24,
          right: 24,
          top: 16,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 8),
            Text(
              _nameController.text.isNotEmpty
                  ? _nameController.text
                  : 'No Name',
              key: ValueKey(_nameController.text),
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                fontFamily: 'Montserrat',
              ),
            ),
            const SizedBox(height: 12),
            Stack(
              alignment: Alignment.bottomRight,
              children: [
                ClipOval(
                  child: Container(
                    width: 150,
                    height: 150,
                    color: Colors.grey.shade200,
                    child: Transform.translate(
                      offset: const Offset(0, 18),
                      child:
                          widget.customImage != null
                              ? Image.file(
                                widget.customImage!,
                                fit: BoxFit.cover,
                              )
                              : SvgPicture.asset(
                                widget.gender == 'female'
                                    ? 'Images/Untitled Design 366x366.svg'
                                    : 'Images/Manavatar.svg',
                                fit: BoxFit.cover,
                              ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: GestureDetector(
                    onTap: widget.onPickImage,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 6,
                          ),
                        ],
                      ),
                      child: SvgPicture.asset(
                        'Images/Edit SVG Icon.svg',
                        width: 24,
                        height: 24,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (widget.customImage != null)
              TextButton(
                onPressed: widget.onRemoveImage,
                style: TextButton.styleFrom(foregroundColor: themeColor),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SvgPicture.asset(
                      'Images/Remove Ellipse Icon.svg',
                      width: 20,
                      height: 20,
                      color: themeColor,
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Remove Photo',
                      style: TextStyle(
                        color: themeColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("Male"),
                Switch(
                  value: widget.gender == 'female',
                  onChanged: widget.onGenderChanged,
                  activeColor: themeColor,
                ),
                const Text("Female"),
              ],
            ),
            const SizedBox(height: 18),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Personal Details',
                style: TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Name',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: 'Email Address',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _passwordController,
              obscureText: _obscurePassword,
              decoration: InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                suffixIcon: IconButton(
                  icon: SvgPicture.asset(
                    _obscurePassword
                        ? 'Images/Eye Slash Icon.svg'
                        : 'Images/Eye SVG Icon.svg',
                    width: 24,
                    height: 24,
                    fit: BoxFit.scaleDown,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                  },
                ),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _saveChanges,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: themeColor,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 4,
                    ),
                    child: const Text(
                      'Save Changes',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton(
                    onPressed: _confirmLogout,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: themeColor,
                      side: const BorderSide(color: themeColor),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 14),
                      child: Text('Logout', style: TextStyle(fontSize: 16)),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
