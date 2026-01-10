import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  final String id;
  final String firebaseUid;
  final String email;
  final String username;
  final String displayName;
  final String? photoURL;
  final DateTime createdAt;
  final DateTime updatedAt;

  const UserEntity({
    required this.id,
    required this.firebaseUid,
    required this.email,
    required this.username,
    required this.displayName,
    this.photoURL,
    required this.createdAt,
    required this.updatedAt,
  });

  UserEntity copyWith({
    String? id,
    String? firebaseUid,
    String? email,
    String? username,
    String? displayName,
    String? photoURL,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserEntity(
      id: id ?? this.id,
      firebaseUid: firebaseUid ?? this.firebaseUid,
      email: email ?? this.email,
      username: username ?? this.username,
      displayName: displayName ?? this.displayName,
      photoURL: photoURL ?? this.photoURL,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        firebaseUid,
        email,
        username,
        displayName,
        photoURL,
        createdAt,
        updatedAt,
      ];
}

