import 'package:flutter/material.dart';
import 'package:kotabi_saudi/main.dart';
import 'package:kotabi_saudi/core/theme/app_theme.dart';
import 'package:kotabi_saudi/core/services/local_storage_service.dart';
import 'package:kotabi_saudi/features/home/presentation/screens/content/content_page.dart';

class LibraryPage extends StatefulWidget {
  const LibraryPage({super.key});

  @override
  State<LibraryPage> createState() => _LibraryPageState();
}

class _LibraryPageState extends State<LibraryPage> {
  final storage = sl<LocalStorageService>();
  List _items = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    setState(() {
      _items = storage.getLibrary();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("التنزيلات")),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: _items.isEmpty
            ? const Center(child: Text("لا توجد ملفات محملة"))
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _items.length,
                itemBuilder: (context, index) {
                  final item = _items[index];
                  return Card(
                    child: ListTile(
                      title: Text(item.title),
                      trailing: const Icon(Icons.download_done_rounded, color: AppTheme.primaryColor),
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ContentPage(node: item, parentId: item.parentId ?? '', title: item.title))),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
