import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:wander_crew_crm/utils/show_snackbar.dart';
import '../../../service/auth_services.dart';
import '../../routes.dart';



class AdminLoginController extends GetxController {
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  final formKey = GlobalKey<FormState>();
  final AuthService authService = AuthService();

  RxBool isLoading = false.obs;



      Future<void> loginAdmin() async {
        if (!formKey.currentState!.validate()) return;

        isLoading.value = true;

        try {
          // Firebase authentication with email and password
          await AuthService.to.login(
            usernameController.text.trim(),
            passwordController.text.trim(),
          );
          // Fetch the logged-in user's docId from Firebase Auth
          final String userId = FirebaseAuth.instance.currentUser!.uid;

          // Update the login timestamp in Firestore
          await FirebaseFirestore.instance
              .collection("AdminAccount")
              .doc(userId) // Use docId of the logged-in user
              .update({
            'loginData': FieldValue.arrayUnion([Timestamp.fromDate(DateTime.now())]),
          });
          // After login success, navigate to intended route or home
          String? intendedRoute = Uri.decodeComponent(
              Get.parameters['redirect'] ?? '');
          if (intendedRoute.isNotEmpty) {
            Get.offNamed(intendedRoute); // Redirect to the intended route
          } else {
            Get.offNamed(Routes.adminHome); // Default to admin home
          }
        } catch (e) {
          // Show error if login failed
          CustomSnackBar.showErrorSnackBar("Failed to log in: $e");
        } finally {
          isLoading.value = false;
        }
      }





  //
  // @override
  // void onClose() {
  //   usernameController.dispose();
  //   passwordController.dispose();
  //   super.onClose();
  // }
}
