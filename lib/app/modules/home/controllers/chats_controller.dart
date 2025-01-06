import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:genz/app/constants/firebase.dart';
import 'package:genz/app/models/chat_model.dart';
import 'package:genz/app/models/message_model.dart';
import 'package:genz/app/models/user_model.dart';
import 'package:genz/app/modules/home/controllers/home_controller.dart';
import 'package:get/get.dart';
import 'package:uuid/uuid.dart';

class ChatsController extends GetxController {
  Rx<Future<List<ChatModel>>> chatsFuture = Future.value(<ChatModel>[]).obs;
  RxList<ChatModel> chats = <ChatModel>[].obs;
  @override
  void onInit() async {
    Get.find<HomeController>().title("scaffoldTitle_chats".tr);
    chatsFuture.bindStream(loadChats());
    ever(chatsFuture, (value) {
      // Await the Futures as soon as the main Stream changes
      value.then((value) {
        chats.assignAll(value);
      });
    });
    super.onInit();
  }

  Stream<Future<List<ChatModel>>> loadChats() {
    log("Stream Updated");
    return firebaseFirestore
        .collection("chats")
        .where("users", arrayContains: auth.currentUser!.uid)
        .snapshots()
        .map((event) {
      var futures = event.docs.map((e) {
        var json = e.data();
        log("$json");
        var partnerId = json["users"].firstWhere((element) {
          return element != auth.currentUser!.uid;
        });

        return firebaseFirestore.collection("users").doc(partnerId).get().then((value) async {
          if (!value.exists) {
            return ChatModel(
              id: const Uuid().v4(),
              partner: UserModel(
                id: const Uuid().v4(),
                name: "deletedUser".tr,
                imageUrl: "https://i.stack.imgur.com/l60Hf.png",
                bio: "deleted".tr,
                fcmToken: "",
                zodiac: "aries",
              ),
              lastMessage: Timestamp(0, 0),
            );
          }
          return ChatModel.fromFirestore(
            json: json,
            partner: UserModel.fromFirestore(json: value.data()!, id: partnerId),
            id: e.id,
          );
        });
      }).toList();
      return Future.wait(futures);
    });
  }

  Stream<MessageModel> loadLastMessage(String chatId) {
    log("loadLastMessage");
    log(chatId);
    return firebaseFirestore
        .collection("chats")
        .doc(chatId)
        .collection("messages")
        .orderBy("timestamp", descending: true)
        .limit(1)
        .snapshots()
        .map((event) {
      return MessageModel.fromFirestore(json: event.docs.first.data(), id: event.docs.first.id);
    });
  }

  // Future<List<ChatModel>> testChats() async {
  // var chats = await firebaseFirestore
  //     .collection("chats")
  //     .where("users", arrayContains: auth.currentUser!.uid)
  //     .get();
  // return chats.docs.map((e) {
  //   return ChatModel.fromFirestore(json: e.data(), id: e.id);
  // }).toList();
  // }
}
