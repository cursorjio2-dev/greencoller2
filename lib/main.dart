import 'dart:convert';
import 'dart:io';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:greencollar/HomeScree.dart';
import 'package:greencollar/constants.dart';
import 'package:greencollar/l10n/app_localizations.dart';
import 'package:greencollar/labourhomepage.dart';
import 'package:greencollar/privacypolicy.dart';
import 'package:greencollar/register.dart';
import 'package:provider/provider.dart';
import 'package:greencollar/location_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:greencollar/constants.dart' as Constants;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:translator/translator.dart';
import 'package:greencollar/api_logger.dart';

Future<void> main() async {
  HttpOverrides.global = MyHttpOverrides();

  http.runWithClient(
    () async {
      WidgetsFlutterBinding.ensureInitialized();
      final languageProvider = LanguageProvider();
      await languageProvider.loadLanguage();

      runApp(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<LanguageProvider>.value(value: languageProvider),
            ChangeNotifierProvider<LocationProvider>(create: (context) => LocationProvider()),
          ],
          child: MyApp(),
        ),
      );
    },
    () => LoggingHttpClient(http.Client()),
  );
}

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

class LanguageProvider extends ChangeNotifier {
  String _selectedLanguage = 'en'; // Default language is English
  final FlutterSecureStorage _secureStorage = FlutterSecureStorage();

  String get selectedLanguage => _selectedLanguage;

  // Set language in FlutterSecureStorage
  Future<void> setLanguage(String languageCode) async {
    _selectedLanguage = languageCode;
    notifyListeners();

    // Save the selected language securely in FlutterSecureStorage
    await _secureStorage.write(
        key: 'selectedLanguage', value: _selectedLanguage);
    String? language = await _secureStorage.read(key: 'selectedLanguage');
    _selectedLanguage = language ?? 'en';
    print(language); // Default to English if null
  }

