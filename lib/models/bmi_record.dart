import 'dart:convert';

class BmiRecord {
  final String id;
  final double score;
  final String category;
  final DateTime date;
  final double height;
  final double weight;

  BmiRecord({
    required this.id,
    required this.score,
    required this.category,
    required this.date,
    required this.height,
    required this.weight,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'score': score,
      'category': category,
      'date': date.toIso8601String(),
      'height': height,
      'weight': weight,
    };
  }

  factory BmiRecord.fromMap(Map<String, dynamic> map) {
    return BmiRecord(
      id: map['id'] ?? '',
      score: (map['score'] as num).toDouble(),
      category: map['category'] ?? '',
      date: DateTime.parse(map['date']),
      height: (map['height'] as num).toDouble(),
      weight: (map['weight'] as num).toDouble(),
    );
  }

  String toJson() => json.encode(toMap());

  factory BmiRecord.fromJson(String source) => BmiRecord.fromMap(json.decode(source));
}
