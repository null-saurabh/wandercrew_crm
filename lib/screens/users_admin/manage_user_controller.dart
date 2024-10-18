import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:printing/printing.dart';
import 'package:http/http.dart' as http;
import 'package:wander_crew_crm/screens/users_admin/widgets/add_user_data.dart';
import 'package:wander_crew_crm/utils/show_loading_dialog.dart';
import '../../../models/user_model.dart';
import 'package:pdf/widgets.dart' as pw;
import '../../../widgets/dialog_widget.dart';
import '../../utils/show_snackbar.dart';

class ManageUserAdminController extends GetxController {


  RxList<AdminUserModel> userDataList = <AdminUserModel>[].obs;
  RxList<AdminUserModel> originalUserDataList = <AdminUserModel>[].obs;


  var isLoading = true.obs; // Loading state

  var selectedFilter = 'All'
      .obs;

  @override
  void onInit() {
    super.onInit();
    fetchUserDataList(); // Fetch data when controller is initialized
  }

  void searchFilterUsers(String query) {
    if (query.isEmpty) {
      userDataList.value = List.from(originalUserDataList); // Restore the original data
    } else {
      userDataList.value = originalUserDataList.where((item) {
        final queryLower = query.toLowerCase();

        return item.name.toLowerCase().contains(queryLower) ||
            item.number.toLowerCase().contains(queryLower) ||
            item.userId.toLowerCase().contains(queryLower)
        ;
      }).toList();
    }
    update();
  }

  void filterOrdersByStatus({required String label}) {

    selectedFilter.value = label;

    if (label == 'All') {
      userDataList.assignAll(originalUserDataList);
    }

    else {
      userDataList.value = originalUserDataList.where((userData) {
        return userData.isOnline == true;
      }).toList();
    }

    // Ensure orders are sorted by orderDate (latest first)
    update();
  }
  
  

  Future<void> fetchUserDataList() async {
    try {
      isLoading.value = true; // Start loading

      QuerySnapshot querySnapshot =
      await FirebaseFirestore.instance.collection("AdminAccount").get();

      // Mapping Fire store data to model and updating observable list
      List<AdminUserModel> newList = querySnapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

        return AdminUserModel.fromMap(
            data); // Using fromMap factory constructor
      }).toList();
      // print(newList);

