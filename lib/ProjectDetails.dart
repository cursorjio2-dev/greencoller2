import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:greencollar/speech_helper.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:greencollar/Addproject.dart';
import 'package:greencollar/HomeScree.dart';
import 'package:provider/provider.dart';
import 'package:greencollar/main.dart'; // Adjust the import as needed
import 'package:http/http.dart' as http;
import 'package:greencollar/constants.dart' as Constants;
import 'package:translator/translator.dart';
import 'package:greencollar/l10n/app_localizations.dart';

class ProjectDetails extends StatefulWidget {
  final String projectId;

  ProjectDetails({required this.projectId});

  // Constructor to accept the projectType argument

  @override
  _ProjectDetailsState createState() => _ProjectDetailsState();
}

class _ProjectDetailsState extends State<ProjectDetails> {
  final _formKey = GlobalKey<FormState>();
  final FlutterSecureStorage _secureStorage = FlutterSecureStorage();

  final TextEditingController titleController = TextEditingController();
  final TextEditingController experienceController = TextEditingController();
  final TextEditingController qualificationController = TextEditingController();

  final TextEditingController requiredLaboursController =
      TextEditingController();
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
  final List<String> descriptions = [
    'Home Renovation',
    'Commercial Project',
    'Maintenance Work'
  ];
  List<String> citiesEn = [];
  List<String> citiesHi = [];
  String? selectedCity;
  String? selectedState;
  List<String> statesEn = [];
  List<String> statesHi = [];
  FocusNode _focusNode = FocusNode();
  Map<String, int> stateCodes = {};
  String? selectedBudget;
  Future<Map<String, dynamic>> fetchProjectDetails() async {
    final response = await http.post(
      Uri.parse(
          '${Constants.AppConstants.apiUrl}farmer/getProjectDetailsByProjectId'),
      body: json.encode({'project_id': widget.projectId}),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      print("Fdfdf");
      final data = json.decode(response.body);
      if (data['status'] == 1) {
        return data['data']; // Return the project data
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
      print(projectData);

      // Populate controllers with the fetched data
      titleController.text = projectData['title'] ?? '';
      _selectedJobType = projectData['job_title'] ?? '';

      // Handling required_skills (single skill or comma-separated)
      if (projectData['required_skills'] != null) {
        if (projectData['required_skills'] is String) {
          selectedSkills = projectData['required_skills']!
              .split(','); // Split if it's comma-separated
        } else {
          selectedSkills = [projectData['required_skills']];
        }
      }
      milestones = projectData['milestones'] is String
          ? List<Map<String, dynamic>>.from(
              jsonDecode(projectData['milestones']))
          : [];

      experienceController.text = projectData['experience']?.toString() ?? '';
      selectedProjectType = projectData['project_type']?.toString() ?? '';
      requiredLaboursController.text =
          projectData['qty_labours']?.toString() ?? '';
      setState(() {});
      estimateDaysController.text = projectData['days']?.toString() ?? '';
      print(budgetController.text);

      budgetController.text = projectData['budget']?.toString() ?? '';
      descriptionController.text = projectData['description'] ?? '';
      pinCodeController.text = projectData['pincode']?.toString() ?? '';
      addressController.text = projectData['address'] ?? '';
      applicantstatus = projectData['applicants']?.toString() ?? '';

      selectedPaymentType = projectData['payment_type'] == "0"
          ? "Project Basis"
          : "Milestone Basis"; // Example logic for payment type

      // Assign city and state correctly
      String? city = projectData['city'];
      String? state = projectData['state'];

      if (city != null && city.isNotEmpty) {
        selectedCity = city;
        if (!citiesEn.contains(city)) {
          citiesEn.add(city);
        }
      }

      if (state != null && state.isNotEmpty) {
        selectedState = state;
        if (!statesEn.contains(state)) {
          statesEn.add(state);
        }
      }

      // Update pincode if available
      String? zipCode = projectData['pincode'];
      if (zipCode != null && zipCode.isNotEmpty) {
        pinCodeController.text = zipCode;
      }

      // Call setState to reflect the changes in the UI
      setState(() {});
    } catch (e) {
      print("Error fetching project details: $e");
    }
  }

  late Future<List<JobType>> _jobTypes;
  String? _selectedJobType; // Store only the job name (String)
  // Make it nullable to avoid late initialization error
  bool isSkillsVisible =
      false; // Variable to control the visibility of the skill list
  @override
  void initState() {
    super.initState();

    fetchProjectData(); // Listen for focus changes
    _focusNode.addListener(() {
      setState(() {
        // If focus is lost, hide the skills dropdown
        isSkillsVisible = _focusNode.hasFocus;
      });
    });
  }

  @override
  void dispose() {
    _focusNode.dispose(); // Don't forget to dispose of the FocusNode
    super.dispose();
  }

  String _selectedLanguage = 'en'; // Default language is English

  Future<void> loadLanguage() async {
    // Read the selected language from FlutterSecureStorage
    String? language = await _secureStorage.read(key: 'selectedLanguage');
    _selectedLanguage = language ?? 'en';
    print(language); // Default to English if null
  }

  Map<String, Map<String, String>> _cachedTranslations = {};

  Map<String, Map<String, String>> translations =
      Constants.AppConstants.translations;
  final GoogleTranslator _translator = GoogleTranslator();
  String translateText(String text) {
    if (text.isEmpty) return "";

    // ✅ Ensure `_selectedLanguage` is set before calling `translateText()`
    String targetLang = _selectedLanguage ?? 'en'; // Default to English if null

    // ✅ Che❤🤣😂😊ck m✅anual translations first
    if (translations.containsKey(text) &&
        translations[text]!.containsKey(targetLang)) {
      return translations[text]![targetLang]!; // Return manual translation
    }

    // ✅ Check cached translations
    if (_cachedTranslations.containsKey(text) &&
        _cachedTranslations[text]!.containsKey(targetLang)) {
      return _cachedTranslations[text]![
          targetLang]!; // Return cached t❤ranslation
    }

    // ✅ Fetch translation dynamically (but without `await`)
    _fetchTranslation(text, targetLang); // Runs in background, no need to wait

    return text; // Return original text while translation is being fetched
  }

  /// ✅ Fetch translation dynamically and update cache
  Future<void> _fetchTranslation(String text, String targetLang) async {
    try {
      // ✅ Check if translation already exists in constants
      if (Constants.AppConstants.translations.containsKey(text) &&
          Constants.AppConstants.translations[text]!.containsKey(targetLang)) {
        return; // No need to fetch if it exists
      }

      // ✅ Fetch translation dynamically
      final translation = await _translator.translate(text, to: targetLang);

      // ✅ Initialize default values if text is not in the map
      if (!translations.containsKey(text)) {
        translations[text] = {
          "en": text,
          "hi": text
        }; // Default to the same value
      }

      // ✅ Store the translation in the correct language
      translations[text]![targetLang] = translation.text;

      // ✅ Store fetched translations in the cache
      _cachedTranslations = translations;

      // ✅ Also store in the constants translations map
      if (!Constants.AppConstants.translations.containsKey(text)) {
        Constants.AppConstants.translations[text] = {};
      }
      Constants.AppConstants.translations[text]![targetLang] = translation.text;

      // ✅ Check for missing translations and fetch dynamically
      for (var key in translations.keys) {
        if (!translations[key]!.containsKey("hi")) {
          await _fetchTranslation(key, "hi");
        }
        if (!translations[key]!.containsKey("en")) {
          await _fetchTranslation(key, "en");
        }
      }

      // ✅ Store translation in cache
      _cachedTranslations.putIfAbsent(text, () => {})[targetLang] =
          translation.text;
      setState(() {});
    } catch (e) {
      print("Translation error: $e");
    }
  }

  Future<void> submitForm() async {
    try {
      // Read the ID from Flutter Secure Storage
      String? userId = await _secureStorage.read(key: 'id');
      if (userId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('User ID not found in secure storage')),
        );
        return;
      }

      final String apiUrl =
          '${Constants.AppConstants.apiUrl}farmer/Projectupdate'; // Replace with your API URL

      // Prepare the form data
      final Map<String, dynamic> formData = {
        'project_id': widget.projectId,
        'job_title': _selectedJobType,
        'farmer_id': userId, // Add user ID from secure storage
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

      print(json.encode(formData));

      // Make the API call
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {"Content-Type": "application/json"},
        body: json.encode(formData),
      );

      if (response.statusCode == 201) {
        // Handle success
        // Handle success
        Fluttertoast.showToast(
          msg: 'Project Updated Successfully!',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Constants.AppColors.brand,
          textColor: Constants.AppColors.card,
          fontSize: 16.0,
        );

        // Wait for 1 second before navigating
        Future.delayed(Duration(seconds: 1), () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => HomePage(),
            ),
          );
        });
      } else {
        // Handle failure
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add project')),
        );
      }
    } catch (e) {
      // Handle errors
    }
  }

  List<Map<String, dynamic>> milestones = [];

  // Function to show the add milestone dialog
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
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (descriptionController.text.isNotEmpty &&
                    amountController.text.isNotEmpty) {
                  setState(() {
                    int newMilestoneNumber = milestones.length + 1;
                    milestones.add({
                      'sno':
                          newMilestoneNumber, // Add serial number to the milestone
                      'description': descriptionController.text,
                      'amount': double.tryParse(amountController.text) ?? 0.0,
                    });
                    double totalProposalAmount =
                        milestones.fold(0.0, (sum, milestone) {
                      // Check if milestone['amount'] is a string, then parse it to double.
                      double amount = 0.0;
                      if (milestone['amount'] != null) {
                        // Try to parse it into a double, if it fails use 0.0 as fallback
                        amount =
                            double.tryParse(milestone['amount'].toString()) ??
                                0.0;
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

  // Function to show the edit milestone dialog

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Constants.AppColors.surface,
      appBar: AppBar(
        backgroundColor: Constants.AppColors.brand,
        foregroundColor: Constants.AppColors.card,
        elevation: 0,
        title: Text(
          AppLocalizations.of(context)!.projectDetails,
          style: Constants.AppTypography.h3.copyWith(color: Constants.AppColors.card),
        ),
        iconTheme: const IconThemeData(color: Constants.AppColors.card),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Text(
                    '• ${AppLocalizations.of(context)!.projectDetails}: ${translateText(_selectedJobType!)}',
                    style: Constants.AppTypography.body.copyWith(color: Constants.AppColors.ink),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Text(
                    '• ${AppLocalizations.of(context)!.workTitle}:  ${translateText(titleController.text.toString().toUpperCase() ?? 'N/A')}',
                    style: Constants.AppTypography.body.copyWith(color: Constants.AppColors.ink),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Text(
                    '• ${AppLocalizations.of(context)!.projectType}: ${translateText(selectedProjectType ?? 'N/A')}',
                    style: Constants.AppTypography.body.copyWith(color: Constants.AppColors.ink),
                  ),
                ),

                // Project Type Dropdown
                Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Text(
                    '• ${AppLocalizations.of(context)!.noOfLaboursRequired}:  ${translateText(requiredLaboursController.text ?? 'N/A')}',
                    style: Constants.AppTypography.body.copyWith(color: Constants.AppColors.ink),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Text(
                    '• ${AppLocalizations.of(context)!.budget}: ${translateText(budgetController.text ?? 'N/A')}',
                    style: Constants.AppTypography.body.copyWith(color: Constants.AppColors.ink),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Text(
                    '• ${AppLocalizations.of(context)!.estimatedDays}: ${translateText(estimateDaysController.text ?? 'N/A')}',
                    style: Constants.AppTypography.body.copyWith(color: Constants.AppColors.ink),
                  ),
                ),

                if (selectedSkills.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: Text(
                      '• ${AppLocalizations.of(context)!.requiredSkills}',
                      style: Constants.AppTypography.subhead.copyWith(color: Constants.AppColors.ink),
                    ),
                  ),

                if (selectedSkills.isNotEmpty)
                  Column(
                    children: selectedSkills.map((skill) {
                      return Container(
                        margin: const EdgeInsets.symmetric(
                            vertical: 4,
                            horizontal: 8),
                        decoration: BoxDecoration(
                          color: Constants.AppColors.card,
                          borderRadius: BorderRadius.circular(Constants.AppRadii.sm),
                          border: Border.all(color: Constants.AppColors.border, width: 0.5),
                          boxShadow: const [Constants.AppShadows.soft],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8),
                          child: Text(
                            translateText(skill),
                            style: Constants.AppTypography.body.copyWith(color: Constants.AppColors.ink),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Text(
                    '• ${AppLocalizations.of(context)!.experienceRequired}: ${translateText(experienceController.text ?? 'N/A')}',
                    style: Constants.AppTypography.body.copyWith(color: Constants.AppColors.ink),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Text(
                    '• ${AppLocalizations.of(context)!.qualification}: ${translateText(qualificationController.text ?? 'N/A')}',
                    style: Constants.AppTypography.body.copyWith(color: Constants.AppColors.ink),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Text(
                    '• ${AppLocalizations.of(context)!.city}: ${translateText(selectedCity ?? 'N/A')}',
                    style: Constants.AppTypography.body.copyWith(color: Constants.AppColors.ink),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Text(
                    '• ${AppLocalizations.of(context)!.state}: ${translateText(selectedState ?? 'N/A')}',
                    style: Constants.AppTypography.body.copyWith(color: Constants.AppColors.ink),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Text(
                    '• ${AppLocalizations.of(context)!.pincode}: ${translateText(pinCodeController.text ?? 'N/A')}',
                    style: Constants.AppTypography.body.copyWith(color: Constants.AppColors.ink),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Text(
                    '• ${AppLocalizations.of(context)!.address}: ${translateText(addressController.text ?? 'N/A')}',
                    style: Constants.AppTypography.body.copyWith(color: Constants.AppColors.ink),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Text(
                    '• ${AppLocalizations.of(context)!.description}: ${translateText(descriptionController.text ?? 'N/A')}',
                    style: Constants.AppTypography.body.copyWith(color: Constants.AppColors.ink),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Text(
                    '• ${AppLocalizations.of(context)!.paymentType}: ${translateText(selectedPaymentType ?? 'N/A')}',
                    style: Constants.AppTypography.body.copyWith(color: Constants.AppColors.ink),
                  ),
                ),

                if (selectedPaymentType == "Milestone Basis") ...[
                  // DataTable to show milestones
                  DataTable(
                    columns: [
                      DataColumn(
                          label: Text(AppLocalizations.of(context)!
                              .descriptionColumn)), // Localized description header
                      DataColumn(
                          label: Text(AppLocalizations.of(context)!
                              .amountColumn)), // Localized amount header
                    ],
                    rows: List<DataRow>.generate(
                      milestones.length,
                      (index) {
                        return DataRow(
                          cells: [
                            DataCell(Text(translateText(milestones[index]
                                    ['description'] ??
                                'N/A'))), // Safely handle null description and translate
                            DataCell(Text(translateText(milestones[index]
                                        ['amount']
                                    .toString() ??
                                'N/A'))), // Safely handle null amount and translate
                          ],
                        );
                      },
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
