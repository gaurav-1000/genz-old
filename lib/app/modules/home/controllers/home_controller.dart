// ignore_for_file: no_leading_underscores_for_local_identifiers

import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:genz/app/constants/firebase.dart';
import 'package:genz/app/global/functions.dart';
import 'package:genz/app/global/image_functions.dart';
import 'package:genz/app/global/messaging.dart';
import 'package:genz/app/global/remote_config.dart';
import 'package:genz/app/models/user_model.dart';
import 'package:genz/app/modules/auth/controllers/account_controller.dart';
import 'package:genz/app/modules/auth/services/user_service.dart';
import 'package:genz/app/modules/home/widgets/wink_bottom_sheet.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geoflutterfire2/geoflutterfire2.dart';
import 'package:flutter_background_geolocation/flutter_background_geolocation.dart' as bg;
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../utils/log.dart';

enum ImageType {
  none,
  png,
  other,
}

class HomeController extends GetxController {
  var title = 'scaffoldTitle_home'.tr.obs;
  RxList<UserModel> closeUser = <UserModel>[].obs;
  RxList<UserModel> closeUserImprecise = <UserModel>[].obs;
  RxString test = "".obs;
  RxInt closeIndex = 0.obs;
  RxInt unreadMessagesCount = 0.obs;

  final pageController = PageController(initialPage: 0).obs;
  RxInt pageViewIndex = 0.obs;

  Rx<String?> pickedFilePath = Rx<String?>(null);
  Rx<bg.Location?> currentLocation = Rx<bg.Location?>(null);
  Rx<bg.Location?> lastUploadedLocation = Rx<bg.Location?>(null);
  RxSet<Marker> markers = <Marker>{}.obs;

  GoogleMapController? mapsController;
  RxBool markerLoading = false.obs;

  RxList<Placemark> placemarks = <Placemark>[].obs;

  RxBool getCloseUserImpreciseLoading = false.obs;
  RxBool getCloseUserLoading = false.obs;

  RxBool errorShown = false.obs;

  Timer? timer;
  Timer? splashScreenFailsafe;

  RxList<ConnectivityResult> connectivityResult = <ConnectivityResult>[].obs;
  RxBool lostWiFiConnection = false.obs;

  RxBool timerFuncRunning = false.obs;
  RxBool locationChanged = false.obs;
  // Debug
  RxBool useActivePeriods = false.obs;

  RxBool customLocationMarker = false.obs;

  RxString settingsSelectedZodiac = 'aries'.obs;

  Stopwatch? stopwatch;

  Stopwatch? impStopwatch;

  Stopwatch? closeStopwatch;

  Stopwatch? pStopwatch;

  @override
  void dispose() {
    timer?.cancel();
    stopwatch?.stop();
    impStopwatch?.stop();
    closeStopwatch?.stop();
    pStopwatch?.stop();
    timerFuncRunning(false);
    super.dispose();
  }

