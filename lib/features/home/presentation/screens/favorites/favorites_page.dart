import 'package:flutter/material.dart';
import 'package:kotabi_saudi/main.dart';
import 'package:kotabi_saudi/core/services/local_storage_service.dart';
import '../content/content_page.dart';

class FavoritesPage extends StatefulWidget {
  const FavoritesPage({super.key});

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  final storage = sl<LocalStorageService>();
  List _items = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    setState(() {
      _items = storage.getFavorites();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("المفضلة")),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: _items.isEmpty
            ? const Center(child: Text("لا توجد عناصر في المفضلة"))
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _items.length,
                itemBuilder: (context, index) {
                  final item = _items[index];
                  return Card(
                    child: ListTile(
                      title: Text(item.title),
                      trailing: const Icon(Icons.favorite, color: Colors.red),
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ContentPage(node: item, parentId: item.parentId ?? '', title: item.title))),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
