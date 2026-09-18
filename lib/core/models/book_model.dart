import 'dart:convert';

class BookModel {
  final String id;
  final String title;
  final String subject;
  final String grade;
  final String stage;
  final String semester;
  final String pdfUrl;
  final String? pageUrl;
  final String contentType;
  final String? thumbnailUrl;
  final String? thumbnailAsset;
  final int? pageCount;
  final String? fileSize;
  bool isFavorite;

  BookModel({
    required this.id,
    required this.title,
    required this.subject,
    required this.grade,
    required this.stage,
    required this.semester,
    required this.pdfUrl,
    this.pageUrl,
    this.contentType = 'book',
    this.thumbnailUrl,
    this.thumbnailAsset,
    this.pageCount,
    this.fileSize,
    this.isFavorite = false,
  });

  factory BookModel.fromJson(Map<String, dynamic> json) {
    return BookModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      subject: json['subject'] ?? '',
      grade: json['grade'] ?? '',
      stage: json['stage'] ?? '',
      semester: json['semester'] ?? '',
      pdfUrl: json['pdf_url'] ?? '',
      pageUrl: json['page_url'],
      contentType: json['content_type'] ?? 'book',
      thumbnailUrl: json['thumbnail_url'],
      thumbnailAsset: json['thumbnail_asset'],
      pageCount: json['page_count'],
      fileSize: json['file_size'],
      isFavorite: json['is_favorite'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'subject': subject,
      'grade': grade,
      'stage': stage,
      'semester': semester,
      'pdf_url': pdfUrl,
      'page_url': pageUrl,
      'content_type': contentType,
      'thumbnail_url': thumbnailUrl,
      'thumbnail_asset': thumbnailAsset,
      'page_count': pageCount,
      'file_size': fileSize,
      'is_favorite': isFavorite,
    };
  }

  String toJsonString() => jsonEncode(toJson());

  factory BookModel.fromJsonString(String jsonString) {
    return BookModel.fromJson(jsonDecode(jsonString));
  }

  BookModel copyWith({
    String? id,
    String? title,
    String? subject,
    String? grade,
    String? stage,
    String? semester,
    String? pdfUrl,
    String? pageUrl,
    String? contentType,
    String? thumbnailUrl,
    String? thumbnailAsset,
    int? pageCount,
    String? fileSize,
    bool? isFavorite,
  }) {
    return BookModel(
      id: id ?? this.id,
      title: title ?? this.title,
      subject: subject ?? this.subject,
      grade: grade ?? this.grade,
      stage: stage ?? this.stage,
      semester: semester ?? this.semester,
      pdfUrl: pdfUrl ?? this.pdfUrl,
      pageUrl: pageUrl ?? this.pageUrl,
      contentType: contentType ?? this.contentType,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      thumbnailAsset: thumbnailAsset ?? this.thumbnailAsset,
      pageCount: pageCount ?? this.pageCount,
      fileSize: fileSize ?? this.fileSize,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BookModel && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'BookModel(id: $id, title: $title, subject: $subject)';
}
