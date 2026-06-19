// // import 'package:flutter/material.dart';
// // import 'package:greencollar/speech_helper.dart';
// // import 'dart:async';
// // import 'dart:convert';
// //
// // import 'package:flutter/material.dart';
// // import 'package:flutter_secure_storage/flutter_secure_storage.dart';
// // import 'package:fluttertoast/fluttertoast.dart';
// // import 'package:greencollar/Addproject.dart';
// // import 'package:greencollar/HomeScree.dart';
// // import 'package:greencollar/NearbyProject.dart';
// // import 'package:greencollar/Nearbylabours.dart';
// // import 'package:greencollar/UpdateProject.dart';
// // import 'package:greencollar/application_detaill.dart';
// // import 'package:greencollar/l10n/app_localizations.dart';
// // import 'package:greencollar/main.dart';
// // import 'package:intl/intl.dart';
// // import 'package:provider/provider.dart';
// // import 'package:http/http.dart' as http;
// // import 'package:translator/translator.dart';
// // import 'package:url_launcher/url_launcher.dart';
// // import 'package:cached_network_image/cached_network_image.dart';
// // import 'package:greencollar/constants.dart' as Constants;
// // import 'package:carousel_slider/carousel_slider.dart';
// // import 'package:smooth_page_indicator/smooth_page_indicator.dart';
// //
// // class FarmerMilestoneService {
// //   static const String _baseUrl =
// //       '${Constants.AppConstants.apiUrl}farmer/confirmcompletemilestone'; // Update with your actual API URL
// //
// //   // Function to send milestone completion request
// //   static Future<Map<String, dynamic>> completeMilestone({
// //     required int projectId,
// //     required String milestoneSno,
// //     required int labourId,
// //   }) async {
// //     final Uri url = Uri.parse(_baseUrl);
// //
// //     try {
// //       // Prepare the request payload
// //       final Map<String, dynamic> payload = {
// //         "projectid": projectId,
// //         "milestonesno": milestoneSno,
// //         "labourid": labourId,
// //       };
// //       print(jsonEncode(payload));
// //       // Send the POST request
// //       final response = await http.post(
// //         url,
// //         headers: {
// //           "Content-Type": "application/json",
// //           "Accept": "application/json",
// //         },
// //         body: jsonEncode(payload),
// //       );
// //
// //       // Check the response status
// //       if (response.statusCode == 200) {
// //         final Map<String, dynamic> responseBody = json.decode(response.body);
// //         return responseBody;
// //       } else {
// //         // Handle non-200 status codes
// //         return {
// //           "status": "0",
// //           "message":
// //               "Failed to complete milestone. Status Code: ${response.statusCode}"
// //         };
// //       }
// //     } catch (e) {
// //       // Handle exceptions
// //       return {"status": "0", "message": "An error occurred: $e"};
// //     }
// //   }
// // }
// //
// // class ApplicationDetailPage extends StatefulWidget {
// //   final Map<String, dynamic> application;
// //
// //   // Constructor to receive application data
// //   ApplicationDetailPage({required this.application});
// //
// //   @override
// //   State<ApplicationDetailPage> createState() => _ApplicationDetailPageState();
// // }
// //
// // class _ApplicationDetailPageState extends State<ApplicationDetailPage> {
// //   final _secureStorage = const FlutterSecureStorage();
// //   // Controllers for each TextField to handle editing
// //   late TextEditingController labourNameController;
// //   late TextEditingController locationController;
// //   late TextEditingController budgetController;
// //   late TextEditingController durationController;
// //   late TextEditingController statusController;
// //   late TextEditingController remarksController;
// //   late TextEditingController praposalamountController;
// //
// //   @override
// //   void initState() {
// //     super.initState();
// //     loadLanguage();
// //     // Initialize the controllers with the existing values or default values
// //     labourNameController =
// //         TextEditingController(text: widget.application['labour_name'] ?? 'N/A');
// //     labourNameController =
// //         TextEditingController(text: widget.application['labour_name'] ?? 'N/A');
// //     locationController = TextEditingController(
// //         text:
// //             '${widget.application['labour_address']}, ${widget.application['labour_city']}, ${widget.application['labour_state']}');
// //     budgetController =
// //         TextEditingController(text: widget.application['budget'] ?? 'N/A');
// //     durationController = TextEditingController(
// //         text: widget.application['day_to_complete'] ?? 'N/A');
// //     statusController =
// //         TextEditingController(text: _getStatus(widget.application['status']));
// //     remarksController =
// //         TextEditingController(text: widget.application['comment'] ?? 'N/A');
// //     praposalamountController = TextEditingController(
// //         text: widget.application['proposal_amount'] ?? 'N/A');
// //   }
// //
// //   @override
// //   void dispose() {
// //     // Dispose of controllers when the widget is disposed to free up resources
// //     labourNameController.dispose();
// //     locationController.dispose();
// //     budgetController.dispose();
// //     durationController.dispose();
// //     statusController.dispose();
// //     remarksController.dispose();
// //     super.dispose();
// //   }
// //
// //   String _selectedLanguage = 'en'; // Default language is English
// //
// //   Future<void> loadLanguage() async {
// //     // Read the selected language from FlutterSecureStorage
// //     String? language = await _secureStorage.read(key: 'selectedLanguage');
// //     _selectedLanguage = language ?? 'en';
// //     print(language); // Default to English if null
// //   }
// //
// //   Map<String, Map<String, String>> _cachedTranslations = {};
// //
// //   Map<String, Map<String, String>> translations =
// //       Constants.AppConstants.translations;
// //   final GoogleTranslator _translator = GoogleTranslator();
// //   String translateText(String text) {
// //     if (text.isEmpty) return "";
// //
// //     // ✅ Ensure `_selectedLanguage` is set before calling `translateText()`
// //     String targetLang = _selectedLanguage ?? 'en'; // Default to English if null
// //
// //     // ✅ Check manual translations first
// //     if (translations.containsKey(text) &&
// //         translations[text]!.containsKey(targetLang)) {
// //       return translations[text]![targetLang]!; // Return manual translation
// //     }
// //
// //     // ✅ Check cached translations
// //     if (_cachedTranslations.containsKey(text) &&
// //         _cachedTranslations[text]!.containsKey(targetLang)) {
// //       return _cachedTranslations[text]![
// //           targetLang]!; // Return cached translation
// //     }
// //
// //     // ✅ Fetch translation dynamically (but without `await`)
// //     _fetchTranslation(text, targetLang); // Runs in background, no need to wait
// //
// //     return text; // Return original text while translation is being fetched
// //   }
// //
// //   /// ✅ Fetch translation dynamically and update cache
// //   Future<void> _fetchTranslation(String text, String targetLang) async {
// //     try {
// //       // ✅ Check if translation already exists in constants
// //       if (Constants.AppConstants.translations.containsKey(text) &&
// //           Constants.AppConstants.translations[text]!.containsKey(targetLang)) {
// //         return; // No need to fetch if it exists
// //       }
// //
// //       // ✅ Fetch translation dynamically
// //       final translation = await _translator.translate(text, to: targetLang);
// //
// //       // ✅ Initialize default values if text is not in the map
// //       if (!translations.containsKey(text)) {
// //         translations[text] = {
// //           "en": text,
// //           "hi": text
// //         }; // Default to the same value
// //       }
// //
// //       // ✅ Store the translation in the correct language
// //       translations[text]![targetLang] = translation.text;
// //
// //       // ✅ Store fetched translations in the cache
// //       _cachedTranslations = translations;
// //
// //       // ✅ Also store in the constants translations map
// //       if (!Constants.AppConstants.translations.containsKey(text)) {
// //         Constants.AppConstants.translations[text] = {};
// //       }
// //       Constants.AppConstants.translations[text]![targetLang] = translation.text;
// //
// //       // ✅ Check for missing translations and fetch dynamically
// //       for (var key in translations.keys) {
// //         if (!translations[key]!.containsKey("hi")) {
// //           await _fetchTranslation(key, "hi");
// //         }
// //         if (!translations[key]!.containsKey("en")) {
// //           await _fetchTranslation(key, "en");
// //         }
// //       }
// //
// //       // ✅ Store translation in cache
// //       _cachedTranslations.putIfAbsent(text, () => {})[targetLang] =
// //           translation.text;
// //       setState(() {});
// //     } catch (e) {
// //       print("Translation error: $e");
// //     }
// //   }
// //
// //   Future<void> unassignProject(String labourId, String projectId) async {
// //     // API URL
// //     String url = '${Constants.AppConstants.apiUrl}farmer/unassignProject';
// //
// //     // Sending POST request
// //     try {
// //       final response = await http.post(
// //         Uri.parse(url),
// //         headers: {'Content-Type': 'application/json'},
// //         body: json.encode({
// //           'labourids': labourId,
// //           'projectids': projectId,
// //         }),
// //       );
// //
// //       if (response.statusCode == 200) {
// //         // Success, show message and update UI
// //         final data = json.decode(response.body);
// //         if (data['status'] == '1') {
// //           Fluttertoast.showToast(
// //             msg: translate('Project Unassigned Successfully!',
// //                 'प्रोजेक्ट अनअसाइन्ड सफलतापूर्वक!'),
// //             toastLength: Toast.LENGTH_SHORT,
// //             gravity: ToastGravity.BOTTOM,
// //             backgroundColor: Constants.AppColors.brand,
// //             textColor: Constants.AppColors.card,
// //             fontSize: 16.0,
// //           );
// //           Future.delayed(Duration(seconds: 1), () {
// //             Navigator.pushReplacement(
// //               context,
// //               MaterialPageRoute(
// //                 builder: (context) => HomePage(),
// //               ),
// //             );
// //           });
// //         }
// //       } else {
// //         ScaffoldMessenger.of(context).showSnackBar(
// //           SnackBar(
// //               content: Text(translate(
// //                   'Failed to unassign job', 'काम असाइन करने में विफल'))),
// //         );
// //       }
// //     } catch (e) {
// //       // ScaffoldMessenger.of(context).showSnackBar(
// //       //   SnackBar(content: Text(translate('Error: $e', 'त्रुटि: $e'))),
// //       // );
// //     }
// //   }
// //
// //   Future<void> cancelConfirm(
// //       String projectId, String labourId, String cancelRemark) async {
// //     // API URL
// //     String url = '${Constants.AppConstants.apiUrl}farmer/cancelConfirm';
// //
// //     // Sending POST request
// //     try {
// //       final response = await http.post(
// //         Uri.parse(url),
// //         headers: {'Content-Type': 'application/json'},
// //         body: json.encode({
// //           'projectid': projectId,
// //           'labourid': labourId,
// //           'cancelremark': cancelRemark,
// //         }),
// //       );
// //
// //       if (response.statusCode == 200) {
// //         // Success, show message and update UI
// //         final data = json.decode(response.body);
// //         if (data['status'] == '1') {
// //           Fluttertoast.showToast(
// //             msg: translate('Cancel request Sent Successfully!',
// //                 'अनुरोध रद्द करें सफलतापूर्वक भेजा गया!'),
// //             toastLength: Toast.LENGTH_SHORT,
// //             gravity: ToastGravity.BOTTOM,
// //             backgroundColor: Constants.AppColors.brand,
// //             textColor: Constants.AppColors.card,
// //             fontSize: 16.0,
// //           );
// //           Future.delayed(Duration(seconds: 1), () {
// //             Navigator.pushReplacement(
// //               context,
// //               MaterialPageRoute(
// //                 builder: (context) => HomePage(),
// //               ),
// //             );
// //           });
// //         }
// //       } else {
// //         ScaffoldMessenger.of(context).showSnackBar(
// //           SnackBar(
// //               content: Text(translate('Failed to send cancel request',
// //                   'कृपया रद्द अनुरोध भेजने में विफल'))),
// //         );
// //       }
// //     } catch (e) {}
// //   }
// //
// //   // Function to show the dialog for cancel remarks
// //   void showCancelDialog(BuildContext context, String labourId) {
// //     TextEditingController _cancelRemarkController = TextEditingController();
// //
// //     showDialog(
// //       context: context,
// //       builder: (BuildContext context) {
// //         return AlertDialog(
// //           title: Text(translate('Cancel Remark', 'रद्द टिप्पणी')),
// //           content: Column(
// //             mainAxisSize: MainAxisSize.min,
// //             children: [
// //               TextField(
// //                 controller: _cancelRemarkController,
// //                 decoration: InputDecoration(
// //                   labelText: translate(
// //                       'Enter Cancel Remark', 'रद्द टिप्पणी दर्ज करें'),
// //                   border: OutlineInputBorder(),
// //                   suffixIcon: MicIconButton(controller: _cancelRemarkController),
// //                 ),
// //                 maxLines: 3,
// //               ),
// //             ],
// //           ),
// //           actions: <Widget>[
// //             TextButton(
// //               onPressed: () {
// //                 Navigator.of(context).pop();
// //               },
// //               child: Text(translate('Cancel', 'रद्द करें')),
// //             ),
// //             TextButton(
// //               onPressed: () {
// //                 if (_cancelRemarkController.text.isNotEmpty) {
// //                   cancelConfirm(
// //                     widget.application['projectID'].toString(),
// //                     labourId,
// //                     _cancelRemarkController.text,
// //                   );
// //                   Navigator.of(context).pop(); // Close the dialog
// //                 } else {
// //                   ScaffoldMessenger.of(context).showSnackBar(
// //                     SnackBar(
// //                         content: Text(translate('Remark cannot be empty',
// //                             'टिप्पणी खाली नहीं हो सकती'))),
// //                   );
// //                 }
// //               },
// //               child: Text(translate('Submit', 'सबमिट करें')),
// //             ),
// //           ],
// //         );
// //       },
// //     );
// //   }
// //
// //   Future<void> confirmComplete(String projectId, String labourId) async {
// //     // API URL
// //     String url = '${Constants.AppConstants.apiUrl}farmer/confirmComplete';
// //
// //     // Sending POST request
// //     try {
// //       final response = await http.post(
// //         Uri.parse(url),
// //         headers: {'Content-Type': 'application/json'},
// //         body: json.encode({
// //           'projectid': projectId,
// //           'labourid': labourId,
// //         }),
// //       );
// //
// //       if (response.statusCode == 200) {
// //         // Success, show message and update UI
// //         final data = json.decode(response.body);
// //         if (data['status'] == '1') {
// //           Fluttertoast.showToast(
// //             msg: translate(
// //                 'Confirm Completion Successful!', 'सफल समापन की पुष्टि!'),
// //             toastLength: Toast.LENGTH_SHORT,
// //             gravity: ToastGravity.BOTTOM,
// //             backgroundColor: Colors.green.shade700,
// //             textColor: Colors.white,
// //             fontSize: 16.0,
// //           );
// //           Future.delayed(Duration(seconds: 1), () {
// //             Navigator.pushReplacement(
// //               context,
// //               MaterialPageRoute(
// //                 builder: (context) => HomePage(),
// //               ),
// //             );
// //           });
// //         }
// //       } else {
// //         ScaffoldMessenger.of(context).showSnackBar(
// //           SnackBar(
// //               content: Text(translate('Failed to confirm completion',
// //                   'पूरा होने की पुष्टि करने में विफल'))),
// //         );
// //       }
// //     } catch (e) {
// //       ScaffoldMessenger.of(context).showSnackBar(
// //         SnackBar(content: Text(translate('Error: $e', 'त्रुटि: $e'))),
// //       );
// //     }
// //   }
// //
// //   Future<void> assignProject(String labourId, BuildContext context,
// //       {String paymentStatus = '0', double jobBudget = 1000.0}) async {
// //     final String apiUrl =
// //         '${Constants.AppConstants.apiUrl}farmer/projectAssigned';
// //     String? userId = await _secureStorage.read(key: 'id');
// //
// //     if (userId == null) {
// //       ScaffoldMessenger.of(context).showSnackBar(
// //         SnackBar(
// //             content: Text(translate('User ID not found in secure storage',
// //                 'सिक्योर स्टोरेज में उपयोगकर्ता आईडी नहीं मिली'))),
// //       );
// //       return;
// //     }
// //
// //     // Show initial confirmation dialog asking if they want to assign the job
// //     bool? shouldAssignProject = await _showAssignJobConfirmationDialog(context);
// //
// //     if (shouldAssignProject != null && shouldAssignProject) {
// //       // Calculate proposal amount as int
// //       int proposalAmount =
// //           (milestones.isNotEmpty && milestones[0]['proposalamount'] != null)
// //               ? (milestones[0]['proposalamount']).toInt()
// //               : ((double.tryParse(budgetController.text) ?? 0) * 0.10).toInt();
// //
// //       if (paymentStatus == '0') {
// //         bool? makePayment = await _showPaymentConfirmationDialog(
// //             context, jobBudget, proposalAmount);
// //         if (makePayment != null && makePayment) {
// //           // Proceed with the project assignment after payment confirmation
// //           await _assignProjectToLabour(labourId, context);
// //         } else {
// //           // Handle cancellation or not making the payment
// //           ScaffoldMessenger.of(context).showSnackBar(
// //             SnackBar(
// //                 content: Text(translate(
// //                     'Project assignment aborted due to payment',
// //                     'भुगतान के कारण परियोजना सौंपने से रोक दिया गया'))),
// //           );
// //         }
// //       } else {
// //         // If payment is not required, proceed with the assignment
// //         await _assignProjectToLabour(labourId, context);
// //       }
// //     }
// //   }
// //
// // // Method to show confirmation dialog for assigning job
// //   // Method to show confirmation dialog for assigning job
// //   Future<bool?> _showAssignJobConfirmationDialog(BuildContext context) {
// //     final language =
// //         Provider.of<LanguageProvider>(context, listen: false).selectedLanguage;
// //
// //     String translate(String enText, String hiText) {
// //       return language == 'en' ? enText : hiText;
// //     }
// //
// //     return showDialog<bool>(
// //       context: context,
// //       builder: (context) {
// //         return AlertDialog(
// //           title: Text(translate('Do you want to assign this job?',
// //               'क्या आप इस नौकरी को सौंपना चाहते हैं?')),
// //           content: Text(
// //             translate(
// //                 'Are you sure you want to assign this job to the selected labour?',
// //                 'क्या आप सुनिश्चित हैं कि आप इस नौकरी को चयनित श्रमिक को सौंपना चाहते हैं?'),
// //           ),
// //           actions: [
// //             TextButton(
// //               onPressed: () {
// //                 Navigator.of(context).pop(false);
// //               },
// //               child: Text(translate('Cancel', 'रद्द करें')),
// //             ),
// //             TextButton(
// //               onPressed: () {
// //                 Navigator.of(context).pop(true);
// //               },
// //               child: Text(translate('Yes', 'हाँ')),
// //             ),
// //           ],
// //         );
// //       },
// //     );
// //   }
// //
// // // Method to show payment confirmation dialog if payment is required
// //   Future<bool?> _showPaymentConfirmationDialog(
// //       BuildContext context, double jobBudget, int proposalAmount) {
// //     final language =
// //         Provider.of<LanguageProvider>(context, listen: false).selectedLanguage;
// //
// //     String translate(String enText, String hiText) {
// //       return language == 'en' ? enText : hiText;
// //     }
// //
// //     return showDialog<bool>(
// //       context: context,
// //       builder: (context) {
// //         return AlertDialog(
// //           title: Text(translate('Payment Required', 'भुगतान आवश्यक है')),
// //           content: Text(
// //             translate(
// //                 'Please make an advance payment of ₹${proposalAmount.toStringAsFixed(2)} to proceed with the assignment.',
// //                 'कृपया असाइनमेंट की प्रक्रिया के लिए ₹${proposalAmount.toStringAsFixed(2)} की अग्रिम भुगतान करें।'),
// //           ),
// //           actions: [
// //             TextButton(
// //               onPressed: () => Navigator.of(context).pop(false),
// //               child: Text(translate('Cancel', 'रद्द करें')),
// //             ),
// //             TextButton(
// //               onPressed: () => Navigator.of(context).pop(true),
// //               child: Text(
// //                   translate('Proceed with Payment', 'भुगतान के साथ आगे बढ़ें')),
// //             ),
// //           ],
// //         );
// //       },
// //     );
// //   }
// //
// //   String translate(String enText, String hiText) {
// //     // Get the selected language from the provider
// //     final language =
// //         Provider.of<LanguageProvider>(context, listen: false).selectedLanguage;
// //
// //     // Return the appropriate text based on the selected language
// //     return language == 'en' ? enText : hiText;
// //   }
// //
// //   Future<void> _assignProjectToLabour(
// //       String labourId, BuildContext context) async {
// //     final String apiUrl =
// //         '${Constants.AppConstants.apiUrl}farmer/projectAssigned';
// //     String? userId = await _secureStorage.read(key: 'id');
// //
// //     if (userId == null) {
// //       ScaffoldMessenger.of(context).showSnackBar(
// //         SnackBar(
// //             content: Text(translate('User ID not found in secure storage',
// //                 'सिक्योर स्टोरेज में उपयोगकर्ता आईडी नहीं मिली'))),
// //       );
// //       return;
// //     }
// //
// //     // Prepare the request body for assigning the project
// //     final Map<String, dynamic> requestBody = {
// //       'labourid': labourId,
// //       'projectid': widget.application['projectID'].toString(),
// //     };
// //     print(
// //       jsonEncode(requestBody),
// //     );
// //     try {
// //       final response = await http.post(
// //         Uri.parse(apiUrl),
// //         headers: {'Content-Type': 'application/json'},
// //         body: jsonEncode(requestBody),
// //       );
// //
// //       if (response.statusCode == 200) {
// //         final responseData = json.decode(response.body);
// //         if (responseData['status'] == 1) {
// //           setState(() {});
// //           Fluttertoast.showToast(
// //             msg: translate('Project assigned successfully',
// //                 'परियोजना सफलतापूर्वक सौंपा गया'),
// //             toastLength: Toast.LENGTH_SHORT,
// //             gravity: ToastGravity.BOTTOM,
// //             backgroundColor: Constants.AppColors.brand,
// //             textColor: Constants.AppColors.card,
// //             fontSize: 16.0,
// //           );
// //
// //           Future.delayed(Duration(seconds: 1), () {
// //             Navigator.pushReplacement(
// //               context,
// //               MaterialPageRoute(
// //                 builder: (context) => HomePage(),
// //               ),
// //             );
// //           });
// //         } else {
// //           ScaffoldMessenger.of(context).showSnackBar(
// //             SnackBar(
// //                 content: Text(translate('Failed to assign project: ',
// //                         'परियोजना सौंपने में विफल: ') +
// //                     responseData['message'])),
// //           );
// //         }
// //       } else {
// //         ScaffoldMessenger.of(context).showSnackBar(
// //           SnackBar(
// //               content: Text(translate(
// //                   'Failed to assign project', 'परियोजना सौंपने में विफल'))),
// //         );
// //       }
// //     } catch (e) {
// //       // Handle exception if needed
// //       print(e);
// //     }
// //   }
// //
// //   void handleMilestoneCompletion(BuildContext context, String milestone) async {
// //     // Retrieve user ID from secure storage
// //     String? userId = await _secureStorage.read(key: 'id');
// //     if (userId == null) {
// //       ScaffoldMessenger.of(context).showSnackBar(
// //         const SnackBar(
// //           content: Text('User ID not found in secure storage'),
// //           backgroundColor: Colors.red,
// //         ),
// //       );
// //       return;
// //     }
// //
// //     // Prepare parameters
// //     int projectId = widget.application['projectID'];
// //     String milestoneSno =
// //         milestone; // Convert milestone to int, default to 1 if invalid
// //     int labourId = widget.application['labourID'];
// //
// //     // Call the milestone completion API
// //     final result = await FarmerMilestoneService.completeMilestone(
// //       projectId: projectId,
// //       milestoneSno: milestoneSno,
// //       labourId: labourId,
// //     );
// //     Fluttertoast.showToast(
// //       msg: translate(result['message'] ?? 'अज्ञात प्रतिक्रिया',
// //           'परियोजना सफलतापूर्वक सौंपा गया'),
// //       toastLength: Toast.LENGTH_SHORT,
// //       gravity: ToastGravity.BOTTOM,
// //       backgroundColor: Constants.AppColors.brand,
// //       textColor: Constants.AppColors.card,
// //       fontSize: 16.0,
// //     );
// //     // Show the result in a SnackBar
// //   }
// //
// //   double _rating = 1.0;
// //   TextEditingController _remarksController = TextEditingController();
// //   List<Map<String, dynamic>> milestones = [];
// //   Future<void> _submitReview() async {
// //     const String _baseUrl =
// //         '${Constants.AppConstants.apiUrl}farmer/reviewForLabour'; // Update with your actual API URL
// //     print(_baseUrl);
// //
// //     // Prepare the request body
// //     final Map<String, dynamic> requestBody = {
// //       'projectid': widget.application['projectID'].toString(),
// //       'labourid': widget.application['labourID'].toString(),
// //       'rating': _rating,
// //       'review': _remarksController.text,
// //     };
// //
// //     print(
// //       jsonEncode(requestBody),
// //     );
// //
// //     try {
// //       final response = await http.post(
// //         Uri.parse(_baseUrl), // Replace with your API URL
// //         body: jsonEncode(requestBody),
// //         headers: {
// //           'Content-Type': 'application/json',
// //         },
// //       );
// //
// //       if (response.statusCode == 200) {
// //         // Handle the response
// //         final responseData = jsonDecode(response.body);
// //         if (responseData['status'] == "1") {
// //           Fluttertoast.showToast(
// //             msg: translate('Review submitted successfully!',
// //                 'समीक्षा सफलतापूर्वक प्रस्तुत की गई!'),
// //             toastLength: Toast.LENGTH_SHORT,
// //             gravity: ToastGravity.BOTTOM,
// //             backgroundColor: Constants.AppColors.brand,
// //             textColor: Constants.AppColors.card,
// //             fontSize: 16.0,
// //           );
// //         } else {
// //           // Show failure message in the appropriate language
// //           ScaffoldMessenger.of(context).showSnackBar(
// //             SnackBar(
// //                 content: Text(
// //               translate('Failed to submit review.',
// //                   'समीक्षा प्रस्तुत करने में विफल।'), // Use custom translate function
// //             )),
// //           );
// //         }
// //       } else {
// //         // Error with response
// //       }
// //     } catch (e) {
// //       // Network or other failure
// //     }
// //   }
// //
// //   void _showReviewDialog() {
// //     showDialog(
// //       context: context,
// //       builder: (context) {
// //         return StatefulBuilder(
// //           builder: (BuildContext context, setState) {
// //             return AlertDialog(
// //               title:
// //                   Text(translate('Review', 'समीक्षा')), // Title of the dialog
// //               content: Column(
// //                 mainAxisSize: MainAxisSize.min,
// //                 children: [
// //                   // Star rating input using Row (star buttons)
// //                   Row(
// //                     mainAxisAlignment: MainAxisAlignment.center,
// //                     children: List.generate(5, (index) {
// //                       return IconButton(
// //                         icon: Icon(
// //                           index < _rating ? Icons.star : Icons.star_border,
// //                           color: Constants.AppColors.star,
// //                         ),
// //                         onPressed: () {
// //                           setState(() {
// //                             _rating = index + 1.0; // Update the rating value
// //                           });
// //                         },
// //                       );
// //                     }),
// //                   ),
// //                   // Remarks input (text field)
// //                   TextField(
// //                     controller: _remarksController,
// //                     maxLines: 3,
// //                     decoration: InputDecoration(
// //                       hintText: translate('Write a Review For Worker',
// //                           'मजदूर के लिए समीक्षा लिखें'), // Hint text for the review input
// //                       border: OutlineInputBorder(),
// //                       suffixIcon: MicIconButton(controller: _remarksController),
// //                     ),
// //                   ),
// //                 ],
// //               ),
// //               actions: [
// //                 TextButton(
// //                   onPressed: () {
// //                     Navigator.of(context).pop(); // Close the dialog
// //                   },
// //                   child: Text(
// //                       translate('Cancel', 'रद्द करें')), // Cancel button text
// //                 ),
// //                 TextButton(
// //                   onPressed: () {
// //                     Navigator.of(context).pop();
// //                     _submitReview(); // Call submit review after dialog is closed
// //                   },
// //                   child: Text(
// //                       translate('Submit', 'सबमिट करें')), // Submit button text
// //                 ),
// //               ],
// //             );
// //           },
// //         );
// //       },
// //     );
// //   }
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     milestones = widget.application['milestones'] is String
// //         ? List<Map<String, dynamic>>.from(
// //             jsonDecode(widget.application['milestones']))
// //         : [];
// //     Future<Map<String, String>> _getTranslatedTexts() async {
// //       // Simulate async fetching and translating texts (this could be API calls, etc.)
// //       return {
// //         'labourName': await translateText(labourNameController.text),
// //         'location': await translateText(locationController.text),
// //         'budget': await translateText(budgetController.text),
// //         'duration': await translateText(durationController.text),
// //         'status': await translateText(statusController.text),
// //         'remarks': await translateText(remarksController.text),
// //       };
// //     }
// //
// //     return Scaffold(
// //       backgroundColor: Constants.AppColors.surface,
// //       appBar: AppBar(
// //         foregroundColor: Constants.AppColors.card,
// //         elevation: 0,
// //         title: Text(
// //           AppLocalizations.of(context)!.applicationDetails, // Localized title
// //           style: Constants.AppTypography.h3.copyWith(color: Constants.AppColors.card),
// //         ),
// //         iconTheme: const IconThemeData(color: Constants.AppColors.card),
// //         flexibleSpace: Container(
// //           decoration: const BoxDecoration(
// //             gradient: Constants.AppColors.brandGradient,
// //           ),
// //         ),
// //       ),
// //       body: Padding(
// //         padding: const EdgeInsets.all(16.0),
// //         child: SingleChildScrollView(
// //           child: Column(
// //             crossAxisAlignment: CrossAxisAlignment.start,
// //             children: [
// //               _buildDetailRow(
// //                   AppLocalizations.of(context)!.labourName,
// //                   labourNameController,
// //                   translateText(labourNameController.text)),
// //               _buildDetailRow(
// //                   AppLocalizations.of(context)!.proposalAmount,
// //                   locationController,
// //                   translateText(praposalamountController.text)),
// //               _buildDetailRow(AppLocalizations.of(context)!.location,
// //                   locationController, translateText(labourNameController.text)),
// //               _buildDetailRow(AppLocalizations.of(context)!.budget,
// //                   budgetController, budgetController.text),
// //               _buildDetailRow(AppLocalizations.of(context)!.proposalDuration,
// //                   durationController, (durationController.text)),
// //               _buildDetailRow(AppLocalizations.of(context)!.status,
// //                   statusController, translateText(statusController.text)),
// //               Row(
// //                 children: [
// //                   Expanded(
// //                     child: _buildDetailRow(AppLocalizations.of(context)!.remarks,
// //                         remarksController, translateText(remarksController.text) ?? 'N/A'),
// //                   ),
// //                   SpeakerIconButton(
// //                     text: translateText(remarksController.text) ?? 'N/A',
// //                   ),
// //                 ],
// //               ),
// //               if (milestones.isNotEmpty)
// //                 SingleChildScrollView(
// //                   scrollDirection: Axis.horizontal,
// //                   child: DataTable(
// //                     columns: [
// //                       DataColumn(
// //                           label: Text(AppLocalizations.of(context)!
// //                               .description)), // Localized
// //                       DataColumn(
// //                           label: Text(AppLocalizations.of(context)!
// //                               .amount)), // Localized
// //                       DataColumn(
// //                           label: Text(AppLocalizations.of(context)!
// //                               .proposalAmount)), // Localized
// //                       DataColumn(
// //                           label: Text(AppLocalizations.of(context)!
// //                               .duration)), // Localized
// //                       DataColumn(
// //                           label: Text(AppLocalizations.of(context)!
// //                               .actions)), // Localized
// //                     ],
// //                     rows: List<DataRow>.generate(
// //                       milestones.length,
// //                       (index) {
// //                         bool canProceed = index == 0 ||
// //                             milestones[index - 1]['status']?.toString() == '4';
// //                         bool isCurrentNotCompleted =
// //                             milestones[index]['status']?.toString() != '4';
// //
// //                         return DataRow(
// //                           cells: [
// //                             DataCell(
// //                               Row(
// //                                 mainAxisSize: MainAxisSize.min,
// //                                 children: [
// //                                   Text(milestones[index]['description'] ?? 'N/A'),
// //                                   const SizedBox(width: 4),
// //                                   SpeakerIconButton(
// //                                     text: milestones[index]['description'] ?? 'N/A',
// //                                     size: 16.0,
// //                                   ),
// //                                 ],
// //                               ),
// //                             ),
// //                             DataCell(Text(
// //                                 milestones[index]['amount']?.toString() ??
// //                                     'N/A')),
// //                             DataCell(Text(milestones[index]['proposalamount']
// //                                     ?.toString() ??
// //                                 'N/A')),
// //                             DataCell(Text(
// //                                 milestones[index]['duration']?.toString() ??
// //                                     'N/A')),
// //                             DataCell(Row(
// //                               children: [
// //                                 if (milestones[index]['status']?.toString() ==
// //                                     '3')
// //                                   ElevatedButton(
// //                                     onPressed: () {
// //                                       handleMilestoneCompletion(context,
// //                                           milestones[index]['sno'].toString());
// //                                     },
// //                                     style: ElevatedButton.styleFrom(
// //                                       shape: RoundedRectangleBorder(
// //                                         borderRadius: BorderRadius.all(
// //                                             Radius.circular(Constants.AppRadii.sm)),
// //                                       ),
// //                                       backgroundColor:
// //                                           Constants.AppColors.brand,
// //                                       foregroundColor: Constants.AppColors.card,
// //                                       elevation: 0,
// //                                     ),
// //                                     child: Text(
// //                                       AppLocalizations.of(context)!
// //                                           .submitted, // Localized
// //                                       style: Constants.AppTypography.label.copyWith(color: Constants.AppColors.card),
// //                                     ),
// //                                   ),
// //                                 if (milestones[index]['status']?.toString() ==
// //                                     '4')
// //                                   ElevatedButton(
// //                                     style: ElevatedButton.styleFrom(
// //                                       shape: RoundedRectangleBorder(
// //                                         borderRadius: BorderRadius.all(
// //                                             Radius.circular(Constants.AppRadii.sm)),
// //                                       ),
// //                                       backgroundColor:
// //                                           Constants.AppColors.brand,
// //                                       foregroundColor: Constants.AppColors.card,
// //                                       elevation: 0,
// //                                     ),
// //                                     onPressed: () {
// //                                       print(
// //                                           'Button pressed for Completed status');
// //                                     },
// //                                     child: Text(
// //                                       AppLocalizations.of(context)!
// //                                           .completed, // Localized
// //                                       style: Constants.AppTypography.label.copyWith(color: Constants.AppColors.card),
// //                                     ),
// //                                   ),
// //                                 if (canProceed && isCurrentNotCompleted)
// //                                   ElevatedButton(
// //                                     onPressed: () {
// //                                       print(
// //                                           'Proceed button pressed for index $index');
// //                                       // Add your proceed action here
// //                                     },
// //                                     style: ElevatedButton.styleFrom(
// //                                       shape: RoundedRectangleBorder(
// //                                         borderRadius: BorderRadius.all(
// //                                             Radius.circular(Constants.AppRadii.sm)),
// //                                       ),
// //                                       backgroundColor:
// //                                           Constants.AppColors.brand,
// //                                       foregroundColor: Constants.AppColors.card,
// //                                       elevation: 0,
// //                                     ),
// //                                     child: Text(
// //                                       AppLocalizations.of(context)!
// //                                           .proceed, // Localized
// //                                       style: Constants.AppTypography.label.copyWith(color: Constants.AppColors.card),
// //                                     ),
// //                                   ),
// //                               ],
// //                             )),
// //                           ],
// //                         );
// //                       },
// //                     ),
// //                   ),
// //                 ),
// //               Row(
// //                 mainAxisAlignment: MainAxisAlignment.end,
// //                 children: [
// //                   Column(
// //                     crossAxisAlignment: CrossAxisAlignment.end,
// //                     children: [
// //                       if (widget.application['status'] == '0') ...[
// //                         // Job not assigned
// //                         ElevatedButton(
// //                           onPressed: () => assignProject(
// //                             widget.application['labourID']
// //                                 .toString(), // Pass the labour ID as String
// //                             context, // Pass the BuildContext
// //                           ),
// //                           style: ElevatedButton.styleFrom(
// //                             shape: RoundedRectangleBorder(
// //                               borderRadius:
// //                                   BorderRadius.all(Radius.circular(Constants.AppRadii.sm)),
// //                             ),
// //                             backgroundColor: Constants.AppColors.brand,
// //                             foregroundColor: Constants.AppColors.card,
// //                             elevation: 0,
// //                           ),
// //                           child: Text(
// //                             AppLocalizations.of(context)!
// //                                 .assignProject, // Localized
// //                             style: Constants.AppTypography.label.copyWith(color: Constants.AppColors.card),
// //                           ),
// //                         ),
// //                       ] else if (widget.application['status'] == '1') ...[
// //                         Center(
// //                           child: ElevatedButton(
// //                             onPressed: () {
// //                               unassignProject(
// //                                 widget.application['labourID'].toString(),
// //                                 widget.application['projectID'].toString(),
// //                               );
// //                             },
// //                             style: ElevatedButton.styleFrom(
// //                               shape: RoundedRectangleBorder(
// //                                 borderRadius:
// //                                     BorderRadius.all(Radius.circular(Constants.AppRadii.sm)),
// //                               ),
// //                               backgroundColor: Constants.AppColors.brand,
// //                               foregroundColor: Constants.AppColors.card,
// //                               elevation: 0,
// //                             ),
// //                             child: Text(
// //                               AppLocalizations.of(context)!
// //                                   .cancelAssignment, // Localized
// //                               style: Constants.AppTypography.label.copyWith(color: Constants.AppColors.card),
// //                             ),
// //                           ),
// //                         ),
// //                       ] else if (widget.application['status'] == '2') ...[
// //                         Center(
// //                           child: ElevatedButton(
// //                             onPressed: () {
// //                               showCancelDialog(
// //                                   context,
// //                                   widget.application['labourID']
// //                                       .toString()); // Show dialog to enter remark
// //                             },
// //                             style: ElevatedButton.styleFrom(
// //                               shape: RoundedRectangleBorder(
// //                                 borderRadius:
// //                                     BorderRadius.all(Radius.circular(Constants.AppRadii.sm)),
// //                               ),
// //                               backgroundColor: Constants.AppColors.brand,
// //                               foregroundColor: Constants.AppColors.card,
// //                               elevation: 0,
// //                             ),
// //                             child: Text(
// //                               '${AppLocalizations.of(context)!.workStarted} ${widget.application['startdate']} ', // Localized
// //                               style: Constants.AppTypography.label.copyWith(color: Constants.AppColors.card),
// //                             ),
// //                           ),
// //                         ),
// //                         if (widget.application['cancel_confirm'] == '0') ...[
// //                           Center(
// //                             child: ElevatedButton(
// //                               onPressed: () {
// //                                 showCancelDialog(
// //                                     context,
// //                                     widget.application['labourID']
// //                                         .toString()); // Show dialog to enter remark
// //                               },
// //                               style: ElevatedButton.styleFrom(
// //                                 shape: RoundedRectangleBorder(
// //                                   borderRadius:
// //                                       BorderRadius.all(Radius.circular(Constants.AppRadii.sm)),
// //                                 ),
// //                                 backgroundColor: Constants.AppColors.brand,
// //                                 foregroundColor: Constants.AppColors.card,
// //                                 elevation: 0,
// //                               ),
// //                               child: Text(
// //                                 AppLocalizations.of(context)!
// //                                     .cancelWork, // Localized
// //                                 style: Constants.AppTypography.label.copyWith(color: Constants.AppColors.card),
// //                               ),
// //                             ),
// //                           ),
// //                         ] else if (widget.application['cancel_confirm'] ==
// //                             '1') ...[
// //                           Center(
// //                             child: ElevatedButton(
// //                               onPressed: null, // Disabled if cancelled already
// //                               style: ElevatedButton.styleFrom(
// //                                 shape: RoundedRectangleBorder(
// //                                   borderRadius:
// //                                       BorderRadius.all(Radius.circular(Constants.AppRadii.sm)),
// //                                 ),
// //                                 backgroundColor: Constants.AppColors.brand,
// //                                 foregroundColor: Constants.AppColors.card,
// //                                 elevation: 0,
// //                               ),
// //                               child: Text(
// //                                 AppLocalizations.of(context)!
// //                                     .cancelledRequested, // Localized
// //                                 style: Constants.AppTypography.label.copyWith(color: Constants.AppColors.card),
// //                               ),
// //                             ),
// //                           ),
// //                         ],
// //                         if (widget.application['complete_confirm'] == '1') ...[
// //                           // Work completed request
// //                           Center(
// //                             child: ElevatedButton(
// //                               onPressed: () {
// //                                 confirmComplete(
// //                                     widget.application['projectID'].toString(),
// //                                     widget.application['labourID'].toString());
// //                               },
// //                               style: ElevatedButton.styleFrom(
// //                                 shape: RoundedRectangleBorder(
// //                                   borderRadius:
// //                                       BorderRadius.all(Radius.circular(Constants.AppRadii.sm)),
// //                                 ),
// //                                 backgroundColor: Constants.AppColors.brand,
// //                                 foregroundColor: Constants.AppColors.card,
// //                                 elevation: 0,
// //                               ),
// //                               child: Text(
// //                                 AppLocalizations.of(context)!
// //                                     .completedRequested, // Localized
// //                                 style: Constants.AppTypography.label.copyWith(color: Constants.AppColors.card),
// //                               ),
// //                             ),
// //                           ),
// //                         ],
// //                       ] else if (widget.application['status'] == '3') ...[
// //                         Row(
// //                           children: [
// //                             ElevatedButton(
// //                               onPressed:
// //                                   _showReviewDialog, // Show review dialog on click
// //                               // Disabled as it's completed
// //                               style: ElevatedButton.styleFrom(
// //                                 shape: RoundedRectangleBorder(
// //                                   borderRadius:
// //                                       BorderRadius.all(Radius.circular(Constants.AppRadii.sm)),
// //                                 ),
// //                                 backgroundColor: Constants.AppColors.brand,
// //                                 foregroundColor: Constants.AppColors.card,
// //                                 disabledBackgroundColor: Constants.AppColors.brand,
// //                                 elevation: 0,
// //                               ),
// //                               child: Text(
// //                                 translate('Review', 'समीक्षा'),
// //                                 style: Constants.AppTypography.label.copyWith(color: Constants.AppColors.card),
// //                               ),
// //                             ),
// //                             SizedBox(
// //                               width: 10,
// //                             ),
// //                             ElevatedButton(
// //                               onPressed: null, // Disabled as it's completed
// //                               style: ElevatedButton.styleFrom(
// //                                 shape: RoundedRectangleBorder(
// //                                   borderRadius:
// //                                       BorderRadius.all(Radius.circular(Constants.AppRadii.sm)),
// //                                 ),
// //                                 backgroundColor: Constants.AppColors.brand,
// //                                 foregroundColor: Constants.AppColors.card,
// //                                 disabledBackgroundColor: Constants.AppColors.brand,
// //                                 elevation: 0,
// //                               ),
// //                               child: Text(
// //                                 '${AppLocalizations.of(context)!.completedDate} ${widget.application['completedate']}',
// //                                 style: Constants.AppTypography.label.copyWith(color: Constants.AppColors.card),
// //                               ),
// //                             ),
// //                           ],
// //                         ),
// //                       ] else if (widget.application['status'] == '4') ...[
// //                         // Job cancelled
// //                         Center(
// //                           child: ElevatedButton(
// //                             onPressed: null, // Disabled as it's cancelled
// //                             style: ElevatedButton.styleFrom(
// //                               shape: RoundedRectangleBorder(
// //                                 borderRadius:
// //                                     BorderRadius.all(Radius.circular(Constants.AppRadii.sm)),
// //                               ),
// //                               backgroundColor: Constants.AppColors.brand,
// //                               foregroundColor: Constants.AppColors.card,
// //                               disabledBackgroundColor: Colors.red,
// //                               elevation: 0,
// //                             ),
// //                             child: Text(
// //                               AppLocalizations.of(context)!
// //                                   .cancelled, // Localized
// //                               style: Constants.AppTypography.label.copyWith(color: Constants.AppColors.card),
// //                             ),
// //                           ),
// //                         ),
// //                       ],
// //                     ],
// //                   ),
// //                 ],
// //               ),
// //             ],
// //           ),
// //         ),
// //       ),
// //     );
// //   }
// //
// //   // Helper to create each detail row
// //   Widget _buildDetailRow(
// //       String label, TextEditingController controller, String text) {
// //     return Padding(
// //       padding: const EdgeInsets.symmetric(vertical: 6),
// //       child: Row(
// //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
// //         children: [
// //           Text(
// //             '$label: ', // Adding colon after the label
// //             style: Constants.AppTypography.subhead.copyWith(color: Constants.AppColors.ink),
// //           ),
// //           Expanded(
// //             child: Text(
// //               text, // Directly accessing the controller's text
// //               style: Constants.AppTypography.body.copyWith(color: Constants.AppColors.ink),
// //             ),
// //           ),
// //         ],
// //       ),
// //     );
// //   }
// //
// //   // Format date from string to more readable format
// //   String _formatDate(String? dateString) {
// //     if (dateString == null || dateString.isEmpty || dateString == 'N/A') {
// //       return 'N/A';
// //     }
// //
// //     try {
// //       // Try to parse the date string
// //       DateTime dateTime = DateTime.parse(dateString);
// //
// //       // Return the formatted date string
// //       return '${dateTime.day}-${dateTime.month}-${dateTime.year}';
// //     } catch (e) {
// //       // In case of error (invalid format), return 'N/A'
// //       return 'N/A';
// //     }
// //   }
// //
// //   // Convert the status code to a human-readable format
// //   String _getStatus(String status) {
// //     switch (status) {
// //       case '0':
// //         return 'Not Assigned';
// //       case '1':
// //         return 'Assigned';
// //       case '2':
// //         return 'Work Started';
// //       case '3':
// //         return 'Completed';
// //       case '4':
// //         return 'Cancelled';
// //       default:
// //         return 'Unknown';
// //     }
// //   }
// // }
//
//
//
// import 'package:flutter/material.dart';
// import 'package:greencollar/speech_helper.dart';
// import 'dart:async';
// import 'dart:convert';
//
// import 'package:flutter_secure_storage/flutter_secure_storage.dart';
// import 'package:fluttertoast/fluttertoast.dart';
// import 'package:greencollar/HomeScree.dart';
// import 'package:greencollar/l10n/app_localizations.dart';
// import 'package:greencollar/main.dart';
// import 'package:intl/intl.dart';
// import 'package:provider/provider.dart';
// import 'package:http/http.dart' as http;
// import 'package:translator/translator.dart';
// import 'package:url_launcher/url_launcher.dart';
// import 'package:greencollar/constants.dart' as Constants;
//
// // ─── FarmerMilestoneService (unchanged) ────────────────────────────────
// class FarmerMilestoneService {
//   static const String _baseUrl =
//       '${Constants.AppConstants.apiUrl}farmer/confirmcompletemilestone';
//
//   static Future<Map<String, dynamic>> completeMilestone({
//     required int projectId,
//     required String milestoneSno,
//     required int labourId,
//   }) async {
//     final Uri url = Uri.parse(_baseUrl);
//     try {
//       final Map<String, dynamic> payload = {
//         "projectid": projectId,
//         "milestonesno": milestoneSno,
//         "labourid": labourId,
//       };
//       final response = await http.post(
//         url,
//         headers: {
//           "Content-Type": "application/json",
//           "Accept": "application/json",
//         },
//         body: jsonEncode(payload),
//       );
//       if (response.statusCode == 200) {
//         return json.decode(response.body);
//       } else {
//         return {
//           "status": "0",
//           "message":
//           "Failed to complete milestone. Status Code: ${response.statusCode}"
//         };
//       }
//     } catch (e) {
//       return {"status": "0", "message": "An error occurred: $e"};
//     }
//   }
// }
//
// // ─── ApplicationDetailPage (refreshed) ─────────────────────────────────
// class ApplicationDetailPage extends StatefulWidget {
//   final Map<String, dynamic> application;
//
//   const ApplicationDetailPage({Key? key, required this.application})
//       : super(key: key);
//
//   @override
//   State<ApplicationDetailPage> createState() => _ApplicationDetailPageState();
// }
//
// class _ApplicationDetailPageState extends State<ApplicationDetailPage> {
//   final _secureStorage = const FlutterSecureStorage();
//
//   // ─── Translation ──────────────────────────────────────────────────────
//   String _selectedLanguage = 'en';
//   Map<String, Map<String, String>> _cachedTranslations = {};
//   Map<String, Map<String, String>> translations =
//       Constants.AppConstants.translations;
//   final GoogleTranslator _translator = GoogleTranslator();
//
//   Future<void> loadLanguage() async {
//     String? language = await _secureStorage.read(key: 'selectedLanguage');
//     _selectedLanguage = language ?? 'en';
//   }
//
//   String translateText(String text) {
//     if (text.isEmpty) return "";
//     String targetLang = _selectedLanguage ?? 'en';
//     if (translations.containsKey(text) &&
//         translations[text]!.containsKey(targetLang)) {
//       return translations[text]![targetLang]!;
//     }
//     if (_cachedTranslations.containsKey(text) &&
//         _cachedTranslations[text]!.containsKey(targetLang)) {
//       return _cachedTranslations[text]![targetLang]!;
//     }
//     _fetchTranslation(text, targetLang);
//     return text;
//   }
//
//   Future<void> _fetchTranslation(String text, String targetLang) async {
//     try {
//       if (Constants.AppConstants.translations.containsKey(text) &&
//           Constants.AppConstants.translations[text]!.containsKey(targetLang)) {
//         return;
//       }
//       final translation = await _translator.translate(text, to: targetLang);
//       if (!translations.containsKey(text)) {
//         translations[text] = {"en": text, "hi": text};
//       }
//       translations[text]![targetLang] = translation.text;
//       _cachedTranslations = translations;
//       if (!Constants.AppConstants.translations.containsKey(text)) {
//         Constants.AppConstants.translations[text] = {};
//       }
//       Constants.AppConstants.translations[text]![targetLang] = translation.text;
//       _cachedTranslations.putIfAbsent(text, () => {})[targetLang] =
//           translation.text;
//       setState(() {});
//     } catch (e) {
//       print("Translation error: $e");
//     }
//   }
//
//   String translate(String enText, String hiText) {
//     return _selectedLanguage == 'en' ? enText : hiText;
//   }
//
//   // ─── Lifecycle ──────────────────────────────────────────────────────
//   @override
//   void initState() {
//     super.initState();
//     loadLanguage();
//   }
//
//   // ─── API Action Methods (unchanged logic, kept as-is) ───────────────
//   Future<void> unassignProject(String labourId, String projectId) async {
//     String url = '${Constants.AppConstants.apiUrl}farmer/unassignProject';
//     try {
//       final response = await http.post(
//         Uri.parse(url),
//         headers: {'Content-Type': 'application/json'},
//         body: json.encode({
//           'labourids': labourId,
//           'projectids': projectId,
//         }),
//       );
//       if (response.statusCode == 200) {
//         final data = json.decode(response.body);
//         if (data['status'] == '1') {
//           Fluttertoast.showToast(
//             msg: translate('Project Unassigned Successfully!',
//                 'प्रोजेक्ट अनअसाइन्ड सफलतापूर्वक!'),
//             toastLength: Toast.LENGTH_SHORT,
//             gravity: ToastGravity.BOTTOM,
//             backgroundColor: Constants.AppColors.brand,
//             textColor: Constants.AppColors.card,
//             fontSize: 16.0,
//           );
//           Future.delayed(Duration(seconds: 1), () {
//             Navigator.pushReplacement(
//               context,
//               MaterialPageRoute(builder: (context) => HomePage()),
//             );
//           });
//         }
//       } else {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//               content: Text(translate(
//                   'Failed to unassign job', 'काम असाइन करने में विफल'))),
//         );
//       }
//     } catch (e) {}
//   }
//
//   Future<void> cancelConfirm(
//       String projectId, String labourId, String cancelRemark) async {
//     String url = '${Constants.AppConstants.apiUrl}farmer/cancelConfirm';
//     try {
//       final response = await http.post(
//         Uri.parse(url),
//         headers: {'Content-Type': 'application/json'},
//         body: json.encode({
//           'projectid': projectId,
//           'labourid': labourId,
//           'cancelremark': cancelRemark,
//         }),
//       );
//       if (response.statusCode == 200) {
//         final data = json.decode(response.body);
//         if (data['status'] == '1') {
//           Fluttertoast.showToast(
//             msg: translate('Cancel request Sent Successfully!',
//                 'अनुरोध रद्द करें सफलतापूर्वक भेजा गया!'),
//             toastLength: Toast.LENGTH_SHORT,
//             gravity: ToastGravity.BOTTOM,
//             backgroundColor: Constants.AppColors.brand,
//             textColor: Constants.AppColors.card,
//             fontSize: 16.0,
//           );
//           Future.delayed(Duration(seconds: 1), () {
//             Navigator.pushReplacement(
//               context,
//               MaterialPageRoute(builder: (context) => HomePage()),
//             );
//           });
//         }
//       } else {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//               content: Text(translate('Failed to send cancel request',
//                   'कृपया रद्द अनुरोध भेजने में विफल'))),
//         );
//       }
//     } catch (e) {}
//   }
//
//   void showCancelDialog(BuildContext context, String labourId) {
//     TextEditingController _cancelRemarkController = TextEditingController();
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: Text(translate('Cancel Remark', 'रद्द टिप्पणी')),
//           content: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               TextField(
//                 controller: _cancelRemarkController,
//                 decoration: InputDecoration(
//                   labelText: translate(
//                       'Enter Cancel Remark', 'रद्द टिप्पणी दर्ज करें'),
//                   border: OutlineInputBorder(),
//                   suffixIcon: MicIconButton(controller: _cancelRemarkController),
//                 ),
//                 maxLines: 3,
//               ),
//             ],
//           ),
//           actions: <Widget>[
//             TextButton(
//               onPressed: () => Navigator.of(context).pop(),
//               child: Text(translate('Cancel', 'रद्द करें')),
//             ),
//             TextButton(
//               onPressed: () {
//                 if (_cancelRemarkController.text.isNotEmpty) {
//                   cancelConfirm(
//                     widget.application['projectID'].toString(),
//                     labourId,
//                     _cancelRemarkController.text,
//                   );
//                   Navigator.of(context).pop();
//                 } else {
//                   ScaffoldMessenger.of(context).showSnackBar(
//                     SnackBar(
//                         content: Text(translate('Remark cannot be empty',
//                             'टिप्पणी खाली नहीं हो सकती'))),
//                   );
//                 }
//               },
//               child: Text(translate('Submit', 'सबमिट करें')),
//             ),
//           ],
//         );
//       },
//     );
//   }
//
//   Future<void> confirmComplete(String projectId, String labourId) async {
//     String url = '${Constants.AppConstants.apiUrl}farmer/confirmComplete';
//     try {
//       final response = await http.post(
//         Uri.parse(url),
//         headers: {'Content-Type': 'application/json'},
//         body: json.encode({
//           'projectid': projectId,
//           'labourid': labourId,
//         }),
//       );
//       if (response.statusCode == 200) {
//         final data = json.decode(response.body);
//         if (data['status'] == '1') {
//           Fluttertoast.showToast(
//             msg: translate(
//                 'Confirm Completion Successful!', 'सफल समापन की पुष्टि!'),
//             toastLength: Toast.LENGTH_SHORT,
//             gravity: ToastGravity.BOTTOM,
//             backgroundColor: Colors.green.shade700,
//             textColor: Colors.white,
//             fontSize: 16.0,
//           );
//           Future.delayed(Duration(seconds: 1), () {
//             Navigator.pushReplacement(
//               context,
//               MaterialPageRoute(builder: (context) => HomePage()),
//             );
//           });
//         }
//       } else {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//               content: Text(translate('Failed to confirm completion',
//                   'पूरा होने की पुष्टि करने में विफल'))),
//         );
//       }
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text(translate('Error: $e', 'त्रुटि: $e'))),
//       );
//     }
//   }
//
//   Future<void> assignProject(String labourId, BuildContext context) async {
//     final String apiUrl =
//         '${Constants.AppConstants.apiUrl}farmer/projectAssigned';
//     String? userId = await _secureStorage.read(key: 'id');
//     if (userId == null) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//             content: Text(translate('User ID not found in secure storage',
//                 'सिक्योर स्टोरेज में उपयोगकर्ता आईडी नहीं मिली'))),
//       );
//       return;
//     }
//
//     bool? shouldAssign = await _showAssignJobConfirmationDialog(context);
//     if (shouldAssign != null && shouldAssign) {
//       await _assignProjectToLabour(labourId, context);
//     }
//   }
//
//   Future<bool?> _showAssignJobConfirmationDialog(BuildContext context) {
//     final language =
//         Provider.of<LanguageProvider>(context, listen: false).selectedLanguage;
//     String translate(String enText, String hiText) {
//       return language == 'en' ? enText : hiText;
//     }
//
//     return showDialog<bool>(
//       context: context,
//       builder: (context) {
//         return AlertDialog(
//           title: Text(translate('Do you want to assign this job?',
//               'क्या आप इस नौकरी को सौंपना चाहते हैं?')),
//           content: Text(
//             translate(
//                 'Are you sure you want to assign this job to the selected labour?',
//                 'क्या आप सुनिश्चित हैं कि आप इस नौकरी को चयनित श्रमिक को सौंपना चाहते हैं?'),
//           ),
//           actions: [
//             TextButton(
//               onPressed: () => Navigator.of(context).pop(false),
//               child: Text(translate('Cancel', 'रद्द करें')),
//             ),
//             TextButton(
//               onPressed: () => Navigator.of(context).pop(true),
//               child: Text(translate('Yes', 'हाँ')),
//             ),
//           ],
//         );
//       },
//     );
//   }
//
//   Future<void> _assignProjectToLabour(String labourId, BuildContext context) async {
//     final String apiUrl =
//         '${Constants.AppConstants.apiUrl}farmer/projectAssigned';
//     String? userId = await _secureStorage.read(key: 'id');
//     if (userId == null) return;
//
//     final Map<String, dynamic> requestBody = {
//       'labourid': labourId,
//       'projectid': widget.application['projectID'].toString(),
//     };
//
//     try {
//       final response = await http.post(
//         Uri.parse(apiUrl),
//         headers: {'Content-Type': 'application/json'},
//         body: jsonEncode(requestBody),
//       );
//       if (response.statusCode == 200) {
//         final responseData = json.decode(response.body);
//         if (responseData['status'] == 1) {
//           Fluttertoast.showToast(
//             msg: translate('Project assigned successfully',
//                 'परियोजना सफलतापूर्वक सौंपा गया'),
//             toastLength: Toast.LENGTH_SHORT,
//             gravity: ToastGravity.BOTTOM,
//             backgroundColor: Constants.AppColors.brand,
//             textColor: Constants.AppColors.card,
//             fontSize: 16.0,
//           );
//           Future.delayed(Duration(seconds: 1), () {
//             Navigator.pushReplacement(
//               context,
//               MaterialPageRoute(builder: (context) => HomePage()),
//             );
//           });
//         } else {
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(
//                 content: Text(translate('Failed to assign project: ',
//                     'परियोजना सौंपने में विफल: ') +
//                     responseData['message'])),
//           );
//         }
//       } else {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//               content: Text(translate(
//                   'Failed to assign project', 'परियोजना सौंपने में विफल'))),
//         );
//       }
//     } catch (e) {}
//   }
//
//   void handleMilestoneCompletion(BuildContext context, String milestone) async {
//     String? userId = await _secureStorage.read(key: 'id');
//     if (userId == null) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text('User ID not found in secure storage'),
//           backgroundColor: Colors.red,
//         ),
//       );
//       return;
//     }
//
//     int projectId = widget.application['projectID'];
//     String milestoneSno = milestone;
//     int labourId = widget.application['labourID'];
//
//     final result = await FarmerMilestoneService.completeMilestone(
//       projectId: projectId,
//       milestoneSno: milestoneSno,
//       labourId: labourId,
//     );
//     Fluttertoast.showToast(
//       msg: translate(result['message'] ?? 'Unknown response',
//           'अज्ञात प्रतिक्रिया'),
//       toastLength: Toast.LENGTH_SHORT,
//       gravity: ToastGravity.BOTTOM,
//       backgroundColor: result['status'] == "1" ? Colors.green : Colors.red,
//       textColor: Colors.white,
//       fontSize: 16.0,
//     );
//   }
//
//   // ─── Review ──────────────────────────────────────────────────────────
//   double _rating = 1.0;
//   final TextEditingController _remarksController = TextEditingController();
//
//   Future<void> _submitReview() async {
//     const String _baseUrl =
//         '${Constants.AppConstants.apiUrl}farmer/reviewForLabour';
//     final Map<String, dynamic> requestBody = {
//       'projectid': widget.application['projectID'].toString(),
//       'labourid': widget.application['labourID'].toString(),
//       'rating': _rating,
//       'review': _remarksController.text,
//     };
//     try {
//       final response = await http.post(
//         Uri.parse(_baseUrl),
//         body: jsonEncode(requestBody),
//         headers: {'Content-Type': 'application/json'},
//       );
//       if (response.statusCode == 200) {
//         final responseData = jsonDecode(response.body);
//         if (responseData['status'] == "1") {
//           Fluttertoast.showToast(
//             msg: translate('Review submitted successfully!',
//                 'समीक्षा सफलतापूर्वक प्रस्तुत की गई!'),
//             toastLength: Toast.LENGTH_SHORT,
//             gravity: ToastGravity.BOTTOM,
//             backgroundColor: Constants.AppColors.brand,
//             textColor: Constants.AppColors.card,
//             fontSize: 16.0,
//           );
//         } else {
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(
//                 content: Text(
//                   translate('Failed to submit review.',
//                       'समीक्षा प्रस्तुत करने में विफल।'),
//                 )),
//           );
//         }
//       }
//     } catch (e) {}
//   }
//
//   void _showReviewDialog() {
//     showDialog(
//       context: context,
//       builder: (context) {
//         return StatefulBuilder(
//           builder: (BuildContext context, setState) {
//             return AlertDialog(
//               title: Text(translate('Review', 'समीक्षा')),
//               content: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: List.generate(5, (index) {
//                       return IconButton(
//                         icon: Icon(
//                           index < _rating ? Icons.star : Icons.star_border,
//                           color: Constants.AppColors.star,
//                         ),
//                         onPressed: () => setState(() => _rating = index + 1.0),
//                       );
//                     }),
//                   ),
//                   TextField(
//                     controller: _remarksController,
//                     maxLines: 3,
//                     decoration: InputDecoration(
//                       hintText: translate('Write a Review For Worker',
//                           'मजदूर के लिए समीक्षा लिखें'),
//                       border: OutlineInputBorder(),
//                       suffixIcon: MicIconButton(controller: _remarksController),
//                     ),
//                   ),
//                 ],
//               ),
//               actions: [
//                 TextButton(
//                   onPressed: () => Navigator.of(context).pop(),
//                   child: Text(translate('Cancel', 'रद्द करें')),
//                 ),
//                 TextButton(
//                   onPressed: () {
//                     Navigator.of(context).pop();
//                     _submitReview();
//                   },
//                   child: Text(translate('Submit', 'सबमिट करें')),
//                 ),
//               ],
//             );
//           },
//         );
//       },
//     );
//   }
//
//   // ─── Helpers ──────────────────────────────────────────────────────────
//   String _formatDate(String? dateString) {
//     if (dateString == null || dateString.isEmpty || dateString == 'N/A') {
//       return 'N/A';
//     }
//     try {
//       DateTime dateTime = DateTime.parse(dateString);
//       return DateFormat('dd MMM yyyy').format(dateTime);
//     } catch (e) {
//       return 'N/A';
//     }
//   }
//
//   String _getStatus(String status) {
//     switch (status) {
//       case '0':
//         return translate('Not Assigned', 'असाइन नहीं');
//       case '1':
//         return translate('Assigned', 'असाइन किया');
//       case '2':
//         return translate('Work Started', 'काम शुरू');
//       case '3':
//         return translate('Completed', 'पूर्ण');
//       case '4':
//         return translate('Cancelled', 'रद्द');
//       default:
//         return translate('Unknown', 'अज्ञात');
//     }
//   }
//
//   // ─── Build ──────────────────────────────────────────────────────────
//   @override
//   Widget build(BuildContext context) {
//     final app = widget.application;
//     final status = app['status']?.toString() ?? '0';
//     final String statusLabel = _getStatus(status);
//
//     // Extract milestone data
//     List<Map<String, dynamic>> milestones = app['milestones'] is String
//         ? List<Map<String, dynamic>>.from(jsonDecode(app['milestones']))
//         : [];
//
//     // Build info list
//     final List<Map<String, dynamic>> infoItems = [
//       {'icon': Icons.person_outline, 'label': 'Labour Name', 'value': app['labour_name'] ?? 'N/A'},
//       {'icon': Icons.currency_rupee, 'label': 'Proposal Amount', 'value': app['proposal_amount']?.toString() ?? 'N/A'},
//       {'icon': Icons.location_on_outlined, 'label': 'Location', 'value': '${app['labour_address'] ?? ''}, ${app['labour_city'] ?? ''}, ${app['labour_state'] ?? ''}'},
//       {'icon': Icons.attach_money, 'label': 'Budget', 'value': app['budget']?.toString() ?? 'N/A'},
//       {'icon': Icons.access_time_outlined, 'label': 'Proposal Duration', 'value': app['day_to_complete']?.toString() ?? 'N/A'},
//       {'icon': Icons.info_outline, 'label': 'Status', 'value': statusLabel},
//       {'icon': Icons.chat_bubble_outline, 'label': 'Remarks', 'value': app['comment'] ?? 'N/A'},
//     ];
//
//     return Scaffold(
//       backgroundColor: Constants.AppColors.surface,
//       appBar: AppBar(
//         title: Text(
//           AppLocalizations.of(context)!.applicationDetails,
//           style: Constants.AppTypography.h2.copyWith(color: Colors.white),
//         ),
//         iconTheme: const IconThemeData(color: Colors.white),
//         flexibleSpace: Container(
//           decoration: const BoxDecoration(
//             gradient: Constants.AppColors.brandGradient,
//           ),
//         ),
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back),
//           onPressed: () {
//             Navigator.push(
//               context,
//               MaterialPageRoute(builder: (context) => HomePage()),
//             );
//           },
//         ),
//         elevation: 0,
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // ─── Info Cards ──────────────────────────────────────────────
//             Container(
//               decoration: BoxDecoration(
//                 color: Colors.white,
//                 borderRadius: BorderRadius.circular(16),
//                 boxShadow: [
//                   BoxShadow(
//                     color: Colors.black.withOpacity(0.04),
//                     blurRadius: 12,
//                     offset: const Offset(0, 4),
//                   ),
//                 ],
//               ),
//               padding: const EdgeInsets.all(16),
//               child: Column(
//                 children: infoItems.map((item) {
//                   return Padding(
//                     padding: const EdgeInsets.symmetric(vertical: 6),
//                     child: Row(
//                       children: [
//                         Icon(item['icon'], size: 18, color: Constants.AppColors.brand),
//                         const SizedBox(width: 12),
//                         Expanded(
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               Text(
//                                 translateText(item['label']),
//                                 style: const TextStyle(
//                                   fontSize: 11,
//                                   color: Colors.grey,
//                                   fontWeight: FontWeight.w500,
//                                 ),
//                               ),
//                               const SizedBox(height: 2),
//                               Text(
//                                 translateText(item['value']),
//                                 style: const TextStyle(
//                                   fontSize: 14,
//                                   fontWeight: FontWeight.w600,
//                                   color: Color(0xFF1A1A2E),
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                       ],
//                     ),
//                   );
//                 }).toList(),
//               ),
//             ),
//             const SizedBox(height: 12),
//
//             // ─── Milestones Table (if any) ─────────────────────────────
//             if (milestones.isNotEmpty) ...[
//               Container(
//                 decoration: BoxDecoration(
//                   color: Colors.white,
//                   borderRadius: BorderRadius.circular(16),
//                   boxShadow: [
//                     BoxShadow(
//                       color: Colors.black.withOpacity(0.04),
//                       blurRadius: 10,
//                       offset: const Offset(0, 2),
//                     ),
//                   ],
//                 ),
//                 padding: const EdgeInsets.all(16),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Row(
//                       children: [
//                         Icon(Icons.layers_outlined,
//                             color: Constants.AppColors.brand, size: 20),
//                         const SizedBox(width: 8),
//                         Text(
//                           translateText('Milestones'),
//                           style: const TextStyle(
//                             fontSize: 16,
//                             fontWeight: FontWeight.w700,
//                             color: Color(0xFF1B2B1B),
//                           ),
//                         ),
//                       ],
//                     ),
//                     const SizedBox(height: 12),
//                     SingleChildScrollView(
//                       scrollDirection: Axis.horizontal,
//                       child: SizedBox(
//                         width: 600,
//                         child: Column(
//                           children: [
//                             // Header
//                             Container(
//                               decoration: BoxDecoration(
//                                 color: Constants.AppColors.brand,
//                                 borderRadius: const BorderRadius.only(
//                                   topLeft: Radius.circular(8),
//                                   topRight: Radius.circular(8),
//                                 ),
//                               ),
//                               padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
//                               child: Row(
//                                 children: [
//                                   Expanded(flex: 2, child: Text(translateText('Description'), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 12))),
//                                   Expanded(flex: 1, child: Text(translateText('Amount'), textAlign: TextAlign.center, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 12))),
//                                   Expanded(flex: 1, child: Text(translateText('Proposal'), textAlign: TextAlign.center, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 12))),
//                                   Expanded(flex: 1, child: Text(translateText('Duration'), textAlign: TextAlign.center, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 12))),
//                                   Expanded(flex: 1, child: Text(translateText('Action'), textAlign: TextAlign.center, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 12))),
//                                 ],
//                               ),
//                             ),
//                             // Rows
//                             ...List.generate(milestones.length, (index) {
//                               final m = milestones[index];
//                               final isEven = index % 2 == 0;
//                               final mStatus = m['status']?.toString();
//                               return Container(
//                                 padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
//                                 decoration: BoxDecoration(
//                                   color: isEven ? Colors.white : const Color(0xFFF9FBF9),
//                                   border: Border(
//                                     bottom: BorderSide(color: Colors.grey[100]!, width: 1),
//                                   ),
//                                 ),
//                                 child: Row(
//                                   children: [
//                                     Expanded(flex: 2, child: Text(translateText(m['description'] ?? 'N/A'), style: const TextStyle(fontSize: 13, color: Color(0xFF1B2B1B)))),
//                                     Expanded(flex: 1, child: Text(m['amount']?.toString() ?? 'N/A', textAlign: TextAlign.center, style: const TextStyle(fontSize: 13, color: Color(0xFF1B2B1B)))),
//                                     Expanded(flex: 1, child: Text(m['proposalamount']?.toString() ?? 'N/A', textAlign: TextAlign.center, style: const TextStyle(fontSize: 13, color: Color(0xFF1B2B1B)))),
//                                     Expanded(flex: 1, child: Text(m['duration']?.toString() ?? 'N/A', textAlign: TextAlign.center, style: const TextStyle(fontSize: 13, color: Color(0xFF1B2B1B)))),
//                                     Expanded(
//                                       flex: 1,
//                                       child: Center(
//                                         child: _buildMilestoneAction(mStatus, () {
//                                           if (mStatus == '3') {
//                                             handleMilestoneCompletion(context, m['sno'].toString());
//                                           }
//                                         }),
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                               );
//                             }),
//                           ],
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//               const SizedBox(height: 12),
//             ],
//
//             // ─── Action Buttons ──────────────────────────────────────────
//             Container(
//               decoration: BoxDecoration(
//                 color: Colors.white,
//                 borderRadius: BorderRadius.circular(16),
//                 boxShadow: [
//                   BoxShadow(
//                     color: Colors.black.withOpacity(0.04),
//                     blurRadius: 10,
//                     offset: const Offset(0, 2),
//                   ),
//                 ],
//               ),
//               padding: const EdgeInsets.all(16),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     translateText('Actions'),
//                     style: const TextStyle(
//                       fontSize: 16,
//                       fontWeight: FontWeight.w700,
//                       color: Color(0xFF1B2B1B),
//                     ),
//                   ),
//                   const SizedBox(height: 12),
//                   _buildActionButtons(status),
//                 ],
//               ),
//             ),
//             const SizedBox(height: 20),
//           ],
//         ),
//       ),
//     );
//   }
//
//   // ─── Milestone action helper ─────────────────────────────────────────
//   Widget _buildMilestoneAction(String? status, VoidCallback onComplete) {
//     if (status == '3') {
//       return Container(
//         padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//         decoration: BoxDecoration(
//           color: Constants.AppColors.brand,
//           borderRadius: BorderRadius.circular(6),
//         ),
//         child: Text(
//           translateText('Complete'),
//           style: const TextStyle(
//             fontSize: 11,
//             fontWeight: FontWeight.bold,
//             color: Colors.white,
//           ),
//         ),
//       );
//     } else if (status == '4') {
//       return Container(
//         padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//         decoration: BoxDecoration(
//           color: Colors.green,
//           borderRadius: BorderRadius.circular(6),
//         ),
//         child: Text(
//           translateText('Done'),
//           style: const TextStyle(
//             fontSize: 11,
//             fontWeight: FontWeight.bold,
//             color: Colors.white,
//           ),
//         ),
//       );
//     } else {
//       return const SizedBox.shrink();
//     }
//   }
//
//   // ─── Build action buttons based on status ────────────────────────────
//   Widget _buildActionButtons(String status) {
//     switch (status) {
//       case '0': // Not assigned
//         return SizedBox(
//           width: double.infinity,
//           height: 44,
//           child: ElevatedButton(
//             onPressed: () => assignProject(
//               widget.application['labourID'].toString(),
//               context,
//             ),
//             style: ElevatedButton.styleFrom(
//               backgroundColor: Constants.AppColors.brand,
//               foregroundColor: Colors.white,
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(10),
//               ),
//               elevation: 0,
//             ),
//             child: Text(
//               translateText('Assign Project'),
//               style: const TextStyle(
//                 fontSize: 14,
//                 fontWeight: FontWeight.bold,
//                 color: Colors.white,
//               ),
//             ),
//           ),
//         );
//
//       case '1': // Assigned
//         return Row(
//           children: [
//             Expanded(
//               child: SizedBox(
//                 height: 44,
//                 child: ElevatedButton(
//                   onPressed: () => unassignProject(
//                     widget.application['labourID'].toString(),
//                     widget.application['projectID'].toString(),
//                   ),
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: Colors.red,
//                     foregroundColor: Colors.white,
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(10),
//                     ),
//                     elevation: 0,
//                   ),
//                   child: FittedBox(
//                     fit: BoxFit.scaleDown,
//                     child: Text(
//                       translateText('Unassign'),
//                       style: const TextStyle(
//                         fontSize: 14,
//                         fontWeight: FontWeight.bold,
//                         color: Colors.white,
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//           ],
//         );
//
//       case '2': // Work Started
//         final cancelConfirm = widget.application['cancel_confirm']?.toString();
//         final completeConfirm = widget.application['complete_confirm']?.toString();
//
//         if (cancelConfirm == '1') {
//           return SizedBox(
//             width: double.infinity,
//             height: 44,
//             child: ElevatedButton(
//               onPressed: null,
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: Colors.grey,
//                 foregroundColor: Colors.white,
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(10),
//                 ),
//                 elevation: 0,
//               ),
//               child: Text(
//                 translateText('Cancellation Requested'),
//                 style: const TextStyle(
//                   fontSize: 14,
//                   fontWeight: FontWeight.bold,
//                   color: Colors.white,
//                 ),
//               ),
//             ),
//           );
//         } else if (completeConfirm == '1') {
//           // Worker has requested completion → farmer can confirm
//           return Row(
//             children: [
//               Expanded(
//                 child: SizedBox(
//                   height: 44,
//                   child: ElevatedButton(
//                     onPressed: () => confirmComplete(
//                       widget.application['projectID'].toString(),
//                       widget.application['labourID'].toString(),
//                     ),
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: Colors.green,
//                       foregroundColor: Colors.white,
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(10),
//                       ),
//                       elevation: 0,
//                     ),
//                     child: FittedBox(
//                       fit: BoxFit.scaleDown,
//                       child: Text(
//                         translateText('Confirm Completion'),
//                         style: const TextStyle(
//                           fontSize: 14,
//                           fontWeight: FontWeight.bold,
//                           color: Colors.white,
//                         ),
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//               const SizedBox(width: 8),
//               Expanded(
//                 child: SizedBox(
//                   height: 44,
//                   child: OutlinedButton(
//                     onPressed: () => showCancelDialog(
//                       context,
//                       widget.application['labourID'].toString(),
//                     ),
//                     style: OutlinedButton.styleFrom(
//                       side: const BorderSide(color: Colors.red, width: 1.2),
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(10),
//                       ),
//                     ),
//                     child: FittedBox(
//                       fit: BoxFit.scaleDown,
//                       child: Text(
//                         translateText('Cancel Work'),
//                         style: const TextStyle(
//                           fontSize: 14,
//                           fontWeight: FontWeight.bold,
//                           color: Colors.red,
//                         ),
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//             ],
//           );
//         } else {
//           // Normal work started: show Cancel Work button only
//           return SizedBox(
//             width: double.infinity,
//             height: 44,
//             child: OutlinedButton(
//               onPressed: () => showCancelDialog(
//                 context,
//                 widget.application['labourID'].toString(),
//               ),
//               style: OutlinedButton.styleFrom(
//                 side: const BorderSide(color: Colors.red, width: 1.2),
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(10),
//                 ),
//               ),
//               child: FittedBox(
//                 fit: BoxFit.scaleDown,
//                 child: Text(
//                   translateText('Cancel Work'),
//                   style: const TextStyle(
//                     fontSize: 14,
//                     fontWeight: FontWeight.bold,
//                     color: Colors.red,
//                   ),
//                 ),
//               ),
//             ),
//           );
//         }
//
//       case '3': // Completed
//         return Row(
//           children: [
//             Expanded(
//               child: SizedBox(
//                 height: 44,
//                 child: ElevatedButton(
//                   onPressed: _showReviewDialog,
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: Constants.AppColors.brand,
//                     foregroundColor: Colors.white,
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(10),
//                     ),
//                     elevation: 0,
//                   ),
//                   child: FittedBox(
//                     fit: BoxFit.scaleDown,
//                     child: Text(
//                       translateText('Review'),
//                       style: const TextStyle(
//                         fontSize: 14,
//                         fontWeight: FontWeight.bold,
//                         color: Colors.white,
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//             const SizedBox(width: 8),
//             Expanded(
//               child: SizedBox(
//                 height: 44,
//                 child: ElevatedButton(
//                   onPressed: null,
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: Colors.grey,
//                     foregroundColor: Colors.white,
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(10),
//                     ),
//                     elevation: 0,
//                   ),
//                   child: FittedBox(
//                     fit: BoxFit.scaleDown,
//                     child: Text(
//                       translateText('Completed'),
//                       style: const TextStyle(
//                         fontSize: 14,
//                         fontWeight: FontWeight.bold,
//                         color: Colors.white,
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//           ],
//         );
//
//       case '4': // Cancelled
//         return SizedBox(
//           width: double.infinity,
//           height: 44,
//           child: ElevatedButton(
//             onPressed: null,
//             style: ElevatedButton.styleFrom(
//               backgroundColor: Colors.grey,
//               foregroundColor: Colors.white,
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(10),
//               ),
//               elevation: 0,
//             ),
//             child: FittedBox(
//               fit: BoxFit.scaleDown,
//               child: Text(
//                 translateText('Cancelled'),
//                 style: const TextStyle(
//                   fontSize: 14,
//                   fontWeight: FontWeight.bold,
//                   color: Colors.white,
//                 ),
//               ),
//             ),
//           ),
//         );
//
//       default:
//         return const SizedBox.shrink();
//     }
//   }
// }


