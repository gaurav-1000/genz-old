import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:genz/app/constants/constants.dart';
import 'package:genz/app/models/chat_model.dart';

import 'package:get/get.dart';

import '../controllers/profile_controller.dart';

class ProfileView extends GetView<ProfileController> {
  const ProfileView({super.key});
  @override
  Widget build(BuildContext context) {
    ChatModel chat = Get.arguments;
    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.systemGroupedBackground,
      navigationBar: const CupertinoNavigationBar(),
      child: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                color: CupertinoColors.white,
                child: Padding(
                  padding: const EdgeInsets.only(
                    bottom: 8,
                    left: 30.0,
                    right: 30.0,
                  ),
                  child: Hero(
                    tag: Key("${chat.partner.id}-image"),
                    child: CachedNetworkImage(
                      imageUrl: chat.partner.imageUrl!,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              CupertinoListSection(
                children: [
                  CupertinoListTile(
                    leading: const Icon(CupertinoIcons.person),
                    subtitle: Text("settings_name".tr),
                    title: Text(
                      chat.partner.name!,
                      style: const TextStyle(fontSize: 20),
                    ),
                  ),
                  CupertinoListTile(
                    leading: Text(
                      Constants.zodiacs[chat.partner.zodiac] ?? "",
                    ),
                    subtitle: Text("zodiacSign".tr),
                    title: Text(
                      chat.partner.zodiac == null ? "none".tr : "zodiac_${chat.partner.zodiac}".tr,
                      style: const TextStyle(fontSize: 20),
                    ),
                  ),
                ],
              ),
              CupertinoListSection(
                children: [
                  GestureDetector(
                    child: const CupertinoListTile(
                      leading: Icon(
                        CupertinoIcons.delete,
                        color: CupertinoColors.systemRed,
                      ),
                      title: Text(
                        "Delete chat",
                        style: TextStyle(
                          fontSize: 20,
                          color: CupertinoColors.systemRed,
                        ),
                      ),
                    ),
                    onTap: () {
                      controller.deleteChat(chat.id);
                    },
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
