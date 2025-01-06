import 'package:get/get.dart';

import '../controllers/otpcode_controller.dart';

class OtpcodeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<OtpcodeController>(
      () => OtpcodeController(),
    );
  }
}
