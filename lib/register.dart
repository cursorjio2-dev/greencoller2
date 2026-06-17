import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:greencollar/speech_helper.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:greencollar/l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart'; // Import image_picker
import 'package:translator/translator.dart';
import 'dart:io'; // For File handling
import 'main.dart'; // Import the LanguageProvider class
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:http/http.dart' as http;
import 'package:fluttertoast/fluttertoast.dart';
import 'package:greencollar/constants.dart' as Constants;

class RegistrationForm extends StatefulWidget {
  const RegistrationForm({super.key});

  @override
  _RegistrationFormState createState() => _RegistrationFormState();
}

class _RegistrationFormState extends State<RegistrationForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController ageController = TextEditingController();
  final TextEditingController numberController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController repasswordController = TextEditingController();

  final TextEditingController pinCodeController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController agencyNameController = TextEditingController();
  final TextEditingController regnoController = TextEditingController();
  bool _isButtonDisabled = false; // Variable to track the button state

  final TextEditingController numberOfEmployeesController =
      TextEditingController();
  final TextEditingController yearofestb = TextEditingController();
  bool _isPasswordVisible = false; // For toggling password visibility
  File? _profileImage; // To hold the selected image
  String selectedOption = 'farmer';
  String selectedLabourType = 'individual'; // Default value for Labour type
  String selectedGender = 'Male'; // Default selected value
  final TextEditingController emailController = TextEditingController();
  final TextEditingController govtIdController = TextEditingController();
  // Image Picker instance
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

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      loadLanguage();

      setState(() {
        gender = [
          AppLocalizations.of(context)!.male,
          AppLocalizations.of(context)!.female,
          AppLocalizations.of(context)!.other,
        ];
      });
      _fetchStates();
      _fetchLocation();
    });
  }

  void _onStateSelected(String? selectedState) {
    if (selectedState != null && stateCodes.containsKey(selectedState)) {
      int stateCode = stateCodes[selectedState]!;
      _fetchOtherData(
          stateCode); // Call another API function using the state code
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

  final List<String> membersOptions = [
    "0-5",
    "5-20",
    "20-50",
    "50-100",
    ">100",
  ];

  Future<void> _submitForm() async {
    final language =
        Provider.of<LanguageProvider>(context, listen: false).selectedLanguage;

    if (_formKey.currentState?.validate() ?? false) {
      _formKey.currentState?.save();

      // Disable the button before submitting the form
      setState(() {
        _isButtonDisabled = true;
      });

      // Select the appropriate endpoint based on `selectedOption`
      final String apiUrl = selectedOption == "farmer"
          ? '${Constants.AppConstants.apiUrl}farmer/register'
          : '${Constants.AppConstants.apiUrl}labour/register';

      final Map<String, dynamic> requestBody = {
        'name': nameController.text,
        'age': ageController.text,
        'phone': numberController.text,
        'password': passwordController.text,
        'pincode': pinCodeController.text,
        'address': addressController.text,
        'email': emailController.text,
        'aadhar': govtIdController.text,
        'selectedOption': selectedOption,
        'userType': selectedLabourType,
        'gender': selectedGender,
        'city': selectedCity,
        'state': selectedState,
        if (selectedLabourType == 'agency')
          'agency_name': agencyNameController.text,
        if (selectedLabourType == 'agency') 'no_of_labour': selectedMembers,
        if (selectedLabourType == 'agency')
          'agency_reg_no': regnoController.text,
        if (selectedLabourType == 'agency') 'agency_reg_year': yearofestb.text,
        if (selectedLabourType == 'agency') 'agency_type': selectedAgencyType,
      };

      // Include the profile image if available
      if (_profileImage != null) {
        requestBody['profileImage'] =
            base64Encode(await _profileImage!.readAsBytes());
      }

      print(jsonEncode(requestBody));
      print(apiUrl);
      try {
        final response = await http.post(
          Uri.parse(apiUrl),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(requestBody),
        );

        if (response.statusCode == 201) {
          final responseData = jsonDecode(response.body);

          Fluttertoast.showToast(
            msg: responseData['message'] ??
                AppLocalizations.of(context)!.registerSuccessful,
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            backgroundColor: Colors.green.shade700,
            textColor: Colors.white,
            fontSize: 16.0,
          );

          await Future.delayed(const Duration(seconds: 2));

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const LoginScreen(),
            ),
          );
        } else if (response.statusCode == 422) {
          final responseData = jsonDecode(response.body);

          if (responseData['errors'] != null) {
            final errors = responseData['errors'] as Map<String, dynamic>;
            errors.forEach((field, messages) {
              for (var message in messages) {
                Fluttertoast.showToast(
                  msg: message,
                  toastLength: Toast.LENGTH_SHORT,
                  gravity: ToastGravity.BOTTOM,
                  backgroundColor: Colors.red.shade700,
                  textColor: Colors.white,
                  fontSize: 16.0,
                );
              }
            });
          }
        } else {
          Fluttertoast.showToast(
            msg: AppLocalizations.of(context)!.registerError,
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            backgroundColor: Colors.red.shade700,
            textColor: Colors.white,
            fontSize: 16.0,
          );
        }
      } catch (e) {
        print(e);
      } finally {
        // Re-enable the button after the response (success or failure)
        setState(() {
          _isButtonDisabled = false;
        });
      }
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

    print("$_selectedLanguage: $text");

    // ✅ Check manual translations first
    if (translations.containsKey(text) &&
        translations[text]!.containsKey(_selectedLanguage)) {
      return translations[text]![
          _selectedLanguage]!; // Return manual translation
    }

    // ✅ Check cached translations
    if (_cachedTranslations.containsKey(text) &&
        _cachedTranslations[text]!.containsKey(_selectedLanguage)) {
      return _cachedTranslations[text]![
          _selectedLanguage]!; // Return cached translation
    }

    // ✅ Fetch translation dynamically if missing
    _fetchTranslation(text, _selectedLanguage);

    return text; // Return original text while waiting for translation
  }

  /// ✅ Fetch translation dynamically and update cache
  Future<void> _fetchTranslation(String text, String targetLang) async {
    try {
      print("dfdsfdsfd");

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

  @override
  void dispose() {
    super.dispose();
    nameController.dispose();
    _speech.stop();
  }

  InputDecoration _buildInputDecoration(String labelText, {Widget? suffixIcon, TextEditingController? controller}) {
    return InputDecoration(
      labelText: labelText,
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
    final language = context.watch<LanguageProvider>().selectedLanguage;
    selectedGender = AppLocalizations.of(context)!.male;

    return Scaffold(
      backgroundColor: Constants.AppColors.surface,
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          AppLocalizations.of(context)!.registerform,
          style: Constants.AppTypography.h3.copyWith(color: Colors.white),
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: Constants.AppColors.brandGradient,
          ),
        ),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      AppLocalizations.of(context)!.registerAs,
                      style: Constants.AppTypography.h3.copyWith(color: Constants.AppColors.ink),
                    ),
                  ],
                ),
                const SizedBox(height: 12), // Add spacing between the cards

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    // Farmer Option
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedOption = 'farmer'; // Set to 'farmer' on tap
                          });
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: selectedOption == 'farmer'
                                ? Constants.AppColors.brand
                                : Constants.AppColors.card,
                            borderRadius: BorderRadius.circular(Constants.AppRadii.sm),
                            border: Border.all(
                              color: selectedOption == 'farmer'
                                  ? Constants.AppColors.brand
                                  : Constants.AppColors.border,
                              width: 1.0,
                            ),
                            boxShadow: const [Constants.AppShadows.soft],
                          ),
                          height: 50,
                          child: Center(
                            child: Text(
                              AppLocalizations.of(context)!.farmer,
                              style: Constants.AppTypography.subhead.copyWith(
                                fontWeight: FontWeight.bold,
                                color: selectedOption == 'farmer'
                                    ? Colors.white
                                    : Constants.AppColors.ink,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(width: 10), // Add spacing between the cards

                    // Labour Option
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedOption = 'labour'; // Set to 'labour' on tap
                          });
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: selectedOption == 'labour'
                                ? Constants.AppColors.brand
                                : Constants.AppColors.card,
                            borderRadius: BorderRadius.circular(Constants.AppRadii.sm),
                            border: Border.all(
                              color: selectedOption == 'labour'
                                  ? Constants.AppColors.brand
                                  : Constants.AppColors.border,
                              width: 1.0,
                            ),
                            boxShadow: const [Constants.AppShadows.soft],
                          ),
                          height: 50,
                          child: Center(
                            child: Text(
                              AppLocalizations.of(context)!.labour,
                              style: Constants.AppTypography.subhead.copyWith(
                                fontWeight: FontWeight.bold,
                                color: selectedOption == 'labour'
                                    ? Colors.white
                                    : Constants.AppColors.ink,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      AppLocalizations.of(context)!.workingAs,
                      style: Constants.AppTypography.h3.copyWith(color: Constants.AppColors.ink),
                    ),
                  ],
                ),
                const SizedBox(height: 10), // Add spacing between the cards

                // Show Radio Buttons for Labour Option
                Column(
                  children: [
                    Row(
                      children: [
                        // Individual Option
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                selectedLabourType = 'individual';
                              });
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: selectedLabourType == 'individual'
                                    ? Constants.AppColors.brand
                                    : Constants.AppColors.card,
                                borderRadius: BorderRadius.circular(Constants.AppRadii.sm),
                                border: Border.all(
                                  color: selectedLabourType == 'individual'
                                      ? Constants.AppColors.brand
                                      : Constants.AppColors.border,
                                  width: 1.0,
                                ),
                                boxShadow: const [Constants.AppShadows.soft],
                              ),
                              height: 50,
                              child: Center(
                                child: Text(
                                  AppLocalizations.of(context)!.individual,
                                  style: Constants.AppTypography.subhead.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: selectedLabourType == 'individual'
                                        ? Colors.white
                                        : Constants.AppColors.ink,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(width: 10), // Spacing between the cards

                        // Agency Option
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                selectedLabourType = 'agency';
                              });
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: selectedLabourType == 'agency'
                                    ? Constants.AppColors.brand
                                    : Constants.AppColors.card,
                                borderRadius: BorderRadius.circular(Constants.AppRadii.sm),
                                border: Border.all(
                                  color: selectedLabourType == 'agency'
                                      ? Constants.AppColors.brand
                                      : Constants.AppColors.border,
                                  width: 1.0,
                                ),
                              ),
                              height: 50,
                              child: Center(
                                child: Text(
                                  AppLocalizations.of(context)!.agency,
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: selectedLabourType == 'agency'
                                        ? Colors.white
                                        : Colors.black,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                // const SizedBox(height: 16),
                // GestureDetector(
                //   onTap: _pickImage,
                //   child: CircleAvatar(
                //     radius: 50,
                //     backgroundColor: Colors.grey[200],
                //     backgroundImage: _profileImage != null
                //         ? FileImage(_profileImage!)
                //         : null,
                //     child: _profileImage == null
                const SizedBox(height: 16),
                if (selectedLabourType == 'agency') ...[
                  const SizedBox(height: 16),
                  // Agency Name Field
                  TextFormField(
                    controller: agencyNameController,
                    keyboardType: TextInputType.text,
                    decoration: _buildInputDecoration(AppLocalizations.of(context)!.agencyName, controller: agencyNameController),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return AppLocalizations.of(context)!.enterAgencyName;
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: regnoController,
                    keyboardType: TextInputType.text,
                    decoration: _buildInputDecoration(AppLocalizations.of(context)!.regno, controller: regnoController),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return AppLocalizations.of(context)!.emptyfield;
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: yearofestb,
                    keyboardType: TextInputType.number,
                    decoration: _buildInputDecoration(AppLocalizations.of(context)!.yearofestb, controller: yearofestb),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return AppLocalizations.of(context)!.emptyfield;
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),

                  DropdownButtonFormField<String>(
                    value: selectedAgencyType,
                    onChanged: (value) {
                      setState(() {
                        selectedAgencyType = value;
                      });
                    },
                    items: agencyTypes.map((type) {
                      return DropdownMenuItem<String>(
                        value: type,
                        child: Text(type),
                      );
                    }).toList(),
                    decoration: _buildInputDecoration("Select Agency Type"),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: selectedMembers,
                    onChanged: (value) {
                      setState(() {
                        selectedMembers = value;
                      });
                    },
                    items: membersOptions.map((option) {
                      return DropdownMenuItem<String>(
                        value: option,
                        child: Text(option),
                      );
                    }).toList(),
                    decoration: _buildInputDecoration("Members"),
                  ),
                  const SizedBox(height: 20),
                ],

                // Name Input
                TextFormField(
                  controller: nameController,
                  decoration: _buildInputDecoration(
                    AppLocalizations.of(context)!.name,
                    controller: nameController,
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return AppLocalizations.of(context)!.nameValidation;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Age Input
                TextFormField(
                  controller: ageController,
                  keyboardType: TextInputType.number,
                  decoration: _buildInputDecoration(AppLocalizations.of(context)!.age),
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

                DropdownButtonFormField<String>(
                  value: selectedGender,
                  decoration: _buildInputDecoration(AppLocalizations.of(context)!.gender),
                  items: gender
                      .map((gender) => DropdownMenuItem<String>(
                            value: gender,
                            child: Text(gender),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedGender = value!;
                    });
                  },
                ),

                const SizedBox(height: 16),

                // Email Field
                TextFormField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: _buildInputDecoration(AppLocalizations.of(context)!.email),
                  validator: (value) {
                    if (value != null && value.isNotEmpty) {
                      if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                        return AppLocalizations.of(context)!.validEmail;
                      }
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Government ID Field
                TextFormField(
                  controller: govtIdController,
                  keyboardType: TextInputType.number,
                  decoration: _buildInputDecoration(AppLocalizations.of(context)!.aadhar),
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(12),
                  ],
                  validator: (value) {
                    if (value != null && value.isNotEmpty) {
                      if (value.length != 12 || int.tryParse(value) == null) {
                        return AppLocalizations.of(context)!.validgovtError;
                      }
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                // Phone Number Input
                TextFormField(
                  controller: numberController,
                  keyboardType: TextInputType.phone,
                  decoration: _buildInputDecoration(AppLocalizations.of(context)!.phone),
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

                // Password Input
                TextFormField(
                  controller: passwordController,
                  obscureText: !_isPasswordVisible,
                  decoration: _buildInputDecoration(
                    AppLocalizations.of(context)!.password,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                        color: Constants.AppColors.brand,
                      ),
                      onPressed: () {
                        setState(() {
                          _isPasswordVisible = !_isPasswordVisible;
                        });
                      },
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return AppLocalizations.of(context)!.emptyPasswordValidation;
                    } else if (value.length < 6) {
                      return AppLocalizations.of(context)!.passwordCharValidation;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: repasswordController,
                  obscureText: !_isPasswordVisible,
                  decoration: _buildInputDecoration(
                    AppLocalizations.of(context)!.confirmPassword,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                        color: Constants.AppColors.brand,
                      ),
                      onPressed: () {
                        setState(() {
                          _isPasswordVisible = !_isPasswordVisible;
                        });
                      },
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return AppLocalizations.of(context)!.emptyPasswordValidation;
                    } else if (passwordController.text != repasswordController.text) {
                      return AppLocalizations.of(context)!.repasserro;
                    } else if (value.length < 6) {
                      return AppLocalizations.of(context)!.passwordCharValidation;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Address Field
                TextFormField(
                  controller: addressController,
                  keyboardType: TextInputType.text,
                  maxLines: 3,
                  decoration: _buildInputDecoration("House No. /VPO / Village", controller: addressController),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return AppLocalizations.of(context)!.emptyAddress;
                    }
                    return null;
                  },
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

                TextFormField(
                  controller: pinCodeController,
                  keyboardType: TextInputType.number,
                  decoration: _buildInputDecoration(AppLocalizations.of(context)!.pincode, controller: pinCodeController),
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

                const SizedBox(height: 24),

                // Submit Button
                Container(
                  height: 50,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: _isButtonDisabled ? null : Constants.AppColors.brandGradient,
                    color: _isButtonDisabled ? Colors.grey : null,
                    borderRadius: BorderRadius.circular(Constants.AppRadii.sm),
                    boxShadow: _isButtonDisabled ? null : const [Constants.AppShadows.soft],
                  ),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(Constants.AppRadii.sm),
                      ),
                    ),
                    onPressed: _isButtonDisabled
                        ? null // Disable the button if _isButtonDisabled is true
                        : () async {
                            if (_formKey.currentState?.validate() ?? false) {
                              await _submitForm();
                            }
                          },
                    child: Text(
                      AppLocalizations.of(context)!.register,
                      style: Constants.AppTypography.subhead.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
