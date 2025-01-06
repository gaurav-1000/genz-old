import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:genz/app/constants/constants.dart';
import 'package:genz/app/models/user_model.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image/image.dart' as img;

class ImageFunctions {
  static Future<BitmapDescriptor> bitmapDescriptorFromUser(UserModel user) async {
    if (user.thumbnail == null || user.thumbnail!.isEmpty) {
      return BitmapDescriptor.bytes(
        await ImageFunctions.getBytesFromAsset("assets/images/person.png", 60),
      );
    }
    try {
      var bytes = await readNetworkImageAsPng(user.thumbnail!);
      ui.Codec codec = await ui.instantiateImageCodec(bytes, targetWidth: 120);
      ui.FrameInfo fi = await codec.getNextFrame();
      bytes = (await fi.image.toByteData(format: ui.ImageByteFormat.png))?.buffer.asUint8List() ??
          Uint8List(0);
      bytes = await makeImageRoundAndAddScore(
          bytes, 120, (user.winksCount ?? 0) >= Constants.waveSteps ? 2 : 1);
      return BitmapDescriptor.bytes(bytes);
    } catch (e) {
      if (kDebugMode) {
        Get.snackbar(
          "DebugError",
          "Could not load image for ${user.id}",
          borderColor: CupertinoColors.systemGrey6,
          borderWidth: 1,
          backgroundColor: CupertinoColors.white,
        );
      }
      return BitmapDescriptor.defaultMarker;
    }
  }

  static Future<Uint8List> readNetworkImageAsPng(String imageUrl) async {
    final ByteData data = await NetworkAssetBundle(Uri.parse(imageUrl)).load(imageUrl);
    final bytes = data.buffer.asUint8List();

    return compute(_convertToPng, bytes);
  }

  static Uint8List _convertToPng(Uint8List bytes) {
    if (bytes[0] == 137 &&
        bytes[2] == 80 &&
        bytes[3] == 78 &&
        bytes[4] == 71 &&
        bytes[5] == 13 &&
        bytes[6] == 10 &&
        bytes[7] == 26 &&
        bytes[8] == 10) {
      // Image is already a png
      return bytes;
    }
    img.Image image = img.decodeImage(bytes) ?? img.Image(width: 0, height: 0);

    return img.encodePng(image, level: 0);
  }

  static Future<Uint8List> makeImageRoundAndAddScore(
    Uint8List bytes,
    int targetSize,
    int emojiCount,
  ) async {
    try {
      ui.Image image = await decodeImage(bytes);

      int width = image.width;
      int height = image.height;
      int radius = (targetSize / 2).floor();

      final recorder = ui.PictureRecorder();
      final canvas = Canvas(
        recorder,
        Rect.fromCircle(
          center: Offset(radius.toDouble(), radius.toDouble()),
          radius: radius.toDouble(),
        ),
      );

      final paint = Paint()..isAntiAlias = true;
      canvas.drawCircle(Offset(radius.toDouble(), radius.toDouble()), radius.toDouble(), paint);

      final srcRect = Rect.fromLTWH(0, 0, width.toDouble(), height.toDouble());
      final destRect = Rect.fromLTWH(0, 0, targetSize.toDouble(), targetSize.toDouble());
      paint.isAntiAlias = true;
      paint.blendMode = BlendMode.srcIn;
      canvas.drawImageRect(image, srcRect, destRect, paint);

      // Add flame emojis
      if (emojiCount >= 1) {
        final flameImage = await loadImage('assets/images/flame_emoji-60x60.png');
        final flameWidth = flameImage.width.toDouble();
        final flameHeight = flameImage.height.toDouble();

        const offsetX = -10.0;
        const offsetY = -6.0;
        final flamePosition =
            Offset(targetSize - flameWidth - 4 - offsetX, targetSize - flameHeight - 4 - offsetY);

        final flamePaint = Paint();
        flamePaint.isAntiAlias = true;
        flamePaint.blendMode = BlendMode.srcOver;

        canvas.drawImage(flameImage, flamePosition, flamePaint);
      }

      if (emojiCount >= 2) {
        final flameImage = await loadImage('assets/images/flame_emoji-60x60.png');
        final flameWidth = flameImage.width.toDouble();
        final flameHeight = flameImage.height.toDouble();

        const offsetX = 30.0;
        const offsetY = -6.0;
        final flamePosition =
            Offset(targetSize - flameWidth - 4 - offsetX, targetSize - flameHeight - 4 - offsetY);

        final flamePaint = Paint();
        flamePaint.isAntiAlias = true;
        flamePaint.blendMode = BlendMode.srcOver;

        canvas.drawImage(flameImage, flamePosition, flamePaint);
      }

      final picture = recorder.endRecording();
      final roundedImage = await picture.toImage(targetSize, targetSize);
      final roundedBytes =
          (await roundedImage.toByteData(format: ui.ImageByteFormat.png))?.buffer.asUint8List();

      return roundedBytes ?? Uint8List(0);
    } catch (e) {
      if (kDebugMode) {
        Get.snackbar(
          "DebugError",
          "Could not make the Image round and add a Score",
          borderColor: CupertinoColors.systemGrey6,
          borderWidth: 1,
          backgroundColor: CupertinoColors.white,
        );
      }
      return Uint8List(0);
    }
  }

  static Future<ui.Image> decodeImage(Uint8List bytes) {
    final completer = Completer<ui.Image>();
    ui.decodeImageFromList(bytes, (ui.Image image) {
      completer.complete(image);
    });
    return completer.future;
  }

  static Future<ui.Image> loadImage(String path) async {
    final data = await rootBundle.load(path);
    final bytes = data.buffer.asUint8List();
    final image = await decodeImage(bytes);
    return image;
  }

  static Future<Uint8List> getBytesFromAsset(String path, int width) async {
    ByteData data = await rootBundle.load(path);
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(), targetWidth: width);
    ui.FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(format: ui.ImageByteFormat.png))!.buffer.asUint8List();
  }

  static Future<Uint8List> generateThumbnail(Uint8List bytes) async {
    var png = await compute(_convertToPng, bytes);
    ui.Codec codec = await ui.instantiateImageCodec(png, targetWidth: 64);
    ui.FrameInfo fi = await codec.getNextFrame();
    final ret = (await fi.image.toByteData(format: ui.ImageByteFormat.png))?.buffer.asUint8List();
    if (ret == null || ret.isEmpty) {
      throw Exception("thumbnailError");
    }
    return ret;
  }

  // ignore: unused_element
  static Uint8List _convertToCompressedPng(Uint8List bytes) {
    if (bytes[0] == 137 &&
        bytes[2] == 80 &&
        bytes[3] == 78 &&
        bytes[4] == 71 &&
        bytes[5] == 13 &&
        bytes[6] == 10 &&
        bytes[7] == 26 &&
        bytes[8] == 10) {
      // Image is already a png
      return bytes;
    }
    img.Image image = img.decodeImage(bytes) ?? img.Image(width: 0, height: 0);

    return img.encodePng(image, level: 6);
  }
}
