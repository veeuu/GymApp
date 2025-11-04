class Achievement {
  final String id;
  final String name;
  final String description;
  final String iconName;
  final String category;
  final int targetValue;
  final String unit;
  final DateTime? unlockedAt;
  final bool isUnlocked;

  Achievement({
    required this.id,
    required this.name,
    required this.description,
    required this.iconName,
    required this.category,
    required this.targetValue,
    required this.unit,
    this.unlockedAt,
    this.isUnlocked = false,
  });

  factory Achievement.fromMap(Map<String, dynamic> map) {
    return Achievement(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      iconName: map['iconName'] ?? '',
      category: map['category'] ?? '',
      targetValue: map['targetValue'] ?? 0,
      unit: map['unit'] ?? '',
      unlockedAt: map['unlockedAt'] != null 
          ? DateTime.fromMillisecondsSinceEpoch(map['unlockedAt'])
          : null,
      isUnlocked: map['isUnlocked'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'iconName': iconName,
      'category': category,
      'targetValue': targetValue,
      'unit': unit,
      'unlockedAt': unlockedAt?.millisecondsSinceEpoch,
      'isUnlocked': isUnlocked,
    };
  }
}

class ClientStreak {
  final String clientId;
  final String type; // workout, water, steps
  final int currentStreak;
  final int longestStreak;
  final DateTime lastActivityDate;
  final DateTime streakStartDate;

  ClientStreak({
    required this.clientId,
    required this.type,
    required this.currentStreak,
    required this.longestStreak,
    required this.lastActivityDate,
    required this.streakStartDate,
  });

  factory ClientStreak.fromMap(Map<String, dynamic> map) {
    return ClientStreak(
      clientId: map['clientId'] ?? '',
      type: map['type'] ?? '',
      currentStreak: map['currentStreak'] ?? 0,
      longestStreak: map['longestStreak'] ?? 0,
      lastActivityDate: DateTime.fromMillisecondsSinceEpoch(map['lastActivityDate']),
      streakStartDate: DateTime.fromMillisecondsSinceEpoch(map['streakStartDate']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'clientId': clientId,
      'type': type,
      'currentStreak': currentStreak,
      'longestStreak': longestStreak,
      'lastActivityDate': lastActivityDate.millisecondsSinceEpoch,
      'streakStartDate': streakStartDate.millisecondsSinceEpoch,
    };
  }
}

class BodyMeasurement {
  final String id;
  final String clientId;
  final DateTime date;
  final double? weight;
  final double? bodyFat;
  final double? chest;
  final double? waist;
  final double? hips;
  final double? leftArm;
  final double? rightArm;
  final double? leftThigh;
  final double? rightThigh;
  final String? notes;
  final List<String> photoUrls;

  BodyMeasurement({
    required this.id,
    required this.clientId,
    required this.date,
    this.weight,
    this.bodyFat,
    this.chest,
    this.waist,
    this.hips,
    this.leftArm,
    this.rightArm,
    this.leftThigh,
    this.rightThigh,
    this.notes,
    required this.photoUrls,
  });

  factory BodyMeasurement.fromMap(Map<String, dynamic> map, String id) {
    return BodyMeasurement(
      id: id,
      clientId: map['clientId'] ?? '',
      date: DateTime.fromMillisecondsSinceEpoch(map['date']),
      weight: map['weight']?.toDouble(),
      bodyFat: map['bodyFat']?.toDouble(),
      chest: map['chest']?.toDouble(),
      waist: map['waist']?.toDouble(),
      hips: map['hips']?.toDouble(),
      leftArm: map['leftArm']?.toDouble(),
      rightArm: map['rightArm']?.toDouble(),
      leftThigh: map['leftThigh']?.toDouble(),
      rightThigh: map['rightThigh']?.toDouble(),
      notes: map['notes'],
      photoUrls: List<String>.from(map['photoUrls'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'clientId': clientId,
      'date': date.millisecondsSinceEpoch,
      'weight': weight,
      'bodyFat': bodyFat,
      'chest': chest,
      'waist': waist,
      'hips': hips,
      'leftArm': leftArm,
      'rightArm': rightArm,
      'leftThigh': leftThigh,
      'rightThigh': rightThigh,
      'notes': notes,
      'photoUrls': photoUrls,
    };
  }
}