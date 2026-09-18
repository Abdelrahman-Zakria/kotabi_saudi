import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import 'package:kotabi_saudi/core/new_ui/app_colors.dart';
import 'package:kotabi_saudi/core/models/grade_model.dart';
import 'package:kotabi_saudi/features/new_ui/widgets/grade_badge.dart';

/// Three-step interactive introduction shown once on first launch.
/// Each step asks the student to try the feature it describes instead of
/// only reading about it.
class OnboardingScreen extends StatefulWidget {
  final VoidCallback onFinished;

  const OnboardingScreen({super.key, required this.onFinished});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  static const int _stepCount = 3;

  final PageController _pageController = PageController();
  int _currentStep = 0;

  // Step 1 — the stage the student picks.
  EducationalStage? _selectedStage;

  // Step 2 — the mock reader the student drags.
  double _readerPage = 12;
  bool _isBookmarked = false;

  // Step 3 — the tools the student switches on.
  final Set<String> _pickedTools = <String>{};

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _goToNextStep() {
    if (_currentStep >= _stepCount - 1) {
      widget.onFinished();
      return;
    }
    _pageController.nextPage(
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLastStep = _currentStep == _stepCount - 1;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                child: TextButton(
                  onPressed: widget.onFinished,
                  child: const Text(
                    'تخطي',
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (index) => setState(() => _currentStep = index),
                children: [
                  _buildLibraryStep(),
                  _buildReaderStep(),
                  _buildToolsStep(),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
              child: Column(
                children: [
                  SmoothPageIndicator(
                    controller: _pageController,
                    count: _stepCount,
                    textDirection: TextDirection.rtl,
                    effect: const ExpandingDotsEffect(
                      dotHeight: 8,
                      dotWidth: 8,
                      expansionFactor: 3.5,
                      spacing: 6,
                      dotColor: AppColors.primaryVeryLight,
                      activeDotColor: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 18),
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      onPressed: _goToNextStep,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                      child: Text(
                        isLastStep ? 'ابدأ الآن' : 'التالي',
                        style: const TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
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

  // ---------------------------------------------------------------- step 1

  Widget _buildLibraryStep() {
    final stage = _selectedStage;
    final grades = stage == null
        ? const <GradeModel>[]
        : GradeModel.getByStage(stage).take(4).toList();

    return _StepScaffold(
      icon: Icons.auto_stories_rounded,
      color: AppColors.primary,
      title: 'مكتبة كاملة بين يديك',
      subtitle:
          'الكتب المدرسية، الحلول، نماذج الاختبارات والشروحات لكل الصفوف.\nجرّب الآن: اختر مرحلتك الدراسية.',
      child: Column(
        children: [
          Row(
            children: [
              for (final item in StageModel.allStages) ...[
                Expanded(
                  child: _ChoiceChipCard(
                    label: item.displayName,
                    icon: item.icon,
                    color: item.color,
                    isSelected: _selectedStage == item.stage,
                    onTap: () => setState(() => _selectedStage = item.stage),
                  ),
                ),
                if (item != StageModel.allStages.last)
                  const SizedBox(width: 10),
              ],
            ],
          ),
          const SizedBox(height: 22),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: stage == null
                ? const _StepHint(
                    key: ValueKey('stage-hint'),
                    text: 'اضغط على إحدى المراحل لترى صفوفها',
                  )
                : Column(
                    key: ValueKey(stage),
                    children: [
                      SizedBox(
                        height: 108,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          itemCount: grades.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(width: 12),
                          itemBuilder: (_, index) {
                            final grade = grades[index];
                            return SizedBox(
                              width: 92,
                              child: Column(
                                children: [
                                  SizedBox(
                                    height: 76,
                                    child: GradeBadge(
                                      gradeNumber: grade.gradeNumber,
                                      gradeId: grade.id,
                                      color: grade.color,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    grade.displayName,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontFamily: 'Cairo',
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 10),
                      const _StepHint(
                        text: 'ممتاز! كل كتب هذه المرحلة جاهزة داخل التطبيق',
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------- step 2

  Widget _buildReaderStep() {
    final page = _readerPage.round();

    return _StepScaffold(
      icon: Icons.menu_book_rounded,
      color: const Color(0xFF2563EB),
      title: 'قارئ ذكي يحفظ تقدّمك',
      subtitle:
          'افتح أي كتاب داخل التطبيق، وأكمل من حيث توقفت في أي وقت.\nجرّب الآن: حرّك الشريط وضع إشارة مرجعية.',
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: AppColors.border),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 16,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2563EB).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        'صفحة $page من 120',
                        style: const TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF2563EB),
                        ),
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () =>
                          setState(() => _isBookmarked = !_isBookmarked),
                      icon: AnimatedScale(
                        scale: _isBookmarked ? 1.15 : 1,
                        duration: const Duration(milliseconds: 220),
                        child: Icon(
                          _isBookmarked
                              ? Icons.bookmark_rounded
                              : Icons.bookmark_border_rounded,
                          color: _isBookmarked
                              ? AppColors.primary
                              : AppColors.textLight,
                          size: 28,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: LinearProgressIndicator(
                    value: _readerPage / 120,
                    minHeight: 10,
                    backgroundColor: AppColors.divider,
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      Color(0xFF2563EB),
                    ),
                  ),
                ),
                Slider(
                  value: _readerPage,
                  min: 1,
                  max: 120,
                  activeColor: const Color(0xFF2563EB),
                  inactiveColor: AppColors.divider,
                  onChanged: (value) => setState(() => _readerPage = value),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _StepHint(
            text: _isBookmarked
                ? 'تم حفظ الإشارة المرجعية عند صفحة $page'
                : 'اسحب الشريط، ثم اضغط رمز الإشارة لحفظ صفحتك',
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------- step 3

  Widget _buildToolsStep() {
    const tools = <_OnboardingTool>[
      _OnboardingTool(
        id: 'weighted',
        label: 'حاسبة الموزونة',
        icon: Icons.calculate_rounded,
      ),
      _OnboardingTool(
        id: 'calendar',
        label: 'التقويم الدراسي',
        icon: Icons.calendar_month_rounded,
      ),
      _OnboardingTool(
        id: 'plan',
        label: 'الخطة الأسبوعية',
        icon: Icons.edit_calendar_rounded,
      ),
      _OnboardingTool(
        id: 'downloads',
        label: 'التحميل للقراءة دون إنترنت',
        icon: Icons.download_done_rounded,
      ),
    ];

    final progress = _pickedTools.length / tools.length;

    return _StepScaffold(
      icon: Icons.auto_awesome_rounded,
      color: AppColors.accent,
      title: 'أدوات تختصر عليك الطريق',
      subtitle:
          'حاسبات، تقويم دراسي، خطة أسبوعية وتحميل يعمل دون إنترنت.\nجرّب الآن: اختر الأدوات التي تهمّك.',
      child: Column(
        children: [
          ...tools.map((tool) {
            final isPicked = _pickedTools.contains(tool.id);
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _ToolRow(
                tool: tool,
                isPicked: isPicked,
                onTap: () => setState(() {
                  if (isPicked) {
                    _pickedTools.remove(tool.id);
                  } else {
                    _pickedTools.add(tool.id);
                  }
                }),
              ),
            );
          }),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 10,
              backgroundColor: AppColors.divider,
              valueColor:
                  const AlwaysStoppedAnimation<Color>(AppColors.accent),
            ),
          ),
          const SizedBox(height: 12),
          _StepHint(
            text: _pickedTools.isEmpty
                ? 'اضغط على أي أداة لتجربتها'
                : 'اخترت ${_pickedTools.length} من ${tools.length} أدوات — وكلها متاحة مجاناً',
          ),
        ],
      ),
    );
  }
}

class _StepScaffold extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final Widget child;

  const _StepScaffold({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 76,
              height: 76,
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Icon(icon, size: 38, color: color),
            ),
          ),
          const SizedBox(height: 18),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: 'Cairo',
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: 'Cairo',
              fontSize: 13,
              height: 1.7,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 24),
          child,
        ],
      ),
    );
  }
}

class _ChoiceChipCard extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  const _ChoiceChipCard({
    required this.label,
    required this.icon,
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 6),
          decoration: BoxDecoration(
            color: isSelected ? color : Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: isSelected ? color : AppColors.border,
              width: 1.4,
            ),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                size: 26,
                color: isSelected ? Colors.white : color,
              ),
              const SizedBox(height: 8),
              Text(
                label,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 11.5,
                  height: 1.3,
                  fontWeight: FontWeight.w800,
                  color: isSelected ? Colors.white : AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OnboardingTool {
  final String id;
  final String label;
  final IconData icon;

  const _OnboardingTool({
    required this.id,
    required this.label,
    required this.icon,
  });
}

class _ToolRow extends StatelessWidget {
  final _OnboardingTool tool;
  final bool isPicked;
  final VoidCallback onTap;

  const _ToolRow({
    required this.tool,
    required this.isPicked,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: isPicked
                ? AppColors.accent.withOpacity(0.1)
                : Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: isPicked ? AppColors.accent : AppColors.border,
              width: 1.4,
            ),
          ),
          child: Row(
            children: [
              Icon(
                tool.icon,
                color: isPicked ? AppColors.accent : AppColors.textLight,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  tool.label,
                  style: const TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              AnimatedScale(
                scale: isPicked ? 1 : 0.8,
                duration: const Duration(milliseconds: 220),
                child: Icon(
                  isPicked
                      ? Icons.check_circle_rounded
                      : Icons.radio_button_unchecked_rounded,
                  color: isPicked ? AppColors.accent : AppColors.border,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StepHint extends StatelessWidget {
  final String text;

  const _StepHint({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: TextAlign.center,
      style: const TextStyle(
        fontFamily: 'Cairo',
        fontSize: 12,
        height: 1.6,
        fontWeight: FontWeight.w600,
        color: AppColors.textSecondary,
      ),
    );
  }
}
