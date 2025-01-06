import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:genz/app/models/user_model.dart';

class ChatModel {
  UserModel partner;
  Timestamp lastMessage;
  String id;

  ChatModel({required this.partner, required this.lastMessage, required this.id});

  factory ChatModel.fromFirestore({
    required Map<String, dynamic> json,
    required UserModel partner,
    required String id,
  }) {
    return ChatModel(
      lastMessage: json['last_message'],
      partner: partner,
      id: id,
    );
  }
}
