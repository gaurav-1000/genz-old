import 'dart:async';

import 'package:genz/app/models/message_model.dart';
import 'package:get/get.dart';

import '../../../constants/firebase.dart';
import '../controllers/chats_controller.dart';

class ChatPreviewController extends GetxController {
  final String chatId;

  StreamSubscription<MessageModel>? lastMessageStream;

  RxInt missedMessages = 0.obs;

  Rx<MessageModel?> lastMessage = Rx<MessageModel?>(null);

  ChatPreviewController({required this.chatId});

  @override
  void onInit() {
    super.onInit();

    lastMessageStream?.cancel();
    lastMessageStream =
        Get.find<ChatsController>().loadLastMessage(chatId).listen((event) {
      _getUnreadMessages();
      lastMessage.value = event;
    });
  }

  void _getUnreadMessages() {
    firebaseFirestore
        .collection("chats")
        .doc(chatId)
        .collection("messages")
        .where("status", isEqualTo: "sent")
        .where("from", isNotEqualTo: auth.currentUser!.uid)
        .get()
        .then((value) {
      missedMessages.value = value.docs.length;
    });
  }

  @override
  void onClose() {
    lastMessageStream?.cancel();
    super.onClose();
  }
}