  // Load the language from FlutterSecureStorage
  Future<void> loadLanguage() async {
    // Read the selected language from FlutterSecureStorage
    String? language = await _secureStorage.read(key: 'selectedLanguage');
    _selectedLanguage = language ?? 'en'; // Default to English if null
    notifyListeners();
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<LanguageProvider>(
      builder: (context, languageProvider, child) {
        Locale _locale = Locale(languageProvider.selectedLanguage);

        return MaterialApp(
          debugShowCheckedModeBanner: false,
          navigatorObservers: [ScreenObserver()],
          title: 'Green Collar',
          supportedLocales: [Locale('en'), Locale('hi')],
          locale: _locale, // Set locale dynamically
          localizationsDelegates: [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          theme: ThemeData(
            useMaterial3: true,
            scaffoldBackgroundColor: AppColors.surface,
            textTheme: GoogleFonts.plusJakartaSansTextTheme(
              Theme.of(context).textTheme,
            ),
            primaryColor: AppColors.brand,
            colorScheme: ColorScheme.fromSeed(
              seedColor: AppColors.brand,
              primary: AppColors.brand,
              secondary: AppColors.brandSoft,
              surface: AppColors.surface,
            ),
            appBarTheme: const AppBarTheme(
              backgroundColor: AppColors.brand,
              foregroundColor: Colors.white,
              elevation: 0,
              centerTitle: false,
              iconTheme: IconThemeData(color: Colors.white),
            ),
            cardTheme: CardThemeData(
              color: AppColors.card,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadii.lg),
                side: const BorderSide(color: AppColors.border, width: 1.0),
              ),
              shadowColor: AppColors.brandDeep.withOpacity(0.04),
            ),
            inputDecorationTheme: InputDecorationTheme(
              filled: true,
              fillColor: AppColors.card,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadii.sm),
                borderSide: const BorderSide(color: AppColors.border),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadii.sm),
                borderSide: const BorderSide(color: AppColors.border),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadii.sm),
                borderSide: const BorderSide(color: AppColors.brand, width: 1.5),
              ),
            ),
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.brand,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadii.sm),
                ),
                padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
              ),
            ),
          ),
          home: const SplashScreen(),
        );
      },
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  final GoogleTranslator _translator = GoogleTranslator();
  Map<String, Map<String, String>> _cachedTranslations =
      {}; // Translation cache

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  /// ✅ Initialize app: fetch translations and check login status
  Future<void> _initializeApp() async {
    await _requestLocationPermission();
    await fetchTranslations();
    await _checkUserLogin();
  }

  /// ✅ Request location permission at app startup
  Future<void> _requestLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Check if location services are enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled, we can still proceed
      return;
    }

    // Check current permission status
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      // Request permission
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are permanently denied
      return;
    }
  }

  /// ✅ Check internet connectivity
  Future<bool> _isConnectedToInternet() async {
    // Get connectivity result (which is not normally a list)
    var connectivityResult = await Connectivity().checkConnectivity();

    // Wrapping the result in a list (as you asked)
    var connectivityList = connectivityResult;

    print(connectivityList); // This will print a list

    // Check if the list contains a connection type other than `ConnectivityResult.none`
    return !connectivityList.contains(ConnectivityResult.none);
  }

  /// ✅ Fetch stored user data and navigate accordingly
  Future<void> _checkUserLogin() async {
    // Check internet connectivity before proceeding
    bool isConnected = await _isConnectedToInternet();
    if (!isConnected) {
      // If no internet connection, show a FlutterToast message
      Fluttertoast.showToast(
          msg: "No internet connection available!",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 3,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0);
    }

    // Proceed with the normal logic if there is an internet connection
    String? userId = await _secureStorage.read(key: 'id');
    String? userType = await _secureStorage.read(key: 'userType');
    String? language = await _secureStorage.read(key: 'selectedLanguage');
    print(language);
    await Future.delayed(const Duration(seconds: 2)); // Simulating splash delay
    if (language == null) {
      // If language is not set, navigate to Language Selection Screen
      Navigator.pushReplacement(context,
          MaterialPageRoute(builder: (context) => LanguageSelectionScreen()));
      return; // Stop further execution
    }
    if (userId != null && userType != null) {
      if (userType == 'farmer') {
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => HomePage()));
      } else {
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => Labourhomepage()));
      }
    } else {
      Navigator.pushReplacement(context,
          MaterialPageRoute(builder: (context) => const LoginScreen()));
    }
  }

  /// ✅ Fetch translations from API and update the cache
  Future<void> fetchTranslations() async {
    try {
      final response = await http
          .post(Uri.parse('${AppConstants.apiUrl}farmer/getTranslations'));

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);

        if (jsonData['status'] == 1) {
          List<dynamic> data = jsonData['data'];

          for (var item in data) {
            String text = item['text'];
            String lang = item['lang'];
            String translation = item['translation'];

            // ✅ Ensure text exists in translations
            if (!AppConstants.translations.containsKey(text)) {
              AppConstants.translations[text] = {
                "en": text,
                "hi": text
              }; // Default values
            }

            // ✅ Store API-provided translations
            AppConstants.translations[text]![lang] = translation;
          }

          // ✅ Cache translations
          _cachedTranslations = AppConstants.translations;

          // ✅ Fetch missing translations dynamically
          for (var text in AppConstants.translations.keys) {
            if (!AppConstants.translations[text]!.containsKey("hi")) {
              _fetchTranslation(text, "hi");
            }
            if (!AppConstants.translations[text]!.containsKey("en")) {
              _fetchTranslation(text, "en");
            }
          }
        } else {
          throw Exception(
              "Failed to load translations: ${jsonData['message']}");
        }
      } else {
        throw Exception("API Error: ${response.statusCode}");
      }
    } catch (e) {
      print("Error fetching translations: $e");
    }
  }

  /// ✅ Translate text dynamically and cache it
  Future<void> _fetchTranslation(String text, String targetLang) async {
    try {
      final translation = await _translator.translate(text, to: targetLang);

      // ✅ Store translation in cache
      _cachedTranslations.putIfAbsent(text, () => {})[targetLang] =
          translation.text;
      AppConstants.translations.putIfAbsent(text, () => {})[targetLang] =
          translation.text;

      if (mounted) {
        setState(() {}); // ✅ Update UI after fetching
      }
    } catch (e) {
      print("Translation error: $e");
    }
  }

  /// ✅ Main function to get translations
  String translateText(String text, {String targetLang = 'hi'}) {
    if (text.isEmpty) return "";

    // ✅ Check manual translations first
    if (AppConstants.translations.containsKey(text) &&
        AppConstants.translations[text]!.containsKey(targetLang)) {
      return AppConstants
          .translations[text]![targetLang]!; // Return stored translation
    }

    // ✅ Check cached translations
    if (_cachedTranslations.containsKey(text) &&
        _cachedTranslations[text]!.containsKey(targetLang)) {
      return _cachedTranslations[text]![
          targetLang]!; // Return cached translation
    }

    // ✅ Fetch translation dynamically if missing
    _fetchTranslation(text, targetLang);

    return text; // Return original text while waiting for translation
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Constants.AppColors.surface,
      body: Stack(
        children: [
          // Background Image
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/app.png', // Your image file path (replace with your image)
                fit: BoxFit
                    .fill, // This will ensure the image covers the whole screen
              ),
            ],
          ),
          // Circular Progress Indicator in the center
        ],
      ),
    );
  }
}

