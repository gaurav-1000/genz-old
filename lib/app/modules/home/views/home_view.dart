import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:genz/app/constants/constants.dart';
import 'package:genz/app/modules/home/tabs/chats_tab.dart';
import 'package:genz/app/modules/home/tabs/list_tab.dart';
import 'package:genz/app/modules/home/tabs/map_tab.dart';
import 'package:genz/app/modules/home/tabs/settings_tab.dart';
import 'package:genz/app/modules/home/tabs/winks_tab.dart';

import 'package:get/get.dart';

import '../controllers/home_controller.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  final pages = const [
    MapTab(),
    ListTab(),
    WinksTab(),
    ChatsTab(),
    SettingsTab(),
  ];

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<HomeController>();
    return Obx(
      () => CupertinoPageScaffold(
        child: Stack(
          children: [
            PageView(
              physics:
                  controller.pageViewIndex.value == 0 ? const NeverScrollableScrollPhysics() : null,
              controller: controller.pageController.value,
              children: pages,
              onPageChanged: (i) {
                log("Page changed to $i");
                controller.pageViewIndex.value = i;
              },
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: SafeArea(
                child: Container(
                  width: double.infinity,
                  height: Constants.navBarHeight,
                  decoration: const BoxDecoration(
                    color: CupertinoColors.white,
                    border: Border(
                      top: BorderSide(
                        color: CupertinoColors.systemGrey,
                        width: 0.5,
                      ),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      NavButton(
                        icon: CupertinoIcons.map,
                        label: "nav_map",
                        index: 0,
                      ),
                      NavButton(
                        icon: CupertinoIcons.list_bullet,
                        label: "nav_list",
                        index: 1,
                        count: controller.closeUser.length,
                      ),
                      NavButton(
                        icon: CupertinoIcons.hand_raised,
                        label: "nav_winks",
                        index: 2,
                      ),
                      NavButton(
                        icon: CupertinoIcons.chat_bubble_2,
                        label: "nav_chats",
                        index: 3,
                        count: controller.unreadMessagesCount.value,
                      ),
                      NavButton(
                        icon: CupertinoIcons.settings,
                        label: "nav_settings",
                        index: 4,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ignore: non_constant_identifier_names
  Widget NavButton({
    required IconData icon,
    required String label,
    required int index,
    int count = 0,
  }) {
    final controller = Get.find<HomeController>();
    return Expanded(
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        fit: StackFit.expand,
        children: [
          GestureDetector(
            behavior: HitTestBehavior.translucent,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  color: controller.pageViewIndex.value == index
                      ? CupertinoColors.activeBlue
                      : CupertinoColors.systemGrey,
                ),
                Text(
                  label.tr,
                  style: TextStyle(
                    color: controller.pageViewIndex.value == index
                        ? CupertinoColors.activeBlue
                        : CupertinoColors.systemGrey,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            onTap: () {
              controller.pageController.value.jumpToPage(index);
              controller.pageViewIndex.value = index;
            },
          ),
          if (count > 0)
            Positioned(
              top: 0,
              right: 20,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: CupertinoColors.systemRed,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  count.toString(),
                  style: const TextStyle(
                    color: CupertinoColors.white,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
