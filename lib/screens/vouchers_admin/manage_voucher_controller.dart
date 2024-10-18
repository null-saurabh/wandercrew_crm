import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:wander_crew_crm/utils/show_snackbar.dart';

import '../../../widgets/dialog_widget.dart';
import '../../models/voucher_model.dart';
import '../../utils/show_loading_dialog.dart';

class ManageVoucherAdminController extends GetxController {


  RxList<CouponModel> voucherList = <CouponModel>[].obs;
  RxList<CouponModel> originalVoucherList = <CouponModel>[].obs;

  ScrollController scrollController = ScrollController();

  TextEditingController filterFromDate = TextEditingController();
  TextEditingController filterToDate = TextEditingController();
  RxList<String> selectedCategory = <String>[].obs;
  RxList<String> selectedVoucherType = <String>[].obs;
  RxList<String> selectedDiscountType = <String>[].obs;


  RxInt activeFilterCount = 0.obs;

  var isLoading = true.obs; // Loading state


  var selectedFilter = 'None'
      .obs;

  @override
  void onInit() {
    super.onInit();
    fetchVoucherList(); // Fetch data when controller is initialized
  }


  void filterOrdersByStatus({required String label, bool? isFilterButton}) {
    if (selectedFilter.value == label && isFilterButton == null) {
      selectedFilter.value = "None";
      applyDefaultFilter();
      applyRangeFilters();
      update();
      return;
    }
    selectedFilter.value = label;
    // print(1);
    // print(label);

    if(label == 'None') {
      applyDefaultFilter();
    }
    else if (label == 'All') {
      // Show all orders
      voucherList.assignAll(originalVoucherList);
    }
    else if (label == "Used"){
      // print(2);
      voucherList.value = originalVoucherList.where((voucher) {
        return voucher.isUsed== true;
      }).toList();

    }

    else if (label == "Active"){
      voucherList.value = originalVoucherList.where((voucher) {
        return voucher.isActive== true && voucher.isUsed == false && voucher.isExpired == false;
      }).toList();
    }
    else if (label == "Disabled"){
      voucherList.value = originalVoucherList.where((voucher) {
        return voucher.isActive== false && voucher.isUsed == false && voucher.isExpired == false;
      }).toList();
    }
    else if (label == "Expired"){
      voucherList.value = originalVoucherList.where((voucher) {
        return voucher.isUsed == false && voucher.isExpired == true;
      }).toList();
    }

    applyRangeFilters();
    update();
  }

  void applyRangeFilters() {
    voucherList.value = voucherList.where((voucher) {
      bool matchesVoucherType = true;
      bool matchesDateRange = true;
      bool matchesCategoryType = true;
      bool matchesDiscountType = true;

      // Check if the min order value is provided
      if (selectedVoucherType.isNotEmpty) {
        matchesVoucherType = selectedVoucherType.contains(voucher.voucherType);
      }

      // Check if the max order value is provided
      if (selectedDiscountType.isNotEmpty) {
        matchesDiscountType = selectedDiscountType.contains(voucher.discountType);
      }

      if (selectedCategory.isNotEmpty) {
        matchesDiscountType = selectedCategory.contains(voucher.applicableCategories.last);
      }

      // Check if the start date is provided
      if (filterFromDate.text.isNotEmpty) {
        DateTime start = DateFormat("dd-MMM-yy").parse(filterFromDate.text);
        matchesDateRange = voucher.validFrom.isAfter(start) ||
            voucher.validFrom.isAtSameMomentAs(start) ||
            (voucher.validUntil.isAfter(start) && voucher.validFrom.isBefore(start));
      }

      // Check if the end date is provided
      if (filterToDate.text.isNotEmpty) {
        DateTime toDate = DateFormat("dd-MMM-yy").parse(filterToDate.text);
        matchesDateRange = matchesDateRange &&
            (voucher.validUntil.isBefore(toDate) ||
                voucher.validUntil.isAtSameMomentAs(toDate));
      }

      return matchesVoucherType && matchesDateRange && matchesCategoryType && matchesDiscountType;
    }).toList();

    // Sort the filtered orders by date (latest first)
    update();
  }


  void applyDefaultFilter() {
    if (selectedFilter.value == 'None') {
      voucherList.value = originalVoucherList.where((voucher) {
        return (voucher.isActive == true && voucher.isUsed == false && voucher.isExpired == false) ||
            (voucher.isActive== false && voucher.isUsed == false && voucher.isExpired == false);
      }).toList();

      // print(voucherList.length);
      //
      // print(originalVoucherList.length);
      // Ensure orders are sorted by orderDate (latest first)
      update();
    }
  }

