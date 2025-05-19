import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'wishlist_screen.dart';
import 'settings_tab.dart';
import 'groceries_screen.dart';
import 'cart_page.dart';
import 'search_screen.dart';

class HomeScreen extends StatefulWidget {
  final String email;
  const HomeScreen({super.key, required this.email});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  double _fabX = 0;
  String userName = '';
  String gender = 'male';
  File? customImage;

  final List<GlobalKey> _iconKeys = List.generate(5, (_) => GlobalKey());
  late List<Widget> _pages;
  List _allProducts = [];

  @override
  void initState() {
    super.initState();
    _pages = List.generate(5, (_) => const SizedBox());
    _loadUserData();
    WidgetsBinding.instance.addPostFrameCallback((_) => _updateFabPosition());
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final name = prefs.getString('user_${widget.email}_name') ?? '';
    final savedGender =
        prefs.getString('user_${widget.email}_gender') ?? 'male';
    final imagePath = prefs.getString('user_${widget.email}_avatarPath');

    if (!prefs.containsKey('user_${widget.email}_gender')) {
      await prefs.setString('user_${widget.email}_gender', 'male');
    }

    setState(() {
      userName = name;
      gender = savedGender;
      customImage = imagePath != null ? File(imagePath) : null;
      _refreshTabs();
    });
  }

  void setProductList(List newProducts) {
    setState(() {
      _allProducts = newProducts;
      _refreshTabs();
    });
  }

  void _refreshTabs() {
    _pages = [
      GroceriesScreen(onProductsLoaded: setProductList),
      WishlistScreen(),
      CartPage(
        onBackToHome: () {
          setState(() {
            _selectedIndex = 0;
          });
          WidgetsBinding.instance.addPostFrameCallback(
            (_) => _updateFabPosition(),
          );
        },
      ),
      SearchScreen(products: _allProducts),
      SettingsTab(
        name: userName,
        email: widget.email,
        gender: gender,
        customImage: customImage,
        onGenderChanged: _handleGenderChange,
        onPickImage: _pickImage,
        onRemoveImage: _removeImage,
        onNameChanged: (name) {
          if (userName != name) {
            setState(() {
              userName = name;
            });
          }
        },
      ),
    ];

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(milliseconds: 250), () {
        if (mounted) _updateFabPosition();
      });
    });
  }

  Future<void> _handleGenderChange(bool isFemale) async {
    final prefs = await SharedPreferences.getInstance();
    final newGender = isFemale ? 'female' : 'male';
    await prefs.setString('user_${widget.email}_gender', newGender);
    setState(() {
      gender = newGender;
      _refreshTabs();
    });
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile == null) return;

    final appDir = await getApplicationDocumentsDirectory();
    final fileName = path.basename(pickedFile.path);
    final savedImage = await File(
      pickedFile.path,
    ).copy('${appDir.path}/$fileName');

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_${widget.email}_avatarPath', savedImage.path);

    setState(() {
      customImage = savedImage;
      _refreshTabs();
    });
  }

  Future<void> _removeImage() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_${widget.email}_avatarPath');
    setState(() {
      customImage = null;
      _refreshTabs();
    });
  }

  void _updateFabPosition() {
    final keyContext = _iconKeys[_selectedIndex].currentContext;
    if (keyContext != null) {
      final box = keyContext.findRenderObject() as RenderBox;
      final position = box.localToGlobal(Offset.zero);
      setState(() {
        _fabX = position.dx + box.size.width / 2 - 28;
      });
    }
  }

  Future<void> _onItemTapped(int index) async {
    setState(() {
      _selectedIndex = index;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) => _updateFabPosition());
  }

  final List<String> _icons = [
    'Images/Home Duotone Icon.svg',
    'Images/Heart SVG Icon.svg',
    'Images/Cart Duotone Icon.svg',
    'Images/Search Icon.svg',
    'Images/Settings Icons (2).svg',
  ];

  final List<String> _labels = [
    'Home',
    'Wishlist',
    'Cart',
    'Search',
    'Setting',
  ];

  @override
  Widget build(BuildContext context) {
    const fabSize = 56.0;
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      extendBody: true,
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 6,
        centerTitle: true,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Transform.scale(
              scale: 3.5,
              child: SvgPicture.asset('Images/Logo.svg', height: 40),
            ),
            const SizedBox(width: 20),
            const Text(
              'AMMM!',
              style: TextStyle(
                fontSize: 28,
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: GestureDetector(
              onTap: () => _onItemTapped(4),
              child: CircleAvatar(
                radius: 20,
                backgroundColor: Colors.grey.shade200,
                child:
                    customImage != null
                        ? ClipOval(
                          child: Image.file(
                            customImage!,
                            width: 40,
                            height: 40,
                            fit: BoxFit.cover,
                          ),
                        )
                        : SvgPicture.asset(
                          gender == 'female'
                              ? 'Images/Untitled Design 366x366.svg'
                              : 'Images/Manavatar.svg',
                          width: 80,
                          height: 80,
                        ),
              ),
            ),
          ),
        ],
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: Stack(
        clipBehavior: Clip.none,
        children: [
          BottomAppBar(
            shape: const CircularNotchedRectangle(),
            notchMargin: 6.0,
            child: SizedBox(
              height: 64,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: List.generate(5, (index) {
                  final isSelected = _selectedIndex == index;
                  return GestureDetector(
                    onTap: () => _onItemTapped(index),
                    child: Container(
                      key: _iconKeys[index],
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Visibility(
                            visible: !isSelected,
                            maintainSize: true,
                            maintainAnimation: true,
                            maintainState: true,
                            child: SvgPicture.asset(_icons[index], height: 23),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _labels[index],
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight:
                                  isSelected
                                      ? FontWeight.w600
                                      : FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),
          AnimatedPositioned(
            duration: const Duration(milliseconds: 250),
            curve: Curves.fastOutSlowIn,
            left: _fabX,
            bottom: 45 + bottomPadding,
            child: Material(
              color: Colors.transparent,
              elevation: 10,
              shape: const CircleBorder(),
              child: Container(
                width: fabSize,
                height: fabSize,
                decoration: BoxDecoration(
                  color: const Color(0xFFF2F2F2),
                  shape: BoxShape.circle,
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 12,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Center(
                  child: SvgPicture.asset(_icons[_selectedIndex], height: 22),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