      // Updating observable list
      originalUserDataList.assignAll(newList);
      userDataList.assignAll(newList);
      update();
    } catch (e) {
      debugPrint(e.toString());

      // print(e);
    }
    finally {
      isLoading.value = false; // End loading
    }
  }

  Future<void> deleteUser(AdminUserModel userData) async {

    var result  = await showModalBottomSheet(
      context: Get.context!,
      isScrollControlled: true, // Allows the bottom sheet to expand with the keyboard
      backgroundColor: const Color(0xffF4F5FA),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        // print("delete 2");
        return const DialogWidget(); // Your widget for the bottom sheet
      },
    );


    if (result == true) {
      // print("1111");

      try {
        
        showLoadingDialog();

        // print("id: ${userData.id}");

        // Check if the document exists before attempting to delete
        DocumentSnapshot docSnapshot = await FirebaseFirestore.instance
            .collection("AdminAccount")
            .doc(userData.id)
            .get();

        if (docSnapshot.exists) {
          // Delete the document if it exists
          await FirebaseFirestore.instance.collection("AdminAccount").doc(userData.id).delete();
          originalUserDataList.remove(userData);
          userDataList.remove(userData);

          update();
          Get.back();

          Get.snackbar(
            "Success", // Title of the snackbar
            "User deleted successfully.", // Message content
            backgroundColor: Colors.green,
            colorText: Colors.white, // Text color
            snackPosition: SnackPosition.BOTTOM, // Position of the snackbar
            duration: const Duration(seconds: 3), // Duration of snackbar visibility
          );

        } else {
          // Document does not exist, show error snackbar
          Get.back();
          CustomSnackBar.showErrorSnackBar("User not found, deletion failed.");
        }


      } catch (error) {
        Get.back();

        CustomSnackBar.showWarningSnackBar("Check Internet Connection");

      }
    }
  }

  Future<void> editUserData(AdminUserModel data) async {

      // showModalBottomSheet(
      //   context: Get.context!,
      //   isScrollControlled: true, // Allows the bottom sheet to expand with the keyboard
      //   backgroundColor: const Color(0xffF4F5FA),
      //   shape: const RoundedRectangleBorder(
      //     borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      //   ),
      //   builder: (context) {
      //     return AddNewUserAdmin(data: data,isEdit: true,); // Your widget for the bottom sheet
      //   },
      // );

    Get.bottomSheet(
      AddNewUserAdmin(data: data,isEdit: true,),
      isScrollControlled: true, // Allows the bottom sheet to expand with keyboard
      backgroundColor: const Color(0xffF4F5FA),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
    );
    // print("Edit Menu Item: ${item.name}");
  }

  void toggleUserOnlineStatus(AdminUserModel userData, bool isOnline) async {
    // Update UI first (optimistic update)
    userData.isOnline = isOnline;
    update();

    try {

        // Update the online status in the correct document
        await FirebaseFirestore.instance
            .collection("AdminAccount")
            .doc(userData.id)
            .update({'isOnline': isOnline});

    } catch (error) {
      // If there's an error, revert the UI back to the previous state
      userData.isOnline = !isOnline;
      CustomSnackBar.showErrorSnackBar("Failed to update online status: $error");
      update();

    }
  }





  static Future<pw.ImageProvider> _fetchImage(String url) async {
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final bytes = response.bodyBytes;
      return pw.MemoryImage(bytes);
    } else {
      throw Exception('Failed to load image');
    }
  }

  // Helper function to build a text row for info
  static pw.Widget  _buildInfoRow(String label, String value) {
    return pw.Row(
      children: [
        pw.Text('$label: ',
            style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
        pw.Text(value),
      ],
    );
  }

  static Future<void> _savePdf(pw.Document pdf, String fileName) async {
    // For Web

      // For Mobile (Android/iOS)
      final pdfBytes = await pdf.save();
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/$fileName');
      await file.writeAsBytes(pdfBytes);
      await Printing.sharePdf(bytes: pdfBytes, filename: fileName);
    }



  Future<void> downloadUserData(AdminUserModel checkInItem) async {
    try {


      showLoadingDialog();
      final pdf = pw.Document();

      // Fetch images first
      final frontImage = await _fetchImage(checkInItem.frontDocumentUrl);
      var backImage;
      if (checkInItem.backDocumentUrl != null) {
        backImage = await _fetchImage(checkInItem.backDocumentUrl!);
      }
      pdf.addPage(
        pw.Page(
          build: (pw.Context context) =>
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text('Check-In Details',
                      style: pw.TextStyle(
                          fontSize: 24, fontWeight: pw.FontWeight.bold)),
                  pw.SizedBox(height: 10),
                  _buildInfoRow('id', checkInItem.id),
                  _buildInfoRow('Document Type', checkInItem.documentType),
                  _buildInfoRow('name', checkInItem.name),
                  _buildInfoRow('userId', checkInItem.userId.toString()),
                  _buildInfoRow('password', checkInItem.password),
                  _buildInfoRow('role', checkInItem.role),
                  _buildInfoRow('permission', checkInItem.permission),
                  _buildInfoRow('number', checkInItem.number),
                  _buildInfoRow('address', checkInItem.address),
                  _buildInfoRow('permission', checkInItem.permission),
                  // _buildInfoRow('loginData', checkInItem.loginData),

                  pw.SizedBox(height: 10),
                  pw.Text('Documents',
                      style: pw.TextStyle(
                          fontSize: 18, fontWeight: pw.FontWeight.bold)),
                  pw.SizedBox(height: 10),
                  pw.Image(
                      frontImage, height: 150,
                      width: 150,
                      fit: pw.BoxFit.cover),
                  pw.SizedBox(height: 10),
                  if(checkInItem.backDocumentUrl != null)
                    pw.Image(
                        backImage, height: 150,
                        width: 150,
                        fit: pw.BoxFit.cover),
                  pw.SizedBox(height: 10),

                ],
              ),
        ),
      );

      // Generate the PDF as bytes and save it
      await _savePdf(pdf, "${checkInItem.name} User Details.pdf");
      Get.back();

    }
    catch (e){

      Get.back();
      CustomSnackBar.showErrorSnackBar("Failed to download $e");


    }
  }

}
