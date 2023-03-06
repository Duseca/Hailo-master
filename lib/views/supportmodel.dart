import 'package:cloud_firestore/cloud_firestore.dart';

class MessageModel {
  final String chatID;
  final String fid;
  final String lastMessage;
  final String lastMessageBy;
  final int unreadCount;
  final Timestamp lastMessageOn;

  const MessageModel(
      this.chatID,
      this.fid,
      this.lastMessage,
      this.lastMessageBy,
      this.unreadCount,
      this.lastMessageOn,
      );

  factory MessageModel.fromDocument(DocumentSnapshot document) {
    return MessageModel(
      document['chatID'],
      document.id,
      document['lastMessage'],
      document['lastMessageBy'],
      document['unreadCount'],
      document['lastMessageOn'],
    );
  }
}

class SupportChat {
  final String chatID;
  final String message;
  final String type;
  final String sentBy;
  final Timestamp sentOn;

  const SupportChat(
      this.chatID,
      this.message,
      this.type,
      this.sentBy,
      this.sentOn,
      );

  factory SupportChat.fromDocument(DocumentSnapshot document) {
    return SupportChat(
      document.id,
      document['message'],
      document['type'],
      document['sentBy'],
      document['sentOn'],
    );
  }
}
