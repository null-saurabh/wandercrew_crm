import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:wander_crew_crm/utils/show_snackbar.dart';

import '../../../../models/user_model.dart';
import '../../../../service/database.dart';
import '../manage_user_controller.dart';

class AddNewUserAdminController extends GetxController{

  var isEditing = false.obs;
  var editingItem = Rxn<AdminUserModel>();


  // Modify the constructor to accept an item
  AddNewUserAdminController({AdminUserModel? data}) {
    if (data != null) {
      isEditing.value = true;
      setEditingItem(data);
    }
  }

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  var nameController = TextEditingController();
  var userNameController = TextEditingController();
  var passwordController = TextEditingController();
  var roleController = TextEditingController();
  var contact = TextEditingController();
  var address = TextEditingController();


  RxnString selectedPermission = RxnString();

  RxnString documentType = RxnString();
  final ImagePicker _picker = ImagePicker();

  Rxn<dynamic> frontDocument = Rxn<dynamic>();
  var frontDocumentName = Rxn<String>();
  var isFrontDocumentInvalid = false.obs;

  Rxn<dynamic> backDocument = Rxn<dynamic>();
  var backDocumentName = Rxn<String>();
  var isBackDocumentInvalid = false.obs;

  RxString selectedCountryCode = '+91'.obs;  // Default to India

  RxnString frontDocumentUrl = RxnString();
  RxnString backDocumentUrl = RxnString();

  final FirebaseStorage storage = FirebaseStorage.instance;




  void setEditingItem(AdminUserModel item) {

    editingItem.value = item;
    // Populate fields with item data
    userNameController.text = item.userId;
    nameController.text = item.name;
    passwordController.text = item.password;
    roleController.text = item.role;
    selectedPermission.value = item.permission;
    documentType.value = item.documentType;
    contact.text = item.number;
    address.text = item.address;
    frontDocumentUrl.value = item.frontDocumentUrl;
    backDocumentUrl.value = item.backDocumentUrl;

    update();
  }


  Future<void> pickDocument(bool isFront) async {
    try {
      if (kIsWeb){
        final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
        if (pickedFile != null) {
          if (isFront) {
            frontDocumentName.value =
                pickedFile.name; // Assign the file name to display
            final imageBytes = await pickedFile.readAsBytes();
            frontDocument.value =
                imageBytes;
          }
          else {
            final imageBytes = await pickedFile.readAsBytes();

            backDocument.value = imageBytes;   // Assign the file name to display
            backDocumentName.value = pickedFile.name;
          }
        }
      }
      else {
        final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
        if (pickedFile != null) {
          if (isFront) {
            frontDocument.value =
                File(pickedFile.path);
            frontDocumentName.value =
                pickedFile.name;
          }
          else {
            backDocument.value = File(pickedFile.path);   // Assign the file name to display
            backDocumentName.value = pickedFile.name;
          }
        }
      }

      // update();
    }
    catch (e) {

      CustomSnackBar.showErrorSnackBar("Failed to pick image $e}");

    }
  }

  Future<String?> uploadDocument(var document, String fileName) async {
    try {
      Reference ref = storage.ref().child("documents").child(fileName);

      SettableMetadata metadata = SettableMetadata(contentType: 'image/jpeg');
      UploadTask task;
      if (kIsWeb) {
        // For web, use putData() since selectedImage.value is Uint8List
        task = ref.putData(document as Uint8List, metadata);
      } else {
        // For mobile, use putFile() since selectedImage.value is File
        task = ref.putFile(document as File);
      }

      // UploadTask uploadTask = ref.putFile(document);

      TaskSnapshot taskSnapshot = await task;
      // var downloadUrl = await (await uploadTask).ref.getDownloadURL();
      String downloadUrl = await taskSnapshot.ref.getDownloadURL();

      return downloadUrl;
    } catch (e) {

      CustomSnackBar.showErrorSnackBar("Failed to upload document: $e}");
      return null;
    }
  }

