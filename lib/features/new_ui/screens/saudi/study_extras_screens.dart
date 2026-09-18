import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:kotabi_saudi/core/new_ui/app_colors.dart';
import 'package:kotabi_saudi/core/providers/reader_library_provider.dart';
import 'package:kotabi_saudi/core/services/reader_library_service.dart';
import 'package:kotabi_saudi/features/new_ui/widgets/book_cover_image.dart';
import '../pdf_reader/pdf_reader_screen.dart';
import 'saudi_education_plus_screens.dart';

class ProgressOverviewScreen extends StatelessWidget {
  const ProgressOverviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('متابعة التقدم الدراسي'),
        backgroundColor: const Color(0xFF15803D),
        foregroundColor: Colors.white,
      ),
      body: Consumer<ReaderLibraryProvider>(
        builder: (context, library, _) {
          return ListView(
            padding: const EdgeInsets.all(18),
            children: [
              _ProgressHero(
                progressBooks: library.booksWithProgressCount,
                recentBooks: library.recentBooks.length,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _ProgressStatCard(
                      title: 'كتب بدأت بها',
                      value: '${library.booksWithProgressCount}',
                      color: const Color(0xFF15803D),
                      icon: Icons.auto_stories_rounded,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _ProgressStatCard(
                      title: 'إشارات مرجعية',
                      value: '${library.totalBookmarksCount}',
                      color: const Color(0xFFF59E0B),
                      icon: Icons.bookmark_rounded,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _ProgressStatCard(
                      title: 'ملاحظات',
                      value: '${library.totalNotesCount}',
                      color: const Color(0xFF8B5CF6),
                      icon: Icons.sticky_note_2_rounded,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _ProgressStatCard(
                      title: 'كتب محمّلة',
                      value: '${library.downloadedBooks.length}',
                      color: const Color(0xFF16A34A),
                      icon: Icons.download_done_rounded,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              const _SubHeader(
                title: 'آخر ما تم فتحه',
                subtitle: 'يمكنك الرجوع مباشرة إلى نفس مكان التوقف',
              ),
              const SizedBox(height: 12),
              ...library.recentBooks.take(8).map(
                    (entry) => _RecentStudyTile(entry: entry),
                  ),
            ],
          );
        },
      ),
    );
  }
}

class WeeklyPlanScreen extends StatefulWidget {
  const WeeklyPlanScreen({super.key});

  @override
  State<WeeklyPlanScreen> createState() => _WeeklyPlanScreenState();
}

class _WeeklyPlanScreenState extends State<WeeklyPlanScreen> {
  final Map<String, String> _labels = const {
    'sun': 'الأحد',
    'mon': 'الاثنين',
    'tue': 'الثلاثاء',
    'wed': 'الأربعاء',
    'thu': 'الخميس',
    'fri': 'الجمعة',
    'sat': 'السبت',
  };

  final List<String> _focusOptions = const [
    'مراجعة كتاب',
    'حل واجبات',
    'اختبارات',
    'ملخصات',
    'قدرات وتحصيلي',
    'راحة',
  ];

  late final Map<String, TextEditingController> _controllers;
  late final Map<String, String> _focuses;

  @override
  void initState() {
    super.initState();
    final provider = context.read<ReaderLibraryProvider>();
    _controllers = {
      for (final dayId in _labels.keys)
        dayId: TextEditingController(
          text: provider.weeklyPlan
              .where((item) => item.dayId == dayId)
              .map((item) => item.title)
              .firstOrNull,
        ),
    };
    _focuses = {
      for (final dayId in _labels.keys)
        dayId: provider.weeklyPlan
                .where((item) => item.dayId == dayId)
                .map((item) => item.focus)
                .firstOrNull ??
            _focusOptions.first,
    };
  }

  @override
  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('الخطة الأسبوعية'),
        backgroundColor: const Color(0xFF2563EB),
        foregroundColor: Colors.white,
        actions: [
          TextButton(
            onPressed: _savePlan,
            child: const Text(
              'حفظ',
              style: TextStyle(
                fontFamily: 'Cairo',
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF2563EB), Color(0xFF3B82F6)],
              ),
              borderRadius: BorderRadius.circular(24),
            ),
            child: const Text(
              'صمّم أسبوعك الدراسي بشكل بسيط: حدّد مهمة رئيسية لكل يوم مع نوع التركيز، وسيبقى كل شيء محفوظًا داخل التطبيق.',
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 14,
                color: Colors.white,
                height: 1.7,
              ),
            ),
          ),
          const SizedBox(height: 16),
          ..._labels.entries.map((entry) {
            final dayId = entry.key;
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    entry.value,
                    style: const TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<String>(
                    value: _focuses[dayId],
                    decoration: InputDecoration(
                      labelText: 'نوع التركيز',
                      labelStyle: const TextStyle(fontFamily: 'Cairo'),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    items: _focusOptions
                        .map(
                          (option) => DropdownMenuItem(
                            value: option,
                            child: Text(
                              option,
                              style: const TextStyle(fontFamily: 'Cairo'),
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      if (value == null) return;
                      setState(() => _focuses[dayId] = value);
                    },
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _controllers[dayId],
                    decoration: InputDecoration(
                      hintText: 'مثال: مراجعة رياضيات الصف الأول الثانوي',
                      hintStyle: const TextStyle(fontFamily: 'Cairo'),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Future<void> _savePlan() async {
    final items = _labels.keys.map((dayId) {
      return WeeklyPlanItem(
        dayId: dayId,
        title: _controllers[dayId]!.text.trim(),
        focus: _focuses[dayId]!,
      );
    }).toList();

    await context.read<ReaderLibraryProvider>().saveWeeklyPlan(items);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('تم حفظ الخطة الأسبوعية')),
    );
  }
}

class BestOpportunitiesScreen extends StatelessWidget {
  const BestOpportunitiesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const opportunities = [
      (
        'الجامعات السعودية',
        'راجِع خطط القبول، الموزونة، والتخصصات التي تناسب مستواك واهتماماتك.',
        Icons.account_balance_rounded,
        Color(0xFF006C35)
      ),
      (
        'التدريب التقني والمهني',
        'فرص ممتازة لمن يفضل المسار التطبيقي أو يريد دخول سوق العمل بسرعة.',
        Icons.engineering_rounded,
        Color(0xFF15803D)
      ),
      (
        'المنح والبرامج النوعية',
        'برامج ومبادرات ومسارات تطوير قد تكون بوابتك القادمة بعد التخرج.',
        Icons.workspace_premium_rounded,
        Color(0xFFD97706)
      ),
      (
        'المهارات الرقمية',
        'تعلم مهارة رقمية قوية قد يفتح لك فرصًا دراسية ومهنية مبكرة داخل السعودية.',
        Icons.computer_rounded,
        Color(0xFF4F46E5)
      ),
    ];
    const actionBullets = [
      'ابدأ بحساب نسبتك الموزونة ومقارنة أكثر من سيناريو قبل التقديم.',
      'ابنِ ملفًا شخصيًا بسيطًا: إنجازات، دورات، تطوع، ومهارات رقمية.',
      'رتّب فرصك إلى ثلاث مسارات: جامعي، مهني، وبرامجي حتى تكون الصورة أوضح.',
      'اختر مهارة واحدة مطلوبة في السوق وابدأ بها خلال هذا الشهر.',
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF8F7F2),
      appBar: AppBar(
        title: const Text('أفضل الفرص'),
        backgroundColor: const Color(0xFF111827),
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  Color(0xFF111827),
                  Color(0xFF374151),
                  Color(0xFFD6A64F)
                ],
              ),
              borderRadius: BorderRadius.circular(24),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'أفضل الفرص للطالب والخريج السعودي',
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'هذه الشاشة تجمع أفضل الاتجاهات التي يفكر فيها الطالب والخريج داخل السعودية: جامعة، تدريب، برامج، ومهارات ترفع فرصك بشكل حقيقي.',
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 14,
                    color: Colors.white,
                    height: 1.7,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(22),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'خطوات عملية هذا الأسبوع',
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 10),
                ...actionBullets.map(
                  (bullet) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 9,
                          height: 9,
                          margin: const EdgeInsets.only(top: 6),
                          decoration: const BoxDecoration(
                            color: Color(0xFF006C35),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            bullet,
                            style: const TextStyle(
                              fontFamily: 'Cairo',
                              fontSize: 13,
                              color: AppColors.textSecondary,
                              height: 1.6,
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
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _OpportunityMiniCard(
                  title: 'احسب موزونتك',
                  subtitle: 'خطوة أولى قبل الفرص',
                  color: const Color(0xFF006C35),
                  icon: Icons.calculate_rounded,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const WeightedScoreScreen(),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _OpportunityMiniCard(
                  title: 'وضع الخريج',
                  subtitle: 'خارطة طريق أعمق',
                  color: const Color(0xFFD97706),
                  icon: Icons.wb_incandescent_rounded,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const GraduateModeScreen(),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const _SubHeader(
            title: 'مسارات بارزة',
            subtitle: 'اختر المسار الأقرب لك ثم ابدأ بجمع محتوى داعم له',
          ),
          const SizedBox(height: 12),
          const Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _HighlightChip(label: 'قبول جامعي'),
              _HighlightChip(label: 'كليات تقنية'),
              _HighlightChip(label: 'منح وبرامج'),
              _HighlightChip(label: 'مسار مهني'),
              _HighlightChip(label: 'مهارات رقمية'),
              _HighlightChip(label: 'ملف إنجاز'),
            ],
          ),
          const SizedBox(height: 16),
          ...opportunities.map(
            (item) => Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(22),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: item.$4.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(item.$3, color: item.$4),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.$1,
                          style: const TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          item.$2,
                          style: const TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 13,
                            color: AppColors.textSecondary,
                            height: 1.6,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: const Color(0xFFF3F4F6),
              borderRadius: BorderRadius.circular(22),
            ),
            child: ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(
                Icons.wb_incandescent_rounded,
                color: Color(0xFFD97706),
              ),
              title: const Text(
                'وضع خاص بالخريج',
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontWeight: FontWeight.w800,
                ),
              ),
              subtitle: const Text(
                'ادخل إلى شاشة ضوء الخريج للمحتوى الأكثر عمقًا وتفصيلًا.',
                style: TextStyle(
                  fontFamily: 'Cairo',
                  color: AppColors.textSecondary,
                ),
              ),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const GraduateSpotlightScreen(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class GraduateModeScreen extends StatelessWidget {
  const GraduateModeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const pillars = [
      (
        'الجامعة والقبول',
        'موازنة الرغبات بين الموزونة، التخصص، والمدينة المناسبة لك.',
        Icons.school_rounded,
        Color(0xFF006C35)
      ),
      (
        'المهارات والشهادات',
        'بناء ملف داعم بالدورات والمهارات الرقمية والتطوع.',
        Icons.verified_rounded,
        Color(0xFF4F46E5)
      ),
      (
        'المسار المهني المبكر',
        'التفكير في العمل الجزئي، التدريب، أو المسار التطبيقي باكرًا.',
        Icons.work_history_rounded,
        Color(0xFF15803D)
      ),
      (
        'الهوية الشخصية',
        'سيرة ذاتية، حسابات مهنية، ورسالة تعريفية بسيطة وواضحة.',
        Icons.badge_rounded,
        Color(0xFFD97706)
      ),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF8F7F2),
      appBar: AppBar(
        title: const Text('وضع الخريج'),
        backgroundColor: const Color(0xFF111827),
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  Color(0xFF111827),
                  Color(0xFF1F2937),
                  Color(0xFFD6A64F)
                ],
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
              ),
              borderRadius: BorderRadius.circular(26),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'وضع خاص بالخريج السعودي',
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'هنا تبدأ المرحلة التالية بوضوح: موزونة، تخصص، جامعة، مهارات، فرص، وخطوات عملية تساعدك قبل وبعد التخرج.',
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 14,
                    color: Colors.white,
                    height: 1.6,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          ...pillars.map(
            (pillar) => Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(22),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: pillar.$4.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(pillar.$3, color: pillar.$4),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          pillar.$1,
                          style: const TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          pillar.$2,
                          style: const TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 13,
                            color: AppColors.textSecondary,
                            height: 1.6,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Row(
            children: [
              Expanded(
                child: _OpportunityMiniCard(
                  title: 'ضوء الخريج',
                  subtitle: 'المحتوى الأعمق',
                  color: const Color(0xFFD97706),
                  icon: Icons.wb_incandescent_rounded,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const GraduateSpotlightScreen(),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _OpportunityMiniCard(
                  title: 'أفضل الفرص',
                  subtitle: 'مساراتك التالية',
                  color: const Color(0xFF006C35),
                  icon: Icons.rocket_launch_rounded,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const BestOpportunitiesScreen(),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _OpportunityMiniCard(
            title: 'حاسبة النسبة الموزونة',
            subtitle: 'ابدأ من النتيجة ثم قرر طريقك الدراسي أو المهني',
            color: const Color(0xFF15803D),
            icon: Icons.calculate_rounded,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const WeightedScoreScreen(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProgressHero extends StatelessWidget {
  final int progressBooks;
  final int recentBooks;

  const _ProgressHero({
    required this.progressBooks,
    required this.recentBooks,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF15803D), Color(0xFF4ADE80)],
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'لوحة التقدم',
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'لديك $progressBooks كتاب بدأت به و$recentBooks عناصر في سجل آخر قراءة.',
                  style: const TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 13,
                    color: Colors.white,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 68,
            height: 68,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.16),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(
              Icons.trending_up_rounded,
              color: Colors.white,
              size: 34,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProgressStatCard extends StatelessWidget {
  final String title;
  final String value;
  final Color color;
  final IconData icon;

  const _ProgressStatCard({
    required this.title,
    required this.value,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Icon(icon, color: color),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(
              fontFamily: 'Cairo',
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _SubHeader extends StatelessWidget {
  final String title;
  final String subtitle;

  const _SubHeader({
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontFamily: 'Cairo',
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: const TextStyle(
            fontFamily: 'Cairo',
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

class _RecentStudyTile extends StatelessWidget {
  final RecentBookEntry entry;

  const _RecentStudyTile({required this.entry});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: SizedBox(
            width: 52,
            height: 52,
            child: BookCoverImage(
              book: entry.book,
              fallback: Container(
                color: AppColors.primary.withOpacity(0.1),
                child: const Icon(Icons.menu_book_rounded),
              ),
            ),
          ),
        ),
        title: Text(
          entry.book.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontFamily: 'Cairo',
            fontWeight: FontWeight.w800,
          ),
        ),
        subtitle: Text(
          '${entry.book.subject} • صفحة ${entry.lastPage}',
          style: const TextStyle(
            fontFamily: 'Cairo',
            color: AppColors.textSecondary,
          ),
        ),
        trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => PdfReaderScreen(book: entry.book),
          ),
        ),
      ),
    );
  }
}

class _OpportunityMiniCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final Color color;
  final IconData icon;
  final VoidCallback onTap;

  const _OpportunityMiniCard({
    required this.title,
    required this.subtitle,
    required this.color,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: color),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                fontFamily: 'Cairo',
                fontSize: 15,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: const TextStyle(
                fontFamily: 'Cairo',
                fontSize: 12,
                color: AppColors.textSecondary,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HighlightChip extends StatelessWidget {
  final String label;

  const _HighlightChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontFamily: 'Cairo',
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }
}
