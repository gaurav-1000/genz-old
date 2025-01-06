import 'dart:developer';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:genz/app/constants/firebase.dart';
import 'package:genz/app/global/functions.dart';
import 'package:genz/app/models/message_model.dart';
import 'package:genz/app/models/user_model.dart';
import 'package:genz/app/modules/auth/controllers/account_controller.dart';
import 'package:get/get.dart';
import 'package:uuid/uuid.dart';

class SendState {
  static const sent = "sent";
  static const received = "received";
  static const read = "read";
}

class ChatController extends GetxController {
  final messageController = TextEditingController().obs;

  Stream<List<MessageModel>> loadMessages(String chatId) {
    log("loadMessages");
    log(chatId);
    return firebaseFirestore
        .collection("chats")
        .doc(chatId)
        .collection("messages")
        .orderBy("timestamp", descending: true)
        .snapshots()
        .map(
      (event) {
        return event.docs.map((e) {
          if (e.data()["from"] != auth.currentUser!.uid) {
            e.reference.update({"status": SendState.read});
          }
          return MessageModel.fromFirestore(json: e.data(), ref: e.reference, id: e.id);
        }).toList();
      },
    );
  }

  void sendMessage(UserModel partner, {required String chatId}) async {
    if (messageController.value.text == "") {
      return;
    }
    firebaseFirestore.collection("chats").doc(chatId).collection("messages").add({
      "from": auth.currentUser!.uid,
      "text": messageController.value.text,
      "timestamp": Timestamp.now(),
      "images": [],
      "status": SendState.sent,
    });
    Functions.sendNotification(
      title: Get.find<AccountController>().userModel.value!.name!,
      body: messageController.value.text,
      token: await getCurrentToken(partner),
      data: {
        "click_action": "FLUTTER_NOTIFICATION_CLICK",
        "type": "chatMessage",
        "chatId": chatId,
      },
    );
    messageController.value.text = "";
  }

  Future<String> getCurrentToken(UserModel partner) async {
    return firebaseFirestore.collection("users").doc(partner.id).get().then((value) {
      return value.data()?["fcm_token"] ?? "";
    });
  }

  void sendImage(UserModel partner, {required String chatId}) async {
    File? image;
    //if (await Permission.photos.request().isGranted) {
    List<File>? images;
    try {
      images = await Functions.pickImage(title: "pickImage".tr, text: "pickImageText".tr);
    } catch (_) {
      Get.snackbar(
        "error".tr,
        "unsupportedFileType".tr,
        borderColor: CupertinoColors.systemGrey6,
        borderWidth: 1,
        backgroundColor: CupertinoColors.white,
      );
      Get.back();
      return;
    }
    //}
    if (images == null) {
      return;
    }
    image = images[1];

    final path = 'userContent/${auth.currentUser!.uid}/${const Uuid().v4()}.png';
    final file = File(image.path);
    final ref = firebaseStorage.ref(path);
    await ref.putFile(file);

    final download = await ref.getDownloadURL();

    firebaseFirestore.collection("chats").doc(chatId).collection("messages").add({
      "from": auth.currentUser!.uid,
      "text": "",
      "timestamp": Timestamp.now(),
      "images": [download],
      "status": SendState.sent,
    });
    messageController.value.text = "";
    Functions.sendNotification(
      title: Get.find<AccountController>().userModel.value!.name!,
      imageUrl: download,
      token: await getCurrentToken(partner),
      data: {
        "click_action": "FLUTTER_NOTIFICATION_CLICK",
        "type": "chatImage",
        "chatId": chatId,
        "imageUrl": download,
      },
    );
  }
}
