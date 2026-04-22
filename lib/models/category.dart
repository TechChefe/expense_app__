// lib/models/category.dart

class Category {
  final int? id;
  final String name;
  final String? description;

  const Category({
    this.id,
    required this.name,
    this.description,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'description': description,
      };

  factory Category.fromMap(Map<String, dynamic> map) => Category(
        id: map['id'] as int?,
        name: map['name'] as String,
        description: map['description'] as String?,
      );

  Category copyWith({int? id, String? name, String? description}) => Category(
        id: id ?? this.id,
        name: name ?? this.name,
        description: description ?? this.description,
      );

  @override
  bool operator ==(Object other) =>
      other is Category && other.id == id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'Category(id: $id, name: $name)';
}
