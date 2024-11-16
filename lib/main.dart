import 'package:flutter/material.dart';
import 'package:a114514/learn.dart'; // 根据项目名称正确导入

void main() => runApp(MyApp());


class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter 中文示例',
      theme: ThemeData(
        fontFamily: 'misans', // 使用自定义的中文字体
      ),
      home: Scaffold(
        appBar: AppBar(
          title: Text('中文输出示例'),
        ),
        body: Center(
          child: ContentWidget(),
        ),
      ),
    );
  }
}

class ContentWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: getLearningContent(), // 调用异步函数
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else if (snapshot.hasData) {
          return Text(
            snapshot.data!,
            style: TextStyle(fontSize: 20),
          );
        } else {
          return Text('No data found');
        }
      },
    );
  }
}
