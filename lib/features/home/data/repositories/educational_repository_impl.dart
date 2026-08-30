import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/educational_node.dart';
import '../../domain/repositories/educational_repository.dart';

class EducationalRepositoryImpl implements EducationalRepository {
  final FirebaseFirestore firestore;

  EducationalRepositoryImpl(this.firestore);

  @override
  Future<List<EducationalNode>> getGrades() async {
    // Exact IDs for the 12 main grades to ensure they always load
    final gradeIds = [
      '2c320eee84b1f8f59cc515fa51a9d9ce', // s1
      'c63cc3c4bc33e35b85613f1f2eb3d562', // s2
      '9651505f1b57ed01c33eb6eafaa5b99b', // tnaf3
      'cccea53d3a73dd23a5f1732282e8e9ca', // s4
      '0d6843edfb9dc0e21618840d87d8e52d', // s5
      'c4049fdb4696c4e7839260b1b2de0c24', // s6
      'f6f2cbbaa3ddfc0287830dfec6c6f804', // m1
      '95671efdb0eb2723aa1e754a5ad7a0f9', // m2
      '4f4183677e0fb0d83d7c6cac416b9ebe', // m3
      '2f37138dbaa3c1b7426b5c859af01ba0', // t1
      '180099da8ee785bba755692fdf2d1269', // t2
      '9e7ead7f654c61852b2597f46c3cf214'  // t3
    ];

    final snapshot = await firestore
        .collection('full_nodes')
        .where(FieldPath.documentId, whereIn: gradeIds)
        .get();
    
    var nodes = snapshot.docs
        .map((doc) => EducationalNode.fromMap(doc.id, doc.data()))
        .toList();

    // Deduplicate by title just in case
    final seen = <String>{};
    nodes = nodes.where((n) => seen.add(n.title)).toList();

    nodes.sort((a, b) => _getSortWeight(a.title).compareTo(_getSortWeight(b.title)));
    
    return nodes;
  }

  @override
  Future<List<EducationalNode>> getChildren(String parentId) async {
    final snapshot = await firestore
        .collection('full_nodes')
        .where('parentId', isEqualTo: parentId)
        .get();
        
    var nodes = snapshot.docs
        .map((doc) => EducationalNode.fromMap(doc.id, doc.data()))
        .toList();

    // Deduplicate by title (sometimes the crawler finds same thing via different URLs)
    final seen = <String>{};
    nodes = nodes.where((n) => seen.add(n.title)).toList();

    // Logical Sort
    nodes.sort((a, b) => _getSortWeight(a.title).compareTo(_getSortWeight(b.title)));
    
    return nodes;
  }

  int _getSortWeight(String title) {
    // 1. Semesters (Hard priority for 1st Semester)
    if (title.contains("الفصل الدراسي الاول") || title.contains("الفصل الاول")) return -100;
    if (title.contains("الفصل الدراسي الثاني") || title.contains("الفصل الثاني")) return -90;
    if (title.contains("الفصل الدراسي الثالث") || title.contains("الفصل الثالث")) return -80;

    // 2. Main Grades (For Home Page)
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

    // 3. Document types
    if (title.contains("كتاب")) return 20;
    if (title.contains("حل") || title.contains("الحل")) return 21;
    if (title.contains("اختبار")) return 22;
    if (title.contains("توزيع")) return 23;
    if (title.contains("ملخص")) return 24;

    return 999;
  }
}
