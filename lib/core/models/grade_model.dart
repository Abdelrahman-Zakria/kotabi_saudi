import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

enum EducationalStage {
  primary,
  middle,
  high,
}

class GradeModel {
  final String id;
  final String name;
  final String displayName;
  final EducationalStage stage;
  final String stageDisplayName;
  final int gradeNumber;
  final Color color;
  final String? wajibiPath;

  const GradeModel({
    required this.id,
    required this.name,
    required this.displayName,
    required this.stage,
    required this.stageDisplayName,
    required this.gradeNumber,
    required this.color,
    this.wajibiPath,
  });

  static const List<GradeModel> allGrades = [
    // Primary Stage
    GradeModel(
      id: 'grade1',
      name: 'grade1',
      displayName: 'الصف الأول الابتدائي',
      stage: EducationalStage.primary,
      stageDisplayName: 'المرحلة الابتدائية',
      gradeNumber: 1,
      color: AppColors.primarySchoolColor,
      wajibiPath: '/primary/1',
    ),
    GradeModel(
      id: 'grade2',
      name: 'grade2',
      displayName: 'الصف الثاني الابتدائي',
      stage: EducationalStage.primary,
      stageDisplayName: 'المرحلة الابتدائية',
      gradeNumber: 2,
      color: AppColors.primarySchoolColor,
      wajibiPath: '/primary/2',
    ),
    GradeModel(
      id: 'grade3',
      name: 'grade3',
      displayName: 'الصف الثالث الابتدائي',
      stage: EducationalStage.primary,
      stageDisplayName: 'المرحلة الابتدائية',
      gradeNumber: 3,
      color: AppColors.primarySchoolColor,
      wajibiPath: '/primary/3',
    ),
    GradeModel(
      id: 'grade4',
      name: 'grade4',
      displayName: 'الصف الرابع الابتدائي',
      stage: EducationalStage.primary,
      stageDisplayName: 'المرحلة الابتدائية',
      gradeNumber: 4,
      color: AppColors.primarySchoolColor,
      wajibiPath: '/primary/4',
    ),
    GradeModel(
      id: 'grade5',
      name: 'grade5',
      displayName: 'الصف الخامس الابتدائي',
      stage: EducationalStage.primary,
      stageDisplayName: 'المرحلة الابتدائية',
      gradeNumber: 5,
      color: AppColors.primarySchoolColor,
      wajibiPath: '/primary/5',
    ),
    GradeModel(
      id: 'grade6',
      name: 'grade6',
      displayName: 'الصف السادس الابتدائي',
      stage: EducationalStage.primary,
      stageDisplayName: 'المرحلة الابتدائية',
      gradeNumber: 6,
      color: AppColors.primarySchoolColor,
      wajibiPath: '/primary/6',
    ),

    // Middle Stage
    GradeModel(
      id: 'grade7',
      name: 'grade7',
      displayName: 'الصف الأول المتوسط',
      stage: EducationalStage.middle,
      stageDisplayName: 'المرحلة المتوسطة',
      gradeNumber: 7,
      color: AppColors.middleSchoolColor,
      wajibiPath: '/middle/1',
    ),
    GradeModel(
      id: 'grade8',
      name: 'grade8',
      displayName: 'الصف الثاني المتوسط',
      stage: EducationalStage.middle,
      stageDisplayName: 'المرحلة المتوسطة',
      gradeNumber: 8,
      color: AppColors.middleSchoolColor,
      wajibiPath: '/middle/2',
    ),
    GradeModel(
      id: 'grade9',
      name: 'grade9',
      displayName: 'الصف الثالث المتوسط',
      stage: EducationalStage.middle,
      stageDisplayName: 'المرحلة المتوسطة',
      gradeNumber: 9,
      color: AppColors.middleSchoolColor,
      wajibiPath: '/middle/3',
    ),

    // High Stage
    GradeModel(
      id: 'grade10',
      name: 'grade10',
      displayName: 'الصف الأول الثانوي',
      stage: EducationalStage.high,
      stageDisplayName: 'المرحلة الثانوية',
      gradeNumber: 10,
      color: AppColors.highSchoolColor,
      wajibiPath: '/high/1',
    ),
    GradeModel(
      id: 'grade11',
      name: 'grade11',
      displayName: 'الصف الثاني الثانوي',
      stage: EducationalStage.high,
      stageDisplayName: 'المرحلة الثانوية',
      gradeNumber: 11,
      color: AppColors.highSchoolColor,
      wajibiPath: '/high/2',
    ),
    GradeModel(
      id: 'grade12',
      name: 'grade12',
      displayName: 'الصف الثالث الثانوي',
      stage: EducationalStage.high,
      stageDisplayName: 'المرحلة الثانوية',
      gradeNumber: 12,
      color: AppColors.highSchoolColor,
      wajibiPath: '/high/3',
    ),
  ];

  static List<GradeModel> getByStage(EducationalStage stage) {
    return allGrades.where((g) => g.stage == stage).toList();
  }

  static GradeModel? getById(String id) {
    try {
      return allGrades.firstWhere((g) => g.id == id);
    } catch (e) {
      return null;
    }
  }
}

class StageModel {
  final EducationalStage stage;
  final String displayName;
  final String description;
  final Color color;
  final IconData icon;
  final List<GradeModel> grades;

  const StageModel({
    required this.stage,
    required this.displayName,
    required this.description,
    required this.color,
    required this.icon,
    required this.grades,
  });

  static List<StageModel> get allStages => [
        StageModel(
          stage: EducationalStage.primary,
          displayName: 'المرحلة الابتدائية',
          description: 'الصفوف من الأول حتى السادس',
          color: AppColors.primarySchoolColor,
          icon: Icons.school_rounded,
          grades: GradeModel.getByStage(EducationalStage.primary),
        ),
        StageModel(
          stage: EducationalStage.middle,
          displayName: 'المرحلة المتوسطة',
          description: 'الصفوف السابع والثامن والتاسع',
          color: AppColors.middleSchoolColor,
          icon: Icons.menu_book_rounded,
          grades: GradeModel.getByStage(EducationalStage.middle),
        ),
        StageModel(
          stage: EducationalStage.high,
          displayName: 'المرحلة الثانوية',
          description: 'الصفوف العاشر والحادي عشر والثاني عشر',
          color: AppColors.highSchoolColor,
          icon: Icons.auto_stories_rounded,
          grades: GradeModel.getByStage(EducationalStage.high),
        ),
      ];
}
