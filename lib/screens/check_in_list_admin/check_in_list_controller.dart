import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:printing/printing.dart';
import '../../../models/self_checking_model.dart';
import '../../../utils/date_time.dart';
import 'dart:io' as io;
import 'package:http/http.dart' as http;
import 'package:pdf/widgets.dart' as pw;
import '../../../widgets/app_elevated_button.dart';
import '../../../widgets/edit_text.dart';
import '../../../widgets/elevated_container.dart';
import '../../../widgets/widget_support.dart';
import '../../utils/show_loading_dialog.dart';

class CheckInListController extends GetxController {



  @override
  void onInit() {
    super.onInit();
    fetchCheckInList(); // Fetch data when controller is initialized
  }

  TextEditingController filterFromDate = TextEditingController();
  TextEditingController filterToDate = TextEditingController();

  RxInt activeFilterCount = 0.obs;

  var isLoading = true.obs; // Loading state

  RxList<SelfCheckInModel> checkInList =
      <SelfCheckInModel>[].obs; // Using observable list
  RxMap<String, List<SelfCheckInModel>> groupedCheckIns =
      <String, List<SelfCheckInModel>>{}.obs;

  RxMap<String, List<SelfCheckInModel>> originalGroupedCheckIns =
      <String, List<SelfCheckInModel>>{}.obs;

  void applyRangeFilters() {
    // Create a new filtered map
    RxMap<String, List<SelfCheckInModel>> filteredCheckIns = <String, List<SelfCheckInModel>>{}.obs;

    // Loop through the original groupedCheckIns map
    originalGroupedCheckIns.forEach((key, checkInList) {
      // Apply filters to each list of check-ins
      List<SelfCheckInModel> filteredList = checkInList.where((checkIn) {
        bool matchesDateRange = true;

        // Check if the start date is provided
        if (filterFromDate.text.isNotEmpty) {
          DateTime start = DateFormat("dd-MMM-yy").parse(filterFromDate.text);
          matchesDateRange = checkIn.createdAt.isAfter(start);
        }

        // Check if the end date is provided
        if (filterToDate.text.isNotEmpty) {
          DateTime end = DateFormat("dd-MMM-yy").parse(filterToDate.text);
          matchesDateRange = matchesDateRange && checkIn.createdAt.isBefore(end.add(const Duration(days: 1)));
        }

        return matchesDateRange;
      }).toList();

      // Only add the key if there are any matching check-ins
      if (filteredList.isNotEmpty) {
        filteredCheckIns[key] = filteredList;
      }
    });

    // Assign the filtered map to groupedCheckIns
    groupedCheckIns.value = filteredCheckIns;

    // Call update to refresh UI or dependent components
    update();
  }











  void searchFilterCheckInList(String query) {
    if (query.isEmpty) {
      // Restore the original grouped check-ins when the query is empty
      groupedCheckIns.assignAll(originalGroupedCheckIns);
      applyRangeFilters();
    } else {
      final queryLower = query.toLowerCase();

      // Create a new map to hold the filtered results
      Map<String, List<SelfCheckInModel>> filteredGroupedData = {};

      // Loop through each group (date as key) and filter the corresponding list of check-ins
      originalGroupedCheckIns.forEach((date, checkIns) {
        List<SelfCheckInModel> filteredCheckIns = checkIns.where((item) {
          return item.fullName.toLowerCase().contains(queryLower) ||
              item.contact.toLowerCase().contains(queryLower) ||
              (item.address ?? "address").toLowerCase().contains(queryLower) ||
              (item.email ?? "").toLowerCase().contains(queryLower) ||
              item.regionState.toLowerCase().contains(queryLower);
        }).toList();

        // Only add to the filteredGroupedData if there are matching check-ins for this date
        if (filteredCheckIns.isNotEmpty) {
          filteredGroupedData[date] = filteredCheckIns;
        }
      });

      // Update the observable with the filtered data
      groupedCheckIns.assignAll(filteredGroupedData);
      applyRangeFilters();

    }

    update(); // Update UI to reflect changes
  }

