import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

/// detail screen of the image, display when tap on the image bubble
class ImageView extends StatefulWidget {
  final String tag;
  final Widget image;

  const ImageView({super.key, required this.tag, required this.image});

  @override
  // ignore: library_private_types_in_public_api
  _ImageViewState createState() => _ImageViewState();
}

/// created using the Hero Widget
class _ImageViewState extends State<ImageView> {
  @override
  initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onHorizontalDragEnd: (details) {
        //Get.back();
      },
      child: CupertinoPageScaffold(
        child: Stack(
          children: [
            Center(
              child: Hero(
                tag: widget.tag,
                child: widget.image,
              ),
            ),
            Positioned(
              top: 8,
              right: 8,
              child: SafeArea(
                child: CupertinoButton(
                  padding: const EdgeInsets.all(8),
                  color: CupertinoColors.white.withOpacity(0.5),
                  onPressed: Get.back,
                  child: const Icon(CupertinoIcons.xmark, color: CupertinoColors.black),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