import 'package:flutter/material.dart';
import 'package:greencollar/speech_helper.dart';
import 'dart:async';
import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:greencollar/HomeScree.dart';
import 'package:greencollar/l10n/app_localizations.dart';
import 'package:greencollar/main.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:translator/translator.dart';
import 'package:greencollar/constants.dart' as Constants;

// ─── FarmerMilestoneService (unchanged) ────────────────────────────────
class FarmerMilestoneService {
  static const String _baseUrl =
      '${Constants.AppConstants.apiUrl}farmer/confirmcompletemilestone';

  static Future<Map<String, dynamic>> completeMilestone({
    required int projectId,
    required String milestoneSno,
    required int labourId,
  }) async {
    final Uri url = Uri.parse(_baseUrl);
    try {
      final Map<String, dynamic> payload = {
        "projectid": projectId,
        "milestonesno": milestoneSno,
        "labourid": labourId,
      };
      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
        },
        body: jsonEncode(payload),
      );
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        return {
          "status": "0",
          "message":
          "Failed to complete milestone. Status Code: ${response.statusCode}"
        };
      }
    } catch (e) {
      return {"status": "0", "message": "An error occurred: $e"};
    }
  }
}

// ─── ApplicationDetailPage (refreshed with review handling) ───────────
class ApplicationDetailPage extends StatefulWidget {
  final Map<String, dynamic> application;

