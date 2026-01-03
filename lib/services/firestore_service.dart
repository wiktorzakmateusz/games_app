import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/lobby.dart';
import '../models/game.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<Lobby> watchLobby(String lobbyId) {
    return _firestore
        .collection('lobbies')
        .doc(lobbyId)
        .snapshots()
        .map((snapshot) {
      if (!snapshot.exists) {
        throw Exception('Lobby not found: $lobbyId');
      }
      
      final data = snapshot.data()!;
      // Add the document ID to the data
      data['id'] = snapshot.id;
      
      return Lobby.fromJson(data);
    });
  }

  Stream<Game> watchGame(String gameId) {
    return _firestore
        .collection('games')
        .doc(gameId)
        .snapshots()
        .map((snapshot) {
      if (!snapshot.exists) {
        throw Exception('Game not found: $gameId');
      }
      
      final data = snapshot.data()!;
      // Add the document ID to the data
      data['id'] = snapshot.id;
      
      return Game.fromJson(data);
    });
  }

  Stream<List<Lobby>> watchAvailableLobbies() {
    return _firestore
        .collection('lobbies')
        .where('status', isEqualTo: 'WAITING')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return Lobby.fromJson(data);
      }).toList();
    });
  }

  Future<Lobby?> getLobby(String lobbyId) async {
    final doc = await _firestore.collection('lobbies').doc(lobbyId).get();
    
    if (!doc.exists) return null;
    
    final data = doc.data()!;
    data['id'] = doc.id;
    return Lobby.fromJson(data);
  }

  Future<Game?> getGame(String gameId) async {
    final doc = await _firestore.collection('games').doc(gameId).get();
    
    if (!doc.exists) return null;
    
    final data = doc.data()!;
    data['id'] = doc.id;
    return Game.fromJson(data);
  }

  Future<Game?> getGameByLobbyId(String lobbyId) async {
    final snapshot = await _firestore
        .collection('games')
        .where('lobbyId', isEqualTo: lobbyId)
        .limit(1)
        .get();
    
    if (snapshot.docs.isEmpty) return null;
    
    final doc = snapshot.docs.first;
    final data = doc.data();
    data['id'] = doc.id;
    return Game.fromJson(data);
  }
}

