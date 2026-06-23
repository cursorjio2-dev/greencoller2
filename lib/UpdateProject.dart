import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:greencollar/speech_helper.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:greencollar/Addproject.dart';
import 'package:greencollar/HomeScree.dart';
import 'package:greencollar/l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:greencollar/main.dart'; // Adjust the import as needed
import 'package:http/http.dart' as http;
import 'package:greencollar/constants.dart' as Constants;
import 'package:translator/translator.dart';

class Qualification {
  final int id;
  final String name;
  final String? description;

  // Correct constructor name
  Qualification({
    required this.id,
    required this.name,
    this.description,
  });

  // Corrected fromJson factory
  factory Qualification.fromJson(Map<String, dynamic> json) {
    return Qualification(
      id: json['id'] as int,
      name: json['certificate'] as String,
      description: json['description'] as String?,
    );
  }
}

class QualificationService {
  static const String apiUrl =
      '${Constants.AppConstants.apiUrl}farmer/qualification'; // Adjust based on your actual Constants class

  static Future<List<Qualification>> fetchQualifications() async {
    try {
      final response = await http.post(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          List<dynamic> qualificationData = data['data'];
          return qualificationData
              .map((e) => Qualification.fromJson(e))
              .toList();
        } else {
          throw Exception('API responded with failure: ${data['message']}');
        }
      } else {
        throw Exception(
            'Failed to load qualifications: Status ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load qualifications: $e');
    }
  }
}

class UpdateProject extends StatefulWidget {
  final String projectId;

  UpdateProject({required this.projectId});

  // Constructor to accept the projectType argument

  @override
  _UpdateProjectState createState() => _UpdateProjectState();
}

class _UpdateProjectState extends State<UpdateProject> {
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
  List<Qualification> certifications = [];
  List<String> selectedcertifications = [];
  String? selectedSkill;
  String? selectedLanguage;
  List<Skill> skills = [];
  List<String> selectedSkills = [];
  final List<String> descriptions = [
    'Home Renovation',
    'Commercial Project',
    'Maintenance Work'
  ];
  String? selectedExperience;
  final List<String> experienceOptions = [
    "0 - 1 year",
    "1 - 3 years",
    "3 - 5 years",
    "> 5 years"
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
  String? selectedEstimateDays;

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

    // ✅ Check manual translations first
    if (translations.containsKey(text) &&
        translations[text]!.containsKey(targetLang)) {
      return translations[text]![targetLang]!; // Return manual translation
    }

    // ✅ Check cached translations
    if (_cachedTranslations.containsKey(text) &&
        _cachedTranslations[text]!.containsKey(targetLang)) {
      return _cachedTranslations[text]![
          targetLang]!; // Return cached translation
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
      print(budgetController.text);
      selectedProjectType = projectData['project_type'];
      // Handling required_skills (single skill or comma-separated)
      if (projectData['required_skills'] != null) {
        if (projectData['required_skills'] is String) {
          selectedSkills = projectData['required_skills'].split(',');
        } else {
          selectedSkills = [projectData['required_skills'].toString()];
        }
      }

      if (projectData['qualification'] != null) {
        if (projectData['qualification'] is String) {
          selectedcertifications = projectData['qualification'].split(',');
        } else {
          selectedcertifications = [projectData['qualification'].toString()];
        }
      }

      milestones = projectData['milestones'] is String
          ? List<Map<String, dynamic>>.from(
              jsonDecode(projectData['milestones']))
          : [];

      // Convert to string in case these fields are int
      selectedExperience = projectData['experience']?.toString() ?? '';
      requiredLaboursController.text =
          projectData['qty_labours']?.toString() ?? '';
      setState(() {});
      selectedEstimateDays = projectData['days']?.toString() ?? '';
      print(budgetController.text);

      budgetController.text = projectData['budget']?.toString() ?? '';
      descriptionController.text = projectData['description'] ?? '';
      pinCodeController.text = projectData['pincode']?.toString() ?? '';
      addressController.text = projectData['address'] ?? '';
      applicantstatus = projectData['applicants']?.toString() ?? '';

      // For payment type, compare as integer if needed, or convert
      selectedPaymentType = projectData['payment_type']?.toString() == "0"
          ? "Project Basis"
          : "Milestone Basis";

      // Assign city and state correctly
      String? city = projectData['city'];
      String? state = projectData['state'];

      if (city != null && city.isNotEmpty) {
        selectedCity = city;
        if (!citiesEn.contains(city)) {
          citiesEn.add(city);
        }
        if (!citiesHi.contains(city)) {
          citiesHi.add(city);
        }
      }

      if (state != null && state.isNotEmpty) {
        selectedState = state;
        if (!statesEn.contains(state)) {
          statesEn.add(state);
        }
        if (!statesHi.contains(state)) {
          statesHi.add(state);
        }
      }

      // Update pincode if available (again)
      String? zipCode = projectData['pincode']?.toString();
      if (zipCode != null && zipCode.isNotEmpty) {
        pinCodeController.text = zipCode;
      }

      // Call setState to reflect the changes in the UI
      setState(() {});
    } catch (e) {
      print("Error fetching project details: $e");
    }
  }

