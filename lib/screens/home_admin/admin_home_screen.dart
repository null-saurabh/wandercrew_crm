import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:wander_crew_crm/screens/home_admin/widgets/home_screen_menu_widget.dart';
import 'package:wander_crew_crm/routes.dart';
import 'package:wander_crew_crm/widgets/widget_support.dart';


class AdminHomeScreen extends StatelessWidget {
  const AdminHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
          backgroundColor: const Color(0xffFDFDED),
          body: SingleChildScrollView(
            child: Container(
              height: MediaQuery.of(context).size.height,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF72B4E8), // #72B4E8
                    Color(0xFF92E2E3), // #92E2E3
                  ],
                  stops:  [0.0146, 0.9854],
                ),
                image: DecorationImage(
                  image: AssetImage('assets/textures/reception_noise.png'), // Replace with your image path
                  fit: BoxFit.cover, // To make the image cover the entire container
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(0.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("WANDER",
                            style: AppWidget.white32Heading700TextStyle()),
                        const SizedBox(
                          width: 4,
                        ),
                        Text("CREW",
                            style: AppWidget.headingBoldTextStyle()),
                      ],
                    ),
                    Text("Your Journey, Our Passion.",
                        style: AppWidget.white12SubHeadingTextStyle()),
                    const SizedBox(height: 48,),


                    TextButton(onPressed: (){
                      sendTestNotification();
                    }, child: Text("Send")),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ReceptionHomeGridItem(
                              height: 199,
                              width: 218,
                              widthRatio: 0.50,
                              iconWidth: 120,
                              iconHeight: 120,
                              icon: "assets/icons/burger.png",
                              label: "Ordered Food",
                              onTap: () {
                                // Add action for order food
                                Get.toNamed(Routes.adminOrderList);

                              },

                            ),
                            const SizedBox(
                              width: 12,
                            ),
                            ReceptionHomeGridItem(
                              height: 199,
                              width: 122,
                              widthRatio: 0.40,

                              label: "Menu",
                              icon: "assets/icons/menu.png",

                              onTap: () {
                                // Add action for order food
                                Get.toNamed(Routes.adminMenu);

                              },
                              isRoomService: true,

                            ),
                          ],
                        ),


                    const SizedBox(
                      height: 12,
                    ),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,

                      children: [
                        ReceptionHomeGridItem(
                          height: 182,
                          width: 155,// Fixed size for each grid item
                          widthRatio: 0.42,
                          iconWidth: 138,
                          iconHeight: 80,
                          icon: "assets/icons/users.png",
                          label: "Manage User",
                          onTap: () {
                            // Add action for order food
                            Get.toNamed(Routes.adminManageUsers);

                          },
                        ),
                        const SizedBox(  width: 12,
                        ),

                        ReceptionHomeGridItem(
                          height: 182,
                          width: 186,
                          widthRatio: 0.42,
                          iconHeight: 86,
                          iconWidth: 86,
                          icon: "assets/icons/check_in_circle.png",
                          label: "Check In List",
                          onTap: () {
                            // Add action for room service
                              Get.toNamed(Routes.adminCheckInList);


                          },
                        )
                      ],
                    ),
                        const SizedBox(
                          height: 12,
                        ),
                        ReceptionHomeGridItem(
                          width: 354,
                          height: 84,
                          widthRatio: 0.90,
                          isFeedbackList: true,
                          iconHeight: 55,
                          iconWidth: 55,
                          icon: "assets/icons/feedback.png",
                          label: "Vouchers",
                          onTap: () {
                            Get.toNamed(Routes.adminManageVoucher);


                          },
                        )

                      ],
                    ),

                  ],
                ),
              ),
            ),
          ),
        );
  }

  Future<void> sendTestNotification() async {
    final url = 'https://us-central1-wander-crew.cloudfunctions.net/sendTestNotification';
    final response = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'token': "flaZkF-FT4CaZoUWSy2hb9:APA91bEbC3Y6N-G6o-kX0W4BYnDiwrA_YGD-_a7Qb_-1i4mRMSibvNq2eCL3hDbtKdmxpXAEz05j_1_vvPqfvTURTu22Qs801iOAssny5mHiWW39lvUcjO48xZ_qg8_d9E6KJzYLitRb"}),
    );

    if (response.statusCode == 200) {
      print('Notification sent successfully');
    } else {
      print('Failed to send notification: ${response.body}');
    }
  }


}
