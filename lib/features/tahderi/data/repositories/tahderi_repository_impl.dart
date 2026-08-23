import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kotabi_saudi/features/home/domain/entities/educational_node.dart';
import 'package:kotabi_saudi/features/tahderi/domain/repositories/tahderi_repository.dart';

class TahderiRepositoryImpl implements TahderiRepository {
  final FirebaseFirestore firestore;

  TahderiRepositoryImpl(this.firestore);

  @override
  Future<List<EducationalNode>> getChildren(String? parentId) async {
    // In our scrape, the root nodes have parentId = null
    final query = firestore.collection('tahderi_nodes');
    
    final snapshot = await query
        .where('parentId', isEqualTo: parentId)
        .get();
        
    final nodes = snapshot.docs
        .map((doc) => EducationalNode.fromMap(doc.id, doc.data()))
        .toList();

    // Sort stages/grades/terms logically
    nodes.sort((a, b) => _getSortWeight(a.title).compareTo(_getSortWeight(b.title)));
    
    return nodes;
  }

  int _getSortWeight(String title) {
    if (title.contains("الابتدائية")) return 1;
    if (title.contains("المتوسطة")) return 2;
    if (title.contains("الثانوية")) return 3;
    if (title.contains("الأول")) return 1;
    if (title.contains("الثاني")) return 2;
    if (title.contains("الثالث")) return 3;
    if (title.contains("الرابع")) return 4;
    if (title.contains("الخامس")) return 5;
    if (title.contains("السادس")) return 6;
    return 99;
  }
}
