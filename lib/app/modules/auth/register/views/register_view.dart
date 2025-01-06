import 'package:flutter/cupertino.dart';

import 'package:get/get.dart';

import '../controllers/register_controller.dart';

class RegisterView extends GetView<RegisterController> {
  const RegisterView({super.key});
  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
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
            largeTitle: Text('register'.tr),
          ),
          SliverFillRemaining(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Text('1/3 ${'setupSteps'.tr}'),
                Text("putInformationHere".tr),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: CupertinoTextField(
                    controller: controller.phoneController.value,
                    placeholder: "phoneNumber".tr,
                    keyboardType: TextInputType.phone,
                    prefix: const Text(" +46"),
                  ),
                ),
                Text(
                  "registerLegalText".tr,
                  textAlign: TextAlign.center,
                ),
                CupertinoButton.filled(
                  onPressed: controller.register,
                  child: Text('register'.tr),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
