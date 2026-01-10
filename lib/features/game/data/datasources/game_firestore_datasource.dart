import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/utils/typedefs.dart';

/// Firestore data source for game real-time updates
abstract class GameFirestoreDataSource {
  Stream<JsonMap> watchGame(String gameId);
  Future<JsonMap?> getGame(String gameId);
}

class GameFirestoreDataSourceImpl implements GameFirestoreDataSource {
  final FirebaseFirestore firestore;

  GameFirestoreDataSourceImpl({required this.firestore});

  @override
  Stream<JsonMap> watchGame(String gameId) {
    return firestore
        .collection('games')
        .doc(gameId)
        .snapshots()
        .map((snapshot) {
      if (!snapshot.exists) {
        throw FirestoreException('Game not found: $gameId');
      }

      final data = snapshot.data()!;
      data['id'] = snapshot.id;
      return data;
    });
  }

  @override
  Future<JsonMap?> getGame(String gameId) async {
    try {
      final doc = await firestore.collection('games').doc(gameId).get();

      if (!doc.exists) return null;

      final data = doc.data()!;
      data['id'] = doc.id;
      return data;
    } catch (e) {
      throw FirestoreException('Failed to get game: $e');
    }
  }
}

