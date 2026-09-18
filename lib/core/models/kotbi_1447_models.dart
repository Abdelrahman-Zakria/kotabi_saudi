import 'book_model.dart';
import 'grade_model.dart';

class Kotbi1447Catalog {
  final Kotbi1447Section section;
  final List<Kotbi1447Grade> grades;

  const Kotbi1447Catalog({
    required this.section,
    required this.grades,
  });

  factory Kotbi1447Catalog.fromJson(Map<String, dynamic> json) {
    return Kotbi1447Catalog(
      section: Kotbi1447Section.fromJson(
        json['section'] as Map<String, dynamic>? ?? const {},
      ),
      grades: (json['grades'] as List<dynamic>? ?? const [])
          .whereType<Map<String, dynamic>>()
          .map(Kotbi1447Grade.fromJson)
          .toList(),
    );
  }
}

class Kotbi1447Section {
  final String title;
  final String sourceName;
  final String sourceUrl;
  final String description;

  const Kotbi1447Section({
    required this.title,
    required this.sourceName,
    required this.sourceUrl,
    required this.description,
  });

  factory Kotbi1447Section.fromJson(Map<String, dynamic> json) {
    return Kotbi1447Section(
      title: json['title'] as String? ?? 'كتبي 1447',
      sourceName: json['sourceName'] as String? ?? '',
      sourceUrl: json['sourceUrl'] as String? ?? '',
      description: json['description'] as String? ?? '',
    );
  }
}

class Kotbi1447Grade {
  final int id;
  final String gradeId;
  final String name;
  final String slug;
  final String url;
  final String description;
  final String imageUrl;
  final String stage;
  final List<Kotbi1447Term> terms;

  const Kotbi1447Grade({
    required this.id,
    required this.gradeId,
    required this.name,
    required this.slug,
    required this.url,
    required this.description,
    required this.imageUrl,
    required this.stage,
    required this.terms,
  });

  factory Kotbi1447Grade.fromJson(Map<String, dynamic> json) {
    final name = json['name'] as String? ?? '';
    return Kotbi1447Grade(
      id: json['id'] as int? ?? 0,
      gradeId: _gradeIdFromName(name),
      name: name,
      slug: json['slug'] as String? ?? '',
      url: json['url'] as String? ?? '',
      description: json['description'] as String? ?? '',
      imageUrl: json['imageUrl'] as String? ?? '',
      stage: json['stage'] as String? ?? '',
      terms: (json['terms'] as List<dynamic>? ?? const [])
          .whereType<Map<String, dynamic>>()
          .map(Kotbi1447Term.fromJson)
          .toList(),
    );
  }

  GradeModel? get appGrade => GradeModel.getById(gradeId);

  int get resourceCount {
    var count = 0;
    for (final term in terms) {
      for (final subject in term.subjects) {
        count += subject.resources.length;
      }
    }
    return count;
  }

  List<Kotbi1447SubjectGroup> get subjectGroups {
    final groups = <String, Kotbi1447SubjectGroup>{};
    for (final term in terms) {
      for (final subject in term.subjects) {
        final key = subject.key.trim().isEmpty ? subject.name : subject.key;
        final existing = groups[key];
        if (existing == null) {
          groups[key] = Kotbi1447SubjectGroup(
            key: key,
            name: subject.name,
            description: subject.description,
            imageUrl: subject.imageUrl,
            terms: [
              Kotbi1447SubjectTerm(term: term, subject: subject),
            ],
          );
        } else {
          existing.terms
              .add(Kotbi1447SubjectTerm(term: term, subject: subject));
        }
      }
    }

    final result = groups.values.toList()
      ..sort((a, b) => a.name.compareTo(b.name));
    return result;
  }

  static String _gradeIdFromName(String value) {
    final text = _normalize(value);
    if (text.contains('الاول الابتدائي')) return 'grade1';
    if (text.contains('الثاني الابتدائي')) return 'grade2';
    if (text.contains('الثالث الابتدائي')) return 'grade3';
    if (text.contains('الرابع الابتدائي')) return 'grade4';
    if (text.contains('الخامس الابتدائي')) return 'grade5';
    if (text.contains('السادس الابتدائي')) return 'grade6';
    if (text.contains('الاول المتوسط')) return 'grade7';
    if (text.contains('الثاني المتوسط')) return 'grade8';
    if (text.contains('الثالث المتوسط')) return 'grade9';
    if (text.contains('الاول الثانوي')) return 'grade10';
    if (text.contains('الثاني الثانوي')) return 'grade11';
    if (text.contains('الثالث الثانوي')) return 'grade12';
    return '';
  }
}

class Kotbi1447Term {
  final int id;
  final String name;
  final String slug;
  final String url;
  final String description;
  final String imageUrl;
  final List<Kotbi1447Subject> subjects;

  const Kotbi1447Term({
    required this.id,
    required this.name,
    required this.slug,
    required this.url,
    required this.description,
    required this.imageUrl,
    required this.subjects,
  });

