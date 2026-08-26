import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:kotabi_saudi/main.dart';
import 'package:kotabi_saudi/core/theme/app_theme.dart';
import 'package:kotabi_saudi/core/services/local_storage_service.dart';
import 'package:kotabi_saudi/features/home/domain/repositories/educational_repository.dart';
import 'package:kotabi_saudi/features/home/domain/entities/educational_node.dart';
import 'package:kotabi_saudi/features/home/presentation/widgets/resource_chips.dart';
import 'package:url_launcher/url_launcher.dart';
import 'cubit/content_cubit.dart';
import 'cubit/content_state.dart';

class ContentPage extends StatelessWidget {
  final EducationalNode? node;
  final String parentId;
  final String title;

  const ContentPage({super.key, this.node, required this.parentId, required this.title});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ContentCubit(
        repository: context.read<EducationalRepository>(),
        storage: sl<LocalStorageService>(),
      )..loadItems(parentId, node?.url),
      child: ContentView(node: node, parentId: parentId, title: title),
    );
  }
}

class ContentView extends StatefulWidget {
  final EducationalNode? node;
  final String parentId;
  final String title;

  const ContentView({super.key, this.node, required this.parentId, required this.title});

  @override
  State<ContentView> createState() => _ContentViewState();
}

class _ContentViewState extends State<ContentView> {
  bool _isPdfLoading = true;
  bool _useWebView = false;
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
            if (mounted) setState(() => _isPdfLoading = true);
          },
          onPageFinished: (String url) {
            if (mounted) setState(() => _isPdfLoading = false);
          },
          onWebResourceError: (WebResourceError error) {
            print("WebView Error: ${error.description}");
          },
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    // Advanced Detection: Check type OR if URL contains .pdf extension
    final pdfResource = widget.node?.resources.where((r) {
      final url = r.url.toLowerCase();
      return r.type == 'pdf' || 
             r.type == 'pdf_viewer' || 
             r.type == 'pdf_direct' ||
             url.endsWith('.pdf') ||
             url.contains('.pdf?');
    }).firstOrNull;

    final otherResources = widget.node?.resources.where((r) => r != pdfResource).toList() ?? [];

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.node?.title ?? widget.title),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          if (widget.node != null)
            BlocBuilder<ContentCubit, ContentState>(
              builder: (context, state) {
                return IconButton(
                  icon: Icon(
                    state.isFavorite ? Icons.favorite : Icons.favorite_border, 
                    color: state.isFavorite ? Colors.red : Colors.white
                  ),
                  onPressed: () => context.read<ContentCubit>().toggleFavorite(widget.node!),
                );
              },
            ),
          if (pdfResource != null) ...[
            IconButton(
              icon: const Icon(Icons.open_in_browser),
              tooltip: "فتح في المتصفح",
              onPressed: () => launchUrl(Uri.parse(pdfResource.url), mode: LaunchMode.externalApplication),
            ),
            IconButton(
              icon: const Icon(Icons.download),
              onPressed: () {
                context.read<ContentCubit>().addToLibrary(widget.node!);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("تمت الإضافة إلى التنزيلات"))
                );
              },
            ),],
        ],
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: Column(
          children: [
            _buildBreadcrumbs(),
            if (otherResources.isNotEmpty) ResourceChips(resources: otherResources),
            if (pdfResource != null)
              Expanded(child: _buildPdfViewer(pdfResource.url))
            else
              Expanded(child: _buildItemsList(context)),
          ],
        ),
      ),
    );
  }

  Widget _buildBreadcrumbs() {
    if (widget.node == null || widget.node!.breadcrumbs.isEmpty) return const SizedBox();
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Colors.grey.shade100,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: widget.node!.breadcrumbs.map((b) => 
            Text("${b.title} » ", style: const TextStyle(fontSize: 11, color: AppTheme.subTextColor))
          ).toList(),
        ),
      ),
    );
  }

  Widget _buildPdfViewer(String url) {
    // If it's from a known protected domain or we've switched to WebView
    if (url.contains("kottby.net") || _useWebView) {
      // If we haven't loaded the webview yet (e.g. initial load for kottby.net)
      if (!_useWebView) {
        _useWebView = true;
        final String viewerUrl = "https://docs.google.com/viewer?url=${Uri.encodeComponent(url)}&embedded=true";
        _webViewController.loadRequest(Uri.parse(viewerUrl));
      }
      return _buildWebViewer(url);
    }
    
    // More robust URL handling: remove double encoding if it exists
    // and ensure special characters are handled correctly
    String safeUrl = url.trim();
    try {
      // If it's already encoded, parsing it and converting back to string
      // avoids double encoding issues common with encodeFull
      safeUrl = Uri.parse(safeUrl).toString();
    } catch (e) {
      safeUrl = Uri.encodeFull(safeUrl);
    }

    print("PDF URL: ${safeUrl}");


    return Container(
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
        color: Colors.white,
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Directionality(
            textDirection: TextDirection.ltr,
            child: SfPdfViewer.network(
              safeUrl,
              key: ValueKey(safeUrl),
              onDocumentLoaded: (_) {
                if (mounted) setState(() => _isPdfLoading = false);
              },
              onDocumentLoadFailed: (details) {
                if (mounted) {
                  print("PDF ERROR : ${details.description}");
                  setState(() {
                    _isPdfLoading = true;
                    _useWebView = true;
                  });
                  
                  // Load the request here instead of in the build method
                  final String viewerUrl = "https://docs.google.com/viewer?url=${Uri.encodeComponent(url)}&embedded=true";
                  _webViewController.loadRequest(Uri.parse(viewerUrl));

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("جاري المحاولة عبر المحرك الاحتياطي..."),
                      duration: Duration(seconds: 2),
                    )
                  );
                }
              },
              canShowScrollHead: true,
              canShowPaginationDialog: true,
            ),
          ),
          if (_isPdfLoading)
            const Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }

  Widget _buildWebViewer(String url) {
    // Google Docs Viewer is the most reliable way to show protected PDFs in a WebView
    return Container(
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
        color: Colors.white,
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          WebViewWidget(controller: _webViewController),
          if (_isPdfLoading)
            const Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }

  Widget _buildItemsList(BuildContext context) {
    return BlocBuilder<ContentCubit, ContentState>(
      builder: (context, state) {
        if (state is ContentLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state is ContentLoaded) {
          if (state.items.isEmpty) {
             if (widget.node != null && widget.node!.description.isNotEmpty) {
               return SingleChildScrollView(
                 padding: const EdgeInsets.all(16),
                 child: Text(widget.node!.description, style: const TextStyle(height: 1.6, color: AppTheme.textColor)),
               );
             }
             return const Center(child: Text("لا توجد محتويات"));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: state.items.length,
            itemBuilder: (context, index) {
              final item = state.items[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  title: Text(item.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ContentPage(
                          node: item,
                          parentId: item.id,
                          title: item.title,
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          );
        }
        return const SizedBox();
      },
    );
  }
}
