import 'package:flutter/cupertino.dart';
import 'package:genz/app/constants/firebase.dart';
import 'package:genz/app/modules/auth/controllers/account_controller.dart';
import 'package:get/get.dart';

class EditPhoneController extends GetxController {
  final phoneController = TextEditingController().obs;

  Future<void> save() async {
    firebaseFirestore.collection('users').doc(auth.currentUser!.uid).update(
      {
        'phone_number': phoneController.value.text,
      },
    );
    Get.back(id: 1);
  }

  @override
  void onInit() {
    super.onInit();
    final accountController = Get.find<AccountController>();
    phoneController.value.text = accountController.userModel.value?.phoneNumber ?? "";
  }
}
