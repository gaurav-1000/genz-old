import 'package:flutter/cupertino.dart';

import 'package:get/get.dart';

import '../controllers/loading_controller.dart';

class LoadingView extends GetView<LoadingController> {
  const LoadingView({super.key});
  @override
  Widget build(BuildContext context) {
    return const CupertinoPageScaffold(
      child: Center(
        child: Text(
          'LoadingView is working',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
