import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:kotabi_saudi/core/theme/app_theme.dart';
import 'package:kotabi_saudi/features/home/domain/entities/educational_node.dart';
import 'package:kotabi_saudi/core/services/local_storage_service.dart';
import 'package:kotabi_saudi/main.dart';

class TahderiSubjectCard extends StatelessWidget {
  final EducationalNode node;

  const TahderiSubjectCard({super.key, required this.node});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 20),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.school, color: AppTheme.primaryColor),
                const SizedBox(width: 10),
                Text(
                  node.title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryColor,
                  ),
                ),
              ],
            ),
            const Divider(height: 25),
            ...node.resources.map((res) => _buildResourceRow(context, res)),
          ],
        ),
      ),
    );
  }

  Widget _buildResourceRow(BuildContext context, Resource res) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              res.label,
              style: const TextStyle(fontSize: 14, color: AppTheme.textColor),
            ),
          ),
          ElevatedButton.icon(
            onPressed: () => _handleDownload(context, res),
            icon: const Icon(Icons.download, size: 18),
            label: const Text("تحميل"),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF26C6DA),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
        ],
      ),
    );
  }

  void _handleDownload(BuildContext context, Resource res) async {
    final storage = sl<LocalStorageService>();
    // Add to library for 'Downloads' tab visibility
    await storage.addToLibrary(node);
    
    final uri = Uri.parse(res.url);
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Directionality(
                textDirection: TextDirection.rtl,
                child: Text("تمت الإضافة إلى التنزيلات وفتح الرابط"),
              ),
            ),
          );
        }
      } else {
        throw 'Could not launch $uri';
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Directionality(
              textDirection: TextDirection.rtl,
              child: Text("تعذر فتح الرابط"),
            ),
          ),
        );
      }
    }
  }
}
