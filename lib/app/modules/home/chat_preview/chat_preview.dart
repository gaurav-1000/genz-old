import 'package:flutter/cupertino.dart';
import 'package:genz/app/constants/constants.dart';
import 'package:genz/app/models/chat_model.dart';
import 'package:genz/app/modules/home/widgets/profile_picture_small.dart';
import 'package:genz/app/routes/app_pages.dart';
import 'package:get/get.dart';

import 'chat_preview_controller.dart';

class ChatPreview extends StatelessWidget {
  final ChatModel chat;

   const ChatPreview({super.key, required this.chat});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put<ChatPreviewController>(ChatPreviewController(chatId: chat.id));

    return Obx(
          () =>  CupertinoListTile(
        leadingSize: Constants.listTileLeadingSize,
        leading: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(6.0),
              child: ProfilePictureSmall(
                id: chat.partner.id,
                imageUrl: chat.partner.thumbnail,
              ),
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: Text(
                Constants.zodiacs[chat.partner.zodiac] ?? "",
                textAlign: TextAlign.right,
                style: const TextStyle(
                  fontSize: 18,
                  height: 1.2,
                ),
              ),
            ),
          ],
        ),
        title: Text(
            "${chat.partner.name}${(chat.partner.winksCount ?? 0) >= Constants.waveSteps ? '🔥🔥' : '🔥'}"),

        trailing: Row(
          children: [
            if (controller.missedMessages > 0)
              Container(
                decoration: BoxDecoration(
                  color: Get.theme.primaryColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                margin: const EdgeInsets.only(right: 8),
                child: Text(
                  controller.missedMessages.toString(),
                  style: const TextStyle(
                    color: CupertinoColors.white,
                    fontSize: 12,
                  ),
                ),
              ),
            controller.lastMessage.value == null
                ? const Center(
              child: Text(
                "--:--",
                style: TextStyle(
                  fontSize: 12,
                  height: 1.2,
                ),
              ),
            )
                : Text(
                    "${controller.lastMessage.value?.timestamp.toDate().hour.toString().padLeft(2, "0")}:${controller.lastMessage.value?.timestamp.toDate().minute.toString().padLeft(2, "0")}",
                    style: const TextStyle(
                      fontSize: 12,
                      height: 1.2,
                    ),
                  ),
          ],
        ),
        subtitle: controller.lastMessage.value == null
            ? Center(child: Text("noMessages".tr))
            : Text(controller.lastMessage.value?.images.isEmpty == true ? controller.lastMessage.value?.text ?? '' : "image".tr),
        onTap: () async {
          await Get.toNamed(Routes.CHAT, arguments: chat);
        },
      ),
    );
  }
}