class LanguageSelectionScreen extends StatefulWidget {
  const LanguageSelectionScreen({super.key});

  @override
  State<LanguageSelectionScreen> createState() =>
      _LanguageSelectionScreenState();
}

final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
final GoogleTranslator _translator = GoogleTranslator();
Map<String, Map<String, String>> _cachedTranslations = {}; // Translation cache

/// ✅ Initialize app: fetch translations and check login status

Future<void> _checkUserLogin(BuildContext context) async {
  // await _secureStorage.delete(
  //     key: 'selectedLanguage'); // Clear the user ID from storage

  String? userId = await _secureStorage.read(key: 'id');
  String? userType = await _secureStorage.read(key: 'userType');
  String? language = await _secureStorage.read(key: 'selectedLanguage');
  print(language);
  await Future.delayed(const Duration(seconds: 2)); // Simulating splash delay
  if (language == null) {
    // If language is not set, navigate to Language Selection Screen
    Navigator.pushReplacement(context,
        MaterialPageRoute(builder: (context) => LanguageSelectionScreen()));
    return; // Stop further execution
  }
  if (userId != null && userType != null) {
    if (userType == 'farmer') {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => HomePage()));
    } else {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => Labourhomepage()));
    }
  } else {
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => const LoginScreen()));
  }
}

