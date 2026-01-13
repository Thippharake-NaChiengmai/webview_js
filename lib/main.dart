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
  final String jsToFlutter = r'''
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>WebView JS</title>
</head>
<body>
    <h1>My Cart 
    <p id="total">Total: $120.00</p>
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
  final String flutterToJS = r'''
<! DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>JS from Flutter</title>
</head>
<body>
    <h1>Web Page</h1>
    <p id="msg">No message yet</p>

<script>
    function showMessageFromFlutter(msg) {
        document.getElementById('msg').innerText = "Flutter says: " + msg;
        return "Message received: " + msg;
    }
</script>
</body>
</html> ''';

  //Challenge
  final String challenge = r'''
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>WebView JS Example</title>
    <style>
        body { font-family: sans-serif; padding: 20px; }
        .item { border: 1px solid #ddd; padding: 10px; margin-bottom: 10px; border-radius: 8px; display: flex; justify-content: space-between; align-items: center; }
        button { background-color: #d1e7fd; border: none; padding: 5px 15px; border-radius: 15px; color: #007bff; font-weight: bold; cursor: pointer; }
        #total-display { font-size: 24px; font-weight: bold; margin-top: 20px; }
    </style>
</head>
<body>

    <h2>My Cart</h2>

    <div class="item">
        <span>Apple - $30</span>
        <button onclick="addToCart(30)">Add</button>
    </div>
    <div class="item">
        <span>Banana - $20</span>
        <button onclick="addToCart(20)">Add</button>
    </div>
    <div class="item">
        <span>Orange - $25</span>
        <button onclick="addToCart(25)">Add</button>
    </div>

    <h3>Cart</h3>
    <p>Total:</p>
    <div id="total-display">$0</div>

    <script>
        let currentTotal = 0;

        function addToCart(price) {
            currentTotal += price;
            updateDisplay();
            
            if (window.FlutterChannel) {
                window.FlutterChannel.postMessage(currentTotal.toString());
            }
        }

        function updateDisplay() {
            document.getElementById('total-display').innerText = "$" + currentTotal;
        }

        function updateTotalFromFlutter(newTotal) {
            currentTotal = parseInt(newTotal);
            updateDisplay();
        }
    </script>
</body>
</html> ''';

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
      // ..loadHtmlString(jsToFlutter);
      ..loadHtmlString(flutterToJS);
    // ..loadHtmlString(challenge);
  }

  Future<void> _sendMessage() async {
    // Option 1: just run JS (no return)
    await _controller.runJavaScript(
      "showMessageFromFlutter('Hello from Flutter!')",
    );

    // Option 2: run JS and get returned value
    final result = await _controller.runJavaScriptReturningResult(
      "showMessageFromFlutter('Hello from Flutter with return value!')",
    );
    debugPrint("JS returned: $result");
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
            // child: Text('From JS: $totalFromJS'),
            child: ElevatedButton(
              onPressed: _sendMessage,
              child: const Text('Send to JS'),
            ),
          ),
        ],
      ),
    );
  }
}
