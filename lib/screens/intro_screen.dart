import 'package:flutter/material.dart';
import 'package:meleto/screens/auth/login_screen.dart';
import 'package:meleto/screens/home_screen.dart';

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
      title: "欢迎使用ToDo",
      description: "让您的任务管理更简单、更高效",
      imagePath: "assets/images/intro1.png",
    ),
    IntroComponent(
      title: "任务管理",
      description: "轻松创建任务、设置优先级、跟踪进度",
      imagePath: "assets/images/intro2.png",
    ),
    IntroComponent(
      title: "及时提醒",
      description: "永不错过重要任务，按时完成待办事项",
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

  void _onFinish() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => LoginScreen()
            // (context) => Scaffold(body: Center(child: Text("Home Screen"))),
      ),
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
