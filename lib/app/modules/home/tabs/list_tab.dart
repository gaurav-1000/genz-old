import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:genz/app/constants/constants.dart';
import 'package:genz/app/models/user_model.dart';
import 'package:genz/app/modules/auth/controllers/account_controller.dart';
import 'package:genz/app/modules/home/widgets/floating_user_stats.dart';
import 'package:genz/app/modules/home/widgets/profile_picture_small.dart';
import 'package:genz/app/modules/home/widgets/wink_bottom_sheet.dart';
import 'package:get/get.dart';

import '../controllers/home_controller.dart';

class ListTab extends StatelessWidget {
  const ListTab({super.key});
  @override
  Widget build(BuildContext context) {
    final accountController = Get.find<AccountController>();
    final controller = Get.find<HomeController>();
    return Obx(
      () => CupertinoPageScaffold(
        navigationBar: CupertinoNavigationBar(
          middle: Text('scaffoldTitle_list'.tr),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              Center(
                child: Container(
                  color: CupertinoColors.systemGroupedBackground,
                  child: controller.closeUser.isEmpty
                      ? Center(child: Text("noCloseUsers".tr))
                      : ListView(
                          children: [
                            CupertinoListSection(
                              header: Text('header_nearbyUsers'.tr),
                              children: [
                                for (UserModel user in controller.closeUser)
                                  CupertinoListTile(
                                    leadingSize: Constants.listTileLeadingSize,
                                    leading: Stack(
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.all(6.0),
                                          child: ProfilePictureSmall(
                                            id: user.id,
                                            imageUrl: user.thumbnail,
                                          ),
                                        ),
                                        Positioned(
                                          bottom: 0,
                                          right: 0,
                                          child: Text(
                                            Constants.zodiacs[user.zodiac] ?? "",
                                            textAlign: TextAlign.right,
                                            style: const TextStyle(
                                              fontSize: 18,
                                              height: 1.2,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    trailing: accountController.userModel.value == null
                                        ? const CupertinoActivityIndicator()
                                        : CupertinoButton(
                                            child: Icon(
                                                (accountController.userModel.value?.winkedTo ?? [])
                                                        .contains(user.id)
                                                    ? CupertinoIcons.hand_raised_fill
                                                    : CupertinoIcons.hand_raised),
                                            onPressed: () {
                                              if ((accountController.userModel.value!.winkedTo ??
                                                      [])
                                                  .contains(user.id)) {
                                                //Show info that user already winked
                                                //Snackbar
                                                Get.snackbar(
                                                  'alreadyWinked'.tr,
                                                  'alreadyWinkedInfo'.tr,
                                                  snackPosition: SnackPosition.BOTTOM,
                                                  backgroundColor: CupertinoColors.systemBackground.darkColor,
                                                  colorText: CupertinoColors.white,
                                                );
                                                return;
                                              }else {
                                                showCupertinoModalPopup(
                                                  context: Get.context!,
                                                  builder: (context) {
                                                    return WinkBottomSheet(
                                                        user: user);
                                                  },
                                                );
                                              }
                                            },
                                          ),
                                    title: Text(
                                        "${user.name}${(user.winksCount ?? 0) >= Constants.waveSteps ? '🔥🔥' : '🔥'}"),
                                    onTap: () {
                                      //Get.toNamed(Routes.CHAT, arguments: user);
                                    },
                                  ),
                              ],
                            ),
                            const SizedBox(height: Constants.navBarHeight),
                          ],
                        ),
                ),
              ), // ---- Center
              const Positioned(
                  bottom: Constants.navBarHeight, right: 0, child: FloatingUserStatsWidget()),
            ],
          ),
        ),
      ),
    );
  }
}
