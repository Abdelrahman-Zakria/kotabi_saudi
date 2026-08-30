import 'package:equatable/equatable.dart';

class Resource extends Equatable {
  final String type;
  final String url;
  final String label;

  const Resource({required this.type, required this.url, required this.label});

  @override
  List<Object?> get props => [type, url, label];

  factory Resource.fromMap(Map<String, dynamic> map) {
    return Resource(
      type: map['type'] ?? '',
      url: map['url'] ?? '',
      label: map['label'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'type': type,
      'url': url,
      'label': label,
    };
  }
}

class Breadcrumb extends Equatable {
  final String title;
  final String url;

  const Breadcrumb({required this.title, required this.url});

  @override
  List<Object?> get props => [title, url];

  factory Breadcrumb.fromMap(Map<String, dynamic> map) {
    return Breadcrumb(
      title: map['title'] ?? '',
      url: map['url'] ?? '',
    );
  }
}

class EducationalNode extends Equatable {
  final String id;
  final String? parentId;
  final String title;
  final String url;
  final String kind;
  final List<Resource> resources;
  final String description;
  final List<Breadcrumb> breadcrumbs;

  const EducationalNode({
    required this.id,
    this.parentId,
    required this.title,
    required this.url,
    required this.kind,
    this.resources = const [],
    this.description = '',
    this.breadcrumbs = const [],
  });

  @override
  List<Object?> get props => [id, parentId, title, url, kind, resources, description, breadcrumbs];

  factory EducationalNode.fromMap(String id, Map<String, dynamic> map) {
    return EducationalNode(
      id: id,
      parentId: map['parentId'],
      title: map['title'] ?? '',
      url: map['url'] ?? '',
      kind: map['kind'] ?? '',
      description: map['description'] ?? '',
      resources: (map['resources'] as List?)
              ?.map((e) => Resource.fromMap(Map<String, dynamic>.from(e as Map)))
              .toList() ??
          [],
      breadcrumbs: (map['breadcrumbs'] as List? ?? map['breadcrumb'] as List?)
              ?.map((e) => Breadcrumb.fromMap(Map<String, dynamic>.from(e as Map)))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'parentId': parentId,
      'title': title,
      'url': url,
      'kind': kind,
      'description': description,
      'resources': resources.map((e) => e.toMap()).toList(),
      // Breadcrumbs are usually for display, might not need to save back
    };
  }
}
