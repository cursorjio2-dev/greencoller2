import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:greencollar/speech_helper.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:greencollar/Addproject.dart';
import 'package:greencollar/HomeScree.dart';
import 'package:greencollar/l10n/app_localizations.dart';
import 'package:greencollar/labourhomepage.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart'; // Import image_picker
import 'package:translator/translator.dart';
import 'dart:io'; // For File handling
import 'main.dart'; // Import the LanguageProvider class
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:http/http.dart' as http;
import 'package:fluttertoast/fluttertoast.dart';
import 'package:greencollar/constants.dart';
import 'package:greencollar/constants.dart' as Constants;

class UpdateLabourProfile extends StatefulWidget {
  const UpdateLabourProfile({super.key});

  @override
  _UpdateLabourProfileState createState() => _UpdateLabourProfileState();
}

class _UpdateLabourProfileState extends State<UpdateLabourProfile> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController ageController = TextEditingController();
  final TextEditingController numberController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController repasswordController = TextEditingController();

  final TextEditingController pinCodeController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController dailywageController = TextEditingController();
  final TextEditingController aboutmeController = TextEditingController();

  final TextEditingController agencyNameController = TextEditingController();
  final TextEditingController regnoController = TextEditingController();
  FocusNode _focusNode = FocusNode();
  FocusNode _certfocusNode = FocusNode();
  final TextEditingController numberOfEmployeesController =
      TextEditingController();
  final TextEditingController yearofestb = TextEditingController();
  bool _isPasswordVisible = false; // For toggling password visibility
  File? _profileImage; // To hold the selected image

  String selectedGender = 'Male'; // Default selected value
  final TextEditingController emailController = TextEditingController();
  final TextEditingController govtIdController = TextEditingController();
  String pfpurl = "";
  final ImagePicker _picker = ImagePicker();
  List<String> citiesEn = [];
  List<String> citiesHi = [];
  String? selectedCity;
  String? selectedState;
  List<String> statesEn = [];
  List<String> statesHi = [];
  Map<String, int> stateCodes =
      {}; // To store state titles with their respective IDs
  List<String> gender =
      []; // Method to pick an image from the gallery or camera
  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
      });
    }
  }

  final _secureStorage = const FlutterSecureStorage();

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

  String? UserTypeWag;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      setState(() {
        gender = ['Male', 'Female', 'Other'];
      });
      _loadSkillsData();
      await _fetchStates();
      await fetchLabourDetails();
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
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _certfocusNode.dispose();
    nameController.dispose();
    _speech.stop(); // Don't forget to dispose of the FocusNode
    super.dispose();
  }

  void _onStateSelected(String? selectedState) {
    if (selectedState != null && stateCodes.containsKey(selectedState)) {
      int stateCode = stateCodes[selectedState]!;
      _fetchOtherData(
          stateCode); // Call another API function using the state code
    }
  }

  List<Qualification> certifications = [];
  List<String> selectedcertifications = [];
  String? selectedEducation;
  String? selectedExperience = "8 th";

  final List<String> experienceOptions = [
    "Illiterate",
    "8 th",
    "10 th",
    "12 th",
    "Graduate",
    "Post Graduate",
  ];
  Future<void> fetchLabourDetails() async {
    setState(() {});

    // Read user type and user ID from secure storage
    String? userType = await _secureStorage.read(key: 'userType');
    String? userId = await _secureStorage.read(key: 'id');

    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('User ID not found in secure storage')),
      );
      return;
    }

    // Determine the API URL based on user type
    String apiUrl = '';
    if (userType == 'farmer') {
      // API URL for farmer
      apiUrl = '${Constants.AppConstants.apiUrl}farmer/details';
    } else {
      // API URL for labour
      apiUrl = '${Constants.AppConstants.apiUrl}labour/labourdetails';
    }
    print(userType);
    try {
      // Make the POST request to the API
      final response = await http.post(
        Uri.parse(apiUrl), // Proper URI parsing here
        headers: {'Content-Type': 'application/json'},
        body: json
            .encode({'id': userId}), // Pass the ID as part of the request body
      );

      if (response.statusCode == 200) {
        print(response.statusCode);
        print(json.decode(response.body));
        final responseData = json.decode(response.body);
        if (responseData['success'] == true) {
          // Extract the data and update the respective fields
          String name = responseData['data']['name'] ?? 'No Name';
          var profile = responseData['data']['profile'];
          if (userType != "farmer") {
            pfpurl = (profile != null &&
                    profile != "null" &&
                    profile.isNotEmpty)
                ? '${Constants.AppConstants.folderUrl}storage/upload/labourprofile/$profile'
                : '';
          } else {
            pfpurl = (profile != null &&
                    profile != "null" &&
                    profile.isNotEmpty)
                ? '${Constants.AppConstants.folderUrl}storage/upload/farmerprofile/$profile'
                : '';
          }
// Ensure profile is not null before using it

          print("Profile URL: $pfpurl");

          nameController.text = name;
          ageController.text = responseData['data']['age']?.toString() ?? '10';
          emailController.text = responseData['data']['email'] ?? '';
          govtIdController.text = responseData['data']['aadharno'] ?? '';
          dailywageController.text = responseData['data']['daily_wage'] ?? '';
          aboutmeController.text = responseData['data']['aboutme'] ?? '';

          numberController.text = responseData['data']['phone'] ?? '';
          pinCodeController.text = responseData['data']['pincode'] ?? '';
          addressController.text = responseData['data']['address'] ?? '';
          // Handle city and state
          if (responseData['data']['city'] != null) {
            if (!citiesEn.contains(responseData['data']['city'])) {
              citiesEn.add(responseData['data']['city']);
            }
            selectedCity = responseData['data']['city'];
          }

          if (responseData['data']['state'] != "null") {
            if (!statesEn.contains(responseData['data']['state'])) {
              statesEn.add(responseData['data']['state']);
            }
            selectedState = responseData['data']['state'];
          }

          if (responseData['data']['skills'] != null && responseData['data']['skills'] != "null" && responseData['data']['skills'].toString().isNotEmpty) {
            selectedSkills = responseData['data']['skills'].toString()
                .split(',').map((s) => s.trim()).where((s) => s.isNotEmpty).toList();
          }
          if (responseData['data']['certifications'] != null && responseData['data']['certifications'] != "null" && responseData['data']['certifications'].toString().isNotEmpty) {
            selectedcertifications = responseData['data']['certifications'].toString()
                .split(',').map((s) => s.trim()).where((s) => s.isNotEmpty).toList();
          }
          print(responseData['data']['education']);
          selectedExperience = (responseData['data']['education'] != null &&
                  responseData['data']['education'] != "null" &&
                  responseData['data']['education'].isNotEmpty)
              ? responseData['data']['education']
              : '8 th';

          print(selectedExperience);
          pinCodeController.text = responseData['data']['pincode'] ?? '';
          addressController.text = responseData['data']['address'] ?? '';
        } else {
          // If the response is unsuccessful, show an error message
        }
      } else {
        // If the server returns an error, show an error message
      }
    } catch (e) {
      // Handle any exceptions that occur during the request
    } finally {
      setState(() {});
    }
  }

  Future<void> _fetchStates() async {
    final language =
        Provider.of<LanguageProvider>(context, listen: false).selectedLanguage;
    final response = await http
        .post(Uri.parse('${Constants.AppConstants.apiUrl}app/states'));

    if (response.statusCode == 200) {
      print("Fdfsdfdfsdfsd");
      print(language);
      final data = json.decode(response.body);
      List<dynamic> states = data['data'];

      setState(() {
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
            statesEn.add(
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

  // This function will be triggered when a state is selected.

  // Another API call using the state code (can be used for further processing)
  Future<void> _fetchOtherData(int stateCode) async {
    print(stateCode);
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
            citiesEn
                .add(cityTitle); // Assuming citiesHi has the Hindi translations
          }

          // Map city title to its city ID
        }
      });
    } else {
      throw Exception('Failed to load cities for state code $stateCode');
    }
  }

  stt.SpeechToText _speech = stt.SpeechToText();
  bool _isListening = false;

  void _toggleListening() async {
    // Use `Provider.of` with `listen: false` to avoid rebuilding the widget tree
    final language =
        Provider.of<LanguageProvider>(context, listen: false).selectedLanguage;

    if (_isListening) {
      await _speech.stop();
      setState(() {
        _isListening = false;
      });
    } else {
      bool available = await _speech.initialize();
      if (available) {
        setState(() {
          _isListening = true;
        });

        // Set the localeId based on the selected language
        String localeId = language == 'en'
            ? 'en_US'
            : 'hi_IN'; // 'en' for English, 'hi' for Hindi

        _speech.listen(
          localeId: localeId, // Set the appropriate language locale
          onResult: (result) {
            setState(() {
              _isListening = false; // Stop listening after result

              nameController.text = result
                  .recognizedWords; // Update the text field with recognized words
            });
          },
        );
      } else {
        print("Speech recognition is not available");
      }
    }
  }

  bool isSkillsVisible = false;
  bool iscertVisible = false;
  Future<void> _fetchLocation() async {
    try {
      // Get the current position with higher accuracy settings (if needed)
      // Assuming you have access to the position (latitude, longitude)
      // Add logic here to fetch position if required

      // Fetch public IP address
      String ipAddress = await _getIpAddress();
      print('IP Address: $ipAddress');

      if (ipAddress.isNotEmpty) {
        // Fetch location from the backend based on IP address
        final response = await http.post(
          Uri.parse('${Constants.AppConstants.apiUrl}user/iplocation'),
          body: {
            'ipadd': ipAddress, // Pass the IP address in the request
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
        }
      }
    } catch (e) {
      print('Error fetching location: $e');
    }
  }

  Future<String> _getIpAddress() async {
    try {
      final response =
          await http.get(Uri.parse('https://api.ipify.org?format=json'));
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return data['ip'] ?? 'Unable to fetch IP';
      } else {
        return 'Unable to fetch IP';
      }
    } catch (e) {
      print('Error fetching IP address: $e');
      return 'Unable to fetch IP';
    }
  }

  String? selectedAgencyType;
  String? selectedMembers;

  final List<String> agencyTypes = [
    "FPO",
    "NGO",
    "Govt. Agency",
    "Contractor",
    "Society",
    "Other",
  ];
  List<Skill> skills = [];
  List<String> selectedSkills = [];
  final List<String> membersOptions = [
    "0-5",
    "5-20",
    "20-50",
    "50-100",
    ">100",
  ];
  Future<void> _loadSkillsData() async {
    String? UserTypeWags = await _secureStorage.read(key: 'userType');
    try {
      final fetchedSkills = await SkillService.fetchSkills();
      final fetchQualifications =
          await QualificationService.fetchQualifications();
      print(fetchQualifications);
      setState(() {
        UserTypeWag = UserTypeWags;
        skills = fetchedSkills;
        certifications = fetchQualifications;
      });
    } catch (e) {
      print('Error fetching skills: $e');
    }
  }

  Future<void> _submitForm() async {
    final language =
        Provider.of<LanguageProvider>(context, listen: false).selectedLanguage;

    if (_formKey.currentState?.validate() ?? false) {
      _formKey.currentState?.save();

      String? userType = await _secureStorage.read(key: 'userType');
      String? userId = await _secureStorage.read(key: 'id');

      if (userId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(translate('User ID not found in secure storage',
                  'सुरक्षित भंडारण में उपयोगकर्ता आईडी नहीं मिली'))),
        );
        return;
      }

      // Determine the appropriate API URL
      String apiUrl = userType == 'farmer'
          ? '${Constants.AppConstants.apiUrl}farmer/farmerprofileupdate'
          : '${Constants.AppConstants.apiUrl}labour/labourprofileupdate';

      try {
        var request = http.MultipartRequest('POST', Uri.parse(apiUrl));

        // Add text fields
        request.fields['id'] = userId;
        request.fields['name'] = nameController.text;
        request.fields['aboutme'] = aboutmeController.text;
        request.fields['daily_wage'] = dailywageController.text;

        request.fields['age'] = ageController.text;
        request.fields['phone'] = numberController.text;
        request.fields['pincode'] = pinCodeController.text;
        request.fields['address'] = addressController.text;
        request.fields['email'] = emailController.text;
        request.fields['aadhar'] = govtIdController.text;
        request.fields['city'] = selectedCity ?? '';
        request.fields['state'] = selectedState ?? '';
        request.fields['education'] = selectedExperience ?? '';

        // Add 'qualification' and 'skills' only if they are not empty
        if (selectedcertifications.isNotEmpty) {
          request.fields['qualification'] = selectedcertifications.join(', ');
        }

        if (selectedSkills.isNotEmpty) {
          request.fields['skills'] = selectedSkills.join(', ');
        }

        print('Request Body: ${jsonEncode({
              'id': userId,
              'name': nameController.text,
              'daily_wage': dailywageController.text,
              'aboutme': aboutmeController.text,
              'age': ageController.text,
              'phone': numberController.text,
              'pincode': pinCodeController.text,
              'address': addressController.text,
              'email': emailController.text,
              'aadhar': govtIdController.text,
              'city': selectedCity ?? '',
              'state': selectedState ?? '',
              'education': selectedExperience ?? '',
              'qualification': selectedcertifications?.join(', ') ?? '',
              'skills': selectedSkills?.join(', ') ?? ''
            })}');

        // Add image file if available
        if (_profileImage != null) {
          var imageStream = http.ByteStream(_profileImage!.openRead());
          var length = await _profileImage!.length();

          var multipartFile = http.MultipartFile(
            'profile_picture',
            imageStream,
            length,
            filename: _profileImage!.path.split('/').last,
          );

          request.files.add(multipartFile);
        }

        var response = await request.send();
        print(response);

        if (response.statusCode == 200) {
          var responseData = jsonDecode(await response.stream.bytesToString());

          Fluttertoast.showToast(
            msg: translate(
                responseData['message'] ?? 'Profile updated successfully',
                'प्रोफ़ाइल सफलतापूर्वक अपडेट की गई'),
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            backgroundColor: Constants.AppColors.brand,
            textColor: Constants.AppColors.card,
            fontSize: 16.0,
          );

          if (userType != 'farmer') {
            // Navigate to the LabourHomepage (or login page) if the userType is not 'farmer'
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    Labourhomepage(), // Replace with your login page or another page
              ),
            );
            return; // Exit the function early to prevent further execution
          } else {
            // If userType is 'farmer', proceed to HomePage
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => HomePage(),
              ),
            );
          }
        } else {
          Fluttertoast.showToast(
            msg: translate("Updation Failed", "अपडेट करने में विफल"),
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            backgroundColor: AppColors.button,
            textColor: Constants.AppColors.card,
            fontSize: 16.0,
          );
        }
      } catch (e) {
        print('Error: $e');
      }
    }
  }

  String translate(String enText, String hiText) {
    // Get the selected language from the provider
    final language =
        Provider.of<LanguageProvider>(context, listen: false).selectedLanguage;

    // Return the appropriate text based on the selected language
    return language == 'en' ? enText : hiText;
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
        backgroundColor: Constants.AppColors.brand,
        elevation: 0,
        title: Text(
          translate("Profile Details", "प्रोफ़ाइल विवरण"),
          style: Constants.AppTypography.h3.copyWith(color: Constants.AppColors.card),
        ),
        iconTheme: const IconThemeData(color: Constants.AppColors.card),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: Constants.AppColors.brandGradient,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: _pickImage,
                      child: CircleAvatar(
                        radius: 50,
                        backgroundColor: Constants.AppColors.surface2,
                        // Only load image if pfpurl is not empty or the profile image is available locally
                        backgroundImage: _profileImage != null
                            ? FileImage(
                                _profileImage!) // If local image is selected
                            : (pfpurl.isNotEmpty
                                ? NetworkImage(
                                    pfpurl) // Load profile picture from URL if available
                                : null), // Don't display image if pfpurl is empty
                        child: (_profileImage == null &&
                                pfpurl
                                    .isEmpty) // Hide icon if image is not available
                            ? const Icon(Icons.camera_alt,
                                size: 40,
                                color: Constants.AppColors
                                    .inkSoft) // Show camera icon if no image
                            : null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: nameController,
                  style: Constants.AppTypography.body.copyWith(color: Constants.AppColors.ink),
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(context)!.name,
                    hintText: translate('Enter your full name', 'अपना पूरा नाम दर्ज करें'),
                    hintStyle: Constants.AppTypography.body.copyWith(color: Constants.AppColors.inkSoft.withOpacity(0.5)),
                    labelStyle: Constants.AppTypography.body.copyWith(color: Constants.AppColors.inkSoft),
                    fillColor: Constants.AppColors.card,
                    filled: true,
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
                        color: AppColors.button,
                        width: 1.5,
                      ),
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(Constants.AppRadii.sm),
                      borderSide: const BorderSide(
                        color: AppColors.button,
                        width: 1.5,
                      ),
                    ),
                    contentPadding:
                        const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                    suffixIcon: MicIconButton(controller: nameController),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return AppLocalizations.of(context)!.nameValidation;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Address Field
                TextFormField(
                  controller: aboutmeController,
                  keyboardType: TextInputType.text,
                  style: Constants.AppTypography.body.copyWith(color: Constants.AppColors.ink),
                  decoration: InputDecoration(
                    labelText: translate("About You", "आपके बारे में"),
                    hintText: translate('Tell us about yourself', 'अपने बारे में बताएं'),
                    hintStyle: Constants.AppTypography.body.copyWith(color: Constants.AppColors.inkSoft.withOpacity(0.5)),
                    labelStyle: Constants.AppTypography.body.copyWith(color: Constants.AppColors.inkSoft),
                    fillColor: Constants.AppColors.card,
                    filled: true,
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
                        color: AppColors.button,
                        width: 1.5,
                      ),
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(Constants.AppRadii.sm),
                      borderSide: const BorderSide(
                        color: AppColors.button,
                        width: 1.5,
                      ),
                    ),
                    contentPadding:
                        const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                    suffixIcon: MicIconButton(controller: aboutmeController),
                  ),
                ),

                const SizedBox(height: 16),
                if (UserTypeWag != "farmer") ...[
                  TextFormField(
                    controller: dailywageController,
                    keyboardType: TextInputType.number,
                    style: Constants.AppTypography.body.copyWith(color: Constants.AppColors.ink),
                    decoration: InputDecoration(
                      labelText: translate(
                          "Daily Wages In Rs", "दैनिक वेतन रुपये में"),
                      hintText: translate('Enter daily wage amount', 'दैनिक वेतन राशि दर्ज करें'),
                      hintStyle: Constants.AppTypography.body.copyWith(color: Constants.AppColors.inkSoft.withOpacity(0.5)),
                      labelStyle: Constants.AppTypography.body.copyWith(color: Constants.AppColors.inkSoft),
                      fillColor: Constants.AppColors.card,
                      filled: true,
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
                          color: AppColors.button,
                          width: 1.5,
                        ),
                      ),
                      focusedErrorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(Constants.AppRadii.sm),
                        borderSide: const BorderSide(
                          color: AppColors.button,
                          width: 1.5,
                        ),
                      ),
                      contentPadding:
                          const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                TextFormField(
                  controller: ageController,
                  keyboardType: TextInputType.number,
                  style: Constants.AppTypography.body.copyWith(color: Constants.AppColors.ink),
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(context)!.age,
                    hintText: translate('Enter your age', 'अपनी उम्र दर्ज करें'),
                    hintStyle: Constants.AppTypography.body.copyWith(color: Constants.AppColors.inkSoft.withOpacity(0.5)),
                    labelStyle: Constants.AppTypography.body.copyWith(color: Constants.AppColors.inkSoft),
                    fillColor: Constants.AppColors.card,
                    filled: true,
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
                        color: AppColors.button,
                        width: 1.5,
                      ),
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(Constants.AppRadii.sm),
                      borderSide: const BorderSide(
                        color: AppColors.button,
                        width: 1.5,
                      ),
                    ),
                    contentPadding:
                        const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return AppLocalizations.of(context)!.emptyAgeError;
                    } else if (int.tryParse(value) == null) {
                      return AppLocalizations.of(context)!.validAgeError;
                    } else if (int.parse(value) < 0) {
                      return AppLocalizations.of(context)!.negativeAgeError;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Email Field
                TextFormField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  style: Constants.AppTypography.body.copyWith(color: Constants.AppColors.ink),
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(context)!.email,
                    hintText: translate('Enter your email address', 'अपना ईमेल पता दर्ज करें'),
                    hintStyle: Constants.AppTypography.body.copyWith(color: Constants.AppColors.inkSoft.withOpacity(0.5)),
                    labelStyle: Constants.AppTypography.body.copyWith(color: Constants.AppColors.inkSoft),
                    fillColor: Constants.AppColors.card,
                    filled: true,
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
                        color: AppColors.button,
                        width: 1.5,
                      ),
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(Constants.AppRadii.sm),
                      borderSide: const BorderSide(
                        color: AppColors.button,
                        width: 1.5,
                      ),
                    ),
                    contentPadding:
                        const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                  ),
                  validator: (value) {
                    if (value != null &&
                        value.isNotEmpty &&
                        !RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                      return AppLocalizations.of(context)!.validEmail;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Government ID Field
                TextFormField(
                  controller: govtIdController,
                  keyboardType: TextInputType.number,
                  style: Constants.AppTypography.body.copyWith(color: Constants.AppColors.ink),
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(context)!.aadhar,
                    hintText: translate('Enter 12-digit Aadhaar number', '12 अंकों का आधार नंबर दर्ज करें'),
                    hintStyle: Constants.AppTypography.body.copyWith(color: Constants.AppColors.inkSoft.withOpacity(0.5)),
                    labelStyle: Constants.AppTypography.body.copyWith(color: Constants.AppColors.inkSoft),
                    fillColor: Constants.AppColors.card,
                    filled: true,
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
                        color: AppColors.button,
                        width: 1.5,
                      ),
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(Constants.AppRadii.sm),
                      borderSide: const BorderSide(
                        color: AppColors.button,
                        width: 1.5,
                      ),
                    ),
                    contentPadding:
                        const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly, // Only allow digits
                    LengthLimitingTextInputFormatter(
                        12), // Limit input to 12 digits
                  ],
                  validator: (value) {
                    if (value != null && value.isNotEmpty) {
                      if (value.length != 12 || int.tryParse(value) == null) {
                        return AppLocalizations.of(context)!.validgovtError;
                      }
                    }
                    return null; // No error if it's empty or valid
                  },
                ),
                const SizedBox(height: 16),
                // Phone Number Input
                TextFormField(
                  controller: numberController,
                  keyboardType: TextInputType.phone,
                  style: Constants.AppTypography.body.copyWith(color: Constants.AppColors.ink),
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(context)!.phone,
                    hintText: translate('Enter 10-digit mobile number', '10 अंकों का मोबाइल नंबर दर्ज करें'),
                    hintStyle: Constants.AppTypography.body.copyWith(color: Constants.AppColors.inkSoft.withOpacity(0.5)),
                    labelStyle: Constants.AppTypography.body.copyWith(color: Constants.AppColors.inkSoft),
                    fillColor: Constants.AppColors.card,
                    filled: true,
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
                        color: AppColors.button,
                        width: 1.5,
                      ),
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(Constants.AppRadii.sm),
                      borderSide: const BorderSide(
                        color: AppColors.button,
                        width: 1.5,
                      ),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                        vertical: 14, horizontal: 16),
                  ),
                  maxLength: 10,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return AppLocalizations.of(context)!.phoneEmpty;
                    } else if (value.length != 10) {
                      return AppLocalizations.of(context)!.validPhoneError;
                    }
                    return null;
                  },
                ),

                TextFormField(
                  decoration: InputDecoration(
                    labelText: translate(
                        'Select your skills', 'अपने कौशल का चयन करें'),
                    hintText: translate('Tap to select your skills', 'अपने कौशल चुनने के लिए टैप करें'),
                    hintStyle: Constants.AppTypography.body.copyWith(color: Constants.AppColors.inkSoft.withOpacity(0.5)),
                    border: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: AppColors.brand, // Default border color
                        width: 2.0, // Border width
                      ),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: AppColors.button, // Red border in case of error
                        width: 2.0,
                      ),
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors
                            .red, // Red border when focused and error exists
                        width: 2.0,
                      ),
                    ),
                    contentPadding:
                        EdgeInsets.symmetric(vertical: 3, horizontal: 5),
                  ),
                  onTap: () {
                    setState(() {
                      // Toggle skills visibility on tap
                      isSkillsVisible = !isSkillsVisible;
                    });
                  },
                ),
                // Show the skills list only when isSkillsVisible is true
                if (isSkillsVisible)
                  Column(
                    children: skills.map((skill) {
                      return CheckboxListTile(
                        title: Text(translateText(skill.name)),
                        value: selectedSkills.contains(skill.name),
                        onChanged: (bool? selected) {
                          setState(() {
                            if (selected != null && selected) {
                              selectedSkills.add(skill.name); // Add skill
                            } else {
                              selectedSkills.remove(skill.name); // Remove skill
                            }

                            // Close the skills list after a skill is selected or deselected
                            isSkillsVisible = false;
                          });
                        },
                      );
                    }).toList(),
                  ),

                // Display selected skills
                if (selectedSkills.isNotEmpty)
                  Wrap(
                    spacing: 8.0,
                    runSpacing: 8.0,
                    children: selectedSkills.map((skill) {
                      return Card(
                        elevation: 4, // Adds a shadow effect
                        margin: EdgeInsets.symmetric(
                            vertical: 4,
                            horizontal: 8), // Space around each card
                        child: Padding(
                          padding: EdgeInsets.all(8), // Padding inside the card
                          child: Text(
                            translateText(
                                skill), // Dynamic translation for skill
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                      );
                    }).toList(),
                  ),

                SizedBox(height: 16),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: translate(
                        'Select your certifications', 'अपने प्रमाणपत्र चुनें'),
                    hintText: translate('Tap to select certifications', 'प्रमाणपत्र चुनने के लिए टैप करें'),
                    hintStyle: Constants.AppTypography.body.copyWith(color: Constants.AppColors.inkSoft.withOpacity(0.5)),
                    border: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: AppColors.brand, // Default border color
                        width: 2.0, // Border width
                      ),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: AppColors.button, // Red border in case of error
                        width: 2.0,
                      ),
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors
                            .red, // Red border when focused and error exists
                        width: 2.0,
                      ),
                    ),
                    contentPadding:
                        EdgeInsets.symmetric(vertical: 3, horizontal: 5),
                  ),
                  onTap: () {
                    setState(() {
                      // Toggle skills visibility on tap
                      iscertVisible = !iscertVisible;
                    });
                  },
                ),

                if (iscertVisible)
                  Column(
                    children: certifications.map((Qualification) {
                      return CheckboxListTile(
                        title: Text(translateText(Qualification.name)),
                        value:
                            selectedcertifications.contains(Qualification.name),
                        onChanged: (bool? selected) {
                          setState(() {
                            if (selected != null && selected) {
                              selectedcertifications
                                  .add(Qualification.name); // Add qualification
                            } else {
                              selectedcertifications.remove(
                                  Qualification.name); // Remove qualification
                            }

                            // Close the qualifications list after selecting or deselecting
                            iscertVisible = false;
                          });
                        },
                      );
                    }).toList(),
                  ),
                Column(
                  children: selectedcertifications.map((skill) {
                    return Card(
                      elevation: 4, // Adds a shadow effect
                      margin: EdgeInsets.symmetric(
                          vertical: 4, horizontal: 8), // Space around each card
                      child: Padding(
                        padding: EdgeInsets.all(8), // Padding inside the card
                        child: Text(
                          translateText(skill), // Dynamic translation for skill
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    );
                  }).toList(),
                ),

                SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: selectedExperience, // Allow null if the value is empty
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: AppColors.brand, // Default border color
                        width: 2.0, // Border width
                      ),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.red, width: 2.0),
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.red, width: 2.0),
                    ),
                    contentPadding:
                        EdgeInsets.symmetric(vertical: 3, horizontal: 5),
                  ),
                  items: experienceOptions.map((experience) {
                    return DropdownMenuItem<String>(
                      value: experience,
                      child: Text(experience),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedExperience = value ??
                          ''; // If value is null, set it to an empty string
                    });
                  },
                  validator: (value) {
                    // You can allow null or empty string and show a custom message if needed
                    return value == null || value.isEmpty
                        ? 'Please select an Education'
                        : null;
                  },
                ),

                const SizedBox(height: 16),
                TextFormField(
                  controller: addressController,
                  keyboardType: TextInputType.text,
                  maxLines: 3,
                  decoration: InputDecoration(
                    labelText: "House No. /VPO / Village",
                    hintText: translate('Enter house no., village, area', 'मकान नं., गांव, क्षेत्र दर्ज करें'),
                    hintStyle: Constants.AppTypography.body.copyWith(color: Constants.AppColors.inkSoft.withOpacity(0.5)),
                    suffixIcon: MicIconButton(controller: addressController),
                    border: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: AppColors.brand, // Default border color
                        width: 2.0, // Border width
                      ),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: AppColors.button, // Red border in case of error
                        width: 2.0,
                      ),
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors
                            .red, // Red border when focused and error exists
                        width: 2.0,
                      ),
                    ),
                    contentPadding:
                        EdgeInsets.symmetric(vertical: 3, horizontal: 5),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return AppLocalizations.of(context)!.emptyAddress;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),



                // State Dropdown
                DropdownButtonFormField<String>(
                  value: selectedState,
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(context)!.state,
                    contentPadding:
                        EdgeInsets.symmetric(vertical: 3, horizontal: 5),
                    border: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: AppColors.brand, // Default border color
                        width: 2.0, // Border width
                      ),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: AppColors.button, // Red border in case of error
                        width: 2.0,
                      ),
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors
                            .red, // Red border when focused and error exists
                        width: 2.0,
                      ),
                    ),
                  ),
                  items: (statesEn)
                      .map((state) => DropdownMenuItem<String>(
                            value: state,
                            child: Text(state),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedState = value!;
                    });
                    _onStateSelected(
                        value); // Trigger the state selection handler
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return AppLocalizations.of(context)!.stateEmpty;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                DropdownButtonFormField<String>(
                  value: selectedCity,
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(context)!.city,
                    contentPadding:
                    EdgeInsets.symmetric(vertical: 3, horizontal: 5),
                    border: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: AppColors.brand, // Default border color
                        width: 2.0, // Border width
                      ),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: AppColors.button, // Red border in case of error
                        width: 2.0,
                      ),
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors
                            .red, // Red border when focused and error exists
                        width: 2.0,
                      ),
                    ),
                  ),
                  items: (citiesEn)
                      .map((city) => DropdownMenuItem<String>(
                    value: city,
                    child: Text(city),
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

                TextFormField(
                  controller: pinCodeController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(context)!.pincode,
                    hintText: translate('Enter 6-digit pin code', '6 अंकों का पिन कोड दर्ज करें'),
                    hintStyle: Constants.AppTypography.body.copyWith(color: Constants.AppColors.inkSoft.withOpacity(0.5)),
                    border: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: AppColors.brand, // Default border color
                        width: 2.0, // Border width
                      ),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: AppColors.button, // Red border in case of error
                        width: 2.0,
                      ),
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors
                            .red, // Red border when focused and error exists
                        width: 2.0,
                      ),
                    ),
                    contentPadding:
                        EdgeInsets.symmetric(vertical: 3, horizontal: 5),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return AppLocalizations.of(context)!.emptyPinError;
                    } else if (value.length != 6 ||
                        int.tryParse(value) == null) {
                      return AppLocalizations.of(context)!.validPinError;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Address Field

                // Submit Button
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(
                            0xFF0E6805), // Green color for the button
                        padding: const EdgeInsets.symmetric(
                            vertical: 2, horizontal: 32),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                              8), // Reduced curvature for a more rectangular look
                        ),
                      ),
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          await _submitForm();
                        }
                      },
                      child: Text(
                        translate('Update', 'अपडेट'),
                        style: TextStyle(color: Colors.white),
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


