// lib/models/expense.dart

class Expense {
  final int? id;
  final String? description;
  final double amount;
  final int categoryId;
  final DateTime dateTime;
  final double? latitude;
  final double? longitude;
  final String? locationName;

  const Expense({
    this.id,
    this.description,
    required this.amount,
    required this.categoryId,
    required this.dateTime,
    this.latitude,
    this.longitude,
    this.locationName,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'description': description,
        'amount': amount,
        'category_id': categoryId,
        'date_time': dateTime.toIso8601String(),
        'latitude': latitude,
        'longitude': longitude,
        'location_name': locationName,
      };

  factory Expense.fromMap(Map<String, dynamic> map) => Expense(
        id: map['id'] as int?,
        description: map['description'] as String?,
        amount: (map['amount'] as num).toDouble(),
        categoryId: map['category_id'] as int,
        dateTime: DateTime.parse(map['date_time'] as String),
        latitude: map['latitude'] != null ? (map['latitude'] as num).toDouble() : null,
        longitude: map['longitude'] != null ? (map['longitude'] as num).toDouble() : null,
        locationName: map['location_name'] as String?,
      );

  Expense copyWith({
    int? id,
    String? description,
    double? amount,
    int? categoryId,
    DateTime? dateTime,
    double? latitude,
    double? longitude,
    String? locationName,
  }) =>
      Expense(
        id: id ?? this.id,
        description: description ?? this.description,
        amount: amount ?? this.amount,
        categoryId: categoryId ?? this.categoryId,
        dateTime: dateTime ?? this.dateTime,
        latitude: latitude ?? this.latitude,
        longitude: longitude ?? this.longitude,
        locationName: locationName ?? this.locationName,
      );
}
