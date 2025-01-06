import 'dart:developer';
import 'dart:io';

import 'package:flutter/cupertino.dart';
// ignore: library_prefixes
import 'package:flutter/material.dart' as M;
import 'package:genz/app/routes/app_pages.dart';

import 'package:get/get.dart';

import '../controllers/setup_account_controller.dart';

class SetupAccountView extends GetView<SetupAccountController> {
  const SetupAccountView({super.key});
  @override
  Widget build(BuildContext context) {
    log("rerendered");
    return CupertinoPageScaffold(
      child: SingleChildScrollView(
        physics: const ClampingScrollPhysics(),
        child: SizedBox(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          child: Column(
            children: [
              Expanded(
                flex: 2,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      flex: 2,
                      child: Center(
                        child: Text(
                          "2/3 ${"setupSteps".tr}",
                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Text(
                        "chooseProfilePicture".tr,
                      ),
                    ),
                    Expanded(
                      flex: 3,
                      child: GestureDetector(
                        onTap: controller.selectImg,
                        child: Stack(
                          children: [
                            Center(
                              child: Obx(
                                () => controller.pickedFilePath.value != null
                                    ? M.CircleAvatar(
                                        radius: 160,
                                        backgroundImage: FileImage(
                                          File(controller.pickedFilePath.value!),
                                        ),
                                      )
                                    : const M.CircleAvatar(
                                        radius: 160,
                                        backgroundImage:
                                            AssetImage("assets/images/default_profile.png"),
                                      ),
                              ),
                            ),
                            Positioned.fill(
                              child: Align(
                                alignment: Alignment.center,
                                child: Transform.scale(
                                  scale: 2,
                                  child: const Icon(
                                    CupertinoIcons.photo,
                                    color: CupertinoColors.black,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 56.0, right: 56.0, top: 10.0),
                      child: CupertinoTextField(
                        controller: controller.usernameController.value,
                        placeholder: "textField_putName".tr,
                        textAlign: TextAlign.center,
                        decoration: const BoxDecoration(
                          border: Border(
                            left: BorderSide(
                              color: CupertinoColors.black,
                              width: 1,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                flex: 1,
                child: Padding(
                  padding: const EdgeInsets.only(left: 69.0, right: 69.0, top: 100),
                  child: Column(
                    children: [
                      M.OutlinedButton(
                        onPressed: () {
                          if (controller.pickedFilePath.value == null ||
                              controller.usernameController.value.text.isEmpty) {
                            Get.snackbar(
                              "error".tr,
                              "error_fillAllFields".tr,
                              snackPosition: SnackPosition.BOTTOM,
                              borderColor: CupertinoColors.systemGrey6,
                              borderWidth: 1,
                              backgroundColor: CupertinoColors.white,
                            );
                            return;
                          }
                          Get.toNamed(Routes.ZODIAC);
                        },
                        style: M.OutlinedButton.styleFrom(
                          shape: const StadiumBorder(),
                          side: const BorderSide(
                            color: CupertinoColors.black,
                            width: 1,
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12.0),
                          child: Center(
                            child: Text(
                              'button_continue'.tr,
                              style: const TextStyle(
                                color: CupertinoColors.black,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
