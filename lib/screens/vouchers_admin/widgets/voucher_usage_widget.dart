import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:wander_crew_crm/utils/make_phone_call.dart';
import '../../../../models/voucher_model.dart';
import '../../../../utils/date_time.dart';
import '../../../../widgets/elevated_container.dart';
import '../../../../widgets/widget_support.dart';

class VoucherUsageWidget extends StatelessWidget {
  final List<CouponUsage> usageList;
  VoucherUsageWidget({super.key, required this.usageList});

  final ScrollController scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0), // Customize the radius here
      ),
      backgroundColor: const Color(0xffFFFEF9),
      child: Container(
        constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.68),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 20, right: 20.0, left: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Voucher History",
                    style: AppWidget.black20Text600Style(),
                  ),
                  IconButton(
                    onPressed: () {
                      Get.back();
                    },
                    icon: const Icon(Icons.close),
                  )
                ],
              ),
            ),
            const SizedBox(
              height: 12,
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.only(bottom: 16, right: 20.0, left: 20),

                controller: scrollController,
                itemCount: usageList.length,
                itemBuilder: (context, index) {
                  var usage = usageList[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: ElevatedContainer(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 16.0, horizontal: 12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text(
                              DateTimeUtils.formatDateTime(
                                  DateTime.parse(usage.orderModel.orderDate),
                                  format: 'dd MMM HH:mm a'),
                              style: AppWidget.black16Text600Style(),
                            ),
                            const SizedBox(
                              height: 12,
                            ),
                            Row(
                              children: [
                                Text(
                                  "Order ID",
                                  style: AppWidget.black16Text400Style(),
                                ),
                                Text(
                                  "  #${usage.orderModel.orderId}",
                                  style: AppWidget.black16Text500Style(),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                Text(
                                  'Diner: ',
                                  style: AppWidget.black16Text400Style(),
                                ),
                                Text(
                                  usage.orderModel.dinerName,
                                  style: AppWidget.black18Text500Style(),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                Text(
                                  'Number: ',
                                  style: AppWidget.black16Text400Style(),
                                ),
                                Text(
                                  usage.orderModel.contactNumber,
                                  style: AppWidget.black16Text500Style(),
                                ),
                                const SizedBox(
                                  width: 4,
                                ),
                                GestureDetector(
                                  onTap: () {
                                    makePhoneCall('${usage.orderModel.contactNumber}');
                                  },
                                  child: const Icon(
                                    Icons.call,
                                    color: Colors.green,
                                    size: 20,
                                  ),
                                )
                              ],
                            ),
                            const SizedBox(
                              height: 12,
                            ),
                            Text(
                              usage.orderModel.items
                                  .map((item) =>
                              '${item.quantity} x ${item.menuItemName} (${item.price.toStringAsFixed(2)})')
                                  .join('\n'),
                              style: AppWidget.black16Text500Style(),
                            ),
                            const SizedBox(
                              height: 12,
                            ),
                            Row(
                              children: [
                                Text("Amount: ",
                                    style: AppWidget.black16Text400Style()),
                                Text(
                                    "\u{20B9}${usage.orderModel.totalAmount.toString()}",
                                    style: AppWidget.black16Text500Style(
                                      color: const Color(0xff2563EB),
                                    )),
                              ],
                            ),
                            Row(
                              children: [
                                Text("Discount: ",
                                    style: AppWidget.black16Text400Style()),
                                Text(
                                    usage.orderModel.discount != null
                                        ? "\u{20B9}${usage.orderModel.discount.toStringAsFixed(0)}"
                                        : "N/A",
                                    style: AppWidget.black16Text500Style(
                                      color: const Color(0xff2563EB),
                                    )),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

