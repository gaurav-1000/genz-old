import 'dart:developer';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_background_geolocation/flutter_background_geolocation.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:genz/app/constants/firebase.dart';
import 'package:genz/app/global/messaging.dart';
import 'package:genz/app/global/remote_config.dart';
import 'package:genz/app/global/revenuecat.dart';
import 'package:genz/app/modules/auth/controllers/account_controller.dart';
import 'package:genz/app/modules/auth/services/user_service.dart';
import 'package:genz/app/utils/log.dart';
import 'package:genz/generated/locales.g.dart';
import 'package:genz/theme.dart';
import 'package:geoflutterfire2/geoflutterfire2.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter_background_geolocation/flutter_background_geolocation.dart' as bg;
import 'package:purchases_flutter/purchases_flutter.dart';
import 'app/modules/auth/controllers/auth_controller.dart';
import 'app/modules/home/controllers/chats_controller.dart';
import 'app/modules/home/controllers/purchase_controller.dart';
import 'app/routes/app_pages.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  final _ = Get.put(AuthController(), permanent: true);
  SystemChrome.setPreferredOrientations(
    [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown],
  );
  if (kDebugMode) {
    FlutterError.onError = (FlutterErrorDetails errorDetails) {
      FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
    };
    PlatformDispatcher.instance.onError = (error, stack) {
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
      return true;
    };
  }
  await RemoteConfigService.init();
  await RevenueCatService.init();
  await Messaging.init();
  if (Platform.isAndroid) {
    await bg.BackgroundGeolocation.registerHeadlessTask(headlessTask);
  }
  String initialRoute = Routes.WELCOME;
  if (auth.currentUser != null) {
    final userExists = await UserService.checkIfUserExists(auth.currentUser!.uid);
    if (userExists) {
      log("Setting Home as initial Route", name: "Main");
      Get.put<AccountController>(AccountController(), permanent: true);
      initialRoute = Routes.HOME;
    } else {
      log("Setting Setup as initial Route", name: "Main");
      initialRoute = Routes.SETUP_ACCOUNT;
    }
  }
  BackgroundGeolocation.registerHeadlessTask(headlessTask);
  Get.put<PurchaseController>(PurchaseController());

  runApp(
    GetCupertinoApp(
      title: "Application",
      initialRoute: initialRoute,
      getPages: AppPages.routes,
      theme: theme,
      debugShowCheckedModeBanner: false,
      locale: Get.deviceLocale,
      fallbackLocale: const Locale('en', 'US'),
      translationsKeys: AppTranslation.translations,
      onInit: () async {
        firebaseMessaging.onTokenRefresh.listen((fcmToken) {
          log("FCMToken: $fcmToken");
          if (auth.currentUser == null) return;
          firebaseFirestore
              .collection('users')
              .doc(auth.currentUser?.uid)
              .update({"fcm_token": fcmToken});
        }).onError((err) {
          log("ERROR: updating token failed");
        });
        FirebaseAuth.instance.authStateChanges().listen((user) async {
          try {
            if (user == null) {
              FlutterNativeSplash.remove();
              log("Going to welcome because of auth state change");
              try {
                await Purchases.logOut();
              } catch (e) {
                log("Error logging out of purchases");
              }
              Get.delete<AccountController>(force: true);
              Get.offAllNamed(Routes.WELCOME);
            } else {
              // put controller
              log("New user id is ${user.uid}");
              await Purchases.logIn(user.uid);
              final userExists = await UserService.checkIfUserExists(user.uid);
              if (!userExists) {
                Get.delete<AccountController>(force: true);
                log("Going to setup because of auth state change");
                Get.offAllNamed(Routes.SETUP_ACCOUNT);
                FlutterNativeSplash.remove();
                return;
              } else {
                try {
                  if (Get.find<AccountController>().id == user.uid) {
                    return;
                  }
                } catch (_) {}
                await Get.delete<AccountController>(force: true);
                Get.put<AccountController>(AccountController(), permanent: true);
                log("Going to home because of auth state change");
                Get.offAllNamed(Routes.HOME);
              }
            }
          } catch (e) {
            Log.e("Error in auth state change $e", stackTrace: StackTrace.current);
            FlutterNativeSplash.remove();
            Get.snackbar("DebugError", "Something went wrong");
          }
        }).onError((err) {
          log("ERROR: auth state change failed");
        });
      },
    ),
  );
}

@pragma('vm:entry-point')
void headlessTask(bg.HeadlessEvent headlessEvent) async {
  log('[BackgroundGeolocation HeadlessTask]: $headlessEvent');
  switch (headlessEvent.name) {
    case bg.Event.LOCATION:
      bg.Location location = headlessEvent.event;
      log('Headless - Location: $location');
      final geo = GeoFlutterFire();
      GeoFirePoint myLocation =
          geo.point(latitude: location.coords.latitude, longitude: location.coords.longitude);
      if (auth.currentUser != null) {
        firebaseFirestore
            .collection('users')
            .doc(auth.currentUser!.uid)
            .update({'position': myLocation.data});
      } else {
        firebaseFirestore
            .collection('users')
            .doc("123")
            .update({'message': "Error finding auth.currentUser"});
      }
      break;
  }
}
