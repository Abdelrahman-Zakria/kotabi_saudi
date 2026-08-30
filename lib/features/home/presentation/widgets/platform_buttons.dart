import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:kotabi_saudi/features/home/domain/entities/educational_node.dart';
import 'package:kotabi_saudi/core/theme/app_theme.dart';

class PlatformButtons extends StatelessWidget {
  final List<Resource> resources;

  const PlatformButtons({super.key, required this.resources});

  @override
  Widget build(BuildContext context) {
    // Group links to ensure we know which is which
    final einRes = resources.firstWhere((r) => r.url.contains('ien.edu.sa'), orElse: () => Resource(type: '', url: '', label: ''));
    final madrasatiRes = resources.firstWhere((r) => r.url.contains('madrasati.sa'), orElse: () => Resource(type: '', url: '', label: ''));

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        children: [
          if (einRes.url.isNotEmpty)
            _buildLargeButton(
              context,
              label: 'تصفح عبر بوابة عين التعليمية',
              url: einRes.url,
              color: const Color(0xFF00A19D), // Ein Green/Teal
              icon: Icons.menu_book_rounded,
            ),
          if (einRes.url.isNotEmpty && madrasatiRes.url.isNotEmpty)
            const SizedBox(height: 12),
          if (madrasatiRes.url.isNotEmpty)
            _buildLargeButton(
              context,
              label: 'مشاهدة الكتاب في منصة مدرستي',
              url: madrasatiRes.url,
              color: const Color(0xFF1B4E5E), // Madrasati Dark Blue
              icon: Icons.computer_rounded,
            ),
        ],
      ),
    );
  }

  Widget _buildLargeButton(BuildContext context, {
    required String label,
    required String url,
    required Color color,
    required IconData icon,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 58,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          padding: const EdgeInsets.symmetric(horizontal: 16),
        ),
        onPressed: () => _launchURL(context, url),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 24),
            const SizedBox(width: 12),
            Text(
              label,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                fontFamily: 'Tajawal',
              ),
            ),
            const Spacer(),
            const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.white70),
          ],
        ),
      ),
    );
  }

  Future<void> _launchURL(BuildContext context, String url) async {
    final Uri uri = Uri.parse(url);
    try {
      if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تعذر فتح المنصة')));
        }
      }
    } catch (e) {
       if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('خطأ: $e')));
       }
    }
  }
}
