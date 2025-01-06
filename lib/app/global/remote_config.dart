import 'dart:developer';

import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:get/get.dart';

class ActivePeriod {
  ActivePeriod({required this.start, required this.end});
  final String start;
  final String end;
}

class RemoteConfigService {
  static late final FirebaseRemoteConfig remoteConfig;
  static late final ActivePeriod activePeriod1;
  static late final ActivePeriod activePeriod2;
  static late final ActivePeriod activePeriod3;
  static bool initialized = false;

  static init() async {
    if (initialized) {
      return;
    }
    initialized = true;
    remoteConfig = FirebaseRemoteConfig.instance;
    await remoteConfig.setConfigSettings(RemoteConfigSettings(
      fetchTimeout: const Duration(minutes: 1),
      minimumFetchInterval: const Duration(minutes: 10),
    ));

    await remoteConfig.setDefaults(const {
      "activePeriod1_start": "12:00",
      "activePeriod1_end": "13:30",
      "activePeriod2_start": "216:00",
      "activePeriod2_end": "20:00",
      "activePeriod3_start": "23:00",
      "activePeriod3_end": "03:00",
    });

    await remoteConfig.fetchAndActivate();

    activePeriod1 = ActivePeriod(
      start: remoteConfig.getString("activePeriod1_start"),
      end: remoteConfig.getString("activePeriod1_end"),
    );

    activePeriod2 = ActivePeriod(
      start: remoteConfig.getString("activePeriod2_start"),
      end: remoteConfig.getString("activePeriod2_end"),
    );

    activePeriod3 = ActivePeriod(
      start: remoteConfig.getString("activePeriod3_start"),
      end: remoteConfig.getString("activePeriod3_end"),
    );

    log("initialized GeneralService");
  }

  /*
   * Returns true if app is not active
   */
  static bool checkTime() {
    return checkActivePeriod(activePeriod1) &&
        checkActivePeriod(activePeriod2) &&
        checkActivePeriod(activePeriod3, endNextDay: true);
  }

  static String notActiveText() {
    return "${"onlyActiveFrom".tr} ${activePeriod1.start}-${activePeriod1.end}, ${activePeriod2.start}-${activePeriod2.end}, ${activePeriod3.start}-${activePeriod3.end}.";
  }

  static bool checkActivePeriod(ActivePeriod ap, {bool endNextDay = false}) {
    var now = DateTime.now();
    var start = DateTime(now.year, now.month, now.day, int.parse(ap.start.split(":")[0]),
        int.parse(ap.start.split(":")[1]));
    var end = DateTime(now.year, now.month, endNextDay ? now.day + 1 : now.day,
        int.parse(ap.end.split(":")[0]), int.parse(ap.end.split(":")[1]));
    if (start.isBefore(now) && end.isAfter(now)) {
      //Get.snackbar("Success", "appActive".tr);
      return false;
    } else {
      return true;
    }
  }
}
