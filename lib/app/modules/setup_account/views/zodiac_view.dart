import 'dart:developer';

import 'package:flutter/cupertino.dart';
// ignore: library_prefixes
import 'package:flutter/material.dart' as M;
import 'package:genz/app/constants/constants.dart';
import 'package:genz/app/modules/setup_account/controllers/setup_account_controller.dart';
import 'package:flutter_background_geolocation/flutter_background_geolocation.dart' as bg;

import 'package:get/get.dart';

import '../controllers/zodiac_controller.dart';

class ZodiacView extends GetView<ZodiacController> {
  const ZodiacView({super.key});
  @override
  Widget build(BuildContext context) {
    final setupController = Get.find<SetupAccountController>();
    return Obx(
      () => CupertinoPageScaffold(
        child: Column(
          children: [
            Expanded(
              flex: 1,
              child: Center(
                child: Text(
                  "3/3 ${"setupSteps".tr}",
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    // Display a CupertinoPicker with list of fruits.
                    onPressed: () => _showDialog(
                      CupertinoPicker(
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
                          setupController.zodiac.value =
                              Constants.zodiacs.keys.toList()[selectedItem];
                        },
                        children: List<Widget>.generate(Constants.zodiacs.keys.toList().length,
                            (int index) {
                          return Center(
                              child: Text("zodiac_${Constants.zodiacs.keys.toList()[index]}".tr));
                        }),
                      ),
                    ),
                    // This displays the selected fruit name.
                    child: Row(
                      children: [
                        Text(
                          "zodiac_${setupController.zodiac.value}".tr,
                          style: const TextStyle(fontSize: 22.0, color: CupertinoColors.black),
                        ),
                        const Icon(CupertinoIcons.chevron_down, color: CupertinoColors.black),
                      ],
                    ),
                  ),
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Text(
                        Constants.zodiacs[setupController.zodiac.value] ?? "",
                        style: const TextStyle(fontSize: 50),
                      ),
                      Positioned(
                        bottom: -35,
                        left: -25,
                        child: Text(
                          "makeThemCurious".tr,
                          style: const TextStyle(fontSize: 10),
                        ),
                      )
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 1,
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("allowLocation".tr),
                      const SizedBox(width: 10),
                      CupertinoSwitch(
                        value: setupController.allowLocation.value,
                        onChanged: (value) {
                          if (!setupController.allowLocation.value) {
                            showCupertinoDialog(
                              context: context,
                              builder: (context) => CupertinoAlertDialog(
                                title: Text("location".tr),
                                content: Text("bottomSheet_allowLocation".tr),
                                actions: [
                                  CupertinoDialogAction(
                                    child: Text("button_allow".tr),
                                    onPressed: () async {
                                      //var status = await Permission.location.status;
                                      final status = bg.BackgroundGeolocation.requestPermission();
                                      log("[requestPermission] status: $status");

                                      bg.ProviderChangeEvent providerState = await bg.BackgroundGeolocation.providerState;
                                      if (providerState.status == bg.ProviderChangeEvent.AUTHORIZATION_STATUS_ALWAYS) {
                                        setupController.allowLocation.value = true;
                                        Get.back();
                                      }else{
                                        Get.back();
                                      }
                                    },
                                  ),
                                  CupertinoDialogAction(
                                    child: Text("button_deny".tr),
                                    onPressed: () {
                                      Get.back();
                                    },
                                  ),
                                ],
                              ),
                            );
                          }
                        },
                        //activeTrackColor: Colors.lightGreenAccent,
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 69.0, right: 69.0, top: 40),
                    child: M.OutlinedButton(
                      onPressed: setupController.setup,
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
                          child: setupController.setupLoading.value
                              ? const CupertinoActivityIndicator()
                              : Text(
                                  'button_done'.tr,
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

  void _showDialog(Widget child) {
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
          child: child,
        ),
      ),
    );
  }
}
