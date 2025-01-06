import 'package:flutter/cupertino.dart';

import 'package:get/get.dart';

import '../controllers/edit_bio_controller.dart';

class EditBioView extends StatelessWidget {
  const EditBioView({super.key});
  @override
  Widget build(BuildContext context) {
    final controller = Get.put(EditBioController());
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text('scaffoldTitle_editBio'.tr),
      ),
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
                  controller: controller.bioController.value,
                  minLines: 3,
                  maxLines: 4,
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
