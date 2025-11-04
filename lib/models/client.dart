class Client {
  final String id;
  final String name;
  final String phone;
  final String? email;
  final String gender;
  final String goal;
  final DateTime? dob;
  final String trainerId;
  final DateTime createdAt;
  final DateTime lastUpdated;

  Client({
    required this.id,
    required this.name,
    required this.phone,
    this.email,
    required this.gender,
    required this.goal,
    this.dob,
    required this.trainerId,
    required this.createdAt,
    required this.lastUpdated,
  });

  factory Client.fromMap(Map<String, dynamic> map, String id) {
    return Client(
      id: id,
      name: map['name'] ?? '',
      phone: map['phone'] ?? '',
      email: map['email'],
      gender: map['gender'] ?? '',
      goal: map['goal'] ?? '',
      dob: map['dob'] != null ? DateTime.fromMillisecondsSinceEpoch(map['dob']) : null,
      trainerId: map['trainerId'] ?? '',
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt']),
      lastUpdated: DateTime.fromMillisecondsSinceEpoch(map['lastUpdated']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'phone': phone,
      'email': email,
      'gender': gender,
      'goal': goal,
      'dob': dob?.millisecondsSinceEpoch,
      'trainerId': trainerId,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'lastUpdated': lastUpdated.millisecondsSinceEpoch,
    };
  }

  Client copyWith({
    String? name,
    String? phone,
    String? email,
    String? gender,
    String? goal,
    DateTime? dob,
    DateTime? lastUpdated,
  }) {
    return Client(
      id: id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      gender: gender ?? this.gender,
      goal: goal ?? this.goal,
      dob: dob ?? this.dob,
      trainerId: trainerId,
      createdAt: createdAt,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }
}