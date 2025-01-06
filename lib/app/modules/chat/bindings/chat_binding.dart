import 'package:genz/app/modules/home/controllers/home_controller.dart';
import 'package:get/get.dart';

import '../controllers/chat_controller.dart';

class ChatBinding extends Bindings {
  @override
  void dependencies() {
    Get.find<HomeController>().updateUnreadMessages();
    Get.lazyPut<ChatController>(
      () => ChatController(),
    );
  }
}
