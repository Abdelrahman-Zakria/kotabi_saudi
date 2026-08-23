import 'package:equatable/equatable.dart';
import '../../../../domain/entities/educational_node.dart';

abstract class HomeState extends Equatable {
  const HomeState();
  @override
  List<Object?> get props => [];
}

class HomeInitial extends HomeState {}
class HomeLoading extends HomeState {}
class HomeLoaded extends HomeState {
  final List<EducationalNode> grades;
  final String activeFilter;
  const HomeLoaded(this.grades, this.activeFilter);
  @override
  List<Object?> get props => [grades, activeFilter];
}
class HomeError extends HomeState {
  final String message;
  const HomeError(this.message);
  @override
  List<Object?> get props => [message];
}
