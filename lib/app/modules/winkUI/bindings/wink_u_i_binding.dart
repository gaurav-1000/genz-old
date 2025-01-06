import 'package:get/get.dart';

import '../controllers/wink_u_i_controller.dart';

class WinkUIBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<WinkUIController>(
      () => WinkUIController(),
    );
  }
}
