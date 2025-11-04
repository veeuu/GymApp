class Trainer {
  final String uid;
  final String name;
  final String email;
  final String role;
  final DateTime createdAt;

  Trainer({
    required this.uid,
    required this.name,
    required this.email,
    this.role = 'trainer',
    required this.createdAt,
  });

  factory Trainer.fromMap(Map<String, dynamic> map) {
    return Trainer(
      uid: map['uid'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      role: map['role'] ?? 'trainer',
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'role': role,
      'createdAt': createdAt.millisecondsSinceEpoch,
    };
  }
}