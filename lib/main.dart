import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/intro_screen.dart';
import 'screens/home_screen.dart'; // 导入主页面

/// 应用程序入口点
void main() async {
  // 确保Flutter绑定初始化
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

/// 应用程序根组件
/// 定义全局样式和主题
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Meleto', // 应用名称
      theme: ThemeData(
        // 应用主题配置
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true, // 启用Material 3设计
      ),
      home: const AppStartPage(), // 启动页面
      debugShowCheckedModeBanner: false, // 移除调试标识
    );
  }
}

/// 应用启动页面
/// 负责检查用户是否首次使用应用，并决定导航到介绍页或主页
class AppStartPage extends StatefulWidget {
  const AppStartPage({super.key});

  @override
  State<AppStartPage> createState() => _AppStartPageState();
}

class _AppStartPageState extends State<AppStartPage> {
  bool? _hasSeenIntro; // 用户是否已查看过介绍页，null表示正在加载
  bool _isLoading = true; // 标记是否正在加载数据
  String? _errorMessage; // 错误信息，如果有的话

  @override
  void initState() {
    super.initState();
    _checkFirstTime(); // 初始化时检查是否首次使用
  }

  /// 检查用户是否首次打开应用
  /// 通过SharedPreferences存储和获取用户状态
  Future<void> _checkFirstTime() async {
    try {
      // 获取SharedPreferences实例
      final prefs = await SharedPreferences.getInstance();

      // 读取'hasSeenIntro'键的值，如果不存在则默认为false（首次使用）
      final hasSeenIntro = prefs.getBool('hasSeenIntro') ?? false;

      // 更新状态
      if (mounted) {
        setState(() {
          _hasSeenIntro = hasSeenIntro;
          _isLoading = false;
        });
      }
    } catch (e) {
      // 错误处理
      if (mounted) {
        setState(() {
          _errorMessage = "加载用户偏好设置时出错: $e";
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // 显示错误信息（如有）
    if (_errorMessage != null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 48),
              const SizedBox(height: 16),
              Text(_errorMessage!, style: const TextStyle(fontSize: 16)),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _errorMessage = null;
                    _isLoading = true;
                  });
                  _checkFirstTime(); // 重试
                },
                child: const Text('重试'),
              ),
            ],
          ),
        ),
      );
    }

    // 显示加载指示器
    if (_isLoading || _hasSeenIntro == null) {
      return const Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('正在加载...', style: TextStyle(fontSize: 16)),
            ],
          ),
        ),
      );
    }

    // 根据用户状态导航到适当的页面
    if (_hasSeenIntro!) {
      return const HomeScreen(); // 已查看介绍，直接进入主页
    } else {
      return const IntroScreen(); // 首次使用，显示介绍页
    }
  }
}
