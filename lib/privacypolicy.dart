import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:greencollar/main.dart'; // Import your login screen
import 'package:greencollar/constants.dart' as Constants;

class MyWebView extends StatefulWidget {
  @override
  _MyWebViewState createState() => _MyWebViewState();
}

class _MyWebViewState extends State<MyWebView> {
  late InAppWebViewController _webViewController;
  late PullToRefreshController _pullToRefreshController;

  @override
  void initState() {
    super.initState();
    _pullToRefreshController = PullToRefreshController(
      onRefresh: () async {
        // Handle pull to refresh
        await _webViewController.reload();
      },
    );
  }

  @override
  void dispose() {
    super.dispose();
    // Clean up when widget is disposed
    _pullToRefreshController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // Check if WebView can go back in its history
        if (await _webViewController.canGoBack()) {
          _webViewController.goBack();
          return Future.value(false); // Prevent default back action
        } else {
          // If no history to go back to, navigate to login screen
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const LoginScreen()),
          );
          return Future.value(false); // Prevent default back action
        }
      },
      child: Scaffold(
        appBar: AppBar(
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: Constants.AppColors.brandGradient,
            ),
          ),
          title: Text(
            'Privacy Policy',
            style: Constants.AppTypography.h3.copyWith(color: Colors.white),
          ),
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back,
              color: Colors.white,
            ),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
              );
            },
          ),
        ),
        body: SafeArea(
          child: InAppWebView(
            initialUrlRequest: URLRequest(
              url: WebUri(
                  'https://greencollar.in/terms-and-service')),
            initialOptions: InAppWebViewGroupOptions(
              crossPlatform: InAppWebViewOptions(
                javaScriptEnabled: true,
                useOnDownloadStart: true,
              ),
            ),
            pullToRefreshController: _pullToRefreshController,
            onWebViewCreated: (InAppWebViewController controller) {
              _webViewController = controller;
            },
            onLoadStart: (controller, url) {
              // Handle load start (optional)
            },
            onLoadStop: (controller, url) async {
              // Handle load stop (optional)
              _pullToRefreshController.endRefreshing();
            },
          ),
        ),
      ),
    );
  }
}
