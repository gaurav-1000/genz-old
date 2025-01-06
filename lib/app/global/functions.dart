import 'dart:developer';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:genz/app/constants/firebase.dart';
import 'package:genz/app/global/image_functions.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

class Functions {
  static Future<List<File>?> pickImage({required String title, required String text}) async {
    final pFile = await showCupertinoModalPopup<XFile?>(
      context: Get.context!,
      builder: (BuildContext context) => CupertinoActionSheet(
        title: Text(title),
        message: Text(text),
        cancelButton: CupertinoActionSheetAction(
          onPressed: () {
            Navigator.pop(context);
          },
          child: Text('cancel'.tr),
        ),
        actions: <CupertinoActionSheetAction>[
          CupertinoActionSheetAction(
            /// This parameter indicates the action would be a default
            /// default behavior, turns the action's text to bold text.
            isDefaultAction: true,
            onPressed: () {
              ImagePicker()
                  .pickImage(
                source: ImageSource.camera,
              )
                  .then((image) {
                Navigator.pop(context, image);
              });
            },
            child: Text('camera'.tr),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              ImagePicker()
                  .pickImage(
                source: ImageSource.gallery,
              )
                  .then((image) {
                Navigator.pop(context, image);
              });
            },
            child: Text('gallery'.tr),
          ),
        ],
      ),
    );
    log("image picked", name: "pickImage");
    if (pFile == null) {
      return null;
    }
    showCupertinoDialog(
      context: Get.context!,
      builder: (context) => const CupertinoAlertDialog(
        content: CupertinoActivityIndicator(),
      ),
    );
    var bytes = await pFile.readAsBytes();
    final tempDir = await getTemporaryDirectory();

    var thumbnail = await ImageFunctions.generateThumbnail(bytes);
    File tFile = await File('${tempDir.path}/${const Uuid().v4()}_thumbnail.png').create();
    await tFile.writeAsBytes(thumbnail);
    log("Image compressed", name: "pickImage");

    File file = await File('${tempDir.path}/${const Uuid().v4()}.png').create();
    await file.writeAsBytes(bytes);
    log("Wrote file", name: "pickImage");
    Get.back();
    return [tFile, file];
  }

  static Future<void> sendNotification({
    required String title,
    required String token,
    String? body,
    String? imageUrl,
    Map<String, String>? data,
  }) {
    return firebaseFirestore.collection("notifications").add(
      {
        "title": title,
        "body": body,
        "imageUrl": imageUrl,
        "token": token,
        "timestamp": Timestamp.now(),
        if (data != null) "data": data,
      },
    );
  }
}