  factory Kotbi1447Term.fromJson(Map<String, dynamic> json) {
    return Kotbi1447Term(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? '',
      slug: json['slug'] as String? ?? '',
      url: json['url'] as String? ?? '',
      description: json['description'] as String? ?? '',
      imageUrl: json['imageUrl'] as String? ?? '',
      subjects: (json['subjects'] as List<dynamic>? ?? const [])
          .whereType<Map<String, dynamic>>()
          .map(Kotbi1447Subject.fromJson)
          .toList(),
    );
  }
}

class Kotbi1447Subject {
  final int id;
  final String name;
  final String slug;
  final String url;
  final String description;
  final String imageUrl;
  final String key;
  final int resourceCount;
  final List<Kotbi1447Resource> resources;

  const Kotbi1447Subject({
    required this.id,
    required this.name,
    required this.slug,
    required this.url,
    required this.description,
    required this.imageUrl,
    required this.key,
    required this.resourceCount,
    required this.resources,
  });

  factory Kotbi1447Subject.fromJson(Map<String, dynamic> json) {
    return Kotbi1447Subject(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? '',
      slug: json['slug'] as String? ?? '',
      url: json['url'] as String? ?? '',
      description: json['description'] as String? ?? '',
      imageUrl: json['imageUrl'] as String? ?? '',
      key: json['key'] as String? ?? '',
      resourceCount: json['resourceCount'] as int? ?? 0,
      resources: (json['resources'] as List<dynamic>? ?? const [])
          .whereType<Map<String, dynamic>>()
          .map(Kotbi1447Resource.fromJson)
          .toList(),
    );
  }
}

class Kotbi1447Resource {
  final String id;
  final String title;
  final String shortTitle;
  final String slug;
  final String type;
  final String sourcePageUrl;
  final String imageUrl;
  final String description;
  final DateTime? publishedAt;
  final DateTime? updatedAt;
  final String pdfUrl;
  final String internalReaderUrl;

  const Kotbi1447Resource({
    required this.id,
    required this.title,
    required this.shortTitle,
    required this.slug,
    required this.type,
    required this.sourcePageUrl,
    required this.imageUrl,
    required this.description,
    required this.publishedAt,
    required this.updatedAt,
    required this.pdfUrl,
    required this.internalReaderUrl,
  });

  factory Kotbi1447Resource.fromJson(Map<String, dynamic> json) {
    final reader = json['reader'] as Map<String, dynamic>? ?? const {};
    return Kotbi1447Resource(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      shortTitle: json['shortTitle'] as String? ?? '',
      slug: json['slug'] as String? ?? '',
      type: json['type'] as String? ?? '',
      sourcePageUrl: json['sourcePageUrl'] as String? ?? '',
      imageUrl: json['imageUrl'] as String? ?? '',
      description: json['description'] as String? ?? '',
      publishedAt: DateTime.tryParse(json['publishedAt'] as String? ?? ''),
      updatedAt: DateTime.tryParse(json['updatedAt'] as String? ?? ''),
      pdfUrl: reader['pdfUrl'] as String? ?? '',
      internalReaderUrl: reader['internalReaderUrl'] as String? ?? '',
    );
  }

  BookModel toBookModel({
    required Kotbi1447Grade grade,
    required Kotbi1447Term term,
    required Kotbi1447Subject subject,
  }) {
    return BookModel(
      id: 'kotbi1447_${grade.slug}_${term.slug}_${subject.slug}_$id',
      title: title,
      subject: subject.key.trim().isEmpty ? subject.name : subject.key,
      grade: grade.gradeId,
      stage: grade.stage,
      semester: term.name,
      pdfUrl: pdfUrl,
      pageUrl: sourcePageUrl,
      contentType: _contentType(type),
      thumbnailUrl: imageUrl,
    );
  }

  static String _contentType(String value) {
    final normalized = _normalize(value);
    if (normalized.contains('كتاب')) return 'book';
    if (normalized.contains('حل')) return 'solution';
    if (normalized.contains('اختبار')) return 'exam';
    if (normalized.contains('ورق')) return 'worksheet';
    if (normalized.contains('ملخص')) return 'summary';
    return value.trim().isEmpty ? 'content' : value;
  }
}

class Kotbi1447SubjectGroup {
  final String key;
  final String name;
  final String description;
  final String imageUrl;
  final List<Kotbi1447SubjectTerm> terms;

  const Kotbi1447SubjectGroup({
    required this.key,
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.terms,
  });

  int get resourceCount {
    var count = 0;
    for (final item in terms) {
      count += item.subject.resources.length;
    }
    return count;
  }
}

class Kotbi1447SubjectTerm {
  final Kotbi1447Term term;
  final Kotbi1447Subject subject;

  const Kotbi1447SubjectTerm({
    required this.term,
    required this.subject,
  });
}

String _normalize(String text) {
  return text
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim()
      .toLowerCase()
      .replaceAll('أ', 'ا')
      .replaceAll('إ', 'ا')
      .replaceAll('آ', 'ا')
      .replaceAll('ى', 'ي')
      .replaceAll('ة', 'ه');
}
