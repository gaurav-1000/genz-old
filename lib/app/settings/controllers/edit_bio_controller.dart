import 'package:flutter/cupertino.dart';
import 'package:genz/app/constants/firebase.dart';
import 'package:genz/app/modules/auth/controllers/account_controller.dart';
import 'package:get/get.dart';

class EditBioController extends GetxController {
  final bioController = TextEditingController().obs;

  Future<void> save() async {
    firebaseFirestore.collection('users').doc(auth.currentUser!.uid).update(
      {
        'bio': bioController.value.text,
      },
    );
    Get.back(id: 1);
  }

  @override
  void onInit() {
    super.onInit();
    final accountController = Get.find<AccountController>();
    bioController.value.text = accountController.userModel.value?.bio ?? "";
  }
}
