import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter JS',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrange),
      ),
      home: const MyHomePage(title: 'Flutter JS'),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late WebViewController _controller;
  String totalFromJS = '';

  //Send data from JS to Flutter
  final String htmlContentJStoFlutter = r'''
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>WebView JS</title>
</head>
<body>
    <h1>My Cart 
    <p id="total">Total:2 $120.00</p>
    </h1>
<button style="padding: 16px 32px; font-size: 20px; width: 100%;" onclick="sendTotalToFlutter()">Send Total to Flutter</button>
    
<script>
    function sendTotalToFlutter() {
        var totalPrice = document.getElementById("total").innerText;
        FlutterChannel.postMessage(totalPrice);
    }
</script>
</body>
</html>''';

  //Send data from Flutter to JS
  final String htmlContentFlutterToJS = r''' ''';

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..addJavaScriptChannel(
        'FlutterChannel',
        onMessageReceived: (JavaScriptMessage message) {
          setState(() {
            totalFromJS = message.message;
          });
        },
      )
      ..loadHtmlString(htmlContentJStoFlutter);
    // ..loadHtmlString(htmlContentFlutterToJS);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Column(
        children: [
          Expanded(child: WebViewWidget(controller: _controller)),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text('From JS: $totalFromJS'),
          ),
        ],
      ),
    );
  }
}
