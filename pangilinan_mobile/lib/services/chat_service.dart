import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;

import '../models/message_model.dart';

// Lab Activity 6, Enhancement 1 & 2: Powers the chat list (all registered
// users minus the current one) and the realtime message thread between two
// users, backed by Cloud Firestore.
class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final firebase_auth.FirebaseAuth _firebaseAuth =
      firebase_auth.FirebaseAuth.instance;

  /// All registered users, as raw Firestore data (doc id included as 'uid'
  /// when the document itself doesn't already carry one).
  Stream<List<Map<String, dynamic>>> getUsersStream() {
    return _firestore.collection('Users').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final Map<String, dynamic> user = doc.data();
        user['uid'] = user['uid'] ?? doc.id;
        return user;
      }).toList();
    });
  }

  String _chatRoomId(String userIdA, String userIdB) {
    final List<String> ids = <String>[userIdA, userIdB]..sort();
    return ids.join('_');
  }

  Future<void> sendMessage(String receiverId, String message) async {
    final firebase_auth.User currentUser = _firebaseAuth.currentUser!;
    final MessageModel newMessage = MessageModel(
      senderId: currentUser.uid,
      senderEmail: currentUser.email ?? '',
      receiverId: receiverId,
      message: message,
      timestamp: Timestamp.now(),
    );

    final String chatRoomId = _chatRoomId(currentUser.uid, receiverId);
    await _firestore
        .collection('chat_rooms')
        .doc(chatRoomId)
        .collection('messages')
        .add(newMessage.toMap());
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getMessages(
    String userId,
    String otherUserId,
  ) {
    final String chatRoomId = _chatRoomId(userId, otherUserId);
    return _firestore
        .collection('chat_rooms')
        .doc(chatRoomId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  /// Enhancement 3: Marks messages the other user sent us as seen, so their
  /// screen can show a "seen" checkmark instead of just "delivered".
  Future<void> markMessagesSeen(
    String currentUserId,
    String otherUserId,
  ) async {
    final String chatRoomId = _chatRoomId(currentUserId, otherUserId);
    final QuerySnapshot<Map<String, dynamic>> unseen = await _firestore
        .collection('chat_rooms')
        .doc(chatRoomId)
        .collection('messages')
        .where('receiverId', isEqualTo: currentUserId)
        .where('senderId', isEqualTo: otherUserId)
        .where('seen', isEqualTo: false)
        .get();
    if (unseen.docs.isEmpty) return;
    final WriteBatch batch = _firestore.batch();
    for (final QueryDocumentSnapshot<Map<String, dynamic>> doc
        in unseen.docs) {
      batch.update(doc.reference, <String, dynamic>{'seen': true});
    }
    await batch.commit();
  }

  Future<String?> getUidByEmail(String email) async {
    final QuerySnapshot<Map<String, dynamic>> query = await _firestore
        .collection('Users')
        .where('email', isEqualTo: email)
        .limit(1)
        .get();
    if (query.docs.isEmpty) return null;
    final Map<String, dynamic> data = query.docs.first.data();
    return (data['uid'] ?? query.docs.first.id).toString();
  }
}
