import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:wander_crew_crm/screens/users_admin/widgets/add_user_data.dart';
import 'package:wander_crew_crm/screens/users_admin/widgets/user_data_item.dart';
import 'package:wander_crew_crm/service/auth_services.dart';
import '../../../widgets/filter_button.dart';
import '../../../widgets/widget_support.dart';
import '../../widgets/app_elevated_button.dart';
import 'manage_user_controller.dart';

class ManageUserAdmin extends StatelessWidget {
  const ManageUserAdmin({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ManageUserAdminController>(
      init: ManageUserAdminController(),
      builder: (controller) {
        return Scaffold(
          backgroundColor: const Color(0xffFFFEF9),
          body: Column(
            children: [
              Container(
                color: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.only(
                      left: 16.0, right: 16, top: 46, bottom: 0),
                  child: Column(children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                       IconButton(
                                icon: const Icon(Icons.arrow_back),
                                onPressed: () {
                                  Get.back(); // Go back if there's a previous route

                                },
                              ),

                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              'Manage',
                              style: AppWidget.black24Text600Style(
                                      color: const Color(0xffE7C64E))
                                  .copyWith(height: 1),
                            ),
                            Text(
                              'User',
                              style: AppWidget.black24Text600Style()
                                  .copyWith(height: 1),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 20, bottom: 12),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: SizedBox(
                                  height: 40,
                                  child: TextField(
                                    onChanged: (value) =>
                                        controller.searchFilterUsers(
                                            value), // Call the search function
                                    decoration: InputDecoration(
                                      contentPadding: EdgeInsets.zero,
                                      hintText:
                                          "Search by name, number, username",
                                      hintStyle: const TextStyle(color: Colors.grey),
                                      prefixIcon: const Icon(Icons.search,
                                          color: Colors.grey),
                                      filled: true,
                                      fillColor: Colors.white,
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: const BorderSide(
                                            color: Color(0xffEDCC23)),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: const BorderSide(
                                            color: Color(0xffEDCC23)),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: const BorderSide(
                                            color: Color(0xffEDCC23)),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(
                                width: 4,
                              ),
                              AppElevatedButton(
                                showBorder: true,
                                backgroundColor: Colors.transparent,
                                borderColor: const Color(0xffEDCC23),
                                borderWidth: 1,
                                titleTextColor: Colors.black,
                                title: "Add",
                                onPressed: () {


                                  showModalBottomSheet(
                                    context: context,
                                    isScrollControlled: true, // Allows the bottom sheet to expand with the keyboard
                                    backgroundColor: const Color(0xffF4F5FA),
                                    shape: const RoundedRectangleBorder(
                                      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                                    ),
                                    builder: (context) {
                                      return const AddNewUserAdmin(); // Your widget for the bottom sheet
                                    },
                                  );


                                  // Get.bottomSheet(
                                  //   AddNewUserAdmin(),
                                  //   isScrollControlled:
                                  //       true, // Allows the bottom sheet to expand with keyboard
                                  //   backgroundColor: Color(0xffF4F5FA),
                                  //   shape: RoundedRectangleBorder(
                                  //     borderRadius: BorderRadius.vertical(
                                  //         top: Radius.circular(16)),
                                  //   ),
                                  // );
                                },


                              ),

                              const SizedBox(
                                width: 4,
                              ),
                              AppElevatedButton(
                                showBorder: true,
                                backgroundColor: Colors.transparent,
                                borderColor: const Color(0xffEDCC23),
                                borderWidth: 1,
                                // titleTextColor: Colors.black,
                                child: const Icon(Icons.logout,color: Colors.black,size: 20,),
                                onPressed: () {

                                  AuthService.to.logout();

                                },


                              )
                            ],
                          ),
                          const SizedBox(
                            height: 8,
                          ),
                          Row(
                            children: [
                              FilterButton(
                                label: "All",
                                isSelected:
                                    controller.selectedFilter.value == "All",
                                onTap: () {
                                  controller.filterOrdersByStatus(label: "All");
                                },
                              ),
                              const SizedBox(
                                width: 4,
                              ),
                              FilterButton(
                                label: "Online",
                                isSelected:
                                    controller.selectedFilter.value == "Online",
                                onTap: () {
                                  controller.filterOrdersByStatus(
                                      label: "Online");
                                },
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                  ]),
                ),
              ),
              Obx(() {
                if (controller.userDataList.isNotEmpty) {
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(
                          left: 16.0, right: 16, top: 8, bottom: 16),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius:
                              const BorderRadius.all(Radius.circular(12)),
                          border:
                              Border.all(color: Colors.black.withOpacity(0.12)),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.2),
                              spreadRadius: 0.1,
                              blurRadius: 8,
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.only(
                            top: 16.0,
                            bottom: 16.0,
                            left: 16.0,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Administrator Access",
                                style: AppWidget.black16Text600Style(),
                              ),
                              const SizedBox(
                                height: 8,
                              ),
                              Expanded(
                                child: ListView.builder(
                                  padding: const EdgeInsets.only(right: 16.0),
                                  // controller: controller2,
                                  shrinkWrap: true,
                                  itemCount: controller.userDataList.length,
                                  itemBuilder: (context, index) {
                                    // print(controller.groupedCheckIns.length);
                                    final data = controller.userDataList
                                        .elementAt(index);
                                    return UserDataItemAdmin(
                                      userData: data,
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                } else if (controller.isLoading.value) {
                  return const Expanded(
                      child: Center(child: CircularProgressIndicator()));
                } else {
                  return const Expanded(
                      child: Center(child: Text("No User found.")));
                }
              }),
            ],
          ),
        );
      },
    );
  }
}
