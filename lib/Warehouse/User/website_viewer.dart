import 'package:Lisofy/resources/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebViewScreen extends StatefulWidget {
  final String url;
  final String title;

  const WebViewScreen({super.key, required this.title, required this.url});

  @override
  State<WebViewScreen> createState() => _WebViewScreenState();
}

class _WebViewScreenState extends State<WebViewScreen> {
  late WebViewController controller;
  bool _isLoading = true;
  bool _hasError = false;
  String _errorMessage = "";

  @override
  void initState() {
    super.initState();
    _initializeWebView();
  }

  void _initializeWebView() {
    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (_) {
            setState(() {
              _isLoading = true;
              _hasError = false;
              _errorMessage = "";
            });
          },
          onPageFinished: (_) {
            setState(() {
              _isLoading = false;
            });
          },
          onWebResourceError: (error) {
            setState(() {
              _isLoading = false;
              _hasError = true;
              _errorMessage = "Error: ${error.description}";
            });
          },
        ),
      );
    _loadPage();
  }

  void _loadPage() {
    try {
      controller.loadRequest(Uri.parse(widget.url));
    } catch (e) {
      setState(() {
        _isLoading = false;
        _hasError = true;
        _errorMessage =
            "Failed to load the page. Please check your internet connection.";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title,
            style: const TextStyle(
                fontWeight: FontWeight.w400, color: Colors.white)),
        backgroundColor: AppTheme.primary,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Stack(
                children: [
                  if (!_hasError)
                    WebViewWidget(
                      layoutDirection: TextDirection.ltr,
                      controller: controller,
                    ),
                  if (_isLoading)
                    Container(
                      color: Colors.white.withValues(alpha: 0.8),
                      child: const Center(
                        child: SpinKitCircle(
                          color: AppTheme.primary,
                          size: 50,
                        ),
                      ),
                    ),
                  if (_hasError)
                    Container(
                      color: Colors.white,
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.wifi_off,
                                  color: Colors.red, size: 80),
                              const SizedBox(height: 10),
                              Text(_errorMessage,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(fontSize: 16)),
                              const SizedBox(height: 10),
                              ElevatedButton.icon(
                                onPressed: _loadPage,
                                icon: const Icon(Icons.refresh),
                                label: const Text("Retry"),
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 20, vertical: 12),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
