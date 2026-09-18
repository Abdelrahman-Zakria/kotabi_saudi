import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:provider/provider.dart';
import 'package:kotabi_saudi/core/new_ui/app_colors.dart';
import 'package:kotabi_saudi/core/new_ui/app_constants.dart';
import 'package:kotabi_saudi/core/new_ui/feature_gates.dart';
import 'package:kotabi_saudi/core/new_ui/helpers.dart';
import 'package:kotabi_saudi/core/models/grade_model.dart';
import 'package:kotabi_saudi/core/providers/reader_library_provider.dart';
import 'package:kotabi_saudi/features/new_ui/widgets/book_cover_image.dart';
import 'package:kotabi_saudi/features/new_ui/widgets/grade_badge.dart';
import 'package:kotabi_saudi/features/new_ui/widgets/menu_button.dart';
import 'package:kotabi_saudi/features/tahderi/presentation/screens/tahderi/tahderi_page.dart';
import '../browse/browse_screen.dart';
import '../browse/grade_books_screen.dart';
import '../explanations/explanations_semesters_screen.dart';
import '../downloads/downloaded_books_screen.dart';
import '../hululi/hululi_grades_screen.dart';
import '../kotbi_1447/kotbi_1447_grades_screen.dart';
import '../mnhaji/exam_models_grades_screen.dart';
import '../mnhaji/mnhaji_books_grades_screen.dart';
import '../mnhaji/mnhaji_books_screen.dart';
import '../saudi/academic_calendar_screen.dart';
import '../saudi/saudi_education_plus_screens.dart';
import '../saudi/saudi_feature_screens.dart';
import '../saudi/study_extras_screens.dart';
import '../pdf_reader/pdf_reader_screen.dart';
import '../search/search_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _entranceController;

  @override
  void initState() {
    super.initState();
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    )..forward();
  }

  @override
  void dispose() {
    _entranceController.dispose();
    super.dispose();
  }

  /// Wraps each top-level home section in a staggered fade + slide-up +
  /// gentle scale entrance animation driven by [_entranceController].
  List<Widget> _staggeredChildren(List<Widget> children) {
    return List.generate(children.length, (index) {
      final begin = (index * 0.05).clamp(0.0, 0.75);
      final end = (begin + 0.35).clamp(0.0, 1.0);
      final animation = CurvedAnimation(
        parent: _entranceController,
        curve: Interval(begin, end, curve: Curves.easeOutCubic),
      );
      final scaleAnimation = CurvedAnimation(
        parent: _entranceController,
        curve: Interval(begin, end, curve: Curves.easeOutBack),
      );
      return FadeTransition(
        opacity: animation,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 0.08),
            end: Offset.zero,
          ).animate(animation),
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.96, end: 1.0).animate(
              scaleAnimation,
            ),
            child: children[index],
          ),
        ),
      );
    });
  }

  void _open(Widget screen) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
  }

  Future<void> _requestNativeRatePrompt(BuildContext context) async {
    final inAppReview = InAppReview.instance;

    try {
      final isAvailable = await inAppReview.isAvailable();
      if (isAvailable) {
        await inAppReview.requestReview();
        return;
      }
    } catch (_) {}

    if (!context.mounted) return;
    AppHelpers.showSnackBar(
      context,
      'نافذة التقييم غير متاحة حاليًا على هذا الجهاز',
      isError: true,
    );
  }

  /// The study library: everything that opens a book, a solution or an exam.
  List<_HomeAction> get _libraryActions => [
        _HomeAction(
          title: 'تحضيري',
          icon: Icons.assignment_rounded,
          color: const Color(0xFF10B981),
          onTap: () => _open(const TahderiPage()),
        ),
        _HomeAction(
          title: 'المراحل الدراسية',
          icon: Icons.auto_stories_rounded,
          color: AppColors.primary,
          onTap: () => _open(const BrowseScreen()),
        ),
        _HomeAction(
          title: 'الكتب المدرسية',
          icon: Icons.menu_book_rounded,
          color: AppColors.primaryDark,
          onTap: () => _open(const MnhajiBooksGradesScreen()),
        ),
        if (FeatureGates.showMay14Features)
          _HomeAction(
            title: 'حلول الكتب',
            icon: Icons.fact_check_rounded,
            color: const Color(0xFF0D9488),
            onTap: () => _open(const HululiGradesScreen()),
          ),
        _HomeAction(
          title: 'نماذج الاختبارات',
          icon: Icons.quiz_rounded,
          color: const Color(0xFF059669),
          onTap: () => _open(const ExamModelsGradesScreen()),
        ),
        if (FeatureGates.showMay19Features)
          _HomeAction(
            title: 'شروحات الدروس',
            icon: Icons.play_lesson_rounded,
            color: const Color(0xFF16A34A),
            onTap: () => _open(const ExplanationsSemestersScreen()),
          ),
        if (FeatureGates.showMay14Features)
          _HomeAction(
            title: 'كتبي ١٤٤٧',
            icon: Icons.library_books_rounded,
            color: const Color(0xFF15803D),
            onTap: () => _open(const Kotbi1447GradesScreen()),
          ),
      ];

  /// Day-to-day student tools.
  List<_HomeAction> get _toolActions => [
        _HomeAction(
          title: 'التقويم الدراسي',
          icon: Icons.calendar_month_rounded,
          color: const Color(0xFF006C35),
          onTap: () => _open(const AcademicCalendarScreen()),
        ),
        _HomeAction(
          title: 'حاسبة الموزونة',
          icon: Icons.calculate_rounded,
          color: const Color(0xFF0D9488),
          onTap: () => _open(const WeightedScoreScreen()),
        ),
        _HomeAction(
          title: 'الخطة الأسبوعية',
          icon: Icons.edit_calendar_rounded,
          color: const Color(0xFF16A34A),
          onTap: () => _open(const WeeklyPlanScreen()),
        ),
        _HomeAction(
          title: 'اليوم الدراسي',
          icon: Icons.wb_sunny_rounded,
          color: const Color(0xFFF59E0B),
          onTap: () => _open(const StudentDayScreen()),
        ),
        _HomeAction(
          title: 'وضع الخريج',
          icon: Icons.school_rounded,
          color: const Color(0xFF111827),
          onTap: () => _open(const GraduateModeScreen()),
        ),
      ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light,
        child: CustomScrollView(
          slivers: [
            // Custom App Bar
            // Green header: the app mark, its name and a one-line promise,
            // all drawn from the app's own green palette so the header and
            // the cards below read as one design.
            SliverAppBar(
              expandedHeight: 210,
              floating: false,
              pinned: true,
              elevation: 0,
              backgroundColor: AppColors.primaryDark,
              actions: [
                Padding(
                  padding: const EdgeInsets.only(left: 6),
                  child: IconButton(
                    onPressed: () => _requestNativeRatePrompt(context),
                    tooltip: 'قيّم التطبيق',
                    icon: const Icon(
                      Icons.star_rate_rounded,
                      color: Colors.white,
                      size: 26,
                    ),
                  ),
                ),
              ],
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.primaryLight,
                        AppColors.primary,
                        AppColors.primaryDark,
                      ],
                      begin: Alignment.topRight,
                      end: Alignment.bottomLeft,
                    ),
                  ),
                  child: Stack(
                    children: [
                      // Soft light blooms keep the flat green from looking
                      // plain without bringing in a second colour.
                      const Positioned(
                        top: -45,
                        right: -35,
                        child: _HeaderGlow(size: 175, opacity: 0.16),
                      ),
                      const Positioned(
                        bottom: -65,
                        left: -45,
                        child: _HeaderGlow(size: 205, opacity: 0.10),
                      ),
                      SafeArea(
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 82,
                                height: 82,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(26),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFF14532D)
                                          .withOpacity(0.22),
                                      blurRadius: 18,
                                      offset: const Offset(0, 8),
                                    ),
                                  ],
                                ),
                                child:  ClipRRect(
                                  borderRadius: BorderRadius.circular(26),
                                  child: Image.asset(
                                    'assets/logo.png',
                                  ),
                                ),
                              ),
                              const SizedBox(height: 14),
                              const Text(
                                AppConstants.appName,
                                style: TextStyle(
                                  fontFamily: 'Cairo',
                                  fontSize: 24,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white,
                                  letterSpacing: 0.3,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 5,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.18),
                                  borderRadius: BorderRadius.circular(999),
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.24),
                                  ),
                                ),
                                child: const Text(
                                  'كتب وحلول واختبارات المناهج السعودية',
                                  style: TextStyle(
                                    fontFamily: 'Cairo',
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
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
            ),

            // Content
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
              sliver: SliverList(
                delegate: SliverChildListDelegate(_staggeredChildren([
                  // const _SectionHeader(
                  //   title: 'المكتبة الدراسية',
                  //   subtitle: 'كل ما تحتاجه من كتب وحلول واختبارات',
                  // ),
                  // _ActionGrid(actions: _libraryActions),
                  // const SizedBox(height: 26),

                  const _SectionHeader(
                    title: 'المراحل الدراسية',
                    subtitle: 'تصفح الكتب حسب الصف الدراسي',
                  ),
                  const _GradesGrid(),
                  const SizedBox(height: 26),

                  const _SectionHeader(
                    title: 'أدوات الطالب',
                    subtitle: 'أدوات سريعة ترتّب يومك ومسارك الدراسي',
                  ),
                  _ActionGrid(actions: _toolActions),
                  const SizedBox(height: 26),

                  Consumer<ReaderLibraryProvider>(
                    builder: (context, provider, _) {
                      final count = provider.downloadedBooks.length;

                      return Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF16A34A), Color(0xFF4ADE80)],
                            begin: Alignment.topRight,
                            end: Alignment.bottomLeft,
                          ),
                          borderRadius: BorderRadius.circular(22),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF16A34A).withOpacity(0.25),
                              blurRadius: 16,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: InkWell(
                          onTap: () => _open(const DownloadedBooksScreen()),
                          borderRadius: BorderRadius.circular(22),
                          child: Row(
                            children: [
                              Container(
                                width: 56,
                                height: 56,
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.18),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: const Icon(
                                  Icons.download_done_rounded,
                                  color: Colors.white,
                                  size: 30,
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'الكتب المحمّلة',
                                      style: TextStyle(
                                        fontFamily: 'Cairo',
                                        fontSize: 17,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      count == 0
                                          ? 'نزّل كتبك لتفتح بسرعة حتى بدون انتظار الشبكة'
                                          : '$count كتاب محفوظ محليًا وجاهز للقراءة السريعة',
                                      style: const TextStyle(
                                        fontFamily: 'Cairo',
                                        fontSize: 12,
                                        color: Colors.white,
                                        height: 1.4,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(
                                Icons.arrow_forward_ios_rounded,
                                color: Colors.white,
                                size: 18,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  Consumer<ReaderLibraryProvider>(
                    builder: (context, provider, _) {
                      final recents = provider.recentBooks.take(3).toList();

                      if (recents.isEmpty) {
                        return const SizedBox.shrink();
                      }

                      return Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 16,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'أكمل من حيث توقفت',
                              style: TextStyle(
                                fontFamily: 'Cairo',
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'آخر الكتب المفتوحة مع الصفحة التي وصلت إليها',
                              style: TextStyle(
                                fontFamily: 'Cairo',
                                fontSize: 12,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 14),
                            ...recents.map(
                              (entry) => Padding(
                                padding: const EdgeInsets.only(bottom: 10),
                                child: InkWell(
                                  onTap: () => _open(
                                    PdfReaderScreen(book: entry.book),
                                  ),
                                  borderRadius: BorderRadius.circular(18),
                                  child: Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF8FAFC),
                                      borderRadius: BorderRadius.circular(18),
                                      border: Border.all(
                                        color:
                                            AppColors.border.withOpacity(0.5),
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          child: SizedBox(
                                            width: 46,
                                            height: 46,
                                            child: BookCoverImage(
                                              book: entry.book,
                                              fallback: Container(
                                                color: AppColors.primary
                                                    .withOpacity(0.12),
                                                child: const Icon(
                                                  Icons.menu_book_rounded,
                                                  color: AppColors.primary,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                entry.book.title,
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: const TextStyle(
                                                  fontFamily: 'Cairo',
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w800,
                                                  color: AppColors.textPrimary,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                '${entry.book.subject} • صفحة ${entry.lastPage}',
                                                style: const TextStyle(
                                                  fontFamily: 'Cairo',
                                                  fontSize: 12,
                                                  color:
                                                      AppColors.textSecondary,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const Icon(
                                          Icons.arrow_forward_ios_rounded,
                                          size: 16,
                                          color: AppColors.textLight,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  Consumer<ReaderLibraryProvider>(
                    builder: (context, provider, _) {
                      return Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF15803D), Color(0xFF4ADE80)],
                            begin: Alignment.topRight,
                            end: Alignment.bottomLeft,
                          ),
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'متابعة التقدم الدراسي',
                              style: TextStyle(
                                fontFamily: 'Cairo',
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 6),
                            const Text(
                              'لوحة سريعة توضح ما أنجزته داخل القراءة والتحميل والملاحظات.',
                              style: TextStyle(
                                fontFamily: 'Cairo',
                                fontSize: 12,
                                color: Colors.white,
                                height: 1.5,
                              ),
                            ),
                            const SizedBox(height: 14),
                            Row(
                              children: [
                                Expanded(
                                  child: _StatBubble(
                                    label: 'بدأتها',
                                    value: '${provider.booksWithProgressCount}',
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: _StatBubble(
                                    label: 'إشارات',
                                    value: '${provider.totalBookmarksCount}',
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: _StatBubble(
                                    label: 'ملاحظات',
                                    value: '${provider.totalNotesCount}',
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Align(
                              alignment: Alignment.centerLeft,
                              child: TextButton.icon(
                                onPressed: () =>
                                    _open(const ProgressOverviewScreen()),
                                icon: const Icon(
                                  Icons.analytics_rounded,
                                  color: Colors.white,
                                ),
                                label: const Text(
                                  'افتح لوحة التقدم',
                                  style: TextStyle(
                                    fontFamily: 'Cairo',
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  Consumer<ReaderLibraryProvider>(
                    builder: (context, provider, _) {
                      final weekly = provider.weeklyPlan
                          .where((item) => item.title.trim().isNotEmpty)
                          .take(3)
                          .toList();

                      return Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.04),
                              blurRadius: 14,
                              offset: const Offset(0, 7),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 48,
                                  height: 48,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF2563EB)
                                        .withOpacity(0.12),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: const Icon(
                                    Icons.edit_calendar_rounded,
                                    color: Color(0xFF2563EB),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                const Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'الخطة الأسبوعية',
                                        style: TextStyle(
                                          fontFamily: 'Cairo',
                                          fontSize: 18,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                      SizedBox(height: 4),
                                      Text(
                                        'رتّب أسبوعك الدراسي واحفظ تركيز كل يوم',
                                        style: TextStyle(
                                          fontFamily: 'Cairo',
                                          fontSize: 12,
                                          color: AppColors.textSecondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 14),
                            if (weekly.isEmpty)
                              const Text(
                                'لم تضف خطة بعد. افتح القسم وابنِ أسبوعك الدراسي بشكل واضح.',
                                style: TextStyle(
                                  fontFamily: 'Cairo',
                                  fontSize: 13,
                                  color: AppColors.textSecondary,
                                  height: 1.5,
                                ),
                              )
                            else
                              ...weekly.map(
                                (item) => Padding(
                                  padding: const EdgeInsets.only(bottom: 8),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 8,
                                        height: 8,
                                        decoration: const BoxDecoration(
                                          color: Color(0xFF2563EB),
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Text(
                                          '${_arabicDayLabel(item.dayId)}: ${item.title} • ${item.focus}',
                                          style: const TextStyle(
                                            fontFamily: 'Cairo',
                                            fontSize: 12,
                                            color: AppColors.textPrimary,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            const SizedBox(height: 10),
                            ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF2563EB),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              onPressed: () => _open(const WeeklyPlanScreen()),
                              icon: const Icon(Icons.arrow_forward_rounded),
                              label: const Text(
                                'افتح الخطة الأسبوعية',
                                style: TextStyle(fontFamily: 'Cairo'),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 26),

                  const _SectionHeader(
                    title: 'المزيد لك',
                    subtitle: 'أقسام مختارة تدعم مسيرتك الدراسية',
                  ),
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: EdgeInsets.zero,
                    crossAxisCount: 2,
                    crossAxisSpacing: 14,
                    mainAxisSpacing: 14,
                    // A fixed tile height keeps two-line titles from clipping.
                    childAspectRatio: 1.0,
                    children: [
                      MenuButton(
                        title: 'أفضل الفرص',
                        icon: Icons.rocket_launch_rounded,
                        color: const Color(0xFF065F46),
                        onTap: () => _open(const BestOpportunitiesScreen()),
                      ),
                      MenuButton(
                        title: 'اختبارات السعودية',
                        icon: Icons.fact_check_rounded,
                        color: const Color(0xFF15803D),
                        onTap: () =>
                            _open(const SearchScreen(initialQuery: 'اختبار')),
                      ),
                      MenuButton(
                        title: 'حلول ومراجعات',
                        icon: Icons.assignment_turned_in_rounded,
                        color: const Color(0xFF166534),
                        onTap: () =>
                            _open(const SearchScreen(initialQuery: 'حل')),
                      ),
                      MenuButton(
                        title: 'المسارات الثانوية',
                        icon: Icons.account_tree_rounded,
                        color: const Color(0xFF0D9488),
                        onTap: () => _open(const SecondaryTracksScreen()),
                      ),
                      MenuButton(
                        title: 'مناطق السعودية',
                        icon: Icons.map_rounded,
                        color: const Color(0xFF047857),
                        onTap: () => _open(const RegionsPreviewScreen()),
                      ),
                      MenuButton(
                        title: 'أدعية وأذكار',
                        icon: Icons.auto_awesome_rounded,
                        color: const Color(0xFFD6A64F),
                        onTap: () => _open(const StudentAthkarScreen()),
                      ),
                    ],
                  ),

                  const SizedBox(height: 26),

                  // Welcome Card
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.primary.withOpacity(0.08),
                          AppColors.primaryLight.withOpacity(0.05),
                        ],
                        begin: Alignment.topRight,
                        end: Alignment.bottomLeft,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: AppColors.primary.withOpacity(0.15),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Icon(
                            Icons.lightbulb_rounded,
                            color: AppColors.primary,
                            size: 26,
                          ),
                        ),
                        const SizedBox(width: 14),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'نصيحة اليوم',
                                style: TextStyle(
                                  fontFamily: 'Cairo',
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.primary,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'ابدأ بمراجعة كتبك المفضلة للوصول السريع إلى موادك الدراسية',
                                style: TextStyle(
                                  fontFamily: 'Cairo',
                                  fontSize: 12,
                                  color: AppColors.textSecondary,
                                  height: 1.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 40),
                ])),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A soft circular light used behind the home header, in the header's own
/// white so the gradient keeps a single colour family.
class _HeaderGlow extends StatelessWidget {
  final double size;
  final double opacity;

  const _HeaderGlow({required this.size, required this.opacity});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withOpacity(opacity),
      ),
    );
  }
}

/// A single destination shown inside a home-screen action grid.
class _HomeAction {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _HomeAction({
    required this.title,
    required this.icon,
    required this.color,
    required this.onTap,
  });
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final String subtitle;

  const _SectionHeader({
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 2, bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 4,
            height: 34,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(999),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 11.5,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Lays the actions out in a 3-column grid of equally sized tiles. A fixed
/// tile height (rather than an aspect ratio) keeps every row identical no
/// matter how wide the device is, so two-line titles never clip.
class _ActionGrid extends StatelessWidget {
  final List<_HomeAction> actions;

  const _ActionGrid({required this.actions});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.zero,
      itemCount: actions.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        mainAxisExtent: 118,
      ),
      itemBuilder: (_, index) => _QuickActionTile(action: actions[index]),
    );
  }
}

class _QuickActionTile extends StatelessWidget {
  final _HomeAction action;

  const _QuickActionTile({required this.action});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: action.onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.primaryVeryLight),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 6),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: action.color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(action.icon, color: action.color, size: 24),
              ),
              const SizedBox(height: 10),
              SizedBox(
                height: 32,
                child: Center(
                  child: Text(
                    action.title,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                      height: 1.35,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatBubble extends StatelessWidget {
  final String label;
  final String value;

  const _StatBubble({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.14),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              fontFamily: 'Cairo',
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'Cairo',
              fontSize: 11,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

class _GradesGrid extends StatefulWidget {
  const _GradesGrid();

  @override
  State<_GradesGrid> createState() => _GradesGridState();
}

class _GradesGridState extends State<_GradesGrid> {
  String _selectedStage = 'الكل';

  @override
  Widget build(BuildContext context) {
    final List<GradeModel> filteredGrades = _selectedStage == 'الكل'
        ? GradeModel.allGrades
        : GradeModel.allGrades.where((g) {
            if (_selectedStage == 'الابتدائية') return g.stage == EducationalStage.primary;
            if (_selectedStage == 'المتوسط') return g.stage == EducationalStage.middle;
            if (_selectedStage == 'الثانوية') return g.stage == EducationalStage.high;
            return true;
          }).toList();

    return Column(
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: ['الكل', 'الابتدائية', 'المتوسط', 'الثانوية'].map((stage) {
              final isSelected = _selectedStage == stage;
              return Padding(
                padding: const EdgeInsets.only(left: 8),
                child: ChoiceChip(
                  label: Text(stage, style: TextStyle(fontFamily: 'Cairo', fontSize: 12, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
                  selected: isSelected,
                  onSelected: (val) {
                    if (val) setState(() => _selectedStage = stage);
                  },
                  selectedColor: AppColors.primary,
                  labelStyle: TextStyle(color: isSelected ? Colors.white : AppColors.textPrimary),
                  backgroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  side: BorderSide(color: isSelected ? Colors.transparent : AppColors.border),
                  showCheckmark: false,
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: filteredGrades.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.85,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemBuilder: (context, index) {
            final grade = filteredGrades[index];
            return _GradeItem(grade: grade);
          },
        ),
      ],
    );
  }
}

class _GradeItem extends StatelessWidget {
  final GradeModel grade;

  const _GradeItem({required this.grade});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => GradeBooksScreen(grade: grade)),
        ),
        borderRadius: BorderRadius.circular(20),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.primaryVeryLight),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          padding: const EdgeInsets.all(8),
          child: Column(
            children: [
              Expanded(
                child: GradeBadge(
                  gradeNumber: grade.gradeNumber,
                  color: grade.color,
                  gradeId: grade.id,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                grade.displayName,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                  height: 1.2,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
            ],
          ),
        ),
      ),
    );
  }
}

String _arabicDayLabel(String dayId) {
  switch (dayId) {
    case 'sun':
      return 'الأحد';
    case 'mon':
      return 'الاثنين';
    case 'tue':
      return 'الثلاثاء';
    case 'wed':
      return 'الأربعاء';
    case 'thu':
      return 'الخميس';
    case 'fri':
      return 'الجمعة';
    case 'sat':
      return 'السبت';
    default:
      return dayId;
  }
}