  const ApplicationDetailPage({Key? key, required this.application})
      : super(key: key);

  @override
  State<ApplicationDetailPage> createState() => _ApplicationDetailPageState();
}

class _ApplicationDetailPageState extends State<ApplicationDetailPage> {
  final _secureStorage = const FlutterSecureStorage();

  // ─── Translation ──────────────────────────────────────────────────────
  String _selectedLanguage = 'en';
  Map<String, Map<String, String>> _cachedTranslations = {};
  Map<String, Map<String, String>> translations =
      Constants.AppConstants.translations;
  final GoogleTranslator _translator = GoogleTranslator();

  Future<void> loadLanguage() async {
    String? language = await _secureStorage.read(key: 'selectedLanguage');
    _selectedLanguage = language ?? 'en';
  }

  String translateText(String text) {
    if (text.isEmpty) return "";
    String targetLang = _selectedLanguage ?? 'en';
    if (translations.containsKey(text) &&
        translations[text]!.containsKey(targetLang)) {
      return translations[text]![targetLang]!;
    }
    if (_cachedTranslations.containsKey(text) &&
        _cachedTranslations[text]!.containsKey(targetLang)) {
      return _cachedTranslations[text]![targetLang]!;
    }
    _fetchTranslation(text, targetLang);
    return text;
  }

