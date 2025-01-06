import 'package:flutter/cupertino.dart';
import 'package:genz/app/constants/firebase.dart';
import 'package:genz/app/modules/auth/controllers/account_controller.dart';
import 'package:get/get.dart';

class EditNameController extends GetxController {
  final firstNameController = TextEditingController().obs;
  final lastNameController = TextEditingController().obs;

  Future<void> save() async {
    firebaseFirestore.collection('users').doc(auth.currentUser!.uid).update(
      {
        'name': '${firstNameController.value.text} ${lastNameController.value.text}',
      },
    );
    Get.back(id: 1);
  }

  @override
  void onInit() {
    super.onInit();
    final accountController = Get.find<AccountController>();
    firstNameController.value.text = accountController.userModel.value?.name?.split(' ')[0] ?? '';
    final wordL = accountController.userModel.value?.name?.split(' ') ?? [];
    lastNameController.value.text = wordL.sublist(1, wordL.length).join(" ");
  }
}