  void searchFilterVoucher(String query) {
    if (query.isEmpty) {
      voucherList.value = List.from(originalVoucherList); // Restore the original data
    } else {
      voucherList.value = originalVoucherList.where((item) {
        final queryLower = query.toLowerCase();

        // print("$queryLower : ${item.discountValue}");
        return item.code.toLowerCase().contains(queryLower) ||
            item.discountValue.toString() == queryLower ||
            item.usageCount.toString()  == queryLower ||
            item.usageLimit.toString()  == queryLower ||
            item.maxDiscount.toString()  == queryLower ||
            item.minOrderValue.toString()  == queryLower;
      }).toList();
    }
    update();
  }





  Future<void> fetchVoucherList() async {
    try {
      isLoading.value = true; // Start loading

      QuerySnapshot querySnapshot =
      await FirebaseFirestore.instance.collection("Voucher").get();

      // Mapping Fire store data to model and updating observable list
      List<CouponModel> newList = querySnapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

        return CouponModel.fromMap(
            data); // Using fromMap factory constructor
      }).toList();

      // Updating observable list
      voucherList.assignAll(newList);
      originalVoucherList.assignAll(newList);
      applyDefaultFilter();
      update();
    } catch (e) {
      debugPrint('Error: Failed to fetch list $e');

    }
    finally {
      isLoading.value = false; // End loading
    }
  }

  void toggleVoucherActiveStatus(CouponModel voucherData, bool isActive) async {
    // Update UI first (optimistic update)
    voucherData.isActive = isActive;
    update();

    try {

        // Update the online status in the correct document
        await FirebaseFirestore.instance
            .collection("Voucher")
            .doc(voucherData.voucherId)
            .update({'isActive': isActive});

    } catch (error) {
      // If there's an error, revert the UI back to the previous state
      voucherData.isActive = !isActive;
      update();
      CustomSnackBar.showErrorSnackBar("Failed to update online status: $error");
    }
  }

  Future<void> refreshAndExpireCoupons() async {

    final now = DateTime.now();
    final firestore = FirebaseFirestore.instance;

    showDialog(
      context: Get.context!,
      barrierDismissible: false, // Prevents the user from dismissing the dialog
      builder: (BuildContext context) {
        return const Center(child: CircularProgressIndicator());
      },
    );

    try {
      // Fetch all active coupons that are not expired
      final snapshot = await firestore
          .collection('Voucher')
          // .where('isActive', isEqualTo: true)
          .where('isUsed', isEqualTo: false)
          .get();

      for (var doc in snapshot.docs) {
        final couponData = doc.data();
        final validUntil = (couponData['validUntil'] as Timestamp).toDate();
        final validFrom = (couponData['validFrom'] as Timestamp).toDate();

        // Expire the coupon if it's past the validUntil date
        if (now.isAfter(validUntil.add(const Duration(days: 1))) || now.isBefore(validFrom)) {
          await doc.reference.update({'isExpired': true,'isActive':false});
        }
        else{
          await doc.reference.update({'isExpired': false});
        }
      }

      fetchVoucherList();
      Get.back();
      CustomSnackBar.showErrorSnackBar("Vouchers updated successfully.");


    } catch (e) {
      Get.back();
      CustomSnackBar.showErrorSnackBar("Failed to update voucher.$e");

    }
  }


  Future<void> deleteVoucher(CouponModel voucherData) async {



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
      showLoadingDialog();

      try {
        // Query the document with matching custom 'id' field
        // QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        //     .collection("Voucher")
        //     .where("voucherId", isEqualTo: voucherData.voucherId) // Assuming 'id' is the custom field name in Firestore
        //     .get();
        //
        // if (querySnapshot.docs.isNotEmpty) {
        //   // Get the document ID
        //   String  = querySnapshot.docs.first.id;

          // Delete the document using the retrieved document ID
          await FirebaseFirestore.instance.collection("Voucher").doc(voucherData.voucherId).delete();

          voucherList.remove(voucherData);
          originalVoucherList.remove(voucherData);
          update();
          Get.back();
          CustomSnackBar.showErrorSnackBar("Vouchers deleted successfully.");


      } catch (error) {
        Get.back();
        CustomSnackBar.showErrorSnackBar("Failed to delete voucher. $error");


      }
    }
  }

}