import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:genz/app/constants/firebase.dart';
import 'package:genz/app/global/functions.dart';
import 'package:genz/app/models/user_model.dart';
import 'package:genz/app/modules/auth/controllers/account_controller.dart';
import 'package:genz/app/modules/auth/services/chat_service.dart';
import 'package:get/get.dart';

class UserService extends GetxController {
  static Stream<UserModel> fetchCurrentUserDataAsStream() {
    if (auth.currentUser == null) {
      if (kDebugMode) {
        Get.snackbar(
          "[Debug] Error",
          "tried to call fetchCurrentUserDataAsStream without a user or current user",
          borderColor: CupertinoColors.systemGrey6,
          borderWidth: 1,
          backgroundColor: CupertinoColors.white,
        );
      }
      return const Stream.empty();
    }
    return firebaseFirestore.collection('users').doc(auth.currentUser?.uid).snapshots().map(
        (event) => UserModel.fromFirestore(json: event.data()!, id: auth.currentUser?.uid ?? ""));
  }

  static Stream<UserModel> getUserStream(String userId) {
    return firebaseFirestore
        .collection('users')
        .doc(userId)
        .snapshots()
        .map((event) => UserModel.fromFirestore(json: event.data()!, id: userId));
  }

  static Future<UserModel> getCurrentUser() async {
    return firebaseFirestore
        .collection('users')
        .doc(auth.currentUser!.uid)
        .get()
        .then((event) => UserModel.fromFirestore(json: event.data()!, id: auth.currentUser!.uid));
  }

  static Future<UserModel> getUser(String userId) async {
    return firebaseFirestore
        .collection('users')
        .doc(userId)
        .get()
        .then((event) => UserModel.fromFirestore(json: event.data()!, id: auth.currentUser!.uid));
  }

  static Future<bool> checkIfUserExists(String userId) async {
    return firebaseFirestore.collection('users').doc(userId).get().then((value) => value.exists);
  }

  static Future updateCurrentUser(
      {required String name, required String email, required String phoneNumber}) async {
    return firebaseFirestore.collection('users').doc(auth.currentUser!.uid).update({
      'name': name,
      'email': email,
      'phone_number': phoneNumber,
    });
  }

  static Future<void> removeWink(String userId) async {
    firebaseFirestore.collection('users').doc(auth.currentUser!.uid).update({
      'current_winks': FieldValue.arrayRemove([userId]),
    });
  }

  static Future<void> winkBack(String userId) async {
    if (Get.find<AccountController>().userModel.value!.remainingWinks == 0) {
      Get.snackbar(
        'Error',
        'You have no winks left',
        borderColor: CupertinoColors.systemGrey6,
        borderWidth: 1,
        backgroundColor: CupertinoColors.white,
      );
      return;
    }
    // await showCupertinoModalPopup<PickedFile?>(
    //   context: Get.context!,
    //   builder: (BuildContext context) => CupertinoActionSheet(
    //     title: Text('wink'.tr),
    //     message: Text('winkOrStartChat'.tr),
    //     cancelButton: CupertinoActionSheetAction(
    //       onPressed: () {
    //         Navigator.pop(context);
    //       },
    //       child: Text('cancel'.tr),
    //     ),
    //     actions: <CupertinoActionSheetAction>[
    //       CupertinoActionSheetAction(
    //         /// This parameter indicates the action would be a default
    //         /// default behavior, turns the action's text to bold text.
    //         isDefaultAction: true,
    //         onPressed: () {
    //           _winkBackFirestore(userId);
    //           Get.back();
    //         },
    //         child: Text('onlyWink'.tr),
    //       ),
    //       CupertinoActionSheetAction(
    //         onPressed: () {
    _winkBackFirestore(userId);
    Get.back();
    ChatService.startChat(userId);
    //         },
    //         child: Text('startChat'.tr),
    //       ),
    //     ],
    //   ),
    // );
  }

  static Future<void> _winkBackFirestore(String userId) async {
    final user = await firebaseFirestore.collection('users').doc(auth.currentUser!.uid).get();
    if (user.data()?["unlimited"] ?? false) {
      user.reference.update(
        {
          'current_winks': FieldValue.arrayRemove([userId]),
        },
      );
    } else if (user.data()?["remaining_winks"] > 0) {
      user.reference.update(
        {
          'current_winks': FieldValue.arrayRemove([userId]),
          'remaining_winks': FieldValue.increment(-1),
        },
      );
    } else if ((user.data()?["premium_winks"] ?? 0) > 0) {
      user.reference.update(
        {
          'current_winks': FieldValue.arrayRemove([userId]),
          'premium_winks': FieldValue.increment(-1),
        },
      );
    } else {
      Get.snackbar(
        "warning".tr,
        "noWinksLeft".tr,
        borderColor: CupertinoColors.systemGrey6,
        borderWidth: 1,
        backgroundColor: CupertinoColors.white,
      );
      return;
    }
    await firebaseFirestore.collection('users').doc(userId).update({
      'winks_count': FieldValue.increment(1),
    });
    Functions.sendNotification(
      title: user.data()?["name"],
      body: "${user.data()?["name"]} ${"winkedBackAtYou".tr}",
      token: await firebaseFirestore
          .collection('users')
          .doc(userId)
          .get()
          .then((value) => value.data()?["fcm_token"]),
    );
  }
}
