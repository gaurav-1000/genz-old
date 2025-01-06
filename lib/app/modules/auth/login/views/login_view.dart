import 'package:flutter/cupertino.dart';
// ignore: library_prefixes
import 'package:flutter/material.dart' as M;

import 'package:get/get.dart';

import '../controllers/login_controller.dart';

class LoginView extends GetView<LoginController> {
  const LoginView({super.key});
  @override
  Widget build(BuildContext context) {
    final controller = Get.put(LoginController());
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
              largeTitle: Text('${'login'.tr} 🥰'),
            ),
            SliverFillRemaining(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Text("putInformationHere".tr),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 56.0),
                    child: CupertinoTextField(
                      controller: controller.phoneController.value,
                      placeholder: "phoneNumber".tr,
                      keyboardType: TextInputType.phone,
                      prefix: const Text(" +46"),
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
                      onPressed: controller.login,
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
                                  'login'.tr,
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
