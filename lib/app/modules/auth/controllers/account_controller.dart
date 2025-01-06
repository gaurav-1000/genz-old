import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:genz/app/constants/firebase.dart';
import 'package:genz/app/models/user_model.dart';
import 'package:genz/app/modules/auth/services/user_service.dart';
import 'package:get/get.dart';

class AccountController extends GetxController {
  Rx<UserModel?> userModel = Rx<UserModel?>(null);

  String get id => userModel.value?.id ?? "";
  String get name => userModel.value?.name ?? "";
  String get phoneNumber => userModel.value?.phoneNumber ?? "";
  DocumentReference<Map<String, dynamic>> get ref => firebaseFirestore.collection("users").doc(id);
  String get email => userModel.value?.email ?? "";
  String get imageUrl => userModel.value?.imageUrl ?? "";
  String get thumbnail => userModel.value?.thumbnail ?? "";
  CustomPosition get position => userModel.value?.position ?? CustomPosition();
  int get winksCount => userModel.value?.winksCount ?? -1;
  int get premiumWinks => userModel.value?.premiumWinks ?? 0;
  int get remainingWinks => userModel.value?.remainingWinks ?? 0;
  List<PinnedUser> get pinnedUsers => userModel.value?.pinnedUsers ?? [];
  List<String> get currentWinks => userModel.value?.currentWinks ?? [];
  String? get bio => userModel.value?.bio;
  bool get ghostMode => userModel.value?.ghostMode ?? false;
  List<String> get winkedTo => userModel.value?.winkedTo ?? [];
  String get zodiac => userModel.value?.zodiac ?? "aries";
  PinnedInfo get pinnedInfo =>
      userModel.value?.pinnedInfo ?? PinnedInfo(day: Timestamp(0, 0), count: 0);
  String get fcmToken => userModel.value?.fcmToken ?? "";
  bool get unlimited => userModel.value?.unlimited ?? false;
  bool get admin => userModel.value?.admin ?? false;

  @override
  void onInit() async {
    super.onInit();
    userModel.bindStream(UserService.fetchCurrentUserDataAsStream());
  }
}