  // initialize the apps state
  @override
  void onInit() async {
    timerFuncRunning(false);

    splashScreenFailsafe = Timer.periodic(const Duration(seconds: 15), (Timer t) {
      if (Get.context == null) {
        return;
      }
      FlutterNativeSplash.remove();
      t.cancel();
    });
    connectivityResult.bindStream(Connectivity().onConnectivityChanged);
    ever(connectivityResult, (c) {
      if (c.first == ConnectivityResult.none) {
        lostWiFiConnection(true);
        Get.snackbar(
          "error".tr,
          "noInternet".tr,
          duration: const Duration(seconds: 4),
          backgroundColor: CupertinoColors.systemRed,
        );
      } else if (c.first == ConnectivityResult.mobile) {
        lostWiFiConnection(true);
        Get.snackbar(
          "warning".tr,
          "mobileData".tr,
          duration: const Duration(seconds: 4),
          backgroundColor: CupertinoColors.systemYellow,
        );
      } else if (c.first == ConnectivityResult.wifi && lostWiFiConnection.value) {
        Get.snackbar(
          "success".tr,
          "wifiConnected".tr,
          duration: const Duration(seconds: 4),
          backgroundColor: CupertinoColors.systemGreen,
        );
        lostWiFiConnection(false);
      }
    });

    await FirebaseMessaging.instance.requestPermission();
    try {
      final fcmToken = await firebaseMessaging.getToken();
      Log.d("FCMToken: $fcmToken");
      firebaseFirestore.collection('users').doc(FirebaseAuth.instance.currentUser?.uid).update(
          {"fcm_token": fcmToken});
    }catch(e, s){
      Log.e("Error updating FCM token $e", stackTrace: s);
    }

    final permissionLocationAlways = await Permission.locationAlways.status;

    if(permissionLocationAlways.isGranted) {
      Log.d("Location permission granted");
      await _startBackgroundGeolocation();
    }else{
      //Show permissions dialog
      showCupertinoModalPopup(
        context: Get.context!,
        builder: (context) => CupertinoAlertDialog(
          title: Text("locationPermissionTitle".tr),
          content: Text("locationPermissionDescription".tr),
          actions: [
            CupertinoDialogAction(
              child: Text("cancel".tr),
              onPressed: () {
                Get.back();
              },
            ),
            CupertinoDialogAction(
              child: Text("ok".tr),
              onPressed: () async {
                Get.back();
                await _startBackgroundGeolocation();
                timer = Timer.periodic(const Duration(seconds: 4), (Timer t) => timerFunc());
              },
            ),
          ],
        ),
      );
    }

    updateUnreadMessages();
    super.onInit();
    // check if the user clicked on a notification to open the App and handle it
    Messaging.checkIfOpenedWithNotification();
  }

  Future<void> _startBackgroundGeolocation() async {
    bg.BackgroundGeolocation.onLocation((bg.Location location) async {
      log('[onLocation] $location');
      currentLocation.value = location;
      if (auth.currentUser == null) return;
      final geo = GeoFlutterFire();
      final point =
          geo.point(latitude: location.coords.latitude, longitude: location.coords.longitude);
      // check if the last uploaded location is only a few meters (5) away, so the
      // users don't move every app refresh
      if (lastUploadedLocation.value != null) {
        final distance = point.distance(
                lat: lastUploadedLocation.value!.coords.latitude,
                lng: lastUploadedLocation.value!.coords.longitude) *
            1000;
        log("Distance: $distance");
        if (distance <= 5.0) return;
      }
      locationChanged(true);
      log("Sending loc to firebase");

      lastUploadedLocation.value = location;
      GeoFirePoint myLocation =
          geo.point(latitude: location.coords.latitude, longitude: location.coords.longitude);
      firebaseFirestore
          .collection('users')
          .doc(auth.currentUser!.uid)
          .update({'position': myLocation.data});
    }, (bg.LocationError error) {
      Log.d(error.message);
      log('[onLocation] ERROR - $error');
    });

    var state = await bg.BackgroundGeolocation.ready(
      bg.Config(
        desiredAccuracy: bg.Config.DESIRED_ACCURACY_HIGH,
        distanceFilter: 3.0,
        stopOnTerminate: false,
        stationaryRadius: 0,
        startOnBoot: true,
        enableHeadless: true,
        debug: false,
        logLevel: bg.Config.LOG_LEVEL_OFF,
        showsBackgroundLocationIndicator: false,
        activityType: bg.Config.ACTIVITY_TYPE_FITNESS,
        //! This is extremely dangerous, but we need it to satisfy the customer
        preventSuspend: true,
        isMoving: true,
      ),
    );
    if (!state.enabled) {
      await bg.BackgroundGeolocation.start();
    } else {
      log("state enabled");
    }
  }

  // Load the markers one by one and check
  // if the marker has already been loaded
  Future<void> loadMarkersLazy() async {
    log("close User len ${closeUser.length}", name: "Marker");
    markerLoading(true);
    final pins = Get.find<AccountController>().pinnedUsers;
    for (var pin in pins) {
      await loadPin(pin);
    }
    var pinIds = pins.map((e) => e.id).toList();
    log("Started loading markers for ${closeUser.length} users", name: "Marker");
    var userIds = closeUser.map((e) => e.id).toList();
    for (var user in closeUser) {
      log("Loading marker for ${user.id}", name: "TimerFunc");
      if (pinIds.contains(user.id)) {
        continue;
      }

      loadMarker(user);
    }
    // Remove markers
    for (var marker in markers) {
      final pinsAndCloseUserIds = pinIds + userIds;
      if (!pinsAndCloseUserIds.contains(marker.markerId.value)) {
        markers.remove(marker);
      }
    }
    markerLoading(false);
  }

