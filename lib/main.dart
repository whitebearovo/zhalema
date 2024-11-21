import 'dart:async'; // Import dart:async for handling timeouts
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Example',
      theme: ThemeData(
        fontFamily: 'misans', // Using custom font
      ),
      home: Scaffold(
        appBar: AppBar(
          title: Text('Zhalema'),
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
  String? _content; // To store the async result
  bool _isLoading = false; // Loading state
  bool _isValidUrl = true; // URL validation state
  TextEditingController _urlController = TextEditingController(); // URL input controller
  TextEditingController _statusCodeController = TextEditingController(); // Status code input controller
  String _url = 'https://'; // Default URL
  int _expectedStatusCode = 200; // Default expected status code is 200

  // URL format validation
  bool _isValidUrlFormat(String url) {
    final urlPattern = r'^(https?|ftp)://[^\s/$.?#].[^\s]*$';
    final regExp = RegExp(urlPattern);
    return regExp.hasMatch(url);
  }

  // Add http:// or https:// if not present
  String _addHttpHeaderIfNeeded(String url) {
    if (url.isEmpty) return url;

    // If URL doesn't start with http:// or https://, add http://
    if (!url.startsWith('http://') && !url.startsWith('https://')) {
      return 'http://$url'; // Default to add http://
    }
    return url;
  }

  // Async function to load content, receives the URL parameter
  Future<void> _loadContent() async {
    // Validate if the URL or expected status code is empty
    if (_urlController.text.trim().isEmpty) {
      setState(() {
        _content = 'Please enter a valid URL';
        _isLoading = false;
      });
      return;
    }

    // Default to 200 if the status code input is empty
    if (_statusCodeController.text.trim().isEmpty) {
      _expectedStatusCode = 200;
    } else {
      _expectedStatusCode = int.tryParse(_statusCodeController.text) ?? 200;
    }

    setState(() {
      _isLoading = true; // Start loading
      _url = _urlController.text.trim(); // Get URL from input
      _url = _addHttpHeaderIfNeeded(_url); // Add HTTP header if needed
      _isValidUrl = _isValidUrlFormat(_url); // Validate URL format
    });

    if (_isValidUrl) {
      try {
        // Add timeout mechanism, automatically stop the request after 5 seconds
        var result = await realHttpRequest(_url).timeout(Duration(seconds: 5));

        int actualStatusCode = 0;
        String responseBody = '';
        String errorMessage = '';

        // Get the statusCode, ensure it's an integer
        if (result['statusCode'] is int) {
          actualStatusCode = result['statusCode'];
        } else if (result['statusCode'] is String) {
          actualStatusCode = int.tryParse(result['statusCode']) ?? 0;
        }

        // Get the body, ensure it's a string
        if (result['body'] is String) {
          responseBody = result['body'];
        }

        // Check if actual status code matches the expected status code
        if (actualStatusCode != _expectedStatusCode) {
          errorMessage = 'Error: Expected status code $_expectedStatusCode, but got $actualStatusCode';
        }

        setState(() {
          _content = errorMessage.isNotEmpty
              ? errorMessage
              : 'Actual Status Code: $actualStatusCode\nResponse Body: $responseBody';
          _isLoading = false; // Request completed, stop loading
        });
      } on TimeoutException {
        setState(() {
          _content = 'Request timed out, please try again later'; // Timeout handling
          _isLoading = false;
        });
      }
    }
  }

  // Perform the actual HTTP request
  Future<Map<String, dynamic>> realHttpRequest(String url) async {
    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        return {
          'statusCode': response.statusCode,
          'body': response.body,
        };
      } else {
        return {
          'statusCode': response.statusCode,
          'body': response.body,
        };
      }
    } catch (e) {
      return {
        'statusCode': 0,
        'body': 'Request error: $e',
      };
    }
  }

  // Clear input fields and output content
  void _clearContent() {
    setState(() {
      _urlController.clear(); // Clear the URL input field
      _statusCodeController.clear(); // Clear the status code input field
      _content = null; // Clear the content
      _isLoading = false; // Reset loading state
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          // URL input field
          TextField(
            controller: _urlController,
            decoration: InputDecoration(
              labelText: 'Enter URL',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.0),
              ),
              prefixIcon: Icon(Icons.link),
              filled: true,
              fillColor: Colors.grey[200],
            ),
            keyboardType: TextInputType.url,
          ),
          SizedBox(height: 20),

          // Expected status code input field
          TextField(
            controller: _statusCodeController,
            decoration: InputDecoration(
              labelText: 'Expected Status Code',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.0),
              ),
              prefixIcon: Icon(Icons.code),
              filled: true,
              fillColor: Colors.grey[200],
            ),
            keyboardType: TextInputType.number,
          ),
          SizedBox(height: 20),

          // Load content button
          ElevatedButton(
            onPressed: _loadContent,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue, // Set button background color
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0), // Set rounded corners for button
              ),
              padding: EdgeInsets.symmetric(horizontal: 32.0, vertical: 12.0), // Set button padding
            ),
            child: _isLoading
                ? CircularProgressIndicator(color: Colors.white) // Show progress indicator while loading
                : Text(
              'Load Content',
              style: TextStyle(fontSize: 16, color: Colors.white), // Set button text style
            ),
          ),
          SizedBox(height: 20),

          // Clear button
          ElevatedButton(
            onPressed: _clearContent,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red, // Set button background color
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0), // Set rounded corners for button
              ),
              padding: EdgeInsets.symmetric(horizontal: 32.0, vertical: 12.0), // Set button padding
            ),
            child: Text(
              'Clear Content',
              style: TextStyle(fontSize: 16, color: Colors.white), // Set button text style
            ),
          ),
          SizedBox(height: 20),

          // Display the result of the request
          if (_content != null) ...[
            Text(
              _content!,
              style: TextStyle(fontSize: 16, color: Colors.black),
              textAlign: TextAlign.center,
            ),
          ]
        ],
      ),
    );
  }
}
