import 'package:flutter/material.dart';

import 'package:kotabi_saudi/core/new_ui/app_colors.dart';

class WeightedScoreScreen extends StatefulWidget {
  const WeightedScoreScreen({super.key});

  @override
  State<WeightedScoreScreen> createState() => _WeightedScoreScreenState();
}

class _WeightedScoreScreenState extends State<WeightedScoreScreen> {
  final TextEditingController _schoolController =
      TextEditingController(text: '95');
  final TextEditingController _quduratController =
      TextEditingController(text: '85');
  final TextEditingController _tahsiliController =
      TextEditingController(text: '80');

  double _schoolWeight = 30;
  double _quduratWeight = 30;
  double _tahsiliWeight = 40;

  @override
  void dispose() {
    _schoolController.dispose();
    _quduratController.dispose();
    _tahsiliController.dispose();
    super.dispose();
  }

  double get _weightedScore {
    final school = _parse(_schoolController.text);
    final qudurat = _parse(_quduratController.text);
    final tahsili = _parse(_tahsiliController.text);

    return (school * (_schoolWeight / 100)) +
        (qudurat * (_quduratWeight / 100)) +
        (tahsili * (_tahsiliWeight / 100));
  }

  @override
  Widget build(BuildContext context) {
    final weightedScore = _weightedScore;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F2),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 250,
            pinned: true,
            backgroundColor: const Color(0xFF006C35),
            foregroundColor: Colors.white,
            flexibleSpace: FlexibleSpaceBar(
              title: const Text(
                'حاسبة النسبة الموزونة',
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color(0xFF006C35),
                      Color(0xFF0F8E4C),
                      Color(0xFFD6A64F)
                    ],
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                  ),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      top: 40,
                      right: -30,
                      child: Container(
                        width: 140,
                        height: 140,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.08),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 15,
                      left: -20,
                      child: Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.08),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                    SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.14),
                                borderRadius: BorderRadius.circular(30),
                              ),
                              child: const Text(
                                'خاصة بالجامعات السعودية',
                                style: TextStyle(
                                  fontFamily: 'Cairo',
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            const Spacer(),
                            const Text(
                              'احسب فرصتك بشكل سريع وواضح',
                              style: TextStyle(
                                fontFamily: 'Cairo',
                                fontSize: 25,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                                height: 1.3,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'النسبة الموزونة تختلف حسب الجامعة والتخصص، لذلك أضفت لك قوالب سريعة مع إمكانية تعديل الأوزان يدويًا.',
                              style: TextStyle(
                                fontFamily: 'Cairo',
                                fontSize: 13,
                                color: Colors.white.withOpacity(0.94),
                                height: 1.5,
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
          SliverPadding(
            padding: const EdgeInsets.all(18),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _ResultHeroCard(score: weightedScore),
                const SizedBox(height: 18),
                const _SectionHeader(
                  title: 'قوالب سريعة',
                  subtitle: 'اختر قالبًا شائعًا ثم عدّل عليه إذا احتجت',
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    _PresetChip(
                      label: '30 / 30 / 40',
                      onTap: () => _applyPreset(30, 30, 40),
                    ),
                    _PresetChip(
                      label: '50 / 50 / 0',
                      onTap: () => _applyPreset(50, 50, 0),
                    ),
                    _PresetChip(
                      label: '50 / 0 / 50',
                      onTap: () => _applyPreset(50, 0, 50),
                    ),
                    _PresetChip(
                      label: '40 / 30 / 30',
                      onTap: () => _applyPreset(40, 30, 30),
                    ),
                  ],
                ),
                const SizedBox(height: 22),
                const _SectionHeader(
                  title: 'درجاتك',
                  subtitle:
                      'أدخل النسب الحالية كما ظهرت لك في الشهادات والاختبارات',
                ),
                const SizedBox(height: 12),
                _ScoreInputCard(
                  title: 'نسبة الثانوية',
                  hint: 'من 100',
                  controller: _schoolController,
                  color: const Color(0xFF15803D),
                  onChanged: (_) => setState(() {}),
                ),
                _ScoreInputCard(
                  title: 'درجة القدرات',
                  hint: 'من 100',
                  controller: _quduratController,
                  color: const Color(0xFF7C3AED),
                  onChanged: (_) => setState(() {}),
                ),
                _ScoreInputCard(
                  title: 'درجة التحصيلي',
                  hint: 'من 100',
                  controller: _tahsiliController,
                  color: const Color(0xFFD97706),
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: 22),
                const _SectionHeader(
                  title: 'الأوزان',
                  subtitle: 'عدّل النسب حسب الجهة التي تتقدم لها',
                ),
                const SizedBox(height: 12),
                _WeightSliderCard(
                  label: 'الثانوية',
                  color: const Color(0xFF15803D),
                  value: _schoolWeight,
                  onChanged: (value) => setState(() => _schoolWeight = value),
                ),
                _WeightSliderCard(
                  label: 'القدرات',
                  color: const Color(0xFF7C3AED),
                  value: _quduratWeight,
                  onChanged: (value) => setState(() => _quduratWeight = value),
                ),
                _WeightSliderCard(
                  label: 'التحصيلي',
                  color: const Color(0xFFD97706),
                  value: _tahsiliWeight,
                  onChanged: (value) => setState(() => _tahsiliWeight = value),
                ),
                const SizedBox(height: 14),
                _WeightSummaryCard(
                  total: _schoolWeight + _quduratWeight + _tahsiliWeight,
                ),
                const SizedBox(height: 22),
                const _SectionHeader(
                  title: 'ملاحظات مهمة',
                  subtitle: 'حتى تستخدم الحاسبة بالشكل الصحيح داخل السعودية',
                ),
                const SizedBox(height: 12),
                const _NoteBullet(
                  text:
                      'بعض الجامعات السعودية تعتمد النسبة الموزونة، وبعضها يعتمد النسبة المركبة أو شروطًا إضافية.',
                ),
                const _NoteBullet(
                  text:
                      'يمكنك استخدام القوالب السريعة كبداية، ثم تعديل الأوزان حسب الجهة أو التخصص المطلوب.',
                ),
                const _NoteBullet(
                  text:
                      'إذا كان مجموع الأوزان لا يساوي 100% فستظهر النتيجة الحسابية كما هي، لذلك يُفضّل ضبطها على 100%.',
                ),
                const SizedBox(height: 90),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  void _applyPreset(double school, double qudurat, double tahsili) {
    setState(() {
      _schoolWeight = school;
      _quduratWeight = qudurat;
      _tahsiliWeight = tahsili;
    });
  }

  double _parse(String input) {
    final value = double.tryParse(input.replaceAll(',', '.')) ?? 0;
    return value.clamp(0, 100);
  }
}

class GraduateSpotlightScreen extends StatelessWidget {
  const GraduateSpotlightScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F7F2),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 250,
            pinned: true,
            backgroundColor: const Color(0xFF111827),
            foregroundColor: Colors.white,
            flexibleSpace: FlexibleSpaceBar(
              title: const Text(
                'ضوء الخريج',
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color(0xFF111827),
                      Color(0xFF1F2937),
                      Color(0xFFD6A64F)
                    ],
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                  ),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      top: 35,
                      left: -15,
                      child: Container(
                        width: 110,
                        height: 110,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.06),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 20,
                      right: -10,
                      child: Container(
                        width: 150,
                        height: 150,
                        decoration: BoxDecoration(
                          color: const Color(0xFFD6A64F).withOpacity(0.18),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                    SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(24, 30, 24, 24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(30),
                              ),
                              child: const Text(
                                'محتوى سعودي غني للخريج',
                                style: TextStyle(
                                  fontFamily: 'Cairo',
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            const Spacer(),
                            const Text(
                              'من التخرج إلى الجامعة أو المسار المهني',
                              style: TextStyle(
                                fontFamily: 'Cairo',
                                fontSize: 25,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                                height: 1.3,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'شاشة مركزة للطالب السعودي بعد التخرج: قرارات، اختبارات، مهارات، وثائق، وخطوات عملية للمستقبل.',
                              style: TextStyle(
                                fontFamily: 'Cairo',
                                fontSize: 13,
                                color: Colors.white.withOpacity(0.92),
                                height: 1.5,
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
          SliverPadding(
            padding: const EdgeInsets.all(18),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                const _SectionHeader(
                  title: 'خارطة الطريق',
                  subtitle: 'أهم المسارات التي يفكر بها الخريج في السعودية',
                ),
                const SizedBox(height: 12),
                const _SpotlightTimelineCard(),
                const SizedBox(height: 22),
                const _SectionHeader(
                  title: 'محطات مهمة',
                  subtitle:
                      'محاور أساسية للانتقال من المدرسة إلى المرحلة التالية',
                ),
                const SizedBox(height: 12),
                const _GraduateGrid(),
                const SizedBox(height: 22),
                const _SectionHeader(
                  title: 'المحتوى السعودي للخريج',
                  subtitle: 'مواضيع تفصيلية غنية ومفيدة بعد التخرج',
                ),
                const SizedBox(height: 12),
                const _ContentArticleCard(
                  title: 'القدرات والتحصيلي بعد التخرج',
                  body:
                      'للطالب السعودي، تحسين درجة القدرات أو التحصيلي قد يغيّر فرصة القبول بشكل كبير. من المهم مراجعة خطة المحاولات، المواعيد، والتركيز على نقاط الضعف لا مجرد كثرة المصادر.',
                  accent: Color(0xFF006C35),
                  icon: Icons.analytics_rounded,
                ),
                const _ContentArticleCard(
                  title: 'القبول الجامعي والتخصصات',
                  body:
                      'ابدأ بتحديد التخصص الذي يناسبك من حيث الرغبة، ثم راجع متطلبات القبول، النسبة الموزونة أو المركبة، المدينة، والفرص المستقبلية للتخصص داخل السوق السعودي.',
                  accent: Color(0xFF4F46E5),
                  icon: Icons.account_balance_rounded,
                ),
                const _ContentArticleCard(
                  title: 'المسار المهني والوظائف',
                  body:
                      'ليس كل خريج يجب أن يسلك الطريق نفسه. بعض الطلاب يناسبهم المسار الجامعي، وبعضهم ينجح أكثر في التدريب التقني أو المهارات المهنية أو العمل المبكر مع التعلم المستمر.',
                  accent: Color(0xFFD97706),
                  icon: Icons.work_rounded,
                ),
                const _ContentArticleCard(
                  title: 'بناء الملف الشخصي للخريج',
                  body:
                      'من الآن جهّز بريدًا احترافيًا، سيرة ذاتية مختصرة، ملف إنجاز، وشهاداتك الأساسية. هذه التفاصيل الصغيرة تصنع فرقًا كبيرًا في التسجيل أو التقديم أو الفرص المبكرة.',
                  accent: Color(0xFF15803D),
                  icon: Icons.badge_rounded,
                ),
                const SizedBox(height: 22),
                const _SectionHeader(
                  title: 'قائمة الخريج الذهبية',
                  subtitle: 'أشياء يُفضّل تجهيزها بعد التخرج مباشرة',
                ),
                const SizedBox(height: 12),
                const _ChecklistCard(),
                const SizedBox(height: 90),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

class _ResultHeroCard extends StatelessWidget {
  final double score;

  const _ResultHeroCard({required this.score});

  @override
  Widget build(BuildContext context) {
    final progress = (score / 100).clamp(0.0, 1.0);
    final scoreColor = score >= 85
        ? const Color(0xFF15803D)
        : score >= 70
            ? const Color(0xFFD97706)
            : const Color(0xFFE11D48);

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 170,
                height: 170,
                child: CircularProgressIndicator(
                  value: progress,
                  strokeWidth: 14,
                  backgroundColor: scoreColor.withOpacity(0.12),
                  valueColor: AlwaysStoppedAnimation<Color>(scoreColor),
                ),
              ),
              Column(
                children: [
                  Text(
                    score.toStringAsFixed(2),
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 34,
                      fontWeight: FontWeight.w800,
                      color: scoreColor,
                    ),
                  ),
                  const Text(
                    'النسبة الموزونة',
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 18),
          Text(
            score >= 85
                ? 'نتيجة قوية جدًا'
                : score >= 70
                    ? 'نتيجة جيدة وتحتاج تحسينًا بسيطًا'
                    : 'يمكن رفعها بتحسين القدرات أو التحصيلي',
            style: const TextStyle(
              fontFamily: 'Cairo',
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _PresetChip extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _PresetChip({
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFF006C35).withOpacity(0.12)),
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontFamily: 'Cairo',
            fontWeight: FontWeight.w700,
            color: Color(0xFF006C35),
          ),
        ),
      ),
    );
  }
}

class _ScoreInputCard extends StatelessWidget {
  final String title;
  final String hint;
  final TextEditingController controller;
  final Color color;
  final ValueChanged<String> onChanged;

  const _ScoreInputCard({
    required this.title,
    required this.hint,
    required this.controller,
    required this.color,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(Icons.edit_note_rounded, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontFamily: 'Cairo',
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  hint,
                  style: const TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            width: 90,
            child: TextField(
              controller: controller,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: color,
              ),
              decoration: InputDecoration(
                isDense: true,
                filled: true,
                fillColor: color.withOpacity(0.06),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }
}

class _WeightSliderCard extends StatelessWidget {
  final String label;
  final Color color;
  final double value;
  final ValueChanged<double> onChanged;

  const _WeightSliderCard({
    required this.label,
    required this.color,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
              const Spacer(),
              Text(
                '${value.toStringAsFixed(0)}%',
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: color,
                ),
              ),
            ],
          ),
          Slider(
            value: value,
            min: 0,
            max: 100,
            activeColor: color,
            inactiveColor: color.withOpacity(0.15),
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}

class _WeightSummaryCard extends StatelessWidget {
  final double total;

  const _WeightSummaryCard({required this.total});

  @override
  Widget build(BuildContext context) {
    final isBalanced = total.round() == 100;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isBalanced ? const Color(0xFFECFDF5) : const Color(0xFFFFFBEB),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isBalanced ? const Color(0xFF34D399) : const Color(0xFFFBBF24),
        ),
      ),
      child: Row(
        children: [
          Icon(
            isBalanced
                ? Icons.check_circle_rounded
                : Icons.warning_amber_rounded,
            color:
                isBalanced ? const Color(0xFF059669) : const Color(0xFFD97706),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              isBalanced
                  ? 'مجموع الأوزان 100% وهذا هو الوضع الأنسب للحساب.'
                  : 'مجموع الأوزان الحالي ${total.toStringAsFixed(0)}%، والأفضل ضبطه على 100%.',
              style: const TextStyle(
                fontFamily: 'Cairo',
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontFamily: 'Cairo',
            fontSize: 19,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: const TextStyle(
            fontFamily: 'Cairo',
            fontSize: 13,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

class _NoteBullet extends StatelessWidget {
  final String text;

  const _NoteBullet({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 6),
            width: 10,
            height: 10,
            decoration: const BoxDecoration(
              color: Color(0xFF006C35),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontFamily: 'Cairo',
                fontSize: 13,
                color: AppColors.textPrimary,
                height: 1.6,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SpotlightTimelineCard extends StatelessWidget {
  const _SpotlightTimelineCard();

  @override
  Widget build(BuildContext context) {
    const steps = [
      (
        '1',
        'راجع نتيجتك الحالية',
        'احسب الموزونة وحدد واقعك الحقيقي قبل أي قرار.'
      ),
      ('2', 'حدد المسار الأنسب', 'جامعة، تدريب تقني، ابتعاث، أو مسار مهني.'),
      (
        '3',
        'ارفع الجاهزية',
        'حسن القدرات أو التحصيلي وابدأ تجهيز الملف الشخصي.'
      ),
      ('4', 'تابع الفرص', 'راقب مواعيد التسجيل والقبول والمفاضلات والتقديم.'),
    ];

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(26),
      ),
      child: Column(
        children: steps
            .map(
              (step) => Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: Row(
                  children: [
                    Container(
                      width: 34,
                      height: 34,
                      decoration: const BoxDecoration(
                        color: Color(0xFFD6A64F),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          step.$1,
                          style: const TextStyle(
                            fontFamily: 'Cairo',
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            step.$2,
                            style: const TextStyle(
                              fontFamily: 'Cairo',
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            step.$3,
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
            )
            .toList(),
      ),
    );
  }
}

class _GraduateGrid extends StatelessWidget {
  const _GraduateGrid();

  @override
  Widget build(BuildContext context) {
    const cards = [
      ('الجامعات السعودية', Icons.account_balance_rounded, Color(0xFF006C35)),
      ('التدريب التقني', Icons.engineering_rounded, Color(0xFF15803D)),
      ('القدرات والتحصيلي', Icons.bar_chart_rounded, Color(0xFF4F46E5)),
      ('السيرة الذاتية', Icons.description_rounded, Color(0xFFD97706)),
      ('المهارات الرقمية', Icons.computer_rounded, Color(0xFF111827)),
      (
        'فرص التطوع والإنجاز',
        Icons.volunteer_activism_rounded,
        Color(0xFFE11D48)
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: cards.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.02,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemBuilder: (context, index) {
        final card = cards[index];
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: card.$3.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(card.$2, color: card.$3),
              ),
              const Spacer(),
              Text(
                card.$1,
                style: const TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ContentArticleCard extends StatelessWidget {
  final String title;
  final String body;
  final Color accent;
  final IconData icon;

  const _ContentArticleCard({
    required this.title,
    required this.body,
    required this.accent,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: accent.withOpacity(0.12)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: accent.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: accent),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: accent,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  body,
                  style: const TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 13,
                    color: AppColors.textPrimary,
                    height: 1.7,
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

class _ChecklistCard extends StatelessWidget {
  const _ChecklistCard();

  @override
  Widget build(BuildContext context) {
    const items = [
      'نسخة رقمية من الشهادة والسجل',
      'بريد إلكتروني احترافي',
      'سيرة ذاتية مختصرة',
      'حساب منظم للوثائق والمواعيد',
      'خطة شهرية لرفع الدرجات أو المهارات',
      'قائمة بالجامعات أو البرامج المستهدفة',
    ];

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: items
            .map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    const Icon(
                      Icons.check_circle_rounded,
                      color: Color(0xFF15803D),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        item,
                        style: const TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 13,
                          color: AppColors.textPrimary,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}
