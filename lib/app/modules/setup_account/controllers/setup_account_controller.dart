import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:genz/app/constants/firebase.dart';
import 'package:genz/app/global/functions.dart';
import 'package:genz/app/modules/auth/controllers/account_controller.dart';
import 'package:genz/app/routes/app_pages.dart';
import 'package:get/get.dart';
import 'package:flutter_background_geolocation/flutter_background_geolocation.dart' as bg;

class SetupAccountController extends GetxController {
  //Rx<PlatformFile?> pickedFile = Rx<PlatformFile?>(null);
  Rx<String?> pickedFilePath = Rx<String?>(null);
  Rx<File?> thumbnail = Rx<File?>(null);
  final usernameController = TextEditingController().obs;
  final phoneNumberController = TextEditingController().obs;
  RxString zodiac = "aries".obs;
  RxBool allowLocation = false.obs;
  RxBool setupLoading = false.obs;

  late final AppLifecycleListener _listener;

  @override
  void onInit() {
    // Initialize the AppLifecycleListener class and pass callbacks
    _listener = AppLifecycleListener(
      onStateChange: _onStateChanged,
    );
    super.onInit();
  }

  @override
  void dispose() {
    // Do not forget to dispose the listener
    _listener.dispose();

    super.dispose();
  }

  // Listen to the app lifecycle state changes
  Future<void> _onStateChanged(AppLifecycleState state) async {
    switch (state) {
      case AppLifecycleState.detached:
        break;
      case AppLifecycleState.resumed:
        bg.ProviderChangeEvent providerState = await bg.BackgroundGeolocation.providerState;
        if (providerState.status == bg.ProviderChangeEvent.AUTHORIZATION_STATUS_ALWAYS) {
          allowLocation.value = true;
        }
        break;
      case AppLifecycleState.inactive:
        break;
      case AppLifecycleState.hidden:
        break;
      case AppLifecycleState.paused:
        break;
    }
  }

  Future<void> selectImg() async {
    List<File>? images;
    try {
      images = await Functions.pickImage(title: "pickImage".tr, text: "pickImageText".tr);
    } catch (_) {
      Get.snackbar(
        "error".tr,
        "unsupportedFileType".tr,
        borderColor: CupertinoColors.systemGrey6,
        borderWidth: 1,
        backgroundColor: CupertinoColors.white,
      );
      Get.back();
      return;
    }
    if (images == null) {
      return;
    }
    thumbnail.value = images[0];
    pickedFilePath.value = images[1].path;
  }

  Future<void> setup() async {
    if (setupLoading.value) {
      return;
    }
    setupLoading.value = true;
    // final authController = Get.find<AuthController>();

    if (pickedFilePath.value == null ||
        usernameController.value.text.isEmpty ||
        zodiac.value.isEmpty) {
      Get.snackbar(
        "Error",
        "error_fillAllFields".tr,
        borderColor: CupertinoColors.systemGrey6,
        borderWidth: 1,
        backgroundColor: CupertinoColors.white,
      );
      setupLoading.value = false;
      return;
    }

    if (!allowLocation.value) {
      Get.snackbar(
        "Error",
        "error_allowLocation".tr,
        borderColor: CupertinoColors.systemGrey6,
        borderWidth: 1,
        backgroundColor: CupertinoColors.white,
      );
      setupLoading.value = false;
      return;
    }

    // upload the profile picture
    final path = 'userContent/${auth.currentUser!.uid}/profile.png';
    final tPath = 'userContent/${auth.currentUser!.uid}/profile_thumbnail.png';
    final file = File(pickedFilePath.value!);
    firebaseStorage.ref(tPath).putFile(thumbnail.value!).whenComplete(
          () => firebaseStorage.ref(path).putFile(file).whenComplete(
            () async {
              try {
                await firebaseFirestore.collection("users").doc(auth.currentUser!.uid).set(
                  {
                    "phone_number": auth.currentUser!.phoneNumber,
                    'name': usernameController.value.text,
                    'zodiac': zodiac.value,
                    'image_url': await firebaseStorage.ref(path).getDownloadURL(),
                    'thumbnail': await firebaseStorage.ref(tPath).getDownloadURL(),
                    "winks_count": 0,
                    "remaining_winks": 30,
                    "pinned_users": [],
                    "current_winks": [],
                    "winked_to": [],
                  },
                );
              } catch (e) {
                Get.snackbar(
                  "Error",
                  e.toString(),
                  borderColor: CupertinoColors.systemGrey6,
                  borderWidth: 1,
                  backgroundColor: CupertinoColors.white,
                );
                return;
              }
              Get.put<AccountController>(AccountController(), permanent: true);
              Get.offAllNamed(Routes.HOME);
            },
          ),
        );
  }
}