  Future<void> _fetchStates() async {
    final language =
        Provider.of<LanguageProvider>(context, listen: false).selectedLanguage;
    final response = await http
        .post(Uri.parse('${Constants.AppConstants.apiUrl}app/states'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      List<dynamic> states = data['data'];

      setState(() {
        selectedCity = null;
        statesEn = [];
        statesHi = [];
        stateCodes = {}; // Reset previous data

        for (var state in states) {
          String stateTitle = state['state_title'];
          int stateId = state['state_id'];

          // Add state to the respective language list
          if (language == 'en') {
            statesEn.add(stateTitle);
          } else {
            // Add Hindi translation logic here if required
            statesHi.add(
                stateTitle); // Assuming statesHi has the Hindi translations
          }

          // Map state title to its state ID
          stateCodes[stateTitle] = stateId;
        }
      });
    } else {
      throw Exception('Failed to load states');
    }
  }

  Future<void> _fetchOtherData(int stateCode) async {
    final language =
        Provider.of<LanguageProvider>(context, listen: false).selectedLanguage;
    // Make the request to fetch cities based on the state code
    final response = await http.post(
      Uri.parse(
          '${Constants.AppConstants.apiUrl}app/cities'), // Use correct API endpoint for cities
      body: {
        'stateid':
            stateCode.toString(), // Passing the state code in the request body
      },
    );
    print(response.statusCode);
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      List<dynamic> cities = data['data'];

      setState(() {
        selectedCity = null;

        citiesEn = [];
        citiesHi = [];

        for (var city in cities) {
          String cityTitle = city['district_title']; // Name of the city

          // Add city to the respective language list
          if (language == 'en') {
            citiesEn.add(cityTitle);
          } else {
            // Add Hindi translation logic if required
            citiesHi
                .add(cityTitle); // Assuming citiesHi has the Hindi translations
          }

          // Map city title to its city ID
        }
      });
    } else {
      throw Exception('Failed to load cities for state code $stateCode');
    }
  }

  Future<void> _fetchLocation() async {
    try {
      // Get the current position with higher accuracy settings (if needed)
      // Assuming you have access to the position (latitude, longitude)
      // Add logic here to fetch position if required

      // Fetch public IP address
      String? userId = await _secureStorage.read(key: 'id');
      if (userId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('User ID not found in secure storage')),
        );
        return;
      }

