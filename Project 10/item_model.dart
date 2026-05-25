class ItemModel {
  final int id;
  String name;
  String description;
  String category;
  DateTime createdAt;

  ItemModel({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.createdAt,
  });

  // Konversi dari JSON (SharedPreferences)
  factory ItemModel.fromJson(Map<String, dynamic> json) {
    return ItemModel(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      category: json['category'] ?? 'Umum',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
    );
  }

  // Konversi ke JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'category': category,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}