import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'package:kotabi_saudi/core/new_ui/app_colors.dart';
import 'package:kotabi_saudi/core/new_ui/helpers.dart';
import 'package:kotabi_saudi/core/providers/favorites_provider.dart';
import 'package:kotabi_saudi/core/providers/reader_library_provider.dart';
import '../browse/browse_screen.dart';
import '../downloads/downloaded_books_screen.dart';

class StudentDayScreen extends StatelessWidget {
  const StudentDayScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final date = _formatArabicDate(DateTime.now());

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('اليوم الدراسي'),
        backgroundColor: const Color(0xFF006C35),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(18),
        child: Consumer2<FavoritesProvider, ReaderLibraryProvider>(
          builder: (context, favorites, library, _) {
            return ListView(
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF006C35), Color(0xFF0E8A4B)],
                    ),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'خطة يومك الدراسي',
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        date,
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 13,
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'ابدأ بالكتب المحمّلة أو ارجع إلى المفضلة ثم أكمل على الصفوف الدراسية حسب المنهج.',
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 13,
                          color: Colors.white,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _SimpleStatCard(
                        title: 'المفضلة',
                        value: '${favorites.favorites.length}',
                        icon: Icons.favorite_rounded,
                        color: const Color(0xFFE11D48),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _SimpleStatCard(
                        title: 'الكتب المحمّلة',
                        value: '${library.downloadedBooks.length}',
                        icon: Icons.download_done_rounded,
                        color: const Color(0xFF15803D),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                _ActionTile(
                  title: 'ابدأ من المراحل الدراسية',
                  subtitle: 'تصفّح الكتب والمواد حسب الصف الدراسي',
                  icon: Icons.auto_stories_rounded,
                  color: AppColors.primary,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const BrowseScreen()),
                  ),
                ),
                _ActionTile(
                  title: 'افتح الكتب المحمّلة',
                  subtitle: 'وصول سريع للكتب المحفوظة داخل الجهاز',
                  icon: Icons.download_for_offline_rounded,
                  color: const Color(0xFF16A34A),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const DownloadedBooksScreen()),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class SecondaryTracksScreen extends StatelessWidget {
  const SecondaryTracksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const tracks = [
      (
        'المسار العام',
        'المواد الأساسية ومسار البداية للثانوي',
        Icons.school_rounded
      ),
      (
        'الصحة والحياة',
        'مواد مرتبطة بالصحة والعلوم الحيوية',
        Icons.health_and_safety_rounded
      ),
      (
        'علوم الحاسب والهندسة',
        'الحاسب والهندسة والتقنية الرقمية',
        Icons.memory_rounded
      ),
      (
        'إدارة الأعمال',
        'مهارات الأعمال والإدارة والأنظمة',
        Icons.business_center_rounded
      ),
      ('المسار الشرعي', 'مواد شرعية ودراسات متخصصة', Icons.menu_book_rounded),
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('المسارات في الثانوية'),
        backgroundColor: const Color(0xFF4F46E5),
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFFEEF2FF),
              borderRadius: BorderRadius.circular(24),
            ),
            child: const Text(
              'هذا القسم يوضح المسارات الثانوية السعودية بشكل تمهيدي، ويمكن لاحقًا ربط كل مسار بمواده ومحتواه داخل التطبيق.',
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 14,
                color: AppColors.textPrimary,
                height: 1.7,
              ),
            ),
          ),
          const SizedBox(height: 16),
          ...tracks.map(
            (track) => Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: const Color(0xFF4F46E5).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(track.$3, color: const Color(0xFF4F46E5)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          track.$1,
                          style: const TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          track.$2,
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
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class RegionsPreviewScreen extends StatefulWidget {
  const RegionsPreviewScreen({super.key});

  @override
  State<RegionsPreviewScreen> createState() => _RegionsPreviewScreenState();
}

class _RegionsPreviewScreenState extends State<RegionsPreviewScreen> {
  @override
  Widget build(BuildContext context) {
    const regions = [
      (
        'الرياض',
        'مركز تعليمي واسع ومتعدد المسارات',
        'منطقة قوية للمحتوى المدرسي والجامعي والمهني، ويمكن لاحقًا ربطها بفرص ومبادرات محلية.',
        Color(0xFF006C35)
      ),
      (
        'مكة المكرمة',
        'كثافة تعليمية عالية وتنوع كبير',
        'مناسبة لعرض محتوى عام وموارد مساندة للطالب عبر المدارس والجامعات والمراجعات.',
        Color(0xFFD97706)
      ),
      (
        'المدينة المنورة',
        'بيئة تعليمية متوازنة',
        'يمكن ربطها لاحقًا بمحتوى دراسي محلي ومبادرات طلابية وخدمات إرشادية.',
        Color(0xFF15803D)
      ),
      (
        'المنطقة الشرقية',
        'تخصصات علمية وتقنية بارزة',
        'تصلح لتجميع فرص جامعية ومهنية ومحتوى تقني متقدم داخل التطبيق.',
        Color(0xFF2563EB)
      ),
      (
        'عسير',
        'توسعة مهمة للمحتوى المحلي',
        'منطقة مناسبة لربط الأدلة والمبادرات التعليمية بالطالب بشكل أقرب.',
        Color(0xFF7C3AED)
      ),
      (
        'القصيم',
        'محور دراسي مهم في قلب المملكة',
        'يمكن دعمها لاحقًا بمحتوى مواد واختبارات وخدمات تعليمية موجهة.',
        Color(0xFFE11D48)
      ),
      (
        'تبوك',
        'فرص توسعة تعليمية واعدة',
        'قابلة لربط المحتوى بالمؤسسات التعليمية والبرامج التطويرية مستقبلًا.',
        Color(0xFF16A34A)
      ),
      (
        'حائل',
        'مساحة مناسبة لبناء محتوى محلي',
        'يمكن مستقبلاً إضافة أدلة وخرائط مبادرات ومحتوى حسب المنطقة.',
        Color(0xFF4B5563)
      ),
      (
        'جازان',
        'تنوع جغرافي وتعليمي مهم',
        'تصلح لعرض مسارات ومصادر محلية مرتبطة بالإدارة التعليمية.',
        Color(0xFF059669)
      ),
      (
        'نجران',
        'منطقة قابلة لإبراز المبادرات المحلية',
        'يمكن تقوية حضورها داخل التطبيق عبر محتوى وخدمات تعليمية مخصصة.',
        Color(0xFFB45309)
      ),
      (
        'الجوف',
        'واجهة شمالية واعدة للمحتوى التعليمي',
        'مناسبة لتجميع مصادر وخرائط تعليمية حسب المنطقة.',
        Color(0xFF4338CA)
      ),
      (
        'الباحة',
        'منطقة هادئة وغنية بالفرص المحلية',
        'يمكن دعمها لاحقًا بمحتوى طلابي وإرشادي وفرص تعليمية نوعية.',
        Color(0xFFBE185D)
      ),
    ];
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('خرائط ومناطق السعودية'),
        backgroundColor: const Color(0xFF1F2937),
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF111827), Color(0xFF374151)],
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
              ),
              borderRadius: BorderRadius.circular(24),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'مناطق السعودية بشكل تفاعلي',
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'اختر المنطقة، استعرض بطاقتها، وابدأ من الآن تصور التوسعة التعليمية المحلية داخل التطبيق.',
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 13,
                    color: Colors.white,
                    height: 1.6,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          ...regions.map(
            (region) => Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: region.$4.withOpacity(0.10),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 54,
                        height: 54,
                        decoration: BoxDecoration(
                          color: region.$4.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Icon(Icons.map_rounded, color: region.$4),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              region.$1,
                              style: const TextStyle(
                                fontFamily: 'Cairo',
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              region.$2,
                              style: TextStyle(
                                fontFamily: 'Cairo',
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: region.$4,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    region.$3,
                    style: const TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 14,
                      color: AppColors.textSecondary,
                      height: 1.7,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _InteractiveMiniAction(
                          label: 'نسخ الاسم',
                          icon: Icons.copy_rounded,
                          color: region.$4,
                          onTap: () async {
                            await Clipboard.setData(
                              ClipboardData(text: region.$1),
                            );
                            if (!context.mounted) return;
                            AppHelpers.showSnackBar(
                                context, 'تم نسخ اسم المنطقة');
                          },
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _InteractiveMiniAction(
                          label: 'استكشاف',
                          icon: Icons.explore_rounded,
                          color: region.$4,
                          onTap: () {
                            AppHelpers.showSnackBar(
                              context,
                              'سيتم لاحقًا ربط ${region.$1} بمحتوى تعليمي محلي',
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class StudentAthkarScreen extends StatefulWidget {
  const StudentAthkarScreen({super.key});

  @override
  State<StudentAthkarScreen> createState() => _StudentAthkarScreenState();
}

class _StudentAthkarScreenState extends State<StudentAthkarScreen> {
  @override
  Widget build(BuildContext context) {
    const athkar = [
      (
        'دعاء طلب العلم',
        'اللهم انفعني بما علمتني وعلمني ما ينفعني وزدني علمًا.',
        'قبل بداية الدراسة أو المذاكرة',
        Icons.lightbulb_rounded
      ),
      (
        'دعاء التيسير',
        'اللهم لا سهل إلا ما جعلته سهلاً وأنت تجعل الحزن إذا شئت سهلاً.',
        'عند صعوبة الفهم أو ضضغط الواجبات',
        Icons.auto_awesome_rounded
      ),
      (
        'ذكر قبل المذاكرة',
        'بسم الله توكلت على الله، ولا حول ولا قوة إلا بالله.',
        'قبل فتح الكتاب أو القارئ',
        Icons.menu_book_rounded
      ),
      (
        'دعاء الحفظ',
        'اللهم استودعتك ما قرأت وما حفظت فردّه إليّ عند حاجتي إليه.',
        'بعد الحفظ وقبل الاختبار',
        Icons.bookmark_rounded
      ),
      (
        'دعاء زيادة العلم',
        'رب زدني علمًا، وافتح لي أبواب فهمك وحكمتك.',
        'عند بداية درس جديد',
        Icons.psychology_rounded
      ),
      (
        'ذكر الطمأنينة',
        'حسبي الله لا إله إلا هو عليه توكلت وهو رب العرش العظيم.',
        'عند التوتر أو القلق الدراسي',
        Icons.self_improvement_rounded
      ),
      (
        'دعاء الفهم',
        'اللهم افتح عليّ فتوح العارفين، ووفقني لفهم النافع من العلم.',
        'قبل حل الأسئلة أو الاختبارات',
        Icons.task_alt_rounded
      ),
      (
        'ذكر التوكل',
        'توكلت على الله، واستعنت بالله، ولا حول ولا قوة إلا بالله.',
        'قبل الدخول لاختبار أو مهمة مهمة',
        Icons.shield_moon_rounded
      ),
      (
        'دعاء البركة في الوقت',
        'اللهم بارك لي في وقتي، وأعني على حسن الاستفادة منه.',
        'عند تنظيم اليوم والخطة الأسبوعية',
        Icons.schedule_rounded
      ),
      (
        'دعاء التوفيق',
        'اللهم وفقني وسددني ويسر لي الخير حيث كان.',
        'قبل المذاكرة والمراجعة',
        Icons.check_circle_rounded
      ),
      (
        'ذكر بعد الإنجاز',
        'الحمد لله الذي بنعمته تتم الصالحات.',
        'بعد إنهاء المذاكرة أو إكمال واجب',
        Icons.celebration_rounded
      ),
      (
        'دعاء الثبات',
        'اللهم ثبت في قلبي العلم النافع، وارزقني حسن التذكر والفهم.',
        'قبل الاختبارات النهائية',
        Icons.auto_fix_high_rounded
      ),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF8F7F2),
      appBar: AppBar(
        title: const Text('أدعية وأذكار الطالب'),
        backgroundColor: const Color(0xFFD6A64F),
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFD6A64F), Color(0xFFE7B766)],
              ),
              borderRadius: BorderRadius.circular(24),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'أذكار الطالب بشكل تفاعلي',
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'اختر الذكر المناسب، انسخه، ثم تنقّل سريعًا بين الأذكار أثناء الدراسة.',
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 13,
                    color: Colors.white,
                    height: 1.6,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          ...athkar.map(
            (zikr) => Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: const Color(0xFFD6A64F).withOpacity(0.22),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          color: const Color(0xFFD6A64F).withOpacity(0.12),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Icon(zikr.$4, color: const Color(0xFFD6A64F)),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              zikr.$1,
                              style: const TextStyle(
                                fontFamily: 'Cairo',
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF8A6413),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              zikr.$3,
                              style: const TextStyle(
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
                  const SizedBox(height: 16),
                  Text(
                    zikr.$2,
                    style: const TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 17,
                      color: AppColors.textPrimary,
                      height: 2,
                    ),
                  ),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      Expanded(
                        child: _InteractiveMiniAction(
                          label: 'نسخ الذكر',
                          icon: Icons.copy_rounded,
                          color: const Color(0xFFD6A64F),
                          onTap: () async {
                            await Clipboard.setData(
                                ClipboardData(text: zikr.$2));
                            if (!context.mounted) return;
                            AppHelpers.showSnackBar(context, 'تم نسخ الذكر');
                          },
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _InteractiveMiniAction(
                          label: 'حفظ للتأمل',
                          icon: Icons.favorite_border_rounded,
                          color: const Color(0xFF8A6413),
                          onTap: () {
                            AppHelpers.showSnackBar(
                              context,
                              'يمكن لاحقًا إضافة قسم أذكار محفوظة',
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InteractiveMiniAction extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _InteractiveMiniAction({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.10),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SimpleStatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _SimpleStatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
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
          Icon(icon, color: color, size: 28),
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

class _ActionTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ActionTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(icon, color: color),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontFamily: 'Cairo',
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(
            fontFamily: 'Cairo',
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
        ),
        trailing: const Icon(
          Icons.arrow_forward_ios_rounded,
          size: 16,
          color: AppColors.textLight,
        ),
        onTap: onTap,
      ),
    );
  }
}

String _formatArabicDate(DateTime date) {
  const months = [
    'يناير',
    'فبراير',
    'مارس',
    'أبريل',
    'مايو',
    'يونيو',
    'يوليو',
    'أغسطس',
    'سبتمبر',
    'أكتوبر',
    'نوفمبر',
    'ديسمبر',
  ];

  const weekdays = [
    'الاثنين',
    'الثلاثاء',
    'الأربعاء',
    'الخميس',
    'الجمعة',
    'السبت',
    'الأحد',
  ];

  return '${weekdays[date.weekday - 1]}، ${date.day} ${months[date.month - 1]} ${date.year}';
}
