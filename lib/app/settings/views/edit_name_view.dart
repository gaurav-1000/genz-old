import 'package:flutter/cupertino.dart';

import 'package:get/get.dart';

import '../controllers/edit_name_controller.dart';

class EditNameView extends GetView<EditNameController> {
  const EditNameView({super.key});
  @override
  Widget build(BuildContext context) {
    final controller = Get.put(EditNameController());
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text('scaffoldTitle_editName'.tr),
      ),
      resizeToAvoidBottomInset: false,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.only(top: 10, left: 10, right: 10, bottom: 10),
          child: SizedBox(
            height: 300,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                CupertinoTextField(
                  controller: controller.firstNameController.value,
                  placeholder: "textField_firstName".tr,
                ),
                const SizedBox(height: 18),
                CupertinoTextField(
                  controller: controller.lastNameController.value,
                  placeholder: 'textField_lastName'.tr,
                ),
                const SizedBox(height: 18),
                CupertinoButton.filled(
                  onPressed: controller.save,
                  child: Text('save'.tr),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
