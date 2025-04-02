import 'package:flutter/material.dart';

/// 应用主页面
/// 用户完成介绍流程后显示的主要界面
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Meleto'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              '欢迎使用 Meleto!',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            const Text('这是应用的主页面'),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                // 这里可以添加其他操作
              },
              child: const Text('开始使用'),
            ),
          ],
        ),
      ),
    );
  }
}