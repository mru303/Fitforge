class AchievementBadge {
  final String id;
  final String title;
  final String description;
  final String iconCode; // Custom identifier for badge type
  final bool isUnlocked;
  final DateTime? unlockedAt;

  AchievementBadge({
    required this.id,
    required this.title,
    required this.description,
    required this.iconCode,
    this.isUnlocked = false,
    this.unlockedAt,
  });

  AchievementBadge copyWith({
    bool? isUnlocked,
    DateTime? unlockedAt,
  }) {
    return AchievementBadge(
      id: id,
      title: title,
      description: description,
      iconCode: iconCode,
      isUnlocked: isUnlocked ?? this.isUnlocked,
      unlockedAt: unlockedAt ?? this.unlockedAt,
    );
  }
}
