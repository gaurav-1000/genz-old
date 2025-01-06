import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:genz/app/constants/firebase.dart';
import 'package:genz/app/global/log.dart';
import 'package:genz/app/modules/auth/controllers/account_controller.dart';
import 'package:genz/app/modules/auth/login/controllers/login_controller.dart';
import 'package:genz/app/routes/app_pages.dart';
import 'package:get/get.dart';
import 'package:flutter/cupertino.dart';

class AuthController extends GetxController {
  RxBool isHome = false.obs;
  RxBool requestAccountDeletionLoading = false.obs;

  // Future<bool> checkIfPhoneNumberUsed(String number) async {
  //   var x =
  //       await firebaseFirestore.collection("users").where("phoneNumber", isEqualTo: number).get();

  //   if (x.docs.isNotEmpty) {
  //     return true;
  //   } else {
  //     return false;
  //   }
  // }

  Future<void> loginWithPhone(String phoneNumber, bool delete) async {
    try {
      Log.d("loginWithPhone $phoneNumber");
      auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: (c) {
          log("verificationCompleted");
        },
        verificationFailed: (FirebaseAuthException e) {
          Log.e(e);
          Log.e("Message: ${e.message}");
          Log.e("code: ${e.code}");
          Get.find<LoginController>().loading.value = false;
          log(e.message ?? e.code);
          Get.snackbar(
            "Error",
            e.message ?? e.code,
            borderColor: CupertinoColors.systemGrey6,
            borderWidth: 1,
            backgroundColor: CupertinoColors.white,
          );
        },
        codeSent: (String verificationId, int? resendToken) async {
          Get.toNamed(Routes.OTPCODE, arguments: {
            "verificationId": verificationId,
            "resendToken": resendToken ?? -1,
            "phoneNumber": phoneNumber,
            "delete": delete,
          });
          return;
        },
        codeAutoRetrievalTimeout: (String verificationId) {},
      );
    } on FirebaseAuthException catch (e) {
      Log.e(e);
      Get.snackbar(
        "Error",
        e.code,
        borderColor: CupertinoColors.systemGrey6,
        borderWidth: 1,
        backgroundColor: CupertinoColors.white,
      );
    } catch (e) {
      Log.e(e);
      Get.snackbar(
        "Error",
        e.toString(),
        borderColor: CupertinoColors.systemGrey6,
        borderWidth: 1,
        backgroundColor: CupertinoColors.white,
      );
    }
  }

  Future<void> logout() async {
    try {
      var accountController = Get.find<AccountController>();
      accountController.ref.update({"fcm_token": null});
      Get.offAllNamed(Routes.LOGIN);
      accountController.userModel.value = null;
      await auth.signOut();
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
    }
  }

  Future<void> requestAccountDeletion() async {
    if (requestAccountDeletionLoading.value) {
      return;
    }
    requestAccountDeletionLoading.value = true;
    try {
      loginWithPhone(auth.currentUser!.phoneNumber!, true);
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
    } finally {
      requestAccountDeletionLoading.value = false;
    }
  }

  Future<void> deleteUser() async {
    try {
      firebaseFirestore.collection("users").doc(auth.currentUser!.uid).delete();
      await auth.currentUser!.delete();
      Get.offAllNamed(Routes.LOGIN);
      Get.delete<AccountController>();
      await auth.signOut();
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
    }
  }
}
