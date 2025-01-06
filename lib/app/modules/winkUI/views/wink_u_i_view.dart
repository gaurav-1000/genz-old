import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:genz/app/constants/constants.dart';
import 'package:genz/app/models/user_model.dart';
import 'package:genz/app/modules/auth/controllers/account_controller.dart';
import 'package:genz/app/modules/home/controllers/home_controller.dart';

import 'package:get/get.dart';

import '../controllers/wink_u_i_controller.dart';

class WinkUIView extends GetView<WinkUIController> {
  const WinkUIView({super.key, required this.user});
  final UserModel user;
  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      child: SafeArea(
        child: Align(
          alignment: Alignment.bottomCenter,
          child: SizedBox(
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
                        image:
                            DecorationImage(image: NetworkImage(user.imageUrl!), fit: BoxFit.fill),
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
                    Draggable<String>(
                      axis: Axis.vertical,
                      //data: test.value,
                      onDragEnd: (details) {
                        log("onDragEnd");
                        log("${details.offset}");
                        if (details.offset.dy > 450) {
                          return;
                        }
                        final accountController = Get.find<AccountController>();
                        if ((accountController.userModel.value!.winkedTo ?? []).contains(user.id)) {
                          return;
                        }
                        Get.find<HomeController>().winkUser(user.id);
                        Get.back();
                      },
                      feedback: const Text(
                        '👋',
                        style: TextStyle(
                          fontSize: 40.0,
                          decoration: TextDecoration.none,
                        ),
                      ),
                      childWhenDragging: SizedBox(
                        height: 57.0,
                        width: 40.0,
                        child: Center(
                          child: Container(),
                        ),
                      ),
                      child: const Text(
                        '👋',
                        style: TextStyle(fontSize: 40.0),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
