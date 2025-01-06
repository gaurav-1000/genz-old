import 'package:get/get.dart';

import '../controllers/setup_account_controller.dart';

class SetupAccountBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<SetupAccountController>(
      SetupAccountController(),
    );
  }
}
