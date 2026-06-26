class UserProfile {
  final String name;
  final double heightCm;
  final double weightKg;
  final int age;
  final String gender;

  UserProfile({
    this.name = 'Iron Forger',
    this.heightCm = 175,
    this.weightKg = 70,
    this.age = 25,
    this.gender = 'Male',
  });

  UserProfile copyWith({
    String? name,
    double? heightCm,
    double? weightKg,
    int? age,
    String? gender,
  }) {
    return UserProfile(
      name: name ?? this.name,
      heightCm: heightCm ?? this.heightCm,
      weightKg: weightKg ?? this.weightKg,
      age: age ?? this.age,
      gender: gender ?? this.gender,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'heightCm': heightCm,
      'weightKg': weightKg,
      'age': age,
      'gender': gender,
    };
  }

  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      name: map['name'] ?? 'Iron Forger',
      heightCm: (map['heightCm'] as num?)?.toDouble() ?? 175,
      weightKg: (map['weightKg'] as num?)?.toDouble() ?? 70,
      age: map['age'] as int? ?? 25,
      gender: map['gender'] ?? 'Male',
    );
  }
}