  Future<void> fetchCheckInList() async {
    try {
      isLoading.value = true; // Start loading

      QuerySnapshot querySnapshot =
      await FirebaseFirestore.instance.collection("Self_Check_In").get();

      // Mapping Fire store data to model and updating observable list
      List<SelfCheckInModel> newList = querySnapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

        // Log data to help trace the issue
        // print("Document ID: ${doc.id}");
        // print("Raw Data: $data");

        try {
          return SelfCheckInModel.fromMap(data); // Using fromMap factory constructor
        } catch (e) {
          // print("Error parsing document ID: ${doc.id}, Error: $e");
          throw 'Error in document ${doc.id}: $e'; // Re-throw error with document info
        }
      }).toList();

      //   return SelfCheckInModel.fromMap(
      //       data); // Using fromMap factory constructor
      // }).toList();
      // // print(newList);

      // Updating observable list
      checkInList.assignAll(newList);
      groupCheckInsByDate();
      update();
    } catch (e) {
      debugPrint('Error: Failed to fetch list $e');

      // print(e);
    }finally {
      // print("Aaaaa");
      isLoading.value = false; // End loading
    }
  }

  void groupCheckInsByDate() {
    Map<String, List<SelfCheckInModel>> groupedData = {};
    for (var checkIn in checkInList) {
      // Formatting DateTime to a string date
      String formattedDate =
      DateTimeUtils.formatDDMMYYYYWithSlashes(checkIn.createdAt);
      if (!groupedData.containsKey(formattedDate)) {
        groupedData[formattedDate] = [];
      }
      groupedData[formattedDate]!.add(checkIn);
    }
    groupedCheckIns.assignAll(groupedData);
    originalGroupedCheckIns.assignAll(groupedData);
    update();
  }

  // Function to download an image (works for both Android and Web)
  void downloadFile(
      {required String imageUrl, required String fileName}) async {

      // For Android
      await downloadFileAndroid(imageUrl, fileName);
  }



  // Function for Android download
  static Future<void> downloadFileAndroid(String imageUrl,
      String fileName) async {
    try {

      showLoadingDialog();
      // Get directory to save the file
      var directory = await getExternalStorageDirectory();
      String savePath = '${directory!.path}/$fileName';

      // Download the file using Dio
      Dio dio = Dio();
      await dio.download(imageUrl, savePath);
      Get.back();

      // Notify user that the download is successful
      // print("File downloaded at $savePath");
    } catch (e) {
      Get.back();

      // print("Error downloading file: $e");
    }
  }

  // Get the external storage directory for Android
  static Future<io.Directory?> getExternalStorageDirectory() async {
    io.Directory? directory = await getApplicationDocumentsDirectory();
    return directory;
  }


// Function to download the PDF
  Future<void> downloadCheckInAsPdf(SelfCheckInModel checkInItem) async {
    try {
      showLoadingDialog();

    final pdf = pw.Document();

    // Fetch images first
    final frontImage = await _fetchImage(checkInItem.frontDocumentUrl);
    var backImage;
    if(checkInItem.backDocumentUrl != null ) backImage = await _fetchImage(checkInItem.backDocumentUrl!);
    final signatureImage = await _fetchImage(checkInItem.signatureUrl);

    // Add a page with text and images
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
                _buildInfoRow('Full Name', checkInItem.fullName),
                _buildInfoRow('Document Type', checkInItem.documentType),
                _buildInfoRow('Contact', checkInItem.contact),
                _buildInfoRow('Age', checkInItem.age.toString()),
                _buildInfoRow('Gender', checkInItem.gender),
                _buildInfoRow('Country', checkInItem.country),
                _buildInfoRow('State', checkInItem.regionState),
                if (checkInItem.email != null)
                  _buildInfoRow('Email', checkInItem.email!),
                if (checkInItem.address != null)
                  _buildInfoRow('Address', checkInItem.address!),
                if (checkInItem.city != null)
                  _buildInfoRow('City', checkInItem.city!),
                if (checkInItem.arrivingFrom != null)
                  _buildInfoRow('Arriving From', checkInItem.arrivingFrom!),
                if (checkInItem.goingTo != null)
                  _buildInfoRow('Going To', checkInItem.goingTo!),
                pw.SizedBox(height: 10),
                pw.Text('Documents',
                    style: pw.TextStyle(
                        fontSize: 18, fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 10),
                pw.Image(
                    frontImage, height: 150, width: 150, fit: pw.BoxFit.cover),
                pw.SizedBox(height: 10),
                if(checkInItem.backDocumentUrl !=null)
                pw.Image(
                    backImage, height: 150, width: 150, fit: pw.BoxFit.cover),
                pw.SizedBox(height: 10),
                pw.Image(signatureImage, height: 150,
                    width: 150,
                    fit: pw.BoxFit.cover),
              ],
            ),
      ),
    );

    // Generate the PDF as bytes and save it
    await _savePdf(pdf, "${checkInItem.fullName} Check In Details.pdf");
    Get.back();

    }
    catch (e){

      Get.back();
      debugPrint('Error: Failed to download $e');


    }
  }

