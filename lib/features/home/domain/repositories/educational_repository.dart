import '../entities/educational_node.dart';

abstract class EducationalRepository {
  Future<List<EducationalNode>> getGrades();
  Future<List<EducationalNode>> getChildren(String parentId);
}