  // Function to submit data to Firebase
  Future<void> submitData() async {

    showDialog(
      context: Get.context!,
      barrierDismissible: false, // Prevents the user from dismissing the dialog
      builder: (BuildContext context) {
        return const Center(child: CircularProgressIndicator());
      },
    );
    try {


      if (frontDocument.value != null) {
        frontDocumentUrl.value = await uploadDocument(frontDocument.value!, "front_user_${nameController.value}");
      }
      // print("1");
      if (backDocument.value != null) {
        backDocumentUrl.value = await uploadDocument(backDocument.value!, "back_user_${nameController.value}");
      }

      // String  = randomAlphaNumeric(10);

      if (isEditing.value ? true:frontDocumentUrl.value != null) {
        if (documentType.value == "Passport" ? true : backDocumentUrl.value != null) {
          // Handle optional fields: email, address, city, arrivingFrom, goingTo
          AdminUserModel newUserData = AdminUserModel(
            id: isEditing.value ? editingItem.value!.id :"",
            documentType: documentType.value ?? "",
            frontDocumentUrl: frontDocumentUrl.value ?? "",
            backDocumentUrl: backDocumentUrl.value,
            name: nameController.text,
            number: selectedCountryCode.value + contact.text,
            userId: userNameController.text,
            password: passwordController.text,
            permission: selectedPermission.value ?? "Admin",
            role: roleController.text,
            isOnline: true,
            address: address.text,
            loginData: [DateTime.now()]
          );

          // print("4");
          if(isEditing.value){
            try {



                await DatabaseMethods().updateUserData( editingItem.value!.id,newUserData.toMap());


                // Update the item in the lists
                ManageUserAdminController controller = Get.find<ManageUserAdminController>();
                // Find the index of the item to update
                int index = controller.userDataList.indexWhere((item) => item.id == editingItem.value!.id);
                if (index != -1) {
                  controller.userDataList[index] = newUserData; // Update the item in allMenuItems
                  // Optionally update in originalMenuItems if needed
                  int originalIndex = controller.originalUserDataList.indexWhere((item) => item.id == editingItem.value!.id);
                  if (originalIndex != -1) {
                    controller.originalUserDataList[originalIndex] = newUserData; // Update in originalMenuItems if needed
                  }
                  controller.update();
                }


                Get.back();
                Get.back();
                CustomSnackBar.showSuccessSnackBar("User updated successfully.");



            } catch (error) {
              Get.back();

              CustomSnackBar.showErrorSnackBar("Failed to update user: $error");

            }

          }
          else {


            DocumentReference docRef = await FirebaseFirestore.instance
                .collection('AdminAccount')
                .add(newUserData.toMap());


            String id = docRef.id; // Retrieve the autogenerated ID

            // Optionally, update the document with the newly assigned ID
            await docRef.update({'id': id});

            ManageUserAdminController controller = Get.find<ManageUserAdminController>();
            // Find the index of the item to update
            newUserData.id = id;
              controller.userDataList.add(newUserData); // Update the item in allMenuItems
            controller.originalUserDataList.add(newUserData); // Update the item in allMenuItems
            update();
            Get.back();
            Get.back();

            // print("55");
            CustomSnackBar.showSuccessSnackBar("User Added successfully.");

            clearFields();
          } }
         }else {
        Get.back();

        CustomSnackBar.showErrorSnackBar("Failed to  upload documents");

      }
    } catch (e) {
      Get.back();
      CustomSnackBar.showErrorSnackBar("Failed to Failed to add user: $e");


    } finally {
    }

  }



  bool validateForm() {

    final isValid = formKey.currentState?.validate() ?? false;

    // Manually validate the front document and back document
    if (frontDocument.value == null) {
      isFrontDocumentInvalid.value = true;
    } else {
      isFrontDocumentInvalid.value = false;
    }

    if (backDocument.value == null) {
      if (documentType.value == "Passport"){
        isBackDocumentInvalid.value = false;

      } else {
        isBackDocumentInvalid.value = true;
      }
    } else {
      isBackDocumentInvalid.value = false;
    }
    update();
    // Return whether the entire form is valid
    return isValid && !isFrontDocumentInvalid.value && !isBackDocumentInvalid.value;
  }




  void clearFields() {
    contact.clear();
    address.clear();
    userNameController.clear();
    roleController.clear();
    userNameController.clear();
    passwordController.clear();
  }

}