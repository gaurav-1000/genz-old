import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:genz/app/constants/firebase.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

class ProfileController extends GetxController {
  void deleteChat(String chatId) async {
    showCupertinoDialog(
        context: Get.context!,
        builder: (context) => CupertinoAlertDialog(
              title: Text("dialog_deleteChat_title".tr),
              content: Text("dialog_deleteChat_content".tr),
              actions: [
                CupertinoDialogAction(
                  child: Text("yes".tr),
                  onPressed: () async {
                    await firebaseFirestore.collection("chats").doc(chatId).delete();
                    Get.back();
                    Get.back();
                    Get.back();
                  },
                ),
                CupertinoDialogAction(
                  child: Text("close".tr),
                  onPressed: () {
                    Get.back();
                  },
                ),
              ],
            ));
    Get.dialog(
      CupertinoAlertDialog(
        title: Text('dialog_deleteChat_title'.tr),
        content: Text('dialog_deleteChat_content'.tr),
        actions: [
          CupertinoButton(
            child: Text('close'.tr),
            onPressed: () => Get.back(),
          ),
          CupertinoButton(
            child: Text("yes".tr),
            onPressed: () async {
              await firebaseFirestore.collection("chats").doc(chatId).delete();
              Get.back();
              Get.back();
              Get.back();
            },
          ),
        ],
      ),
    );
  }

  Future<void> call(String number) async {
    final url = Uri(
      scheme: 'tel',
      path: number,
    );
    try {
      log("launching $url");
      await launchUrl(url);
    } catch (e) {
      Get.snackbar(
        "error".tr,
        "error_call".tr,
        borderColor: CupertinoColors.systemGrey6,
        borderWidth: 1,
        backgroundColor: CupertinoColors.white,
      );
    }
  }
}
