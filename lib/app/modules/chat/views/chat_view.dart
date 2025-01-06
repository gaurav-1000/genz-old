import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_bubbles/chat_bubbles.dart';
import 'package:flutter/cupertino.dart';
import 'package:genz/app/constants/firebase.dart';
import 'package:genz/app/models/chat_model.dart';
import 'package:genz/app/modules/chat/views/image_view.dart';
import 'package:genz/app/routes/app_pages.dart';

import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';

import '../controllers/chat_controller.dart';

class ChatView extends GetView<ChatController> {
  const ChatView({super.key});
  @override
  Widget build(BuildContext context) {
    ChatModel chat = Get.arguments;
    return Obx(
      () => CupertinoPageScaffold(
        navigationBar: CupertinoNavigationBar(
          middle: GestureDetector(
            onTap: () async {
              await Get.toNamed(Routes.PROFILE, arguments: chat);
            },
            child: Row(
              children: [
                // Hero(
                //   tag: Key("${chat.partner.id}-image"),
                //   child:
                CachedNetworkImage(imageUrl: chat.partner.imageUrl!, height: 38),
                //),
                const SizedBox(width: 8),
                Text(chat.partner.name!),
              ],
            ),
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: StreamBuilder(
                  stream: controller.loadMessages(chat.id),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CupertinoActivityIndicator());
                    }
                    var messages = snapshot.data;
                    if (messages == null) {
                      return const Center(child: Text("No messages found"));
                    }
                    String? lastUserId;
                    //
                    //  inspect(messages);
                    return ListView.builder(
                      itemCount: messages.length,
                      reverse: true,
                      itemBuilder: (context, index) {
                        var message = messages[index];
                        var isSender = message.from == auth.currentUser!.uid;
                        var bubble = message.images.isEmpty
                            ? BubbleSpecialThree(
                                text: message.text,
                                color: isSender ? const Color(0xFF1B97F3) : const Color(0xFFE8E8EE),
                                tail: message.from != lastUserId,
                                textStyle: TextStyle(
                                    color: isSender ? CupertinoColors.white : CupertinoColors.black,
                                    fontSize: 16),
                                isSender: isSender,
                                sent: !isSender ? false : message.status == SendState.sent,
                                //delivered: !isSender ? false : message.status == SendState.received,
                                seen: !isSender ? false : message.status == SendState.read,
                              )
                            : BubbleNormalImage(
                                id: message.images[0],
                                onTap: () {
                                  Get.to(
                                    () => ImageView(
                                      tag: "",
                                      image: CachedNetworkImage(
                                        imageUrl: message.images[0],
                                      ),
                                    ),
                                  );
                                },
                                image: CachedNetworkImage(
                                  imageUrl: message.images[0],
                                  width: 200,
                                  height: 150,
                                  fit: BoxFit.cover,
                                  placeholder: (context, text) {
                                    return Shimmer.fromColors(
                                      baseColor: isSender
                                          ? const Color(0xFF1B97F3)
                                          : const Color(0xFFE8E8EE),
                                      highlightColor: isSender
                                          ? const Color.fromARGB(255, 89, 174, 240)
                                          : CupertinoColors.white.withAlpha(255),
                                      direction: ShimmerDirection.ltr,
                                      child: Container(
                                        width: 200,
                                        height: 150,
                                        color: CupertinoColors.white,
                                      ),
                                    );
                                  },
                                ),
                                isSender: isSender,
                                color: isSender ? const Color(0xFF1B97F3) : const Color(0xFFE8E8EE),
                                sent: !isSender ? false : message.status == SendState.sent,
                                //delivered: !isSender ? false : message.status == SendState.received,
                                seen: !isSender ? false : message.status == SendState.read,
                              );
                        DateTime nextDate =
                            messages[index == messages.length - 1 || index == 0 ? index : index - 1]
                                .timestamp
                                .toDate();
                        DateTime date = message.timestamp.toDate();
                        String dateString = "${nextDate.day}/${nextDate.month}/${nextDate.year}";

                        var col = Column(
                          children: [
                            if (index == messages.length - 1) Text(dateString),
                            bubble,
                            if (nextDate.year != date.year ||
                                nextDate.month != date.month ||
                                nextDate.day != date.day)
                              Text(dateString),
                          ],
                        );
                        lastUserId = message.from;
                        return col;
                      },
                    );
                  },
                ),
              ),
              Row(
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: CupertinoTextField(
                        controller: controller.messageController.value,
                        placeholder: "textField_typeMessage".tr,
                        onSubmitted: (_) {
                          controller.sendMessage(chat.partner, chatId: chat.id);
                        },
                      ),
                    ),
                  ),
                  CupertinoButton(
                    onPressed: () {
                      controller.sendImage(chat.partner, chatId: chat.id);
                    },
                    child: const Icon(CupertinoIcons.photo),
                  ),
                  CupertinoButton(
                    onPressed: () {
                      controller.sendMessage(chat.partner, chatId: chat.id);
                    },
                    child: const Icon(CupertinoIcons.paperplane),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