      // Fetch location from the backend based on IP address
      final response = await http.post(
        Uri.parse('${Constants.AppConstants.apiUrl}farmer/getFarmerLocation'),
        body: {
          'id': userId, // Pass the IP address in the request
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        // Extract the location data
        String? city = data['city'];
        String? state = data['state'];
        String? zipCode = data['zipcode'];

        setState(() {
          // Set the location details in the state
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
          if (zipCode != null && zipCode.isNotEmpty) {
            pinCodeController.text = zipCode;
          }
        });

        // Show location details in debug console
        print('City: $city');
        print('State: $state');
        print('Zip Code: $zipCode');
      } else {
        print('Error fetching location details from API.');
        Fluttertoast.showToast(
          msg: "Error getting location details.",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.red.shade700,
          textColor: Colors.white,
          fontSize: 16.0,
        );
      }
    } catch (e) {
      print('Error fetching location: $e');
      Fluttertoast.showToast(
        msg: "Error getting location. Please try again or enter manually.",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red.shade700,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    }
  }

  void _onStateSelected(String? selectedState) {
    if (selectedState != null && stateCodes.containsKey(selectedState)) {
      int stateCode = stateCodes[selectedState]!;
      _fetchOtherData(
          stateCode); // Call another API function using the state code
    }
  }

  Future<void> _loadSkillsData() async {
    try {
      final fetchedSkills = await SkillService.fetchSkills();
      final fetchQualifications =
          await QualificationService.fetchQualifications();
      setState(() {
        skills = fetchedSkills;
        certifications = fetchQualifications;
      });
    } catch (e) {
      print('Error fetching skills: $e');
    }
  }

  bool iscertVisible = false;
  FocusNode _certfocusNode = FocusNode();