  // Load the marker for a user
  Future<void> loadMarker(UserModel user) async {
    Marker? markerToRemove;
    for (final marker in markers) {
      if (marker.markerId.value == user.id) {
        markerToRemove = marker;
      }
    }
    if (markerToRemove != null) {
      if (markerToRemove.markerId.value == user.id &&
          markerToRemove.position.latitude == user.position?.geopoint?.latitude &&
          markerToRemove.position.longitude == user.position?.geopoint?.longitude) {
        log("Marker for ${user.id} already loaded", name: "Marker");
        return;
      }
    }
    final marker = Marker(
      markerId: MarkerId(user.id),
      position:
          LatLng(user.position?.geopoint?.latitude ?? 0, user.position?.geopoint?.longitude ?? 0),
      icon: await ImageFunctions.bitmapDescriptorFromUser(user),
      onTap: () {
        // final doc = await firebaseFirestore.collection('users').doc(user.id).get();
        // if (!doc.exists) return;
        // final data = doc.data();
        // final _user = UserModel.fromFirestore(json: data!, id: user.id);
        showCupertinoModalPopup(
          context: Get.context!,
          builder: (context) {
            return WinkBottomSheet(user: user);
          },
        );
      },
    );
    log("Loaded normal user ${user.id}", name: "TimerFunc");
    if (markers.contains(marker)) {
      return;
    }
    markers.remove(markerToRemove);
    markers.add(marker);
  }

  // Load the marker for a pinned user
  Future<void> loadPin(PinnedUser user) async {
    final userData = (await firebaseFirestore.collection('users').doc(user.id).get()).data();
    final isBefore2Hours = (user.timestamp as Timestamp)
        .toDate()
        .isBefore(DateTime.now().subtract(const Duration(hours: 2)));
    if (user.timestamp != null && isBefore2Hours) {
      firebaseFirestore.collection('users').doc(auth.currentUser!.uid).update({
        'pinned_users': FieldValue.arrayRemove([user.toJson()])
      });
      return;
    }
    if (userData == null) {
      if (kDebugMode) {
        Get.snackbar(
          "DebugError",
          "User ${user.id} does not exist anymore or something else went wrong",
          borderColor: CupertinoColors.systemGrey6,
          borderWidth: 1,
          backgroundColor: CupertinoColors.white,
        );
      }
      return;
    }
    final geopoint = user.position?.geopoint;
    if (geopoint == null) {
      if (kDebugMode) {
        Get.snackbar(
          "DebugError",
          "User ${user.id} does not have a location",
          borderColor: CupertinoColors.systemGrey6,
          borderWidth: 1,
          backgroundColor: CupertinoColors.white,
        );
      }
      return;
    }
    log("$geopoint");
    final _user = UserModel.fromFirestore(json: userData, id: user.id ?? "");
    loadMarker(_user);
    log("Loaded pinned user ${user.id}", name: "Pins");
  }

