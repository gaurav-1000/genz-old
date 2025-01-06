import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:genz/app/constants/firebase.dart';
import 'package:get/get.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import '../../../utils/log.dart';

class PurchaseController extends GetxController {
  RxBool purchaseLoading = false.obs;
  RxList<StoreProduct> products = <StoreProduct>[].obs;

  @override
  void onInit() {
    loadProducts();
    super.onInit();
  }

  // Load the products to display in the store (settings)
  void loadProducts() async {
    final value = await Purchases.getProducts([
      "20winks",
      "40winks",
      "100winks",
    ], productCategory: ProductCategory.nonSubscription);
    value.sort((a, b) => a.price.compareTo(b.price));
    products.value = value;
    Log.d("Loaded products");
    inspect(products);
  }

  // Purchase a product in the Store
  Future<void> purchaseProduct(String productIdentifier) async {
    try {
      purchaseLoading(true);
      final pack = products
          .firstWhere((element) => element.identifier == productIdentifier);

      try {
        CustomerInfo customerInfo = await Purchases.purchaseStoreProduct(pack);
        if (customerInfo.entitlements.all["pack"]?.isActive == true) {
          Get.snackbar(
            "success".tr,
            "winksPurchasedSuccess".tr,
            backgroundColor: CupertinoColors.systemGreen,
          );
          if(productIdentifier == "20winks"){
            // Add 20 winks to the user
            firebaseFirestore.collection("users").doc(auth.currentUser!.uid).update({
              "winks": FieldValue.increment(20),
            });
          } else if(productIdentifier == "40winks"){
            // Add 40 winks to the user
            firebaseFirestore.collection("users").doc(auth.currentUser!.uid).update({
              "winks": FieldValue.increment(40),
            });
          } else if(productIdentifier == "100winks"){
            // Add 100 winks to the user
            firebaseFirestore.collection("users").doc(auth.currentUser!.uid).update({
              "winks": FieldValue.increment(100),
            });
          }
        }
      } on PlatformException catch (e) {
        var errorCode = PurchasesErrorHelper.getErrorCode(e);
        if (errorCode != PurchasesErrorCode.purchaseCancelledError) {
          Get.snackbar(
            "warning".tr,
            "somethingWentWrong".tr,
            borderColor: CupertinoColors.systemGrey6,
            borderWidth: 1,
            backgroundColor: CupertinoColors.white,
          );
        }
      }

      //inspect(offerings);
      log("Pack:");
      //inspect(pack);
    } on PlatformException catch (_) {
      // optional error handling
      Log.e("Error purchasing product");
    } finally {
      purchaseLoading(false);
    }
  }
}