  Future<void> _fetchTranslation(String text, String targetLang) async {
    try {
      if (Constants.AppConstants.translations.containsKey(text) &&
          Constants.AppConstants.translations[text]!.containsKey(targetLang)) {
        return;
      }
      final translation = await _translator.translate(text, to: targetLang);
      if (!translations.containsKey(text)) {
        translations[text] = {"en": text, "hi": text};
      }
      translations[text]![targetLang] = translation.text;
      _cachedTranslations = translations;
      if (!Constants.AppConstants.translations.containsKey(text)) {
        Constants.AppConstants.translations[text] = {};
      }
      Constants.AppConstants.translations[text]![targetLang] = translation.text;
      _cachedTranslations.putIfAbsent(text, () => {})[targetLang] =
          translation.text;
      setState(() {});
    } catch (e) {
      print("Translation error: $e");
    }
  }

  String translate(String enText, String hiText) {
    return _selectedLanguage == 'en' ? enText : hiText;
  }

  // ─── Lifecycle ──────────────────────────────────────────────────────
  @override
  void initState() {
    super.initState();
    loadLanguage();
  }

  // ─── API Action Methods (unchanged) ────────────────────────────────
  Future<void> unassignProject(String labourId, String projectId) async {
    String url = '${Constants.AppConstants.apiUrl}farmer/unassignProject';
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'labourids': labourId,
          'projectids': projectId,
        }),
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == '1') {
          Fluttertoast.showToast(
            msg: translate('Project Unassigned Successfully!',
                'प्रोजेक्ट अनअसाइन्ड सफलतापूर्वक!'),
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            backgroundColor: Constants.AppColors.brand,
            textColor: Constants.AppColors.card,
            fontSize: 16.0,
          );
          Future.delayed(Duration(seconds: 1), () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => HomePage()),
            );
          });
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(translate(
                  'Failed to unassign job', 'काम असाइन करने में विफल'))),
        );
      }
    } catch (e) {}
  }

  Future<void> cancelConfirm(
      String projectId, String labourId, String cancelRemark) async {
    String url = '${Constants.AppConstants.apiUrl}farmer/cancelConfirm';
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'projectid': projectId,
          'labourid': labourId,
          'cancelremark': cancelRemark,
        }),
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == '1') {
          Fluttertoast.showToast(
            msg: translate('Cancel request Sent Successfully!',
                'अनुरोध रद्द करें सफलतापूर्वक भेजा गया!'),
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            backgroundColor: Constants.AppColors.brand,
            textColor: Constants.AppColors.card,
            fontSize: 16.0,
          );
          Future.delayed(Duration(seconds: 1), () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => HomePage()),
            );
          });
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(translate('Failed to send cancel request',
                  'कृपया रद्द अनुरोध भेजने में विफल'))),
        );
      }
    } catch (e) {}
  }

  void showCancelDialog(BuildContext context, String labourId) {
    TextEditingController _cancelRemarkController = TextEditingController();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(translate('Cancel Remark', 'रद्द टिप्पणी')),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _cancelRemarkController,
                decoration: InputDecoration(
                  labelText: translate(
                      'Enter Cancel Remark', 'रद्द टिप्पणी दर्ज करें'),
                  border: OutlineInputBorder(),
                  suffixIcon: MicIconButton(controller: _cancelRemarkController),
                ),
                maxLines: 3,
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(translate('Cancel', 'रद्द करें')),
            ),
            TextButton(
              onPressed: () {
                if (_cancelRemarkController.text.isNotEmpty) {
                  cancelConfirm(
                    widget.application['projectID'].toString(),
                    labourId,
                    _cancelRemarkController.text,
                  );
                  Navigator.of(context).pop();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text(translate('Remark cannot be empty',
                            'टिप्पणी खाली नहीं हो सकती'))),
                  );
                }
              },
              child: Text(translate('Submit', 'सबमिट करें')),
            ),
          ],
        );
      },
    );
  }

  Future<void> confirmComplete(String projectId, String labourId) async {
    String url = '${Constants.AppConstants.apiUrl}farmer/confirmComplete';
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'projectid': projectId,
          'labourid': labourId,
        }),
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == '1') {
          Fluttertoast.showToast(
            msg: translate(
                'Confirm Completion Successful!', 'सफल समापन की पुष्टि!'),
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            backgroundColor: Colors.green.shade700,
            textColor: Colors.white,
            fontSize: 16.0,
          );
          Future.delayed(Duration(seconds: 1), () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => HomePage()),
            );
          });
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(translate('Failed to confirm completion',
                  'पूरा होने की पुष्टि करने में विफल'))),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(translate('Error: $e', 'त्रुटि: $e'))),
      );
    }
  }

  Future<void> assignProject(String labourId, BuildContext context) async {
    final String apiUrl =
        '${Constants.AppConstants.apiUrl}farmer/projectAssigned';
    String? userId = await _secureStorage.read(key: 'id');
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(translate('User ID not found in secure storage',
                'सिक्योर स्टोरेज में उपयोगकर्ता आईडी नहीं मिली'))),
      );
      return;
    }

    bool? shouldAssign = await _showAssignJobConfirmationDialog(context);
    if (shouldAssign != null && shouldAssign) {
      await _assignProjectToLabour(labourId, context);
    }
  }

  Future<bool?> _showAssignJobConfirmationDialog(BuildContext context) {
    final language =
        Provider.of<LanguageProvider>(context, listen: false).selectedLanguage;
    String translate(String enText, String hiText) {
      return language == 'en' ? enText : hiText;
    }

    return showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(translate('Do you want to assign this job?',
              'क्या आप इस नौकरी को सौंपना चाहते हैं?')),
          content: Text(
            translate(
                'Are you sure you want to assign this job to the selected labour?',
                'क्या आप सुनिश्चित हैं कि आप इस नौकरी को चयनित श्रमिक को सौंपना चाहते हैं?'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(translate('Cancel', 'रद्द करें')),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(translate('Yes', 'हाँ')),
            ),
          ],
        );
      },
    );
  }

  Future<void> _assignProjectToLabour(String labourId, BuildContext context) async {
    final String apiUrl =
        '${Constants.AppConstants.apiUrl}farmer/projectAssigned';
    String? userId = await _secureStorage.read(key: 'id');
    if (userId == null) return;

    final Map<String, dynamic> requestBody = {
      'labourid': labourId,
      'projectid': widget.application['projectID'].toString(),
    };

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );
      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData['status'] == 1) {
          Fluttertoast.showToast(
            msg: translate('Project assigned successfully',
                'परियोजना सफलतापूर्वक सौंपा गया'),
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            backgroundColor: Constants.AppColors.brand,
            textColor: Constants.AppColors.card,
            fontSize: 16.0,
          );
          Future.delayed(Duration(seconds: 1), () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => HomePage()),
            );
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(translate('Failed to assign project: ',
                    'परियोजना सौंपने में विफल: ') +
                    responseData['message'])),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(translate(
                  'Failed to assign project', 'परियोजना सौंपने में विफल'))),
        );
      }
    } catch (e) {}
  }

  void handleMilestoneCompletion(BuildContext context, String milestone) async {
    String? userId = await _secureStorage.read(key: 'id');
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('User ID not found in secure storage'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    int projectId = widget.application['projectID'];
    String milestoneSno = milestone;
    int labourId = widget.application['labourID'];

    final result = await FarmerMilestoneService.completeMilestone(
      projectId: projectId,
      milestoneSno: milestoneSno,
      labourId: labourId,
    );
    Fluttertoast.showToast(
      msg: translate(result['message'] ?? 'Unknown response',
          'अज्ञात प्रतिक्रिया'),
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: result['status'] == "1" ? Colors.green : Colors.red,
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }

  // ─── Review ──────────────────────────────────────────────────────────
  double _rating = 1.0;
  final TextEditingController _remarksController = TextEditingController();

  Future<void> _submitReview() async {
    const String _baseUrl =
        '${Constants.AppConstants.apiUrl}farmer/reviewForLabour';
    final Map<String, dynamic> requestBody = {
      'projectid': widget.application['projectID'].toString(),
      'labourid': widget.application['labourID'].toString(),
      'rating': _rating,
      'review': _remarksController.text,
    };
    try {
      final response = await http.post(
        Uri.parse(_baseUrl),
        body: jsonEncode(requestBody),
        headers: {'Content-Type': 'application/json'},
      );
      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData['status'] == "1") {
          Fluttertoast.showToast(
            msg: translate('Review submitted successfully!',
                'समीक्षा सफलतापूर्वक प्रस्तुत की गई!'),
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            backgroundColor: Constants.AppColors.brand,
            textColor: Constants.AppColors.card,
            fontSize: 16.0,
          );
          // Update local data to reflect review submitted
          setState(() {
            widget.application['review_by_farmer'] = _remarksController.text;
            widget.application['rating_by_farmer'] = _rating.toString();
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(
                  translate('Failed to submit review.',
                      'समीक्षा प्रस्तुत करने में विफल।'),
                )),
          );
        }
      }
    } catch (e) {}
  }

  void _showReviewDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, setState) {
            return AlertDialog(
              title: Text(translate('Review', 'समीक्षा')),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) {
                      return IconButton(
                        icon: Icon(
                          index < _rating ? Icons.star : Icons.star_border,
                          color: Constants.AppColors.star,
                        ),
                        onPressed: () => setState(() => _rating = index + 1.0),
                      );
                    }),
                  ),
                  TextField(
                    controller: _remarksController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: translate('Write a Review For Worker',
                          'मजदूर के लिए समीक्षा लिखें'),
                      border: OutlineInputBorder(),
                      suffixIcon: MicIconButton(controller: _remarksController),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(translate('Cancel', 'रद्द करें')),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    _submitReview();
                  },
                  child: Text(translate('Submit', 'सबमिट करें')),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // ─── Helpers ──────────────────────────────────────────────────────────
  String _formatDate(String? dateString) {
    if (dateString == null || dateString.isEmpty || dateString == 'N/A') {
      return 'N/A';
    }
    try {
      DateTime dateTime = DateTime.parse(dateString);
      return DateFormat('dd MMM yyyy').format(dateTime);
    } catch (e) {
      return 'N/A';
    }
  }

  String _getStatus(String status) {
    switch (status) {
      case '0':
        return translate('Not Assigned', 'असाइन नहीं');
      case '1':
        return translate('Assigned', 'असाइन किया');
      case '2':
        return translate('Work Started', 'काम शुरू');
      case '3':
        return translate('Completed', 'पूर्ण');
      case '4':
        return translate('Cancelled', 'रद्द');
      default:
        return translate('Unknown', 'अज्ञात');
    }
  }

  Widget _buildStarRating(String? ratingStr) {
    int rating = 0;
    if (ratingStr != null && ratingStr.isNotEmpty) {
      rating = int.tryParse(ratingStr) ?? 0;
    }
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        return Icon(
          index < rating ? Icons.star : Icons.star_border,
          color: Constants.AppColors.star,
          size: 16,
        );
      }),
    );
  }

  // ─── Build ──────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final app = widget.application;
    final status = app['status']?.toString() ?? '0';
    final String statusLabel = _getStatus(status);

    // Check if review already exists
    final String? reviewByFarmer = app['review_by_farmer'];
    final String? ratingByFarmer = app['rating_by_farmer'];
    final bool hasReview = (reviewByFarmer != null && reviewByFarmer.isNotEmpty) ||
        (ratingByFarmer != null && ratingByFarmer.isNotEmpty);

    // Extract milestone data
    List<Map<String, dynamic>> milestones = app['milestones'] is String
        ? List<Map<String, dynamic>>.from(jsonDecode(app['milestones']))
        : [];

    // Build info list
    final List<Map<String, dynamic>> infoItems = [
      {'icon': Icons.person_outline, 'label': 'Labour Name', 'value': app['labour_name'] ?? 'N/A'},
      {'icon': Icons.currency_rupee, 'label': 'Proposal Amount', 'value': app['proposal_amount']?.toString() ?? 'N/A'},
      {'icon': Icons.location_on_outlined, 'label': 'Location', 'value': '${app['labour_address'] ?? ''}, ${app['labour_city'] ?? ''}, ${app['labour_state'] ?? ''}'},
      {'icon': Icons.attach_money, 'label': 'Budget', 'value': app['budget']?.toString() ?? 'N/A'},
      {'icon': Icons.access_time_outlined, 'label': 'Proposal Duration', 'value': app['day_to_complete']?.toString() ?? 'N/A'},
      {'icon': Icons.info_outline, 'label': 'Status', 'value': statusLabel},
      {'icon': Icons.chat_bubble_outline, 'label': 'Remarks', 'value': app['comment'] ?? 'N/A'},
    ];

    // Add review info if present
    if (hasReview) {
      infoItems.add({
        'icon': Icons.star,
        'label': 'Rating',
        'value': _buildStarRating(ratingByFarmer),
        'isWidget': true,
      });
      infoItems.add({
        'icon': Icons.comment,
        'label': 'Review',
        'value': reviewByFarmer ?? 'N/A',
        'isWidget': false,
      });
    }

    return Scaffold(
      backgroundColor: Constants.AppColors.surface,
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context)!.applicationDetails,
          style: Constants.AppTypography.h2.copyWith(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: Constants.AppColors.brandGradient,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => HomePage()),
            );
          },
        ),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ─── Info Cards ──────────────────────────────────────────────
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                children: infoItems.map((item) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Row(
                      children: [
                        Icon(item['icon'], size: 18, color: Constants.AppColors.brand),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                translateText(item['label']),
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 2),
                              if (item['isWidget'] == true)
                                item['value'] as Widget
                              else
                                Text(
                                  translateText(item['value']),
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF1A1A2E),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 12),

            // ─── Milestones Table (if any) ─────────────────────────────
            if (milestones.isNotEmpty) ...[
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.layers_outlined,
                            color: Constants.AppColors.brand, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          translateText('Milestones'),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1B2B1B),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: SizedBox(
                        width: 600,
                        child: Column(
                          children: [
                            // Header
                            Container(
                              decoration: BoxDecoration(
                                color: Constants.AppColors.brand,
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(8),
                                  topRight: Radius.circular(8),
                                ),
                              ),
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                              child: Row(
                                children: [
                                  Expanded(flex: 2, child: Text(translateText('Description'), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 12))),
                                  Expanded(flex: 1, child: Text(translateText('Amount'), textAlign: TextAlign.center, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 12))),
                                  Expanded(flex: 1, child: Text(translateText('Proposal'), textAlign: TextAlign.center, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 12))),
                                  Expanded(flex: 1, child: Text(translateText('Duration'), textAlign: TextAlign.center, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 12))),
                                  Expanded(flex: 1, child: Text(translateText('Action'), textAlign: TextAlign.center, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 12))),
                                ],
                              ),
                            ),
                            // Rows
                            ...List.generate(milestones.length, (index) {
                              final m = milestones[index];
                              final isEven = index % 2 == 0;
                              final mStatus = m['status']?.toString();
                              return Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                                decoration: BoxDecoration(
                                  color: isEven ? Colors.white : const Color(0xFFF9FBF9),
                                  border: Border(
                                    bottom: BorderSide(color: Colors.grey[100]!, width: 1),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Expanded(flex: 2, child: Text(translateText(m['description'] ?? 'N/A'), style: const TextStyle(fontSize: 13, color: Color(0xFF1B2B1B)))),
                                    Expanded(flex: 1, child: Text(m['amount']?.toString() ?? 'N/A', textAlign: TextAlign.center, style: const TextStyle(fontSize: 13, color: Color(0xFF1B2B1B)))),
                                    Expanded(flex: 1, child: Text(m['proposalamount']?.toString() ?? 'N/A', textAlign: TextAlign.center, style: const TextStyle(fontSize: 13, color: Color(0xFF1B2B1B)))),
                                    Expanded(flex: 1, child: Text(m['duration']?.toString() ?? 'N/A', textAlign: TextAlign.center, style: const TextStyle(fontSize: 13, color: Color(0xFF1B2B1B)))),
                                    Expanded(
                                      flex: 1,
                                      child: Center(
                                        child: _buildMilestoneAction(mStatus, () {
                                          if (mStatus == '3') {
                                            handleMilestoneCompletion(context, m['sno'].toString());
                                          }
                                        }),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
            ],

            // ─── Action Buttons ──────────────────────────────────────────
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    translateText('Actions'),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1B2B1B),
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildActionButtons(status, hasReview),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // ─── Milestone action helper ─────────────────────────────────────────
  Widget _buildMilestoneAction(String? status, VoidCallback onComplete) {
    if (status == '3') {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Constants.AppColors.brand,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          translateText('Complete'),
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      );
    } else if (status == '4') {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.green,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          translateText('Done'),
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      );
    } else {
      return const SizedBox.shrink();
    }
  }

  // ─── Build action buttons based on status & review existence ─────────
  Widget _buildActionButtons(String status, bool hasReview) {
    switch (status) {
      case '0': // Not assigned
        return SizedBox(
          width: double.infinity,
          height: 44,
          child: ElevatedButton(
            onPressed: () => assignProject(
              widget.application['labourID'].toString(),
              context,
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Constants.AppColors.brand,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              elevation: 0,
            ),
            child: Text(
              translateText('Assign Project'),
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        );

      case '1': // Assigned
        return Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 44,
                child: ElevatedButton(
                  onPressed: () => unassignProject(
                    widget.application['labourID'].toString(),
                    widget.application['projectID'].toString(),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 0,
                  ),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      translateText('Unassign'),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );

      case '2': // Work Started
        final cancelConfirm = widget.application['cancel_confirm']?.toString();
        final completeConfirm = widget.application['complete_confirm']?.toString();

        if (cancelConfirm == '1') {
          return SizedBox(
            width: double.infinity,
            height: 44,
            child: ElevatedButton(
              onPressed: null,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 0,
              ),
              child: Text(
                translateText('Cancellation Requested'),
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          );
        } else if (completeConfirm == '1') {
          return Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 44,
                  child: ElevatedButton(
                    onPressed: () => confirmComplete(
                      widget.application['projectID'].toString(),
                      widget.application['labourID'].toString(),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 0,
                    ),
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        translateText('Confirm Completion'),
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: SizedBox(
                  height: 44,
                  child: OutlinedButton(
                    onPressed: () => showCancelDialog(
                      context,
                      widget.application['labourID'].toString(),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.red, width: 1.2),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        translateText('Cancel Work'),
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        } else {
          return SizedBox(
            width: double.infinity,
            height: 44,
            child: OutlinedButton(
              onPressed: () => showCancelDialog(
                context,
                widget.application['labourID'].toString(),
              ),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.red, width: 1.2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  translateText('Cancel Work'),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
              ),
            ),
          );
        }

      case '3': // Completed
        if (hasReview) {
          // Review already given → show "Review Submitted" disabled
          return SizedBox(
            width: double.infinity,
            height: 44,
            child: ElevatedButton(
              onPressed: null,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 0,
              ),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  translateText('Review Submitted'),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          );
        } else {
          // No review → show Review & Completed buttons
          return Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 44,
                  child: ElevatedButton(
                    onPressed: _showReviewDialog,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Constants.AppColors.brand,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 0,
                    ),
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        translateText('Review'),
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: SizedBox(
                  height: 44,
                  child: ElevatedButton(
                    onPressed: null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 0,
                    ),
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        translateText('Completed'),
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        }

      case '4': // Cancelled
        return SizedBox(
          width: double.infinity,
          height: 44,
          child: ElevatedButton(
            onPressed: null,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              elevation: 0,
            ),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                translateText('Cancelled'),
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        );

      default:
        return const SizedBox.shrink();
    }
  }
}