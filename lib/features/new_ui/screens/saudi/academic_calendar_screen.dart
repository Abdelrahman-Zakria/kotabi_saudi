import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:kotabi_saudi/core/new_ui/app_colors.dart';

class AcademicCalendarScreen extends StatefulWidget {
  const AcademicCalendarScreen({super.key});

  @override
  State<AcademicCalendarScreen> createState() => _AcademicCalendarScreenState();
}

class _AcademicCalendarScreenState extends State<AcademicCalendarScreen> {
  static const _sourceUrl =
      'https://www.moe.gov.sa/ar/mediacenter/MOEnews/Pages/news1-22062024.aspx';

  final List<_CalendarMonth> _months = const [
    _CalendarMonth(
      title: 'أغسطس 2024',
      month: 8,
      year: 2024,
      headline: 'بداية الفصل الأول',
      events: [
        _CalendarEvent(
          day: 18,
          title: 'بداية الفصل الدراسي الأول',
          subtitle: 'انطلاقة العام الدراسي',
          color: Color(0xFF0E8A4B),
        ),
      ],
    ),
    _CalendarMonth(
      title: 'نوفمبر 2024',
      month: 11,
      year: 2024,
      headline: 'بداية الفصل الثاني',
      events: [
        _CalendarEvent(
          day: 17,
          title: 'بداية الفصل الدراسي الثاني',
          subtitle: 'عودة الدراسة للفصل الثاني',
          color: Color(0xFF15803D),
        ),
      ],
    ),
    _CalendarMonth(
      title: 'مارس 2025',
      month: 3,
      year: 2025,
      headline: 'بداية الفصل الثالث',
      events: [
        _CalendarEvent(
          day: 2,
          title: 'بداية الفصل الدراسي الثالث',
          subtitle: 'بداية آخر فصول العام',
          color: Color(0xFFD97706),
        ),
      ],
    ),
    _CalendarMonth(
      title: 'يونيو 2025',
      month: 6,
      year: 2025,
      headline: 'نهاية العام الدراسي',
      events: [
        _CalendarEvent(
          day: 26,
          title: 'نهاية العام الدراسي',
          subtitle: 'آخر يوم دراسي معتمد',
          color: Color(0xFFE11D48),
        ),
      ],
    ),
  ];

  int _selectedMonthIndex = 0;

  @override
  Widget build(BuildContext context) {
    final month = _months[_selectedMonthIndex];
    final days = _buildMonthDays(month.year, month.month);

    return Scaffold(
      backgroundColor: const Color(0xFFF6F8F2),
      appBar: AppBar(
        title: const Text('التقويم الدراسي السعودي'),
        backgroundColor: const Color(0xFF006C35),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  Color(0xFF006C35),
                  Color(0xFF0E8A4B),
                  Color(0xFFD6A64F)
                ],
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
              ),
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF006C35).withOpacity(0.2),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.14),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: const Text(
                    'تقويم رسمي معتمد',
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'العام الدراسي 1446-1447 هـ',
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'اختر الشهر لعرض الحدث الدراسي المميز داخل تقويم بتصميم سعودي واضح وسريع.',
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 13,
                    color: Colors.white.withOpacity(0.92),
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 14),
                TextButton.icon(
                  onPressed: _openSource,
                  icon: const Icon(Icons.open_in_new_rounded,
                      color: Colors.white),
                  label: const Text(
                    'المصدر الرسمي',
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          SizedBox(
            height: 44,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _months.length,
              reverse: true,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final item = _months[index];
                final isSelected = index == _selectedMonthIndex;
                return ChoiceChip(
                  selected: isSelected,
                  label: Text(
                    item.title,
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontWeight: FontWeight.w700,
                      color: isSelected ? Colors.white : AppColors.textPrimary,
                    ),
                  ),
                  selectedColor: const Color(0xFF006C35),
                  backgroundColor: Colors.white,
                  side: BorderSide(
                    color:
                        isSelected ? const Color(0xFF006C35) : AppColors.border,
                  ),
                  onSelected: (_) =>
                      setState(() => _selectedMonthIndex = index),
                );
              },
            ),
          ),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(26),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
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
                    const Icon(
                      Icons.calendar_month_rounded,
                      color: Color(0xFF006C35),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        month.title,
                        style: const TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  month.headline,
                  style: const TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 18),
                const Row(
                  children: [
                    _WeekdayLabel('أحد'),
                    _WeekdayLabel('اثن'),
                    _WeekdayLabel('ثلا'),
                    _WeekdayLabel('أرب'),
                    _WeekdayLabel('خمي'),
                    _WeekdayLabel('جمع'),
                    _WeekdayLabel('سبت'),
                  ],
                ),
                const SizedBox(height: 10),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: days.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 7,
                    mainAxisSpacing: 8,
                    crossAxisSpacing: 8,
                    childAspectRatio: 0.92,
                  ),
                  itemBuilder: (context, index) {
                    final day = days[index];
                    if (day == null) return const SizedBox();
                    final event = month.eventForDay(day);
                    return Container(
                      decoration: BoxDecoration(
                        color: event?.color.withOpacity(0.1) ??
                            const Color(0xFFF6F7F4),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: event?.color.withOpacity(0.35) ??
                              Colors.transparent,
                          width: 1.4,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '$day',
                            style: TextStyle(
                              fontFamily: 'Cairo',
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              color: event?.color ?? AppColors.textPrimary,
                            ),
                          ),
                          if (event != null) ...[
                            const SizedBox(height: 4),
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: event.color,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ],
                        ],
                      ),
                    );
                  },
                ),
                const SizedBox(height: 18),
                ...month.events.map(
                  (event) => Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: event.color.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 14,
                          height: 14,
                          decoration: BoxDecoration(
                            color: event.color,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                event.title,
                                style: TextStyle(
                                  fontFamily: 'Cairo',
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800,
                                  color: event.color,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${event.subtitle} • ${event.day}/${month.month}/${month.year}',
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
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<int?> _buildMonthDays(int year, int month) {
    final firstDay = DateTime(year, month, 1);
    final lastDay = DateTime(year, month + 1, 0);
    final leadingEmpty = firstDay.weekday % 7;
    final totalCells = leadingEmpty + lastDay.day;
    final trailing = (7 - (totalCells % 7)) % 7;

    return [
      ...List<int?>.filled(leadingEmpty, null),
      ...List<int?>.generate(lastDay.day, (index) => index + 1),
      ...List<int?>.filled(trailing, null),
    ];
  }

  Future<void> _openSource() async {
    await launchUrl(
      Uri.parse(_sourceUrl),
      mode: LaunchMode.externalApplication,
    );
  }
}

class _WeekdayLabel extends StatelessWidget {
  final String text;

  const _WeekdayLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Center(
        child: Text(
          text,
          style: const TextStyle(
            fontFamily: 'Cairo',
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}

class _CalendarMonth {
  final String title;
  final int month;
  final int year;
  final String headline;
  final List<_CalendarEvent> events;

  const _CalendarMonth({
    required this.title,
    required this.month,
    required this.year,
    required this.headline,
    required this.events,
  });

  _CalendarEvent? eventForDay(int day) {
    for (final event in events) {
      if (event.day == day) return event;
    }
    return null;
  }
}

class _CalendarEvent {
  final int day;
  final String title;
  final String subtitle;
  final Color color;

  const _CalendarEvent({
    required this.day,
    required this.title,
    required this.subtitle,
    required this.color,
  });
}
