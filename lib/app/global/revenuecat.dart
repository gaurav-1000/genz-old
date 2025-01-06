import 'dart:developer';
import 'dart:io';

import 'package:genz/app/constants/firebase.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

class RevenueCatService {
  RevenueCatService._();

  static Future<void> init() async {
    try {
      await Purchases.setLogLevel(LogLevel.debug);
      PurchasesConfiguration configuration;
      if (Platform.isAndroid) {
        configuration = PurchasesConfiguration("goog_LHgwvDGOfrKAdGiOVGFTdOZBMor");
      } else {
        configuration = PurchasesConfiguration("appl_QqmzpgGdthTXpstHYlVDtrApfVe");
      }
      await Purchases.configure(configuration);
      final currentUser = auth.currentUser;
      if (currentUser != null) {
        log("user id is ${currentUser.uid}");
        await Purchases.logIn(currentUser.uid);
      }
    } on UnimplementedError catch (_) {
      log("RevenueCat not implemented");
    } catch (e) {
      log(e.toString());
    }
  }
}
