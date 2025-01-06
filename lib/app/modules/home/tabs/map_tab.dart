import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' as m;
import 'package:genz/app/constants/constants.dart';
import 'package:genz/app/modules/auth/controllers/account_controller.dart';
import 'package:genz/app/modules/home/controllers/home_controller.dart';
import 'package:genz/app/modules/home/widgets/floating_user_stats.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapTab extends StatefulWidget {
  const MapTab({super.key});

  @override
  State<MapTab> createState() => _MapTabState();
}

class _MapTabState extends State<MapTab> {
  GoogleMapController? _controller;

  @override
  Widget build(BuildContext context) {
    // final authController = Get.find<AuthController>();
    final accountController = Get.find<AccountController>();
    return Obx(() {
      final controller = Get.find<HomeController>();
      // if (controller.markers.isEmpty &&
      //         controller.closeUser.isNotEmpty &&
      //         !controller.markerLoading.value ||
      //     controller.markers.length != controller.closeUser.length) {
      //   controller.loadMarkers(controller.closeUser);
      // }
      //inspect(controller.markers);
      return CupertinoPageScaffold(
        //backgroundColor: Constants.darkBackground,
        navigationBar: CupertinoNavigationBar(
          //backgroundColor: Constants.darkBackground,
          middle: Row(
            children: [
              CupertinoSwitch(
                value: accountController.userModel.value?.ghostMode ?? false,
                onChanged: controller.toggleGhost,
              ),
              const Text(
                "👻",
                style: TextStyle(fontSize: 28),
              ),
              const Spacer(),
              Text(
                // remove 1 for the location indicator
                "${"usersNearby".tr}: ${controller.customLocationMarker.value ? controller.markers.length - 1 : controller.markers.length}",
                style: const TextStyle(
                  fontSize: 16,
                ),
              ),
              const Spacer(flex: 2),
            ],
          ),
        ),
        child: Stack(
          children: [
            controller.currentLocation.value == null
                ? const Center(child: CupertinoActivityIndicator())
                : SafeArea(
                    child: GoogleMap(
                      mapType: MapType.normal,
                      style: Constants.googleMapsStyle,
                      myLocationEnabled: !controller.customLocationMarker.value,
                      myLocationButtonEnabled: false,
                      initialCameraPosition: CameraPosition(
                        target: LatLng(
                          controller.currentLocation.value!.coords.latitude,
                          controller.currentLocation.value!.coords.longitude,
                        ),
                        zoom: 20,
                      ),
                      onMapCreated: (GoogleMapController controller) {
                        _controller = controller;
                      },
                      // ignore: invalid_use_of_protected_member
                      markers: controller.markers.value,
                    ),
                  ),
            const Positioned(
                bottom: Constants.navBarHeight, right: 0, child: FloatingUserStatsWidget()),
            Positioned(
              bottom: Constants.navBarHeight,
              left: 0,
              child: SafeArea(
                child: CupertinoButton(
                  child: const Icon(m.Icons.my_location),
                  onPressed: () {
                    if (controller.currentLocation.value == null) {
                      return;
                    }
                    _controller!.animateCamera(
                      CameraUpdate.newCameraPosition(
                        CameraPosition(
                          target: LatLng(
                            controller.currentLocation.value!.coords.latitude,
                            controller.currentLocation.value!.coords.longitude,
                          ),
                          zoom: 20,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            if (kDebugMode && controller.markerLoading.value)
              const Positioned(
                top: 0,
                right: 0,
                child: CupertinoActivityIndicator(),
              ),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.only(top: 8, left: 8),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: CupertinoColors.white,
                    boxShadow: [
                      BoxShadow(
                        color: CupertinoColors.systemGrey.withOpacity(0.5),
                        blurRadius: 1,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          CupertinoIcons.location_solid,
                          color: CupertinoColors.systemGrey,
                        ),
                        controller.placemarks.isEmpty
                            ? const CupertinoActivityIndicator()
                            : Text(
                                controller.placemarks[0].street == null
                                    ? "Null street"
                                    : controller.placemarks[0].street!.isEmpty
                                        ? "No street"
                                        : controller.placemarks[0].street!,
                                style: const TextStyle(
                                  fontSize: 16,
                                ),
                              ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    });
  }
}
