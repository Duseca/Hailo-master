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

class Chat {
  final String chatID;
  final String message;
  final String type;
  final String sentBy;
  final Timestamp sentOn;

  const Chat(
      this.chatID,
      this.message,
      this.type,
      this.sentBy,
      this.sentOn,
      );

  factory Chat.fromDocument(DocumentSnapshot document) {
    return Chat(
      document.id,
      document['message'],
      document['type'],
      document['sentBy'],
      document['sentOn'],
    );
  }
}
