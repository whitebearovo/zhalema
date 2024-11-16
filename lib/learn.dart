import 'package:http/http.dart' as http;

Future<String> getLearningContent(String url) async {
  final response = await http.get(Uri.parse(url));  // 使用传入的 URL
  if (response.statusCode == 200) {
    return "状态码：${response.statusCode}";
  } else {
    throw Exception('Failed to load content');
  }
}