// Helper function to fetch images from URL
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
  static pw.Widget _buildInfoRow(String label, String value) {
    return pw.Row(
      children: [
        pw.Text('$label: ',
            style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
        pw.Text(value),
      ],
    );
  }


  // Function to save and download the PDF file
  static Future<void> _savePdf(pw.Document pdf, String fileName) async {
    // For Web

      // For Mobile (Android/iOS)
      final pdfBytes = await pdf.save();
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/checkin_details.pdf');
      await file.writeAsBytes(pdfBytes);
      await Printing.sharePdf(bytes: pdfBytes, filename: 'checkin_details.pdf');

  }


  Future<void> addNote(SelfCheckInModel item) async {
    TextEditingController noteController = TextEditingController(
        text: item.notes ?? "");

    if (item.notes != null) {
      noteController.text = item.notes!;
    }
    // Show a confirmation dialog
    showDialog(
      context: Get.context!,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius:
            BorderRadius.circular(12.0), // Customize the radius here
          ),
          backgroundColor: const Color(0xffFFFEF9),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding:
                const EdgeInsets.only(top: 20, right: 20.0, left: 20),
                child: Text(
                  "Modify",
                  style: AppWidget.black20Text600Style(),
                ),
              ),
              const SizedBox(
                height: 12,
              ),
              Padding(
                padding: const EdgeInsets.only(
                    bottom: 16, right: 20.0, left: 20),
                child: ElevatedContainer(
                  child: EditText(
                    labelFontWeight: FontWeight.w600,
                    labelText: "Note",
                    hint: "Enter Note",
                    controller:noteController,
                    inputType: TextInputType.number,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AppElevatedButton(
                    onPressed: (){
                      Get.back();
                    },
                    title: "Back",
                    titleTextColor: Colors.black,
                    backgroundColor: Colors.transparent,
                    showBorder: true,
                  ),
                  const SizedBox(width: 12,),
                  AppElevatedButton(
                    onPressed: () async {
                      showLoadingDialog();



                      String newNote = noteController.text;
                      // Update the note in the database
                      await FirebaseFirestore.instance.collection("Self_Check_In")
                          .doc(item.id)
                          .update({'notes': newNote,'updatedAt':DateTime.now(),'updatedBy':"Admin"});

                      // Update local item note
                      item.notes = newNote;
                      update();

                      // Close the dialog
                      Get.back();
                      Get.back();

                    },

                    title: "Apply",
                  ),
                ],
              ),
              const SizedBox(height: 16),

            ],
          ),
        );
      },
    );
  }


  Future<void> deleteNote(SelfCheckInModel item) async {

    showLoadingDialog();

      // Update the note in the database
      await FirebaseFirestore.instance.collection("Self_Check_In")
          .doc(item.id)
          .update({'notes': null});

      // Update local item note
      item.notes = null;
      update();

      Get.back();

  }

}
