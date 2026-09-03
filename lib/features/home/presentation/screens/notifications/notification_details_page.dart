import 'package:flutter/material.dart';
import 'package:intl/intl.dart' as intl;
import 'package:kotabi_saudi/core/theme/app_theme.dart';
import 'package:kotabi_saudi/core/services/ad_service.dart';
import 'package:kotabi_saudi/main.dart';

class NotificationDetailsPage extends StatefulWidget {
  final Map<String, dynamic> notification;

  const NotificationDetailsPage({super.key, required this.notification});

  @override
  State<NotificationDetailsPage> createState() => _NotificationDetailsPageState();
}

class _NotificationDetailsPageState extends State<NotificationDetailsPage> {
  @override
  void initState() {
    super.initState();
    // Show App Open Ad when entering details page
    if (sl.isRegistered<AdService>()) {
      sl<AdService>().showAppOpenAdIfAvailable();
    }
  }

  @override
  Widget build(BuildContext context) {
    final date = DateTime.parse(widget.notification['timestamp']);
    final formattedDate = intl.DateFormat('yyyy/MM/dd - hh:mm a').format(date);

    return Scaffold(
      appBar: AppBar(
        title: const Text("تفاصيل الإشعار"),
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.notifications_active, color: AppTheme.primaryColor),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            widget.notification['title'] ?? '',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.primaryColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 30),
                    Text(
                      widget.notification['body'] ?? '',
                      style: const TextStyle(
                        fontSize: 16,
                        height: 1.6,
                        color: AppTheme.textColor,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        formattedDate,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppTheme.subTextColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
