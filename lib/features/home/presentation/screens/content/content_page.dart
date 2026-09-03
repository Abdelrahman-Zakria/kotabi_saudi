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
import 'package:kotabi_saudi/features/home/presentation/widgets/platform_buttons.dart';
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
  String? _lastLoadedUrl;

  @override
  void initState() {
    super.initState();
    _initWebViewController();
  }

  void _initWebViewController() {
    _webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setUserAgent("Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Mobile Safari/537.36")
      ..setBackgroundColor(const Color(0xFFFFFFFF))
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (url) {
            if (mounted) setState(() => _isPdfLoading = true);
          },
          onPageFinished: (String url) {
            if (mounted) setState(() => _isPdfLoading = false);
          },
          onWebResourceError: (WebResourceError error) {
          },
        ),
      );
  }

  void _handlePdfUrl(String url) {
    if (_lastLoadedUrl == url) return;
    _lastLoadedUrl = url;

    // Use WebView for kottby.net (protected) OR direct PDF files
    final bool isKottby = url.contains("kottby.net");
    final bool isDirectPdf = url.toLowerCase().contains(".pdf");

    if (isKottby || isDirectPdf) {
      String finalUrl = url;
      // Google Docs Viewer is only for direct .pdf links, NOT for kottby viewer pages
      if (isDirectPdf && !url.contains("/ktby/")) {
        finalUrl = "https://docs.google.com/viewer?url=${Uri.encodeComponent(url)}&embedded=true";
      }

      setState(() => _useWebView = true);
      _webViewController.loadRequest(Uri.parse(finalUrl));
    } else {
      setState(() => _useWebView = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Strict Detection: ONLY treat as PDF if it's explicitly a direct PDF link
    // or a known kottby viewer that is NOT a main category page.
    final pdfResource = widget.node?.resources.where((r) {
      final url = r.url.toLowerCase();
      final isDirect = url.endsWith('.pdf') || url.contains('.pdf?');
      final isViewer = url.contains('/ktby/') && !url.contains('category');
      
      return (r.type == 'pdf' || r.type == 'pdf_viewer' || r.type == 'pdf_direct') && (isDirect || isViewer);
    }).firstOrNull;

    if (pdfResource != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _handlePdfUrl(pdfResource.url);
      });
    }

    final platformResources = widget.node?.resources.where((r) {
      final url = r.url.toLowerCase();
      return url.contains('ien.edu.sa') || url.contains('madrasati.sa');
    }).toList() ?? [];

    final otherResources = widget.node?.resources.where((r) => 
      r != pdfResource && 
      !platformResources.contains(r) &&
      !r.label.contains("رابط") // Filter out generic "Link" chips
    ).toList() ?? [];

    // Identify if this is a "Book" page
    final bool isBookPage = (widget.node?.title.contains("كتاب") ?? false) && 
                            !(widget.node?.title.contains("حل") ?? false);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.node?.title ?? widget.title,style: TextStyle(fontSize: 16),),
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
          if (pdfResource != null && !isBookPage) ...[
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
        child: BlocBuilder<ContentCubit, ContentState>(
          builder: (context, state) {
            bool hasChildren = (state is ContentLoaded && state.items.isNotEmpty);
            
            return Column(
              children: [
                _buildBreadcrumbs(),
                
                // Priority 1: If there are children (Semesters, Subjects), show them as a grid.
                if (hasChildren)
                  Expanded(child: _buildItemsList(context))
                
                // Priority 2: If there is a PDF, show it ONLY (as requested)
                else if (pdfResource != null)
                  Expanded(child: _buildPdfViewer(pdfResource.url))
                
                // Priority 3: Leaf node without direct PDF (like Book platform links)
                else ...[
                  // FOR BOOKS: Show ONLY Platform Buttons. No chips, no description.
                  if (isBookPage) ...[
                    if (platformResources.isNotEmpty) PlatformButtons(resources: platformResources)
                    else const Expanded(child: Center(child: Text("المحتوى متوفر عبر المنصات الرسمية فقط"))),
                  ] 
                  // FOR OTHERS (Solutions, Tests without direct PDF): Show available resources
                  else ...[
                    if (platformResources.isNotEmpty) PlatformButtons(resources: platformResources),
                    if (otherResources.isNotEmpty) ResourceChips(resources: otherResources),
                    Expanded(child: _buildFallbackContent(context, state)),
                  ],
                ],
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildFallbackContent(BuildContext context, ContentState state) {
    if (state is ContentLoading) return const Center(child: CircularProgressIndicator());
    
    if (widget.node != null && widget.node!.description.isNotEmpty && widget.node!.description.length > 50) {
       // Filter out common junk text from descriptions
       final cleanDesc = widget.node!.description
           .replaceAll("تكرمأ ساهم في نشر موقع كتبي المدرسية للأخرين", "")
           .replaceAll("تحميل تطبيق كتبي المدرسية من هنا", "")
           .trim();
           
       if (cleanDesc.isNotEmpty) {
         return SingleChildScrollView(
           padding: const EdgeInsets.all(16),
           child: Text(cleanDesc, style: const TextStyle(height: 1.6, color: AppTheme.textColor, fontSize: 15)),
         );
       }
    }
    return const Center(child: Text("لا توجد محتويات حالياً"));
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
    if (_useWebView) {
      return _buildWebViewer(url);
    }

    // SfPdfViewer is now only a fallback for non-kottby direct PDFs
    String safeUrl = url.trim();
    try {
      safeUrl = Uri.parse(safeUrl).toString();
    } catch (e) {
      safeUrl = Uri.encodeFull(safeUrl);
    }

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
                  setState(() {
                    _isPdfLoading = true;
                    _useWebView = true;
                  });

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
        if (state is ContentLoading) return const SizedBox.shrink(); // Handled by parent
        if (state is ContentLoaded) {
          if (state.items.isEmpty) return const SizedBox.shrink(); // Handled by parent

          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 1.1,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: state.items.length,
            itemBuilder: (context, index) {
              final item = state.items[index];
              return _buildItemCard(context, item);
            },
          );
        }
        return const SizedBox();
      },
    );
  }

  Widget _buildItemCard(BuildContext context, EducationalNode item) {
    IconData icon = Icons.folder_rounded;
    Color color = AppTheme.primaryColor;

    if (item.title.contains("الفصل الدراسي")) {
      icon = Icons.calendar_today_rounded;
      color = Colors.blue.shade700;
    } else if (item.title.contains("كتاب")) {
      icon = Icons.book_rounded;
      color = Colors.orange.shade800;
    } else if (item.title.contains("حل") || item.title.contains("الحل")) {
      icon = Icons.task_alt_rounded;
      color = Colors.green.shade700;
    } else if (item.title.contains("اختبار")) {
      icon = Icons.quiz_rounded;
      color = Colors.red.shade700;
    }

    return InkWell(
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
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(color: Colors.grey.shade100),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 30),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                item.title,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