  // This function gets called every 4 seconds and updates
  // the users close to the current user. We don't use the users
  // location stream because that would be too much data and we
  // don't need the exact location every time
  void timerFunc() async {
    final String? name;
    try {
      name = Get.find<AccountController>().userModel.value?.name;
    } catch (_) {
      return;
    }
    log("$name is running timerFunc", name: "TimerFunc");
    stopwatch = Stopwatch()..start();

    if (timerFuncRunning.value) {
      log("Still running, skipping update", name: "TimerFunc");
      return;
    }
    timerFuncRunning(true);

    log("Refreshing close users", name: "TimerFunc");
    // get the current location if it's null
    if (currentLocation.value == null) {
      bg.Location pos = await bg.BackgroundGeolocation.getCurrentPosition(
        persist: false,
        desiredAccuracy: 0,
        timeout: 30000,
        samples: 3,
      );
      currentLocation.value = pos;
    }
    try {
      final locChangedNow = locationChanged.value;
      if (useActivePeriods.value) {
        if (RemoteConfigService.checkTime()) {
          FlutterNativeSplash.remove();
          if (!errorShown.value) {
            errorShown.value = true;
            closeUserImprecise([]);
            closeUser([]);
            markers({});
            placemarks([Placemark(street: "appNotActive".tr)]);
            Get.snackbar(
              "error".tr,
              RemoteConfigService.notActiveText(),
              borderColor: CupertinoColors.systemGrey6,
              borderWidth: 1,
              backgroundColor: CupertinoColors.white,
            );
          }
          Log.d("App not active");
          timerFuncRunning(false);
          return;
        }
      }
      // get the close users. This only updates when the user moves in or
      // out of the radius, thats why we need to call getCloseUser afterwards,
      // so we have the exact location
      impStopwatch = Stopwatch()..start();
      closeUserImprecise(await getCloseUserImprecise().first);
      log('Imprecise loading took ${impStopwatch?.elapsed}');
      closeStopwatch = Stopwatch()..start();
      closeUser(await getCloseUser(closeUserImprecise));
      log('Close user loading took ${closeStopwatch?.elapsed}');
      // load the markers
      FlutterNativeSplash.remove();
      Stopwatch mStopwatch = Stopwatch()..start();
      await loadMarkersLazy();
      log('Marker loading took ${mStopwatch.elapsed}');
      log("loaded markers", name: "TimerFunc");

      if (locChangedNow || errorShown.value) {
        pStopwatch = Stopwatch()..start();
        locationChanged(false);
        placemarkFromCoordinates(currentLocation.value?.coords.latitude ?? 0,
                currentLocation.value?.coords.longitude ?? 0)
            .then((value) {
          placemarks(value);
        });
        log('Loading the Placemarks took took ${pStopwatch?.elapsed}');
      }
    } catch (e) {
      if (kDebugMode) {
        Get.snackbar(
          "DebugError",
          e.toString(),
          borderColor: CupertinoColors.systemGrey6,
          borderWidth: 1,
          backgroundColor: CupertinoColors.white,
        );
        log("------------------------------------------");
        log("Error while refreshing close users:");
        log(e.toString());
        log("------------------------------------------");
      }
    } finally {
      errorShown.value = false;
      timerFuncRunning(false);
      log("Finished refreshing close users", name: "TimerFunc");
      log('TimerFunc took ${stopwatch?.elapsed}');
    }
  }

  // this function switches from profile pictures
  // to generic markers
  void toggleLocationMarker(bool value) async {
    customLocationMarker(value);
    markers({});
    showCupertinoModalPopup(
      context: Get.context!,
      builder: (context) => const CupertinoAlertDialog(
        content: CupertinoActivityIndicator(),
      ),
    );
    await loadMarkersLazy();
    Get.back();
  }

  // Open an image picker and update the profile picture
  Future<void> selectProfilePicture() async {
    List<File>? images;
    try {
      images = await Functions.pickImage(title: "pickImage".tr, text: "pickImageText".tr);
    } catch (_) {
      Get.snackbar(
        "error".tr,
        "unsupportedFileType".tr,
        borderColor: CupertinoColors.systemGrey6,
        borderWidth: 1,
        backgroundColor: CupertinoColors.white,
      );
      Get.back();
      return;
    }
    if (images == null) {
      return;
    }
    if (images.length == 1) {
      Get.snackbar(
        "error".tr,
        "thumbnailError".tr,
        borderColor: CupertinoColors.systemGrey6,
        borderWidth: 1,
        backgroundColor: CupertinoColors.white,
      );
      return;
    }

    pickedFilePath.value = images[1].path;

    // upload the profile picture and thumbnail
    final thumbnailPath = 'userContent/${auth.currentUser!.uid}/profile_thumbnail.png';
    final path = 'userContent/${auth.currentUser!.uid}/profile.png';

    firebaseStorage.ref(thumbnailPath).putFile(images[0]).whenComplete(
          () => firebaseStorage.ref(path).putFile(images![1]).whenComplete(
            () async {
              firebaseFirestore.collection('users').doc(auth.currentUser!.uid).update(
                {
                  'image_url': await firebaseStorage.ref(path).getDownloadURL(),
                  'thumbnail': await firebaseStorage.ref(thumbnailPath).getDownloadURL(),
                },
              );
            },
          ),
        );
  }

