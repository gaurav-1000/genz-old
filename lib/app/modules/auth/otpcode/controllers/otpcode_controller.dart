import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:genz/app/constants/firebase.dart';
import 'package:genz/app/modules/auth/controllers/auth_controller.dart';
import 'package:get/get.dart';

class OtpcodeController extends GetxController {
  var codeController = TextEditingController().obs;
  RxBool loading = false.obs;

  Future<void> verify() async {
    if (loading.value) return;
    loading.value = true;
    try {
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
          verificationId: Get.arguments["verificationId"], smsCode: codeController.value.text);
      await auth.signInWithCredential(credential);
      if (Get.arguments["delete"] ?? false) {
        await Get.find<AuthController>().deleteUser();
      }
    } on FirebaseAuthException catch (e) {
      Get.snackbar(
        "Error",
        e.code,
        borderColor: CupertinoColors.systemGrey6,
        borderWidth: 1,
        backgroundColor: CupertinoColors.white,
      );
    } catch (e) {
      Get.snackbar(
        "Error",
        e.toString(),
        borderColor: CupertinoColors.systemGrey6,
        borderWidth: 1,
        backgroundColor: CupertinoColors.white,
      );
      rethrow;
    } finally {
      loading.value = false;
    }
  }
}
