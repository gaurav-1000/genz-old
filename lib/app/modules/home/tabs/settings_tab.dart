import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:genz/app/constants/constants.dart';
import 'package:genz/app/constants/firebase.dart';
import 'package:genz/app/modules/auth/controllers/account_controller.dart';
import 'package:genz/app/modules/auth/controllers/auth_controller.dart';
import 'package:genz/app/modules/home/controllers/home_controller.dart';
import 'package:genz/app/modules/home/controllers/purchase_controller.dart';
import 'package:genz/app/settings/views/change_language_view.dart';
import 'package:genz/app/settings/views/edit_name_view.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsTab extends StatelessWidget {
  const SettingsTab({super.key});
  @override
  Widget build(BuildContext context) {
    return PopScope(
      onPopInvoked: (popped) async {
        if(popped){
          Get.back(id: 1);
        }
      },
      child: Navigator(
        key: Get.nestedKey(1),
        onGenerateRoute: (RouteSettings settings) {
          return GetPageRoute<void>(
            settings: settings,
            page: () => home(context),
          );
        },
      ),
    );
  }

  Widget home(BuildContext context) {
    final controller = Get.find<HomeController>();
    final accountController = Get.find<AccountController>();
    final purchaseController = Get.find<PurchaseController>();
    purchaseController.loadProducts();
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text('scaffoldTitle_settings'.tr),
      ),
      child: SafeArea(
        child: Container(
          color: CupertinoColors.systemGroupedBackground,
          child: ListView(
            children: [
              Obx(
                () => GestureDetector(
                  onTap: controller.selectProfilePicture,
                  child: Container(
                    color: CupertinoColors.white,
                    child: accountController.userModel.value == null ||
                            accountController.userModel.value?.imageUrl == null
                        ? const SizedBox(child: Text("Error Loading User image"))
                        : controller.pickedFilePath.value == null
                            ? CachedNetworkImage(
                                imageUrl: accountController.userModel.value?.imageUrl ?? "",
                                width: double.infinity,
                                height: 300,
                                placeholder: (context, url) => Shimmer.fromColors(
                                  baseColor: CupertinoColors.systemGrey6,
                                  highlightColor: CupertinoColors.systemGrey5,
                                  child: const SizedBox(
                                    width: double.infinity,
                                    height: 300,
                                  ),
                                ),
                              )
                            : Image.file(
                                File(controller.pickedFilePath.value!),
                                width: double.infinity,
                                height: 300,
                              ),
                  ),
                ),
              ),
              CupertinoListSection(
                header: Text('header_account'.tr),
                children: [
                  Obx(
                    () => customListTile(
                      icon: CupertinoIcons.person,
                      title: accountController.userModel.value?.name ?? 'settings_error_name'.tr,
                      subtitle: 'settings_name'.tr,
                      onTap: () async {
                        Get.to(const EditNameView(), id: 1);
                      },
                    ),
                  ),
                  Obx(
                    () => GestureDetector(
                      onTap: (){
                        showCupertinoModalPopup<void>(
                          context: Get.context!,
                          builder: (BuildContext context) => Container(
                            height: 216,
                            padding: const EdgeInsets.only(top: 6.0),
                            // The Bottom margin is provided to align the popup above the system navigation bar.
                            margin: EdgeInsets.only(
                              bottom: MediaQuery.of(context).viewInsets.bottom,
                            ),
                            // Provide a background color for the popup.
                            color: CupertinoColors.systemBackground.resolveFrom(context),
                            // Use a SafeArea widget to avoid system overlaps.
                            child: SafeArea(
                              top: false,
                              child: Column(
                                children: [
                                  Expanded(
                                    child: CupertinoPicker(
                                      magnification: 1.22,
                                      squeeze: 1.2,
                                      useMagnifier: true,
                                      itemExtent: 32.0,
                                      // This sets the initial item.
                                      scrollController: FixedExtentScrollController(
                                        initialItem: 0,
                                      ),
                                      // This is called when selected item is changed.
                                      onSelectedItemChanged: (int selectedItem) {
                                        controller.settingsSelectedZodiac.value =
                                        Constants.zodiacs.keys.toList()[selectedItem];
                                      },
                                      children: List<Widget>.generate(
                                        Constants.zodiacs.keys.toList().length,
                                            (int index) {
                                          return Center(
                                            child: Text(
                                                "zodiac_${Constants.zodiacs.keys.toList()[index]}"
                                                    .tr),
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                  CupertinoButton(
                                    onPressed: () async {
                                      Get.find<AccountController>().ref.update({
                                        "zodiac": controller.settingsSelectedZodiac.value,
                                      });
                                      HapticFeedback.selectionClick();
                                      Get.back();
                                    },
                                    child: Text('done'.tr),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                      child: CupertinoListTile(
                        leading: Text(
                          Constants.zodiacs[Get.find<AccountController>().zodiac] ?? "",
                        ),
                        subtitle: Text("zodiacSign".tr),
                        title: Text(
                          accountController.userModel.value?.zodiac == null
                              ? "none".tr
                              : "zodiac_${Get.find<AccountController>().zodiac}".tr,
                          style: const TextStyle(fontSize: 20),
                        ),
                        trailing: const SizedBox.shrink(),
                      ),
                    ),
                  ),
                  Obx(
                    () => customListTile(
                      icon: CupertinoIcons.phone,
                      title: accountController.userModel.value?.phoneNumber ??
                          'settings_error_phone'.tr,
                      subtitle: 'settings_phone'.tr,
                      onTap: () async {},
                    ),
                  ),
                ],
              ),
              if (purchaseController.products.isNotEmpty)
              Obx(
                () => CupertinoListSection(
                  children: [
                    for (final product in purchaseController.products)
                      customListTile(
                        // add a fitting icon for a premium purchase
                        icon: CupertinoIcons.money_dollar,
                        title: product.title,
                        subtitle: product.description,
                        trailing: CupertinoButton(
                          onPressed: () => purchaseController.purchaseProduct(product.identifier),
                          child: purchaseController.purchaseLoading.value
                              ? const CupertinoActivityIndicator()
                              : Text(product.priceString),
                        ),
                      ),
                  ],
                ),
              ),
              CupertinoListSection(
                children: [
                  customListTile(
                    icon: CupertinoIcons.globe,
                    title: "currentLang".tr,
                    subtitle: "language".tr,
                    onTap: () async {
                      Get.to(const ChangeLanguageView(), id: 1);
                    },
                  ),
                  Obx(
                    () => customListTile(
                      icon: CupertinoIcons.moon_stars,
                      title: "Ghost mode",
                      subtitle: "hideLocation".tr,
                      trailing: CupertinoSwitch(
                        value: accountController.userModel.value?.ghostMode ?? false,
                        onChanged: controller.toggleGhost,
                      ),
                    ),
                  ),
                  Obx(
                    () => customListTile(
                      icon: CupertinoIcons.circle_grid_hex_fill,
                      title: "Don't use Active Periods",
                      subtitle: "DEGUG: make App always active",
                      trailing: CupertinoSwitch(
                        value: !controller.useActivePeriods.value,
                        onChanged: (val) =>
                            controller.useActivePeriods.value = !controller.useActivePeriods.value,
                      ),
                    ),
                  ),
                  // Obx(
                  //   () => customListTile(
                  //     icon: CupertinoIcons.location,
                  //     title: "Custom Location Marker",
                  //     subtitle:
                  //         "Use a custom location marker instead of the default GoogleMaps marker",
                  //     trailing: CupertinoSwitch(
                  //         value: controller.customLocationMarker.value,
                  //         onChanged: controller.toggleLocationMarker),
                  //   ),
                  // ),
                ],
              ),
              CupertinoButton(
                  onPressed: () {
                    launchUrl(Uri.parse('https://generationzab.me/privacy-policy-and-terms-of-service/'));
                  },
                  child: const Text("Privacy Policy")),
              CupertinoButton(
                  onPressed: () {
                    launchUrl(Uri.parse('https://generationzab.me/privacy-policy-and-terms-of-service/'));
                  },
                  child: const Text("Terms of Service")),
              CupertinoListSection(
                children: [
                  customListTile(
                    icon: CupertinoIcons.square_arrow_right,
                    title: "settings_logout".tr,
                    onTap: () async {
                      firebaseFirestore
                          .collection('users')
                          .doc(auth.currentUser?.uid)
                          .update({"fcm_token": null});
                      await auth.signOut();
                      await auth.signOut();
                    },
                  ),
                ],
              ),
              CupertinoListSection(
                children: [
                  customListTile(
                    icon: CupertinoIcons.trash,
                    title: "settings_deleteAccount".tr,
                    color: CupertinoColors.destructiveRed,
                    onTap: Get.find<AuthController>().requestAccountDeletion,
                  ),
                ],
              ),
              const SizedBox(height: Constants.navBarHeight),
            ],
          ),
        ),
      ),
    );
  }

  Widget customListTile(
      {required IconData icon,
      required String title,
      String? subtitle,
      Widget? trailing,
      Color? color,
      void Function()? onTap}) {
    return CupertinoListTile(
      leading: Icon(
        icon,
        color: color ?? CupertinoColors.black,
      ),
      title: Text(
        title,
        style: TextStyle(color: color ?? CupertinoColors.black),
      ),
      subtitle: subtitle == null
          ? null
          : Text(subtitle, style: const TextStyle(fontSize: 12, color: CupertinoColors.systemGrey)),
      trailing: trailing,
      onTap: onTap,
    );
  }
}
