import 'package:flutter/cupertino.dart';
import 'package:genz/app/constants/constants.dart';
import 'package:genz/app/modules/home/controllers/home_controller.dart';
import 'package:genz/app/settings/controllers/change_language_controller.dart';

import 'package:get/get.dart';

class ChangeLanguageView extends StatelessWidget {
  const ChangeLanguageView({super.key});
  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ChangeLanguageController());
    return PopScope(
      onPopInvoked: (popped) async {
        if(popped){
          // this is a little hack because GetX forgets to update the language inside a nested navigator
          Get.find<HomeController>().pageController.value.jumpToPage(PageIndex.list.index);
          await Future.delayed(const Duration(milliseconds: 100));
          Get.find<HomeController>().pageController.value.jumpToPage(PageIndex.settings.index);
        }
      },
      child: CupertinoPageScaffold(
        navigationBar: CupertinoNavigationBar(
          middle: Text('scaffoldTitle_changeLang'.tr),
        ),
        child: SafeArea(
          bottom: false,
          child: Obx(
            () => ListView(
              children: [
                GestureDetector(
                  onTap: () {
                    controller.selectedLanguage.value = "en";
                    Get.updateLocale(const Locale("en", "US"));
                  },
                  child: CupertinoListTile(
                    leading: CupertinoRadio(
                      value: "en",
                      groupValue: controller.selectedLanguage.value,
                      onChanged: (value) {
                        if (value == null) return;
                        controller.selectedLanguage.value = value;
                        Get.updateLocale(const Locale("en", "US"));
                      },
                    ),
                    title: const Text("English"),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    controller.selectedLanguage.value = "sv";
                    Get.updateLocale(const Locale("sv", "SE"));
                  },
                  child: CupertinoListTile(
                    leading: CupertinoRadio(
                      value: "sv",
                      groupValue: controller.selectedLanguage.value,
                      onChanged: (value) {
                        if (value == null) return;
                        controller.selectedLanguage.value = value;
                        Get.updateLocale(const Locale("sv", "SE"));
                      },
                    ),
                    title: const Text("Svenska"),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
