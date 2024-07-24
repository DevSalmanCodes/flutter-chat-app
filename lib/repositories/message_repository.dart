import 'package:chat_app/models/message_model.dart';
import 'package:chat_app/type_defs.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

abstract class IMessageRepository{
FutureEitherVoid sendMessage(MessageModel messageModel);
Stream<List<QueryDocumentSnapshot<Map<String,dynamic>>>> getMessages();
}
class MessageRepository implements IMessageRepository{
  @override
  FutureEitherVoid sendMessage(MessageModel messageModel) {
throw UnimplementedError();
  }
  
  @override
  Stream<List<QueryDocumentSnapshot<Map<String, dynamic>>>> getMessages() {
    throw UnimplementedError();
  }
}