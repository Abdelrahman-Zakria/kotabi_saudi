import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:gal/gal.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

import 'package:kotabi_saudi/core/new_ui/app_colors.dart';
import 'package:kotabi_saudi/core/new_ui/feature_gates.dart';
import 'package:kotabi_saudi/core/new_ui/helpers.dart';
import 'package:kotabi_saudi/core/models/book_model.dart';
import 'package:kotabi_saudi/core/providers/favorites_provider.dart';
import 'package:kotabi_saudi/core/providers/reader_library_provider.dart';
import 'package:kotabi_saudi/core/services/ad_service.dart';
import 'package:kotabi_saudi/core/services/reader_library_service.dart';
import 'package:kotabi_saudi/core/services/scraping_service.dart';

class PdfReaderScreen extends StatefulWidget {
  final BookModel book;

  const PdfReaderScreen({super.key, required this.book});

  @override
  State<PdfReaderScreen> createState() => _PdfReaderScreenState();
}

class _PdfReaderScreenState extends State<PdfReaderScreen> {
  static const Map<String, String> _pdfRequestHeaders = {
    'User-Agent':
        'Mozilla/5.0 (iPhone; CPU iPhone OS 17_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.0 Mobile/15E148 Safari/604.1',
    'Accept': 'application/pdf,*/*;q=0.8',
    'Accept-Language': 'ar,en;q=0.8',
  };

  final GlobalKey<SfPdfViewerState> _pdfViewerKey = GlobalKey();
  final GlobalKey _pageCaptureKey = GlobalKey();
  final PdfViewerController _pdfController = PdfViewerController();
  final ScrapingService _scrapingService = ScrapingService();

  bool _isLoading = true;
  bool _hasError = false;
  bool _showToolbar = true;
  bool _isSavingDocument = false;
  bool _isSavingPageImage = false;
  bool _hasTextSelection = false;
  bool _hasShownOpenInterstitial = false;
  bool _isHandlingCloseRequest = false;
  int _currentPage = 1;
  int _totalPages = 0;
  String? _resolvedPdfUrl;
  String? _errorMessage;
  Uint8List? _pdfBytes;
  PdfScrollDirection _scrollDirection = PdfScrollDirection.vertical;

