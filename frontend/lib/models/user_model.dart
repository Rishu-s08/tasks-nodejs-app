// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class UserModel {
  final String id;
  final String email;
  final String token;
  final String name;
  final DateTime createdAt;
  final DateTime updatedAt;
  UserModel({
    required this.id,
    required this.email,
    required this.token,
    required this.name,
    required this.createdAt,
    required this.updatedAt,
  });

  UserModel copyWith({
    String? id,
    String? email,
    String? token,
    String? name,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      token: token ?? this.token,
      name: name ?? this.name,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'email': email,
      'token': token,
      'name': name,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    // Handle nested user object from signup response
    final userData = map['user'] ?? map;

    return UserModel(
      id: userData['id'] ?? '',
      email: userData['email'] ?? '',
      token:
          map['token'] ?? '', // token comes from root level in login response
      name: userData['name'] ?? '',
      createdAt: userData['created_at'] != null
          ? DateTime.parse(userData['created_at'] as String)
          : userData['createdAt'] != null
          ? DateTime.parse(userData['createdAt'] as String)
          : DateTime.now(),
      updatedAt: userData['updated_at'] != null
          ? DateTime.parse(userData['updated_at'] as String)
          : userData['updatedAt'] != null
          ? DateTime.parse(userData['updatedAt'] as String)
          : DateTime.now(),
    );
  }

  String toJson() => json.encode(toMap());

  factory UserModel.fromJson(String source) =>
      UserModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'UserModel(id: $id, email: $email, token: $token, name: $name, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(covariant UserModel other) {
    if (identical(this, other)) return true;

    return other.id == id &&
        other.email == email &&
        other.token == token &&
        other.name == name &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        email.hashCode ^
        token.hashCode ^
        name.hashCode ^
        createdAt.hashCode ^
        updatedAt.hashCode;
  }
}
