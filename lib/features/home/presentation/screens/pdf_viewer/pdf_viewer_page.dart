import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class PdfViewerPage extends StatefulWidget {
  final String url;
  final String title;

  const PdfViewerPage({super.key, required this.url, required this.title});

  @override
  State<PdfViewerPage> createState() => _PdfViewerPageState();
}

class _PdfViewerPageState extends State<PdfViewerPage> {
  bool _isLoading = true;
  bool _useWebView = false;
  final GlobalKey<SfPdfViewerState> _pdfViewerKey = GlobalKey();
  late final WebViewController _webViewController;

  @override
  void initState() {
    super.initState();
    _initWebViewController();
  }

  void _initWebViewController() {
    _webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (url) {
            if (mounted) setState(() => _isLoading = true);
          },
          onPageFinished: (String url) {
            if (mounted) setState(() => _isLoading = false);
          },
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    print("PDF URL: ${widget.url}");
    
    Widget content;
    if (widget.url.contains("kottby.net") || _useWebView) {
      if (!_useWebView) {
        _useWebView = true;
        final String viewerUrl = "https://docs.google.com/viewer?url=${Uri.encodeComponent(widget.url)}&embedded=true";
        _webViewController.loadRequest(Uri.parse(viewerUrl));
      }
      content = _buildWebViewer(widget.url);
    } else {
      content = _buildSfPdfViewer();
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.open_in_browser),
            tooltip: "فتح في المتصفح",
            onPressed: () => launchUrl(Uri.parse(widget.url), mode: LaunchMode.externalApplication),
          ),
          if (!_useWebView)
            IconButton(
              icon: const Icon(Icons.bookmark),
              onPressed: () {
                _pdfViewerKey.currentState?.openBookmarkView();
              },
            ),
        ],
      ),
      body: content,
    );
  }

  Widget _buildSfPdfViewer() {
    return Stack(
      children: [
        Directionality(
          textDirection: TextDirection.ltr,
          child: SfPdfViewer.network(
            Uri.parse(widget.url).toString(),
            key: _pdfViewerKey,
            onDocumentLoaded: (details) {
              setState(() => _isLoading = false);
            },
            onDocumentLoadFailed: (details) {
              print("PDF ERROR : ${details.description}");
              setState(() {
                _isLoading = true;
                _useWebView = true;
              });

              final String viewerUrl = "https://docs.google.com/viewer?url=${Uri.encodeComponent(widget.url)}&embedded=true";
              _webViewController.loadRequest(Uri.parse(viewerUrl));

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('جاري المحاولة عبر المحرك الاحتياطي...')),
              );
            },
          ),
        ),
        if (_isLoading)
          const Center(child: CircularProgressIndicator()),
      ],
    );
  }

  Widget _buildWebViewer(String url) {
    return Stack(
      children: [
        WebViewWidget(controller: _webViewController),
        if (_isLoading)
          const Center(child: CircularProgressIndicator()),
      ],
    );
  }
}
