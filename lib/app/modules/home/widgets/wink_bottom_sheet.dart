import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:genz/app/constants/constants.dart';
import 'package:genz/app/models/user_model.dart';
import 'package:genz/app/modules/auth/controllers/account_controller.dart';
import 'package:genz/app/modules/home/controllers/home_controller.dart';
import 'package:get/get.dart';

class WinkBottomSheet extends StatelessWidget {
  const WinkBottomSheet({super.key, required this.user});
  final UserModel user;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        color: CupertinoColors.white,
        boxShadow: [
          BoxShadow(
            color: CupertinoColors.systemGrey.withOpacity(0.5),
            blurRadius: 1,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 8.0, left: 8.0, right: 8.0),
          child: Stack(
            children: [
              SizedBox(
                height: 160,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Stack(
                      children: [
                        Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            image: DecorationImage(
                              image: CachedNetworkImageProvider(
                                user.imageUrl!,
                              ),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Text(
                            Constants.zodiacs[user.zodiac] ?? "",
                            textAlign: TextAlign.right,
                            style: const TextStyle(
                              fontSize: 30,
                              height: 1.2,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "${user.name}${(user.winksCount ?? 0) > 199 ? '🔥🔥' : '🔥'}",
                          style: const TextStyle(
                            fontSize: 25,
                          ),
                        ),
                        // CupertinoButton(
                        //   onPressed: () {
                        //     final authController = Get.find<AuthController>();
                        //     if ((authController.userModel.value!.winkedTo ?? []).contains(user.id)) {
                        //       return;
                        //     }
                        //     winkUser(user.id!);
                        //   },
                        //   child: const Text(
                        //     "👋",
                        //     style: TextStyle(
                        //       fontSize: 40,
                        //     ),
                        //   ),
                        // ),
                        if (!((Get.find<AccountController>().userModel.value?.winkedTo ?? [])
                            .contains(user.id)))
                          CupertinoButton(
                            onPressed: () {
                              Get.find<HomeController>().winkUser(user.id);
                              Get.back();
                            },
                            child: const Text(
                              "👋",
                              style: TextStyle(
                                fontSize: 40,
                              ),
                            ),
                          ),
                        // Draggable<String>(
                        //   axis: Axis.vertical,
                        //   //data: test.value,

                        //   onDragEnd: (details) async {
                        //     log("onDragEnd");
                        //     log("${details.offset}");
                        //     if (details.offset.dy > 450) {
                        //       return;
                        //     }
                        //     HapticFeedback.mediumImpact();
                        //     final accountController = Get.find<AccountController>();
                        //     if ((accountController.userModel.value!.winkedTo ?? [])
                        //         .contains(user.id)) {
                        //       return;
                        //     }
                        //     Get.find<HomeController>().winkUser(user.id);
                        //     Get.back();
                        //   },
                        //   feedback: const Text(
                        //     '👋',
                        //     style: TextStyle(
                        //       fontSize: 40.0,
                        //       decoration: TextDecoration.none,
                        //     ),
                        //   ),
                        //   childWhenDragging: const Text(
                        //     '👋',
                        //     style: TextStyle(fontSize: 40.0, color: Color.fromARGB(0, 0, 0, 0)),
                        //   ),
                        //   child: const Text(
                        //     '👋',
                        //     style: TextStyle(fontSize: 40.0),
                        //   ),
                        // ),
                      ],
                    ),
                  ],
                ),
              ),
              Positioned(
                right: 0,
                child: CupertinoButton(
                  onPressed: () {
                    Get.find<HomeController>().pinUser(user.id);
                    Get.back();
                  },
                  child: const Text("📌"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
