import 'package:flutter/material.dart';
import 'package:kotabi_saudi/main.dart';
import 'package:intl/intl.dart' as intl;
import 'package:kotabi_saudi/core/theme/app_theme.dart';
import 'package:kotabi_saudi/core/services/local_storage_service.dart';
import 'package:kotabi_saudi/core/services/notification_service.dart';

class TimerPage extends StatefulWidget {
  const TimerPage({super.key});

  @override
  State<TimerPage> createState() => _TimerPageState();
}

class _TimerPageState extends State<TimerPage> {
  final storage = sl<LocalStorageService>();
  List<Map<String, dynamic>> _timers = [];

  @override
  void initState() {
    super.initState();
    _loadTimers();
  }

  void _loadTimers() {
    setState(() {
      _timers = storage.getTimers();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("التذكير"),
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: _timers.isEmpty
            ? _buildEmptyState()
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _timers.length,
                itemBuilder: (context, index) => _buildTimerCard(index),
              ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddTimer(context),
        backgroundColor: AppTheme.primaryColor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.alarm_off_rounded, size: 80, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          const Text("لا توجد تذكيرات حالياً", style: TextStyle(color: AppTheme.subTextColor)),
        ],
      ),
    );
  }

  Widget _buildTimerCard(int index) {
    final timer = _timers[index];
    final int timerId = timer['id'] ?? index;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(timer['title'], style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const Icon(Icons.notifications_active, color: AppTheme.primaryColor),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _buildTag("منبه فعال", Colors.orange),
                const SizedBox(width: 8),
                _buildTag("مذاكرة", AppTheme.primaryColor),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildTimeInfo("من", timer['start']),
                _buildTimeInfo("إلى", timer['end']),
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  onPressed: () async {
                    await sl<NotificationService>().cancelAlarm(timerId);
                    await storage.deleteTimer(index);
                    _loadTimers();
                  },
                )
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTag(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Text(label, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildTimeInfo(String label, String time) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: AppTheme.subTextColor)),
        Text(time, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.primaryColor)),
      ],
    );
  }

  void _showAddTimer(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
      builder: (context) => _AddTimerSheet(onSave: () {
        _loadTimers();
        Navigator.pop(context);
      }),
    );
  }
}

class _AddTimerSheet extends StatefulWidget {
  final VoidCallback onSave;
  const _AddTimerSheet({required this.onSave});

  @override
  State<_AddTimerSheet> createState() => _AddTimerSheetState();
}

class _AddTimerSheetState extends State<_AddTimerSheet> {
  final _titleController = TextEditingController();
  DateTime _date = DateTime.now();
  TimeOfDay _start = TimeOfDay.now();
  TimeOfDay _end = TimeOfDay.fromDateTime(DateTime.now().add(const Duration(hours: 1)));

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, left: 20, right: 20, top: 20),
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Center(child: Text("إضافة تذكير جديد", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold))),
            const SizedBox(height: 20),
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                hintText: "عنوان التذكير (مثال: مراجعة لغتي)",
                prefixIcon: const Icon(Icons.title),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
              ),
            ),
            const SizedBox(height: 20),
            const Text("الموعد", style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            _buildPicker("تاريخ المذاكرة", intl.DateFormat('yyyy-MM-dd').format(_date), Icons.calendar_today, () async {
              final picked = await showDatePicker(context: context, initialDate: _date, firstDate: DateTime.now(), lastDate: DateTime.now().add(const Duration(days: 365)));
              if (picked != null) setState(() => _date = picked);
            }),
            Row(
              children: [
                Expanded(child: _buildPicker("وقت البدء", _start.format(context), Icons.play_circle_outline, () async {
                  final picked = await showTimePicker(context: context, initialTime: _start);
                  if (picked != null) setState(() => _start = picked);
                })),
                const SizedBox(width: 10),
                Expanded(child: _buildPicker("وقت الانتهاء", _end.format(context), Icons.stop_circle_rounded, () async {
                  final picked = await showTimePicker(context: context, initialTime: _end);
                  if (picked != null) setState(() => _end = picked);
                })),
              ],
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                ),
                child: const Text("حفظ التذكير", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildPicker(String label, String value, IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        margin: const EdgeInsets.symmetric(vertical: 5),
        decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(12)),
        child: Row(
          children: [
            Icon(icon, color: AppTheme.primaryColor),
            const SizedBox(width: 10),
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(label, style: const TextStyle(fontSize: 10, color: AppTheme.subTextColor)),
              Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
            ]),
          ],
        ),
      ),
    );
  }

  void _save() async {
    if (_titleController.text.isEmpty) return;
    
    final int timerId = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    
    final timer = {
      'id': timerId,
      'title': _titleController.text,
      'start': _start.format(context),
      'end': _end.format(context),
      'date': intl.DateFormat('yyyy-MM-dd').format(_date),
    };

    await sl<LocalStorageService>().saveTimer(timer);

    final startDateTime = DateTime(_date.year, _date.month, _date.day, _start.hour, _start.minute);
    
    if (startDateTime.isAfter(DateTime.now())) {
      await sl<NotificationService>().scheduleSystemAlarm(
        id: timerId,
        title: "بدأ وقت المذاكرة: ${_titleController.text}",
        body: "حان الوقت للبدء في جلستك الدراسية. بالتوفيق!",
        time: startDateTime,
      );
    }

    widget.onSave();
  }
}
