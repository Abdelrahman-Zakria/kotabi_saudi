import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'home_state.dart';
import '../../../../domain/repositories/educational_repository.dart';
import 'package:share_plus/share_plus.dart';

class HomeCubit extends Cubit<HomeState> {
  final EducationalRepository repository;

  HomeCubit(this.repository) : super(HomeInitial());

  void loadGrades({String filter = 'الكل'}) async {
    emit(HomeLoading());
    try {
      final allGrades = await repository.getGrades();
      if (filter == 'الكل') {
        emit(HomeLoaded(allGrades, filter));
      } else if (filter == 'الابتدائية') {
        emit(HomeLoaded(allGrades.where((g) => g.title.contains('الابتدائي')).toList(), filter));
      } else if (filter == 'المتوسط') {
        emit(HomeLoaded(allGrades.where((g) => g.title.contains('المتوسط')).toList(), filter));
      } else if (filter == 'الثانوية') {
        emit(HomeLoaded(allGrades.where((g) => g.title.contains('الثانوي')).toList(), filter));
      }
    } catch (e) {
      emit(HomeError(e.toString()));
    }
  }

  void shareApp() {
    final String link = Platform.isIOS
        ? 'https://apps.apple.com/app/%D9%83%D8%AA%D8%A8%D9%8A-%D8%A7%D9%84%D8%B3%D8%B9%D9%88%D8%AF%D9%8A%D8%A9/id6804324680'
        : 'https://play.google.com/store/apps/details?id=com.mo.azkaryapppasi';
        
    SharePlus.instance.share(
      ShareParams(
        text: 'حمل تطبيق كتبي التعليمي الآن واستمتع بكافة المناهج الدراسية مجاناً!\n$link',
      ),
    );
  }
}
