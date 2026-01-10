import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/utils/typedefs.dart';

abstract class LobbyFirestoreDataSource {
  Stream<List<JsonMap>> watchAvailableLobbies();
  Stream<JsonMap> watchLobby(String lobbyId);
  Future<JsonMap?> getLobby(String lobbyId);
}

class LobbyFirestoreDataSourceImpl implements LobbyFirestoreDataSource {
  final FirebaseFirestore firestore;

  LobbyFirestoreDataSourceImpl({required this.firestore});

  @override
  Stream<List<JsonMap>> watchAvailableLobbies() {
    return firestore
        .collection('lobbies')
        .where('status', isEqualTo: 'WAITING')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
    });
  }

  @override
  Stream<JsonMap> watchLobby(String lobbyId) {
    return firestore
        .collection('lobbies')
        .doc(lobbyId)
        .snapshots()
        .map((snapshot) {
      if (!snapshot.exists) {
        throw FirestoreException('Lobby not found: $lobbyId');
      }

      final data = snapshot.data()!;
      data['id'] = snapshot.id;
      return data;
    });
  }

  @override
  Future<JsonMap?> getLobby(String lobbyId) async {
    try {
      final doc = await firestore.collection('lobbies').doc(lobbyId).get();

      if (!doc.exists) return null;

      final data = doc.data()!;
      data['id'] = doc.id;
      return data;
    } catch (e) {
      throw FirestoreException('Failed to get lobby: $e');
    }
  }
}

