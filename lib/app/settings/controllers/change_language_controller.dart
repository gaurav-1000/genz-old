import 'package:get/get.dart';

class ChangeLanguageController extends GetxController {
  RxString selectedLanguage = (Get.locale?.languageCode ?? "en").obs;
}
