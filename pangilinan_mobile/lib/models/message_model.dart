import 'package:cloud_firestore/cloud_firestore.dart';

class MessageModel {
  final String senderId;
  final String senderEmail;
  final String receiverId;
  final String message;
  final Timestamp timestamp;
  final bool seen;

  const MessageModel({
    required this.senderId,
    required this.senderEmail,
    required this.receiverId,
    required this.message,
    required this.timestamp,
    this.seen = false,
  });

  factory MessageModel.fromMap(Map<String, dynamic> map) => MessageModel(
    senderId: map['senderId']?.toString() ?? '',
    senderEmail: map['senderEmail']?.toString() ?? '',
    receiverId: map['receiverId']?.toString() ?? '',
    message: map['message']?.toString() ?? '',
    timestamp: map['timestamp'] is Timestamp
        ? map['timestamp'] as Timestamp
        : Timestamp.now(),
    seen: map['seen'] == true,
  );

  Map<String, dynamic> toMap() => <String, dynamic>{
    'senderId': senderId,
    'senderEmail': senderEmail,
    'receiverId': receiverId,
    'message': message,
    'timestamp': timestamp,
    'seen': seen,
  };
}