class _LanguageSelectionScreenState extends State<LanguageSelectionScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Constants.AppColors.brand,
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            SizedBox(height: MediaQuery.of(context).size.height * 0.2),
            Container(
              decoration: BoxDecoration(
                color: Constants.AppColors.card,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(48),
                  topRight: Radius.circular(48),
                ),
              ),
              width: double.infinity,
              height: MediaQuery.of(context).size.height * 0.8,
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Center(
                      child: Column(
                        children: [
                          Image.asset(
                            'assets/app.png',
                            width: 200,
                            height: 220,
                          ),
                          Text(
                            AppLocalizations.of(context)!.welcome,
                            style: Constants.AppTypography.h2,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 40),
                    Text(
                      AppLocalizations.of(context)!.selectLanguage,
                      style: Constants.AppTypography.h1,
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Flexible(
                          child: _buildLanguageCard(
                            context,
                            languageCode: 'hi',
                            text: 'हिन्दी',
                            symbol: 'ह',
                          ),
                        ),
                        Flexible(
                          child: _buildLanguageCard(
                            context,
                            languageCode: 'en',
                            text: 'English',
                            symbol: 'E',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        ElevatedButton(
                          onPressed: () async {
                            final selectedLanguage = context
                                .read<LanguageProvider>()
                                .selectedLanguage;
                            final languageCode = selectedLanguage.isEmpty
                                ? 'en'
                                : selectedLanguage;

                            // Save selected language
                            context
                                .read<LanguageProvider>()
                                .setLanguage(languageCode);
                            await _checkUserLogin(context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Constants.AppColors.brand,
                            padding: const EdgeInsets.symmetric(
                                vertical: 2, horizontal: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(Constants.AppRadii.xs),
                            ),
                            elevation: 0,
                          ),
                          child: Text(
                            AppLocalizations.of(context)!.continueText,
                            style: Constants.AppTypography.h3.copyWith(
                              color: Constants.AppColors.card,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageCard(
    BuildContext context, {
    required String languageCode,
    required String text,
    required String symbol,
  }) {
    final isSelected =
        context.watch<LanguageProvider>().selectedLanguage == languageCode;
    return GestureDetector(
      onTap: () {
        context.read<LanguageProvider>().setLanguage(languageCode);
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 10),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? Constants.AppColors.brand : Constants.AppColors.card,
          borderRadius: BorderRadius.circular(Constants.AppRadii.md),
          border: Border.all(
            color: isSelected ? Constants.AppColors.brand : Constants.AppColors.border,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected ? const [Constants.AppShadows.card] : const [Constants.AppShadows.soft],
        ),
        width: 150,
        height: 150,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              decoration: BoxDecoration(
                color: isSelected ? Constants.AppColors.card : Constants.AppColors.brandTint,
                shape: BoxShape.circle,
              ),
              width: 60,
              height: 60,
              child: Center(
                child: Text(
                  symbol,
                  style: Constants.AppTypography.display.copyWith(
                    fontSize: 40,
                    color: Constants.AppColors.brand,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              text,
              style: Constants.AppTypography.h3.copyWith(
                color: isSelected ? Constants.AppColors.card : Constants.AppColors.ink,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final FlutterSecureStorage _secureStorage = FlutterSecureStorage();
  String selectedOption = 'farmer';
  bool _isButtonDisabled =
      false; // Flag to control button's enabled/disabled state

  TextEditingController phoneNumberController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isPasswordVisible = false; // To toggle password visibility
  Future<void> _submitForm() async {
    final language =
        Provider.of<LanguageProvider>(context, listen: false).selectedLanguage;

    if (_formKey.currentState?.validate() ?? false) {
      _formKey.currentState?.save();

      // Determine the endpoint based on user type
      final String apiUrl = selectedOption == "farmer"
          ? '${Constants.AppConstants.apiUrl}farmer/login'
          : '${Constants.AppConstants.apiUrl}labour/login';
      print(apiUrl);

      final Map<String, dynamic> requestBody = {
        'phone': phoneNumberController.text,
        'password': passwordController.text,
      };
      print(jsonEncode(requestBody));

      // Disable the button before submitting the form
      setState(() {
        _isButtonDisabled = true;
      });

      try {
        // Make API call
        final response = await http.post(
          Uri.parse(apiUrl),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(requestBody),
        );
        print(response.statusCode);
        print(response.body);

        if (response.statusCode == 200) {
          // Success: Parse the response
          final responseData = jsonDecode(response.body);
          print(responseData);

          Fluttertoast.showToast(
            msg: translate(
              responseData['message'] ?? 'Login successful!',
              'लॉगिन सफल!',
            ),
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            backgroundColor: Colors.green.shade700,
            textColor: Colors.white,
            fontSize: 16.0,
          );

          // Storing data in secure storage
          await _secureStorage.write(
              key: 'id', value: responseData['user']['id'].toString());
          await _secureStorage.write(
              key: 'name', value: responseData['user']['name']);
          await _secureStorage.write(
              key: 'phone', value: responseData['user']['phone']);

          // Store the user type (farmer or labour)
          await _secureStorage.write(key: 'userType', value: selectedOption);

          // Navigate to the appropriate homepage based on user type
          await Future.delayed(const Duration(seconds: 2));

          if (selectedOption == 'farmer') {
            // Navigate to Farmer Home Page
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) =>
                      HomePage()), // Adjust the target page as needed
            );
          } else {
            // Navigate to Labour Home Page
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) =>
                      Labourhomepage()), // Adjust the target page as needed
            );
          }
        } else if (response.statusCode == 401) {
          // Unauthorized: Invalid credentials
          final responseData = jsonDecode(response.body);
          Fluttertoast.showToast(
            msg: translate(
              responseData['message'] ?? 'Invalid credentials.',
              'अमान्य क्रेडेंशियल्स।',
            ),
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            backgroundColor: Colors.red.shade700,
            textColor: Colors.white,
            fontSize: 16.0,
          );
        } else if (response.statusCode == 422) {
          // Validation errors
          final responseData = jsonDecode(response.body);
          final errors = responseData['errors'] as Map<String, dynamic>?;
          errors?.forEach((field, messages) {
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
        } else {
          // Generic error
          Fluttertoast.showToast(
            msg: translate(
              'Login failed. Try again.',
              'लॉगिन विफल। पुनः प्रयास करें।',
            ),
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            backgroundColor: Colors.red.shade700,
            textColor: Colors.white,
            fontSize: 16.0,
          );
        }
      } catch (e) {
        // Network or unexpected error
        Fluttertoast.showToast(
          msg: translate(
            'An error occurred.',
            'एक त्रुटि हुई।',
          ),
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.orange.shade700,
          textColor: Colors.white,
          fontSize: 16.0,
        );
        debugPrint('Error: $e');
      } finally {
        // Re-enable the button after a delay or when the response is received
        setState(() {
          _isButtonDisabled = false; // Re-enable the button
        });
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
    final language = context.watch<LanguageProvider>().selectedLanguage;

    return Scaffold(
      backgroundColor: Constants.AppColors.surface,
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Constants.AppColors.brandTint,
              Constants.AppColors.surface,
            ],
            stops: [0.0, 0.45],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  const SizedBox(height: 40),
                  // App Logo with soft shadow
                  Center(
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      height: 160,
                      child: Image.asset(
                        'assets/app.png',
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Title Header
                  Text(
                    AppLocalizations.of(context)!.pleaseLogin,
                    style: Constants.AppTypography.display.copyWith(
                      fontSize: 30,
                      fontWeight: FontWeight.w800,
                      color: Constants.AppColors.brandDeep,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),

                  // Main Interactive Form Card
                  Container(
                    padding: const EdgeInsets.all(20.0),
                    decoration: BoxDecoration(
                      color: Constants.AppColors.card,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: const [Constants.AppShadows.card],
                      border: Border.all(
                        color: Constants.AppColors.border,
                        width: 1.0,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Row for Farmer and Labour selection
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            // Farmer Option
                            Expanded(
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    selectedOption = 'farmer';
                                  });
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: selectedOption == 'farmer'
                                        ? Constants.AppColors.brand
                                        : Constants.AppColors.surface2,
                                    borderRadius: BorderRadius.circular(Constants.AppRadii.md),
                                    border: Border.all(
                                      color: selectedOption == 'farmer'
                                          ? Constants.AppColors.brand
                                          : Constants.AppColors.border,
                                    ),
                                    boxShadow: selectedOption == 'farmer'
                                        ? const [Constants.AppShadows.soft]
                                        : null,
                                  ),
                                  height: 48,
                                  child: Center(
                                    child: Text(
                                      AppLocalizations.of(context)!.farmer,
                                      style: Constants.AppTypography.h3.copyWith(
                                        color: selectedOption == 'farmer'
                                            ? Constants.AppColors.card
                                            : Constants.AppColors.ink,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            // Labour Option
                            Expanded(
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    selectedOption = 'labour';
                                  });
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: selectedOption == 'labour'
                                        ? Constants.AppColors.brand
                                        : Constants.AppColors.surface2,
                                    borderRadius: BorderRadius.circular(Constants.AppRadii.md),
                                    border: Border.all(
                                      color: selectedOption == 'labour'
                                          ? Constants.AppColors.brand
                                          : Constants.AppColors.border,
                                    ),
                                    boxShadow: selectedOption == 'labour'
                                        ? const [Constants.AppShadows.soft]
                                        : null,
                                  ),
                                  height: 48,
                                  child: Center(
                                    child: Text(
                                      AppLocalizations.of(context)!.labour,
                                      style: Constants.AppTypography.h3.copyWith(
                                        color: selectedOption == 'labour'
                                            ? Constants.AppColors.card
                                            : Constants.AppColors.ink,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 24),

                        // Form Fields
                        Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                AppLocalizations.of(context)!.phone,
                                style: Constants.AppTypography.label.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Constants.AppColors.ink,
                                ),
                              ),
                              const SizedBox(height: 8),
                              // Phone Number Input with +91
                              Row(
                                children: [
                                  // Static +91
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 14),
                                    height: 50,
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      color: Constants.AppColors.brandTint,
                                      borderRadius: BorderRadius.circular(Constants.AppRadii.sm),
                                      border: Border.all(
                                        color: Constants.AppColors.border,
                                        width: 1,
                                      ),
                                    ),
                                    child: Text(
                                      "+91",
                                      style: Constants.AppTypography.h3.copyWith(
                                        color: Constants.AppColors.brandDeep,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  // TextField for phone number
                                  Expanded(
                                    child: TextFormField(
                                      controller: phoneNumberController,
                                      keyboardType: TextInputType.phone,
                                      style: Constants.AppTypography.body.copyWith(
                                        fontWeight: FontWeight.w600,
                                      ),
                                      decoration: InputDecoration(
                                        hintText: AppLocalizations.of(context)!.enterMobile,
                                        hintStyle: Constants.AppTypography.body.copyWith(
                                          color: Constants.AppColors.inkSoft,
                                        ),
                                        filled: true,
                                        fillColor: Constants.AppColors.surface,
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(Constants.AppRadii.sm),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(Constants.AppRadii.sm),
                                          borderSide: const BorderSide(color: Constants.AppColors.border),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(Constants.AppRadii.sm),
                                          borderSide: const BorderSide(color: Constants.AppColors.brand, width: 1.5),
                                        ),
                                        contentPadding: const EdgeInsets.symmetric(
                                          vertical: 0,
                                          horizontal: 14,
                                        ),
                                      ),
                                      inputFormatters: [
                                        FilteringTextInputFormatter.digitsOnly,
                                        LengthLimitingTextInputFormatter(10),
                                      ],
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return AppLocalizations.of(context)!.emptyMobileValidation;
                                        } else if (value.length != 10) {
                                          return AppLocalizations.of(context)!.mobileDigitValidation;
                                        }
                                        return null;
                                      },
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 18),
                              // Password Label
                              Text(
                                AppLocalizations.of(context)!.passwordHintText,
                                style: Constants.AppTypography.label.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Constants.AppColors.ink,
                                ),
                              ),
                              const SizedBox(height: 8),
                              // Password Input
                              TextFormField(
                                controller: passwordController,
                                obscureText: !_isPasswordVisible,
                                style: Constants.AppTypography.body.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                                decoration: InputDecoration(
                                  hintText: AppLocalizations.of(context)!.passwordHintText,
                                  hintStyle: Constants.AppTypography.body.copyWith(
                                    color: Constants.AppColors.inkSoft,
                                  ),
                                  filled: true,
                                  fillColor: Constants.AppColors.surface,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(Constants.AppRadii.sm),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(Constants.AppRadii.sm),
                                    borderSide: const BorderSide(color: Constants.AppColors.border),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(Constants.AppRadii.sm),
                                    borderSide: const BorderSide(color: Constants.AppColors.brand, width: 1.5),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                    vertical: 0,
                                    horizontal: 14,
                                  ),
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
                            ],
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Button to continue
                        SizedBox(
                          height: 52,
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _isButtonDisabled
                                ? null
                                : () async {
                                    if (_formKey.currentState?.validate() ?? false) {
                                      await _submitForm();
                                    }
                                  },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Constants.AppColors.brand,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(Constants.AppRadii.sm),
                              ),
                              elevation: 0,
                            ),
                            child: Text(
                              AppLocalizations.of(context)!.login,
                              style: Constants.AppTypography.h2.copyWith(
                                color: Constants.AppColors.card,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Register Now Link
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => RegistrationForm(),
                        ),
                      );
                    },
                    child: Text(
                      AppLocalizations.of(context)!.registernow,
                      style: Constants.AppTypography.subhead.copyWith(
                        color: Constants.AppColors.brandDeep,
                        fontWeight: FontWeight.bold,
                        decoration: TextDecoration.underline,
                        decorationColor: Constants.AppColors.brandDeep,
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Terms & Conditions
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: RichText(
                      text: TextSpan(
                        text: AppLocalizations.of(context)!.termsAndCondition,
                        style: Constants.AppTypography.label.copyWith(
                          height: 1.5,
                          color: Constants.AppColors.inkSoft,
                        ),
                        children: [
                          TextSpan(
                            text: AppLocalizations.of(context)!.termsAndCondition2,
                            style: const TextStyle(
                              color: Colors.blue,
                              decoration: TextDecoration.underline,
                            ),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => MyWebView(),
                                  ),
                                );
                              },
                          ),
                          TextSpan(
                            text: AppLocalizations.of(context)!.purnViram,
                            style: Constants.AppTypography.label.copyWith(
                              height: 1.5,
                              color: Constants.AppColors.inkSoft,
                            ),
                          ),
                        ],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
