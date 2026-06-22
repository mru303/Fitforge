import 'dart:convert';

class WeightEntry {
  final String id;
  final double weight;
  final DateTime date;
  final String notes;

  WeightEntry({
    required this.id,
    required this.weight,
    required this.date,
    this.notes = '',
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'weight': weight,
      'date': date.toIso8601String(),
      'notes': notes,
    };
  }

  factory WeightEntry.fromMap(Map<String, dynamic> map) {
    return WeightEntry(
      id: map['id'] ?? '',
      weight: (map['weight'] as num).toDouble(),
      date: DateTime.parse(map['date']),
      notes: map['notes'] ?? '',
    );
  }

  String toJson() => json.encode(toMap());

  factory WeightEntry.fromJson(String source) => WeightEntry.fromMap(json.decode(source));
}