  // Get the users close to the current user
  // depending on the Geohash
  Stream<List<UserModel>> getCloseUserImprecise() {
    if (auth.currentUser == null) {
      return Stream.value([]);
    }
    getCloseUserImpreciseLoading(true);
    log("loading imprecise close users", name: "TimerFunc");
    log("${currentLocation.value!.coords.latitude}, ${currentLocation.value!.coords.longitude}",
        name: "Location");
    final geo = GeoFlutterFire();
    var collectionReference = firebaseFirestore.collection('users');
    //This is in km
    double radius = kDebugMode? 50 : 0.35;

    var ret = geo
        .collection(collectionRef: collectionReference)
        .within(
          center: geo.point(
              latitude: currentLocation.value!.coords.latitude,
              longitude: currentLocation.value!.coords.longitude),
          radius: radius,
          field: 'position',
        )
        .map(
      (event) {
        //inspect(event);
        return event
            .map((e) {
              if (e.id == auth.currentUser!.uid) {
                return null;
              }
              var json = e.data()! as Map<String, dynamic>;
              // if (json["ghost_mode"] == true) {
              //   return null;
              // }
              //log(e.id);
              return UserModel.fromFirestore(json: json, id: e.id);
            })
            .whereType<UserModel>()
            .toList();
      },
    );
    getCloseUserImpreciseLoading(false);
    return ret;
  }

  // The geohash stream only updates when the user moves
  // out of the radius, so we need to get the exact location
  // with a new stream that checks for userDoc changed
  Future<List<UserModel>> getCloseUser(List<UserModel> list) async {
    getCloseUserLoading(true);
    log("loading close users for index", name: "TimerFunc");
    var _closeUserImprecise = list;
    //inspect(_closeUserImprecise.map((e) => e.id).toList());
    if (_closeUserImprecise.isEmpty) {
      return [];
    }
    var d = await firebaseFirestore
        .collection("users")
        .where(FieldPath.documentId, whereIn: _closeUserImprecise.map((e) => e.id).toList())
        .get();

    var ret = d.docs
        .map((e) {
          var json = e.data();
          if (json["ghost_mode"] == true) {
            return null;
          }
          return UserModel.fromFirestore(json: json, id: e.id);
        })
        .whereType<UserModel>()
        .toList();

    getCloseUserLoading(false);
    return ret;
  }

  // calculate the distance to another user
  int calculateDistanceToUser(GeoPoint? otherUser) {
    if (otherUser == null) {
      return 0;
    }
    final geo = GeoFlutterFire();
    return (geo
                .point(
                    latitude: currentLocation.value!.coords.latitude,
                    longitude: currentLocation.value!.coords.longitude)
                .distance(lat: otherUser.latitude, lng: otherUser.longitude) *
            1000)
        .round();
  }

  // Toggle Ghost mode
  Future<void> toggleGhost(bool value) async {
    HapticFeedback.mediumImpact();
    if (value) {
      await bg.BackgroundGeolocation.stop();
    } else {
      await bg.BackgroundGeolocation.start();
    }
    firebaseFirestore.collection('users').doc(auth.currentUser!.uid).update(
      {'ghost_mode': value},
    );
  }

