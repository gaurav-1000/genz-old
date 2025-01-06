import 'package:genz/app/modules/auth/controllers/auth_controller.dart';
import 'package:get/get.dart';

import '../controllers/chats_controller.dart';
import '../controllers/home_controller.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.find<AuthController>().isHome.value = true;
    Get.put<HomeController>(HomeController());
    Get.put<ChatsController>(ChatsController());
  }
}
