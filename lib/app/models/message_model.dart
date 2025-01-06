import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:genz/app/modules/chat/controllers/chat_controller.dart';

typedef FirebaseRef = DocumentReference<Map<String, dynamic>>;

class MessageModel {
  Timestamp timestamp;
  String from;
  String text;
  List<dynamic> images;
  String id;
  String status;
  FirebaseRef? reference;

  MessageModel(
      {required this.timestamp,
      required this.from,
      required this.text,
      required this.images,
      required this.status,
      required this.reference,
      required this.id});

  factory MessageModel.fromFirestore({
    required Map<String, dynamic> json,
    FirebaseRef? ref,
    required String id,
  }) {
    return MessageModel(
      timestamp: json['timestamp'],
      from: json['from'],
      text: json['text'],
      images: json['images'],
      status: json['status'] ?? SendState.sent,
      reference: ref,
      id: id,
    );
  }
}
