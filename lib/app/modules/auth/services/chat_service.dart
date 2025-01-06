import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:genz/app/constants/firebase.dart';
import 'package:genz/app/models/chat_model.dart';
import 'package:genz/app/modules/auth/services/user_service.dart';
import 'package:genz/app/routes/app_pages.dart';
import 'package:get/get.dart';

class ChatService extends GetxController {
  static Future<void> startChat(String userId) async {
    // check if the chat already exists
    final chat = await firebaseFirestore
        .collection("chats")
        .where("users", isEqualTo: [userId, auth.currentUser!.uid]).where("users",
            isEqualTo: [userId, auth.currentUser!.uid]).get();
    if (chat.docs.isNotEmpty) {
      openChat(chat.docs.first.id);
      return;
    }
    var doc = await firebaseFirestore.collection("chats").add({
      "users": [auth.currentUser!.uid, userId],
      "last_message": Timestamp.now(),
    });
    HapticFeedback.mediumImpact();
    openChat(doc.id);
  }

  static Future<void> openChat(String chatId) async {
    final chat = await firebaseFirestore.collection("chats").doc(chatId).get();
    if (!chat.exists) {
      Get.snackbar(
        "error".tr,
        "chatDoesNotExist".tr,
        borderColor: CupertinoColors.systemGrey6,
        borderWidth: 1,
        backgroundColor: CupertinoColors.white,
      );
      return;
    }
    var json = chat.data() ?? {};
    var partnerId = json["users"].firstWhere((element) {
      return element != auth.currentUser!.uid;
    });
    var partner = await UserService.getUser(partnerId);
    final chatModel = ChatModel.fromFirestore(
      json: json,
      partner: partner,
      id: chat.id,
    );
    await Get.toNamed(Routes.CHAT, arguments: chatModel);
  }
}
