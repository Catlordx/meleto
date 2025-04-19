import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:meleto/screens/auth/login_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _darkMode = false;
  bool _notifications = true;
  bool _isLoading = false;
  final _oldPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _showChangePasswordDialog() {
    // 重置控制器
    _oldPasswordController.clear();
    _newPasswordController.clear();
    _confirmPasswordController.clear();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('修改密码'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _oldPasswordController,
                  decoration: const InputDecoration(
                    labelText: '当前密码',
                    border: OutlineInputBorder(),
                  ),
                  obscureText: true,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _newPasswordController,
                  decoration: const InputDecoration(
                    labelText: '新密码',
                    border: OutlineInputBorder(),
                  ),
                  obscureText: true,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _confirmPasswordController,
                  decoration: const InputDecoration(
                    labelText: '确认新密码',
                    border: OutlineInputBorder(),
                  ),
                  obscureText: true,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('取消'),
            ),
            TextButton(
              onPressed: () => _changePassword(),
              child: const Text('确认'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _changePassword() async {
    // 验证输入
    if (_oldPasswordController.text.isEmpty ||
        _newPasswordController.text.isEmpty ||
        _confirmPasswordController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('请填写所有字段')));
      return;
    }

    if (_newPasswordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('新密码和确认密码不匹配')));
      return;
    }

    if (_newPasswordController.text.length < 6) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('新密码至少需要6个字符')));
      return;
    }

    // 关闭对话框
    Navigator.of(context).pop();

    // 显示加载状态
    setState(() => _isLoading = true);

    try {
      // 获取用户ID和令牌
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('userid');
      final token = prefs.getString('token');

      if (userId == null || token == null) {
        throw Exception('未登录');
      }

      // 发送请求到后端API
      final response = await http.post(
        Uri.parse('http://10.0.2.2:8080/api/user/changepassword'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'old_password': _oldPasswordController.text,
          'new_password': _newPasswordController.text,
        }),
      );

      if (!mounted) return;
      setState(() => _isLoading = false);

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('密码修改成功')));
      } else {
        final errorData = json.decode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('密码修改失败: ${errorData['message'] ?? '未知错误'}')),
        );
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const LoginScreen()),
          (route) => false,
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('密码修改失败: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('设置')),
      body: ListView(
        children: [
          SwitchListTile(
            title: const Text('深色模式'),
            subtitle: const Text('切换应用的主题'),
            value: _darkMode,
            onChanged: (value) {
              setState(() {
                _darkMode = value;
                // 这里需要实现实际的主题切换逻辑
              });
            },
          ),
          SwitchListTile(
            title: const Text('通知'),
            subtitle: const Text('启用或禁用推送通知'),
            value: _notifications,
            onChanged: (value) {
              setState(() {
                _notifications = value;
              });
            },
          ),
          ListTile(
            title: const Text('隐私政策'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              // 跳转到隐私政策页面
            },
          ),
          ListTile(
            title: const Text('修改密码'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              _showChangePasswordDialog();
            },
          ),
          ListTile(
            title: const Text('用户协议'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              // 跳转到用户协议页面
            },
          ),
          ListTile(
            title: const Text('关于我们'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              // 跳转到关于我们页面
            },
          ),
          const SizedBox(height: 16),
          // 将退出登录按钮移到设置页面也是一个好选择
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: OutlinedButton(
              onPressed: () {
                // 这里可以调用profile_screen中的_logout方法
                _logout();
                // Navigator.pop(context);
                // 或者直接在这里实现退出逻辑
              },
              child: const Text('退出登录'),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _logout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('退出登录'),
            content: const Text('确定要退出登录吗？'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('取消'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('确定'),
              ),
            ],
          ),
    );

    if (confirmed == true) {
      setState(() => _isLoading = true);

      try {
        // 模拟退出登录
        await Future.delayed(const Duration(seconds: 1));

        if (!mounted) return;

        final prefs = await SharedPreferences.getInstance();
        prefs.clear();

        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const LoginScreen()),
          (route) => false,
        );
      } catch (e) {
        if (!mounted) return;

        setState(() => _isLoading = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('退出失败: ${e.toString()}')));
      }
    }
  }
}