  @override
  void initState() {
    super.initState();
    final libraryProvider = context.read<ReaderLibraryProvider>();
    _scrollDirection =
        libraryProvider.getScrollDirection(widget.book.id) == 'horizontal'
            ? PdfScrollDirection.horizontal
            : PdfScrollDirection.vertical;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showOpenInterstitial();
    });
    _loadPdf();
  }

  @override
  void dispose() {
    _pdfController.dispose();
    super.dispose();
  }

  void _toggleToolbar() {
    setState(() => _showToolbar = !_showToolbar);
  }

  Future<void> _showOpenInterstitial() async {
    if (!mounted || _hasShownOpenInterstitial) return;
    _hasShownOpenInterstitial = true;
    AdService().showInterstitialAd(onAdDismissed: () {});
  }

  Future<void> _handleCloseRequest() async {
    if (_isHandlingCloseRequest) return;
    _isHandlingCloseRequest = true;

    try {
      AdService().showInterstitialAd(onAdDismissed: () {
        if (mounted) {
          Navigator.pop(context);
        }
      });
    } finally {
      _isHandlingCloseRequest = false;
    }
  }

  Future<void> _loadPdf() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
      _errorMessage = null;
      _resolvedPdfUrl = null;
      _pdfBytes = null;
      _currentPage = 1;
      _totalPages = 0;
      _hasTextSelection = false;
    });

    try {
      final libraryProvider = context.read<ReaderLibraryProvider>();
      final downloadedBook = libraryProvider.getDownloadedBook(widget.book.id);

      Uint8List? pdfBytes;
      String? pdfUrl = downloadedBook?.sourceUrl;

      if (downloadedBook != null &&
          await File(downloadedBook.localPath).exists()) {
        pdfBytes = await File(downloadedBook.localPath).readAsBytes();
      } else {
        pdfUrl = await _scrapingService.resolveBookPdfUrl(widget.book);
        if (pdfUrl != null) {
          pdfBytes = await _loadPdfBytesWithoutFirstPage(pdfUrl);
        }
      }

      if (!mounted) return;

      setState(() {
        _resolvedPdfUrl = pdfUrl;
        _pdfBytes = pdfBytes;
        _hasError = pdfBytes == null;
        _errorMessage = pdfBytes == null
            ? 'تعذر الوصول إلى ملف PDF الخاص بهذا الكتاب. حاول مرة أخرى بعد قليل.'
            : null;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _hasError = true;
        _isLoading = false;
        _errorMessage = 'حدث خلل أثناء تحميل الكتاب. حاول مرة أخرى.';
      });
    }
  }

  Future<Uint8List?> _loadPdfBytesWithoutFirstPage(String pdfUrl) async {
    try {
      final response =
          await http.get(Uri.parse(pdfUrl), headers: _pdfRequestHeaders);
      if (response.statusCode != 200) return null;

      final originalBytes = response.bodyBytes;
      final document = PdfDocument(inputBytes: originalBytes);

      if (document.pages.count <= 1) {
        final singlePageBytes = Uint8List.fromList(originalBytes);
        document.dispose();
        return singlePageBytes;
      }

      document.pages.removeAt(0);
      final trimmedBytes = Uint8List.fromList(await document.save());
      document.dispose();
      return trimmedBytes;
    } catch (_) {
      return null;
    }
  }

  Future<void> _toggleBookmark() async {
    final libraryProvider = context.read<ReaderLibraryProvider>();
    final added =
        await libraryProvider.toggleBookmark(widget.book.id, _currentPage);

    if (!mounted) return;
    AppHelpers.showSnackBar(
      context,
      added
          ? 'تمت إضافة الصفحة إلى الإشارات المرجعية'
          : 'تمت إزالة الإشارة المرجعية',
    );
  }

  Future<void> _toggleScrollDirection() async {
    final nextDirection = _scrollDirection == PdfScrollDirection.vertical
        ? PdfScrollDirection.horizontal
        : PdfScrollDirection.vertical;

    await context.read<ReaderLibraryProvider>().setScrollDirection(
          widget.book.id,
          nextDirection == PdfScrollDirection.horizontal
              ? 'horizontal'
              : 'vertical',
        );

    if (!mounted) return;

    setState(() {
      _scrollDirection = nextDirection;
    });

    AppHelpers.showSnackBar(
      context,
      nextDirection == PdfScrollDirection.horizontal
          ? 'تم تفعيل القراءة الأفقية'
          : 'تم تفعيل القراءة العمودية',
    );
  }

  Future<bool> _ensurePhotoSavePermission() async {
    if (Platform.isAndroid) return true;
    if (!Platform.isIOS) return true;
    return Gal.requestAccess(toAlbum: true);
  }

  Future<void> _saveCurrentPageImageToGallery() async {
    if (_isSavingPageImage) return;
    if (_isLoading) return;

    final pixelRatio = MediaQuery.of(context).devicePixelRatio.clamp(2.0, 3.0);

    final permissionOk = await _ensurePhotoSavePermission();
    if (!permissionOk) {
      if (!mounted) return;
      AppHelpers.showSnackBar(
        context,
        'لا يمكن حفظ الصورة بدون إذن مكتبة الصور',
        isError: true,
      );
      return;
    }

    final boundaryContext = _pageCaptureKey.currentContext;
    final boundary =
        boundaryContext?.findRenderObject() as RenderRepaintBoundary?;
    if (boundary == null) {
      if (!mounted) return;
      AppHelpers.showSnackBar(
        context,
        'تعذر تجهيز الصورة الآن. حاول مرة أخرى.',
        isError: true,
      );
      return;
    }

    setState(() => _isSavingPageImage = true);
    try {
      final ui.Image image = await boundary.toImage(
        pixelRatio: pixelRatio,
      );
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) {
        throw StateError('Failed to encode png');
      }

      final pngBytes = byteData.buffer.asUint8List();
      final safeTitle = widget.book.title
          .replaceAll(RegExp(r'[\\\\/:*?\"<>|]'), '')
          .replaceAll(RegExp(r'\\s+'), '_')
          .trim();
      final name =
          'kutub_${safeTitle.isEmpty ? widget.book.id : safeTitle}_p$_currentPage';

      await Gal.putImageBytes(
        pngBytes,
        album: 'كتبي',
        name: name,
      );

      if (!mounted) return;
      AppHelpers.showSnackBar(context, 'تم حفظ الصورة في معرض الصور');
    } catch (_) {
      if (!mounted) return;
      AppHelpers.showSnackBar(
        context,
        'تعذر حفظ الصورة. حاول مرة أخرى.',
        isError: true,
      );
    } finally {
      if (mounted) setState(() => _isSavingPageImage = false);
    }
  }

  Future<void> _saveCurrentDocumentLocally({
    bool showFeedback = false,
    bool persistIfDownloadedOnly = false,
    bool showAdAfterSave = false,
  }) async {
    if (_isSavingDocument) return;

    if (_pdfBytes == null) {
      AppHelpers.showSnackBar(
        context,
        'انتظر حتى يكتمل تحميل الكتاب أولًا',
        isError: true,
      );
      return;
    }

    setState(() => _isSavingDocument = true);

    try {
      final libraryProvider = context.read<ReaderLibraryProvider>();
      final bytes = _pdfBytes!;

      if (persistIfDownloadedOnly &&
          !libraryProvider.isDownloaded(widget.book.id)) {
        return;
      }

      if (persistIfDownloadedOnly) {
        await libraryProvider.persistDocumentIfDownloaded(
            widget.book.id, bytes);
      } else {
        await libraryProvider.saveDocumentLocally(
          widget.book,
          bytes,
          sourceUrl: _resolvedPdfUrl,
        );
      }

      if (!mounted) return;

      setState(() {
        _pdfBytes = bytes;
      });

      if (showFeedback) {
        AppHelpers.showSnackBar(
          context,
          'تم حفظ الكتاب محليًا ويمكنك الوصول إليه من الشاشة الرئيسية',
        );
      }

      if (showAdAfterSave) {
        AdService().showInterstitialAd(onAdDismissed: () {});
      }
    } catch (error) {
      debugPrint('Failed to save PDF locally: $error');
      if (!mounted) return;
      AppHelpers.showSnackBar(
        context,
        'تعذر حفظ الكتاب محليًا حاليًا',
        isError: true,
      );
    } finally {
      if (mounted) {
        setState(() => _isSavingDocument = false);
      }
    }
  }

  Future<void> _handleDownloadAction() async {
    final libraryProvider = context.read<ReaderLibraryProvider>();

    if (libraryProvider.isDownloaded(widget.book.id)) {
      final shouldDelete = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text(
            'الكتاب محفوظ بالفعل',
            textAlign: TextAlign.center,
            style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w700),
          ),
          content: const Text(
            'هل تريد حذف النسخة المحفوظة محليًا من هذا الكتاب؟',
            textAlign: TextAlign.center,
            style: TextStyle(fontFamily: 'Cairo', height: 1.5),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text(
                'إلغاء',
                style: TextStyle(fontFamily: 'Cairo'),
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
                foregroundColor: Colors.white,
              ),
              child: const Text(
                'حذف النسخة',
                style: TextStyle(fontFamily: 'Cairo'),
              ),
            ),
          ],
        ),
      );

      if (shouldDelete == true) {
        await libraryProvider.removeDownloadedBook(widget.book.id);
        if (!mounted) return;
        AppHelpers.showSnackBar(context, 'تم حذف النسخة المحفوظة من الجهاز');
      }
      return;
    }

    await _saveCurrentDocumentLocally(
      showFeedback: true,
      showAdAfterSave: true,
    );
  }

  Future<void> _showNoteDialog() async {
    final libraryProvider = context.read<ReaderLibraryProvider>();
    final currentNote =
        libraryProvider.getNoteForPage(widget.book.id, _currentPage);
    final controller = TextEditingController(text: currentNote?.text ?? '');

    final result = await showDialog<String?>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'ملاحظة الصفحة $_currentPage',
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontFamily: 'Cairo',
            fontWeight: FontWeight.w700,
          ),
        ),
        content: TextField(
          controller: controller,
          maxLines: 5,
          minLines: 3,
          textDirection: TextDirection.rtl,
          decoration: InputDecoration(
            hintText: 'اكتب ملاحظتك هنا...',
            hintStyle: const TextStyle(fontFamily: 'Cairo'),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),
        actions: [
          if (currentNote != null)
            TextButton(
              onPressed: () => Navigator.pop(ctx, '__delete__'),
              child: const Text(
                'حذف الملاحظة',
                style: TextStyle(
                  fontFamily: 'Cairo',
                  color: AppColors.error,
                ),
              ),
            ),
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(
              'إلغاء',
              style: TextStyle(fontFamily: 'Cairo'),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, controller.text),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            child: const Text(
              'حفظ',
              style: TextStyle(fontFamily: 'Cairo'),
            ),
          ),
        ],
      ),
    );

    controller.dispose();

    if (result == null || !mounted) return;

    if (result == '__delete__') {
      await libraryProvider.removeNote(widget.book.id, _currentPage);
      if (!mounted) return;
      AppHelpers.showSnackBar(context, 'تم حذف الملاحظة');
      return;
    }

    await libraryProvider.saveNote(widget.book.id, _currentPage, result);
    if (!mounted) return;
    AppHelpers.showSnackBar(context, 'تم حفظ الملاحظة للصفحة الحالية');
  }

  void _showBookmarksSheet(List<int> bookmarks) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'الإشارات المرجعية',
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 12),
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: bookmarks.length,
                  itemBuilder: (context, index) {
                    final page = bookmarks[index];
                    return ListTile(
                      leading: const Icon(
                        Icons.bookmark_rounded,
                        color: Color(0xFFF59E0B),
                      ),
                      title: Text(
                        'الصفحة $page',
                        style: const TextStyle(
                          fontFamily: 'Cairo',
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      onTap: () {
                        Navigator.pop(ctx);
                        _pdfController.jumpToPage(page);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showNotesSheet(List<BookPageNote> notes) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'ملاحظات الصفحات',
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 12),
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: notes.length,
                  itemBuilder: (context, index) {
                    final note = notes[index];
                    return ListTile(
                      leading: const Icon(
                        Icons.sticky_note_2_rounded,
                        color: AppColors.primary,
                      ),
                      title: Text(
                        'الصفحة ${note.page}',
                        style: const TextStyle(
                          fontFamily: 'Cairo',
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      subtitle: Text(
                        note.text,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontFamily: 'Cairo',
                          color: AppColors.textSecondary,
                        ),
                      ),
                      onTap: () {
                        Navigator.pop(ctx);
                        _pdfController.jumpToPage(note.page);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _applyHighlight() async {
    if (!_hasTextSelection) {
      AppHelpers.showSnackBar(
        context,
        'حدّد النص أولًا ثم اختر التمييز',
        isError: true,
      );
      return;
    }

    _pdfController.annotationMode = PdfAnnotationMode.highlight;
    await Future<void>.delayed(const Duration(milliseconds: 100));
    _pdfController.annotationMode = PdfAnnotationMode.none;
    _pdfController.clearSelection();

    if (!mounted) return;
    setState(() => _hasTextSelection = false);
  }

  Future<void> _handleMenuAction(
    _ReaderMenuAction action,
    ReaderLibraryProvider libraryProvider,
  ) async {
    switch (action) {
      case _ReaderMenuAction.download:
        await _handleDownloadAction();
        break;
      case _ReaderMenuAction.toggleDirection:
        await _toggleScrollDirection();
        break;
      case _ReaderMenuAction.toggleBookmark:
        await _toggleBookmark();
        break;
      case _ReaderMenuAction.showBookmarks:
        final bookmarks = libraryProvider.getBookmarks(widget.book.id);
        if (bookmarks.isEmpty) {
          AppHelpers.showSnackBar(context, 'لا توجد إشارات مرجعية بعد',
              isError: true);
          return;
        }
        _showBookmarksSheet(bookmarks);
        break;
      case _ReaderMenuAction.editNote:
        await _showNoteDialog();
        break;
      case _ReaderMenuAction.showNotes:
        final notes = libraryProvider.getNotes(widget.book.id);
        if (notes.isEmpty) {
          AppHelpers.showSnackBar(context, 'لا توجد ملاحظات محفوظة بعد',
              isError: true);
          return;
        }
        _showNotesSheet(notes);
        break;
      case _ReaderMenuAction.highlightSelection:
        await _applyHighlight();
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final showDownloadButton = FeatureGates.showMay19Features;
    final favoritesProvider = context.watch<FavoritesProvider>();
    final libraryProvider = context.watch<ReaderLibraryProvider>();
    final isFav = favoritesProvider.isFavorite(widget.book.id);
    final isDownloaded = libraryProvider.isDownloaded(widget.book.id);
    final bookmarks = libraryProvider.getBookmarks(widget.book.id);
    final currentPageNote =
        libraryProvider.getNoteForPage(widget.book.id, _currentPage);
    final isCurrentPageBookmarked = bookmarks.contains(_currentPage);
    final stageColor = AppHelpers.getStageColor(widget.book.stage);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) {
          _handleCloseRequest();
        }
      },
      child: Scaffold(
        backgroundColor: Colors.black87,
        body: Column(
          children: [
            AnimatedSlide(
              offset: _showToolbar ? Offset.zero : const Offset(0, -1),
              duration: const Duration(milliseconds: 250),
              child: AnimatedOpacity(
                opacity: _showToolbar ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 250),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [stageColor, stageColor.withOpacity(0.82)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: SafeArea(
                    bottom: false,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      child: Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.arrow_back_ios_rounded,
                                color: Colors.white),
                            onPressed: _handleCloseRequest,
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  widget.book.title,
                                  style: const TextStyle(
                                    fontFamily: 'Cairo',
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  widget.book.subject,
                                  style: TextStyle(
                                    fontFamily: 'Cairo',
                                    fontSize: 12,
                                    color: Colors.white.withOpacity(0.82),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (showDownloadButton)
                            IconButton(
                              icon: _isSavingDocument
                                  ? const SizedBox(
                                      width: 22,
                                      height: 22,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2.4,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                          Colors.white,
                                        ),
                                      ),
                                    )
                                  : Icon(
                                      isDownloaded
                                          ? Icons.download_done_rounded
                                          : Icons.download_rounded,
                                      color: Colors.white,
                                    ),
                              onPressed: (_isLoading ||
                                      _pdfBytes == null ||
                                      _isSavingDocument)
                                  ? null
                                  : _handleDownloadAction,
                            ),
                          IconButton(
                            icon: _isSavingPageImage
                                ? const SizedBox(
                                    width: 22,
                                    height: 22,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.4,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white,
                                      ),
                                    ),
                                  )
                                : const Icon(
                                    Icons.image_rounded,
                                    color: Colors.white,
                                  ),
                            onPressed: (_isLoading || _isSavingPageImage)
                                ? null
                                : _saveCurrentPageImageToGallery,
                            tooltip: 'حفظ صورة من الصفحة الحالية',
                          ),
                          IconButton(
                            icon: Icon(
                              isFav
                                  ? Icons.favorite_rounded
                                  : Icons.favorite_border_rounded,
                              color: isFav ? Colors.red.shade200 : Colors.white,
                            ),
                            onPressed: () {
                              favoritesProvider.toggleFavorite(widget.book);
                              AppHelpers.showSnackBar(
                                context,
                                isFav
                                    ? 'تمت الإزالة من المفضلة'
                                    : 'تمت الإضافة للمفضلة',
                              );
                            },
                          ),
                          PopupMenuButton<_ReaderMenuAction>(
                            onSelected: (action) =>
                                _handleMenuAction(action, libraryProvider),
                            icon: const Icon(Icons.more_vert_rounded,
                                color: Colors.white),
                            itemBuilder: (context) => [
                              PopupMenuItem(
                                value: _ReaderMenuAction.toggleBookmark,
                                child: Text(
                                  isCurrentPageBookmarked
                                      ? 'إزالة إشارة الصفحة الحالية'
                                      : 'إضافة إشارة للصفحة الحالية',
                                  style: const TextStyle(fontFamily: 'Cairo'),
                                ),
                              ),
                              const PopupMenuItem(
                                value: _ReaderMenuAction.showBookmarks,
                                child: Text(
                                  'عرض الإشارات المرجعية',
                                  style: TextStyle(fontFamily: 'Cairo'),
                                ),
                              ),
                              const PopupMenuItem(
                                value: _ReaderMenuAction.editNote,
                                child: Text(
                                  'ملاحظة على الصفحة الحالية',
                                  style: TextStyle(fontFamily: 'Cairo'),
                                ),
                              ),
                              const PopupMenuItem(
                                value: _ReaderMenuAction.showNotes,
                                child: Text(
                                  'عرض الملاحظات',
                                  style: TextStyle(fontFamily: 'Cairo'),
                                ),
                              ),
                              PopupMenuItem(
                                value: _ReaderMenuAction.toggleDirection,
                                child: Text(
                                  _scrollDirection ==
                                          PdfScrollDirection.vertical
                                      ? 'تفعيل القراءة الأفقية'
                                      : 'تفعيل القراءة العمودية',
                                  style: const TextStyle(fontFamily: 'Cairo'),
                                ),
                              ),
                              if (showDownloadButton)
                                PopupMenuItem(
                                  value: _ReaderMenuAction.download,
                                  child: Text(
                                    isDownloaded
                                        ? 'إدارة النسخة المحفوظة'
                                        : 'تنزيل الكتاب محليًا',
                                    style: const TextStyle(fontFamily: 'Cairo'),
                                  ),
                                ),
                              const PopupMenuItem(
                                value: _ReaderMenuAction.highlightSelection,
                                child: Text(
                                  'تمييز النص المحدد',
                                  style: TextStyle(fontFamily: 'Cairo'),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: GestureDetector(
                onTap: _toggleToolbar,
                child: Stack(
                  children: [
                    if (_hasError)
                      _buildErrorView()
                    else if (_pdfBytes != null)
                      RepaintBoundary(
                        key: _pageCaptureKey,
                        child: SfPdfViewer.memory(
                          _pdfBytes!,
                          key: _pdfViewerKey,
                          controller: _pdfController,
                          pageLayoutMode:
                              _scrollDirection == PdfScrollDirection.horizontal
                                  ? PdfPageLayoutMode.single
                                  : PdfPageLayoutMode.continuous,
                          scrollDirection: _scrollDirection,
                          canShowScrollHead: true,
                          canShowScrollStatus: true,
                          canShowPaginationDialog: true,
                          canShowTextSelectionMenu: false,
                          enableDoubleTapZooming: true,
                          enableTextSelection: true,
                          onTextSelectionChanged: (details) {
                            if (!mounted) return;
                            setState(() {
                              _hasTextSelection =
                                  (details.selectedText?.trim().isNotEmpty ??
                                      false);
                            });
                          },
                          onDocumentLoaded: (details) {
                            final libraryProvider =
                                context.read<ReaderLibraryProvider>();
                            final savedPage = libraryProvider.getLastPage(
                              widget.book.id,
                            );
                            final targetPage = savedPage.clamp(
                                1, details.document.pages.count);

                            setState(() {
                              _isLoading = false;
                              _totalPages = details.document.pages.count;
                              _currentPage = targetPage;
                            });

                            libraryProvider.addRecentBook(
                                widget.book, targetPage);

                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              if (!mounted) return;
                              if (targetPage > 1) {
                                _pdfController.jumpToPage(targetPage);
                              }
                            });
                          },
                          onDocumentLoadFailed: (_) {
                            setState(() {
                              _isLoading = false;
                              _hasError = true;
                              _errorMessage =
                                  'تعذر فتح ملف الكتاب داخل القارئ. حاول مرة أخرى.';
                            });
                          },
                          onPageChanged: (details) {
                            setState(() {
                              _currentPage = details.newPageNumber;
                            });
                            final libraryProvider =
                                context.read<ReaderLibraryProvider>();
                            libraryProvider.setLastPage(
                              widget.book.id,
                              details.newPageNumber,
                            );
                            libraryProvider.addRecentBook(
                              widget.book,
                              details.newPageNumber,
                            );
                          },
                          onAnnotationAdded: (_) {
                            _saveCurrentDocumentLocally();
                          },
                          onAnnotationEdited: (_) {
                            _saveCurrentDocumentLocally();
                          },
                          onAnnotationRemoved: (_) {
                            _saveCurrentDocumentLocally();
                          },
                        ),
                      ),
                    if (_hasTextSelection && _showToolbar)
                      Positioned(
                        top: 16,
                        left: 16,
                        right: 16,
                        child: Center(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.78),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: const Text(
                              'تم تحديد نص. اختر "تمييز النص المحدد" من القائمة.',
                              style: TextStyle(
                                fontFamily: 'Cairo',
                                fontSize: 12,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    if (_isLoading)
                      Container(
                        color: Colors.black54,
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CircularProgressIndicator(
                                color: stageColor,
                                strokeWidth: 3,
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                'جار تحميل الكتاب...',
                                style: TextStyle(
                                  fontFamily: 'Cairo',
                                  fontSize: 16,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            AnimatedSlide(
              offset: _showToolbar ? Offset.zero : const Offset(0, 1),
              duration: const Duration(milliseconds: 250),
              child: AnimatedOpacity(
                opacity: _showToolbar ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 250),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.grey.shade900,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 10,
                        offset: const Offset(0, -3),
                      ),
                    ],
                  ),
                  padding: EdgeInsets.only(
                    left: 16,
                    right: 16,
                    top: 12,
                    bottom: MediaQuery.of(context).padding.bottom + 12,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _ToolbarButton(
                        icon: Icons.zoom_out_rounded,
                        onTap: () => _pdfController.zoomLevel -= 0.25,
                      ),
                      _ToolbarButton(
                        icon: Icons.zoom_in_rounded,
                        onTap: () => _pdfController.zoomLevel += 0.25,
                      ),
                      if (_totalPages > 0)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 6),
                          decoration: BoxDecoration(
                            color: stageColor.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                                color: stageColor.withOpacity(0.3)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (isCurrentPageBookmarked) ...[
                                const Icon(
                                  Icons.bookmark_rounded,
                                  size: 14,
                                  color: Color(0xFFFBBF24),
                                ),
                                const SizedBox(width: 4),
                              ],
                              if (currentPageNote != null) ...[
                                const Icon(
                                  Icons.sticky_note_2_rounded,
                                  size: 14,
                                  color: Color(0xFF34D399),
                                ),
                                const SizedBox(width: 4),
                              ],
                              Text(
                                '$_currentPage / $_totalPages',
                                style: TextStyle(
                                  fontFamily: 'Cairo',
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: stageColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      _ToolbarButton(
                        icon: Icons.navigate_before_rounded,
                        onTap: () {
                          if (_currentPage > 1) {
                            _pdfController.previousPage();
                          }
                        },
                      ),
                      _ToolbarButton(
                        icon: Icons.navigate_next_rounded,
                        onTap: () {
                          if (_currentPage < _totalPages) {
                            _pdfController.nextPage();
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
            if (_isSavingDocument ||
                libraryProvider.isPersisting(widget.book.id))
              Container(
                width: double.infinity,
                color: const Color(0xFF16A34A),
                padding: EdgeInsets.only(
                  top: 8,
                  bottom: MediaQuery.of(context).padding.bottom > 0 ? 8 : 12,
                ),
                child: const Text(
                  'جار حفظ نسختك المحلية...',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorView() {
    return Container(
      color: AppColors.background,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppColors.error.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.picture_as_pdf_rounded,
                  size: 40,
                  color: AppColors.error,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'تعذر تحميل الكتاب',
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _errorMessage ??
                    (_isLikelyFallbackBook(widget.book)
                        ? 'الرابط الحالي للكتاب قديم أو غير مباشر. سنحاول جلب نسخة صحيحة عند إعادة المحاولة.'
                        : 'تعذر الوصول إلى ملف PDF الخاص بهذا الكتاب. حاول مرة أخرى بعد قليل.'),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  bool _isLikelyFallbackBook(BookModel book) {
    final url = book.pdfUrl.toLowerCase();
    return url.endsWith('.pdf') &&
        !url.contains('/wp-content/uploads/') &&
        !url.contains('/pdfviewer/web/viewer.html');
  }
}

enum _ReaderMenuAction {
  download,
  toggleDirection,
  toggleBookmark,
  showBookmarks,
  editNote,
  showNotes,
  highlightSelection,
}

class _ToolbarButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _ToolbarButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: Colors.grey.shade800,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: Colors.white, size: 22),
      ),
    );
  }
}
