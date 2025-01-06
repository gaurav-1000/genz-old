import 'package:get/get.dart';

import '../controllers/zodiac_controller.dart';

class ZodiacBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ZodiacController>(
      () => ZodiacController(),
    );
  }
}
