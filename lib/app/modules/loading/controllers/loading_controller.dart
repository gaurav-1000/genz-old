import 'dart:developer';

import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:genz/app/constants/firebase.dart';
import 'package:genz/app/modules/auth/controllers/account_controller.dart';
import 'package:genz/app/modules/auth/services/user_service.dart';
import 'package:genz/app/routes/app_pages.dart';
import 'package:get/get.dart';

class LoadingController extends GetxController {
  final count = 0.obs;
  @override
  void onInit() async {
    if (auth.currentUser == null) {
      log("Going to welcome because error");
      Get.offAllNamed(Routes.WELCOME);
      FlutterNativeSplash.remove();
      return;
    }
    final userExists = await UserService.checkIfUserExists(auth.currentUser!.uid);
    if (!userExists) {
      Get.delete<AccountController>(force: true);
      log("Going to setup", name: "LoadingController");
      Get.offAllNamed(Routes.SETUP_ACCOUNT);
      FlutterNativeSplash.remove();
      return;
    } else {
      try {
        if (Get.find<AccountController>().id == auth.currentUser!.uid) {
          return;
        }
      } catch (_) {}
      await Get.delete<AccountController>(force: true);
      Get.put<AccountController>(AccountController(), permanent: true);
      log("Going to home", name: "LoadingController");
      Get.offAllNamed(Routes.HOME);
      FlutterNativeSplash.remove();
    }
    super.onInit();
  }
}
