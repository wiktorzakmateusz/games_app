import 'package:flutter_test/flutter_test.dart';
import 'package:games_app/features/auth/data/models/user_model.dart';
import 'package:games_app/features/auth/domain/entities/user_entity.dart';

void main() {
  final testDateTime = DateTime(2024, 1, 1);
  
  final testUserModel = UserModel(
    id: '1',
    firebaseUid: 'firebase123',
    email: 'test@example.com',
    username: 'testuser',
    displayName: 'Test User',
    photoURL: 'https://example.com/photo.jpg',
    createdAt: testDateTime,
    updatedAt: testDateTime,
  );

  final testJson = {
    'id': '1',
    'firebaseUid': 'firebase123',
    'email': 'test@example.com',
    'username': 'testuser',
    'displayName': 'Test User',
    'photoURL': 'https://example.com/photo.jpg',
    'createdAt': testDateTime.toIso8601String(),
    'updatedAt': testDateTime.toIso8601String(),
  };

  group('UserModel', () {
    test('should be a subclass of UserEntity', () {
      expect(testUserModel, isA<UserEntity>());
    });

    test('fromJson creates UserModel from JSON', () {
      // Act
      final result = UserModel.fromJson(testJson);

      // Assert
      expect(result, isA<UserModel>());
      expect(result.id, '1');
      expect(result.firebaseUid, 'firebase123');
      expect(result.email, 'test@example.com');
      expect(result.username, 'testuser');
      expect(result.displayName, 'Test User');
      expect(result.photoURL, 'https://example.com/photo.jpg');
      expect(result.createdAt, testDateTime);
      expect(result.updatedAt, testDateTime);
    });

    test('fromJson handles null photoURL', () {
      // Arrange
      final jsonWithNullPhoto = Map<String, dynamic>.from(testJson);
      jsonWithNullPhoto['photoURL'] = null;

      // Act
      final result = UserModel.fromJson(jsonWithNullPhoto);

      // Assert
      expect(result.photoURL, null);
    });

    test('toJson converts UserModel to JSON', () {
      // Act
      final result = testUserModel.toJson();

      // Assert
      expect(result, testJson);
      expect(result['id'], '1');
      expect(result['firebaseUid'], 'firebase123');
      expect(result['email'], 'test@example.com');
      expect(result['username'], 'testuser');
      expect(result['displayName'], 'Test User');
      expect(result['photoURL'], 'https://example.com/photo.jpg');
      expect(result['createdAt'], testDateTime.toIso8601String());
      expect(result['updatedAt'], testDateTime.toIso8601String());
    });

    test('toEntity converts UserModel to UserEntity', () {
      // Act
      final result = testUserModel.toEntity();

      // Assert
      expect(result, isA<UserEntity>());
      expect(result.id, testUserModel.id);
      expect(result.firebaseUid, testUserModel.firebaseUid);
      expect(result.email, testUserModel.email);
      expect(result.username, testUserModel.username);
      expect(result.displayName, testUserModel.displayName);
      expect(result.photoURL, testUserModel.photoURL);
      expect(result.createdAt, testUserModel.createdAt);
      expect(result.updatedAt, testUserModel.updatedAt);
    });

    test('round trip from JSON to model to JSON preserves data', () {
      // Act
      final model = UserModel.fromJson(testJson);
      final json = model.toJson();

      // Assert
      expect(json, testJson);
    });

    test('round trip from model to entity preserves data', () {
      // Act
      final entity = testUserModel.toEntity();

      // Assert
      expect(entity.id, testUserModel.id);
      expect(entity.firebaseUid, testUserModel.firebaseUid);
      expect(entity.email, testUserModel.email);
      expect(entity.username, testUserModel.username);
      expect(entity.displayName, testUserModel.displayName);
      expect(entity.photoURL, testUserModel.photoURL);
      expect(entity.createdAt, testUserModel.createdAt);
      expect(entity.updatedAt, testUserModel.updatedAt);
    });
  });
}

