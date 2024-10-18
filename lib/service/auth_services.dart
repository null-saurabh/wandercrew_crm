import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:get/get.dart';
import 'package:wander_crew_crm/routes.dart';

class AuthService extends GetxService {
  static AuthService get to => Get.find<AuthService>();

  RxBool isLoggedIn = false.obs;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  RxnString loggedInUserId = RxnString();

  @override
  void onInit() {
    super.onInit();
    _auth.authStateChanges().listen((User? user) {
      if (user != null) {
        isLoggedIn.value = true;
        loggedInUserId.value = user.uid;
      } else {
        isLoggedIn.value = false;
        loggedInUserId.value = null;
      }
    }
   );
  }

  // Future<void> register(String email, String password, String name, String phoneNumber) async {
  //   try {
  //     // Create user with email and password
  //     UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
  //       email: email,
  //       password: password,
  //     );
  //
  //     // Get the newly created user's UID
  //     String userId = userCredential.user!.uid;
  //
  //     // Store additional user information in Firestore
  //     await _firestore.collection('users').doc(userId).set({
  //       'name': name,
  //       'email': email,
  //       'phoneNumber': phoneNumber,
  //       'createdAt': FieldValue.serverTimestamp(),
  //     });
  //
  //     isLoggedIn.value = true; // Mark user as logged in
  //
  //   } catch (e) {
  //     throw Exception("Registration failed: $e");
  //   }
  // }

  Future<void> login(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);

      User? user = _auth.currentUser;
      if (user != null) {
        String userId = user.uid; // Get the user ID

        // Call your method to save the token to the database
        await saveTokenToDatabase(userId);

        isLoggedIn.value = true;
      } else {
        throw Exception("No user is currently signed in.");
      }
    } catch (e) {
      throw Exception("Login failed: $e");
    }
  }

  Future<void> logout() async {
    await _auth.signOut();
    isLoggedIn.value = false;
    if(loggedInUserId.value != null) {
      removeTokenFromDatabase(loggedInUserId.value!);
    }
    Get.offAllNamed(Routes.adminLogin);
  }


  Future<void> saveTokenToDatabase(String userId) async {
    String? token = await FirebaseMessaging.instance.getToken();

    if (token != null) {
      await FirebaseFirestore.instance
          .collection('userTokens')
          .doc(userId)
          .set({
        'token': token,
        'createdAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true)); // Merge allows you to update existing doc
    }
  }



// Call this on logout
  Future<void> removeTokenFromDatabase(String userId) async {
    await FirebaseFirestore.instance.collection('userTokens').doc(userId).delete();
  }

}
