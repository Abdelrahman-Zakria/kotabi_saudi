import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/educational_node.dart';
import '../../domain/repositories/educational_repository.dart';

class EducationalRepositoryImpl implements EducationalRepository {
  final FirebaseFirestore firestore;

  EducationalRepositoryImpl(this.firestore);

  @override
  Future<List<EducationalNode>> getGrades() async {
    final snapshot = await firestore
        .collection('nodes')
        .where('kind', isEqualTo: '1')
        .get();
    
    var nodes = snapshot.docs
        .map((doc) => EducationalNode.fromMap(doc.id, doc.data()))
        .toList();

    // Filter to only include nodes that look like school levels
    nodes = nodes.where((n) => 
      n.title.contains("الابتدائي") || 
      n.title.contains("المتوسط") || 
      n.title.contains("الثانوي")
    ).toList();

    // Deduplicate by title to handle the scraper finding the same grade via different paths
    final seen = <String>{};
    nodes = nodes.where((n) => seen.add(n.title)).toList();

    nodes.sort((a, b) => _getSortWeight(a.title).compareTo(_getSortWeight(b.title)));
    
    return nodes;
  }

  @override
  Future<List<EducationalNode>> getChildren(String parentId) async {
    final snapshot = await firestore
        .collection('nodes')
        .where('parentId', isEqualTo: parentId)
        .get();
        
    return snapshot.docs
        .map((doc) => EducationalNode.fromMap(doc.id, doc.data()))
        .toList();
  }

  int _getSortWeight(String title) {
    if (title.contains("الاول الابتدائي")) return 1;
    if (title.contains("الثاني الابتدائي")) return 2;
    if (title.contains("الثالث الابتدائي")) return 3;
    if (title.contains("الرابع الابتدائي")) return 4;
    if (title.contains("الخامس الابتدائي")) return 5;
    if (title.contains("السادس الابتدائي")) return 6;
    if (title.contains("الاول المتوسط")) return 7;
    if (title.contains("الثاني المتوسط")) return 8;
    if (title.contains("الثالث المتوسط")) return 9;
    if (title.contains("الاول الثانوي")) return 10;
    if (title.contains("الثاني الثانوي")) return 11;
    if (title.contains("الثالث الثانوي")) return 12;
    return 99;
  }
}
