import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_app_badger/flutter_app_badger.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';
import 'package:genz/app/constants/firebase.dart';
import 'package:genz/app/modules/auth/services/chat_service.dart';
import 'package:genz/app/modules/chat/views/image_view.dart';
import 'package:genz/app/modules/home/controllers/home_controller.dart';
import 'package:get/get.dart';

class Messaging {
  Messaging._();

  static Future<void> init() async {
    firebaseMessaging.requestPermission();
    FirebaseMessaging.onBackgroundMessage(handleBackgroundMessage);
    await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
      alert: false,
      badge: true,
      sound: true,
    );
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      FlutterAppBadger.updateBadgeCount(1);
      FlutterRingtonePlayer().playNotification();
      Get.find<HomeController>().updateUnreadMessages();
      late String title;
      late String body;
      if (message.data["type"] == "chatMessage") {
        title = "${message.notification?.title ?? "[Deleted]"} ${"sentYouAMessage".tr}";
        body = message.notification?.body ?? "".tr;
      } else if (message.data["type"] == "chatImage") {
        title = "${message.notification?.title ?? "[Deleted]"} ${"sentYouAnImage".tr}";
        body = "clickToView".tr;
      } else {
        var firstName = (message.notification?.body ?? "").split(" ").first;
        title = "newWink".tr;
        body = "$firstName ${"winkedAtYou".tr}";
      }
      Get.snackbar(
        title,
        body,
        backgroundColor: CupertinoColors.white,
        icon: Icon(CupertinoIcons.chat_bubble_2, color: Get.theme.primaryColor),
        borderColor: CupertinoColors.systemGrey6,
        borderWidth: 1,
        onTap: (snack) async {
          if (message.data["type"] == "chatMessage") {
            Get.back();
            ChatService.openChat(message.data["chatId"]);
          } else if (message.data["type"] == "chatImage") {
            Get.back();
            ChatService.openChat(message.data["chatId"]);
            await Future.delayed(const Duration(milliseconds: 500));
            Get.to(
              () => ImageView(
                tag: "",
                image: CachedNetworkImage(
                  imageUrl: message.data["imageUrl"],
                ),
              ),
            );
          } else {
            Get.find<HomeController>().pageController.value.jumpToPage(2);
          }
        },
      );
      log("Got a message whilst in the foreground!");
      log('Message data: ${message.data}');
      if (message.notification == null) {
        return;
      }
      log('Message also contained a notification: ${message.notification}');
    });
  }

  static Future<void> checkIfOpenedWithNotification() async {
    RemoteMessage? initialMessage = await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) {
      log("Got a message whilst in the background!");
      log('Message data: ${initialMessage.data}');
      if (initialMessage.notification == null) {
        return;
      }
      log('Message also contained a notification: ${initialMessage.notification}');
      if (initialMessage.data["type"] == "chatMessage") {
        ChatService.openChat(initialMessage.data["chatId"]);
      }
    }
  }
}

Future<void> handleBackgroundMessage(RemoteMessage message) async {
  FlutterAppBadger.updateBadgeCount(1);
  log("Title: ${message.notification?.title}");
  log("Body: ${message.notification?.body}");
  log("Data: ${message.data}");
}
