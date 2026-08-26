import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:kotabi_saudi/features/home/domain/entities/educational_node.dart';
import '../screens/pdf_viewer/pdf_viewer_page.dart';

class ResourceChips extends StatelessWidget {
  final List<Resource> resources;

  const ResourceChips({super.key, required this.resources});

  @override
  Widget build(BuildContext context) {
    if (resources.isEmpty) return const SizedBox();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Wrap(
        spacing: 10,
        runSpacing: 10,
        children: resources.map((res) => _buildChip(context, res)).toList(),
      ),
    );
  }

  Widget _buildChip(BuildContext context, Resource res) {
    IconData icon;
    String label;
    Color color;

    final bool isPdf = res.type == 'pdf' || res.type == 'pdf_viewer' || res.type == 'pdf_direct';

    if (res.type == 'external_link') {
      icon = Icons.open_in_new;
      label = res.url.contains('ien.edu.sa') ? 'بوابة عين' : 
              res.url.contains('madrasati.sa') ? 'منصة مدرستي' : 'رابط خارجي';
      color = Colors.teal;
    } else if (isPdf) {
      icon = Icons.picture_as_pdf;
      label = 'عرض PDF';
      color = Colors.red.shade700;
    } else if (res.type == 'youtube') {
      icon = Icons.play_circle_fill;
      label = 'فيديو';
      color = Colors.red;
    } else {
      icon = Icons.link;
      label = 'مصدر';
      color = Colors.blueGrey;
    }

    return ActionChip(
      avatar: Icon(icon, size: 18, color: Colors.white),
      label: Text(label, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
      backgroundColor: color,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      onPressed: () {
        if (isPdf) {
          _openPdf(context, res.url, label);
        } else {
          _launchURL(context, res.url);
        }
      },
    );
  }

  void _openPdf(BuildContext context, String url, String title) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PdfViewerPage(
          url: url,
          title: title,
        ),
      ),
    );
  }

  Future<void> _launchURL(BuildContext context, String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تعذر فتح الرابط')));
      }
    }
  }
}
