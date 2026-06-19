// import 'dart:async';
// import 'dart:developer' as developer;
// import 'dart:convert';
// import 'dart:io';
// import 'package:greencollar/l10n/app_localizations.dart';
// import 'package:greencollar/labournoti.dart';
// import 'package:permission_handler/permission_handler.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:geocoding/geocoding.dart';
//
// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:carousel_slider/carousel_slider.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_secure_storage/flutter_secure_storage.dart';
// import 'package:greencollar/Addproject.dart';
// import 'package:greencollar/HomeScree.dart';
// import 'package:greencollar/NearbyFarmers.dart';
// import 'package:greencollar/NearbyProject.dart';
// import 'package:greencollar/Nearbylabours.dart';
// import 'package:greencollar/main.dart';
// import 'package:greencollar/updateprofile.dart';
// import 'package:provider/provider.dart';
// import 'package:http/http.dart' as http;
// import 'package:url_launcher/url_launcher.dart';
// import 'package:greencollar/constants.dart' as Constants;
// import 'package:google_fonts/google_fonts.dart';
// import 'package:translator/translator.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:greencollar/wallet_helper.dart';
// import 'package:intl/intl.dart';
// import 'package:greencollar/speech_helper.dart';
// import 'package:greencollar/api_logger.dart';
//
// class TranslationService {
//   final GoogleTranslator _translator = GoogleTranslator();
//
//   // ✅ Cache translations to avoid duplicate API calls
//   Map<String, Map<String, String>> _cachedTranslations = {};
//
//   // ✅ Predefined manual translations (Higher Priority than API)
//   Map<String, Map<String, String>> translations = {
//     // Add more manual translations here...
//   };
//
//   /// ✅ Fetch translations from API and update the cache
//   Future<Map<String, Map<String, String>>> fetchTranslations() async {
//     try {
//       final response = await http.post(
//           Uri.parse('${Constants.AppConstants.apiUrl}farmer/getTranslations'));
//
//       if (response.statusCode == 200) {
//         final jsonData = jsonDecode(response.body);
//
//         if (jsonData['status'] == 1) {
//           List<dynamic> data = jsonData['data'];
//           Map<String, Map<String, String>> translations = {};
//
//           for (var item in data) {
//             String text = item['text'];
//             String lang = item['lang'];
//             String translation = item['translation'];
//
//             // ✅ Initialize default values if text is not in the map
//             if (!translations.containsKey(text)) {
//               translations[text] = {
//                 "en": text,
//                 "hi": text
//               }; // Default both to the same value
//             }
//
//             // ✅ Store the translation in the correct language
//             translations[text]![lang] = translation;
//           }
//
//           // ✅ Store fetched translations in the cache
//           _cachedTranslations = translations;
//
//           // ✅ Check for missing translations and fetch dynamically
//           for (var text in translations.keys) {
//             if (!translations[text]!.containsKey("hi")) {
//               _fetchTranslation(text, "hi");
//             }
//             if (!translations[text]!.containsKey("en")) {
//               _fetchTranslation(text, "en");
//             }
//           }
//
//           return translations;
//         } else {
//           throw Exception(
//               "Failed to load translations: ${jsonData['message']}");
//         }
//       } else {
//         throw Exception("API Error: ${response.statusCode}");
//       }
//     } catch (e) {
//       print("Error fetching translations: $e");
//       return {};
//     }
//   }
//
//   /// ✅ Main function to translate text
//   String translateText(String text, {String targetLang = 'hi'}) {
//     if (text.isEmpty) return "";
//
//     // ✅ Check manual translations first
//     if (translations.containsKey(text) &&
//         translations[text]!.containsKey(targetLang)) {
//       return translations[text]![targetLang]!; // Return manual translation
//     }
//
//     // ✅ Check cached translations
//     if (_cachedTranslations.containsKey(text) &&
//         _cachedTranslations[text]!.containsKey(targetLang)) {
//       return _cachedTranslations[text]![
//       targetLang]!; // Return cached translation
//     }
//
//     // ✅ Fetch translation dynamically if missing
//     _fetchTranslation(text, targetLang);
//
//     return text; // Return original text while waiting for translation
//   }
//
//   /// ✅ Fetch translation dynamically and update cache
//   Future<void> _fetchTranslation(String text, String targetLang) async {
//     try {
//       final translation = await _translator.translate(text, to: targetLang);
//
//       // ✅ Store translation in cache
//       _cachedTranslations.putIfAbsent(text, () => {})[targetLang] =
//           translation.text;
//     } catch (e) {
//       print("Translation error: $e");
//     }
//   }
// }
//
// class Labourhomepage extends StatefulWidget {
//   @override
//   _LabourhomepageState createState() => _LabourhomepageState();
// }
//
// class _LabourhomepageState extends State<Labourhomepage> {
//   int _currentIndex = 0;
//   final _secureStorage = const FlutterSecureStorage();
//   String _selectedLanguage = 'en'; // Default language is English
//   String _userName = '';
//   String _userType = '';
//   int _walletCoins = 0;
//
//   Future<void> _loadUserInfo() async {
//     String? name = await _secureStorage.read(key: 'name');
//     String? userType = await _secureStorage.read(key: 'userType');
//     setState(() {
//       _userName = name ?? '';
//       _userType = userType ?? 'labour';
//     });
//   }
//
//   Future<void> loadLanguage() async {
//     await fetchUnreadNotificationsCount();
//
//     // Read the selected language from FlutterSecureStorage
//     String? language = await _secureStorage.read(key: 'selectedLanguage');
//     _selectedLanguage = language ?? 'en';
//   }
//
//   int unreadNotificationsCount = 0; // To store unread notifications count
//   @override
//   void initState() {
//     super.initState();
//     loadLanguage();
//     _loadUserInfo();
//     _loadWalletBalance();
//     ApiLogger.logScreenOpened('LabourHomepage');
//   }
//
//   Future<void> _loadWalletBalance() async {
//     int coins = await WalletHelper.getCoins();
//     if (mounted) {
//       setState(() => _walletCoins = coins);
//     }
//   }
//
//   // Pages for navigation
//   final List<Widget> _pages = [
//     LabourHomepage(),
//     FarmerPage(),
//     NearbyProjectPage(),
//   ];
//   Future<void> _logout(BuildContext context) async {
//     await _secureStorage.delete(key: 'id'); // Clear the user ID from storage
//     Navigator.pushReplacement(
//       context,
//       MaterialPageRoute(builder: (context) => const LoginScreen()),
//     );
//   }
//
//   Future<void> fetchUnreadNotificationsCount() async {
//     print("Fetching unread notifications count...");
//
//     // Retrieve the userId from secure storage
//     String? userId = await _secureStorage.read(key: 'id');
//     if (userId == null) {
//       // Handle case if user id is not found
//       print('User ID not found.');
//       return;
//     }
//
//     // Construct the URL for the API call
//     final url = Uri.parse(
//         '${Constants.AppConstants.apiUrl}farmer/getlabourUnreadNotificationsCount');
//     print('URL: $url');
//
//     // Print the request body
//     print('Request Body: {\'id\': $userId}');
//
//     try {
//       print(url);
//       final response = await http.post(
//         url,
//         body: {
//           'id': userId, // Sending userId as part of the request body
//         },
//       );
//
//       print('Response Sttatus: ${response.statusCode}');
//       print('Response Body: ${response.body}');
//
//       if (response.statusCode == 200) {
//         final responseData = json.decode(response.body);
//         if (responseData['status'] == 'success') {
//           setState(() {
//             unreadNotificationsCount =
//             responseData['unread_notifications_count'];
//             print('Unread notifications count: $unreadNotificationsCount');
//           });
//         } else {
//           // Handle case where the response is not success
//           print(
//               'Failed to fetch notifications count: ${responseData['message']}');
//         }
//       } else {
//         // Handle case when the server response is not 200 (OK)
//         print('Failed to connect to the server: ${response.statusCode}');
//       }
//     } catch (e) {
//       print('Error: $e');
//     }
//   }
//
//   @override
//   @override
//   Widget build(BuildContext context) {
//     return WillPopScope(
//       onWillPop: () async {
//         SystemNavigator.pop();
//         return false;
//       },
//       child: Scaffold(
//         extendBody: true,
//         backgroundColor: Constants.AppColors.surface,
//         appBar: AppBar(
//           title: _currentIndex == 0
//               ? Row(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               Container(
//                 padding: const EdgeInsets.symmetric(
//                     horizontal: 8, vertical: 3),
//                 decoration: BoxDecoration(
//                   color: Colors.white.withOpacity(0.20),
//                   borderRadius: BorderRadius.circular(12),
//                   border: Border.all(color: Colors.white30, width: 0.5),
//                 ),
//                 child: Text(
//                   _selectedLanguage == 'en' ? 'Worker' : 'श्रमिक',
//                   style: Constants.AppTypography.micro.copyWith(
//                     color: Colors.white,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//               ),
//             ],
//           )
//               : Text(
//             _currentIndex == 1
//                 ? AppLocalizations.of(context)!.nearbyFarmers
//                 : _currentIndex == 2
//                 ? AppLocalizations.of(context)!.find_Work
//                 : 'Default Title',
//             style: Constants.AppTypography.h2.copyWith(color: Colors.white),
//           ),
//           iconTheme: const IconThemeData(color: Colors.white),
//           flexibleSpace: Container(
//             decoration: const BoxDecoration(
//               gradient: Constants.AppColors.brandGradient,
//             ),
//           ),
//           elevation: 0,
//           actions: [
//             // Wallet coin button
//             WalletHelper.buildWalletButton(
//               coinBalance: _walletCoins,
//               onTap: () {
//                 WalletHelper.showCoinShop(context, onCoinsAdded: (newBalance) {
//                   setState(() => _walletCoins = newBalance);
//                 });
//               },
//             ),
//             IconButton(
//               icon: Stack(
//                 children: [
//                   const Icon(Icons.notifications),
//                   if (unreadNotificationsCount > 0)
//                     Positioned(
//                       right: 0,
//                       top: 0,
//                       child: CircleAvatar(
//                         radius: 8,
//                         backgroundColor: Colors.red,
//                         child: Text(
//                           unreadNotificationsCount.toString(),
//                           style: const TextStyle(
//                             fontSize: 10,
//                             color: Colors.white,
//                           ),
//                         ),
//                       ),
//                     ),
//                 ],
//               ),
//               onPressed: () {
//                 Navigator.pushReplacement(
//                   context,
//                   MaterialPageRoute(builder: (context) => LabourNotification()),
//                 );
//               },
//             ),
//           ],
//         ),
//         drawer: Drawer(
//           backgroundColor: Constants.AppColors.surface,
//           child: Container(
//             color: Constants.AppColors.surface,
//             child: ListView(
//               padding: EdgeInsets.zero,
//               children: [
//                 DrawerHeader(
//                   decoration: const BoxDecoration(
//                     gradient: Constants.AppColors.brandGradient,
//                   ),
//                   child: Row(
//                     crossAxisAlignment: CrossAxisAlignment.center,
//                     children: [
//                       CircleAvatar(
//                         radius: 30,
//                         backgroundColor: Colors.white,
//                         child: Text(
//                           _userName.isNotEmpty ? _userName[0].toUpperCase() : 'U',
//                           style: TextStyle(
//                             color: Constants.AppColors.brand,
//                             fontSize: 28,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                       ),
//                       const SizedBox(width: 16),
//                       Expanded(
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           mainAxisAlignment: MainAxisAlignment.center,
//                           children: [
//                             Text(
//                               _userName.isNotEmpty ? _userName : 'User',
//                               style: Constants.AppTypography.h2.copyWith(color: Colors.white),
//                               overflow: TextOverflow.ellipsis,
//                             ),
//                             const SizedBox(height: 4),
//                             Container(
//                               padding: const EdgeInsets.symmetric(
//                                   horizontal: 8, vertical: 4),
//                               decoration: BoxDecoration(
//                                 color: Colors.white24,
//                                 borderRadius: BorderRadius.circular(12),
//                               ),
//                               child: Text(
//                                 _userType == 'labour'
//                                     ? (context.watch<LanguageProvider>().selectedLanguage == 'en' ? 'Worker' : 'श्रमिक')
//                                     : (context.watch<LanguageProvider>().selectedLanguage == 'en' ? 'Farmer' : 'किसान'),
//                                 style: Constants.AppTypography.micro.copyWith(color: Colors.white),
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//                 ListTile(
//                   leading: const Icon(Icons.home, color: Constants.AppColors.brand),
//                   title: Text(
//                     context.watch<LanguageProvider>().selectedLanguage == 'en'
//                         ? 'Home'
//                         : 'घर',
//                     style: Constants.AppTypography.body.copyWith(fontWeight: FontWeight.bold),
//                   ),
//                   onTap: () {
//                     setState(() {
//                       _currentIndex = 0;
//                     });
//                     Navigator.pop(context);
//                   },
//                 ),
//                 ListTile(
//                   leading: const Icon(Icons.notifications, color: Constants.AppColors.brand),
//                   title: Text(
//                     context.watch<LanguageProvider>().selectedLanguage == 'en'
//                         ? 'Notifications'
//                         : 'सूचनाएं',
//                     style: Constants.AppTypography.body.copyWith(fontWeight: FontWeight.bold),
//                   ),
//                   trailing: unreadNotificationsCount > 0
//                       ? Padding(
//                     padding: const EdgeInsets.only(left: 8.0),
//                     child: CircleAvatar(
//                       radius: 10,
//                       backgroundColor: Colors.red,
//                       child: Text(
//                         unreadNotificationsCount.toString(),
//                         style: const TextStyle(
//                           fontSize: 10,
//                           color: Colors.white,
//                         ),
//                       ),
//                     ),
//                   )
//                       : null,
//                   onTap: () {
//                     Navigator.pushReplacement(
//                       context,
//                       MaterialPageRoute(
//                           builder: (context) => LabourNotification()),
//                     );
//                   },
//                 ),
//                 ListTile(
//                   leading: const Icon(Icons.language, color: Constants.AppColors.brand),
//                   title: Text(
//                     context.watch<LanguageProvider>().selectedLanguage == 'en'
//                         ? 'Language'
//                         : 'भाषा चुने',
//                     style: Constants.AppTypography.body.copyWith(fontWeight: FontWeight.bold),
//                   ),
//                   onTap: () {
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                         builder: (context) => LanguageSelectionScreen(),
//                       ),
//                     );
//                   },
//                 ),
//                 ListTile(
//                   leading: const Icon(Icons.notes, color: Constants.AppColors.brand),
//                   title: Text(
//                     context.watch<LanguageProvider>().selectedLanguage == 'en'
//                         ? 'My Projects'
//                         : 'मेरी परियोजनाएं',
//                     style: Constants.AppTypography.body.copyWith(fontWeight: FontWeight.bold),
//                   ),
//                   onTap: () {
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                         builder: (context) => AppliedProjects(),
//                       ),
//                     );
//                   },
//                 ),
//                 ListTile(
//                   leading: const Icon(Icons.person, color: Constants.AppColors.brand),
//                   title: Text(
//                     context.watch<LanguageProvider>().selectedLanguage == 'en'
//                         ? 'Profile'
//                         : 'प्रोफ़ाइल',
//                     style: Constants.AppTypography.body.copyWith(fontWeight: FontWeight.bold),
//                   ),
//                   onTap: () {
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                         builder: (context) => const UpdateLabourProfile(),
//                       ),
//                     );
//                   },
//                 ),
//                 ListTile(
//                   leading: Icon(Icons.logout, color: Colors.red[700]),
//                   title: Text(
//                     context.watch<LanguageProvider>().selectedLanguage == 'en'
//                         ? 'Logout'
//                         : 'लॉग आउट',
//                     style: Constants.AppTypography.body.copyWith(
//                       color: Colors.red[700],
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                   onTap: () => _logout(context),
//                 ),
//               ],
//             ),
//           ),
//         ),
//         body: _pages[_currentIndex],
//         bottomNavigationBar: Padding(
//           padding: const EdgeInsets.only(left: 12.0, right: 12.0, bottom: 12.0),
//           child: Container(
//             decoration: const BoxDecoration(
//               gradient: Constants.AppColors.brandGradient,
//               borderRadius: BorderRadius.only(
//                 topLeft: Radius.circular(28),
//                 topRight: Radius.circular(28),
//                 bottomLeft: Radius.circular(28),
//                 bottomRight: Radius.circular(28),
//               ),
//               boxShadow: [Constants.AppShadows.fab],
//             ),
//             child: ClipRRect(
//               borderRadius: BorderRadius.circular(28),
//               child: BottomNavigationBar(
//                 backgroundColor: Colors.transparent,
//                 currentIndex: _currentIndex,
//                 selectedItemColor: Colors.white,
//                 unselectedItemColor: Colors.white70,
//                 selectedLabelStyle: Constants.AppTypography.label.copyWith(
//                   color: Colors.white,
//                   fontWeight: FontWeight.bold,
//                 ),
//                 unselectedLabelStyle: Constants.AppTypography.label.copyWith(
//                   color: Colors.white70,
//                 ),
//                 showUnselectedLabels: false,
//                 elevation: 0,
//                 type: BottomNavigationBarType.fixed,
//                 items: [
//                   BottomNavigationBarItem(
//                       icon: const Icon(Icons.home),
//                       label: AppLocalizations.of(context)!.homepage),
//                   BottomNavigationBarItem(
//                       icon: const Icon(Icons.search),
//                       label: AppLocalizations.of(context)!.nearbyFarmers),
//                   BottomNavigationBarItem(
//                       icon: const Icon(Icons.work_outline),
//                       label: AppLocalizations.of(context)!.find_Work),
//                 ],
//                 onTap: (index) {
//                   setState(() {
//                     _currentIndex = index;
//                   });
//                   final pages = ['LabourHomepage', 'FarmerPage', 'NearbyProjectPage'];
//                   if (index >= 0 && index < pages.length) {
//                     ApiLogger.logScreenOpened(pages[index]);
//                   }
//                 },
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
//
// class LabourHomepage extends StatefulWidget {
//   @override
//   _LabourHomepageState createState() => _LabourHomepageState();
// }
//
// class _LabourHomepageState extends State<LabourHomepage> with WidgetsBindingObserver {
//   static String _cachedCity = '';
//   static String _cachedState = '';
//   static String _cachedError = '';
//
//   // Location state variables
//   String _currentCity = '';
//   String _currentState = '';
//   bool _isLoadingLocation = true;
//   String _locationError = '';
//
//   FlutterSecureStorage _secureStorage = FlutterSecureStorage();
//   final TextEditingController _projectSearchController =
//   TextEditingController();
//   final TextEditingController _labourSearchController = TextEditingController();
//   final GoogleTranslator _translator = GoogleTranslator();
//
//   List<dynamic> projects = [];
//   List<dynamic> filteredProjects = [];
//   bool isLoading = false;
//   List<JobType> _jobTypes = [];
//   late Timer _timer;
//
//   String? _selectedCategoryFilter;
//
//   bool _matchesJobTitle(String jobTitle, String filter) {
//     final cleanTitle = jobTitle.trim().toLowerCase();
//     final cleanFilter = filter.trim().toLowerCase();
//
//     if (cleanFilter == 'farming' || cleanFilter == 'crop farming') {
//       return cleanTitle == 'farming' || cleanTitle == 'crop farming';
//     }
//
//     if (cleanTitle == cleanFilter) {
//       return true;
//     }
//
//     return cleanTitle.contains(cleanFilter) || cleanFilter.contains(cleanTitle);
//   }
//
//   void _updateFilteredProjects() {
//     if (_selectedCategoryFilter == null) {
//       filteredProjects = projects;
//     } else {
//       filteredProjects = projects.where((project) {
//         final jobTitle = project['job_title']?.toString() ?? '';
//         return _matchesJobTitle(jobTitle, _selectedCategoryFilter!);
//       }).toList();
//     }
//   }
//
//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addObserver(this);
//     loadLanguage();
//     fetchJobTypes();
//     fetchProjects();
//     _fetchCurrentLocation();
//   }
//
//   @override
//   void dispose() {
//     WidgetsBinding.instance.removeObserver(this);
//     super.dispose();
//   }
//
//   @override
//   void didChangeAppLifecycleState(AppLifecycleState state) {
//     if (state == AppLifecycleState.resumed) {
//       _fetchCurrentLocation(force: true);
//     }
//   }
//
//   Future<void> _fetchCurrentLocation({bool force = false}) async {
//     if (!force && (_cachedCity.isNotEmpty || _cachedState.isNotEmpty)) {
//       if (mounted) {
//         setState(() {
//           _currentCity = _cachedCity;
//           _currentState = _cachedState;
//           _isLoadingLocation = false;
//           _locationError = _cachedError;
//         });
//       }
//       return;
//     }
//
//     try {
//       bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
//       if (!serviceEnabled) {
//         if (mounted) {
//           setState(() {
//             _isLoadingLocation = false;
//             _locationError = 'Location services are disabled';
//           });
//         }
//         return;
//       }
//
//       LocationPermission permission = await Geolocator.checkPermission();
//       if (permission == LocationPermission.denied) {
//         permission = await Geolocator.requestPermission();
//         if (permission == LocationPermission.denied) {
//           if (mounted) {
//             setState(() {
//               _isLoadingLocation = false;
//               _locationError = 'Location permission denied';
//             });
//           }
//           return;
//         }
//       }
//
//       if (permission == LocationPermission.deniedForever) {
//         if (mounted) {
//           setState(() {
//             _isLoadingLocation = false;
//             _locationError = 'Location permission permanently denied';
//           });
//         }
//         return;
//       }
//
//       // Get current position
//       Position position = await Geolocator.getCurrentPosition(
//         desiredAccuracy: LocationAccuracy.high,
//       );
//
//       // Reverse geocode to get city and state
//       List<Placemark> placemarks = await placemarkFromCoordinates(
//         position.latitude,
//         position.longitude,
//       );
//
//       if (placemarks.isNotEmpty && mounted) {
//         Placemark place = placemarks[0];
//         _cachedCity = place.locality ?? place.subAdministrativeArea ?? '';
//         _cachedState = place.administrativeArea ?? '';
//         _cachedError = '';
//         setState(() {
//           _currentCity = _cachedCity;
//           _currentState = _cachedState;
//           _isLoadingLocation = false;
//         });
//       }
//     } catch (e) {
//       print('Error fetching location: $e');
//       _cachedError = 'Unable to fetch location';
//       if (mounted) {
//         setState(() {
//           _isLoadingLocation = false;
//           _locationError = _cachedError;
//         });
//       }
//     }
//   }
//
//   Map<String, Map<String, String>> _cachedTranslations = {};
//
//   Map<String, Map<String, String>> translations =
//       Constants.AppConstants.translations;
//   String _selectedLanguage = 'en'; // Default language is English
//
//   Future<void> downloadTranslations() async {
//     try {
//       var status = await Permission.storage.status;
//       if (!status.isGranted) {
//         await Permission.storage.request();
//       }
//
//       // Specify the destination path
//       final destinationPath = '/storage/emulated/0/Download/Invoice';
//       final destinationDir = Directory(destinationPath);
//
//       // Ensure the destination directory exists
//       await destinationDir.create(recursive: true);
//
//       // ✅ Define the folder inside the directory
//       final folderPath = '${destinationDir.path}/Appointment_Details';
//       final folder = Directory(folderPath);
//
//       // ✅ Create folder if it doesn't exist
//       if (!await folder.exists()) {
//         await folder.create(recursive: true);
//       }
//
//       // ✅ Define file path
//       final filePath = '$folderPath/translations.txt';
//       final file = File(filePath);
//
//       // ✅ Convert translations Map to readable text format
//       StringBuffer buffer = StringBuffer();
//       translations.forEach((key, value) {
//         buffer.writeln("$key: ${value.toString()}");
//       });
//
//       // ✅ Write to file
//       await file.writeAsString(buffer.toString());
//
//       // ✅ Print full file path
//       print("✅ Translations saved at: ${file.absolute.path}");
//     } catch (e) {
//       print("❌ Error saving translations: $e");
//     }
//   }
//
//   Future<void> loadLanguage() async {
//     // Read the selected language from FlutterSecureStorage
//     String? language = await _secureStorage.read(key: 'selectedLanguage');
//     _selectedLanguage = language ?? 'en';
//     print(language); // Default to English if null
//   }
//
//   Future<Map<String, Map<String, String>>> fetchTranslations() async {
//     try {
//       final response = await http.post(
//           Uri.parse('${Constants.AppConstants.apiUrl}farmer/getTranslations'));
//
//       if (response.statusCode == 200) {
//         final jsonData = jsonDecode(response.body);
//
//         if (jsonData['status'] == 1) {
//           List<dynamic> data = jsonData['data'];
//
//           for (var item in data) {
//             String text = item['text'];
//             String lang = item['lang'];
//             String translation = item['translation'];
//
//             // ✅ Initialize default values if text is not in the map
//             if (!translations.containsKey(text)) {
//               translations[text] = {
//                 "en": text,
//                 "hi": text
//               }; // Default both to the same value
//             }
//
//             // ✅ Store the translation in the correct language
//             translations[text]![lang] = translation;
//           }
//
//           // ✅ Store fetched translations in the cache
//           _cachedTranslations = translations;
//
//           // ✅ Check for missing translations and fetch dynamically
//           for (var text in translations.keys) {
//             if (!translations[text]!.containsKey("hi")) {
//               _fetchTranslation(text, "hi");
//             }
//             if (!translations[text]!.containsKey("en")) {
//               _fetchTranslation(text, "en");
//             }
//           }
//
//           return translations;
//         } else {
//           throw Exception(
//               "Failed to load translations: ${jsonData['message']}");
//         }
//       } else {
//         throw Exception("API Error: ${response.statusCode}");
//       }
//     } catch (e) {
//       print("Error fetching translations: $e");
//       return {};
//     }
//   }
//
//   /// ✅ Main function to translate text
//   String translateText(String text) {
//     if (text.isEmpty) return "";
//
//     // ✅ Ensure `_selectedLanguage` is set before calling `translateText()`
//     String targetLang = _selectedLanguage ?? 'en'; // Default to English if null
//
//     // ✅ Check manual translations first
//     if (translations.containsKey(text) &&
//         translations[text]!.containsKey(targetLang)) {
//       return translations[text]![targetLang]!; // Return manual translation
//     }
//
//     // ✅ Check cached translations
//     if (_cachedTranslations.containsKey(text) &&
//         _cachedTranslations[text]!.containsKey(targetLang)) {
//       return _cachedTranslations[text]![
//       targetLang]!; // Return cached translation
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
//   Future<void> fetchJobTypes() async {
//     final response = await http
//         .post(Uri.parse('${Constants.AppConstants.apiUrl}farmer/jobtype'));
//
//     if (response.statusCode == 200) {
//       final Map<String, dynamic> data = json.decode(response.body);
//       List<dynamic> jobData = data['data'];
//       setState(() {
//         _jobTypes = jobData.map((job) => JobType.fromJson(job)).toList();
//       });
//     } else {
//       throw Exception('Failed to load job types');
//     }
//   }
//
//   Future<void> fetchProjects() async {
//     final String apiUrl =
//         '${Constants.AppConstants.apiUrl}labour/nearbyProjectApi';
//     String? userId = await _secureStorage.read(key: 'id');
//     if (userId == null) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('User ID not found in secure storage')),
//       );
//       return;
//     }
//
//     try {
//       setState(() {
//         isLoading = true;
//       });
//
//       final Map<String, dynamic> requestBody = {
//         'id': userId,
//       };
//
//       final response = await http.post(
//         Uri.parse(apiUrl),
//         headers: {'Content-Type': 'application/json'},
//         body: jsonEncode(requestBody),
//       );
//
//       developer.log('Nearby Projects API Status: ${response.statusCode}', name: 'greencollar.api');
//       developer.log('Nearby Projects API Response: ${response.body}', name: 'greencollar.api');
//
//       if (response.statusCode == 200) {
//         final responseBody = json.decode(response.body);
//         if (responseBody['status'] == 1) {
//           setState(() {
//             projects = responseBody['data'];
//             _updateFilteredProjects();
//             isLoading = false;
//           });
//         } else {
//           setState(() {
//             projects = [];
//             _updateFilteredProjects();
//             isLoading = false;
//           });
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(
//                 content: Text(
//                     responseBody['message'] ?? 'Failed to fetch projects')),
//           );
//         }
//       } else {
//         setState(() {
//           isLoading = false;
//         });
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//               content:
//               Text('Failed to fetch projects: ${response.statusCode}')),
//         );
//       }
//     } catch (e) {
//       setState(() {
//         isLoading = false;
//       });
//     }
//   }
//
//   int _currentIndex = 0; // To track the current index of the carousel
//   final PageController _pageController = PageController();
//   String selectedCategory = 'All';
//   double selectedPriceRange = 1000000;
//   double selectedRating = 3;
//   String selectedJobType = 'All';
//   bool isDailyWageSelected = false;
//   bool isContractSelected = false;
//
//   void _showFilterDialog() {
//     showDialog(
//       context: context,
//       builder: (context) => StatefulBuilder(
//         builder: (context, setStateDialog) {
//           return AlertDialog(
//             title: Text(translateText('Filter Projects')),
//             content: SingleChildScrollView(
//               child: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   Padding(
//                     padding: const EdgeInsets.symmetric(vertical: 8.0),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(translateText('Select Job Type')),
//                         DropdownButton<String>(
//                           value: selectedJobType,
//                           isExpanded: true,
//                           items: [
//                             DropdownMenuItem<String>(
//                               value: 'All',
//                               child: Text(translateText('All')),
//                             ),
//                             ..._jobTypes
//                                 .map((job) => DropdownMenuItem<String>(
//                               value: job.jobname,
//                               child: Text(translateText(job.jobname)),
//                             ))
//                                 .toList(),
//                           ],
//                           onChanged: (value) {
//                             setStateDialog(() {
//                               selectedJobType = value!;
//                             });
//                           },
//                         ),
//                       ],
//                     ),
//                   ),
//                   const SizedBox(height: 10),
//                   Padding(
//                     padding: const EdgeInsets.symmetric(vertical: 8.0),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(translateText('Select Payment Type')),
//                         DropdownButton<String>(
//                           value: selectedCategory,
//                           isExpanded: true,
//                           items: ['All', 'Project Basis', 'Milestone Basis']
//                               .map((category) => DropdownMenuItem<String>(
//                             value: category,
//                             child: Text(translateText(category)),
//                           ))
//                               .toList(),
//                           onChanged: (value) {
//                             setStateDialog(() {
//                               selectedCategory = value!;
//                             });
//                           },
//                         ),
//                       ],
//                     ),
//                   ),
//                   const SizedBox(height: 10),
//                   Padding(
//                     padding: const EdgeInsets.all(16.0),
//                     child: TextField(
//                       controller: _labourSearchController,
//                       decoration: InputDecoration(
//                         prefixIcon:
//                         const Icon(Icons.search, color: Colors.green),
//                         suffixIcon: MicIconButton(controller: _labourSearchController),
//                         hintText:
//                         translateText('Search by pincode, city, or state'),
//                         fillColor: Colors.white,
//                         filled: true,
//                         border: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(15.0),
//                           borderSide: const BorderSide(color: Colors.green),
//                         ),
//                         focusedBorder: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(15.0),
//                           borderSide:
//                           const BorderSide(color: Colors.green, width: 2),
//                         ),
//                       ),
//                     ),
//                   ),
//                   Padding(
//                     padding: const EdgeInsets.symmetric(vertical: 8.0),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(translateText('Select Budget Range')),
//                         Slider(
//                           value: selectedPriceRange,
//                           min: 0,
//                           max: 1000000,
//                           divisions: 100,
//                           label: '\$${selectedPriceRange.toStringAsFixed(0)}',
//                           onChanged: (value) {
//                             setStateDialog(() {
//                               selectedPriceRange = value;
//                             });
//                           },
//                         ),
//                       ],
//                     ),
//                   ),
//                   const SizedBox(height: 10),
//                   Padding(
//                     padding: const EdgeInsets.symmetric(vertical: 8.0),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(translateText('Select Job Type')),
//                         Row(
//                           children: [
//                             Checkbox(
//                               value: isDailyWageSelected,
//                               onChanged: (bool? value) {
//                                 setStateDialog(() {
//                                   isDailyWageSelected = value!;
//                                 });
//                               },
//                             ),
//                             Text(translateText('Daily Wage')),
//                             const SizedBox(width: 10),
//                             Checkbox(
//                               value: isContractSelected,
//                               onChanged: (bool? value) {
//                                 setStateDialog(() {
//                                   isContractSelected = value!;
//                                 });
//                               },
//                             ),
//                             Text(translateText('Contract')),
//                           ],
//                         ),
//                       ],
//                     ),
//                   ),
//                   const SizedBox(height: 10),
//                 ],
//               ),
//             ),
//             actions: [
//               TextButton(
//                 onPressed: () {
//                   _applyFilters();
//                   setState(() {});
//                   Navigator.of(context).pop();
//                 },
//                 child: Text(translateText('Apply Filters')),
//               ),
//               TextButton(
//                 onPressed: () {
//                   setStateDialog(() {
//                     selectedJobType = 'All';
//                     selectedCategory = 'All';
//                     selectedPriceRange = 1000000;
//                     isDailyWageSelected = false;
//                     isContractSelected = false;
//                     _labourSearchController.clear();
//                   });
//                   setState(() {
//                     _selectedCategoryFilter = null;
//                   });
//                 },
//                 child: Text(translateText('Reset Filters'),
//                     style: const TextStyle(color: Colors.red)),
//               ),
//             ],
//           );
//         },
//       ),
//     );
//   }
//
//   Future<void> _applyFilters() async {
//     String? userId = await _secureStorage.read(key: 'id');
//     if (userId == null) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('User ID not found in secure storage')),
//       );
//       return;
//     }
//     _selectedCategoryFilter = null;
//     Map<String, dynamic> filters = {
//       'id': userId,
//       'job_type': selectedJobType,
//       'category': selectedCategory,
//       'search': _labourSearchController.text,
//       'budget': selectedPriceRange.toInt(),
//       'dailyWage': isDailyWageSelected,
//       'contract': isContractSelected,
//     };
//
//     fetchFilteredProjects(filters);
//   }
//
//   Future<void> fetchFilteredProjects(Map<String, dynamic> filters) async {
//     final String apiUrl =
//         '${Constants.AppConstants.apiUrl}labour/searchProjectsApi';
//     String? userId = await _secureStorage.read(key: 'id');
//     if (userId == null) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('User ID not found in secure storage')),
//       );
//       return;
//     }
//     print(jsonEncode(filters));
//     try {
//       setState(() {
//         isLoading = true;
//       });
//
//       final response = await http.post(
//         Uri.parse(apiUrl),
//         headers: {'Content-Type': 'application/json'},
//         body: json.encode(filters),
//       );
//
//       developer.log('Filtered Projects API Status: ${response.statusCode}', name: 'greencollar.api');
//       developer.log('Filtered Projects API Response: ${response.body}', name: 'greencollar.api');
//
//       if (response.statusCode == 200) {
//         final responseBody = json.decode(response.body);
//         if (responseBody['status'] == 1) {
//           setState(() {
//             projects = responseBody['data'];
//             _updateFilteredProjects();
//             isLoading = false;
//           });
//         } else {
//           setState(() {
//             projects = [];
//             _updateFilteredProjects();
//             isLoading = false;
//           });
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(
//                 content: Text(
//                     responseBody['message'] ?? 'Failed to fetch projects')),
//           );
//         }
//       } else {
//         setState(() {
//           isLoading = false;
//         });
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//               content:
//               Text('Failed to fetch projects: ${response.statusCode}')),
//         );
//       }
//     } catch (e) {
//       setState(() {
//         isLoading = false;
//       });
//     }
//   }
//
//   final List<String> imageUrls = [
//     'assets/slider1.png',
//     'assets/slider2.png',
//     'assets/slider4.jpg',
//     'assets/slider3.png',
//     'assets/slider5.png',
//   ];
//
//   Widget _buildChip({
//     required IconData icon,
//     required String label,
//     required Color bgColor,
//     required Color textColor,
//     required Color iconColor,
//   }) {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
//       decoration: BoxDecoration(
//         color: bgColor,
//         borderRadius: BorderRadius.circular(8),
//       ),
//       child: Row(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Icon(icon, size: 14, color: iconColor),
//           const SizedBox(width: 4),
//           Text(
//             label,
//             style: TextStyle(
//               color: textColor,
//               fontWeight: FontWeight.w600,
//               fontSize: 12,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   // ─────────────────────────────────────────────────────────────────────────
//   // CHANGED: _buildStatusBadge now matches the "View Details" button style
//   // – same padding (horizontal:12, vertical:8), same borderRadius(8),
//   //   same border approach, and font set to bold (not w700).
//   // ─────────────────────────────────────────────────────────────────────────
//   Widget _buildStatusBadge(dynamic project) {
//     String? appliedStatus = project['applyStatus']?.toString();
//     if (appliedStatus == null) return const SizedBox.shrink();
//
//     final language = Provider.of<LanguageProvider>(context, listen: false).selectedLanguage;
//     String translate(String enText, String hiText) {
//       return language == 'en' ? enText : hiText;
//     }
//
//     String text = '';
//     Color bgColor = const Color(0xFFEAF4E8);
//     Color textColor = const Color(0xFF0E6805);
//     Color borderColor = const Color(0xFFC8E6C9);
//     IconData statusIcon = Icons.check;
//
//     if (appliedStatus == "0") {
//       text = translate('Applied', 'आवेदन किया');
//       bgColor = const Color(0xFFEAF4E8);
//       textColor = const Color(0xFF0E6805);
//       borderColor = const Color(0xFFC8E6C9);
//       statusIcon = Icons.check;
//     } else if (appliedStatus == "1") {
//       text = translate('Assigned', 'आवंटित');
//       bgColor = const Color(0xFFEFF6FF);
//       textColor = const Color(0xFF1E40AF);
//       borderColor = const Color(0xFFBFDBFE);
//       statusIcon = Icons.assignment_ind_outlined;
//     } else if (appliedStatus == "2") {
//       text = translate('Work Started', 'कार्य शुरू हुआ');
//       if (project['complete_confirm']?.toString() == "1") {
//         text = translate('Completion Requested', 'पूर्णता का अनुरोध');
//       } else if (project['cancel_confirm']?.toString() == "1") {
//         text = translate('Cancellation Requested', 'रद्दीकरण का अनुरोध');
//       }
//       bgColor = const Color(0xFFFFF7ED);
//       textColor = const Color(0xFFC2410C);
//       borderColor = const Color(0xFFFED7AA);
//       statusIcon = Icons.hourglass_top_outlined;
//     } else if (appliedStatus == "3") {
//       text = translate('Work Completed', 'कार्य पूर्ण');
//       bgColor = const Color(0xFFF0FDF4);
//       textColor = const Color(0xFF15803D);
//       borderColor = const Color(0xFFBBF7D0);
//       statusIcon = Icons.check_circle_outline;
//     } else if (appliedStatus == "4") {
//       text = translate('Work Cancelled', 'रद्द किया गया');
//       bgColor = const Color(0xFFFEF2F2);
//       textColor = const Color(0xFF991B1B);
//       borderColor = const Color(0xFFFCA5A5);
//       statusIcon = Icons.close;
//     } else {
//       return const SizedBox.shrink();
//     }
//
//     // ── Same size as the "Contract" / project_type tag ──
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//       decoration: BoxDecoration(
//         color: bgColor,
//         borderRadius: BorderRadius.circular(6),
//         border: Border.all(color: borderColor, width: 0.8),
//       ),
//       child: Row(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Icon(statusIcon, size: 11, color: textColor),
//           const SizedBox(width: 3),
//           Text(
//             text,
//             style: TextStyle(
//               color: textColor,
//               fontWeight: FontWeight.bold,
//               fontSize: 11,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildViewDetailsButton(dynamic project) {
//     String? appliedStatus = project['applyStatus']?.toString();
//     final language = Provider.of<LanguageProvider>(context, listen: false).selectedLanguage;
//     String translate(String enText, String hiText) {
//       return language == 'en' ? enText : hiText;
//     }
//
//     String label = appliedStatus == null
//         ? translate('Apply Now', 'आवेदन करें')
//         : translate('View Details', 'विवरण देखें');
//
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//       decoration: BoxDecoration(
//         color: const Color(0xFFEAF4E8),
//         borderRadius: BorderRadius.circular(8),
//         border: Border.all(color: const Color(0xFFC8E6C9), width: 0.5),
//       ),
//       child: Row(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Text(
//             label,
//             style: const TextStyle(
//               color: Color(0xFF0E6805),
//               fontWeight: FontWeight.bold,
//               fontSize: 12,
//             ),
//           ),
//           const SizedBox(width: 4),
//           const Icon(
//             Icons.arrow_forward_ios,
//             size: 10,
//             color: Color(0xFF0E6805),
//           ),
//         ],
//       ),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final language =
//         Provider.of<LanguageProvider>(context, listen: false).selectedLanguage;
//
//     String translate(String enText, String hiText) {
//       return language == 'en' ? enText : hiText;
//     }
//
//     return WillPopScope(
//       onWillPop: () async {
//         SystemNavigator.pop();
//         return false;
//       },
//       child: RefreshIndicator(
//         onRefresh: () async {
//           _selectedCategoryFilter = null;
//           setState(() {
//             _isLoadingLocation = true;
//             _locationError = '';
//           });
//           _fetchCurrentLocation(force: true);
//           await loadLanguage();
//           await fetchProjects();
//           await fetchJobTypes();
//           setState(() {});
//         },
//         child: Scaffold(
//           backgroundColor: Constants.AppColors.surface,
//           body: Container(
//             width: double.infinity,
//             color: Constants.AppColors.surface,
//             child: SingleChildScrollView(
//               physics: const AlwaysScrollableScrollPhysics(),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.center,
//                 children: [
//                   // Current Location Display notice banner
//                   if (_locationError.isNotEmpty || _isLoadingLocation)
//                     Container(
//                       margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//                       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//                       decoration: BoxDecoration(
//                         color: const Color(0xFFFFF9E6),
//                         borderRadius: BorderRadius.circular(14),
//                         border: Border.all(
//                           color: Constants.AppColors.amberNotice.withOpacity(0.4),
//                           width: 1.0,
//                         ),
//                       ),
//                       child: Row(
//                         children: [
//                           const Icon(
//                             Icons.location_off,
//                             color: Constants.AppColors.amberNotice,
//                             size: 20,
//                           ),
//                           const SizedBox(width: 8),
//                           Expanded(
//                             child: _isLoadingLocation
//                                 ? Row(
//                               children: [
//                                 const SizedBox(
//                                   width: 14,
//                                   height: 14,
//                                   child: CircularProgressIndicator(
//                                     strokeWidth: 2,
//                                     valueColor:
//                                     AlwaysStoppedAnimation<Color>(
//                                         Constants.AppColors.amberNotice),
//                                   ),
//                                 ),
//                                 const SizedBox(width: 8),
//                                 Text(
//                                   translate('Fetching location...', 'स्थान प्राप्त हो रहा है...'),
//                                   style: Constants.AppTypography.label.copyWith(
//                                     color: Constants.AppColors.inkSoft,
//                                   ),
//                                 ),
//                               ],
//                             )
//                                 : Text(
//                               _locationError,
//                               style: Constants.AppTypography.label.copyWith(
//                                 color: Constants.AppColors.inkSoft,
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                     )
//                   else if (_currentCity.isNotEmpty)
//                     Container(
//                       margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//                       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//                       decoration: BoxDecoration(
//                         color: Constants.AppColors.brandTint,
//                         borderRadius: BorderRadius.circular(14),
//                         border: Border.all(
//                           color: Constants.AppColors.brandSoft.withOpacity(0.3),
//                           width: 1.0,
//                         ),
//                       ),
//                       child: Row(
//                         children: [
//                           const Icon(
//                             Icons.location_on,
//                             color: Constants.AppColors.brand,
//                             size: 20,
//                           ),
//                           const SizedBox(width: 8),
//                           Expanded(
//                             child: Text(
//                               '$_currentCity, $_currentState',
//                               style: Constants.AppTypography.label.copyWith(
//                                 color: Constants.AppColors.brandDeep,
//                                 fontWeight: FontWeight.w700,
//                               ),
//                             ),
//                           ),
//                           GestureDetector(
//                             onTap: () {
//                               setState(() {
//                                 _isLoadingLocation = true;
//                                 _locationError = '';
//                               });
//                               _fetchCurrentLocation(force: true);
//                             },
//                             child: const Icon(
//                               Icons.refresh,
//                               color: Constants.AppColors.brand,
//                               size: 18,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   // Carousel Slider
//                   Container(
//                     width: double.infinity,
//                     height: 200,
//                     margin: const EdgeInsets.all(12),
//                     decoration: BoxDecoration(
//                       borderRadius: BorderRadius.circular(Constants.AppRadii.lg),
//                       boxShadow: const [Constants.AppShadows.card],
//                     ),
//                     child: ClipRRect(
//                       borderRadius: BorderRadius.circular(Constants.AppRadii.lg),
//                       child: CarouselSlider.builder(
//                         itemCount: imageUrls.length,
//                         itemBuilder: (BuildContext context, int index, int realIndex) {
//                           return SizedBox(
//                             width: double.infinity,
//                             child: Image.asset(
//                               imageUrls[index],
//                               fit: BoxFit.cover,
//                             ),
//                           );
//                         },
//                         options: CarouselOptions(
//                           height: 200,
//                           enlargeCenterPage: false,
//                           autoPlay: true,
//                           aspectRatio: 16 / 9,
//                           viewportFraction: 1.0,
//                         ),
//                       ),
//                     ),
//                   ),
//                   _buildSectionTitle(
//                     translate('Select category for job/Work', 'नौकरी/कार्य के लिए श्रेणी चुनें'),
//                   ),
//                   if (_jobTypes.isNotEmpty)
//                     Column(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         SizedBox(
//                           height: 128,
//                           child: ListView.builder(
//                             scrollDirection: Axis.horizontal,
//                             itemCount: _jobTypes.length,
//                             itemBuilder: (context, index) {
//                               JobType job = _jobTypes[index];
//
//                               return InkWell(
//                                 onTap: () {
//                                   setState(() {
//                                     if (_selectedCategoryFilter == job.jobname) {
//                                       _selectedCategoryFilter = null;
//                                     } else {
//                                       _selectedCategoryFilter = job.jobname;
//                                     }
//                                     _updateFilteredProjects();
//                                   });
//                                 },
//                                 child: SizedBox(
//                                   width: 90,
//                                   child: Column(
//                                     children: [
//                                       Container(
//                                         width: 70,
//                                         height: 70,
//                                         margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
//                                         decoration: BoxDecoration(
//                                           color: Constants.AppColors.brandTint,
//                                           shape: BoxShape.circle,
//                                           border: _selectedCategoryFilter == job.jobname
//                                               ? Border.all(
//                                             color: Constants.AppColors.brand,
//                                             width: 2.0,
//                                           )
//                                               : null,
//                                         ),
//                                         child: Center(
//                                           child: CachedNetworkImage(
//                                             imageUrl: '${Constants.AppConstants.folderUrl}storage/upload/jobtypes/${job.image}',
//                                             width: 42,
//                                             height: 42,
//                                             placeholder: (context, url) => const CircularProgressIndicator(),
//                                             errorWidget: (context, url, error) => const Icon(Icons.error, color: Constants.AppColors.brand),
//                                           ),
//                                         ),
//                                       ),
//                                       Padding(
//                                         padding: const EdgeInsets.only(left: 4.0, right: 4.0, top: 4.0),
//                                         child: Text(
//                                           translateText(job.jobname),
//                                           style: Constants.AppTypography.label.copyWith(
//                                             color: Constants.AppColors.ink,
//                                             fontWeight: FontWeight.bold,
//                                           ),
//                                           textAlign: TextAlign.center,
//                                           maxLines: 2,
//                                           overflow: TextOverflow.ellipsis,
//                                         ),
//                                       ),
//                                     ],
//                                   ),
//                                 ),
//                               );
//                             },
//                           ),
//                         ),
//                       ],
//                     ),
//                   const Divider(color: Constants.AppColors.border),
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.start,
//                     children: [
//                       Padding(
//                         padding: const EdgeInsets.only(left: 12.0),
//                         child: IconButton(
//                           icon: const Icon(Icons.filter_list, color: Constants.AppColors.brand),
//                           onPressed: () => _showFilterDialog(),
//                         ),
//                       ),
//                     ],
//                   ),
//                   if (filteredProjects.isEmpty)
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         Padding(
//                           padding: const EdgeInsets.all(16.0),
//                           child: Text(
//                             AppLocalizations.of(context)!.noProjectsFound,
//                             style: Constants.AppTypography.h2,
//                             textAlign: TextAlign.center,
//                           ),
//                         ),
//                       ],
//                     )
//                   else
//                     ListView.builder(
//                       itemCount: filteredProjects.length,
//                       shrinkWrap: true,
//                       physics: const NeverScrollableScrollPhysics(),
//                       itemBuilder: (context, index) {
//                         var project = filteredProjects[index];
//                         return InkWell(
//                           onTap: () {
//                             Navigator.push(
//                               context,
//                               MaterialPageRoute(
//                                 builder: (context) => ProjectDetailsPage(
//                                   projectId: project['id'],
//                                 ),
//                               ),
//                             );
//                           },
//                           child: Container(
//                             margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
//                             decoration: BoxDecoration(
//                               color: Constants.AppColors.card,
//                               borderRadius: BorderRadius.circular(16),
//                               border: Border.all(
//                                 color: const Color(0xFFF1F5EE),
//                                 width: 1.0,
//                               ),
//                               boxShadow: [
//                                 BoxShadow(
//                                   color: Colors.black.withOpacity(0.04),
//                                   blurRadius: 16,
//                                   offset: const Offset(0, 6),
//                                 ),
//                               ],
//                             ),
//                             child: Padding(
//                               padding: const EdgeInsets.all(16),
//                               child: Column(
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: [
//                                   // ── TOP ROW: Avatar + Title/Meta + Status badge ──
//                                   Row(
//                                     crossAxisAlignment: CrossAxisAlignment.start,
//                                     children: [
//                                       // Left: Farmer Avatar
//                                       Container(
//                                         width: 50,
//                                         height: 50,
//                                         decoration: const BoxDecoration(
//                                           color: Color(0xFFF1F5EE),
//                                           shape: BoxShape.circle,
//                                         ),
//                                         alignment: Alignment.center,
//                                         child: const Text(
//                                           '👨‍🌾',
//                                           style: TextStyle(fontSize: 26),
//                                         ),
//                                       ),
//                                       const SizedBox(width: 12),
//                                       // Right: Title + status badge row + Date + Type
//                                       Expanded(
//                                         child: Column(
//                                           crossAxisAlignment: CrossAxisAlignment.start,
//                                           children: [
//                                             // ── Title + status badge on same row ──
//                                             Row(
//                                               crossAxisAlignment: CrossAxisAlignment.start,
//                                               children: [
//                                                 Expanded(
//                                                   child: Text(
//                                                     translateText(project['title']?.toString() ?? 'No Title') ?? 'No Title',
//                                                     style: Constants.AppTypography.h2.copyWith(
//                                                       color: Constants.AppColors.ink,
//                                                       fontWeight: FontWeight.bold,
//                                                       fontSize: 16,
//                                                     ),
//                                                     maxLines: 2,
//                                                     overflow: TextOverflow.ellipsis,
//                                                   ),
//                                                 ),
//                                                 if (project['applyStatus'] != null) ...[
//                                                   const SizedBox(width: 8),
//                                                   _buildStatusBadge(project),
//                                                 ],
//                                               ],
//                                             ),
//                                             const SizedBox(height: 6),
//                                             // ── Date + contract type tag row ──
//                                             Row(
//                                               children: [
//                                                 const Icon(
//                                                   Icons.calendar_today_outlined,
//                                                   size: 13,
//                                                   color: Colors.grey,
//                                                 ),
//                                                 const SizedBox(width: 4),
//                                                 Text(
//                                                   _formatDate(project['created_at']?.toString() ?? ''),
//                                                   style: const TextStyle(
//                                                     fontSize: 13,
//                                                     color: Colors.grey,
//                                                   ),
//                                                 ),
//                                                 const SizedBox(width: 10),
//                                                 Container(
//                                                   padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//                                                   decoration: BoxDecoration(
//                                                     color: Constants.AppColors.brandTint,
//                                                     borderRadius: BorderRadius.circular(6),
//                                                   ),
//                                                   child: Row(
//                                                     mainAxisSize: MainAxisSize.min,
//                                                     children: [
//                                                       const Text('🌾', style: TextStyle(fontSize: 12)),
//                                                       const SizedBox(width: 4),
//                                                       Text(
//                                                         translateText(project['project_type'] ?? 'N/A') ?? 'N/A',
//                                                         style: TextStyle(
//                                                           fontSize: 12,
//                                                           fontWeight: FontWeight.bold,
//                                                           color: Constants.AppColors.brandDeep,
//                                                         ),
//                                                       ),
//                                                     ],
//                                                   ),
//                                                 ),
//                                               ],
//                                             ),
//                                           ],
//                                         ),
//                                       ),
//                                     ],
//                                   ),
//                                   const SizedBox(height: 12),
//                                   const Divider(color: Color(0xFFF1F5EE), height: 1),
//                                   const SizedBox(height: 10),
//                                   // ── Location ──
//                                   Row(
//                                     children: [
//                                       const Text('📍', style: TextStyle(fontSize: 14)),
//                                       const SizedBox(width: 6),
//                                       Expanded(
//                                         child: Text(
//                                           "${translateText(project['city'] ?? 'N/A')}, ${translateText(project['state'] ?? 'N/A')}",
//                                           style: Constants.AppTypography.body.copyWith(
//                                             color: Constants.AppColors.inkSoft,
//                                             fontWeight: FontWeight.w600,
//                                             fontSize: 14,
//                                           ),
//                                         ),
//                                       ),
//                                     ],
//                                   ),
//                                   const SizedBox(height: 12),
//                                   // ── ROW 1: Workers · Amount · Duration ──
//                                   Row(
//                                     children: [
//                                       _buildChip(
//                                         icon: Icons.people_outline,
//                                         label: '${project['qty_labours'] ?? '0'} ${translate('Workers', 'मजदूर')}',
//                                         bgColor: const Color(0xFFEAF4E8),
//                                         textColor: const Color(0xFF0E6805),
//                                         iconColor: const Color(0xFF0E6805),
//                                       ),
//                                       const SizedBox(width: 8),
//                                       _buildChip(
//                                         icon: Icons.currency_rupee,
//                                         label: '₹${project['budget'] ?? '0'}',
//                                         bgColor: const Color(0xFFFFF3E0),
//                                         textColor: const Color(0xFFE65100),
//                                         iconColor: const Color(0xFFE65100),
//                                       ),
//                                       const SizedBox(width: 8),
//                                       _buildChip(
//                                         icon: Icons.access_time,
//                                         label: translateText(project['days']?.toString() ?? '') ?? '',
//                                         bgColor: const Color(0xFFE3F2FD),
//                                         textColor: const Color(0xFF0D47A1),
//                                         iconColor: const Color(0xFF0D47A1),
//                                       ),
//                                     ],
//                                   ),
//                                   const SizedBox(height: 10),
//                                   // ── ROW 2: View Details right-aligned ──
//                                   Align(
//                                     alignment: Alignment.centerRight,
//                                     child: _buildViewDetailsButton(project),
//                                   ),
//                                 ],
//                               ),
//                             ),
//                           ),
//                         );
//                       },
//                     ),
//                   const SizedBox(height: 80), // Padding for floating nav bar
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
//
//   String _formatDate(String dateString) {
//     if (dateString.isEmpty) return 'N/A';
//     try {
//       DateTime dateTime = DateTime.parse(dateString);
//       return DateFormat('dd MMM yyyy').format(dateTime);
//     } catch (e) {
//       return dateString;
//     }
//   }
//
//   Widget _buildProjectDetailRow(IconData icon, String label, String value) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 2.0),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Icon(icon, size: 16, color: Constants.AppColors.brand),
//           const SizedBox(width: 8),
//           Text(
//             '$label: ',
//             style: Constants.AppTypography.label.copyWith(
//               color: Constants.AppColors.inkSoft,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//           Expanded(
//             child: Text(
//               value,
//               style: Constants.AppTypography.body.copyWith(
//                 color: Constants.AppColors.ink,
//               ),
//               softWrap: true,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildApplyButton(dynamic project) {
//     String? appliedStatus = project['applyStatus']?.toString();
//     final language = Provider.of<LanguageProvider>(context, listen: false).selectedLanguage;
//     String translate(String enText, String hiText) {
//       return language == 'en' ? enText : hiText;
//     }
//
//     Widget gradientButton(String text, VoidCallback onPressed) {
//       return Container(
//         decoration: BoxDecoration(
//           gradient: Constants.AppColors.brandGradient,
//           borderRadius: BorderRadius.circular(Constants.AppRadii.sm),
//           boxShadow: const [Constants.AppShadows.soft],
//         ),
//         child: ElevatedButton(
//           onPressed: onPressed,
//           style: ElevatedButton.styleFrom(
//             backgroundColor: Colors.transparent,
//             shadowColor: Colors.transparent,
//             padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 24),
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(Constants.AppRadii.sm),
//             ),
//           ),
//           child: Text(
//             text,
//             style: Constants.AppTypography.label.copyWith(
//               color: Colors.white,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//         ),
//       );
//     }
//
//     Widget statusBadge(String text, Color color, Color textColor) {
//       return Container(
//         padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
//         decoration: BoxDecoration(
//           color: color,
//           borderRadius: BorderRadius.circular(Constants.AppRadii.sm),
//           border: Border.all(color: Constants.AppColors.border),
//         ),
//         child: Text(
//           text,
//           style: Constants.AppTypography.label.copyWith(
//             color: textColor,
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//       );
//     }
//
//     if (appliedStatus == null) {
//       return gradientButton(
//         AppLocalizations.of(context)!.apply_now,
//             () {
//           Navigator.push(
//             context,
//             MaterialPageRoute(
//               builder: (context) => ProjectDetailsPage(
//                 projectId: project['id'],
//               ),
//             ),
//           );
//         },
//       );
//     } else if (appliedStatus == "0") {
//       return statusBadge(
//         AppLocalizations.of(context)!.applied,
//         Constants.AppColors.brandTint,
//         Constants.AppColors.brandDeep,
//       );
//     } else if (appliedStatus == "1") {
//       return statusBadge(
//         AppLocalizations.of(context)!.assigned,
//         Constants.AppColors.surface2,
//         Constants.AppColors.ink,
//       );
//     } else if (appliedStatus == "2") {
//       String text = AppLocalizations.of(context)!.workStarted;
//       if (project['complete_confirm']?.toString() == "1") {
//         text = AppLocalizations.of(context)!.completedRequested;
//       } else if (project['cancel_confirm']?.toString() == "1") {
//         text = AppLocalizations.of(context)!.cancelledRequested;
//       }
//       return statusBadge(
//         text,
//         Constants.AppColors.brandTint,
//         Constants.AppColors.brandDeep,
//       );
//     } else if (appliedStatus == "3") {
//       return statusBadge(
//         translate('Work Completed', 'कार्य पूरा हुआ'),
//         Constants.AppColors.brandTint,
//         Constants.AppColors.brandDeep,
//       );
//     } else if (appliedStatus == "4") {
//       return statusBadge(
//         translate('Work Cancelled', 'कार्य रद्द'),
//         Colors.red.shade50,
//         Colors.red.shade900,
//       );
//     }
//
//     return Container();
//   }
// }
//
// Widget _buildSectionTitle(String title) {
//   return Padding(
//     padding: const EdgeInsets.symmetric(vertical: 8.0),
//     child: Text(
//       title,
//       style: const TextStyle(
//           color: Colors.black, fontWeight: FontWeight.bold, fontSize: 20),
//     ),
//   );
// }













/////2 nd Changes














// import 'dart:async';
// import 'dart:developer' as developer;
// import 'dart:convert';
// import 'dart:io';
// import 'package:greencollar/l10n/app_localizations.dart';
// import 'package:greencollar/labournoti.dart';
// import 'package:permission_handler/permission_handler.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:geocoding/geocoding.dart';
//
// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:carousel_slider/carousel_slider.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_secure_storage/flutter_secure_storage.dart';
// import 'package:greencollar/Addproject.dart';
// import 'package:greencollar/HomeScree.dart'; // JobType is imported from here
// import 'package:greencollar/NearbyFarmers.dart';
// import 'package:greencollar/NearbyProject.dart';
// import 'package:greencollar/Nearbylabours.dart';
// import 'package:greencollar/main.dart';
// import 'package:greencollar/updateprofile.dart';
// import 'package:provider/provider.dart';
// import 'package:http/http.dart' as http;
// import 'package:url_launcher/url_launcher.dart';
// import 'package:greencollar/constants.dart' as Constants;
// import 'package:google_fonts/google_fonts.dart';
// import 'package:translator/translator.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:greencollar/wallet_helper.dart';
// import 'package:intl/intl.dart';
// import 'package:greencollar/speech_helper.dart';
// import 'package:greencollar/api_logger.dart';
//
// // ──────────────────────────────────────────────────────────────────────────
// // DO NOT redefine JobType – it is already in HomeScree.dart
// // ──────────────────────────────────────────────────────────────────────────
//
// // ──────────────────────────────────────────────────────────────────────────
// // OUTER WIDGET – Labourhomepage (Scaffold + Drawer + BottomNav)
// // ──────────────────────────────────────────────────────────────────────────
// class Labourhomepage extends StatefulWidget {
//   @override
//   _LabourhomepageState createState() => _LabourhomepageState();
// }
//
// class _LabourhomepageState extends State<Labourhomepage> {
//   int _currentIndex = 0;
//   final _secureStorage = const FlutterSecureStorage();
//   String _selectedLanguage = 'en';
//   String _userName = '';
//   String _userType = '';
//   int _walletCoins = 0;
//
//   // Translation maps (copied from inner class to use in drawer)
//   Map<String, Map<String, String>> _cachedTranslations = {};
//   Map<String, Map<String, String>> translations =
//       Constants.AppConstants.translations;
//   final GoogleTranslator _translator = GoogleTranslator();
//
//   int unreadNotificationsCount = 0;
//
//   @override
//   void initState() {
//     super.initState();
//     loadLanguage();
//     _loadUserInfo();
//     _loadWalletBalance();
//     ApiLogger.logScreenOpened('LabourHomepage');
//   }
//
//   Future<void> _loadUserInfo() async {
//     String? name = await _secureStorage.read(key: 'name');
//     String? userType = await _secureStorage.read(key: 'userType');
//     setState(() {
//       _userName = name ?? '';
//       _userType = userType ?? 'labour';
//     });
//   }
//
//   Future<void> loadLanguage() async {
//     await fetchUnreadNotificationsCount();
//     String? language = await _secureStorage.read(key: 'selectedLanguage');
//     _selectedLanguage = language ?? 'en';
//   }
//
//   Future<void> _loadWalletBalance() async {
//     int coins = await WalletHelper.getCoins();
//     if (mounted) setState(() => _walletCoins = coins);
//   }
//
//   Future<void> fetchUnreadNotificationsCount() async {
//     String? userId = await _secureStorage.read(key: 'id');
//     if (userId == null) return;
//     final url = Uri.parse(
//         '${Constants.AppConstants.apiUrl}farmer/getlabourUnreadNotificationsCount');
//     try {
//       final response = await http.post(url, body: {'id': userId});
//       if (response.statusCode == 200) {
//         final responseData = json.decode(response.body);
//         if (responseData['status'] == 'success') {
//           setState(() {
//             unreadNotificationsCount =
//             responseData['unread_notifications_count'];
//           });
//         }
//       }
//     } catch (e) {
//       print('Error: $e');
//     }
//   }
//
//   // Async translation for drawer (same as farmer's)
//   Future<String> translateText(String text) async {
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
//     try {
//       if (Constants.AppConstants.translations.containsKey(text) &&
//           Constants.AppConstants.translations[text]!.containsKey(targetLang)) {
//         return Constants.AppConstants.translations[text]![targetLang]!;
//       }
//       final translation = await _translator.translate(text, to: targetLang);
//       translations.putIfAbsent(text, () => {});
//       translations[text]![targetLang] = translation.text;
//       _cachedTranslations.putIfAbsent(text, () => {});
//       _cachedTranslations[text]![targetLang] = translation.text;
//       Constants.AppConstants.translations.putIfAbsent(text, () => {});
//       Constants.AppConstants.translations[text]![targetLang] = translation.text;
//       setState(() {});
//       return translation.text;
//     } catch (e) {
//       return text;
//     }
//   }
//
//   Future<void> _logout(BuildContext context) async {
//     await _secureStorage.delete(key: 'id');
//     Navigator.pushReplacement(
//       context,
//       MaterialPageRoute(builder: (context) => const LoginScreen()),
//     );
//   }
//
//   // Drawer tile builder (matches farmer's)
//   Widget _buildDrawerTile({
//     required IconData icon,
//     required Widget title,
//     required VoidCallback onTap,
//     Widget? trailing,
//     bool isLogout = false,
//   }) {
//     final Color tintColor = isLogout ? const Color(0xFFFEF2F2) : Constants.AppColors.brandTint;
//     final Color iconColor = isLogout ? const Color(0xFFEF4444) : Constants.AppColors.brand;
//
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
//       child: ListTile(
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(Constants.AppRadii.sm),
//         ),
//         leading: Container(
//           height: 40,
//           width: 40,
//           decoration: BoxDecoration(
//             color: tintColor,
//             borderRadius: BorderRadius.circular(10),
//           ),
//           child: Icon(icon, color: iconColor, size: 20),
//         ),
//         title: title,
//         trailing: trailing ??
//             Icon(
//               Icons.chevron_right_rounded,
//               color: isLogout ? const Color(0xFFEF4444) : const Color(0xFF9CA3AF),
//               size: 20,
//             ),
//         onTap: onTap,
//       ),
//     );
//   }
//
//   // Pages – outer scaffold uses LabourHomepage (the content widget)
//   final List<Widget> _pages = [
//     LabourHomepage(),   // <-- this is the inner content widget
//     FarmerPage(),
//     NearbyProjectPage(),
//   ];
//
//   @override
//   Widget build(BuildContext context) {
//     final language = context.watch<LanguageProvider>().selectedLanguage;
//
//     return WillPopScope(
//       onWillPop: () async {
//         SystemNavigator.pop();
//         return false;
//       },
//       child: Scaffold(
//         extendBody: true,
//         backgroundColor: Constants.AppColors.surface,
//         appBar: AppBar(
//           title: _currentIndex == 0
//               ? Row(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               Container(
//                 padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
//                 decoration: BoxDecoration(
//                   color: Colors.white.withOpacity(0.20),
//                   borderRadius: BorderRadius.circular(12),
//                   border: Border.all(color: Colors.white30, width: 0.5),
//                 ),
//                 child: Text(
//                   _selectedLanguage == 'en' ? 'Worker' : 'श्रमिक',
//                   style: Constants.AppTypography.micro.copyWith(
//                     color: Colors.white,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//               ),
//             ],
//           )
//               : Text(
//             _currentIndex == 1
//                 ? AppLocalizations.of(context)!.nearbyFarmers
//                 : _currentIndex == 2
//                 ? AppLocalizations.of(context)!.find_Work
//                 : 'Default Title',
//             style: Constants.AppTypography.h2.copyWith(color: Colors.white),
//           ),
//           iconTheme: const IconThemeData(color: Colors.white),
//           flexibleSpace: Container(
//             decoration: const BoxDecoration(
//               gradient: Constants.AppColors.brandGradient,
//             ),
//           ),
//           elevation: 0,
//           actions: [
//             WalletHelper.buildWalletButton(
//               coinBalance: _walletCoins,
//               onTap: () {
//                 WalletHelper.showCoinShop(context, onCoinsAdded: (newBalance) {
//                   setState(() => _walletCoins = newBalance);
//                 });
//               },
//             ),
//             IconButton(
//               icon: Stack(
//                 children: [
//                   const Icon(Icons.notifications),
//                   if (unreadNotificationsCount > 0)
//                     Positioned(
//                       right: 0,
//                       top: 0,
//                       child: CircleAvatar(
//                         radius: 8,
//                         backgroundColor: Colors.red,
//                         child: Text(
//                           unreadNotificationsCount.toString(),
//                           style: const TextStyle(fontSize: 10, color: Colors.white),
//                         ),
//                       ),
//                     ),
//                 ],
//               ),
//               onPressed: () {
//                 Navigator.pushReplacement(
//                   context,
//                   MaterialPageRoute(builder: (context) => LabourNotification()),
//                 );
//               },
//             ),
//           ],
//         ),
//         // ── NEW DRAWER (matches farmer's) ──
//         drawer: Drawer(
//           backgroundColor: Colors.white,
//           child: Column(
//             children: [
//               // Premium header
//               Container(
//                 padding: EdgeInsets.only(
//                   top: MediaQuery.of(context).padding.top + 20,
//                   bottom: 24,
//                   left: 20,
//                   right: 20,
//                 ),
//                 decoration: const BoxDecoration(
//                   gradient: LinearGradient(
//                     begin: Alignment.topCenter,
//                     end: Alignment.bottomCenter,
//                     colors: [
//                       Constants.AppColors.brandDeep,
//                       Constants.AppColors.brand,
//                     ],
//                   ),
//                   borderRadius: BorderRadius.only(
//                     bottomLeft: Radius.circular(24),
//                     bottomRight: Radius.circular(24),
//                   ),
//                 ),
//                 child: Row(
//                   children: [
//                     Container(
//                       padding: const EdgeInsets.all(2),
//                       decoration: const BoxDecoration(
//                         color: Colors.white24,
//                         shape: BoxShape.circle,
//                       ),
//                       child: CircleAvatar(
//                         radius: 28,
//                         backgroundColor: Colors.white,
//                         child: Text(
//                           _userName.isNotEmpty ? _userName[0].toUpperCase() : 'U',
//                           style: const TextStyle(
//                             color: Constants.AppColors.brandDeep,
//                             fontSize: 24,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                       ),
//                     ),
//                     const SizedBox(width: 16),
//                     Expanded(
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         mainAxisSize: MainAxisSize.min,
//                         children: [
//                           Text(
//                             _userName.isNotEmpty ? _userName : 'User',
//                             style: const TextStyle(
//                               color: Colors.white,
//                               fontSize: 18,
//                               fontWeight: FontWeight.bold,
//                             ),
//                             overflow: TextOverflow.ellipsis,
//                           ),
//                           const SizedBox(height: 4),
//                           Container(
//                             padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//                             decoration: BoxDecoration(
//                               color: Colors.white.withOpacity(0.15),
//                               borderRadius: BorderRadius.circular(12),
//                             ),
//                             child: Text(
//                               _userType == 'labour'
//                                   ? (language == 'en' ? 'Worker' : 'श्रमिक')
//                                   : (language == 'en' ? 'Farmer' : 'किसान'),
//                               style: const TextStyle(
//                                 color: Colors.white,
//                                 fontSize: 11,
//                                 fontWeight: FontWeight.w500,
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                     GestureDetector(
//                       onTap: () => Navigator.pop(context),
//                       child: Container(
//                         height: 36,
//                         width: 36,
//                         decoration: BoxDecoration(
//                           color: Colors.white.withOpacity(0.15),
//                           shape: BoxShape.circle,
//                         ),
//                         child: const Icon(Icons.close, color: Colors.white, size: 18),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//               // Menu items with FutureBuilder
//               Expanded(
//                 child: ListView(
//                   padding: const EdgeInsets.symmetric(vertical: 12),
//                   children: [
//                     _buildDrawerTile(
//                       icon: Icons.home,
//                       title: FutureBuilder<String>(
//                         future: translateText('Home'),
//                         builder: (context, snapshot) {
//                           return Text(
//                             snapshot.data ?? 'Home',
//                             style: const TextStyle(fontWeight: FontWeight.bold),
//                           );
//                         },
//                       ),
//                       onTap: () {
//                         setState(() => _currentIndex = 0);
//                         Navigator.pop(context);
//                       },
//                     ),
//                     _buildDrawerTile(
//                       icon: Icons.notifications,
//                       title: Row(
//                         children: [
//                           FutureBuilder<String>(
//                             future: translateText('Notifications'),
//                             builder: (context, snapshot) {
//                               return Text(
//                                 snapshot.data ?? 'Notifications',
//                                 style: const TextStyle(fontWeight: FontWeight.bold),
//                               );
//                             },
//                           ),
//                           if (unreadNotificationsCount > 0)
//                             Padding(
//                               padding: const EdgeInsets.only(left: 8.0),
//                               child: CircleAvatar(
//                                 radius: 10,
//                                 backgroundColor: Colors.red,
//                                 child: Text(
//                                   unreadNotificationsCount.toString(),
//                                   style: const TextStyle(fontSize: 12, color: Colors.white),
//                                 ),
//                               ),
//                             ),
//                         ],
//                       ),
//                       onTap: () {
//                         Navigator.pushReplacement(
//                           context,
//                           MaterialPageRoute(builder: (context) => LabourNotification()),
//                         );
//                       },
//                     ),
//                     _buildDrawerTile(
//                       icon: Icons.language,
//                       title: FutureBuilder<String>(
//                         future: translateText('Select Language'),
//                         builder: (context, snapshot) {
//                           return Text(
//                             snapshot.data ?? 'Language',
//                             style: const TextStyle(fontWeight: FontWeight.bold),
//                           );
//                         },
//                       ),
//                       onTap: () {
//                         Navigator.push(
//                           context,
//                           MaterialPageRoute(builder: (context) => LanguageSelectionScreen()),
//                         );
//                       },
//                     ),
//                     _buildDrawerTile(
//                       icon: Icons.notes,
//                       title: FutureBuilder<String>(
//                         future: translateText('My Projects'),
//                         builder: (context, snapshot) {
//                           return Text(
//                             snapshot.data ?? 'My Projects',
//                             style: const TextStyle(fontWeight: FontWeight.bold),
//                           );
//                         },
//                       ),
//                       onTap: () {
//                         Navigator.push(
//                           context,
//                           MaterialPageRoute(builder: (context) => AppliedProjects()),
//                         );
//                       },
//                     ),
//                     _buildDrawerTile(
//                       icon: Icons.person,
//                       title: FutureBuilder<String>(
//                         future: translateText('Profile'),
//                         builder: (context, snapshot) {
//                           return Text(
//                             snapshot.data ?? 'Profile',
//                             style: const TextStyle(fontWeight: FontWeight.bold),
//                           );
//                         },
//                       ),
//                       onTap: () {
//                         Navigator.push(
//                           context,
//                           MaterialPageRoute(builder: (context) => const UpdateLabourProfile()),
//                         );
//                       },
//                     ),
//                     const Divider(color: Constants.AppColors.border, height: 24, thickness: 1),
//                     _buildDrawerTile(
//                       icon: Icons.logout,
//                       isLogout: true,
//                       title: FutureBuilder<String>(
//                         future: translateText('Logout'),
//                         builder: (context, snapshot) {
//                           return Text(
//                             snapshot.data ?? 'Logout',
//                             style: const TextStyle(fontWeight: FontWeight.bold),
//                           );
//                         },
//                       ),
//                       onTap: () => _logout(context),
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ),
//         body: _pages[_currentIndex],
//         bottomNavigationBar: Padding(
//           padding: const EdgeInsets.only(left: 12.0, right: 12.0, bottom: 12.0),
//           child: Container(
//             decoration: const BoxDecoration(
//               gradient: Constants.AppColors.brandGradient,
//               borderRadius: BorderRadius.only(
//                 topLeft: Radius.circular(28),
//                 topRight: Radius.circular(28),
//                 bottomLeft: Radius.circular(28),
//                 bottomRight: Radius.circular(28),
//               ),
//               boxShadow: [Constants.AppShadows.fab],
//             ),
//             child: ClipRRect(
//               borderRadius: BorderRadius.circular(28),
//               child: BottomNavigationBar(
//                 backgroundColor: Colors.transparent,
//                 currentIndex: _currentIndex,
//                 selectedItemColor: Colors.white,
//                 unselectedItemColor: Colors.white70,
//                 selectedLabelStyle: Constants.AppTypography.label.copyWith(
//                   color: Colors.white,
//                   fontWeight: FontWeight.bold,
//                 ),
//                 unselectedLabelStyle: Constants.AppTypography.label.copyWith(
//                   color: Colors.white70,
//                 ),
//                 showUnselectedLabels: false,
//                 elevation: 0,
//                 type: BottomNavigationBarType.fixed,
//                 items: [
//                   BottomNavigationBarItem(
//                     icon: const Icon(Icons.home),
//                     label: AppLocalizations.of(context)!.homepage,
//                   ),
//                   BottomNavigationBarItem(
//                     icon: const Icon(Icons.search),
//                     label: AppLocalizations.of(context)!.nearbyFarmers,
//                   ),
//                   BottomNavigationBarItem(
//                     icon: const Icon(Icons.work_outline),
//                     label: AppLocalizations.of(context)!.find_Work,
//                   ),
//                 ],
//                 onTap: (index) {
//                   setState(() => _currentIndex = index);
//                   final pages = ['LabourHomepage', 'FarmerPage', 'NearbyProjectPage'];
//                   if (index >= 0 && index < pages.length) {
//                     ApiLogger.logScreenOpened(pages[index]);
//                   }
//                 },
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
//
// // ──────────────────────────────────────────────────────────────────────────
// // INNER WIDGET – LabourHomepage (actual home page content – UNCHANGED)
// // ──────────────────────────────────────────────────────────────────────────
// class LabourHomepage extends StatefulWidget {
//   @override
//   _LabourHomepageState createState() => _LabourHomepageState();
// }
//
// class _LabourHomepageState extends State<LabourHomepage>
//     with WidgetsBindingObserver {
//   static String _cachedCity = '';
//   static String _cachedState = '';
//   static String _cachedError = '';
//
//   // Location state variables
//   String _currentCity = '';
//   String _currentState = '';
//   bool _isLoadingLocation = true;
//   String _locationError = '';
//
//   FlutterSecureStorage _secureStorage = FlutterSecureStorage();
//   final TextEditingController _projectSearchController =
//   TextEditingController();
//   final TextEditingController _labourSearchController = TextEditingController();
//   final GoogleTranslator _translator = GoogleTranslator();
//
//   List<dynamic> projects = [];
//   List<dynamic> filteredProjects = [];
//   bool isLoading = false;
//   List<JobType> _jobTypes = [];
//   late Timer _timer;
//
//   String? _selectedCategoryFilter;
//
//   bool _matchesJobTitle(String jobTitle, String filter) {
//     final cleanTitle = jobTitle.trim().toLowerCase();
//     final cleanFilter = filter.trim().toLowerCase();
//
//     if (cleanFilter == 'farming' || cleanFilter == 'crop farming') {
//       return cleanTitle == 'farming' || cleanTitle == 'crop farming';
//     }
//
//     if (cleanTitle == cleanFilter) {
//       return true;
//     }
//
//     return cleanTitle.contains(cleanFilter) || cleanFilter.contains(cleanTitle);
//   }
//
//   void _updateFilteredProjects() {
//     if (_selectedCategoryFilter == null) {
//       filteredProjects = projects;
//     } else {
//       filteredProjects = projects.where((project) {
//         final jobTitle = project['job_title']?.toString() ?? '';
//         return _matchesJobTitle(jobTitle, _selectedCategoryFilter!);
//       }).toList();
//     }
//   }
//
//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addObserver(this);
//     loadLanguage();
//     fetchJobTypes();
//     fetchProjects();
//     _fetchCurrentLocation();
//   }
//
//   @override
//   void dispose() {
//     WidgetsBinding.instance.removeObserver(this);
//     super.dispose();
//   }
//
//   @override
//   void didChangeAppLifecycleState(AppLifecycleState state) {
//     if (state == AppLifecycleState.resumed) {
//       _fetchCurrentLocation(force: true);
//     }
//   }
//
//   Future<void> _fetchCurrentLocation({bool force = false}) async {
//     if (!force && (_cachedCity.isNotEmpty || _cachedState.isNotEmpty)) {
//       if (mounted) {
//         setState(() {
//           _currentCity = _cachedCity;
//           _currentState = _cachedState;
//           _isLoadingLocation = false;
//           _locationError = _cachedError;
//         });
//       }
//       return;
//     }
//
//     try {
//       bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
//       if (!serviceEnabled) {
//         if (mounted) {
//           setState(() {
//             _isLoadingLocation = false;
//             _locationError = 'Location services are disabled';
//           });
//         }
//         return;
//       }
//
//       LocationPermission permission = await Geolocator.checkPermission();
//       if (permission == LocationPermission.denied) {
//         permission = await Geolocator.requestPermission();
//         if (permission == LocationPermission.denied) {
//           if (mounted) {
//             setState(() {
//               _isLoadingLocation = false;
//               _locationError = 'Location permission denied';
//             });
//           }
//           return;
//         }
//       }
//
//       if (permission == LocationPermission.deniedForever) {
//         if (mounted) {
//           setState(() {
//             _isLoadingLocation = false;
//             _locationError = 'Location permission permanently denied';
//           });
//         }
//         return;
//       }
//
//       // Get current position
//       Position position = await Geolocator.getCurrentPosition(
//         desiredAccuracy: LocationAccuracy.high,
//       );
//
//       // Reverse geocode to get city and state
//       List<Placemark> placemarks = await placemarkFromCoordinates(
//         position.latitude,
//         position.longitude,
//       );
//
//       if (placemarks.isNotEmpty && mounted) {
//         Placemark place = placemarks[0];
//         _cachedCity = place.locality ?? place.subAdministrativeArea ?? '';
//         _cachedState = place.administrativeArea ?? '';
//         _cachedError = '';
//         setState(() {
//           _currentCity = _cachedCity;
//           _currentState = _cachedState;
//           _isLoadingLocation = false;
//         });
//       }
//     } catch (e) {
//       print('Error fetching location: $e');
//       _cachedError = 'Unable to fetch location';
//       if (mounted) {
//         setState(() {
//           _isLoadingLocation = false;
//           _locationError = _cachedError;
//         });
//       }
//     }
//   }
//
//   Map<String, Map<String, String>> _cachedTranslations = {};
//
//   Map<String, Map<String, String>> translations =
//       Constants.AppConstants.translations;
//   String _selectedLanguage = 'en'; // Default language is English
//
//   Future<void> downloadTranslations() async {
//     try {
//       var status = await Permission.storage.status;
//       if (!status.isGranted) {
//         await Permission.storage.request();
//       }
//
//       // Specify the destination path
//       final destinationPath = '/storage/emulated/0/Download/Invoice';
//       final destinationDir = Directory(destinationPath);
//
//       // Ensure the destination directory exists
//       await destinationDir.create(recursive: true);
//
//       // ✅ Define the folder inside the directory
//       final folderPath = '${destinationDir.path}/Appointment_Details';
//       final folder = Directory(folderPath);
//
//       // ✅ Create folder if it doesn't exist
//       if (!await folder.exists()) {
//         await folder.create(recursive: true);
//       }
//
//       // ✅ Define file path
//       final filePath = '$folderPath/translations.txt';
//       final file = File(filePath);
//
//       // ✅ Convert translations Map to readable text format
//       StringBuffer buffer = StringBuffer();
//       translations.forEach((key, value) {
//         buffer.writeln("$key: ${value.toString()}");
//       });
//
//       // ✅ Write to file
//       await file.writeAsString(buffer.toString());
//
//       // ✅ Print full file path
//       print("✅ Translations saved at: ${file.absolute.path}");
//     } catch (e) {
//       print("❌ Error saving translations: $e");
//     }
//   }
//
//   Future<void> loadLanguage() async {
//     // Read the selected language from FlutterSecureStorage
//     String? language = await _secureStorage.read(key: 'selectedLanguage');
//     _selectedLanguage = language ?? 'en';
//     print(language); // Default to English if null
//   }
//
//   Future<Map<String, Map<String, String>>> fetchTranslations() async {
//     try {
//       final response = await http.post(
//           Uri.parse('${Constants.AppConstants.apiUrl}farmer/getTranslations'));
//
//       if (response.statusCode == 200) {
//         final jsonData = jsonDecode(response.body);
//
//         if (jsonData['status'] == 1) {
//           List<dynamic> data = jsonData['data'];
//
//           for (var item in data) {
//             String text = item['text'];
//             String lang = item['lang'];
//             String translation = item['translation'];
//
//             // ✅ Initialize default values if text is not in the map
//             if (!translations.containsKey(text)) {
//               translations[text] = {
//                 "en": text,
//                 "hi": text
//               }; // Default both to the same value
//             }
//
//             // ✅ Store the translation in the correct language
//             translations[text]![lang] = translation;
//           }
//
//           // ✅ Store fetched translations in the cache
//           _cachedTranslations = translations;
//
//           // ✅ Check for missing translations and fetch dynamically
//           for (var text in translations.keys) {
//             if (!translations[text]!.containsKey("hi")) {
//               _fetchTranslation(text, "hi");
//             }
//             if (!translations[text]!.containsKey("en")) {
//               _fetchTranslation(text, "en");
//             }
//           }
//
//           return translations;
//         } else {
//           throw Exception(
//               "Failed to load translations: ${jsonData['message']}");
//         }
//       } else {
//         throw Exception("API Error: ${response.statusCode}");
//       }
//     } catch (e) {
//       print("Error fetching translations: $e");
//       return {};
//     }
//   }
//
//   /// ✅ Main function to translate text
//   String translateText(String text) {
//     if (text.isEmpty) return "";
//
//     // ✅ Ensure `_selectedLanguage` is set before calling `translateText()`
//     String targetLang = _selectedLanguage ?? 'en'; // Default to English if null
//
//     // ✅ Check manual translations first
//     if (translations.containsKey(text) &&
//         translations[text]!.containsKey(targetLang)) {
//       return translations[text]![targetLang]!; // Return manual translation
//     }
//
//     // ✅ Check cached translations
//     if (_cachedTranslations.containsKey(text) &&
//         _cachedTranslations[text]!.containsKey(targetLang)) {
//       return _cachedTranslations[text]![
//       targetLang]!; // Return cached translation
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
//   Future<void> fetchJobTypes() async {
//     final response = await http
//         .post(Uri.parse('${Constants.AppConstants.apiUrl}farmer/jobtype'));
//
//     if (response.statusCode == 200) {
//       final Map<String, dynamic> data = json.decode(response.body);
//       List<dynamic> jobData = data['data'];
//       setState(() {
//         _jobTypes = jobData.map((job) => JobType.fromJson(job)).toList();
//       });
//     } else {
//       throw Exception('Failed to load job types');
//     }
//   }
//
//   Future<void> fetchProjects() async {
//     final String apiUrl =
//         '${Constants.AppConstants.apiUrl}labour/nearbyProjectApi';
//     String? userId = await _secureStorage.read(key: 'id');
//     if (userId == null) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('User ID not found in secure storage')),
//       );
//       return;
//     }
//
//     try {
//       setState(() {
//         isLoading = true;
//       });
//
//       final Map<String, dynamic> requestBody = {
//         'id': userId,
//       };
//
//       final response = await http.post(
//         Uri.parse(apiUrl),
//         headers: {'Content-Type': 'application/json'},
//         body: jsonEncode(requestBody),
//       );
//
//       developer.log('Nearby Projects API Status: ${response.statusCode}',
//           name: 'greencollar.api');
//       developer.log('Nearby Projects API Response: ${response.body}',
//           name: 'greencollar.api');
//
//       if (response.statusCode == 200) {
//         final responseBody = json.decode(response.body);
//         if (responseBody['status'] == 1) {
//           setState(() {
//             projects = responseBody['data'];
//             _updateFilteredProjects();
//             isLoading = false;
//           });
//         } else {
//           setState(() {
//             projects = [];
//             _updateFilteredProjects();
//             isLoading = false;
//           });
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(
//                 content: Text(
//                     responseBody['message'] ?? 'Failed to fetch projects')),
//           );
//         }
//       } else {
//         setState(() {
//           isLoading = false;
//         });
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//               content:
//               Text('Failed to fetch projects: ${response.statusCode}')),
//         );
//       }
//     } catch (e) {
//       setState(() {
//         isLoading = false;
//       });
//     }
//   }
//
//   int _currentIndex = 0; // To track the current index of the carousel
//   final PageController _pageController = PageController();
//   String selectedCategory = 'All';
//   double selectedPriceRange = 1000000;
//   double selectedRating = 3;
//   String selectedJobType = 'All';
//   bool isDailyWageSelected = false;
//   bool isContractSelected = false;
//
//   void _showFilterDialog() {
//     showDialog(
//       context: context,
//       builder: (context) => StatefulBuilder(
//         builder: (context, setStateDialog) {
//           return AlertDialog(
//             title: Text(translateText('Filter Projects')),
//             content: SingleChildScrollView(
//               child: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   Padding(
//                     padding: const EdgeInsets.symmetric(vertical: 8.0),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(translateText('Select Job Type')),
//                         DropdownButton<String>(
//                           value: selectedJobType,
//                           isExpanded: true,
//                           items: [
//                             DropdownMenuItem<String>(
//                               value: 'All',
//                               child: Text(translateText('All')),
//                             ),
//                             ..._jobTypes
//                                 .map((job) => DropdownMenuItem<String>(
//                               value: job.jobname,
//                               child: Text(translateText(job.jobname)),
//                             ))
//                                 .toList(),
//                           ],
//                           onChanged: (value) {
//                             setStateDialog(() {
//                               selectedJobType = value!;
//                             });
//                           },
//                         ),
//                       ],
//                     ),
//                   ),
//                   const SizedBox(height: 10),
//                   Padding(
//                     padding: const EdgeInsets.symmetric(vertical: 8.0),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(translateText('Select Payment Type')),
//                         DropdownButton<String>(
//                           value: selectedCategory,
//                           isExpanded: true,
//                           items: ['All', 'Project Basis', 'Milestone Basis']
//                               .map((category) => DropdownMenuItem<String>(
//                             value: category,
//                             child: Text(translateText(category)),
//                           ))
//                               .toList(),
//                           onChanged: (value) {
//                             setStateDialog(() {
//                               selectedCategory = value!;
//                             });
//                           },
//                         ),
//                       ],
//                     ),
//                   ),
//                   const SizedBox(height: 10),
//                   Padding(
//                     padding: const EdgeInsets.all(16.0),
//                     child: TextField(
//                       controller: _labourSearchController,
//                       decoration: InputDecoration(
//                         prefixIcon:
//                         const Icon(Icons.search, color: Colors.green),
//                         suffixIcon: MicIconButton(controller: _labourSearchController),
//                         hintText:
//                         translateText('Search by pincode, city, or state'),
//                         fillColor: Colors.white,
//                         filled: true,
//                         border: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(15.0),
//                           borderSide: const BorderSide(color: Colors.green),
//                         ),
//                         focusedBorder: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(15.0),
//                           borderSide:
//                           const BorderSide(color: Colors.green, width: 2),
//                         ),
//                       ),
//                     ),
//                   ),
//                   Padding(
//                     padding: const EdgeInsets.symmetric(vertical: 8.0),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(translateText('Select Budget Range')),
//                         Slider(
//                           value: selectedPriceRange,
//                           min: 0,
//                           max: 1000000,
//                           divisions: 100,
//                           label: '\$${selectedPriceRange.toStringAsFixed(0)}',
//                           onChanged: (value) {
//                             setStateDialog(() {
//                               selectedPriceRange = value;
//                             });
//                           },
//                         ),
//                       ],
//                     ),
//                   ),
//                   const SizedBox(height: 10),
//                   Padding(
//                     padding: const EdgeInsets.symmetric(vertical: 8.0),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(translateText('Select Job Type')),
//                         Row(
//                           children: [
//                             Checkbox(
//                               value: isDailyWageSelected,
//                               onChanged: (bool? value) {
//                                 setStateDialog(() {
//                                   isDailyWageSelected = value!;
//                                 });
//                               },
//                             ),
//                             Text(translateText('Daily Wage')),
//                             const SizedBox(width: 10),
//                             Checkbox(
//                               value: isContractSelected,
//                               onChanged: (bool? value) {
//                                 setStateDialog(() {
//                                   isContractSelected = value!;
//                                 });
//                               },
//                             ),
//                             Text(translateText('Contract')),
//                           ],
//                         ),
//                       ],
//                     ),
//                   ),
//                   const SizedBox(height: 10),
//                 ],
//               ),
//             ),
//             actions: [
//               TextButton(
//                 onPressed: () {
//                   _applyFilters();
//                   setState(() {});
//                   Navigator.of(context).pop();
//                 },
//                 child: Text(translateText('Apply Filters')),
//               ),
//               TextButton(
//                 onPressed: () {
//                   setStateDialog(() {
//                     selectedJobType = 'All';
//                     selectedCategory = 'All';
//                     selectedPriceRange = 1000000;
//                     isDailyWageSelected = false;
//                     isContractSelected = false;
//                     _labourSearchController.clear();
//                   });
//                   setState(() {
//                     _selectedCategoryFilter = null;
//                   });
//                 },
//                 child: Text(translateText('Reset Filters'),
//                     style: const TextStyle(color: Colors.red)),
//               ),
//             ],
//           );
//         },
//       ),
//     );
//   }
//
//   Future<void> _applyFilters() async {
//     String? userId = await _secureStorage.read(key: 'id');
//     if (userId == null) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('User ID not found in secure storage')),
//       );
//       return;
//     }
//     _selectedCategoryFilter = null;
//     Map<String, dynamic> filters = {
//       'id': userId,
//       'job_type': selectedJobType,
//       'category': selectedCategory,
//       'search': _labourSearchController.text,
//       'budget': selectedPriceRange.toInt(),
//       'dailyWage': isDailyWageSelected,
//       'contract': isContractSelected,
//     };
//
//     fetchFilteredProjects(filters);
//   }
//
//   Future<void> fetchFilteredProjects(Map<String, dynamic> filters) async {
//     final String apiUrl =
//         '${Constants.AppConstants.apiUrl}labour/searchProjectsApi';
//     String? userId = await _secureStorage.read(key: 'id');
//     if (userId == null) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('User ID not found in secure storage')),
//       );
//       return;
//     }
//     print(jsonEncode(filters));
//     try {
//       setState(() {
//         isLoading = true;
//       });
//
//       final response = await http.post(
//         Uri.parse(apiUrl),
//         headers: {'Content-Type': 'application/json'},
//         body: json.encode(filters),
//       );
//
//       developer.log('Filtered Projects API Status: ${response.statusCode}',
//           name: 'greencollar.api');
//       developer.log('Filtered Projects API Response: ${response.body}',
//           name: 'greencollar.api');
//
//       if (response.statusCode == 200) {
//         final responseBody = json.decode(response.body);
//         if (responseBody['status'] == 1) {
//           setState(() {
//             projects = responseBody['data'];
//             _updateFilteredProjects();
//             isLoading = false;
//           });
//         } else {
//           setState(() {
//             projects = [];
//             _updateFilteredProjects();
//             isLoading = false;
//           });
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(
//                 content: Text(
//                     responseBody['message'] ?? 'Failed to fetch projects')),
//           );
//         }
//       } else {
//         setState(() {
//           isLoading = false;
//         });
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//               content:
//               Text('Failed to fetch projects: ${response.statusCode}')),
//         );
//       }
//     } catch (e) {
//       setState(() {
//         isLoading = false;
//       });
//     }
//   }
//
//   final List<String> imageUrls = [
//     'assets/slider1.png',
//     'assets/slider2.png',
//     'assets/slider4.jpg',
//     'assets/slider3.png',
//     'assets/slider5.png',
//   ];
//
//   Widget _buildChip({
//     required IconData icon,
//     required String label,
//     required Color bgColor,
//     required Color textColor,
//     required Color iconColor,
//   }) {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
//       decoration: BoxDecoration(
//         color: bgColor,
//         borderRadius: BorderRadius.circular(8),
//       ),
//       child: Row(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Icon(icon, size: 14, color: iconColor),
//           const SizedBox(width: 4),
//           Text(
//             label,
//             style: TextStyle(
//               color: textColor,
//               fontWeight: FontWeight.w600,
//               fontSize: 12,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   // ─────────────────────────────────────────────────────────────────────────
//   // _buildStatusBadge now matches the "View Details" button style
//   // ─────────────────────────────────────────────────────────────────────────
//   Widget _buildStatusBadge(dynamic project) {
//     String? appliedStatus = project['applyStatus']?.toString();
//     if (appliedStatus == null) return const SizedBox.shrink();
//
//     final language = Provider.of<LanguageProvider>(context, listen: false).selectedLanguage;
//     String translate(String enText, String hiText) {
//       return language == 'en' ? enText : hiText;
//     }
//
//     String text = '';
//     Color bgColor = const Color(0xFFEAF4E8);
//     Color textColor = const Color(0xFF0E6805);
//     Color borderColor = const Color(0xFFC8E6C9);
//     IconData statusIcon = Icons.check;
//
//     if (appliedStatus == "0") {
//       text = translate('Applied', 'आवेदन किया');
//       bgColor = const Color(0xFFEAF4E8);
//       textColor = const Color(0xFF0E6805);
//       borderColor = const Color(0xFFC8E6C9);
//       statusIcon = Icons.check;
//     } else if (appliedStatus == "1") {
//       text = translate('Assigned', 'आवंटित');
//       bgColor = const Color(0xFFEFF6FF);
//       textColor = const Color(0xFF1E40AF);
//       borderColor = const Color(0xFFBFDBFE);
//       statusIcon = Icons.assignment_ind_outlined;
//     } else if (appliedStatus == "2") {
//       text = translate('Work Started', 'कार्य शुरू हुआ');
//       if (project['complete_confirm']?.toString() == "1") {
//         text = translate('Completion Requested', 'पूर्णता का अनुरोध');
//       } else if (project['cancel_confirm']?.toString() == "1") {
//         text = translate('Cancellation Requested', 'रद्दीकरण का अनुरोध');
//       }
//       bgColor = const Color(0xFFFFF7ED);
//       textColor = const Color(0xFFC2410C);
//       borderColor = const Color(0xFFFED7AA);
//       statusIcon = Icons.hourglass_top_outlined;
//     } else if (appliedStatus == "3") {
//       text = translate('Work Completed', 'कार्य पूर्ण');
//       bgColor = const Color(0xFFF0FDF4);
//       textColor = const Color(0xFF15803D);
//       borderColor = const Color(0xFFBBF7D0);
//       statusIcon = Icons.check_circle_outline;
//     } else if (appliedStatus == "4") {
//       text = translate('Work Cancelled', 'रद्द किया गया');
//       bgColor = const Color(0xFFFEF2F2);
//       textColor = const Color(0xFF991B1B);
//       borderColor = const Color(0xFFFCA5A5);
//       statusIcon = Icons.close;
//     } else {
//       return const SizedBox.shrink();
//     }
//
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//       decoration: BoxDecoration(
//         color: bgColor,
//         borderRadius: BorderRadius.circular(6),
//         border: Border.all(color: borderColor, width: 0.8),
//       ),
//       child: Row(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Icon(statusIcon, size: 11, color: textColor),
//           const SizedBox(width: 3),
//           Text(
//             text,
//             style: TextStyle(
//               color: textColor,
//               fontWeight: FontWeight.bold,
//               fontSize: 11,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildViewDetailsButton(dynamic project) {
//     String? appliedStatus = project['applyStatus']?.toString();
//     final language = Provider.of<LanguageProvider>(context, listen: false).selectedLanguage;
//     String translate(String enText, String hiText) {
//       return language == 'en' ? enText : hiText;
//     }
//
//     String label = appliedStatus == null
//         ? translate('Apply Now', 'आवेदन करें')
//         : translate('View Details', 'विवरण देखें');
//
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//       decoration: BoxDecoration(
//         color: const Color(0xFFEAF4E8),
//         borderRadius: BorderRadius.circular(8),
//         border: Border.all(color: const Color(0xFFC8E6C9), width: 0.5),
//       ),
//       child: Row(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Text(
//             label,
//             style: const TextStyle(
//               color: Color(0xFF0E6805),
//               fontWeight: FontWeight.bold,
//               fontSize: 12,
//             ),
//           ),
//           const SizedBox(width: 4),
//           const Icon(
//             Icons.arrow_forward_ios,
//             size: 10,
//             color: Color(0xFF0E6805),
//           ),
//         ],
//       ),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final language =
//         Provider.of<LanguageProvider>(context, listen: false).selectedLanguage;
//
//     String translate(String enText, String hiText) {
//       return language == 'en' ? enText : hiText;
//     }
//
//     return WillPopScope(
//       onWillPop: () async {
//         SystemNavigator.pop();
//         return false;
//       },
//       child: RefreshIndicator(
//         onRefresh: () async {
//           _selectedCategoryFilter = null;
//           setState(() {
//             _isLoadingLocation = true;
//             _locationError = '';
//           });
//           _fetchCurrentLocation(force: true);
//           await loadLanguage();
//           await fetchProjects();
//           await fetchJobTypes();
//           setState(() {});
//         },
//         child: Scaffold(
//           backgroundColor: Constants.AppColors.surface,
//           body: Container(
//             width: double.infinity,
//             color: Constants.AppColors.surface,
//             child: SingleChildScrollView(
//               physics: const AlwaysScrollableScrollPhysics(),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.center,
//                 children: [
//                   // Current Location Display notice banner
//                   if (_locationError.isNotEmpty || _isLoadingLocation)
//                     Container(
//                       margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//                       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//                       decoration: BoxDecoration(
//                         color: const Color(0xFFFFF9E6),
//                         borderRadius: BorderRadius.circular(14),
//                         border: Border.all(
//                           color: Constants.AppColors.amberNotice.withOpacity(0.4),
//                           width: 1.0,
//                         ),
//                       ),
//                       child: Row(
//                         children: [
//                           const Icon(
//                             Icons.location_off,
//                             color: Constants.AppColors.amberNotice,
//                             size: 20,
//                           ),
//                           const SizedBox(width: 8),
//                           Expanded(
//                             child: _isLoadingLocation
//                                 ? Row(
//                               children: [
//                                 const SizedBox(
//                                   width: 14,
//                                   height: 14,
//                                   child: CircularProgressIndicator(
//                                     strokeWidth: 2,
//                                     valueColor:
//                                     AlwaysStoppedAnimation<Color>(
//                                         Constants.AppColors.amberNotice),
//                                   ),
//                                 ),
//                                 const SizedBox(width: 8),
//                                 Text(
//                                   translate('Fetching location...', 'स्थान प्राप्त हो रहा है...'),
//                                   style: Constants.AppTypography.label.copyWith(
//                                     color: Constants.AppColors.inkSoft,
//                                   ),
//                                 ),
//                               ],
//                             )
//                                 : Text(
//                               _locationError,
//                               style: Constants.AppTypography.label.copyWith(
//                                 color: Constants.AppColors.inkSoft,
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                     )
//                   else if (_currentCity.isNotEmpty)
//                     Container(
//                       margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//                       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//                       decoration: BoxDecoration(
//                         color: Constants.AppColors.brandTint,
//                         borderRadius: BorderRadius.circular(14),
//                         border: Border.all(
//                           color: Constants.AppColors.brandSoft.withOpacity(0.3),
//                           width: 1.0,
//                         ),
//                       ),
//                       child: Row(
//                         children: [
//                           const Icon(
//                             Icons.location_on,
//                             color: Constants.AppColors.brand,
//                             size: 20,
//                           ),
//                           const SizedBox(width: 8),
//                           Expanded(
//                             child: Text(
//                               '$_currentCity, $_currentState',
//                               style: Constants.AppTypography.label.copyWith(
//                                 color: Constants.AppColors.brandDeep,
//                                 fontWeight: FontWeight.w700,
//                               ),
//                             ),
//                           ),
//                           GestureDetector(
//                             onTap: () {
//                               setState(() {
//                                 _isLoadingLocation = true;
//                                 _locationError = '';
//                               });
//                               _fetchCurrentLocation(force: true);
//                             },
//                             child: const Icon(
//                               Icons.refresh,
//                               color: Constants.AppColors.brand,
//                               size: 18,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   // Carousel Slider
//                   Container(
//                     width: double.infinity,
//                     height: 200,
//                     margin: const EdgeInsets.all(12),
//                     decoration: BoxDecoration(
//                       borderRadius: BorderRadius.circular(Constants.AppRadii.lg),
//                       boxShadow: const [Constants.AppShadows.card],
//                     ),
//                     child: ClipRRect(
//                       borderRadius: BorderRadius.circular(Constants.AppRadii.lg),
//                       child: CarouselSlider.builder(
//                         itemCount: imageUrls.length,
//                         itemBuilder: (BuildContext context, int index, int realIndex) {
//                           return SizedBox(
//                             width: double.infinity,
//                             child: Image.asset(
//                               imageUrls[index],
//                               fit: BoxFit.cover,
//                             ),
//                           );
//                         },
//                         options: CarouselOptions(
//                           height: 200,
//                           enlargeCenterPage: false,
//                           autoPlay: true,
//                           aspectRatio: 16 / 9,
//                           viewportFraction: 1.0,
//                         ),
//                       ),
//                     ),
//                   ),
//                   _buildSectionTitle(
//                     translate('Select category for job/Work', 'नौकरी/कार्य के लिए श्रेणी चुनें'),
//                   ),
//                   if (_jobTypes.isNotEmpty)
//                     Column(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         SizedBox(
//                           height: 128,
//                           child: ListView.builder(
//                             scrollDirection: Axis.horizontal,
//                             itemCount: _jobTypes.length,
//                             itemBuilder: (context, index) {
//                               JobType job = _jobTypes[index];
//
//                               return InkWell(
//                                 onTap: () {
//                                   setState(() {
//                                     if (_selectedCategoryFilter == job.jobname) {
//                                       _selectedCategoryFilter = null;
//                                     } else {
//                                       _selectedCategoryFilter = job.jobname;
//                                     }
//                                     _updateFilteredProjects();
//                                   });
//                                 },
//                                 child: SizedBox(
//                                   width: 90,
//                                   child: Column(
//                                     children: [
//                                       Container(
//                                         width: 70,
//                                         height: 70,
//                                         margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
//                                         decoration: BoxDecoration(
//                                           color: Constants.AppColors.brandTint,
//                                           shape: BoxShape.circle,
//                                           border: _selectedCategoryFilter == job.jobname
//                                               ? Border.all(
//                                             color: Constants.AppColors.brand,
//                                             width: 2.0,
//                                           )
//                                               : null,
//                                         ),
//                                         child: Center(
//                                           child: CachedNetworkImage(
//                                             imageUrl: '${Constants.AppConstants.folderUrl}storage/upload/jobtypes/${job.image}',
//                                             width: 42,
//                                             height: 42,
//                                             placeholder: (context, url) => const CircularProgressIndicator(),
//                                             errorWidget: (context, url, error) => const Icon(Icons.error, color: Constants.AppColors.brand),
//                                           ),
//                                         ),
//                                       ),
//                                       Padding(
//                                         padding: const EdgeInsets.only(left: 4.0, right: 4.0, top: 4.0),
//                                         child: Text(
//                                           translateText(job.jobname),
//                                           style: Constants.AppTypography.label.copyWith(
//                                             color: Constants.AppColors.ink,
//                                             fontWeight: FontWeight.bold,
//                                           ),
//                                           textAlign: TextAlign.center,
//                                           maxLines: 2,
//                                           overflow: TextOverflow.ellipsis,
//                                         ),
//                                       ),
//                                     ],
//                                   ),
//                                 ),
//                               );
//                             },
//                           ),
//                         ),
//                       ],
//                     ),
//                   const Divider(color: Constants.AppColors.border),
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.start,
//                     children: [
//                       Padding(
//                         padding: const EdgeInsets.only(left: 12.0),
//                         child: IconButton(
//                           icon: const Icon(Icons.filter_list, color: Constants.AppColors.brand),
//                           onPressed: () => _showFilterDialog(),
//                         ),
//                       ),
//                     ],
//                   ),
//                   if (filteredProjects.isEmpty)
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         Padding(
//                           padding: const EdgeInsets.all(16.0),
//                           child: Text(
//                             AppLocalizations.of(context)!.noProjectsFound,
//                             style: Constants.AppTypography.h2,
//                             textAlign: TextAlign.center,
//                           ),
//                         ),
//                       ],
//                     )
//                   else
//                     ListView.builder(
//                       itemCount: filteredProjects.length,
//                       shrinkWrap: true,
//                       physics: const NeverScrollableScrollPhysics(),
//                       itemBuilder: (context, index) {
//                         var project = filteredProjects[index];
//                         return InkWell(
//                           onTap: () {
//                             Navigator.push(
//                               context,
//                               MaterialPageRoute(
//                                 builder: (context) => ProjectDetailsPage(
//                                   projectId: project['id'],
//                                 ),
//                               ),
//                             );
//                           },
//                           child: Container(
//                             margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
//                             decoration: BoxDecoration(
//                               color: Constants.AppColors.card,
//                               borderRadius: BorderRadius.circular(16),
//                               border: Border.all(
//                                 color: const Color(0xFFF1F5EE),
//                                 width: 1.0,
//                               ),
//                               boxShadow: [
//                                 BoxShadow(
//                                   color: Colors.black.withOpacity(0.04),
//                                   blurRadius: 16,
//                                   offset: const Offset(0, 6),
//                                 ),
//                               ],
//                             ),
//                             child: Padding(
//                               padding: const EdgeInsets.all(16),
//                               child: Column(
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: [
//                                   // ── TOP ROW: Avatar + Title/Meta + Status badge ──
//                                   Row(
//                                     crossAxisAlignment: CrossAxisAlignment.start,
//                                     children: [
//                                       // Left: Farmer Avatar
//                                       Container(
//                                         width: 50,
//                                         height: 50,
//                                         decoration: const BoxDecoration(
//                                           color: Color(0xFFF1F5EE),
//                                           shape: BoxShape.circle,
//                                         ),
//                                         alignment: Alignment.center,
//                                         child: const Text(
//                                           '👨‍🌾',
//                                           style: TextStyle(fontSize: 26),
//                                         ),
//                                       ),
//                                       const SizedBox(width: 12),
//                                       // Right: Title + status badge row + Date + Type
//                                       Expanded(
//                                         child: Column(
//                                           crossAxisAlignment: CrossAxisAlignment.start,
//                                           children: [
//                                             // ── Title + status badge on same row ──
//                                             Row(
//                                               crossAxisAlignment: CrossAxisAlignment.start,
//                                               children: [
//                                                 Expanded(
//                                                   child: Text(
//                                                     translateText(project['title']?.toString() ?? 'No Title') ?? 'No Title',
//                                                     style: Constants.AppTypography.h2.copyWith(
//                                                       color: Constants.AppColors.ink,
//                                                       fontWeight: FontWeight.bold,
//                                                       fontSize: 16,
//                                                     ),
//                                                     maxLines: 2,
//                                                     overflow: TextOverflow.ellipsis,
//                                                   ),
//                                                 ),
//                                                 if (project['applyStatus'] != null) ...[
//                                                   const SizedBox(width: 8),
//                                                   _buildStatusBadge(project),
//                                                 ],
//                                               ],
//                                             ),
//                                             const SizedBox(height: 6),
//                                             // ── Date + contract type tag row ──
//                                             Row(
//                                               children: [
//                                                 const Icon(
//                                                   Icons.calendar_today_outlined,
//                                                   size: 13,
//                                                   color: Colors.grey,
//                                                 ),
//                                                 const SizedBox(width: 4),
//                                                 Text(
//                                                   _formatDate(project['created_at']?.toString() ?? ''),
//                                                   style: const TextStyle(
//                                                     fontSize: 13,
//                                                     color: Colors.grey,
//                                                   ),
//                                                 ),
//                                                 const SizedBox(width: 10),
//                                                 Container(
//                                                   padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//                                                   decoration: BoxDecoration(
//                                                     color: Constants.AppColors.brandTint,
//                                                     borderRadius: BorderRadius.circular(6),
//                                                   ),
//                                                   child: Row(
//                                                     mainAxisSize: MainAxisSize.min,
//                                                     children: [
//                                                       const Text('🌾', style: TextStyle(fontSize: 12)),
//                                                       const SizedBox(width: 4),
//                                                       Text(
//                                                         translateText(project['project_type'] ?? 'N/A') ?? 'N/A',
//                                                         style: TextStyle(
//                                                           fontSize: 12,
//                                                           fontWeight: FontWeight.bold,
//                                                           color: Constants.AppColors.brandDeep,
//                                                         ),
//                                                       ),
//                                                     ],
//                                                   ),
//                                                 ),
//                                               ],
//                                             ),
//                                           ],
//                                         ),
//                                       ),
//                                     ],
//                                   ),
//                                   const SizedBox(height: 12),
//                                   const Divider(color: Color(0xFFF1F5EE), height: 1),
//                                   const SizedBox(height: 10),
//                                   // ── Location ──
//                                   Row(
//                                     children: [
//                                       const Text('📍', style: TextStyle(fontSize: 14)),
//                                       const SizedBox(width: 6),
//                                       Expanded(
//                                         child: Text(
//                                           "${translateText(project['city'] ?? 'N/A')}, ${translateText(project['state'] ?? 'N/A')}",
//                                           style: Constants.AppTypography.body.copyWith(
//                                             color: Constants.AppColors.inkSoft,
//                                             fontWeight: FontWeight.w600,
//                                             fontSize: 14,
//                                           ),
//                                         ),
//                                       ),
//                                     ],
//                                   ),
//                                   const SizedBox(height: 12),
//                                   // ── ROW 1: Workers · Amount · Duration ──
//                                   Row(
//                                     children: [
//                                       _buildChip(
//                                         icon: Icons.people_outline,
//                                         label: '${project['qty_labours'] ?? '0'} ${translate('Workers', 'मजदूर')}',
//                                         bgColor: const Color(0xFFEAF4E8),
//                                         textColor: const Color(0xFF0E6805),
//                                         iconColor: const Color(0xFF0E6805),
//                                       ),
//                                       const SizedBox(width: 8),
//                                       _buildChip(
//                                         icon: Icons.currency_rupee,
//                                         label: '₹${project['budget'] ?? '0'}',
//                                         bgColor: const Color(0xFFFFF3E0),
//                                         textColor: const Color(0xFFE65100),
//                                         iconColor: const Color(0xFFE65100),
//                                       ),
//                                       const SizedBox(width: 8),
//                                       _buildChip(
//                                         icon: Icons.access_time,
//                                         label: translateText(project['days']?.toString() ?? '') ?? '',
//                                         bgColor: const Color(0xFFE3F2FD),
//                                         textColor: const Color(0xFF0D47A1),
//                                         iconColor: const Color(0xFF0D47A1),
//                                       ),
//                                     ],
//                                   ),
//                                   const SizedBox(height: 10),
//                                   // ── ROW 2: View Details right-aligned ──
//                                   Align(
//                                     alignment: Alignment.centerRight,
//                                     child: _buildViewDetailsButton(project),
//                                   ),
//                                 ],
//                               ),
//                             ),
//                           ),
//                         );
//                       },
//                     ),
//                   const SizedBox(height: 80), // Padding for floating nav bar
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
//
//   String _formatDate(String dateString) {
//     if (dateString.isEmpty) return 'N/A';
//     try {
//       DateTime dateTime = DateTime.parse(dateString);
//       return DateFormat('dd MMM yyyy').format(dateTime);
//     } catch (e) {
//       return dateString;
//     }
//   }
//
//   Widget _buildProjectDetailRow(IconData icon, String label, String value) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 2.0),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Icon(icon, size: 16, color: Constants.AppColors.brand),
//           const SizedBox(width: 8),
//           Text(
//             '$label: ',
//             style: Constants.AppTypography.label.copyWith(
//               color: Constants.AppColors.inkSoft,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//           Expanded(
//             child: Text(
//               value,
//               style: Constants.AppTypography.body.copyWith(
//                 color: Constants.AppColors.ink,
//               ),
//               softWrap: true,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildApplyButton(dynamic project) {
//     String? appliedStatus = project['applyStatus']?.toString();
//     final language = Provider.of<LanguageProvider>(context, listen: false).selectedLanguage;
//     String translate(String enText, String hiText) {
//       return language == 'en' ? enText : hiText;
//     }
//
//     Widget gradientButton(String text, VoidCallback onPressed) {
//       return Container(
//         decoration: BoxDecoration(
//           gradient: Constants.AppColors.brandGradient,
//           borderRadius: BorderRadius.circular(Constants.AppRadii.sm),
//           boxShadow: const [Constants.AppShadows.soft],
//         ),
//         child: ElevatedButton(
//           onPressed: onPressed,
//           style: ElevatedButton.styleFrom(
//             backgroundColor: Colors.transparent,
//             shadowColor: Colors.transparent,
//             padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 24),
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(Constants.AppRadii.sm),
//             ),
//           ),
//           child: Text(
//             text,
//             style: Constants.AppTypography.label.copyWith(
//               color: Colors.white,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//         ),
//       );
//     }
//
//     Widget statusBadge(String text, Color color, Color textColor) {
//       return Container(
//         padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
//         decoration: BoxDecoration(
//           color: color,
//           borderRadius: BorderRadius.circular(Constants.AppRadii.sm),
//           border: Border.all(color: Constants.AppColors.border),
//         ),
//         child: Text(
//           text,
//           style: Constants.AppTypography.label.copyWith(
//             color: textColor,
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//       );
//     }
//
//     if (appliedStatus == null) {
//       return gradientButton(
//         AppLocalizations.of(context)!.apply_now,
//             () {
//           Navigator.push(
//             context,
//             MaterialPageRoute(
//               builder: (context) => ProjectDetailsPage(
//                 projectId: project['id'],
//               ),
//             ),
//           );
//         },
//       );
//     } else if (appliedStatus == "0") {
//       return statusBadge(
//         AppLocalizations.of(context)!.applied,
//         Constants.AppColors.brandTint,
//         Constants.AppColors.brandDeep,
//       );
//     } else if (appliedStatus == "1") {
//       return statusBadge(
//         AppLocalizations.of(context)!.assigned,
//         Constants.AppColors.surface2,
//         Constants.AppColors.ink,
//       );
//     } else if (appliedStatus == "2") {
//       String text = AppLocalizations.of(context)!.workStarted;
//       if (project['complete_confirm']?.toString() == "1") {
//         text = AppLocalizations.of(context)!.completedRequested;
//       } else if (project['cancel_confirm']?.toString() == "1") {
//         text = AppLocalizations.of(context)!.cancelledRequested;
//       }
//       return statusBadge(
//         text,
//         Constants.AppColors.brandTint,
//         Constants.AppColors.brandDeep,
//       );
//     } else if (appliedStatus == "3") {
//       return statusBadge(
//         translate('Work Completed', 'कार्य पूरा हुआ'),
//         Constants.AppColors.brandTint,
//         Constants.AppColors.brandDeep,
//       );
//     } else if (appliedStatus == "4") {
//       return statusBadge(
//         translate('Work Cancelled', 'कार्य रद्द'),
//         Colors.red.shade50,
//         Colors.red.shade900,
//       );
//     }
//
//     return Container();
//   }
// }
//
// Widget _buildSectionTitle(String title) {
//   return Padding(
//     padding: const EdgeInsets.symmetric(vertical: 8.0),
//     child: Text(
//       title,
//       style: const TextStyle(
//           color: Colors.black, fontWeight: FontWeight.bold, fontSize: 20),
//     ),
//   );
// }
















///3rd chges
///
///
import 'dart:async';
import 'dart:developer' as developer;
import 'dart:convert';
import 'dart:io';
import 'package:greencollar/l10n/app_localizations.dart';
import 'package:greencollar/labournoti.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:greencollar/Addproject.dart';
import 'package:greencollar/HomeScree.dart';
import 'package:greencollar/NearbyFarmers.dart';
import 'package:greencollar/NearbyProject.dart';
import 'package:greencollar/Nearbylabours.dart';
import 'package:greencollar/main.dart';
import 'package:greencollar/updateprofile.dart';
import 'package:provider/provider.dart';
import 'package:greencollar/location_provider.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'package:greencollar/constants.dart' as Constants;
import 'package:translator/translator.dart';
import 'package:greencollar/wallet_helper.dart';
import 'package:intl/intl.dart';
import 'package:greencollar/speech_helper.dart';
import 'package:greencollar/api_logger.dart';
import 'package:greencollar/ProjectDetails.dart';

// ──────────────────────────────────────────────────────────────────────────
// OUTER WIDGET – Labourhomepage (Scaffold + Drawer + BottomNav)
// ──────────────────────────────────────────────────────────────────────────
class Labourhomepage extends StatefulWidget {
  @override
  _LabourhomepageState createState() => _LabourhomepageState();
}

class _LabourhomepageState extends State<Labourhomepage> {
  int _currentIndex = 0;
  final _secureStorage = const FlutterSecureStorage();
  String _selectedLanguage = 'en';
  String _userName = '';
  String _userType = '';
  int _walletCoins = 0;

  Map<String, Map<String, String>> _cachedTranslations = {};
  Map<String, Map<String, String>> translations =
      Constants.AppConstants.translations;
  final GoogleTranslator _translator = GoogleTranslator();

  int unreadNotificationsCount = 0;

  @override
  void initState() {
    super.initState();
    loadLanguage();
    _loadUserInfo();
    _loadWalletBalance();
    ApiLogger.logScreenOpened('LabourHomepage');
  }

  Future<void> _loadUserInfo() async {
    String? name = await _secureStorage.read(key: 'name');
    String? userType = await _secureStorage.read(key: 'userType');
    setState(() {
      _userName = name ?? '';
      _userType = userType ?? 'labour';
    });
  }

  Future<void> loadLanguage() async {
    await fetchUnreadNotificationsCount();
    String? language = await _secureStorage.read(key: 'selectedLanguage');
    _selectedLanguage = language ?? 'en';
  }

  Future<void> _loadWalletBalance() async {
    int coins = await WalletHelper.getCoins();
    if (mounted) setState(() => _walletCoins = coins);
  }

  Future<void> fetchUnreadNotificationsCount() async {
    String? userId = await _secureStorage.read(key: 'id');
    if (userId == null) return;
    final url = Uri.parse(
        '${Constants.AppConstants.apiUrl}farmer/getlabourUnreadNotificationsCount');
    try {
      final response = await http.post(url, body: {'id': userId});
      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData['status'] == 'success') {
          setState(() {
            unreadNotificationsCount =
            responseData['unread_notifications_count'];
          });
        }
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<String> translateText(String text) async {
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
    try {
      if (Constants.AppConstants.translations.containsKey(text) &&
          Constants.AppConstants.translations[text]!.containsKey(targetLang)) {
        return Constants.AppConstants.translations[text]![targetLang]!;
      }
      final translation = await _translator.translate(text, to: targetLang);
      translations.putIfAbsent(text, () => {});
      translations[text]![targetLang] = translation.text;
      _cachedTranslations.putIfAbsent(text, () => {});
      _cachedTranslations[text]![targetLang] = translation.text;
      Constants.AppConstants.translations.putIfAbsent(text, () => {});
      Constants.AppConstants.translations[text]![targetLang] = translation.text;
      setState(() {});
      return translation.text;
    } catch (e) {
      return text;
    }
  }

  Future<void> _logout(BuildContext context) async {
    await _secureStorage.delete(key: 'id');
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }

  Widget _buildDrawerTile({
    required IconData icon,
    required Widget title,
    required VoidCallback onTap,
    Widget? trailing,
    bool isLogout = false,
  }) {
    final Color tintColor = isLogout ? const Color(0xFFFEF2F2) : Constants.AppColors.brandTint;
    final Color iconColor = isLogout ? const Color(0xFFEF4444) : Constants.AppColors.brand;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: ListTile(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Constants.AppRadii.sm),
        ),
        leading: Container(
          height: 40,
          width: 40,
          decoration: BoxDecoration(
            color: tintColor,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: iconColor, size: 20),
        ),
        title: title,
        trailing: trailing ??
            Icon(
              Icons.chevron_right_rounded,
              color: isLogout ? const Color(0xFFEF4444) : const Color(0xFF9CA3AF),
              size: 20,
            ),
        onTap: onTap,
      ),
    );
  }

  final List<Widget> _pages = [
    LabourHomepageContent(),
    FarmerPage(),
    NearbyProjectPage(),
  ];

  @override
  Widget build(BuildContext context) {
    final language = context.watch<LanguageProvider>().selectedLanguage;

    return WillPopScope(
      onWillPop: () async {
        SystemNavigator.pop();
        return false;
      },
      child: Scaffold(
        extendBody: true,
        backgroundColor: Constants.AppColors.surface,
        appBar: AppBar(
          title: _currentIndex == 0
              ? Consumer<LocationProvider>(
                  builder: (context, locationProvider, child) {
                    Widget locationWidget;
                    if (locationProvider.isLoading) {
                      locationWidget = Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const SizedBox(
                            width: 12,
                            height: 12,
                            child: CircularProgressIndicator(
                              strokeWidth: 1.5,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white70),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            _selectedLanguage == 'en' ? 'Finding location...' : 'स्थान खोज रहे हैं...',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.white.withOpacity(0.8),
                            ),
                          ),
                        ],
                      );
                    } else if (locationProvider.error.isNotEmpty || (locationProvider.city.isEmpty && locationProvider.state.isEmpty)) {
                      locationWidget = Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.location_off, size: 14, color: Colors.white70),
                          const SizedBox(width: 4),
                          Text(
                            _selectedLanguage == 'en' ? 'Location unavailable' : 'स्थान अनुपलब्ध',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.white.withOpacity(0.8),
                            ),
                          ),
                        ],
                      );
                    } else {
                      locationWidget = Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.location_on, size: 14, color: Colors.white),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              '${locationProvider.city}, ${locationProvider.state}',
                              style: const TextStyle(
                                fontSize: 13,
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      );
                    }

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.20),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.white30, width: 0.5),
                              ),
                              child: Text(
                                _selectedLanguage == 'en' ? 'Worker' : 'श्रमिक',
                                style: Constants.AppTypography.micro.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        locationWidget,
                      ],
                    );
                  },
                )
              : Text(
            _currentIndex == 1
                ? AppLocalizations.of(context)!.nearbyFarmers
                : _currentIndex == 2
                ? AppLocalizations.of(context)!.find_Work
                : 'Default Title',
            style: Constants.AppTypography.h2.copyWith(color: Colors.white),
          ),
          iconTheme: const IconThemeData(color: Colors.white),
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: Constants.AppColors.brandGradient,
            ),
          ),
          elevation: 0,
          actions: [
            IconButton(
              icon: Stack(
                children: [
                  const Icon(Icons.notifications),
                  if (unreadNotificationsCount > 0)
                    Positioned(
                      right: 0,
                      top: 0,
                      child: CircleAvatar(
                        radius: 8,
                        backgroundColor: Colors.red,
                        child: Text(
                          unreadNotificationsCount.toString(),
                          style: const TextStyle(fontSize: 10, color: Colors.white),
                        ),
                      ),
                    ),
                ],
              ),
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => LabourNotification()),
                );
              },
            ),
          ],
        ),
        drawer: Drawer(
          backgroundColor: Colors.white,
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.only(
                  top: MediaQuery.of(context).padding.top + 20,
                  bottom: 24,
                  left: 20,
                  right: 20,
                ),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Constants.AppColors.brandDeep,
                      Constants.AppColors.brand,
                    ],
                  ),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(24),
                    bottomRight: Radius.circular(24),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(2),
                      decoration: const BoxDecoration(
                        color: Colors.white24,
                        shape: BoxShape.circle,
                      ),
                      child: CircleAvatar(
                        radius: 28,
                        backgroundColor: Colors.white,
                        child: Text(
                          _userName.isNotEmpty ? _userName[0].toUpperCase() : 'U',
                          style: const TextStyle(
                            color: Constants.AppColors.brandDeep,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _userName.isNotEmpty ? _userName : 'User',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              _userType == 'labour'
                                  ? (language == 'en' ? 'Worker' : 'श्रमिक')
                                  : (language == 'en' ? 'Farmer' : 'किसान'),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        height: 36,
                        width: 36,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.close, color: Colors.white, size: 18),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  children: [
                    _buildDrawerTile(
                      icon: Icons.home,
                      title: FutureBuilder<String>(
                        future: translateText('Home'),
                        builder: (context, snapshot) {
                          return Text(
                            snapshot.data ?? 'Home',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          );
                        },
                      ),
                      onTap: () {
                        setState(() => _currentIndex = 0);
                        Navigator.pop(context);
                      },
                    ),
                    _buildDrawerTile(
                      icon: Icons.notifications,
                      title: Row(
                        children: [
                          FutureBuilder<String>(
                            future: translateText('Notifications'),
                            builder: (context, snapshot) {
                              return Text(
                                snapshot.data ?? 'Notifications',
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              );
                            },
                          ),
                          if (unreadNotificationsCount > 0)
                            Padding(
                              padding: const EdgeInsets.only(left: 8.0),
                              child: CircleAvatar(
                                radius: 10,
                                backgroundColor: Colors.red,
                                child: Text(
                                  unreadNotificationsCount.toString(),
                                  style: const TextStyle(fontSize: 12, color: Colors.white),
                                ),
                              ),
                            ),
                        ],
                      ),
                      onTap: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => LabourNotification()),
                        );
                      },
                    ),
                    _buildDrawerTile(
                      icon: Icons.language,
                      title: FutureBuilder<String>(
                        future: translateText('Select Language'),
                        builder: (context, snapshot) {
                          return Text(
                            snapshot.data ?? 'Language',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          );
                        },
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => LanguageSelectionScreen()),
                        );
                      },
                    ),
                    _buildDrawerTile(
                      icon: Icons.notes,
                      title: FutureBuilder<String>(
                        future: translateText('My Projects'),
                        builder: (context, snapshot) {
                          return Text(
                            snapshot.data ?? 'My Projects',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          );
                        },
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => NearbyProjectPage()),
                        );
                      },
                    ),
                    // Wallet
                    _buildDrawerTile(
                      icon: Icons.account_balance_wallet,
                      title: FutureBuilder<String>(
                        future: translateText('Wallet'),
                        builder: (context, snapshot) {
                          final walletTitle = snapshot.data ?? 'Wallet';
                          // final coinsText = _selectedLanguage == 'en'
                          //     ? '($_walletCoins coins)'
                          //     : '($_walletCoins सिक्के)';
                          return Text(
                            '$walletTitle',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          );
                        },
                      ),
                      onTap: () {
                        Navigator.pop(context);
                        WalletHelper.showCoinShop(context, onCoinsAdded: (newBalance) {
                          setState(() => _walletCoins = newBalance);
                        });
                      },
                    ),

                    _buildDrawerTile(
                      icon: Icons.person,
                      title: FutureBuilder<String>(
                        future: translateText('Profile'),
                        builder: (context, snapshot) {
                          return Text(
                            snapshot.data ?? 'Profile',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          );
                        },
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const UpdateLabourProfile()),
                        );
                      },
                    ),
                    const Divider(color: Constants.AppColors.border, height: 24, thickness: 1),
                    _buildDrawerTile(
                      icon: Icons.logout,
                      isLogout: true,
                      title: FutureBuilder<String>(
                        future: translateText('Logout'),
                        builder: (context, snapshot) {
                          return Text(
                            snapshot.data ?? 'Logout',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          );
                        },
                      ),
                      onTap: () => _logout(context),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        body: _pages[_currentIndex],
        bottomNavigationBar: Padding(
          padding: const EdgeInsets.only(left: 12.0, right: 12.0, bottom: 12.0),
          child: Container(
            decoration: const BoxDecoration(
              gradient: Constants.AppColors.brandGradient,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(28),
                topRight: Radius.circular(28),
                bottomLeft: Radius.circular(28),
                bottomRight: Radius.circular(28),
              ),
              boxShadow: [Constants.AppShadows.fab],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(28),
              child: BottomNavigationBar(
                backgroundColor: Colors.transparent,
                currentIndex: _currentIndex,
                selectedItemColor: Colors.white,
                unselectedItemColor: Colors.white70,
                selectedLabelStyle: Constants.AppTypography.label.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
                unselectedLabelStyle: Constants.AppTypography.label.copyWith(
                  color: Colors.white70,
                ),
                showUnselectedLabels: false,
                elevation: 0,
                type: BottomNavigationBarType.fixed,
                items: [
                  BottomNavigationBarItem(
                    icon: const Icon(Icons.home),
                    label: AppLocalizations.of(context)!.homepage,
                  ),
                  BottomNavigationBarItem(
                    icon: const Icon(Icons.search),
                    label: AppLocalizations.of(context)!.nearbyFarmers,
                  ),
                  BottomNavigationBarItem(
                    icon: const Icon(Icons.work_outline),
                    label: AppLocalizations.of(context)!.find_Work,
                  ),
                ],
                onTap: (index) {
                  setState(() => _currentIndex = index);
                  final pages = ['LabourHomepage', 'FarmerPage', 'NearbyProjectPage'];
                  if (index >= 0 && index < pages.length) {
                    ApiLogger.logScreenOpened(pages[index]);
                  }
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────
// CONTENT WIDGET – LabourHomepageContent (with premium card design)
// ──────────────────────────────────────────────────────────────────────────
class LabourHomepageContent extends StatefulWidget {
  @override
  _LabourHomepageContentState createState() => _LabourHomepageContentState();
}

class _LabourHomepageContentState extends State<LabourHomepageContent>
    with WidgetsBindingObserver {
  static String _cachedCity = '';
  static String _cachedState = '';
  static String _cachedError = '';

  String _currentCity = '';
  String _currentState = '';
  bool _isLoadingLocation = true;
  String _locationError = '';

  final FlutterSecureStorage _secureStorage = FlutterSecureStorage();
  final TextEditingController _projectSearchController =
  TextEditingController();
  final TextEditingController _labourSearchController = TextEditingController();
  final GoogleTranslator _translator = GoogleTranslator();

  List<dynamic> projects = [];
  List<dynamic> filteredProjects = [];
  bool isLoading = false;
  List<JobType> _jobTypes = [];
  late Timer _timer;

  String? _selectedCategoryFilter;

  bool _matchesJobTitle(String jobTitle, String filter) {
    final cleanTitle = jobTitle.trim().toLowerCase();
    final cleanFilter = filter.trim().toLowerCase();
    if (cleanFilter == 'farming' || cleanFilter == 'crop farming') {
      return cleanTitle == 'farming' || cleanTitle == 'crop farming';
    }
    if (cleanTitle == cleanFilter) return true;
    return cleanTitle.contains(cleanFilter) || cleanFilter.contains(cleanTitle);
  }

  void _updateFilteredProjects() {
    if (_selectedCategoryFilter == null) {
      filteredProjects = projects;
    } else {
      filteredProjects = projects.where((project) {
        final jobTitle = project['job_title']?.toString() ?? '';
        return _matchesJobTitle(jobTitle, _selectedCategoryFilter!);
      }).toList();
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    loadLanguage();
    fetchJobTypes();
    fetchProjects();
    _fetchCurrentLocation();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _fetchCurrentLocation(force: true);
    }
  }
  Future<void> _fetchCurrentLocation({bool force = false}) async {
    if (!force && (_cachedCity.isNotEmpty || _cachedState.isNotEmpty)) {
      if (mounted) {
        setState(() {
          _currentCity = _cachedCity;
          _currentState = _cachedState;
          _isLoadingLocation = false;
          _locationError = _cachedError;
        });
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            final locProv = Provider.of<LocationProvider>(context, listen: false);
            if (_cachedError.isNotEmpty) {
              locProv.setError(_cachedError);
            } else {
              locProv.setLocation(city: _currentCity, state: _currentState);
            }
          }
        });
      }
      return;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        Provider.of<LocationProvider>(context, listen: false).setLoading(true);
      }
    });

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (mounted) {
          setState(() {
            _isLoadingLocation = false;
            _locationError = 'Location services are disabled';
          });
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              Provider.of<LocationProvider>(context, listen: false).setError('Location services are disabled');
            }
          });
        }
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          if (mounted) {
            setState(() {
              _isLoadingLocation = false;
              _locationError = 'Location permission denied';
            });
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                Provider.of<LocationProvider>(context, listen: false).setError('Location permission denied');
              }
            });
          }
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        if (mounted) {
          setState(() {
            _isLoadingLocation = false;
            _locationError = 'Location permission permanently denied';
          });
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              Provider.of<LocationProvider>(context, listen: false).setError('Location permission permanently denied');
            }
          });
        }
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty && mounted) {
        Placemark place = placemarks[0];
        _cachedCity = place.locality ?? place.subAdministrativeArea ?? '';
        _cachedState = place.administrativeArea ?? '';
        _cachedError = '';
        setState(() {
          _currentCity = _cachedCity;
          _currentState = _cachedState;
          _isLoadingLocation = false;
        });
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            Provider.of<LocationProvider>(context, listen: false).setLocation(city: _currentCity, state: _currentState);
          }
        });
      }
    } catch (e) {
      print('Error fetching location: $e');
      _cachedError = 'Unable to fetch location';
      if (mounted) {
        setState(() {
          _isLoadingLocation = false;
          _locationError = _cachedError;
        });
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            Provider.of<LocationProvider>(context, listen: false).setError(_cachedError);
          }
        });
      }
    }
  }
  Map<String, Map<String, String>> _cachedTranslations = {};
  Map<String, Map<String, String>> translations =
      Constants.AppConstants.translations;
  String _selectedLanguage = 'en';

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

  Future<void> fetchJobTypes() async {
    final response = await http
        .post(Uri.parse('${Constants.AppConstants.apiUrl}farmer/jobtype'));

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      List<dynamic> jobData = data['data'];
      setState(() {
        _jobTypes = jobData.map((job) => JobType.fromJson(job)).toList();
      });
    } else {
      throw Exception('Failed to load job types');
    }
  }

  Future<void> fetchProjects() async {
    final String apiUrl =
        '${Constants.AppConstants.apiUrl}labour/nearbyProjectApi';
    String? userId = await _secureStorage.read(key: 'id');
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User ID not found in secure storage')),
      );
      return;
    }

    try {
      setState(() => isLoading = true);

      final Map<String, dynamic> requestBody = {'id': userId};

      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );

      developer.log('Nearby Projects API Status: ${response.statusCode}',
          name: 'greencollar.api');
      developer.log('Nearby Projects API Response: ${response.body}',
          name: 'greencollar.api');

      if (response.statusCode == 200) {
        final responseBody = json.decode(response.body);
        if (responseBody['status'] == 1) {
          setState(() {
            projects = responseBody['data'];
            _updateFilteredProjects();
            isLoading = false;
          });
        } else {
          setState(() {
            projects = [];
            _updateFilteredProjects();
            isLoading = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(
                    responseBody['message'] ?? 'Failed to fetch projects')),
          );
        }
      } else {
        setState(() => isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content:
              Text('Failed to fetch projects: ${response.statusCode}')),
        );
      }
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  int _currentIndex = 0;
  final PageController _pageController = PageController();
  String selectedCategory = 'All';
  double selectedPriceRange = 1000000;
  double selectedRating = 3;
  String selectedJobType = 'All';
  bool isDailyWageSelected = false;
  bool isContractSelected = false;

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateDialog) {
          return AlertDialog(
            title: Text(translateText('Filter Projects')),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(translateText('Select Job Type')),
                        DropdownButton<String>(
                          value: selectedJobType,
                          isExpanded: true,
                          items: [
                            DropdownMenuItem<String>(
                              value: 'All',
                              child: Text(translateText('All')),
                            ),
                            ..._jobTypes
                                .map((job) => DropdownMenuItem<String>(
                              value: job.jobname,
                              child: Text(translateText(job.jobname)),
                            ))
                                .toList(),
                          ],
                          onChanged: (value) {
                            setStateDialog(() => selectedJobType = value!);
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(translateText('Select Payment Type')),
                        DropdownButton<String>(
                          value: selectedCategory,
                          isExpanded: true,
                          items: ['All', 'Project Basis', 'Milestone Basis']
                              .map((category) => DropdownMenuItem<String>(
                            value: category,
                            child: Text(translateText(category)),
                          ))
                              .toList(),
                          onChanged: (value) {
                            setStateDialog(() => selectedCategory = value!);
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: TextField(
                      controller: _labourSearchController,
                      decoration: InputDecoration(
                        prefixIcon:
                        const Icon(Icons.search, color: Colors.green),
                        suffixIcon:
                        MicIconButton(controller: _labourSearchController),
                        hintText:
                        translateText('Search by pincode, city, or state'),
                        fillColor: Colors.white,
                        filled: true,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15.0),
                          borderSide: const BorderSide(color: Colors.green),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15.0),
                          borderSide:
                          const BorderSide(color: Colors.green, width: 2),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(translateText('Select Budget Range')),
                        Slider(
                          value: selectedPriceRange,
                          min: 0,
                          max: 1000000,
                          divisions: 100,
                          label: '\$${selectedPriceRange.toStringAsFixed(0)}',
                          onChanged: (value) {
                            setStateDialog(() => selectedPriceRange = value);
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(translateText('Select Job Type')),
                        Row(
                          children: [
                            Checkbox(
                              value: isDailyWageSelected,
                              onChanged: (bool? value) {
                                setStateDialog(
                                        () => isDailyWageSelected = value!);
                              },
                            ),
                            Text(translateText('Daily Wage')),
                            const SizedBox(width: 10),
                            Checkbox(
                              value: isContractSelected,
                              onChanged: (bool? value) {
                                setStateDialog(
                                        () => isContractSelected = value!);
                              },
                            ),
                            Text(translateText('Contract')),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  _applyFilters();
                  setState(() {});
                  Navigator.of(context).pop();
                },
                child: Text(translateText('Apply Filters')),
              ),
              TextButton(
                onPressed: () {
                  setStateDialog(() {
                    selectedJobType = 'All';
                    selectedCategory = 'All';
                    selectedPriceRange = 1000000;
                    isDailyWageSelected = false;
                    isContractSelected = false;
                    _labourSearchController.clear();
                  });
                  setState(() => _selectedCategoryFilter = null);
                },
                child: Text(translateText('Reset Filters'),
                    style: const TextStyle(color: Colors.red)),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _applyFilters() async {
    String? userId = await _secureStorage.read(key: 'id');
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User ID not found in secure storage')),
      );
      return;
    }
    _selectedCategoryFilter = null;
    Map<String, dynamic> filters = {
      'id': userId,
      'job_type': selectedJobType,
      'category': selectedCategory,
      'search': _labourSearchController.text,
      'budget': selectedPriceRange.toInt(),
      'dailyWage': isDailyWageSelected,
      'contract': isContractSelected,
    };

    fetchFilteredProjects(filters);
  }

  Future<void> fetchFilteredProjects(Map<String, dynamic> filters) async {
    final String apiUrl =
        '${Constants.AppConstants.apiUrl}labour/searchProjectsApi';
    String? userId = await _secureStorage.read(key: 'id');
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User ID not found in secure storage')),
      );
      return;
    }
    print(jsonEncode(filters));
    try {
      setState(() => isLoading = true);

      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(filters),
      );

      developer.log('Filtered Projects API Status: ${response.statusCode}',
          name: 'greencollar.api');
      developer.log('Filtered Projects API Response: ${response.body}',
          name: 'greencollar.api');

      if (response.statusCode == 200) {
        final responseBody = json.decode(response.body);
        if (responseBody['status'] == 1) {
          setState(() {
            projects = responseBody['data'];
            _updateFilteredProjects();
            isLoading = false;
          });
        } else {
          setState(() {
            projects = [];
            _updateFilteredProjects();
            isLoading = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(
                    responseBody['message'] ?? 'Failed to fetch projects')),
          );
        }
      } else {
        setState(() => isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content:
              Text('Failed to fetch projects: ${response.statusCode}')),
        );
      }
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  final List<String> imageUrls = [
    'assets/slider1.png',
    'assets/slider2.png',
    'assets/slider4.jpg',
    'assets/slider3.png',
    'assets/slider5.png',
  ];

  // ─── PREMIUM CHIP WIDGET ───
  Widget _buildPremiumChip({
    required IconData icon,
    required String label,
    required Color bgColor,
    required Color iconColor,
    required Color labelColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: bgColor.withOpacity(0.5),
          width: 0.5,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: iconColor),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: labelColor,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }

  // ─── PREMIUM STATUS BADGE ───
  Widget _buildPremiumStatusBadge(dynamic project) {
    String? appliedStatus = project['applyStatus']?.toString();
    if (appliedStatus == null) return const SizedBox.shrink();

    Map<String, dynamic> statusMap = {
      "0": {
        'label': 'Applied',
        'bg': const Color(0xFFECFDF5),
        'color': const Color(0xFF065F46),
        'icon': Icons.check_circle_outline,
      },
      "1": {
        'label': 'Assigned',
        'bg': const Color(0xFFEFF6FF),
        'color': const Color(0xFF1E40AF),
        'icon': Icons.assignment_outlined,
      },
      "2": {
        'label': 'In Progress',
        'bg': const Color(0xFFFFF7ED),
        'color': const Color(0xFFC2410C),
        'icon': Icons.hourglass_top_outlined,
      },
      "3": {
        'label': 'Completed',
        'bg': const Color(0xFFECFDF5),
        'color': const Color(0xFF065F46),
        'icon': Icons.check_circle_outline,
      },
      "4": {
        'label': 'Cancelled',
        'bg': const Color(0xFFFEF2F2),
        'color': const Color(0xFF991B1B),
        'icon': Icons.cancel_outlined,
      },
    };

    var status = statusMap[appliedStatus] ?? statusMap["0"];
    String label = status['label'];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: status['bg'],
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: status['color'].withOpacity(0.2),
          width: 0.8,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(status['icon'], size: 10, color: status['color']),
          const SizedBox(width: 4),
          Text(
            translateText(label) ?? label,
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w700,
              color: status['color'],
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(String dateString) {
    if (dateString.isEmpty) return 'N/A';
    try {
      DateTime dateTime = DateTime.parse(dateString);
      return DateFormat('dd MMM yyyy').format(dateTime);
    } catch (e) {
      return dateString;
    }
  }

  // Helper to safely display days - handles both numeric and string values
  String _getDurationLabel(dynamic days, String translate(String en, String hi)) {
    if (days == null) return translateText('N/A');

    String daysStr = days.toString();

    // Try to parse as int
    int? daysInt = int.tryParse(daysStr);
    if (daysInt != null && daysInt > 0) {
      return '$daysInt ${translate('days', 'दिन')}';
    }

    // If it's a string like ">1 year", return it as-is
    return translateText(daysStr);
  }

  @override
  Widget build(BuildContext context) {
    final language =
        Provider.of<LanguageProvider>(context, listen: false).selectedLanguage;

    String translate(String enText, String hiText) {
      return language == 'en' ? enText : hiText;
    }

    return WillPopScope(
      onWillPop: () async {
        SystemNavigator.pop();
        return false;
      },
      child: RefreshIndicator(
        onRefresh: () async {
          _selectedCategoryFilter = null;
          setState(() {
            _isLoadingLocation = true;
            _locationError = '';
          });
          _fetchCurrentLocation(force: true);
          await loadLanguage();
          await fetchProjects();
          await fetchJobTypes();
          setState(() {});
        },
        child: Scaffold(
          backgroundColor: Constants.AppColors.surface,
          body: Container(
            width: double.infinity,
            color: Constants.AppColors.surface,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [


                  // ─── CAROUSEL ───
                  Container(
                    width: double.infinity,
                    height: 200,
                    margin: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(Constants.AppRadii.lg),
                      boxShadow: const [Constants.AppShadows.card],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(Constants.AppRadii.lg),
                      child: CarouselSlider.builder(
                        itemCount: imageUrls.length,
                        itemBuilder: (BuildContext context, int index,
                            int realIndex) {
                          return SizedBox(
                            width: double.infinity,
                            child: Image.asset(
                              imageUrls[index],
                              fit: BoxFit.cover,
                            ),
                          );
                        },
                        options: CarouselOptions(
                          height: 200,
                          enlargeCenterPage: false,
                          autoPlay: true,
                          aspectRatio: 16 / 9,
                          viewportFraction: 1.0,
                        ),
                      ),
                    ),
                  ),

                  // ─── SECTION TITLE ───
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    child: Text(
                      translate('Select category for job/Work',
                          'नौकरी/कार्य के लिए श्रेणी चुनें'),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1A1A2E),
                      ),
                    ),
                  ),

                  // ─── JOB CATEGORIES ───
                  if (_jobTypes.isNotEmpty)
                    SizedBox(
                      height: 128,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: _jobTypes.length,
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        itemBuilder: (context, index) {
                          JobType job = _jobTypes[index];

                          return InkWell(
                            onTap: () {
                              setState(() {
                                if (_selectedCategoryFilter == job.jobname) {
                                  _selectedCategoryFilter = null;
                                } else {
                                  _selectedCategoryFilter = job.jobname;
                                }
                                _updateFilteredProjects();
                              });
                            },
                            child: Container(
                              width: 90,
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              child: Column(
                                children: [
                                  Container(
                                    width: 70,
                                    height: 70,
                                    margin: const EdgeInsets.symmetric(
                                        horizontal: 4, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: Constants.AppColors.brandTint,
                                      shape: BoxShape.circle,
                                      border: _selectedCategoryFilter ==
                                          job.jobname
                                          ? Border.all(
                                        color: Constants.AppColors.brand,
                                        width: 2.0,
                                      )
                                          : null,
                                    ),
                                    child: Center(
                                      child: CachedNetworkImage(
                                        imageUrl:
                                        '${Constants.AppConstants.folderUrl}storage/upload/jobtypes/${job.image}',
                                        width: 42,
                                        height: 42,
                                        placeholder: (context, url) =>
                                        const CircularProgressIndicator(),
                                        errorWidget: (context, url, error) =>
                                        const Icon(Icons.error,
                                            color: Constants
                                                .AppColors.brand),
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        left: 4.0, right: 4.0, top: 4.0),
                                    child: Text(
                                      translateText(job.jobname),
                                      style: Constants.AppTypography.label
                                          .copyWith(
                                        color: Constants.AppColors.ink,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      textAlign: TextAlign.center,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),

                  const Divider(color: Constants.AppColors.border),

                  // ─── FILTER BUTTON ───
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 12.0),
                        child: IconButton(
                          icon: const Icon(Icons.filter_list,
                              color: Constants.AppColors.brand),
                          onPressed: () => _showFilterDialog(),
                        ),
                      ),
                      Text(
                        translate('Filter Projects', 'परियोजनाएं फ़िल्टर करें'),
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),

                  // ─── PROJECT LIST (PREMIUM CARDS) ───
                  if (filteredProjects.isEmpty && !isLoading)
                    Padding(
                      padding: const EdgeInsets.all(40.0),
                      child: Column(
                        children: [
                          Icon(
                            Icons.search_off,
                            size: 64,
                            color: Colors.grey.shade300,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            translate('No projects found', 'कोई परियोजना नहीं मिली'),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF94A3B8),
                            ),
                          ),
                        ],
                      ),
                    )
                  else if (isLoading)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(40.0),
                        child: CircularProgressIndicator(),
                      ),
                    )
                  else
                    ListView.builder(
                      itemCount: filteredProjects.length,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      itemBuilder: (context, index) {
                        var project = filteredProjects[index];

                        // Determine icon based on project type
                        String iconEmoji = '🌾';
                        String projectType = project['project_type'] ?? '';
                        if (projectType.contains('Crop') ||
                            projectType.contains('Farming')) {
                          iconEmoji = '🌾';
                        } else if (projectType.contains('Live') ||
                            projectType.contains('Animal')) {
                          iconEmoji = '🐄';
                        } else if (projectType.contains('Mach') ||
                            projectType.contains('Equipment')) {
                          iconEmoji = '🚜';
                        } else if (projectType.contains('Post') ||
                            projectType.contains('Harvest')) {
                          iconEmoji = '📦';
                        } else if (projectType.contains('Manage') ||
                            projectType.contains('Admin')) {
                          iconEmoji = '📊';
                        }

                        // Safely get duration label
                        String durationLabel = _getDurationLabel(
                          project['days'],
                          translate,
                        );

                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Colors.white,
                                Constants.AppColors.brandTint.withOpacity(0.08),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: Constants.AppColors.brand.withOpacity(0.12),
                              width: 1.2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Constants.AppColors.brand.withOpacity(0.06),
                                blurRadius: 20,
                                offset: const Offset(0, 6),
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ProjectDetailsPage(
                                        projectId: int.parse(project['id'].toString()),
                                      ),
                                    ),
                                  );
                                },
                                splashColor: Constants.AppColors.brand
                                    .withOpacity(0.1),
                                highlightColor: Constants.AppColors.brand
                                    .withOpacity(0.05),
                                child: Padding(
                                  padding: const EdgeInsets.all(18.0),
                                  child: Column(
                                    crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                    children: [
                                      // ── TOP ROW ──
                                      Row(
                                        crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                        children: [
                                          // Category Icon
                                          Container(
                                            width: 48,
                                            height: 48,
                                            decoration: BoxDecoration(
                                              gradient: LinearGradient(
                                                begin: Alignment.topLeft,
                                                end: Alignment.bottomRight,
                                                colors: [
                                                  Constants.AppColors
                                                      .brandTint,
                                                  Constants.AppColors
                                                      .brandSoft
                                                      .withOpacity(0.3),
                                                ],
                                              ),
                                              borderRadius:
                                              BorderRadius.circular(14),
                                            ),
                                            child: Center(
                                              child: Text(
                                                iconEmoji,
                                                style: const TextStyle(
                                                    fontSize: 22),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 14),
                                          // Title and Type
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  translateText(project[
                                                  'title']
                                                      ?.toString() ??
                                                      'No Title'),
                                                  style: const TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight
                                                        .w700,
                                                    color: Color(0xFF1A1A2E),
                                                    height: 1.3,
                                                  ),
                                                  maxLines: 2,
                                                  overflow:
                                                  TextOverflow.ellipsis,
                                                ),
                                                const SizedBox(height: 4),
                                                // Project Type Badge
                                                Container(
                                                  padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 10,
                                                      vertical: 4),
                                                  decoration: BoxDecoration(
                                                    color: Constants
                                                        .AppColors.brandTint
                                                        .withOpacity(0.5),
                                                    borderRadius:
                                                    BorderRadius.circular(
                                                        20),
                                                  ),
                                                  child: Row(
                                                    mainAxisSize:
                                                    MainAxisSize.min,
                                                    children: [
                                                      const Text('🌾',
                                                          style: TextStyle(
                                                              fontSize: 12)),
                                                      const SizedBox(width: 4),
                                                      Text(
                                                        translateText(project[
                                                        'project_type'] ??
                                                            'N/A'),
                                                        style: TextStyle(
                                                          fontSize: 11,
                                                          fontWeight:
                                                          FontWeight.w600,
                                                          color: Constants
                                                              .AppColors
                                                              .brandDeep,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          // Date Badge
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 10, vertical: 6),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFFF8FAFC),
                                              borderRadius:
                                              BorderRadius.circular(12),
                                              border: Border.all(
                                                color: const Color(0xFFE2E8F0),
                                                width: 0.8,
                                              ),
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                const Icon(
                                                  Icons
                                                      .calendar_today_outlined,
                                                  size: 11,
                                                  color: Color(0xFF64748B),
                                                ),
                                                const SizedBox(width: 4),
                                                Text(
                                                  _formatDate(project[
                                                  'created_at']
                                                      ?.toString() ??
                                                      ''),
                                                  style: const TextStyle(
                                                    fontSize: 10,
                                                    fontWeight: FontWeight.w600,
                                                    color: Color(0xFF64748B),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 14),

                                      // ── LOCATION ──
                                      Row(
                                        children: [
                                          const Icon(
                                            Icons.location_on_outlined,
                                            size: 14,
                                            color: Color(0xFF64748B),
                                          ),
                                          const SizedBox(width: 6),
                                          Expanded(
                                            child: Text(
                                              "${translateText(project['city'] ?? 'N/A')}, ${translateText(project['state'] ?? 'N/A')}",
                                              style: const TextStyle(
                                                fontSize: 13,
                                                fontWeight: FontWeight.w500,
                                                color: Color(0xFF475569),
                                              ),
                                            ),
                                          ),
                                          if (project['applyStatus'] != null)
                                            _buildPremiumStatusBadge(project),
                                        ],
                                      ),
                                      const SizedBox(height: 14),

                                      // ── STATS CHIPS ──
                                      Row(
                                        children: [
                                          _buildPremiumChip(
                                            icon: Icons.people_outline,
                                            label:
                                            '${project['qty_labours'] ?? '0'} ${translate('Workers', 'मजदूर')}',
                                            bgColor: const Color(0xFFF0FDF4),
                                            iconColor: const Color(0xFF16A34A),
                                            labelColor: const Color(0xFF166534),
                                          ),
                                          const SizedBox(width: 8),
                                          _buildPremiumChip(
                                            icon: Icons.currency_rupee,
                                            label:
                                            '₹${NumberFormat('#,##0').format(project['budget'] ?? 0)}',
                                            bgColor: const Color(0xFFFFF7ED),
                                            iconColor: const Color(0xFFEA580C),
                                            labelColor: const Color(0xFF9A3412),
                                          ),
                                          const SizedBox(width: 8),
                                          _buildPremiumChip(
                                            icon: Icons.access_time_outlined,
                                            label: durationLabel,
                                            bgColor: const Color(0xFFEFF6FF),
                                            iconColor: const Color(0xFF2563EB),
                                            labelColor: const Color(0xFF1E3A8A),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 16),

                                      // ── APPLY / VIEW DETAILS BUTTON ──
                                      Container(
                                        width: double.infinity,
                                        height: 44,
                                        decoration: BoxDecoration(
                                          gradient: Constants
                                              .AppColors.brandGradient,
                                          borderRadius:
                                          BorderRadius.circular(12),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Constants.AppColors.brand
                                                  .withOpacity(0.3),
                                              blurRadius: 12,
                                              offset: const Offset(0, 4),
                                            ),
                                          ],
                                        ),
                                        child: ElevatedButton(
                                          onPressed: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) => ProjectDetailsPage(
                                                   projectId: int.parse(project['id'].toString()),
                                                 ),
                                              ),
                                            );
                                          },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor:
                                            Colors.transparent,
                                            shadowColor: Colors.transparent,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                              BorderRadius.circular(12),
                                            ),
                                          ),
                                          child: Row(
                                            mainAxisAlignment:
                                            MainAxisAlignment.center,
                                            children: [
                                              Flexible(
                                                child: Text(
                                                  project['applyStatus'] == null
                                                      ? translate('Apply Now',
                                                      'अभी आवेदन करें')
                                                      : translate('View Details',
                                                      'विवरण देखें'),
                                                  style: const TextStyle(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w700,
                                                    color: Colors.white,
                                                    letterSpacing: 0.5,
                                                  ),
                                                  overflow: TextOverflow.ellipsis,
                                                  softWrap: true,
                                                  maxLines: 1,
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              const Icon(
                                                Icons
                                                    .arrow_forward_ios_rounded,
                                                size: 14,
                                                color: Colors.white,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),

                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}