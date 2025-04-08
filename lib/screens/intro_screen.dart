import 'package:flutter/material.dart';
import 'package:meleto/screens/auth/login_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class IntroScreen extends StatefulWidget {
  const IntroScreen({super.key});

  @override
  State<IntroScreen> createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen> {
  final PageController _pageController = PageController();

  int _currentInedx = 0;

  final List<Widget> _pages = [
    IntroComponent(
      title: "欢迎使用Meleto",
      description: "让您的笔记管理更简单、更高效",
      imagePath: "assets/images/intro1.png",
    ),
    IntroComponent(
      title: "笔记管理",
      description: "轻松创建笔记、与他人交流分享、互相学习",
      imagePath: "assets/images/intro2.png",
    ),
    IntroComponent(
      title: "本地存储",
      description: "安全存储您的数据，随时随地访问",
      imagePath: "assets/images/intro3.png",
    ),
  ];

  void _skip() {
    _pageController.animateToPage(
      _pages.length - 1,
      duration: Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  void _onNext() {
    if (_currentInedx < _pages.length - 1) {
      _pageController.nextPage(
        duration: Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    } else {
      _onFinish();
    }
  }

  Future<void> _onFinish() async {
    // 保存用户已经看过介绍页面的状态
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('hasSeenIntro', true);

    if (!mounted) return;

    // 导航到登录页面
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: _pages.length,
            onPageChanged:
                (index) => {
                  setState(() {
                    _currentInedx = index;
                  }),
                },
            itemBuilder: (context, index) => _pages[index],
          ),
          _currentInedx == _pages.length - 1
              ? SizedBox.shrink()
              : Positioned(
                left: 40,
                bottom: 20,
                child: TextButton(
                  onPressed: () {
                    _skip();
                  },
                  child: Text(
                    "Skip",
                    style: TextStyle(
                      color: Colors.red,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
          Positioned(
            right: 40,
            bottom: 20,
            child: TextButton(
              onPressed: () {
                _onNext();
              },
              child: Text(
                _currentInedx == _pages.length - 1 ? "Finish" : "next",
                style: TextStyle(
                  color: Colors.blue,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class IntroComponent extends StatelessWidget {
  final String title;
  final String description;
  final String imagePath;
  const IntroComponent({
    super.key,
    required this.title,
    required this.description,
    required this.imagePath,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.asset(imagePath, height: 300),
        SizedBox(height: 30),
        Text(
          title,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            // fontFamily: "Noto Serif SC",
          ),
        ),
        SizedBox(height: 20),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            description,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[700],
              // fontFamily: "Noto Serif SC",
            ),
          ),
        ),
      ],
    );
  }
}
