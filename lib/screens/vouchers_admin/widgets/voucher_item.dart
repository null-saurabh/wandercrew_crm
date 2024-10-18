import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wander_crew_crm/screens/vouchers_admin/widgets/voucher_usage_widget.dart';
import 'package:get/get.dart';
import '../../../../utils/date_time.dart';
import '../../../../widgets/widget_support.dart';
import '../../../models/voucher_model.dart';
import '../../../widgets/app_elevated_button.dart';
import '../manage_voucher_controller.dart';
import 'add_voucher.dart';

class VoucherItemAdmin extends StatelessWidget {
  final CouponModel voucherData;
  const VoucherItemAdmin({super.key, required this.voucherData});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ManageVoucherAdminController>(
        init: ManageVoucherAdminController(),
        builder: (controller) {
          return Column(
            children: [
              Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: const BorderRadius.all(Radius.circular(12)),
                      border: Border.all(color: Colors.black.withOpacity(0.12)),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            // mainAxisAlignment: MainAxisAlignment.,
                            children: [
                              Text(
                                voucherData.code,
                                style: AppWidget.black16Text600Style(),
                              ),
                              const SizedBox(
                                width: 8,
                              ),
                              GestureDetector(
                                onTap: () {
                                  Clipboard.setData(ClipboardData(text: voucherData.code));


                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      width: 100,
                                      backgroundColor: Colors.black.withOpacity(0.8),
                                      content: const Text("Copied!"),
                                      duration: const Duration(seconds: 2),
                                      behavior: SnackBarBehavior.floating,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                    ),
                                  );

                                },
                                child: const Icon(
                                  Icons.copy,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(
                            height: 8,
                          ),
                          _buildInfoRow(
                              label: 'Voucher Type',
                              value: voucherData.voucherType),
                          const SizedBox(
                            height: 4,
                          ),
                          _buildInfoRow(
                              label: 'Discount Value',
                              value: voucherData.discountType == "percentage"
                                  ? "${voucherData.discountValue}% OFF"
                                  : "\u{20B9}${voucherData.discountValue} OFF"),
                          const SizedBox(
                            height: 4,
                          ),
                          _buildInfoRow(
                              label: 'Validity',
                              value:
                                  "${DateTimeUtils.formatDateTime(voucherData.validFrom, format: "dd-MMM")} to ${DateTimeUtils.formatDateTime(voucherData.validUntil, format: "dd-MMM")}"),
                          const SizedBox(
                            height: 4,
                          ),
                          if (voucherData.minOrderValue != null) ...[
                            _buildInfoRow(
                                label: 'Min Order Value',
                                value: "\u{20B9}${voucherData.minOrderValue.toString()}"),
                            const SizedBox(
                              height: 4,
                            ),
                          ],
                          if (voucherData.maxDiscount != null) ...[
                            _buildInfoRow(
                                label: 'Max Discount Value',
                                value: "\u{20B9}${voucherData.maxDiscount.toString()}"),
                            const SizedBox(
                              height: 4,
                            ),
                          ],
                          if (voucherData.voucherType == "multi-use") ...[
                            _buildInfoRow(
                                label: 'Total Usage',
                                value:
                                    "${voucherData.usageCount} (Max: ${voucherData.usageLimit})"),
                            const SizedBox(
                              height: 4,
                            ),
                          ],
                          if (voucherData.voucherType == "value-based") ...[
                            _buildInfoRow(
                                label: 'Total Usage',
                                value:
                                    "${voucherData.usageCount} (Remaining: \u{20B9}${voucherData.remainingDiscountValue})"),
                            const SizedBox(
                              height: 4,
                            ),
                          ],
                          _buildInfoRow(
                              label: 'Applicable Categories',
                              value: voucherData.applicableCategories.first),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Active",
                                style: AppWidget.black16Text400Style(),
                              ),
                              Transform.scale(
                                scale:
                                    0.8, // Adjust the scale factor to decrease the size
                                child: Switch(
                                  value: voucherData.isActive,
                                  activeColor: Colors.white,
                                  activeTrackColor: const Color(0xff2563EB),
                                  inactiveTrackColor: Colors.grey,
                                  inactiveThumbColor: Colors.white,
                                  onChanged: (bool value) {
                                    controller.toggleVoucherActiveStatus(
                                        voucherData, value);
                                    // controller.isVeg.value = value;
                                  },
                                ),
                              )
                            ],
                          ),
                          const SizedBox(
                            height: 8,
                          ),
                          if(!voucherData.isUsed)
                          Row(
                            children: [
                              if(voucherData.usedOnOrders != null && voucherData.usedOnOrders!.isNotEmpty)
                              AppElevatedButton(
                                title: "History",
                                titleTextColor: Colors.black,
                                backgroundColor: Colors.transparent,
                                showBorder: true,
                                onPressed: () {
                                  showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return VoucherUsageWidget(usageList: voucherData.usedOnOrders!.reversed.toList(),);
                                      });
                                }
                              ),
                              const SizedBox(
                                width: 8,
                              ),
                              AppElevatedButton(
                                title: "Edit",
                                titleTextColor: Colors.white,
                                // backgroundColor: Colors.transparent,
                                // showBorder: true,
                                onPressed: () {

                                  showModalBottomSheet(
                                    context: context,
                                    isScrollControlled: true, // Allows the bottom sheet to expand with the keyboard
                                    backgroundColor: const Color(0xffF4F5FA),
                                    shape: const RoundedRectangleBorder(
                                      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                                    ),
                                    builder: (context) {
                                      return AddVoucherAdmin(
                                        data: voucherData,
                                        isEdit: true,
                                      ); // Your widget for the bottom sheet
                                    },
                                  );

                                },
                              ),
                              const SizedBox(
                                width: 8,
                              ),
                              AppElevatedButton(
                                title: "Delete",
                                titleTextColor: Colors.white,
                                backgroundColor: Colors.red,
                                onPressed: () {
                                  controller.deleteVoucher(voucherData);
                                },
                              ),
                            ],
                          ),
                          if(voucherData.isUsed && voucherData.usedOnOrders != null && voucherData.usedOnOrders!.isNotEmpty)
                            AppElevatedButton(
                                title: "History",
                                titleTextColor: Colors.black,
                                backgroundColor: Colors.transparent,
                                showBorder: true,
                                onPressed: () {
                                  showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return VoucherUsageWidget(usageList: voucherData.usedOnOrders!.reversed.toList(),);
                                      });
                                }
                            ),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    top: 10,
                    right: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: voucherData.isUsed
                            ? Colors.blue
                            :voucherData.isExpired
                            ? Colors.red
                            : voucherData.isActive
                            ? Colors.green // Yellow for preparing
                            : Colors.grey,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        voucherData.isUsed
                            ? "Used"
                            :voucherData.isExpired
                            ?"Expired"
                            : voucherData.isActive
                            ? "Active"
                            : "Disabled",
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
            ],
          );
        });
  }
}

Widget _buildInfoRow({required String label, String? value}) {
  return Row(
    children: [
      Text(
        '$label: ',
        style: AppWidget.black14Text600Style(),
      ),
      const SizedBox(
        width: 8,
      ),
      Text(value ?? "", style: AppWidget.black14Text400Style()),
    ],
  );
}
