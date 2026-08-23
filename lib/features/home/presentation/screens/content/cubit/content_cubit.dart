import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kotabi_saudi/features/home/domain/entities/educational_node.dart';
import 'package:kotabi_saudi/features/home/domain/repositories/educational_repository.dart';
import 'package:kotabi_saudi/core/services/local_storage_service.dart';
import 'content_state.dart';

class ContentCubit extends Cubit<ContentState> {
  final EducationalRepository repository;
  final LocalStorageService storage;

  ContentCubit({required this.repository, required this.storage}) : super(const ContentInitial());

  void loadItems(String parentId, String? currentUrl) async {
    emit(ContentLoading(isFavorite: currentUrl != null ? storage.isFavorite(currentUrl) : false));
    try {
      final items = await repository.getChildren(parentId);
      emit(ContentLoaded(items, isFavorite: currentUrl != null ? storage.isFavorite(currentUrl) : false));
    } catch (e) {
      emit(ContentError(e.toString()));
    }
  }

  void toggleFavorite(EducationalNode node) async {
    await storage.toggleFavorite(node);
    emit(state.copyWith(isFavorite: storage.isFavorite(node.url)));
  }

  void addToLibrary(EducationalNode node) async {
    await storage.addToLibrary(node);
  }
}
