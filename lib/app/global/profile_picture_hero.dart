import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:genz/app/constants/firebase.dart';

class ProfilePictureHero extends StatelessWidget {
  const ProfilePictureHero({super.key, required this.userId, this.width, this.height});
  final String userId;
  final double? width;
  final double? height;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: FutureBuilder(
        future: firebaseStorage.ref('userContent/$userId/profile.png').getDownloadURL(),
        builder: (context, snapshot3) {
          if (snapshot3.connectionState == ConnectionState.waiting) {
            return const Center(child: CupertinoActivityIndicator());
          }
          var url = snapshot3.data;
          return Hero(
            tag: Key("$userId-image"),
            child: CachedNetworkImage(
              imageUrl: url ?? "https://img.icons8.com/color/512/test-account.png",
            ),
          );
        },
      ),
    );
  }
}
