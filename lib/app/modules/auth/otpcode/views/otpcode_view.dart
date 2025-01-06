import 'dart:developer';

import 'package:flutter/cupertino.dart';
// ignore: library_prefixes
import 'package:flutter/material.dart' as M;

import 'package:get/get.dart';

import '../controllers/otpcode_controller.dart';

class OtpcodeView extends GetView<OtpcodeController> {
  const OtpcodeView({super.key});
  @override
  Widget build(BuildContext context) {
    inspect(Get.arguments);
    bool delete;
    try {
      delete = Get.arguments["delete"] ?? false;
    } catch (e) {
      delete = false;
    }
    return Obx(
      () => CupertinoPageScaffold(
        child: CustomScrollView(
          slivers: [
            CupertinoSliverNavigationBar(
              leading: GestureDetector(
                child: const Icon(CupertinoIcons.back),
                onTap: () => Get.back(),
              ),
              // This title is visible in both collapsed and expanded states.
              // When the "middle" parameter is omitted, the widget provided
              // in the "largeTitle" parameter is used instead in the collapsed state.
              largeTitle: Text('${'scaffoldTitle_otpCode'.tr} 🥰'),
            ),
            SliverFillRemaining(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 56.0),
                    child: Text(
                      (Get.arguments["delete"] ?? false)
                          ? "enterOTPDelete".tr
                          : "pleaseEnterOTP".tr,
                      textAlign: TextAlign.center,
                    ),
                  ),
                  SizedBox(
                    width: 100,
                    child: CupertinoTextField(
                      controller: controller.codeController.value,
                      placeholder: "code".tr,
                      keyboardType: TextInputType.number,
                      maxLength: 6,
                      textAlign: TextAlign.center,
                      decoration: const BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: CupertinoColors.systemGrey,
                            width: 1,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 69.0),
                    child: M.OutlinedButton(
                      onPressed: controller.verify,
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
                          child: controller.loading.value
                              ? const CupertinoActivityIndicator()
                              : Text(
                                  delete ? 'button_deleteAccount'.tr : 'button_done'.tr,
                                  style: const TextStyle(
                                    color: CupertinoColors.black,
                                    fontSize: 16,
                                  ),
                                ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