  // Wink to a user
  Future<void> winkUser(String userId) async {
    final user = Get.find<AccountController>().userModel.value!;
    log("Current auth User: ${auth.currentUser?.uid}");
    log("current userModel id: ${user.id}");
    if (user.unlimited) {
      user.ref.update(
        {
          'winked_to': FieldValue.arrayUnion([userId]),
        },
      );
    } else if ((user.remainingWinks ?? 0) > 0) {
      user.ref.update(
        {
          'winked_to': FieldValue.arrayUnion([userId]),
          'remaining_winks': FieldValue.increment(-1),
        },
      );
    } else if ((user.premiumWinks ?? 0) > 0) {
      user.ref.update(
        {
          'winked_to': FieldValue.arrayUnion([userId]),
          'premium_winks': FieldValue.increment(-1),
        },
      );
    } else {
      Get.snackbar(
        "warning".tr,
        "noWinksLeft".tr,
        borderColor: CupertinoColors.systemGrey6,
        borderWidth: 1,
        backgroundColor: CupertinoColors.white,
      );
      return;
    }
    firebaseFirestore.collection('users').doc(userId).update(
      {
        'current_winks': FieldValue.arrayUnion([auth.currentUser!.uid]),
        'winks_count': FieldValue.increment(1),
      },
    );
    Functions.sendNotification(
      title: user.name!,
      body: "${user.name} ${"winkedAtYou".tr}",
      token: await firebaseFirestore
          .collection('users')
          .doc(userId)
          .get()
          .then((value) => value.data()?["fcm_token"]),
    );
  }

  // Pin a user
  Future<void> pinUser(String userId) async {
    final otherUser = await UserService.getUser(userId);
    final accountController = Get.find<AccountController>();
    /*
     * check if user has pinned 5 users today
     * This is done in the App and not the server, because 
     * we don't want to clear the pins when someone is
     * still pinned
     */
    // ignore hours/minutes/second etc and only check the date
    if (accountController.pinnedInfo.day.toDate().difference(DateTime.now()).inDays < 0) {
      log("Resetting pinned users", name: "Pin");
      accountController.ref.update({
        'pinned_info': {
          "day": Timestamp.now(),
          "count": 1,
        }
      });
    } else {
      if (accountController.pinnedInfo.count >= 5) {
        Get.snackbar(
          "warning".tr,
          "maxPinnedUsers".tr,
          borderColor: CupertinoColors.systemGrey6,
          borderWidth: 1,
          backgroundColor: CupertinoColors.white,
        );
        return;
      }
      log("Incrementing count", name: "Pin");
      accountController.ref.update({
        'pinned_info': {
          "day": accountController.pinnedInfo.day,
          "count": accountController.pinnedInfo.count + 1,
        }
      });
    }

    /*
     * ---------------------------------------------
     */
    final pinIds = accountController.pinnedUsers.map((e) => e.id).toList();
    if (pinIds.contains(userId)) {
      Get.snackbar(
        "warning".tr,
        "userAlreadyPinned".tr,
        borderColor: CupertinoColors.systemGrey6,
        borderWidth: 1,
        backgroundColor: CupertinoColors.white,
      );
      return;
    }
    log("adding user to pins", name: "Pin");
    final userToAdd = {
      "id": userId,
      "position": {
        "geo_hash": otherUser.position?.geohash,
        "geopoint": otherUser.position?.geopoint,
      },
      "timestamp": Timestamp.now(),
    };
    log("User to add: $userToAdd", name: "Pin");
    accountController.ref.update(
      {
        'pinned_users': FieldValue.arrayUnion([userToAdd]),
      },
    );
  }

  // Fetch the unread messages count by iterating
  // over all the messages in all the chats the user is
  // in and count how many are not from the user
  // and not marked "read"
  Future<void> updateUnreadMessages() async {
    var res = 0;
    log("Updating unread messages", name: "unreadMessages");
    final chats = await firebaseFirestore
        .collection("chats")
        .where("users", arrayContains: auth.currentUser!.uid)
        .get();
    if (chats.docs.isEmpty) {
      unreadMessagesCount(0);
      log("No chats found", name: "unreadMessages");
      return;
    } else {
      log("Found ${chats.docs.length} chats", name: "unreadMessages");
    }
    for (var doc in chats.docs) {
      log("found chat", name: "unreadMessages");

      var querySnapshot = await doc.reference
          .collection("messages")
          .where("status", isNotEqualTo: "read")
          .get();

      var filteredMessages = querySnapshot.docs.where((doc) {
        return doc['from'] != auth.currentUser!.uid;
      }).toList();

      for (var _ in filteredMessages) {
        res++;
      }
    }
    unreadMessagesCount(res);
  }
}
