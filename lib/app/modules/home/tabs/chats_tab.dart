import 'package:flutter/cupertino.dart';
import 'package:flutter_app_badger/flutter_app_badger.dart';
import 'package:genz/app/constants/constants.dart';
import 'package:genz/app/models/chat_model.dart';
import 'package:genz/app/modules/home/controllers/home_controller.dart';
import 'package:genz/app/modules/home/chat_preview/chat_preview.dart';

import 'package:get/get.dart';

import '../controllers/chats_controller.dart';

class ChatsTab extends StatelessWidget {
  const ChatsTab({super.key});
  @override
  Widget build(BuildContext context) {
    FlutterAppBadger.removeBadge();
    final controller = Get.find<ChatsController>();
    Get.find<HomeController>().updateUnreadMessages();
    return Obx(
      () => CupertinoPageScaffold(
        navigationBar: CupertinoNavigationBar(
          middle: Text('scaffoldTitle_chats'.tr),
        ),
        child: SafeArea(
          child: Container(
            color: CupertinoColors.systemGroupedBackground,
            child: controller.chats.isEmpty
                ? Center(child: Text("noChats".tr))
                : ListView(
                    children: [
                      CupertinoListSection(
                        header: Text('header_chats'.tr),
                        children: [
                          for (ChatModel chat in controller.chats) ChatPreview(chat: chat),
                        ],
                      ),
                      const SizedBox(height: Constants.navBarHeight),
                    ],
                  ),
          ), //Bis hir hin
        ),
      ),
    );
  }
}
