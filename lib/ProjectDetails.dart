// import 'dart:convert';
//
// import 'package:flutter/material.dart';
// import 'package:greencollar/speech_helper.dart';
// import 'package:flutter_secure_storage/flutter_secure_storage.dart';
// import 'package:fluttertoast/fluttertoast.dart';
// import 'package:greencollar/Addproject.dart';
// import 'package:greencollar/HomeScree.dart';
// import 'package:provider/provider.dart';
// import 'package:greencollar/main.dart'; // Adjust the import as needed
// import 'package:http/http.dart' as http;
// import 'package:greencollar/constants.dart' as Constants;
// import 'package:translator/translator.dart';
// import 'package:greencollar/l10n/app_localizations.dart';
//
// class ProjectDetails extends StatefulWidget {
//   final String projectId;
//
//   ProjectDetails({required this.projectId});
//
//   // Constructor to accept the projectType argument
//
//   @override
//   _ProjectDetailsState createState() => _ProjectDetailsState();
// }
//
// class _ProjectDetailsState extends State<ProjectDetails> {
//   final _formKey = GlobalKey<FormState>();
//   final FlutterSecureStorage _secureStorage = FlutterSecureStorage();
//
//   final TextEditingController titleController = TextEditingController();
//   final TextEditingController experienceController = TextEditingController();
//   final TextEditingController qualificationController = TextEditingController();
//
//   final TextEditingController requiredLaboursController =
//       TextEditingController();
//   final TextEditingController budgetController = TextEditingController();
//
//   final TextEditingController estimateDaysController = TextEditingController();
//   final TextEditingController descriptionController = TextEditingController();
//   final TextEditingController pinCodeController = TextEditingController();
//   final TextEditingController addressController = TextEditingController();
//   String? selectedProjectType;
//   String? selectedPaymentType;
//   String? applicantstatus;
//
//   String? selectedSkill;
//   String? selectedLanguage;
//   List<Skill> skills = [];
//   List<String> selectedSkills = [];
//   final List<String> descriptions = [
//     'Home Renovation',
//     'Commercial Project',
//     'Maintenance Work'
//   ];
//   List<String> citiesEn = [];
//   List<String> citiesHi = [];
//   String? selectedCity;
//   String? selectedState;
//   List<String> statesEn = [];
//   List<String> statesHi = [];
//   FocusNode _focusNode = FocusNode();
//   Map<String, int> stateCodes = {};
//   String? selectedBudget;
//   Future<Map<String, dynamic>> fetchProjectDetails() async {
//     final response = await http.post(
//       Uri.parse(
//           '${Constants.AppConstants.apiUrl}farmer/getProjectDetailsByProjectId'),
//       body: json.encode({'project_id': widget.projectId}),
//       headers: {'Content-Type': 'application/json'},
//     );
//
//     if (response.statusCode == 200) {
//       print("Fdfdf");
//       final data = json.decode(response.body);
//       if (data['status'] == 1) {
//         return data['data']; // Return the project data
//       } else {
//         throw Exception('Failed to load project');
//       }
//     } else {
//       throw Exception('Failed to load project');
//     }
//   }
//
//   Future<void> fetchProjectData() async {
//     try {
//       final projectData = await fetchProjectDetails();
//       print(projectData);
//
//       // Populate controllers with the fetched data
//       titleController.text = projectData['title'] ?? '';
//       _selectedJobType = projectData['job_title'] ?? '';
//
//       // Handling required_skills (single skill or comma-separated)
//       if (projectData['required_skills'] != null) {
//         if (projectData['required_skills'] is String) {
//           selectedSkills = projectData['required_skills']!
//               .split(','); // Split if it's comma-separated
//         } else {
//           selectedSkills = [projectData['required_skills']];
//         }
//       }
//       milestones = projectData['milestones'] is String
//           ? List<Map<String, dynamic>>.from(
//               jsonDecode(projectData['milestones']))
//           : [];
//
//       experienceController.text = projectData['experience']?.toString() ?? '';
//       selectedProjectType = projectData['project_type']?.toString() ?? '';
//       requiredLaboursController.text =
//           projectData['qty_labours']?.toString() ?? '';
//       setState(() {});
//       estimateDaysController.text = projectData['days']?.toString() ?? '';
//       print(budgetController.text);
//
//       budgetController.text = projectData['budget']?.toString() ?? '';
//       descriptionController.text = projectData['description'] ?? '';
//       pinCodeController.text = projectData['pincode']?.toString() ?? '';
//       addressController.text = projectData['address'] ?? '';
//       applicantstatus = projectData['applicants']?.toString() ?? '';
//
//       selectedPaymentType = projectData['payment_type'] == "0"
//           ? "Project Basis"
//           : "Milestone Basis"; // Example logic for payment type
//
//       // Assign city and state correctly
//       String? city = projectData['city'];
//       String? state = projectData['state'];
//
//       if (city != null && city.isNotEmpty) {
//         selectedCity = city;
//         if (!citiesEn.contains(city)) {
//           citiesEn.add(city);
//         }
//       }
//
//       if (state != null && state.isNotEmpty) {
//         selectedState = state;
//         if (!statesEn.contains(state)) {
//           statesEn.add(state);
//         }
//       }
//
//       // Update pincode if available
//       String? zipCode = projectData['pincode'];
//       if (zipCode != null && zipCode.isNotEmpty) {
//         pinCodeController.text = zipCode;
//       }
//
//       // Call setState to reflect the changes in the UI
//       setState(() {});
//     } catch (e) {
//       print("Error fetching project details: $e");
//     }
//   }
//
//   late Future<List<JobType>> _jobTypes;
//   String? _selectedJobType; // Store only the job name (String)
//   // Make it nullable to avoid late initialization error
//   bool isSkillsVisible =
//       false; // Variable to control the visibility of the skill list
//   @override
//   void initState() {
//     super.initState();
//
//     fetchProjectData(); // Listen for focus changes
//     _focusNode.addListener(() {
//       setState(() {
//         // If focus is lost, hide the skills dropdown
//         isSkillsVisible = _focusNode.hasFocus;
//       });
//     });
//   }
//
//   @override
//   void dispose() {
//     _focusNode.dispose(); // Don't forget to dispose of the FocusNode
//     super.dispose();
//   }
//
//   String _selectedLanguage = 'en'; // Default language is English
//
//   Future<void> loadLanguage() async {
//     // Read the selected language from FlutterSecureStorage
//     String? language = await _secureStorage.read(key: 'selectedLanguage');
//     _selectedLanguage = language ?? 'en';
//     print(language); // Default to English if null
//   }
//
//   Map<String, Map<String, String>> _cachedTranslations = {};
//
//   Map<String, Map<String, String>> translations =
//       Constants.AppConstants.translations;
//   final GoogleTranslator _translator = GoogleTranslator();
//   String translateText(String text) {
//     if (text.isEmpty) return "";
//
//     // ✅ Ensure `_selectedLanguage` is set before calling `translateText()`
//     String targetLang = _selectedLanguage ?? 'en'; // Default to English if null
//
//     // ✅ Che❤🤣😂😊ck m✅anual translations first
//     if (translations.containsKey(text) &&
//         translations[text]!.containsKey(targetLang)) {
//       return translations[text]![targetLang]!; // Return manual translation
//     }
//
//     // ✅ Check cached translations
//     if (_cachedTranslations.containsKey(text) &&
//         _cachedTranslations[text]!.containsKey(targetLang)) {
//       return _cachedTranslations[text]![
//           targetLang]!; // Return cached t❤ranslation
//     }
//
//     // ✅ Fetch translation dynamically (but without `await`)
//     _fetchTranslation(text, targetLang); // Runs in background, no need to wait
//
//     return text; // Return original text while translation is being fetched
//   }
//
//   /// ✅ Fetch translation dynamically and update cache
//   Future<void> _fetchTranslation(String text, String targetLang) async {
//     try {
//       // ✅ Check if translation already exists in constants
//       if (Constants.AppConstants.translations.containsKey(text) &&
//           Constants.AppConstants.translations[text]!.containsKey(targetLang)) {
//         return; // No need to fetch if it exists
//       }
//
//       // ✅ Fetch translation dynamically
//       final translation = await _translator.translate(text, to: targetLang);
//
//       // ✅ Initialize default values if text is not in the map
//       if (!translations.containsKey(text)) {
//         translations[text] = {
//           "en": text,
//           "hi": text
//         }; // Default to the same value
//       }
//
//       // ✅ Store the translation in the correct language
//       translations[text]![targetLang] = translation.text;
//
//       // ✅ Store fetched translations in the cache
//       _cachedTranslations = translations;
//
//       // ✅ Also store in the constants translations map
//       if (!Constants.AppConstants.translations.containsKey(text)) {
//         Constants.AppConstants.translations[text] = {};
//       }
//       Constants.AppConstants.translations[text]![targetLang] = translation.text;
//
//       // ✅ Check for missing translations and fetch dynamically
//       for (var key in translations.keys) {
//         if (!translations[key]!.containsKey("hi")) {
//           await _fetchTranslation(key, "hi");
//         }
//         if (!translations[key]!.containsKey("en")) {
//           await _fetchTranslation(key, "en");
//         }
//       }
//
//       // ✅ Store translation in cache
//       _cachedTranslations.putIfAbsent(text, () => {})[targetLang] =
//           translation.text;
//       setState(() {});
//     } catch (e) {
//       print("Translation error: $e");
//     }
//   }
//
//   Future<void> submitForm() async {
//     try {
//       // Read the ID from Flutter Secure Storage
//       String? userId = await _secureStorage.read(key: 'id');
//       if (userId == null) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('User ID not found in secure storage')),
//         );
//         return;
//       }
//
//       final String apiUrl =
//           '${Constants.AppConstants.apiUrl}farmer/Projectupdate'; // Replace with your API URL
//
//       // Prepare the form data
//       final Map<String, dynamic> formData = {
//         'project_id': widget.projectId,
//         'job_title': _selectedJobType,
//         'farmer_id': userId, // Add user ID from secure storage
//         'title': titleController.text,
//         'experience': experienceController.text,
//         'qualification': qualificationController.text,
//         'payment_type': selectedPaymentType,
//         'milestones': milestones,
//
//         'budget': budgetController.text,
//         'qty_labours': requiredLaboursController.text,
//         'days': estimateDaysController.text,
//         'description': descriptionController.text,
//         'pincode': pinCodeController.text,
//         'address': addressController.text,
//         'project_type': selectedProjectType,
//         'skills': selectedSkills,
//         'city': selectedCity,
//         'state': selectedState,
//       };
//
//       print(json.encode(formData));
//
//       // Make the API call
//       final response = await http.post(
//         Uri.parse(apiUrl),
//         headers: {"Content-Type": "application/json"},
//         body: json.encode(formData),
//       );
//
//       if (response.statusCode == 201) {
//         // Handle success
//         // Handle success
//         Fluttertoast.showToast(
//           msg: 'Project Updated Successfully!',
//           toastLength: Toast.LENGTH_SHORT,
//           gravity: ToastGravity.BOTTOM,
//           backgroundColor: Constants.AppColors.brand,
//           textColor: Constants.AppColors.card,
//           fontSize: 16.0,
//         );
//
//         // Wait for 1 second before navigating
//         Future.delayed(Duration(seconds: 1), () {
//           Navigator.pushReplacement(
//             context,
//             MaterialPageRoute(
//               builder: (context) => HomePage(),
//             ),
//           );
//         });
//       } else {
//         // Handle failure
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Failed to add project')),
//         );
//       }
//     } catch (e) {
//       // Handle errors
//     }
//   }
//
//   List<Map<String, dynamic>> milestones = [];
//
//   // Function to show the add milestone dialog
//   void showAddMilestoneDialog() {
//     final descriptionController = TextEditingController();
//     final amountController = TextEditingController();
//
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: Text('Add Milestone'),
//           content: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               TextField(
//                 controller: descriptionController,
//                 decoration: InputDecoration(
//                   labelText: 'Milestone Description',
//                   hintText: 'Enter milestone description',
//                   suffixIcon: MicIconButton(controller: descriptionController),
//                 ),
//               ),
//               SizedBox(height: 10),
//               TextField(
//                 controller: amountController,
//                 decoration: InputDecoration(
//                   labelText: 'Amount',
//                   hintText: 'Enter milestone amount',
//                 ),
//                 keyboardType: TextInputType.number,
//               ),
//             ],
//           ),
//           actions: [
//             TextButton(
//               onPressed: () {
//                 Navigator.pop(context);
//               },
//               child: Text('Cancel'),
//             ),
//             TextButton(
//               onPressed: () {
//                 if (descriptionController.text.isNotEmpty &&
//                     amountController.text.isNotEmpty) {
//                   setState(() {
//                     int newMilestoneNumber = milestones.length + 1;
//                     milestones.add({
//                       'sno':
//                           newMilestoneNumber, // Add serial number to the milestone
//                       'description': descriptionController.text,
//                       'amount': double.tryParse(amountController.text) ?? 0.0,
//                     });
//                     double totalProposalAmount =
//                         milestones.fold(0.0, (sum, milestone) {
//                       // Check if milestone['amount'] is a string, then parse it to double.
//                       double amount = 0.0;
//                       if (milestone['amount'] != null) {
//                         // Try to parse it into a double, if it fails use 0.0 as fallback
//                         amount =
//                             double.tryParse(milestone['amount'].toString()) ??
//                                 0.0;
//                       }
//                       return sum + amount;
//                     });
//
//                     budgetController.text = totalProposalAmount.toString();
//                   });
//                   Navigator.pop(context);
//                 }
//               },
//               child: Text('Add'),
//             ),
//           ],
//         );
//       },
//     );
//   }
//
//   // Function to show the edit milestone dialog
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Constants.AppColors.surface,
//       appBar: AppBar(
//         backgroundColor: Constants.AppColors.brand,
//         foregroundColor: Constants.AppColors.card,
//         elevation: 0,
//         title: Text(
//           AppLocalizations.of(context)!.projectDetails,
//           style: Constants.AppTypography.h3.copyWith(color: Constants.AppColors.card),
//         ),
//         iconTheme: const IconThemeData(color: Constants.AppColors.card),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Form(
//           key: _formKey,
//           child: SingleChildScrollView(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Padding(
//                   padding: const EdgeInsets.all(4.0),
//                   child: Text(
//                     '• ${AppLocalizations.of(context)!.projectDetails}: ${translateText(_selectedJobType!)}',
//                     style: Constants.AppTypography.body.copyWith(color: Constants.AppColors.ink),
//                   ),
//                 ),
//                 Padding(
//                   padding: const EdgeInsets.all(4.0),
//                   child: Text(
//                     '• ${AppLocalizations.of(context)!.workTitle}:  ${translateText(titleController.text.toString().toUpperCase() ?? 'N/A')}',
//                     style: Constants.AppTypography.body.copyWith(color: Constants.AppColors.ink),
//                   ),
//                 ),
//                 Padding(
//                   padding: const EdgeInsets.all(4.0),
//                   child: Text(
//                     '• ${AppLocalizations.of(context)!.projectType}: ${translateText(selectedProjectType ?? 'N/A')}',
//                     style: Constants.AppTypography.body.copyWith(color: Constants.AppColors.ink),
//                   ),
//                 ),
//
//                 // Project Type Dropdown
//                 Padding(
//                   padding: const EdgeInsets.all(4.0),
//                   child: Text(
//                     '• ${AppLocalizations.of(context)!.noOfLaboursRequired}:  ${translateText(requiredLaboursController.text ?? 'N/A')}',
//                     style: Constants.AppTypography.body.copyWith(color: Constants.AppColors.ink),
//                   ),
//                 ),
//
//                 Padding(
//                   padding: const EdgeInsets.all(4.0),
//                   child: Text(
//                     '• ${AppLocalizations.of(context)!.budget}: ${translateText(budgetController.text ?? 'N/A')}',
//                     style: Constants.AppTypography.body.copyWith(color: Constants.AppColors.ink),
//                   ),
//                 ),
//
//                 Padding(
//                   padding: const EdgeInsets.all(4.0),
//                   child: Text(
//                     '• ${AppLocalizations.of(context)!.estimatedDays}: ${translateText(estimateDaysController.text ?? 'N/A')}',
//                     style: Constants.AppTypography.body.copyWith(color: Constants.AppColors.ink),
//                   ),
//                 ),
//
//                 if (selectedSkills.isNotEmpty)
//                   Padding(
//                     padding: const EdgeInsets.all(4.0),
//                     child: Text(
//                       '• ${AppLocalizations.of(context)!.requiredSkills}',
//                       style: Constants.AppTypography.subhead.copyWith(color: Constants.AppColors.ink),
//                     ),
//                   ),
//
//                 if (selectedSkills.isNotEmpty)
//                   Column(
//                     children: selectedSkills.map((skill) {
//                       return Container(
//                         margin: const EdgeInsets.symmetric(
//                             vertical: 4,
//                             horizontal: 8),
//                         decoration: BoxDecoration(
//                           color: Constants.AppColors.card,
//                           borderRadius: BorderRadius.circular(Constants.AppRadii.sm),
//                           border: Border.all(color: Constants.AppColors.border, width: 0.5),
//                           boxShadow: const [Constants.AppShadows.soft],
//                         ),
//                         child: Padding(
//                           padding: const EdgeInsets.all(8),
//                           child: Text(
//                             translateText(skill),
//                             style: Constants.AppTypography.body.copyWith(color: Constants.AppColors.ink),
//                           ),
//                         ),
//                       );
//                     }).toList(),
//                   ),
//                 Padding(
//                   padding: const EdgeInsets.all(4.0),
//                   child: Text(
//                     '• ${AppLocalizations.of(context)!.experienceRequired}: ${translateText(experienceController.text ?? 'N/A')}',
//                     style: Constants.AppTypography.body.copyWith(color: Constants.AppColors.ink),
//                   ),
//                 ),
//
//                 Padding(
//                   padding: const EdgeInsets.all(4.0),
//                   child: Text(
//                     '• ${AppLocalizations.of(context)!.qualification}: ${translateText(qualificationController.text ?? 'N/A')}',
//                     style: Constants.AppTypography.body.copyWith(color: Constants.AppColors.ink),
//                   ),
//                 ),
//
//                 Padding(
//                   padding: const EdgeInsets.all(4.0),
//                   child: Text(
//                     '• ${AppLocalizations.of(context)!.city}: ${translateText(selectedCity ?? 'N/A')}',
//                     style: Constants.AppTypography.body.copyWith(color: Constants.AppColors.ink),
//                   ),
//                 ),
//
//                 Padding(
//                   padding: const EdgeInsets.all(4.0),
//                   child: Text(
//                     '• ${AppLocalizations.of(context)!.state}: ${translateText(selectedState ?? 'N/A')}',
//                     style: Constants.AppTypography.body.copyWith(color: Constants.AppColors.ink),
//                   ),
//                 ),
//
//                 Padding(
//                   padding: const EdgeInsets.all(4.0),
//                   child: Text(
//                     '• ${AppLocalizations.of(context)!.pincode}: ${translateText(pinCodeController.text ?? 'N/A')}',
//                     style: Constants.AppTypography.body.copyWith(color: Constants.AppColors.ink),
//                   ),
//                 ),
//
//                 Padding(
//                   padding: const EdgeInsets.all(4.0),
//                   child: Text(
//                     '• ${AppLocalizations.of(context)!.address}: ${translateText(addressController.text ?? 'N/A')}',
//                     style: Constants.AppTypography.body.copyWith(color: Constants.AppColors.ink),
//                   ),
//                 ),
//
//                 Padding(
//                   padding: const EdgeInsets.all(4.0),
//                   child: Text(
//                     '• ${AppLocalizations.of(context)!.description}: ${translateText(descriptionController.text ?? 'N/A')}',
//                     style: Constants.AppTypography.body.copyWith(color: Constants.AppColors.ink),
//                   ),
//                 ),
//
//                 Padding(
//                   padding: const EdgeInsets.all(4.0),
//                   child: Text(
//                     '• ${AppLocalizations.of(context)!.paymentType}: ${translateText(selectedPaymentType ?? 'N/A')}',
//                     style: Constants.AppTypography.body.copyWith(color: Constants.AppColors.ink),
//                   ),
//                 ),
//
//                 if (selectedPaymentType == "Milestone Basis") ...[
//                   // DataTable to show milestones
//                   DataTable(
//                     columns: [
//                       DataColumn(
//                           label: Text(AppLocalizations.of(context)!
//                               .descriptionColumn)), // Localized description header
//                       DataColumn(
//                           label: Text(AppLocalizations.of(context)!
//                               .amountColumn)), // Localized amount header
//                     ],
//                     rows: List<DataRow>.generate(
//                       milestones.length,
//                       (index) {
//                         return DataRow(
//                           cells: [
//                             DataCell(Text(translateText(milestones[index]
//                                     ['description'] ??
//                                 'N/A'))), // Safely handle null description and translate
//                             DataCell(Text(translateText(milestones[index]
//                                         ['amount']
//                                     .toString() ??
//                                 'N/A'))), // Safely handle null amount and translate
//                           ],
//                         );
//                       },
//                     ),
//                   ),
//                 ],
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }


