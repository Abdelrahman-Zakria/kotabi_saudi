import 'package:flutter/material.dart';
import 'package:kotabi_saudi/main.dart';
import 'package:kotabi_saudi/features/home/domain/entities/educational_node.dart';
import 'package:kotabi_saudi/features/tahderi/domain/repositories/tahderi_repository.dart';
import 'package:kotabi_saudi/features/tahderi/presentation/widgets/tahderi_subject_card.dart';

class TahderiPage extends StatefulWidget {
  final String? parentId;
  final String? title;

  const TahderiPage({super.key, this.parentId, this.title});

  @override
  State<TahderiPage> createState() => _TahderiPageState();
}

class _TahderiPageState extends State<TahderiPage> {
  final repository = sl<TahderiRepository>();
  List<EducationalNode> _items = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  Future<void> _loadItems() async {
    setState(() => _isLoading = true);
    try {
      final String? targetId = widget.parentId ?? 'root';
      final items = await repository.getChildren(targetId);
      
      // LOGIC FIX:
      // If this list contains a "Term" node (الفصل الدراسي), it means we are at the Grade level.
      // At the Grade level, we MUST HIDE the individual Subject Cards and ONLY show the Term folder.
      bool hasTerm = items.any((n) => n.title.contains('الفصل الدراسي'));
      
      setState(() {
        if (hasTerm) {
          // Filter to only show navigation folders (exclude leaf subjects)
          _items = items.where((n) => n.title.contains('الفصل الدراسي')).toList();
        } else {
          _items = items;
        }
      });
    } catch (e) {
      debugPrint("Tahderi Load Error: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title ?? "تحضيري"),
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _items.isEmpty
                ? const Center(child: Text("لا توجد بيانات حالياً"))
                : _buildList(),
      ),
    );
  }

  Widget _buildList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _items.length,
      itemBuilder: (context, index) {
        final item = _items[index];
        
        // Render as Card UI only if it actually has resources (Leaf Node)
        if (item.resources.isNotEmpty) {
          return TahderiSubjectCard(node: item);
        }

        // Standard navigation UI for intermediate folders
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            title: Text(
              item.title, 
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)
            ),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => TahderiPage(
                    parentId: item.id,
                    title: item.title,
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