  late Future<List<JobType>> _jobTypes;
  String? _selectedJobType; // Store only the job name (String)
  // Make it nullable to avoid late initialization error
  bool isSkillsVisible =
      false; // Variable to control the visibility of the skill list
  @override
  void initState() {
    super.initState();
    print("zcz");
    _jobTypes = fetchJobTypes();
    _loadSkillsData(); // Fetch skills when the form is initialized

    _fetchStates();

    fetchProjectData(); // Listen for focus changes
    _focusNode.addListener(() {
      setState(() {
        // If focus is lost, hide the skills dropdown
        isSkillsVisible = _focusNode.hasFocus;
      });
    });
    _certfocusNode.addListener(() {
      setState(() {
        // If focus is lost, hide the skills dropdown
        iscertVisible = _certfocusNode.hasFocus;
      });
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _certfocusNode.dispose(); // Don't forget to dispose of the FocusNode
    super.dispose();
  }

  Future<List<JobType>> fetchJobTypes() async {
    try {
      final response = await http
          .post(Uri.parse('${Constants.AppConstants.apiUrl}farmer/jobtype'));
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        List<dynamic> jobData = data['data'];
        return jobData.map((job) => JobType.fromJson(job)).toList();
      } else {
        throw Exception('Failed to load job types');
      }
    } catch (e) {
      throw Exception('Failed to load job types: $e');
    }
  }

  Future<void> submitForm() async {
    final language =
        Provider.of<LanguageProvider>(context, listen: false).selectedLanguage;

    String translate(String enText, String hiText) {
      return language == 'en' ? enText : hiText;
    }

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
        'experience': selectedExperience,
        'qualification': selectedcertifications,
        'payment_type': selectedPaymentType,
        'milestones': milestones,

        'budget': budgetController.text,
        'qty_labours': requiredLaboursController.text,
        'days': selectedEstimateDays,
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
        Fluttertoast.showToast(
          msg: translate('Project Updated Successfully!',
              'प्रोजेक्ट सफलतापूर्वक अपडेट किया गया!'),
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.green.shade700,
          textColor: Colors.white,
          fontSize: 16.0,
        );

        // Wait for 1 second before navigating back
        Future.delayed(Duration(seconds: 1), () {
          Navigator.pop(context, true);
        });
      } else {
        // Handle failure
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(translate('Failed to update project',
                  'प्रोजेक्ट अपडेट करने में विफल'))),
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
        final language = Provider.of<LanguageProvider>(context, listen: false)
            .selectedLanguage;

        String translate(String enText, String hiText) {
          return language == 'en' ? enText : hiText;
        }

        return AlertDialog(
          title: Text(translate('Add Milestone', 'माइलस्टोन जोड़ें')),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: descriptionController,
                decoration: InputDecoration(
                  labelText:
                      translate('Milestone Description', 'माइलस्टोन विवरण'),
                  hintText: translate(
                      'Enter Milestone Description', 'माइलस्टोन विवरण'),
                ),
              ),
              SizedBox(height: 10),
              TextField(
                controller: amountController,
                decoration: InputDecoration(
                    labelText: translate('Milestone Amount',
                        'माइलस्टोन राशि'), // Corrected the Hindi translation here
                    hintText: translate('Enter Milestone Amount',
                        'माइलस्टोन राशि') // Corrected the Hindi translation here
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
              child: Text(AppLocalizations.of(context)!.cancel),
            ),
            TextButton(
              onPressed: () {
                // Add the new milestone if inputs are valid
                if (descriptionController.text.isNotEmpty &&
                    amountController.text.isNotEmpty) {
                  setState(() {
                    int newMilestoneNumber = milestones.length + 1;
                    milestones.add({
                      'sno': newMilestoneNumber,
                      'description': descriptionController.text,
                      'amount': double.tryParse(amountController.text) ?? 0.0,
                    });
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
                  Navigator.pop(context);
                }
              },
              child: Text(AppLocalizations.of(context)!.add),
            ),
          ],
        );
      },
    );
  }

  // Function to show the edit milestone dialog
  void showEditMilestoneDialog(int index) {
    final language =
        Provider.of<LanguageProvider>(context, listen: false).selectedLanguage;

    String translate(String enText, String hiText) {
      return language == 'en' ? enText : hiText;
    }

    final descriptionController =
        TextEditingController(text: milestones[index]['description']);
    final amountController =
        TextEditingController(text: milestones[index]['amount'].toString());

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(translate('Edit Milestone', 'माइलस्टोन संपादित करें')),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: descriptionController,
                decoration: InputDecoration(
                    labelText: translate('Milestone Amount',
                        'माइलस्टोन राशि'), // Corrected the Hindi translation here
                    hintText: translate('Enter Milestone Amount',
                        'माइलस्टोन राशि') // Corrected the Hindi translation here
                    ),
              ),
              SizedBox(height: 10),
              TextField(
                controller: amountController,
                decoration: InputDecoration(
                    labelText: translate('Milestone Amount',
                        'माइलस्टोन राशि'), // Corrected the Hindi translation here
                    hintText: translate('Enter Milestone Amount',
                        'माइलस्टोन राशि') // Corrected the Hindi translation here
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
              child: Text(AppLocalizations.of(context)!.cancel),
            ),
            TextButton(
              onPressed: () {
                // Update the milestone if inputs are valid
                if (descriptionController.text.isNotEmpty &&
                    amountController.text.isNotEmpty) {
                  setState(() {
                    milestones[index] = {
                      'sno': milestones[index]
                          ['sno'], // Keep the same serial number

                      'description': descriptionController.text,
                      'amount': double.tryParse(amountController.text) ?? 0.0,
                    };
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
                  Navigator.pop(context);
                }
              },
              child: Text(AppLocalizations.of(context)!.save),
            ),
          ],
        );
      },
    );
  }

  // Function to delete a milestone
  void deleteMilestone(int index) {
    setState(() {
      milestones.removeAt(index);
    });
  }

  InputDecoration _buildInputDecoration(String labelText, {Widget? suffixIcon, TextEditingController? controller, String? hintText}) {
    return InputDecoration(
      labelText: labelText,
      hintText: hintText,
      hintStyle: Constants.AppTypography.body.copyWith(color: Constants.AppColors.inkSoft.withOpacity(0.5)),
      labelStyle: Constants.AppTypography.body.copyWith(color: Constants.AppColors.inkSoft),
      fillColor: Constants.AppColors.card,
      filled: true,
      suffixIcon: suffixIcon ?? (controller != null ? MicIconButton(controller: controller) : null),
      contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(Constants.AppRadii.sm),
        borderSide: const BorderSide(
          color: Constants.AppColors.border,
          width: 1.0,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(Constants.AppRadii.sm),
        borderSide: const BorderSide(
          color: Constants.AppColors.border,
          width: 1.0,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(Constants.AppRadii.sm),
        borderSide: const BorderSide(
          color: Constants.AppColors.brand,
          width: 1.5,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(Constants.AppRadii.sm),
        borderSide: const BorderSide(
          color: Colors.red,
          width: 1.0,
        ),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(Constants.AppRadii.sm),
        borderSide: const BorderSide(
          color: Colors.red,
          width: 1.5,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final language =
        Provider.of<LanguageProvider>(context, listen: false).selectedLanguage;

    String translate(String enText, String hiText) {
      return language == 'en' ? enText : hiText;
    }

    return Scaffold(
      backgroundColor: Constants.AppColors.surface,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Constants.AppColors.brand,
        title: Text(
          AppLocalizations.of(context)!.projectDetails,
          style: Constants.AppTypography.h3.copyWith(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FutureBuilder<List<JobType>>(
                    future: _jobTypes, // Use the initialized future here
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        return Center(child: Text(''));
                      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return const Center(child: Text('No data available'));
                      } else {
                        List<JobType> jobTypes = snapshot.data!;

                        // Initialize _selectedJobType with the first job as default
                        if (_selectedJobType == null && jobTypes.isNotEmpty) {
                          _selectedJobType = jobTypes[0]
                              .jobname; // Set the first jobname as default
                        }

                        return DropdownButtonFormField<String>(
                          value: _selectedJobType,
                          decoration: _buildInputDecoration(AppLocalizations.of(context)!.jobtype),
                          items: jobTypes.map((JobType job) {
                            return DropdownMenuItem<String>(
                              value: job.jobname,
                              child: Text(translateText(job.jobname)),
                            );
                          }).toList(),
                          onChanged: (String? newJobType) {
                            setState(() {
                              _selectedJobType = newJobType;
                            });
                          },
                        );
                      }
                    },
                  ),
                  const SizedBox(height: 16),

                  TextFormField(
                    controller: titleController,
                    decoration: _buildInputDecoration(AppLocalizations.of(context)!.workTitle, controller: titleController, hintText: translate('Enter project/work title', 'प्रोजेक्ट/कार्य शीर्षक दर्ज करें')),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return translate('Please enter a project title.',
                            'कृपया प्रोजेक्ट का नाम दर्ज करें।');
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Project Type Dropdown
                  DropdownButtonFormField<String>(
                    decoration: _buildInputDecoration(AppLocalizations.of(context)!.projectType),
                    value: selectedProjectType,
                    items: [
                      DropdownMenuItem(
                        value: 'Daily wages',
                        child: Text(translate('Daily Wages', 'दैनिक मजदूरी')),
                      ),
                      DropdownMenuItem(
                        value: 'Contract',
                        child: Text(translate('Contract', 'अनुबंध')),
                      ),
                    ],
                    onChanged: (value) {
                      setState(() {
                        selectedProjectType = value;
                      });
                    },
                    validator: (value) {
                      if (value == null) {
                        return translate('Please select a project type.',
                            'कृपया प्रोजेक्ट प्रकार चुनें।');
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  TextFormField(
                    controller: requiredLaboursController,
                    keyboardType: TextInputType.number,
                    decoration: _buildInputDecoration(translate('Number of Required Labours', 'आवश्यक श्रमिकों की संख्या'), controller: requiredLaboursController, hintText: translate('Enter number of workers needed', 'आवश्यक श्रमिकों की संख्या दर्ज करें')),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return translate(
                            'Please enter the number of required labours.',
                            'कृपया आवश्यक श्रमिकों की संख्या दर्ज करें।');
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 16),
                  // Estimated Days

                  DropdownButtonFormField<String>(
                    value: selectedEstimateDays,
                    onChanged: (newValue) {
                      setState(() {
                        selectedEstimateDays = newValue;
                      });
                    },
                    decoration: _buildInputDecoration(translate('Estimated Days', 'अनुमानित दिन')),
                    items: [
                      DropdownMenuItem<String>(
                        value: '1 day',
                        child: Text(translate('1 day', '1 दिन')),
                      ),
                      DropdownMenuItem<String>(
                        value: '2 days',
                        child: Text(translate('2 days', '2 दिन')),
                      ),
                      DropdownMenuItem<String>(
                        value: '3-7 days',
                        child: Text(translate('3-7 days', '3-7 दिन')),
                      ),
                      DropdownMenuItem<String>(
                        value: '8-15 days',
                        child: Text(translate('8-15 days', '8-15 दिन')),
                      ),
                      DropdownMenuItem<String>(
                        value: '15-1 month',
                        child: Text(translate('15-1 month', '15-1 महीना')),
                      ),
                      DropdownMenuItem<String>(
                        value: '1-3 months',
                        child: Text(translate('1-3 months', '1-3 महीने')),
                      ),
                      DropdownMenuItem<String>(
                        value: '3-6 months',
                        child: Text(translate('3-6 months', '3-6 महीने')),
                      ),
                      DropdownMenuItem<String>(
                        value: '6 months-1 year',
                        child: Text(translate('6 months-1 year', '6 महीने-1 साल')),
                      ),
                      DropdownMenuItem<String>(
                        value: '>1 year',
                        child: Text(translate('>1 year', '> 1 साल')),
                      ),
                    ],
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return translate('Please enter the estimated days.',
                            'कृपया अनुमानित दिन दर्ज करें।');
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    decoration: _buildInputDecoration(
                      translate('Enter Required skills', 'अपना कौशल दर्ज करें'),
                      suffixIcon: Icon(Icons.arrow_drop_down, color: Constants.AppColors.brand),
                      hintText: translate('Tap to select required skills', 'आवश्यक कौशल चुनने के लिए टैप करें'),
                    ),
                    readOnly: true,
                    onTap: () {
                      setState(() {
                        isSkillsVisible = !isSkillsVisible;
                      });
                    },
                  ),
                  if (isSkillsVisible)
                    Container(
                      margin: const EdgeInsets.only(top: 4),
                      decoration: BoxDecoration(
                        color: Constants.AppColors.card,
                        borderRadius: BorderRadius.circular(Constants.AppRadii.sm),
                        border: Border.all(color: Constants.AppColors.border),
                      ),
                      child: Column(
                        children: skills.map((skill) {
                          return CheckboxListTile(
                            activeColor: Constants.AppColors.brand,
                            title: Text(translateText(skill.name), style: Constants.AppTypography.body),
                            value: selectedSkills.contains(skill.name),
                            onChanged: (bool? selected) {
                              setState(() {
                                if (selected != null && selected) {
                                  selectedSkills.add(skill.name);
                                } else {
                                  selectedSkills.remove(skill.name);
                                }
                                isSkillsVisible = false;
                              });
                            },
                          );
                        }).toList(),
                      ),
                    ),
                  const SizedBox(height: 16),

                  if (selectedSkills.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Text(
                        AppLocalizations.of(context)!.requiredSkills,
                        style: Constants.AppTypography.label.copyWith(color: Constants.AppColors.inkSoft),
                      ),
                    ),

                  if (selectedSkills.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: selectedSkills.map((skill) {
                          return Container(
                            decoration: BoxDecoration(
                              color: Constants.AppColors.brandTint,
                              borderRadius: BorderRadius.circular(Constants.AppRadii.sm),
                              border: Border.all(color: Constants.AppColors.brand.withOpacity(0.2)),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
                            child: Text(
                              translateText(skill),
                              style: Constants.AppTypography.body.copyWith(color: Constants.AppColors.brandDeep),
                            ),
                          );
                        }).toList(),
                      ),
                    ),

                  TextFormField(
                    decoration: _buildInputDecoration(
                      translate('Enter Required Qualification', 'आवश्यक योग्यता दर्ज करें'),
                      suffixIcon: Icon(Icons.arrow_drop_down, color: Constants.AppColors.brand),
                      hintText: translate('Tap to select qualifications', 'योग्यता चुनने के लिए टैप करें'),
                    ),
                    readOnly: true,
                    onTap: () {
                      setState(() {
                        iscertVisible = !iscertVisible;
                      });
                    },
                  ),

                  if (iscertVisible)
                    Container(
                      margin: const EdgeInsets.only(top: 4),
                      decoration: BoxDecoration(
                        color: Constants.AppColors.card,
                        borderRadius: BorderRadius.circular(Constants.AppRadii.sm),
                        border: Border.all(color: Constants.AppColors.border),
                      ),
                      child: Column(
                        children: certifications.map((qualification) {
                          return CheckboxListTile(
                            activeColor: Constants.AppColors.brand,
                            title: Text(translateText(qualification.name), style: Constants.AppTypography.body),
                            value: selectedcertifications.contains(qualification.name),
                            onChanged: (bool? selected) {
                              setState(() {
                                if (selected != null && selected) {
                                  selectedcertifications.add(qualification.name);
                                } else {
                                  selectedcertifications.remove(qualification.name);
                                }
                                iscertVisible = false;
                              });
                            },
                          );
                        }).toList(),
                      ),
                    ),

                  const SizedBox(height: 16),

                  if (selectedcertifications.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: selectedcertifications.map((qualification) {
                          return Container(
                            decoration: BoxDecoration(
                              color: Constants.AppColors.brandTint,
                              borderRadius: BorderRadius.circular(Constants.AppRadii.sm),
                              border: Border.all(color: Constants.AppColors.brand.withOpacity(0.2)),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
                            child: Text(
                              translateText(qualification),
                              style: Constants.AppTypography.body.copyWith(color: Constants.AppColors.brandDeep),
                            ),
                          );
                        }).toList(),
                      ),
                    ),

                  DropdownButtonFormField<String>(
                    value: selectedExperience,
                    decoration: _buildInputDecoration(translate('Enter Required Experience', 'आवश्यक अनुभव दर्ज करें')),
                    items: experienceOptions.map((experience) {
                      return DropdownMenuItem<String>(
                        value: experience,
                        child: Text(experience),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedExperience = value;
                      });
                    },
                    validator: (value) => value == null
                        ? AppLocalizations.of(context)!.selectExperienceError
                        : null,
                  ),

                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: selectedCity,
                    decoration: _buildInputDecoration(AppLocalizations.of(context)!.city),
                    items: citiesEn
                        .map((city) => DropdownMenuItem<String>(
                              value: city,
                              child: Text(translateText(city)),
                            ))
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedCity = value!;
                      });
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return AppLocalizations.of(context)!.cityEmpty;
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 16),

                  // State Dropdown
                  DropdownButtonFormField<String>(
                    value: selectedState,
                    decoration: _buildInputDecoration(AppLocalizations.of(context)!.state),
                    items: statesEn
                        .map((state) => DropdownMenuItem<String>(
                              value: state,
                              child: Text(translateText(state)),
                            ))
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedState = value!;
                      });
                      _onStateSelected(value);
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return AppLocalizations.of(context)!.stateEmpty;
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  TextFormField(
                    controller: pinCodeController,
                    keyboardType: TextInputType.number,
                    decoration: _buildInputDecoration(language == 'en' ? 'Pin Code' : 'पिन कोड', controller: pinCodeController, hintText: translate('Enter 6-digit pin code', '6 अंकों का पिन कोड दर्ज करें')),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return language == 'en'
                            ? 'Please enter your pin code'
                            : 'कृपया अपना पिन कोड दर्ज करें';
                      } else if (value.length != 6 ||
                          int.tryParse(value) == null) {
                        return language == 'en'
                            ? 'Please enter a valid 6-digit pin code'
                            : 'कृपया एक मान्य 6-अंकीय पिन कोड दर्ज करें';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Address
                  TextFormField(
                    controller: addressController,
                    decoration: _buildInputDecoration(translate('Enter Location', 'स्थान दर्ज करें'), controller: addressController, hintText: translate('Enter project location', 'प्रोजेक्ट का स्थान दर्ज करें')),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return translate(
                            'Please enter an address.', 'कृपया पता दर्ज करें।');
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: descriptionController,
                    decoration: _buildInputDecoration(translate('Description about Project', 'प्रोजेक्ट के बारे में विवरण'), controller: descriptionController, hintText: translate('Describe the project details', 'प्रोजेक्ट का विवरण लिखें')),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 16),

                  DropdownButtonFormField<String>(
                    decoration: _buildInputDecoration(translate('Payment Type', 'प्रोजेक्ट प्रकार')),
                    value: selectedPaymentType,
                    items: [
                      DropdownMenuItem(
                        value: 'Project Basis',
                        child: Text(
                            translate('Project Basis', 'प्रोजेक्ट बेसिस ')),
                      ),
                      DropdownMenuItem(
                        value: 'Milestone Basis',
                        child: Text(
                            translate('Milestone Basis', 'माइलस्टोन बेसिस ')),
                      ),
                    ],
                    onChanged: (value) {
                      setState(() {
                        selectedPaymentType = value;
                      });
                    },
                    validator: (value) {
                      if (value == null) {
                        return translate('Please select a payment type.',
                            'कृपया प्रोजेक्ट प्रकार चुनें।');
                      }
                      return null;
                    },
                  ),
                  if (selectedPaymentType == "Milestone Basis") ...[
                    // Add button for Milestones
                    IconButton(
                      icon: Icon(Icons.add, color: Constants.AppColors.brand),
                      onPressed: showAddMilestoneDialog,
                    ),
                    // DataTable to show milestones
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        columns: [
                          DataColumn(
                              label: Text(AppLocalizations.of(context)!
                                  .descriptionColumn, style: Constants.AppTypography.label)),
                          DataColumn(
                              label: Text(
                                  AppLocalizations.of(context)!.amountColumn, style: Constants.AppTypography.label)),
                          DataColumn(
                              label: Text(AppLocalizations.of(context)!.actions, style: Constants.AppTypography.label)),
                        ],
                        rows: List<DataRow>.generate(
                          milestones.length,
                          (index) {
                            return DataRow(
                              cells: [
                                DataCell(Text(translateText(
                                    milestones[index]['description']), style: Constants.AppTypography.body)),
                                DataCell(Text(translateText(
                                    milestones[index]['amount'].toString()), style: Constants.AppTypography.body)),
                                DataCell(Row(
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.edit, color: Colors.blue),
                                      onPressed: () =>
                                          showEditMilestoneDialog(index),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete, color: Colors.red),
                                      onPressed: () => deleteMilestone(index),
                                    ),
                                  ],
                                )),
                              ],
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                  // Conditional Fields for Daily Wages

                  // Number of Required Labours
                  TextFormField(
                    controller: budgetController,
                    keyboardType: TextInputType.number,
                    decoration: _buildInputDecoration(AppLocalizations.of(context)!.budget, controller: budgetController, hintText: translate('Enter budget amount', 'बजट राशि दर्ज करें')),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return translate(
                            'Please enter the Budget.', 'कृपया बजट दर्ज करें।');
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        height: 48,
                        width: 200,
                        decoration: BoxDecoration(
                          gradient: Constants.AppColors.brandGradient,
                          borderRadius: BorderRadius.circular(Constants.AppRadii.sm),
                          boxShadow: const [Constants.AppShadows.soft],
                        ),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(Constants.AppRadii.sm),
                            ),
                          ),
                          onPressed: () async {
                            if (_formKey.currentState!.validate()) {
                              await submitForm();
                            }
                          },
                          child: Text(
                            translate('Update', 'अपडेट'),
                            style: Constants.AppTypography.subhead.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
