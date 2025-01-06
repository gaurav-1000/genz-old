import 'package:flutter/cupertino.dart';
import 'package:genz/app/modules/auth/controllers/auth_controller.dart';
import 'package:get/get.dart';

class LoginController extends GetxController {
  final phoneController = TextEditingController().obs;
  RxBool loading = false.obs;

  void login() async {
    if (loading.value) return;
    loading.value = true;
    await Get.find<AuthController>().loginWithPhone("+46${phoneController.value.text}", false);
  }
}
