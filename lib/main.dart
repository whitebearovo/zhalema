import 'package:flutter/material.dart';
import 'package:a114514/learn.dart'; // 根据项目名称正确导入

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Silema',
      theme: ThemeData(
        fontFamily: 'misans', // 使用自定义的中文字体
      ),
      home: Scaffold(
        appBar: AppBar(
          title: Text('Silema'),
        ),
        body: Center(
          child: ContentWidget(),
        ),
      ),
    );
  }
}

class ContentWidget extends StatefulWidget {
  @override
  _ContentWidgetState createState() => _ContentWidgetState();
}

class _ContentWidgetState extends State<ContentWidget> {
  String? _content; // 用于存储异步结果
  bool _isLoading = false; // 控制加载状态
  bool _isValidUrl = true; // 控制 URL 格式验证状态
  TextEditingController _urlController = TextEditingController(); // 控制输入框内容
  TextEditingController _statusCodeController = TextEditingController(); // 控制状态码输入框内容
  String _url = 'https://'; // 默认 URL
  int? _expectedStatusCode; // 用户输入的期望状态码

  // URL 格式验证
  bool _isValidUrlFormat(String url) {
    final urlPattern = r'^(https?|ftp)://[^\s/$.?#].[^\s]*$';
    final regExp = RegExp(urlPattern);
    return regExp.hasMatch(url);
  }

  // 自动添加 http:// 或 https:// 头部
  String _addHttpHeaderIfNeeded(String url) {
    if (url.isEmpty) return url;

    // 如果 URL 没有以 http:// 或 https:// 开头，则自动添加 http://
    if (!url.startsWith('http://') && !url.startsWith('https://')) {
      return 'http://$url'; // 默认添加 http://
    }
    return url;
  }

  // 异步函数，触发时获取内容，接收 URL 参数
  Future<void> _loadContent() async {
    setState(() {
      _isLoading = true; // 开始加载
      _url = _urlController.text.trim(); // 获取 URL
      _url = _addHttpHeaderIfNeeded(_url); // 自动添加 http 头部
      _isValidUrl = _isValidUrlFormat(_url); // 验证 URL 格式
      _expectedStatusCode = int.tryParse(_statusCodeController.text); // 获取期望状态码
    });

    // 如果 URL 格式无效，复位并返回
    if (!_isValidUrl) {
      _reset(); // 调用复位方法清空内容和输入框
      setState(() {
        _content = 'Enter the right url'; // 提示用户 URL 格式无效
      });
      return;
    }

    try {
      final result = await getLearningContent(_url).timeout(
        Duration(seconds: 8), // 设置超时时间为 8 秒
        onTimeout: () {
          // 超时后执行
          return '114514'; // 超时返回 114514
        },
      );

      setState(() {
        if (_expectedStatusCode != null) {
          // 获取实际返回的状态码并与用户输入的状态码比较
          int actualStatusCode = int.tryParse(result.split(":")[1] ?? '') ?? 0;
          if (actualStatusCode != _expectedStatusCode) {
            _content = 'Something Wrong';
          } else {
            _content = result; // 返回正常内容
          }
        } else {
          _content = result; // 返回正常内容
        }
      });
    } catch (e) {
      setState(() {
        _content = 'Error: Failed to load content. Please try again.'; // 错误提示
      });
    } finally {
      setState(() {
        _isLoading = false; // 加载结束
      });
    }
  }

  // 清除内容的方法
  void _clearContent() {
    setState(() {
      _content = null; // 清除显示内容
      _urlController.clear(); // 清空 URL 输入框
      _statusCodeController.clear(); // 清空状态码输入框
    });
  }

  // 重置按钮：恢复初始状态
  void _reset() {
    setState(() {
      _content = null; // 清除内容
      _urlController.clear(); // 清空输入框
      _statusCodeController.clear(); // 清空状态码输入框
      _isLoading = false; // 重置加载状态
      _isValidUrl = true; // 重置 URL 格式验证状态
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0), // 添加内边距
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // URL 输入框
          TextField(
            controller: _urlController,
            decoration: InputDecoration(
              labelText: 'URL',
              hintText: 'https://',
              border: OutlineInputBorder(),
              errorText: _isValidUrl ? null : 'URL Wrong', // 显示错误提示
            ),
            onChanged: (text) {
              setState(() {
                _url = text; // 更新 URL
              });
            },
          ),
          SizedBox(height: 20), // 间距
          // 状态码输入框
          TextField(
            controller: _statusCodeController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: 'Expected Status Code',
              hintText: '200',
              border: OutlineInputBorder(),
            ),
            onChanged: (text) {
              setState(() {
                _expectedStatusCode = int.tryParse(text); // 更新期望的状态码
              });
            },
          ),
          SizedBox(height: 20), // 间距
          // 内容显示部分
          _buildContentDisplay(),
          SizedBox(height: 20), // 间距
          // 按钮部分
          _buildButtons(),
        ],
      ),
    );
  }

  // 显示内容部分的 UI
  Widget _buildContentDisplay() {
    if (_isLoading) {
      return CircularProgressIndicator(); // 加载时显示进度条
    } else {
      return Text(
        _content ?? 'Click "Load" to fetch content.', // 提示用户加载内容
        style: TextStyle(fontSize: 20),
        textAlign: TextAlign.center,
      );
    }
  }

  // 按钮部分的 UI
  Widget _buildButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ElevatedButton(
          onPressed: _isLoading || !_isValidUrl ? null : _loadContent, // 防止无效 URL 点击
          child: Text('Load'),
        ),
        SizedBox(width: 10), // 按钮之间的间距
        ElevatedButton(
          onPressed: _content == null ? null : _clearContent, // 清除内容
          child: Text('Clear'),
        ),
        SizedBox(width: 10), // 按钮之间的间距
        ElevatedButton(
          onPressed: _reset, // 重置按钮
          child: Text('Reset'),
        ),
      ],
    );
  }
}
