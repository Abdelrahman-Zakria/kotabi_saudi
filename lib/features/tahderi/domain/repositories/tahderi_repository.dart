import 'package:kotabi_saudi/features/home/domain/entities/educational_node.dart';

abstract class TahderiRepository {
  Future<List<EducationalNode>> getChildren(String? parentId);
}
