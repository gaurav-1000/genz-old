import 'package:flutter/cupertino.dart';
//import 'package:genz/app/modules/auth/controllers/auth_controller.dart';
import 'package:get/get.dart';

class RegisterController extends GetxController {
  final phoneController = TextEditingController().obs;

  void register() async {
    //var authController = Get.find<AuthController>();
    // await authController.register(
    //   emailController.value.text,
    //   passwordController.value.text,
    // );
    //await authController.registerWithPhone("+46${phoneController.value.text}");
  }
}
