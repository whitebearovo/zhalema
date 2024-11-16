//import 'dart:convert';
import 'package:http/http.dart' as http;

void main() async {
  // 定义 URL
  final url = Uri.parse('https://localapi.gczxtgx.top/api/v2');
  
  // 发送 GET 请求
  final response = await http.get(url);
if (response.statusCode == 200) {
  print('nothing wrong');
  } else {
    // 如果请求失败，输出错误信息
    print('请求失败，状态码: ${response.statusCode}.');
  }
}
Future<String> getLearningContent() async {
  final url = Uri.parse('https://gczxtgx.top');
  final response = await http.get(url);
  return "状态码：${response.statusCode}";
}