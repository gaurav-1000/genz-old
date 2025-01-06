import 'package:flutter/cupertino.dart';
// ignore: library_prefixes
import 'package:flutter/material.dart' as M;
import 'package:genz/app/routes/app_pages.dart';

import 'package:get/get.dart';

import '../controllers/welcome_controller.dart';

class WelcomeView extends GetView<WelcomeController> {
  const WelcomeView({super.key});
  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      child: Center(
        child: Column(
          children: [
            Expanded(
              flex: 2,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("GenZ", style: TextStyle(fontSize: 50, fontWeight: FontWeight.bold)),
                  Text('welcomeMessage'.tr),
                ],
              ),
            ),
            Expanded(
              flex: 1,
              child: IntrinsicWidth(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Transform.scale(
                      scale: 1.2,
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: M.OutlinedButton(
                          onPressed: () => Get.toNamed(Routes.ONBOARDING),
                          style: M.OutlinedButton.styleFrom(
                            shape: const StadiumBorder(),
                            side: const BorderSide(
                              color: CupertinoColors.black,
                              width: 1,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              'login'.tr,
                              style: const TextStyle(
                                color: CupertinoColors.black,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
