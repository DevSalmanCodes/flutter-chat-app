import 'package:cloud_firestore/cloud_firestore.dart';

class MessageModel {
  final String id;
  final String senderId;
  final String content;
  final Timestamp? timestamp;
  final String status; // 'sent', 'delivered', 'read'
  final String type;
  final String contentUrl;
  final Map<String, List<String>> reactions;

  MessageModel({
    required this.id,
    required this.senderId,
    required this.content,
    this.timestamp,
    required this.status,
    required this.type,
    required this.contentUrl,
    required this.reactions,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'senderId': senderId,
      'content': content,
      'timestamp': timestamp ?? FieldValue.serverTimestamp(),
      'status': status,
      'type': type,
      'contentUrl': contentUrl,
      'reactions': reactions,
    };
  }

  factory MessageModel.fromMap(Map<String, dynamic> map) {
    return MessageModel(
      id: map['id'] as String,
      senderId: map['senderId'] as String,
      content: map['content'] as String,
      timestamp: map['timestamp'] as Timestamp,
      status: map['status'] as String,
      type: map['type'] as String,
      contentUrl: map['contentUrl'] as String,
      reactions: (map['reactions'] as Map<String, dynamic>).map(
        (key, value) => MapEntry(
          key,
          List<String>.from(value as List<dynamic>),
        ),
      ),
    );
  }
}