import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:greencollar/speech_helper.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:greencollar/Addproject.dart';
import 'package:greencollar/HomeScree.dart';
import 'package:provider/provider.dart';
import 'package:greencollar/main.dart';
import 'package:http/http.dart' as http;
import 'package:greencollar/constants.dart' as Constants;
import 'package:translator/translator.dart';
import 'package:greencollar/l10n/app_localizations.dart';

class ProjectDetails extends StatefulWidget {
  final String projectId;

  ProjectDetails({required this.projectId});

  @override
  _ProjectDetailsState createState() => _ProjectDetailsState();
}

class _ProjectDetailsState extends State<ProjectDetails> {
  final _formKey = GlobalKey<FormState>();
  final FlutterSecureStorage _secureStorage = FlutterSecureStorage();

  final TextEditingController titleController = TextEditingController();
  final TextEditingController experienceController = TextEditingController();
  final TextEditingController qualificationController = TextEditingController();
  final TextEditingController requiredLaboursController = TextEditingController();
  final TextEditingController budgetController = TextEditingController();
  final TextEditingController estimateDaysController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController pinCodeController = TextEditingController();
  final TextEditingController addressController = TextEditingController();

  String? selectedProjectType;
  String? selectedPaymentType;
  String? applicantstatus;
  String? selectedSkill;
  String? selectedLanguage;
  List<Skill> skills = [];
  List<String> selectedSkills = [];
  List<String> citiesEn = [];
  List<String> citiesHi = [];
  String? selectedCity;
  String? selectedState;
  List<String> statesEn = [];
  List<String> statesHi = [];
  FocusNode _focusNode = FocusNode();
  Map<String, int> stateCodes = {};
  String? selectedBudget;
  String? postedBy;
  String? postedDate;
  String? projectStatus;
  bool _isSpeaking = false;

