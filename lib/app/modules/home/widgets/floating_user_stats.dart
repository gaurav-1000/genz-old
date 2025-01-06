import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:genz/app/constants/firebase.dart';
import 'package:genz/app/models/user_model.dart';
import 'package:genz/app/modules/auth/controllers/account_controller.dart';
import 'package:genz/app/modules/auth/services/user_service.dart';
import 'package:get/get.dart';

class FloatingUserStatsWidget extends StatelessWidget {
  const FloatingUserStatsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    var accountController = Get.find<AccountController>();
    // todo: use fetchCurrentUserDataAsStream instead
    return Obx(() {
      var user = accountController.userModel.value;
      return SafeArea(
        child: Hero(
          tag: "FUSW",
          child: Column(
            children: [
              _buildStatItem("${'score'.tr}: ${(user?.winksCount ?? 0) > 199 ? '🔥🔥' : '🔥'}"),
              // add an infinity emoji if user is unlimited
              _buildStatItem(user?.unlimited ?? false
                  ? "♾️ 👋"
                  : "${(user?.remainingWinks ?? 0) + (user?.premiumWinks ?? 0)} 👋"),
              // sand clock emoji
              GestureDetector(
                onTap: () async {
                  HapticFeedback.lightImpact();
                  final user = await UserService.getCurrentUser();

                  showCupertinoDialog<void>(
                    context: Get.context!,
                    builder: (BuildContext context) => CupertinoAlertDialog(
                      insetAnimationDuration: Duration.zero,
                      title: Text('currentlyPinned'.tr),
                      content: SizedBox(
                        height: 200,
                        width: double.infinity,
                        child: ListView(
                          shrinkWrap: true,
                          children: [
                            for (PinnedUser pu in user.pinnedUsers!)
                              FutureBuilder(
                                future: firebaseFirestore.collection("users").doc(pu.id).get(),
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState == ConnectionState.waiting) {
                                    return const Center(child: CupertinoActivityIndicator());
                                  }
                                  if (snapshot.data == null) {
                                    return Container();
                                  }
                                  var user = UserModel.fromFirestore(
                                      json: snapshot.data!.data()!, id: pu.id!);
                                  var diff =
                                      DateTime.now().difference(pu.timestamp!.toDate()).inMinutes;
                                  var remaining = 120 - diff;
                                  return CupertinoListTile(
                                    title: Text(user.name ?? "No name"),
                                    trailing: Text("$remaining minutes"),
                                  );
                                },
                              ),
                          ],
                        ),
                      ),
                      actions: <CupertinoDialogAction>[
                        CupertinoDialogAction(
                          onPressed: () {
                            HapticFeedback.lightImpact();
                            Get.back();
                          },
                          child: Text('done'.tr),
                        ),
                      ],
                    ),
                  );
                },
                child: _buildStatItem("⏳"),
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildStatItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, right: 8),
      child: Container(
        height: 50,
        width: 120,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: CupertinoColors.white,
          boxShadow: [
            BoxShadow(
              color: CupertinoColors.systemGrey.withOpacity(0.5),
              blurRadius: 1,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Center(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
