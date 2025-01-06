import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:genz/app/constants/constants.dart';
import 'package:genz/app/constants/firebase.dart';
import 'package:genz/app/models/user_model.dart';
import 'package:genz/app/modules/auth/controllers/account_controller.dart';
import 'package:genz/app/modules/auth/services/user_service.dart';
import 'package:genz/app/modules/home/controllers/home_controller.dart';
import 'package:genz/app/modules/home/widgets/profile_picture_small.dart';
import 'package:get/get.dart';

class WinksTab extends StatelessWidget {
  const WinksTab({super.key});
  @override
  Widget build(BuildContext context) {
    final accountController = Get.find<AccountController>();
    final _ = Get.find<HomeController>();
    return Obx(() {
      var currentUser = accountController.userModel.value;
      if (currentUser == null) {
        return const Center(child: CupertinoActivityIndicator());
      }
      return CupertinoPageScaffold(
        navigationBar: CupertinoNavigationBar(
          middle: Text('scaffoldTitle_winks'.tr),
        ),
        child: SafeArea(
          child: Container(
            color: CupertinoColors.systemGroupedBackground,
            child: currentUser.currentWinks?.isEmpty ?? true
                ? Center(
                    child: Text("noWinks".tr),
                  )
                : ListView(
                    children: [
                      CupertinoListSection(
                        header: Text('header_winks'.tr),
                        children: [
                          for (var index = 0; index < currentUser.currentWinks!.length; index++)
                            FutureBuilder(
                              future: firebaseFirestore
                                  .collection("users")
                                  .doc(currentUser.currentWinks![index])
                                  .get(),
                              builder: (context, snapshot2) {
                                if (snapshot2.connectionState == ConnectionState.waiting) {
                                  return const Center(child: CupertinoActivityIndicator());
                                }
                                UserModel user;
                                try {
                                  user = UserModel.fromFirestore(
                                      json: snapshot2.data!.data()!,
                                      id: currentUser.currentWinks![index]);
                                } catch (e) {
                                  if (kDebugMode) {
                                    return Center(
                                        child: Text(
                                            "ERROR: ${currentUser.currentWinks![index]} not found"));
                                  } else {
                                    return Container();
                                  }
                                }

                                return CupertinoListTile(
                                  leadingSize: Constants.listTileLeadingSize,
                                  leading: Stack(
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.all(6.0),
                                        child: ProfilePictureSmall(
                                          id: user.id,
                                          imageUrl: user.thumbnail,
                                        ),
                                      ),
                                      Positioned(
                                        bottom: 0,
                                        right: 0,
                                        child: Text(
                                          Constants.zodiacs[user.zodiac] ?? "",
                                          textAlign: TextAlign.right,
                                          style: const TextStyle(
                                            fontSize: 18,
                                            height: 1.2,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      CupertinoButton(
                                        child: const Icon(CupertinoIcons.hand_raised),
                                        onPressed: () async => UserService.winkBack(user.id),
                                      ),
                                      CupertinoButton(
                                        child: const Icon(CupertinoIcons.delete),
                                        onPressed: () async => UserService.removeWink(user.id),
                                      ),
                                    ],
                                  ),
                                  title: Text(
                                      "${user.name}${(user.winksCount ?? 0) >= Constants.waveSteps ? '🔥🔥' : '🔥'}"),
                                );
                              },
                            ),
                        ],
                      ),
                      const SizedBox(height: Constants.navBarHeight),
                    ],
                  ),
          ),
        ),
      );
    });
  }
}
