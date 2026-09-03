import 'package:flutter/material.dart';
import 'package:kotabi_saudi/main.dart';
import 'package:kotabi_saudi/core/theme/app_theme.dart';
import 'package:kotabi_saudi/core/services/local_storage_service.dart';
import 'package:kotabi_saudi/features/home/presentation/screens/notifications/notification_details_page.dart';
import 'package:intl/intl.dart' as intl;

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> with WidgetsBindingObserver {
  final storage = sl<LocalStorageService>();
  List<Map<String, dynamic>> _history = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadHistory();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _loadHistory();
    }
  }

  void _loadHistory() {
    setState(() {
      _history = storage.getNotificationsHistory();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("الإشعارات"),
        actions: [
          if (_history.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep_rounded),
              onPressed: _confirmDeleteAll,
              tooltip: "مسح الكل",
            ),
        ],
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: _history.isEmpty
            ? _buildEmptyState()
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _history.length,
                itemBuilder: (context, index) => _buildNotificationCard(_history[index]),
              ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.notifications_off_outlined, size: 80, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            "لا توجد إشعارات حالياً",
            style: TextStyle(color: AppTheme.subTextColor, fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationCard(Map<String, dynamic> item) {
    final date = DateTime.parse(item['timestamp']);
    final timeAgo = _formatTimestamp(date);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: const CircleAvatar(
          backgroundColor: AppTheme.primaryColor,
          child: Icon(Icons.notifications, color: Colors.white, size: 20),
        ),
        title: Text(
          item['title'] ?? '',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              item['body'] ?? '',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 13),
            ),
            const SizedBox(height: 4),
            Text(
              timeAgo,
              style: const TextStyle(fontSize: 11, color: AppTheme.subTextColor),
            ),
          ],
        ),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => NotificationDetailsPage(notification: item),
          ),
        ),
      ),
    );
  }

  String _formatTimestamp(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inMinutes < 60) return "منذ ${diff.inMinutes} دقيقة";
    if (diff.inHours < 24) return "منذ ${diff.inHours} ساعة";
    return intl.DateFormat('yyyy/MM/dd').format(date);
  }

  void _confirmDeleteAll() {
    showDialog(
      context: context,
      builder: (context) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          title: const Text("مسح جميع الإشعارات"),
          content: const Text("هل أنت متأكد من رغبتك في مسح كافة سجل الإشعارات؟"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("إلغاء"),
            ),
            TextButton(
              onPressed: () async {
                await storage.clearNotificationsHistory();
                _loadHistory();
                if (context.mounted) Navigator.pop(context);
              },
              child: const Text("مسح الكل", style: TextStyle(color: Colors.red)),
            ),
          ],
        ),
      ),
    );
  }
}
