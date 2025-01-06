// import 'package:flutter/cupertino.dart';

// import 'package:get/get.dart';

// import '../controllers/edit_phone_controller.dart';

// class EditPhoneView extends StatelessWidget {
//   const EditPhoneView({Key? key}) : super(key: key);
//   @override
//   Widget build(BuildContext context) {
//     final controller = Get.put(EditPhoneController());
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('scaffoldTitle_editPhone'.tr),
//       ),
//       floatingActionButton: FloatingActionButton.extended(
//         onPressed: controller.save,
//         tooltip: 'save'.tr,
//         label: Text('save'.tr),
//         icon: const Icon(Icons.save),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.only(top: 10, left: 10, right: 10, bottom: 10),
//         child: SizedBox(
//           height: 300,
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.start,
//             children: [
//               TextFormField(
//                 controller: controller.phoneController.value,
//                 decoration: InputDecoration(
//                   labelText: 'textField_phoneNumber'.tr,
//                   border: const OutlineInputBorder(),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
