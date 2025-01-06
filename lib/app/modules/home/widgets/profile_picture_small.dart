import 'package:flutter/cupertino.dart';
import 'package:shimmer/shimmer.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ProfilePictureSmall extends StatelessWidget {
  const ProfilePictureSmall({super.key, required this.id, this.imageUrl});
  final String id;
  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    if (imageUrl == null) {
      return const Icon(CupertinoIcons.person_crop_circle_fill, size: 50);
    }
    return Hero(
      tag: Key("$id-image"),
      child: CachedNetworkImage(
        imageUrl: imageUrl!,
        width: double.infinity,
        placeholder: (_, __) {
          return Shimmer.fromColors(
            baseColor: const Color(0xFFE8E8EE),
            highlightColor: CupertinoColors.white.withAlpha(255),
            direction: ShimmerDirection.ltr,
            child: Container(
              color: CupertinoColors.white,
            ),
          );
        },
      ),
    );
  }
}