  Future<Map<String, dynamic>> fetchProjectDetails() async {
    final response = await http.post(
      Uri.parse('${Constants.AppConstants.apiUrl}farmer/getProjectDetailsByProjectId'),
      body: json.encode({'project_id': widget.projectId}),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['status'] == 1) {
        return data['data'];
      } else {
        throw Exception('Failed to load project');
      }
    } else {
      throw Exception('Failed to load project');
    }
  }

  Future<void> fetchProjectData() async {
    try {
      final projectData = await fetchProjectDetails();

      titleController.text = projectData['title'] ?? '';
      _selectedJobType = projectData['job_title'] ?? '';
      postedBy = projectData['posted_by'] ?? '';
      postedDate = projectData['created_at'] ?? '';
      projectStatus = projectData['status'] ?? 'Active';

      if (projectData['required_skills'] != null) {
        if (projectData['required_skills'] is String) {
          selectedSkills = projectData['required_skills']!.split(',');
        } else {
          selectedSkills = [projectData['required_skills']];
        }
      }

      milestones = projectData['milestones'] is String
          ? List<Map<String, dynamic>>.from(jsonDecode(projectData['milestones']))
          : [];

      experienceController.text = projectData['experience']?.toString() ?? '';
      selectedProjectType = projectData['project_type']?.toString() ?? '';
      requiredLaboursController.text = projectData['qty_labours']?.toString() ?? '';
      estimateDaysController.text = projectData['days']?.toString() ?? '';
      budgetController.text = projectData['budget']?.toString() ?? '';
      descriptionController.text = projectData['description'] ?? '';
      pinCodeController.text = projectData['pincode']?.toString() ?? '';
      addressController.text = projectData['address'] ?? '';
      applicantstatus = projectData['applicants']?.toString() ?? '';

      selectedPaymentType = projectData['payment_type'] == "0"
          ? "Project Basis"
          : "Milestone Basis";

      String? city = projectData['city'];
      String? state = projectData['state'];

      if (city != null && city.isNotEmpty) {
        selectedCity = city;
        if (!citiesEn.contains(city)) citiesEn.add(city);
      }

      if (state != null && state.isNotEmpty) {
        selectedState = state;
        if (!statesEn.contains(state)) statesEn.add(state);
      }

      String? zipCode = projectData['pincode'];
      if (zipCode != null && zipCode.isNotEmpty) {
        pinCodeController.text = zipCode;
      }

      setState(() {});
    } catch (e) {
      print("Error fetching project details: $e");
    }
  }

  late Future<List<JobType>> _jobTypes;
  String? _selectedJobType;
  bool isSkillsVisible = false;

  @override
  void initState() {
    super.initState();
    fetchProjectData();
    _focusNode.addListener(() {
      setState(() {
        isSkillsVisible = _focusNode.hasFocus;
      });
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  String _selectedLanguage = 'en';

  Future<void> loadLanguage() async {
    String? language = await _secureStorage.read(key: 'selectedLanguage');
    _selectedLanguage = language ?? 'en';
  }

  Map<String, Map<String, String>> _cachedTranslations = {};
  Map<String, Map<String, String>> translations = Constants.AppConstants.translations;
  final GoogleTranslator _translator = GoogleTranslator();

  String translateText(String text) {
    if (text.isEmpty) return "";
    String targetLang = _selectedLanguage ?? 'en';
    if (translations.containsKey(text) && translations[text]!.containsKey(targetLang)) {
      return translations[text]![targetLang]!;
    }
    if (_cachedTranslations.containsKey(text) && _cachedTranslations[text]!.containsKey(targetLang)) {
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
      _cachedTranslations.putIfAbsent(text, () => {})[targetLang] = translation.text;
      setState(() {});
    } catch (e) {
      print("Translation error: $e");
    }
  }

  Future<void> submitForm() async {
    try {
      String? userId = await _secureStorage.read(key: 'id');
      if (userId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('User ID not found in secure storage')),
        );
        return;
      }

      final String apiUrl = '${Constants.AppConstants.apiUrl}farmer/Projectupdate';
      final Map<String, dynamic> formData = {
        'project_id': widget.projectId,
        'job_title': _selectedJobType,
        'farmer_id': userId,
        'title': titleController.text,
        'experience': experienceController.text,
        'qualification': qualificationController.text,
        'payment_type': selectedPaymentType,
        'milestones': milestones,
        'budget': budgetController.text,
        'qty_labours': requiredLaboursController.text,
        'days': estimateDaysController.text,
        'description': descriptionController.text,
        'pincode': pinCodeController.text,
        'address': addressController.text,
        'project_type': selectedProjectType,
        'skills': selectedSkills,
        'city': selectedCity,
        'state': selectedState,
      };

      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {"Content-Type": "application/json"},
        body: json.encode(formData),
      );

      if (response.statusCode == 201) {
        Fluttertoast.showToast(
          msg: 'Project Updated Successfully!',
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
          SnackBar(content: Text('Failed to add project')),
        );
      }
    } catch (e) {
      print("Submit error: $e");
    }
  }

  List<Map<String, dynamic>> milestones = [];

  void showAddMilestoneDialog() {
    final descriptionController = TextEditingController();
    final amountController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Add Milestone'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: descriptionController,
                decoration: InputDecoration(
                  labelText: 'Milestone Description',
                  hintText: 'Enter milestone description',
                  suffixIcon: MicIconButton(controller: descriptionController),
                ),
              ),
              SizedBox(height: 10),
              TextField(
                controller: amountController,
                decoration: InputDecoration(
                  labelText: 'Amount',
                  hintText: 'Enter milestone amount',
                ),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (descriptionController.text.isNotEmpty &&
                    amountController.text.isNotEmpty) {
                  setState(() {
                    int newMilestoneNumber = milestones.length + 1;
                    milestones.add({
                      'sno': newMilestoneNumber,
                      'description': descriptionController.text,
                      'amount': double.tryParse(amountController.text) ?? 0.0,
                    });
                    double totalProposalAmount = milestones.fold(0.0, (sum, milestone) {
                      double amount = 0.0;
                      if (milestone['amount'] != null) {
                        amount = double.tryParse(milestone['amount'].toString()) ?? 0.0;
                      }
                      return sum + amount;
                    });
                    budgetController.text = totalProposalAmount.toString();
                  });
                  Navigator.pop(context);
                }
              },
              child: Text('Add'),
            ),
          ],
        );
      },
    );
  }

  // ─── UI helpers ──────────────────────────────────────────────────────────────

  /// Small stat cell used in the 3-column info grid
  Widget _infoCell({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Expanded(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: const BoxDecoration(
              color: Color(0xFFEAF4E8),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: const Color(0xFF0E6805),
              size: 16,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey[500],
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF152018),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final String jobTitle = translateText(_selectedJobType ?? '');
    final String title = translateText(titleController.text.toUpperCase());
    final String budget = budgetController.text.isNotEmpty
        ? '₹${budgetController.text}'
        : 'N/A';
    final String workers = requiredLaboursController.text.isNotEmpty
        ? requiredLaboursController.text
        : 'N/A';
    final String duration = estimateDaysController.text.isNotEmpty
        ? estimateDaysController.text
        : 'N/A';
    final String city = selectedCity ?? 'N/A';
    final String state = selectedState ?? 'N/A';
    final String address = addressController.text.isNotEmpty
        ? addressController.text
        : 'N/A';
    final String projectType = translateText(selectedProjectType ?? 'N/A');
    final String description = descriptionController.text.isNotEmpty
        ? descriptionController.text
        : 'N/A';
    final String paymentType = translateText(selectedPaymentType ?? 'N/A');

    return Scaffold(
      backgroundColor: const Color(0xFFFAFBF7),
      appBar: AppBar(
        backgroundColor: Constants.AppColors.brand,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(
          AppLocalizations.of(context)!.projectDetails,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          // ── Scrollable content ───────────────────────────────────────────
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Hero card ─────────────────────────────────────────────
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
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title row with status badge
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Custom painted cow avatar
                            const CowAvatar(size: 70),
                            const SizedBox(width: 12),
                            // Title + poster
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    title.isNotEmpty ? title : jobTitle,
                                    style: const TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFF1B2B1B),
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Row(
                                    children: [
                                      Icon(Icons.person_outline,
                                          size: 14, color: Colors.grey[500]),
                                      const SizedBox(width: 4),
                                      Text(
                                        'Posted by ',
                                        style: TextStyle(
                                            fontSize: 11,
                                            color: Colors.grey[500]),
                                      ),
                                      Text(
                                        postedBy ?? '',
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: Constants.AppColors.brand,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Icon(Icons.calendar_today_outlined,
                                          size: 11, color: Colors.grey[400]),
                                      const SizedBox(width: 3),
                                      Text(
                                        postedDate ?? '',
                                        style: TextStyle(
                                            fontSize: 11,
                                            color: Colors.grey[500]),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 4),
                            // Active badge
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color(0xFFEAF4E8),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                    color: const Color(0xFFA5D6A7), width: 1),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.check,
                                      size: 11,
                                      color: Constants.AppColors.brand),
                                  const SizedBox(width: 2),
                                  Text(
                                    projectStatus ?? 'Active',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: Constants.AppColors.brand,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 20),

                        // ── Stats row 1: Budget | Workers | Duration ──────────
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _infoCell(
                              icon: Icons.currency_rupee,
                              label: 'Budget',
                              value: budget,
                            ),
                            _infoCell(
                              icon: Icons.group_outlined,
                              label: 'Workers Required',
                              value: workers,
                            ),
                            _infoCell(
                              icon: Icons.access_time_outlined,
                              label: 'Duration',
                              value: duration,
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        // ── Stats row 2: Location | Address | Project Type ────
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _infoCell(
                              icon: Icons.location_on_outlined,
                              label: 'Location',
                              value: '$city, $state',
                            ),
                            _infoCell(
                              icon: Icons.business_outlined,
                              label: 'Address',
                              value: address,
                            ),
                            _infoCell(
                              icon: Icons.description_outlined,
                              label: 'Project Type',
                              value: projectType,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Skills Required Card
                  Container(
                    width: double.infinity,
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
                            Container(
                              width: 36,
                              height: 36,
                              decoration: const BoxDecoration(
                                color: Color(0xFFFFF3E0),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.workspace_premium_outlined,
                                color: Color(0xFFFF8F00),
                                size: 18,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              translateText('Skills Required'),
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF1B2B1B),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        if (selectedSkills.isEmpty || (selectedSkills.length == 1 && selectedSkills.first.trim() == 'N/A'))
                          Text(
                            translateText('N/A'),
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFFB45309),
                            ),
                          )
                        else
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: selectedSkills.map((skill) {
                              final cleanSkill = translateText(skill.toString().trim());
                              if (cleanSkill.isEmpty) return const SizedBox.shrink();
                              return Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFFFBEB),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color: const Color(0xFFFDE68A), width: 1),
                                ),
                                child: Text(
                                  cleanSkill,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFFB45309),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Payment Type Card
                  Container(
                    width: double.infinity,
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
                    child: Row(
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: const BoxDecoration(
                            color: Color(0xFFEAF4E8),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.receipt_long_outlined,
                            color: Color(0xFF0E6805),
                            size: 18,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                translateText('Payment Type'),
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey[500],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                paymentType,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF152018),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  // ── Project Description card ───────────────────────────────
                  Container(
                    width: double.infinity,
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
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.assignment_outlined,
                                    color: Constants.AppColors.brand, size: 20),
                                const SizedBox(width: 8),
                                Text(
                                  'Project Description',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    color: Constants.AppColors.ink,
                                  ),
                                ),
                              ],
                            ),
                            // Text-to-speech speaker button
                            GestureDetector(
                              onTap: () {
                                if (_isSpeaking) {
                                  SpeechHelper.stop();
                                  setState(() {
                                    _isSpeaking = false;
                                  });
                                } else {
                                  SpeechHelper.speak(
                                    translateText(description),
                                    _selectedLanguage,
                                    onStart: () {
                                      setState(() {
                                        _isSpeaking = true;
                                      });
                                    },
                                    onComplete: () {
                                      setState(() {
                                        _isSpeaking = false;
                                      });
                                    },
                                    onError: () {
                                      setState(() {
                                        _isSpeaking = false;
                                      });
                                    },
                                  );
                                }
                              },
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: const BoxDecoration(
                                  color: Color(0xFFEAF4E8),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  _isSpeaking ? Icons.volume_up : Icons.volume_up_outlined,
                                  color: Constants.AppColors.brand,
                                  size: 18,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(
                          translateText(description),
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[700],
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // ── Milestone & Payment section (only if Milestone Basis) ──
                  if (selectedPaymentType == "Milestone Basis" &&
                      milestones.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Container(
                      width: double.infinity,
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
                          // Section header
                          Row(
                            children: [
                              Icon(Icons.layers_outlined,
                                  color: Constants.AppColors.brand, size: 20),
                              const SizedBox(width: 8),
                              Text(
                                'Milestone & Payment',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    color: Constants.AppColors.ink,
                                  ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),

                            // Horizontally Scrollable Table
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: SizedBox(
                                width: 560,
                                child: Column(
                                  children: [
                                    // Table header with rounded top corners
                                    Container(
                                      decoration: BoxDecoration(
                                        color: Constants.AppColors.brand,
                                        borderRadius: const BorderRadius.only(
                                          topLeft: Radius.circular(8),
                                          topRight: Radius.circular(8),
                                        ),
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 12, vertical: 10),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            flex: 3,
                                            child: Text(
                                              AppLocalizations.of(context)!
                                                  .descriptionColumn,
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.w600,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            flex: 2,
                                            child: Text(
                                              'Amount (₹)',
                                              textAlign: TextAlign.center,
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.w600,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            flex: 2,
                                            child: Text(
                                              'Your Proposal (₹)',
                                              textAlign: TextAlign.right,
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.w600,
                                                fontSize: 12,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),

                                      // Table rows
                                      ...List.generate(milestones.length, (index) {
                                        final milestone = milestones[index];
                                        final isEven = index % 2 == 0;
                                        return Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 12, vertical: 12),
                                          decoration: BoxDecoration(
                                            color: isEven
                                                ? Colors.white
                                                : const Color(0xFFF9FBF9),
                                            border: Border(
                                              bottom: BorderSide(
                                                color: Colors.grey[100]!,
                                                width: 1,
                                              ),
                                            ),
                                          ),
                                          child: Row(
                                            children: [
                                              Expanded(
                                                flex: 3,
                                                child: Text(
                                                  translateText(
                                                      milestone['description'] ?? 'N/A'),
                                                  style: TextStyle(
                                                    fontSize: 13,
                                                    color: Constants.AppColors.ink,
                                                  ),
                                                ),
                                              ),
                                              Expanded(
                                                flex: 2,
                                                child: Text(
                                                  milestone['amount']?.toString() ?? 'N/A',
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                    fontSize: 13,
                                                    color: Constants.AppColors.ink,
                                                  ),
                                                ),
                                              ),
                                              Expanded(
                                                flex: 2,
                                                child: Text(
                                                  milestone['proposal']?.toString() ?? '-',
                                                  textAlign: TextAlign.right,
                                                  style: TextStyle(
                                                    fontSize: 13,
                                                    color: Constants.AppColors.ink,
                                                  ),
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

                          const SizedBox(height: 12),

                          // Summary footer: Proposal Amount | Est. Duration | Comment
                          Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFFF1F9F1), // Light green background
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.all(12),
                            child: Row(
                              children: [
                                // Proposal Amount
                                Expanded(
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 32,
                                        height: 32,
                                        decoration: const BoxDecoration(
                                          color: Color(0xFFEAF4E8),
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(
                                          Icons.edit_note_outlined,
                                          color: Color(0xFF0E6805),
                                          size: 18,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            const Text(
                                              'Proposal Amount',
                                              style: TextStyle(
                                                fontSize: 10,
                                                color: Color(0xFF5B6B5E),
                                                fontWeight: FontWeight.w500,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              budget,
                                              style: const TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                                color: Color(0xFF152018),
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                // Estimate Duration
                                Expanded(
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 32,
                                        height: 32,
                                        decoration: const BoxDecoration(
                                          color: Color(0xFFEAF4E8),
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(
                                          Icons.access_time_outlined,
                                          color: Color(0xFF0E6805),
                                          size: 18,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            const Text(
                                              'Estimate Duration',
                                              style: TextStyle(
                                                fontSize: 10,
                                                color: Color(0xFF5B6B5E),
                                                fontWeight: FontWeight.w500,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              duration,
                                              style: const TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                                color: Color(0xFF152018),
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                // Comment
                                Expanded(
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 32,
                                        height: 32,
                                        decoration: const BoxDecoration(
                                          color: Color(0xFFEAF4E8),
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(
                                          Icons.chat_bubble_outline,
                                          color: Color(0xFF0E6805),
                                          size: 16,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            const Text(
                                              'Comment',
                                              style: TextStyle(
                                                fontSize: 10,
                                                color: Color(0xFF5B6B5E),
                                                fontWeight: FontWeight.w500,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              applicantstatus ?? '-',
                                              style: const TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                                color: Color(0xFF152018),
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),

          // ── Fixed bottom CTA ───────────────────────────────────────────────
          Container(
            color: const Color(0xFFFAFBF7),
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            child: SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: submitForm,
                icon: const Icon(Icons.send, color: Colors.white, size: 18),
                label: const Text(
                  'Request For Complete',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 0.3,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Constants.AppColors.brand,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Custom Cow Avatar & Painter ──────────────────────────────────────────────

class CowAvatar extends StatelessWidget {
  final double size;
  const CowAvatar({Key? key, this.size = 70}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        color: Color(0xFFEAF4E8),
        shape: BoxShape.circle,
      ),
      child: CustomPaint(
        size: Size(size, size),
        painter: CowPainter(),
      ),
    );
  }
}

class CowPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF0E6805)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final fillPaint = Paint()
      ..color = const Color(0xFF0E6805)
      ..style = PaintingStyle.fill;

    final double w = size.width;
    final double h = size.height;
    final double scale = w / 100;

    // Head / Face outline path
    final facePath = Path()
      ..moveTo(38 * scale, 32 * scale)
      ..lineTo(62 * scale, 32 * scale)
      ..quadraticBezierTo(65 * scale, 45 * scale, 64 * scale, 58 * scale)
      ..quadraticBezierTo(50 * scale, 60 * scale, 36 * scale, 58 * scale)
      ..quadraticBezierTo(35 * scale, 45 * scale, 38 * scale, 32 * scale);
    canvas.drawPath(facePath, paint);

    // Muzzle / Snout cup shape
    final muzzlePath = Path()
      ..moveTo(36 * scale, 58 * scale)
      ..cubicTo(32 * scale, 68 * scale, 40 * scale, 76 * scale, 50 * scale, 76 * scale)
      ..cubicTo(60 * scale, 76 * scale, 68 * scale, 68 * scale, 64 * scale, 58 * scale)
      ..quadraticBezierTo(50 * scale, 60 * scale, 36 * scale, 58 * scale);
    canvas.drawPath(muzzlePath, paint);

    // Left Ear
    final leftEar = Path()
      ..moveTo(35 * scale, 38 * scale)
      ..quadraticBezierTo(15 * scale, 35 * scale, 12 * scale, 45 * scale)
      ..quadraticBezierTo(18 * scale, 52 * scale, 35 * scale, 46 * scale);
    canvas.drawPath(leftEar, paint);

    // Right Ear
    final rightEar = Path()
      ..moveTo(65 * scale, 38 * scale)
      ..quadraticBezierTo(85 * scale, 35 * scale, 88 * scale, 45 * scale)
      ..quadraticBezierTo(82 * scale, 52 * scale, 65 * scale, 46 * scale);
    canvas.drawPath(rightEar, paint);

    // Left Horn
    final leftHorn = Path()
      ..moveTo(39 * scale, 32 * scale)
      ..quadraticBezierTo(32 * scale, 14 * scale, 22 * scale, 17 * scale)
      ..quadraticBezierTo(30 * scale, 24 * scale, 43 * scale, 30 * scale);
    canvas.drawPath(leftHorn, paint);

    // Right Horn
    final rightHorn = Path()
      ..moveTo(61 * scale, 32 * scale)
      ..quadraticBezierTo(68 * scale, 14 * scale, 78 * scale, 17 * scale)
      ..quadraticBezierTo(70 * scale, 24 * scale, 57 * scale, 30 * scale);
    canvas.drawPath(rightHorn, paint);

    // Eyes
    canvas.drawCircle(Offset(44 * scale, 44 * scale), 1.8 * scale, fillPaint);
    canvas.drawCircle(Offset(56 * scale, 44 * scale), 1.8 * scale, fillPaint);

    // Nostrils
    canvas.drawCircle(Offset(44 * scale, 66 * scale), 1.5 * scale, fillPaint);
    canvas.drawCircle(Offset(56 * scale, 66 * scale), 1.5 * scale, fillPaint);

    // "IWM" text below the muzzle
    final textPainter = TextPainter(
      text: TextSpan(
        text: 'IWM',
        style: TextStyle(
          color: const Color(0xFF0E6805),
          fontSize: 8.5 * scale,
          fontWeight: FontWeight.w900,
          letterSpacing: 0.8,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset((50 * scale) - (textPainter.width / 2), 79 * scale),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}