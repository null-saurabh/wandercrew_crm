import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import 'admin_order_controller.dart';


class RazorpayService {


  Future<void> handleRefund({required String paymentId, required int refundAmount,required int orderAmount, required String orderId,}) async {

    // Get.back();

    showDialog(
      context: Get.context!,
      barrierDismissible: false, // Prevents the user from dismissing the dialog
      builder: (BuildContext context) {
        return const Center(child: CircularProgressIndicator());
      },
    );

    const url = 'https://us-central1-wander-crew.cloudfunctions.net/handlePayment';
    final response = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'paymentId': paymentId, 'amount': refundAmount * 100}),
    );

    if (response.statusCode == 200) {

          await FirebaseFirestore.instance
              .collection("Orders")
              .doc(orderId)
              .update({
            'isRefunded': refundAmount < orderAmount ? 'partial refund' : 'complete refund',
            'refundAmount': refundAmount,
          });
           var controller = Get.find<AdminOrderListController>();
          controller.fetchOrderData();
          Get.back();
          Get.snackbar(
          "Success", "Refund processed successfully",backgroundColor: Colors.green);

    }

    else {
      Get.back();
    }
  }


}

  void handlePaymentSuccess(BuildContext context,response, Function onSuccess) {
    onSuccess(context,response);
  }

  void handlePaymentDismiss(Function onDismiss) {
    onDismiss();
  }

void handlePaymentFailure(response, Function onFailure) {
  onFailure(response);
}


