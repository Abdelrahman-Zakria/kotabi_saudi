class ExplanationChapter {
  final String title;
  final List<String> youtubeLinks;

  const ExplanationChapter({
    required this.title,
    required this.youtubeLinks,
  });

  factory ExplanationChapter.fromJson(Map<String, dynamic> json) {
    return ExplanationChapter(
      title: (json['title'] ?? json['chapter_name'] ?? '').toString(),
      youtubeLinks: (json['youtube_links'] as List<dynamic>? ?? const [])
          .map((e) => e.toString())
          .where((e) => e.trim().isNotEmpty)
          .toList(),
    );
  }
}

class ExplanationSubject {
  final String name;
  final List<ExplanationChapter> chapters;

  const ExplanationSubject({
    required this.name,
    required this.chapters,
  });

  factory ExplanationSubject.fromJson(Map<String, dynamic> json) {
    return ExplanationSubject(
      name: (json['subject_name'] ?? '').toString(),
      chapters: (json['chapters'] as List<dynamic>? ?? const [])
          .map((e) => ExplanationChapter.fromJson(e as Map<String, dynamic>))
          .where((c) => c.title.trim().isNotEmpty && c.youtubeLinks.isNotEmpty)
          .toList(),
    );
  }
}

class ExplanationGrade {
  final String name;
  final List<ExplanationSubject> subjects;

  const ExplanationGrade({
    required this.name,
    required this.subjects,
  });

  factory ExplanationGrade.fromJson(Map<String, dynamic> json) {
    return ExplanationGrade(
      name: (json['grade_name'] ?? '').toString(),
      subjects: (json['subjects'] as List<dynamic>? ?? const [])
          .map((e) => ExplanationSubject.fromJson(e as Map<String, dynamic>))
          .where((s) => s.name.trim().isNotEmpty && s.chapters.isNotEmpty)
          .toList(),
    );
  }
}

class ExplanationSemester {
  final String name;
  final List<ExplanationGrade> grades;

  const ExplanationSemester({
    required this.name,
    required this.grades,
  });

  factory ExplanationSemester.fromJson(Map<String, dynamic> json) {
    return ExplanationSemester(
      name: (json['semester_name'] ?? '').toString(),
      grades: (json['grades'] as List<dynamic>? ?? const [])
          .map((e) => ExplanationGrade.fromJson(e as Map<String, dynamic>))
          .where((g) => g.name.trim().isNotEmpty && g.subjects.isNotEmpty)
          .toList(),
    );
  }
}
