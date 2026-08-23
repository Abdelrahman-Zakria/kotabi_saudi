import 'package:equatable/equatable.dart';
import '../../../../domain/entities/educational_node.dart';

abstract class ContentState extends Equatable {
  final bool isFavorite;
  const ContentState({this.isFavorite = false});
  @override
  List<Object?> get props => [isFavorite];

  ContentState copyWith({bool? isFavorite});
}

class ContentInitial extends ContentState {
  const ContentInitial({super.isFavorite});
  @override
  ContentInitial copyWith({bool? isFavorite}) => ContentInitial(isFavorite: isFavorite ?? this.isFavorite);
}

class ContentLoading extends ContentState {
  const ContentLoading({super.isFavorite});
  @override
  ContentLoading copyWith({bool? isFavorite}) => ContentLoading(isFavorite: isFavorite ?? this.isFavorite);
}

class ContentLoaded extends ContentState {
  final List<EducationalNode> items;
  const ContentLoaded(this.items, {super.isFavorite});
  @override
  List<Object?> get props => [items, isFavorite];
  @override
  ContentLoaded copyWith({bool? isFavorite}) => ContentLoaded(items, isFavorite: isFavorite ?? this.isFavorite);
}

class ContentError extends ContentState {
  final String message;
  const ContentError(this.message, {super.isFavorite});
  @override
  List<Object?> get props => [message, isFavorite];
  @override
  ContentError copyWith({bool? isFavorite}) => ContentError(message, isFavorite: isFavorite ?? this.isFavorite);
}
