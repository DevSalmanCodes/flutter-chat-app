import 'package:cloud_firestore/cloud_firestore.dart';

class ChatModel {
  final String id;
  final List<String> participantIds;
  final String lastMessage;
  final Timestamp? timestamp;


  ChatModel(
      {required this.id,
      required this.participantIds,
      required this.lastMessage,
      required this.timestamp,
    });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'participantIds': participantIds,
      'lastMessage': lastMessage,
      'timestamp': timestamp ?? FieldValue.serverTimestamp(),

    };
  }

  factory ChatModel.fromMap(Map<String, dynamic> map) {
    return ChatModel(
      id: map['id'] as String,
      participantIds: List<String>.from(map['participantIds'] as List<dynamic>),
      lastMessage: map['lastMessage'] as String,
      timestamp: map['timestamp'] as Timestamp,
  
    );
  }
}
