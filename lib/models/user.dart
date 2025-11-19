class User {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String department;
  final String functionalId;
  final String status;
  final String passwordHash; // In real app, this would be properly hashed

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.department,
    required this.functionalId,
    required this.status,
    required this.passwordHash,
  });

  // Convert User to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'department': department,
      'functionalId': functionalId,
      'status': status,
      'passwordHash': passwordHash,
    };
  }

  // Create User from JSON
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String? ?? '',
      department: json['department'] as String? ?? 'Tecnologia & Inovação',
      functionalId: json['functionalId'] as String? ?? '',
      status: json['status'] as String? ?? 'Ativo',
      passwordHash: json['passwordHash'] as String,
    );
  }

  // Create a copy with updated fields
  User copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? department,
    String? functionalId,
    String? status,
    String? passwordHash,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      department: department ?? this.department,
      functionalId: functionalId ?? this.functionalId,
      status: status ?? this.status,
      passwordHash: passwordHash ?? this.passwordHash,
    );
  }
}
