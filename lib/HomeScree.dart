// import 'dart:async';
// import 'package:greencollar/speech_helper.dart';
// import 'dart:convert';
// import 'dart:io';
// import 'package:geolocator/geolocator.dart';
// import 'package:geocoding/geocoding.dart';
// import 'package:greencollar/l10n/app_localizations.dart';
//
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_secure_storage/flutter_secure_storage.dart';
// import 'package:greencollar/Addproject.dart';
// import 'package:greencollar/NearbyProject.dart';
// import 'package:greencollar/Nearbylabours.dart';
// import 'package:greencollar/ProjectDetails.dart';
// import 'package:greencollar/UpdateProject.dart';
// import 'package:greencollar/application_detaill.dart';
// import 'package:greencollar/main.dart';
// import 'package:greencollar/noti.dart';
// import 'package:greencollar/updateprofile.dart';
// import 'package:greencollar/workerdetails.dart';
// import 'package:intl/intl.dart';
// import 'package:permission_handler/permission_handler.dart';
// import 'package:provider/provider.dart';
// import 'package:http/http.dart' as http;
// import 'package:speech_to_text/speech_to_text.dart' as stt;
// import 'package:translator/translator.dart';
// import 'package:url_launcher/url_launcher.dart';
// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:greencollar/constants.dart' as Constants;
// import 'package:carousel_slider/carousel_slider.dart';
// import 'package:smooth_page_indicator/smooth_page_indicator.dart';
// import 'package:greencollar/wallet_helper.dart';
// import 'package:greencollar/api_logger.dart';
//
// class JobType {
//   final int id;
//   final String jobname;
//   final String image;
//   final String status;
//
//   JobType(
//       {required this.id,
//       required this.jobname,
//       required this.image,
//       required this.status});
//
//   factory JobType.fromJson(Map<String, dynamic> json) {
//     return JobType(
//       id: json['id'],
//       jobname: json['jobname'],
//       image: json['image'],
//       status: json['status'],
//     );
//   }
// }
//
// class HomePage extends StatefulWidget {
//   @override
//   _HomePageState createState() => _HomePageState();
// }
//
// class _HomePageState extends State<HomePage> {
//   int _currentIndex = 0;
//   final _secureStorage = const FlutterSecureStorage();
//
//   String _selectedLanguage = 'en'; // Default language is English
//   String _userName = '';
//   String _userType = '';
//   int _walletCoins = 0;
//
//   Future<void> _loadWalletBalance() async {
//     int coins = await WalletHelper.getCoins();
//     if (mounted) {
//       setState(() {
//         _walletCoins = coins;
//       });
//     }
//   }
//
//   Future<void> _loadUserInfo() async {
//     String? name = await _secureStorage.read(key: 'name');
//     String? userType = await _secureStorage.read(key: 'userType');
//     setState(() {
//       _userName = name ?? '';
//       _userType = userType ?? 'farmer';
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
//   Map<String, Map<String, String>> _cachedTranslations = {};
//   int unreadNotificationsCount = 0; // To store unread notifications count
//
//   Map<String, Map<String, String>> translations =
//       Constants.AppConstants.translations;
//   final GoogleTranslator _translator = GoogleTranslator();
//   @override
//   void initState() {
//     super.initState();
//     loadLanguage();
//     _loadUserInfo();
//     _loadWalletBalance();
//     ApiLogger.logScreenOpened('CombinedPage');
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
//         '${Constants.AppConstants.apiUrl}farmer/getUnreadNotificationsCount');
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
//                 responseData['unread_notifications_count'];
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
//   Future<String> translateText(String text) async {
//     if (text.isEmpty) return "";
//
//     String targetLang = _selectedLanguage ?? 'en'; // Default to English
//
//     // ✅ Check manual translations first
//     if (translations.containsKey(text) &&
//         translations[text]!.containsKey(targetLang)) {
//       return translations[text]![targetLang]!;
//     }
//
//     // ✅ Check cached translations
//     if (_cachedTranslations.containsKey(text) &&
//         _cachedTranslations[text]!.containsKey(targetLang)) {
//       return _cachedTranslations[text]![targetLang]!;
//     }
//
//     // ✅ Fetch translation dynamically (NOW WITH AWAIT)
//     String translatedText =
//         await _fetchTranslation(text, targetLang); // 🚀 Always waits
//     return translatedText;
//   }
//
//   Future<String> _fetchTranslation(String text, String targetLang) async {
//     try {
//       // ✅ Check if translation already exists in constants
//       if (Constants.AppConstants.translations.containsKey(text) &&
//           Constants.AppConstants.translations[text]!.containsKey(targetLang)) {
//         return Constants.AppConstants.translations[text]![targetLang]!;
//       }
//
//       // ✅ Fetch translation dynamically
//       final translation = await _translator.translate(text, to: targetLang);
//
//       // ✅ Store in local translations
//       translations.putIfAbsent(text, () => {});
//       translations[text]![targetLang] = translation.text;
//
//       // ✅ Store in cache
//       _cachedTranslations.putIfAbsent(text, () => {});
//       _cachedTranslations[text]![targetLang] = translation.text;
//
//       // ✅ Store in global constants map
//       Constants.AppConstants.translations.putIfAbsent(text, () => {});
//       Constants.AppConstants.translations[text]![targetLang] = translation.text;
//
//       setState(() {}); // ✅ Update UI with translated text
//
//       return translation.text;
//     } catch (e) {
//       return text; // Return original text if translation fails
//     }
//   }
//
//   final List<Widget> _pages = [
//     CombinedPage(),
//     LabourPage(),
//     ProjectPage(),
//   ];
//   Future<void> _logout(BuildContext context) async {
//     await _secureStorage.delete(key: 'id'); // Clear the user ID from storage
//     Navigator.pushReplacement(
//       context,
//       MaterialPageRoute(builder: (context) => const LoginScreen()),
//     );
//   }
//
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
//           child: Icon(
//             icon,
//             color: iconColor,
//             size: 20,
//           ),
//         ),
//         title: title,
//         trailing: trailing ?? Icon(
//           Icons.chevron_right_rounded,
//           color: isLogout ? const Color(0xFFEF4444) : const Color(0xFF9CA3AF),
//           size: 20,
//         ),
//         onTap: onTap,
//       ),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return WillPopScope(
//       onWillPop: () async {
//         SystemNavigator.pop();
//         return false;
//       },
//       child: Scaffold(
//         extendBody: true,
//         appBar: AppBar(
//           title: _currentIndex == 0
//               ? Row(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     Container(
//                       padding: const EdgeInsets.symmetric(
//                           horizontal: 8, vertical: 3),
//                       decoration: BoxDecoration(
//                         color: Colors.white.withOpacity(0.20),
//                         borderRadius: BorderRadius.circular(Constants.AppRadii.sm),
//                         border: Border.all(color: Colors.white30, width: 0.5),
//                       ),
//                       child: Text(
//                         _selectedLanguage == 'en' ? 'Farmer' : 'किसान',
//                         style: Constants.AppTypography.micro.copyWith(
//                           color: Colors.white,
//                         ),
//                       ),
//                     ),
//                   ],
//                 )
//               : Text(
//                   _currentIndex == 1
//                       ? AppLocalizations.of(context)!.nearbylabours
//                       : _currentIndex == 2
//                           ? AppLocalizations.of(context)!.yourprojects
//                           : 'Default Title',
//                   style: Constants.AppTypography.h1.copyWith(color: Colors.white),
//                 ),
//           iconTheme: const IconThemeData(color: Colors.white),
//           flexibleSpace: Container(
//             decoration: const BoxDecoration(
//               gradient: Constants.AppColors.brandGradient,
//             ),
//           ),
//           actions: [
//             WalletHelper.buildWalletButton(
//               coinBalance: _walletCoins,
//               onTap: () {
//                 WalletHelper.showCoinShop(context, onCoinsAdded: (newBalance) {
//                   setState(() => _walletCoins = newBalance);
//                 });
//               },
//             ),
//             // Show the unread notification count in the AppBar using a badge
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
//                             fontSize: 12,
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
//                   MaterialPageRoute(builder: (context) => NotificationsPage()),
//                 );
//                 print('Notifications tapped');
//               },
//             ),
//           ],
//         ),
//         drawer: Drawer(
//           backgroundColor: Colors.white,
//           child: Column(
//             children: [
//               // Premium Brand Header Container
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
//                             padding: const EdgeInsets.symmetric(
//                                 horizontal: 8, vertical: 4),
//                             decoration: BoxDecoration(
//                               color: Colors.white.withOpacity(0.15),
//                               borderRadius: BorderRadius.circular(12),
//                             ),
//                             child: Text(
//                               _userType == 'labour'
//                                   ? (context.watch<LanguageProvider>().selectedLanguage == 'en' ? 'Worker' : 'श्रमिक')
//                                   : (context.watch<LanguageProvider>().selectedLanguage == 'en' ? 'Farmer' : 'किसान'),
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
//                     // Elegant Close Button
//                     GestureDetector(
//                       onTap: () => Navigator.pop(context),
//                       child: Container(
//                         height: 36,
//                         width: 36,
//                         decoration: BoxDecoration(
//                           color: Colors.white.withOpacity(0.15),
//                           shape: BoxShape.circle,
//                         ),
//                         child: const Icon(
//                           Icons.close,
//                           color: Colors.white,
//                           size: 18,
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//
//               // Scrollable Menu List
//               Expanded(
//                 child: ListView(
//                   padding: const EdgeInsets.symmetric(vertical: 12),
//                   children: [
//                     // Home
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
//                         setState(() {
//                           _currentIndex = 0;
//                         });
//                         Navigator.pop(context);
//                       },
//                     ),
//
//                     // Search
//                     _buildDrawerTile(
//                       icon: Icons.search,
//                       title: FutureBuilder<String>(
//                         future: translateText('Search'),
//                         builder: (context, snapshot) {
//                           return Text(
//                             snapshot.data ?? 'Search',
//                             style: const TextStyle(fontWeight: FontWeight.bold),
//                           );
//                         },
//                       ),
//                       onTap: () {
//                         setState(() {
//                           _currentIndex = 1;
//                         });
//                         Navigator.pop(context);
//                       },
//                     ),
//
//                     // Notifications
//                     _buildDrawerTile(
//                       icon: Icons.notifications,
//                       title: FutureBuilder<String>(
//                         future: translateText('Notifications'),
//                         builder: (context, snapshot) {
//                           return Row(
//                             children: [
//                               Text(
//                                 snapshot.data ?? 'Notifications',
//                                 style: const TextStyle(fontWeight: FontWeight.bold),
//                               ),
//                               if (unreadNotificationsCount > 0)
//                                 Padding(
//                                   padding: const EdgeInsets.only(left: 8.0),
//                                   child: CircleAvatar(
//                                     radius: 10,
//                                     backgroundColor: Colors.red,
//                                     child: Text(
//                                       unreadNotificationsCount.toString(),
//                                       style: const TextStyle(
//                                         fontSize: 12,
//                                         color: Colors.white,
//                                       ),
//                                     ),
//                                   ),
//                                 ),
//                             ],
//                           );
//                         },
//                       ),
//                       onTap: () {
//                         Navigator.pushReplacement(
//                           context,
//                           MaterialPageRoute(
//                               builder: (context) => NotificationsPage()),
//                         );
//                       },
//                     ),
//
//                     // Select Language
//                     _buildDrawerTile(
//                       icon: Icons.language,
//                       title: FutureBuilder<String>(
//                         future: translateText(' Select Language'),
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
//                           MaterialPageRoute(
//                             builder: (context) => LanguageSelectionScreen(),
//                           ),
//                         );
//                       },
//                     ),
//
//                     // Projects
//                     _buildDrawerTile(
//                       icon: Icons.notes,
//                       title: FutureBuilder<String>(
//                         future: translateText('Projects'),
//                         builder: (context, snapshot) {
//                           return Text(
//                             snapshot.data ?? 'Projects',
//                             style: const TextStyle(fontWeight: FontWeight.bold),
//                           );
//                         },
//                       ),
//                       onTap: () {
//                         setState(() {
//                           _currentIndex = 2;
//                         });
//                         Navigator.pop(context);
//                       },
//                     ),
//
//                     // Profile
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
//                           MaterialPageRoute(
//                             builder: (context) => UpdateLabourProfile(),
//                           ),
//                         );
//                       },
//                     ),
//
//                     const Divider(color: Constants.AppColors.border, height: 24, thickness: 1),
//
//                     // Logout
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
//             decoration: BoxDecoration(
//               gradient: Constants.AppColors.brandGradient,
//               borderRadius: BorderRadius.circular(28),
//               boxShadow: const [Constants.AppShadows.fab],
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
//                       label: AppLocalizations.of(context)!.nearbylabours),
//                   BottomNavigationBarItem(
//                       icon: const Icon(Icons.person),
//                       label: AppLocalizations.of(context)!.yourprojects),
//                 ],
//                 onTap: (index) {
//                   setState(() {
//                     _currentIndex = index;
//                   });
//                   final pages = ['CombinedPage', 'LabourPage', 'ProjectPage'];
//                   if (index >= 0 && index < pages.length) {
//                     ApiLogger.logScreenOpened(pages[index]);
//                   }
//                 },
//               ),
//             ),
//           ),
//         ),
//         floatingActionButton: Container(
//           decoration: BoxDecoration(
//             gradient: Constants.AppColors.brandGradient,
//             borderRadius: BorderRadius.circular(999),
//             boxShadow: const [Constants.AppShadows.fab],
//           ),
//           child: FloatingActionButton.extended(
//             onPressed: () {
//               Navigator.push(
//                 context,
//                 MaterialPageRoute(
//                   builder: (context) => AddProjectForm(),
//                 ),
//               );
//             },
//             backgroundColor: Colors.transparent,
//             elevation: 0,
//             highlightElevation: 0,
//             label: Text(
//               AppLocalizations.of(context)!.addProject,
//               style: Constants.AppTypography.body.copyWith(
//                 color: Colors.white,
//                 fontWeight: FontWeight.w700,
//               ),
//             ),
//           ),
//         ),
//         floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
//       ),
//     );
//   }
// }
//
// class Dashboard extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Center(
//       child: Text(
//         "Welcome to the Home Page",
//         style: TextStyle(fontSize: 24, color: Constants.AppColors.brand),
//       ),
//     );
//   }
// }
//
// class SearchPage extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Center(
//       child: Text(
//         "Search for something here!",
//         style: TextStyle(fontSize: 24, color: Constants.AppColors.brand),
//       ),
//     );
//   }
// }
//
// class CombinedPage extends StatefulWidget {
//   @override
//   _CombinedPageState createState() => _CombinedPageState();
// }
//
// class _CombinedPageState extends State<CombinedPage> with WidgetsBindingObserver {
//   static String _cachedCity = '';
//   static String _cachedState = '';
//   static String _cachedError = '';
//
//   final FlutterSecureStorage _secureStorage = FlutterSecureStorage();
//   final TextEditingController _projectSearchController =
//       TextEditingController();
//   final TextEditingController _labourSearchController = TextEditingController();
//   late Future<List<JobType>> _jobTypes;
//
//   List<dynamic> projects = [];
//   List<dynamic> filteredProjects = [];
//   List<dynamic> labours = [];
//   bool isLoading = false;
//   int _currentIndex = 0; // To track the current index of the carousel
// // Use PageController here
//   String _selectedLanguage = 'en'; // Default language is English
//
//   Future<void> loadLanguage() async {
//     // Read the selected language from FlutterSecureStorage
//     String? language = await _secureStorage.read(key: 'selectedLanguage');
//     _selectedLanguage = language ?? 'en';
//   }
//
//   Map<String, Map<String, String>> _cachedTranslations = {};
//
//   Map<String, Map<String, String>> translations =
//       Constants.AppConstants.translations;
//   final GoogleTranslator _translator = GoogleTranslator();
//   late stt.SpeechToText _speech;
//   late PageController _pageController;
//   late Timer _timer;
//
//   // Location state variables
//   String _currentCity = '';
//   String _currentState = '';
//   bool _isLoadingLocation = true;
//   String _locationError = '';
//
//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addObserver(this);
//     _speech = stt.SpeechToText();
//
//     _pageController = PageController();
//
//     _jobTypes =
//         fetchJobTypes(); // Assuming you have this function to fetch the job types
//     fetchLabours();
//     _fetchCurrentLocation();
//   }
//
//   @override
//   void dispose() {
//     WidgetsBinding.instance.removeObserver(this);
//     _pageController.dispose();
//     _timer.cancel();
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
//           targetLang]!; // Return cached translation
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
//   // Function to automatically scroll the carousel every 3 seconds
//   void _startAutoScroll() {
//     Timer.periodic(Duration(seconds: 3), (Timer timer) {
//       if (_pageController.hasClients) {
//         // Scroll to the next index
//         _currentIndex = (_currentIndex + 1) %
//             1; // Change 5 with the number of items in your list
//
//         // Looping back to the first index when it reaches the end
//         _pageController.animateToPage(
//           _currentIndex,
//           duration: Duration(seconds: 1),
//           curve: Curves.easeInOut,
//         );
//       }
//     });
//   }
//
//   bool _isListening = false;
//   String _searchText = '';
//
//   void _startListening() async {
//     // Get selected language from the provider
//     final language =
//         Provider.of<LanguageProvider>(context, listen: false).selectedLanguage;
//
//     // Set the locale based on the selected language
//     String localeId = language == 'en'
//         ? 'en_US'
//         : 'hi_IN'; // 'en' for English, 'hi' for Hindi
//
//     bool available = await _speech.initialize();
//     if (available) {
//       setState(() {
//         _isListening = true;
//       });
//
//       // Start listening and use the localeId based on selected language
//       _speech.listen(
//         localeId: localeId,
//         onResult: (result) {
//           setState(() {
//             _searchText = result.recognizedWords;
//             _labourSearchController.text = _searchText;
//             fetchLabours(searchQuery: _searchText);
//           });
//         },
//       );
//     } else {
//       // Handle speech recognition not available
//       print("Speech recognition is not available.");
//     }
//   }
//
//   void _stopListening() {
//     setState(() {
//       _isListening = false;
//     });
//     _speech.stop();
//   }
//
//   Future<List<JobType>> fetchJobTypes() async {
//     final response = await http
//         .post(Uri.parse('${Constants.AppConstants.apiUrl}farmer/jobtype'));
//
//     if (response.statusCode == 200) {
//       final Map<String, dynamic> data = json.decode(response.body);
//       List<dynamic> jobData = data['data'];
//       return jobData.map((job) => JobType.fromJson(job)).toList();
//     } else {
//       throw Exception('Failed to load job types');
//     }
//   }
//
//   String _formatDate(String dateString) {
//     try {
//       // Parse the date string to DateTime object
//       DateTime dateTime = DateTime.parse(dateString);
//       // Format the DateTime object to "dd-MM-yyyy"
//       return DateFormat('dd-MM-yyyy').format(dateTime);
//     } catch (e) {
//       // In case of any error, return the original date string
//       return dateString;
//     }
//   }
//
//   Future<void> fetchLabours({String? searchQuery}) async {
//     setState(() {
//       isLoading = true;
//     });
//
//     String? userId = await _secureStorage.read(key: 'id');
//     if (userId == null) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('User ID not found in secure storage')),
//       );
//       setState(() {
//         isLoading = false;
//       });
//       return;
//     }
//
//     // Define the API URL
//     final apiUrl = (searchQuery != null && searchQuery.isNotEmpty)
//         ? '${Constants.AppConstants.apiUrl}farmer/searchnearbylabours'
//         : '${Constants.AppConstants.apiUrl}farmer/nearbylabours';
//
//     // Define the request body based on the condition
//     final Map<String, dynamic> requestBody =
//         (searchQuery != null && searchQuery.isNotEmpty)
//             ? {'search': searchQuery}
//             : {'id': userId};
//     print(jsonEncode(requestBody));
//     print(jsonEncode(apiUrl));
//
//     try {
//       final response = await http.post(
//         Uri.parse(apiUrl),
//         headers: {'Content-Type': 'application/json'},
//         body: jsonEncode(requestBody),
//       );
//
//       if (response.statusCode == 200) {
//         final responseData = jsonDecode(response.body);
//         if (responseData['success'] == true) {
//           setState(() {
//             labours = responseData['data'];
//             isExpandedList = List.generate(labours.length, (index) => false);
//           });
//         } else {
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(
//                 content: Text(responseData['message'] ?? 'No labours found')),
//           );
//         }
//       } else {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('Failed to fetch labours')),
//         );
//       }
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Error: $e')),
//       );
//     } finally {
//       setState(() {
//         isLoading = false;
//       });
//     }
//   }
//
//   void filterProjects(String query) {
//     setState(() {
//       filteredProjects = projects.where((project) {
//         String title = project['title'] ?? '';
//         String budget = project['budget']?.toString() ?? '';
//         String city = project['city'] ?? '';
//         String state = project['state'] ?? '';
//
//         return title.toLowerCase().contains(query.toLowerCase()) ||
//             budget.toLowerCase().contains(query.toLowerCase()) ||
//             city.toLowerCase().contains(query.toLowerCase()) ||
//             state.toLowerCase().contains(query.toLowerCase());
//       }).toList();
//     });
//   }
//
//   final List<String> imageUrls = [
//     'assets/slider1.png',
//     'assets/slider2.png',
//     'assets/slider4.jpg',
//     'assets/slider3.png',
//     'assets/slider5.png',
//   ];
//   Future<void> fetchProjects() async {
//     final String apiUrl = '${Constants.AppConstants.apiUrl}farmer/getprojects';
//
//     String? userId = await _secureStorage.read(key: 'id');
//     if (userId == null) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('User ID not found in secure storage')),
//       );
//       return;
//     }
//
//     final Map<String, dynamic> requestBody = {'id': userId};
//
//     try {
//       final response = await http.post(
//         Uri.parse(apiUrl),
//         headers: {'Content-Type': 'application/json'},
//         body: jsonEncode(requestBody),
//       );
//
//       if (response.statusCode == 200) {
//         final responseData = jsonDecode(response.body);
//         setState(() {
//           projects = responseData['data'];
//           filteredProjects = projects;
//         });
//       } else {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Failed to fetch projects: ${response.body}')),
//         );
//       }
//     } catch (e) {}
//   }
//
//   void _startAutoScrolling(int itemCount) {
//     _timer = Timer.periodic(Duration(seconds: 3), (Timer timer) {
//       if (_pageController.hasClients) {
//         setState(() {
//           _currentIndex = (_currentIndex + 1) % itemCount; // Loop through items
//         });
//
//         // Animate to the next page (next job type)
//         _pageController.animateToPage(
//           _currentIndex,
//           duration: Duration(seconds: 1),
//           curve: Curves.easeInOut,
//         );
//       }
//     });
//   }
//
//   List<bool> isExpandedList =
//       []; // List to track if the text is expanded for each item
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
//           onRefresh: () async {
//             // Assuming loadLanguage, fetchProjects, and fetchJobTypes are async functions.
//             Navigator.push(
//               context,
//               MaterialPageRoute(
//                 builder: (context) => HomePage(),
//               ),
//             );
//
//             setState(() {
//               // If you need to update the UI state, you can do it here after all async tasks are done.
//             });
//           },
//           child: Scaffold(
//             body: Container(
//               width: double.infinity,
//               height: double.infinity,
//               decoration: BoxDecoration(color: Colors.white),
//               child: SingleChildScrollView(
//                 // Using SingleChildScrollView for the main scrolling
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     // Current Location Display
//                     // Current Location Display notice banner
//                     if (_locationError.isNotEmpty || _isLoadingLocation)
//                       Container(
//                         margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//                         padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//                         decoration: BoxDecoration(
//                           color: const Color(0xFFFFF9E6), // Amber notice tint
//                           borderRadius: BorderRadius.circular(14),
//                           border: Border.all(
//                             color: Constants.AppColors.amberNotice.withOpacity(0.4),
//                             width: 1.0,
//                           ),
//                         ),
//                         child: Row(
//                           children: [
//                             const Icon(
//                               Icons.location_off,
//                               color: Constants.AppColors.amberNotice,
//                               size: 20,
//                             ),
//                             const SizedBox(width: 8),
//                             Expanded(
//                               child: _isLoadingLocation
//                                   ? Row(
//                                       children: [
//                                         const SizedBox(
//                                           width: 14,
//                                           height: 14,
//                                           child: CircularProgressIndicator(
//                                             strokeWidth: 2,
//                                             valueColor:
//                                                 AlwaysStoppedAnimation<Color>(
//                                                     Constants.AppColors.amberNotice),
//                                           ),
//                                         ),
//                                         const SizedBox(width: 8),
//                                         Text(
//                                           translate('Fetching location...', 'स्थान प्राप्त हो रहा है...'),
//                                           style: Constants.AppTypography.label.copyWith(
//                                             color: Constants.AppColors.inkSoft,
//                                           ),
//                                         ),
//                                       ],
//                                     )
//                                   : Text(
//                                       _locationError,
//                                       style: Constants.AppTypography.label.copyWith(
//                                         color: Constants.AppColors.inkSoft,
//                                       ),
//                                     ),
//                             ),
//                           ],
//                         ),
//                       )
//                     else if (_currentCity.isNotEmpty)
//                       Container(
//                         margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//                         padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//                         decoration: BoxDecoration(
//                           color: Constants.AppColors.brandTint,
//                           borderRadius: BorderRadius.circular(14),
//                           border: Border.all(
//                             color: Constants.AppColors.brandSoft.withOpacity(0.3),
//                             width: 1.0,
//                           ),
//                         ),
//                         child: Row(
//                           children: [
//                             const Icon(
//                               Icons.location_on,
//                               color: Constants.AppColors.brand,
//                               size: 20,
//                             ),
//                             const SizedBox(width: 8),
//                             Expanded(
//                               child: Text(
//                                 '$_currentCity, $_currentState',
//                                 style: Constants.AppTypography.label.copyWith(
//                                   color: Constants.AppColors.brandDeep,
//                                   fontWeight: FontWeight.w700,
//                                 ),
//                               ),
//                             ),
//                             GestureDetector(
//                               onTap: () {
//                                 setState(() {
//                                   _isLoadingLocation = true;
//                                   _locationError = '';
//                                 });
//                                 _fetchCurrentLocation(force: true);
//                               },
//                               child: const Icon(
//                                 Icons.refresh,
//                                 color: Constants.AppColors.brand,
//                                 size: 18,
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     Container(
//                       width: double.infinity,
//                       height: 200,
//                       margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//                       decoration: BoxDecoration(
//                         borderRadius: BorderRadius.circular(20),
//                         boxShadow: const [Constants.AppShadows.card],
//                       ),
//                       child: ClipRRect(
//                         borderRadius: BorderRadius.circular(20),
//                         child: CarouselSlider.builder(
//                           itemCount: imageUrls.length,
//                           itemBuilder:
//                               (BuildContext context, int index, int realIndex) {
//                             return SizedBox(
//                               width: double.infinity,
//                               child: Image.asset(
//                                 imageUrls[index],
//                                 fit: BoxFit.cover,
//                               ),
//                             );
//                           },
//                           options: CarouselOptions(
//                             height: 200,
//                             enlargeCenterPage: false,
//                             autoPlay: true,
//                             aspectRatio: 16 / 9,
//                             viewportFraction: 1.0,
//                           ),
//                         ),
//                       ),
//                     ),
//                     Padding(
//                       padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
//                       child: _buildSectionTitle(
//                         translate('Select category for job/Work',
//                             'नौकरी/कार्य के लिए श्रेणी चुनें'),
//                       ),
//                     ),
//                     Padding(
//                       padding: const EdgeInsets.symmetric(vertical: 8.0),
//                       child: FutureBuilder<List<JobType>>(
//                         future:
//                             _jobTypes, // Replace with your future call to fetch data
//                         builder: (context, snapshot) {
//                           if (snapshot.connectionState ==
//                               ConnectionState.waiting) {
//                             return const Center(
//                                 child: CircularProgressIndicator());
//                           } else if (snapshot.hasError) {
//                             return const Center(
//                                 child: Text('Error fetching job types'));
//                           } else if (!snapshot.hasData ||
//                               snapshot.data!.isEmpty) {
//                             return const Center(
//                                 child: Text('No data available'));
//                           } else {
//                             List<JobType> jobTypes = snapshot.data!;
//                             _startAutoScrolling(jobTypes
//                                 .length); // Start the auto-scrolling logic
//
//                             return Container(
//                               height: 128,
//                               child: ListView.builder(
//                                 scrollDirection: Axis.horizontal,
//                                 padding: const EdgeInsets.symmetric(horizontal: 16),
//                                 itemCount: jobTypes.length,
//                                 itemBuilder: (context, index) {
//                                   JobType job = jobTypes[index];
//
//                                   return InkWell(
//                                     onTap: () {
//                                       Navigator.push(
//                                         context,
//                                         MaterialPageRoute(
//                                           builder: (context) => AddProjectForm(
//                                             projectType: job.jobname,
//                                           ),
//                                         ),
//                                       );
//                                     },
//                                     child: SizedBox(
//                                       width: 90,
//                                       child: Column(
//                                         children: [
//                                           Container(
//                                             width: 70,
//                                             height: 70,
//                                             margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
//                                             decoration: const BoxDecoration(
//                                               color: Constants.AppColors.brandTint,
//                                               shape: BoxShape.circle,
//                                             ),
//                                             child: Center(
//                                               child: CachedNetworkImage(
//                                                 imageUrl:
//                                                     '${Constants.AppConstants.folderUrl}storage/upload/jobtypes/${job.image}',
//                                                 width: 42,
//                                                 height: 42,
//                                                 placeholder: (context, url) => const Center(
//                                                   child: SizedBox(
//                                                     width: 20,
//                                                     height: 20,
//                                                     child: CircularProgressIndicator(strokeWidth: 2),
//                                                   ),
//                                                 ),
//                                                 errorWidget: (context, url, error) => const Icon(
//                                                     Icons.error, color: Constants.AppColors.brand),
//                                               ),
//                                             ),
//                                           ),
//                                           Padding(
//                                             padding: const EdgeInsets.only(left: 4.0, right: 4.0, top: 4.0),
//                                             child: Text(
//                                               translateText(job.jobname),
//                                               style: Constants.AppTypography.label.copyWith(
//                                                 color: Constants.AppColors.ink,
//                                                 fontWeight: FontWeight.bold,
//                                               ),
//                                               textAlign: TextAlign.center,
//                                               maxLines: 2,
//                                               overflow: TextOverflow.ellipsis,
//                                             ),
//                                           ),
//                                         ],
//                                       ),
//                                     ),
//                                   );
//                                 },
//                               ),
//                             );
//                           }
//                         },
//                       ),
//                     ),
//                       Padding(
//                       padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
//                       child: Container(
//                         decoration: BoxDecoration(
//                           color: Constants.AppColors.card,
//                           borderRadius: BorderRadius.circular(16),
//                           boxShadow: const [Constants.AppShadows.soft],
//                         ),
//                         child: TextField(
//                           controller: _labourSearchController,
//                           onChanged: (value) {
//                             fetchLabours(searchQuery: value);
//                           },
//                           style: Constants.AppTypography.body,
//                           decoration: InputDecoration(
//                             prefixIcon: const Icon(
//                               Icons.search,
//                               color: Constants.AppColors.brand,
//                               size: 20,
//                             ),
//                             suffixIcon: MicIconButton(controller: _labourSearchController),
//                             hintText: AppLocalizations.of(context)!.searchlabour,
//                             hintStyle: Constants.AppTypography.body.copyWith(
//                               color: Constants.AppColors.inkSoft,
//                             ),
//                             fillColor: Colors.transparent,
//                             filled: true,
//                             contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
//                             border: OutlineInputBorder(
//                               borderRadius: BorderRadius.circular(16),
//                               borderSide: const BorderSide(color: Constants.AppColors.border),
//                             ),
//                             enabledBorder: OutlineInputBorder(
//                               borderRadius: BorderRadius.circular(16),
//                               borderSide: const BorderSide(color: Constants.AppColors.border),
//                             ),
//                             focusedBorder: OutlineInputBorder(
//                               borderRadius: BorderRadius.circular(16),
//                               borderSide: const BorderSide(color: Constants.AppColors.brand, width: 1.5),
//                             ),
//                           ),
//                         ),
//                       ),
//                     ),
//                     const Divider(), // Divider to separate search field from list
//                     // Labours List
//                     labours.isEmpty
//                         ? Center(
//                             child: Text(
//                               translate('Looking for nearby workers',
//                                   'आसपास के मजदूरों की तलाश की जा रही है'),
//                               style: TextStyle(
//                                 fontSize: 18,
//                                 fontWeight: FontWeight.w500,
//                                 color: Colors.brown,
//                               ),
//                             ),
//                           )
//                         : Padding(
//                             padding: const EdgeInsets.all(8.0),
//                             child: ListView.builder(
//                               shrinkWrap: true,
//                               physics: const NeverScrollableScrollPhysics(),
//                               itemCount: labours.length,
//                               itemBuilder: (context, index) {
//                                 final labour = labours[index];
//
//                                 return InkWell(
//                                   onTap: () {
//                                     Navigator.push(
//                                       context,
//                                       MaterialPageRoute(
//                                         builder: (context) => LabourDetailsPage(
//                                           labour: labour,
//                                         ),
//                                       ),
//                                     );
//                                   },
//                                   child: Container(
//                                     margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//                                     decoration: BoxDecoration(
//                                       color: Constants.AppColors.card,
//                                       borderRadius: BorderRadius.circular(Constants.AppRadii.lg),
//                                       border: Border.all(color: Constants.AppColors.border, width: 1.0),
//                                       boxShadow: const [Constants.AppShadows.card],
//                                     ),
//                                     child: ClipRRect(
//                                       borderRadius: BorderRadius.circular(Constants.AppRadii.lg),
//                                       child: IntrinsicHeight(
//                                         child: Row(
//                                           crossAxisAlignment: CrossAxisAlignment.stretch,
//                                           children: [
//                                             // Vertical brand indicator bar
//                                             Container(
//                                               width: 5,
//                                               color: Constants.AppColors.brand,
//                                             ),
//                                             Expanded(
//                                               child: Padding(
//                                                 padding: const EdgeInsets.all(12.0),
//                                                 child: Column(
//                                                   crossAxisAlignment: CrossAxisAlignment.start,
//                                                   mainAxisAlignment: MainAxisAlignment.start,
//                                                   children: [
//                                                     Row(
//                                                       crossAxisAlignment: CrossAxisAlignment.start,
//                                                       children: [
//                                                         Container(
//                                                           width: 50,
//                                                           height: 50,
//                                                           decoration: BoxDecoration(
//                                                             color: Constants.AppColors.brandTint,
//                                                             borderRadius: BorderRadius.circular(14),
//                                                           ),
//                                                           child: labour['profile'] != null && labour['profile'].isNotEmpty
//                                                               ? ClipRRect(
//                                                                   borderRadius: BorderRadius.circular(14),
//                                                                   child: Image.network(
//                                                                     '${Constants.AppConstants.folderUrl}storage/upload/labourprofile/${labour['profile']}',
//                                                                     fit: BoxFit.cover,
//                                                                     errorBuilder: (context, error, stackTrace) {
//                                                                       return const Icon(
//                                                                         Icons.person,
//                                                                         color: Constants.AppColors.brand,
//                                                                         size: 30,
//                                                                       );
//                                                                     },
//                                                                   ),
//                                                                 )
//                                                               : const Icon(
//                                                                   Icons.person,
//                                                                   color: Constants.AppColors.brand,
//                                                                   size: 30,
//                                                                 ),
//                                                         ),
//                                                         Expanded(
//                                                           child: Padding(
//                                                             padding: const EdgeInsets.only(left: 16.0),
//                                                             child: Column(
//                                                               mainAxisAlignment: MainAxisAlignment.start,
//                                                               crossAxisAlignment: CrossAxisAlignment.start,
//                                                               children: [
//                                                                 Text(
//                                                                   translateText(labour['name'] ?? 'Unknown'),
//                                                                   style: Constants.AppTypography.h3.copyWith(
//                                                                     color: Constants.AppColors.ink,
//                                                                     fontWeight: FontWeight.w800,
//                                                                   ),
//                                                                 ),
//                                                                 const SizedBox(height: 4),
//                                                                 Row(
//                                                                   children: [
//                                                                     const Icon(Icons.location_on, size: 14, color: Constants.AppColors.brand),
//                                                                     const SizedBox(width: 4),
//                                                                     Expanded(
//                                                                       child: Text(
//                                                                         '${translateText(labour['city'] ?? 'Unknown City')}',
//                                                                         style: Constants.AppTypography.subhead.copyWith(
//                                                                           color: Constants.AppColors.inkSoft,
//                                                                           fontWeight: FontWeight.w600,
//                                                                         ),
//                                                                         overflow: TextOverflow.ellipsis,
//                                                                       ),
//                                                                     ),
//                                                                   ],
//                                                                 ),
//                                                                 if (labour['aboutme'] != null && labour['aboutme'].toString().isNotEmpty) ...[
//                                                                   const SizedBox(height: 8),
//                                                                   Text(
//                                                                     labour['aboutme'] ?? 'N/A',
//                                                                     style: Constants.AppTypography.body.copyWith(
//                                                                       color: Constants.AppColors.inkSoft,
//                                                                     ),
//                                                                     maxLines: isExpandedList[index] ? null : 2,
//                                                                     overflow: isExpandedList[index] ? TextOverflow.visible : TextOverflow.ellipsis,
//                                                                   ),
//                                                                   const SizedBox(height: 4),
//                                                                   InkWell(
//                                                                     onTap: () {
//                                                                       setState(() {
//                                                                         isExpandedList[index] = !isExpandedList[index];
//                                                                       });
//                                                                     },
//                                                                     child: Text(
//                                                                       isExpandedList[index]
//                                                                           ? translateText('Read Less')
//                                                                           : translateText('Read More'),
//                                                                       style: Constants.AppTypography.label.copyWith(
//                                                                         color: Constants.AppColors.brand,
//                                                                         fontWeight: FontWeight.bold,
//                                                                       ),
//                                                                     ),
//                                                                   ),
//                                                                 ],
//                                                               ],
//                                                             ),
//                                                           ),
//                                                         ),
//                                                       ],
//                                                     ),
//                                                   ],
//                                                 ),
//                                               ),
//                                             ),
//                                           ],
//                                         ),
//                                       ),
//                                     ),
//                                   ),
//                                 );
//                               },
//                             ),
//                           ),
//                   ],
//                 ),
//               ),
//             ),
//           )),
//     );
//   }
//
//   Widget buildLabourAnimatedWidget(dynamic labour, int index) {
//     return LabourAnimated(
//       labour: labour,
//       index: index,
//     );
//   }
//
//   Widget _buildSectionTitle(String title) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 8.0),
//       child: Text(
//         title,
//         style: Constants.AppTypography.h2,
//       ),
//     );
//   }
//
//   Widget _buildProjectList() {
//     return ListView.builder(
//       shrinkWrap: true,
//       physics: const NeverScrollableScrollPhysics(),
//       itemCount: filteredProjects.length,
//       itemBuilder: (context, index) {
//         var project = filteredProjects[index];
//         return Card(
//           elevation: 4.0,
//           margin: const EdgeInsets.symmetric(vertical: 8.0),
//           child: Padding(
//             padding: const EdgeInsets.all(16.0),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(project['title'] ?? 'Untitled Project'),
//                 const SizedBox(height: 8.0),
//                 Row(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Expanded(
//                       child: Text(project['description'] ?? 'No description'),
//                     ),
//                     SpeakerIconButton(text: project['description'] ?? 'No description'),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }
//
//   Widget _buildLabourList() {
//     return ListView.builder(
//       shrinkWrap: true,
//       physics: const NeverScrollableScrollPhysics(),
//       itemCount: labours.length,
//       itemBuilder: (context, index) {
//         var labour = labours[index];
//         return Card(
//           elevation: 4.0,
//           margin: const EdgeInsets.symmetric(vertical: 8.0),
//           child: Padding(
//             padding: const EdgeInsets.all(16.0),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(translateText(labour['name'] ?? 'Unnamed Labourer')),
//                 const SizedBox(height: 8.0),
//                 Text('Role: ${labour['role'] ?? 'N/A'}'),
//                 const SizedBox(height: 8.0),
//                 Text('Wage: ${labour['wage'] ?? 'N/A'}'),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }
// }
//
// class LabourAnimated extends StatefulWidget {
//   final dynamic labour;
//   final int index;
//   const LabourAnimated({required this.labour, required this.index});
//
//   @override
//   State<LabourAnimated> createState() => _LabourAnimatedState();
// }
//
// class _LabourAnimatedState extends State<LabourAnimated> {
//   Map<String, Map<String, String>> _cachedTranslations = {};
//
//   Map<String, Map<String, String>> translations =
//       Constants.AppConstants.translations;
//
//   final GoogleTranslator _translator = GoogleTranslator();
//   final _secureStorage = const FlutterSecureStorage();
//
//   @override
//   void initState() {
//     super.initState();
//     loadLanguage();
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
//           targetLang]!; // Return cached translation
//     }
//
//     // ✅ Fetch translation dynamically (but without `await`)
//
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
//     } catch (e) {
//       print("Translation error: $e");
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return AnimatedContainer(
//       duration: const Duration(milliseconds: 500),
//       curve: Curves.easeInOut,
//       margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//       decoration: BoxDecoration(
//         color: const Color(0xFFEBF5F0),
//         borderRadius: BorderRadius.circular(15),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.green.withOpacity(0.2),
//             spreadRadius: 2,
//             blurRadius: 5,
//           ),
//         ],
//       ),
//       child: ListTile(
//         leading: CircleAvatar(
//           backgroundColor: Colors.green,
//           child: Text(
//             translateText(widget.labour['name'][0].toUpperCase()),
//             style: const TextStyle(color: Colors.white),
//           ),
//         ),
//         title: Text(
//           translateText(widget.labour['name'] ?? 'Unknown'),
//           style: const TextStyle(fontWeight: FontWeight.bold),
//         ),
//         subtitle: Text(
//           '${translateText(widget.labour['city'] ?? 'Unknown City')}, ${translateText(widget.labour['state'] ?? 'Unknown State')}',
//         ),
//         trailing: Column(
//           children: [
//             Text(
//               widget.labour['type'] == '0'
//                   ? translateText('Individual')
//                   : translateText('Agency'),
//             ),
//             if (widget.labour['type'] == '1')
//               Text(
//                 '${translateText(widget.labour['agency_name'])}',
//               ),
//             // GestureDetector(
//             //   onTap: () {
//             //     // Trigger dialer when phone number is tapped
//             //     if (labour['phone'] != null) {
//             //       _launchPhoneDialer(labour['phone']);
//             //     }
//             //   },
//             //   child: Text(
//             //     labour['phone'] ?? 'N/A',
//             //     style: const TextStyle(color: Colors.green),
//             //   ),
//             // ),
//           ],
//         ),
//       ),
//     );
//   }
// }
//
// class ProjectPage extends StatefulWidget {
//   @override
//   _ProjectPageState createState() => _ProjectPageState();
// }
//
// class _ProjectPageState extends State<ProjectPage> {
//   final _secureStorage = const FlutterSecureStorage();
//   List<dynamic> projects = [];
//   List<dynamic> filteredProjects = []; // To store filtered results
//   bool isLoading = true;
//   TextEditingController _searchController = TextEditingController();
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
//   late stt.SpeechToText _speech;
//
//   @override
//   void initState() {
//     super.initState();
//     _speech = stt.SpeechToText();
//
//     fetchProjects();
//     loadLanguage();
//   }
//
//   String translateText(String text) {
//     final language =
//         Provider.of<LanguageProvider>(context, listen: false).selectedLanguage;
//     if (text.isEmpty) return "";
//
//     // ✅ Ensure `_selectedLanguage` is set before calling `translateText()`
//     String targetLang = language ?? 'en'; // Default to English if null
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
//           targetLang]!; // Return cached translation
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
//   Future<void> fetchProjects() async {
//     final String apiUrl = '${Constants.AppConstants.apiUrl}farmer/getprojects';
//
//     // Get user ID from secure storage
//     String? userId = await _secureStorage.read(key: 'id');
//     if (userId == null) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('User ID not found in secure storage')),
//       );
//       return;
//     }
//
//     final Map<String, dynamic> requestBody = {
//       'id': userId,
//     };
//
//     print(jsonEncode(requestBody));
//
//     try {
//       final response = await http.post(
//         Uri.parse(apiUrl),
//         headers: {'Content-Type': 'application/json'},
//         body: jsonEncode(requestBody),
//       );
//       print(json.decode(response.body)['data']);
//       if (response.statusCode == 200) {
//         setState(() {
//           projects = json.decode(response.body)['data'];
//           filteredProjects =
//               projects; // Set the filtered list to all projects initially
//           isLoading = false;
//         });
//       } else {
//         setState(() {
//           // Set the filtered list to all projects initially
//           isLoading = false;
//         });
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('No Projects Created Yet')),
//         );
//       }
//     } catch (e) {
//       isLoading = false;
//     }
//   }
//
//   void filterProjects(String query) {
//     setState(() {
//       filteredProjects = projects.where((project) {
//         String title =
//             project['title'] ?? ''; // Default to empty string if null
//         String budget =
//             project['budget']?.toString() ?? ''; // Convert to string if null
//         String city = project['city'] ?? ''; // Default to empty string if null
//         String state =
//             project['state'] ?? ''; // Default to empty string if null
//
//         // Perform the filtering check
//         return title.toLowerCase().contains(query.toLowerCase()) ||
//             budget.toLowerCase().contains(query.toLowerCase()) ||
//             city.toLowerCase().contains(query.toLowerCase()) ||
//             state.toLowerCase().contains(query.toLowerCase());
//       }).toList();
//     });
//   }
//
//   bool _isListening = false;
//   String _searchText = '';
//
//   void _startListening() async {
//     // Get selected language from the provider
//     final language =
//         Provider.of<LanguageProvider>(context, listen: false).selectedLanguage;
//
//     // Set the locale based on the selected language
//     String localeId = language == 'en'
//         ? 'en_US'
//         : 'hi_IN'; // 'en' for English, 'hi' for Hindi
//
//     bool available = await _speech.initialize();
//     if (available) {
//       setState(() {
//         _isListening = true;
//       });
//
//       // Start listening and use the localeId based on selected language
//       _speech.listen(
//         localeId: localeId,
//         onResult: (result) {
//           setState(() {
//             _searchText = result.recognizedWords;
//             _searchController.text = _searchText;
//             filterProjects(_searchText);
//           });
//         },
//       );
//     } else {
//       // Handle speech recognition not available
//       print("Speech recognition is not available.");
//     }
//   }
//
//   void _stopListening() {
//     setState(() {
//       _isListening = false;
//     });
//     _speech.stop();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return WillPopScope(
//       onWillPop: () async {
//         SystemNavigator.pop();
//         return false;
//       },
//       child: Scaffold(
//         body: Container(
//           decoration: const BoxDecoration(color: Colors.white),
//           child: SafeArea(
//             child: Column(
//               children: [
//                 // Search Bar
//                 Padding(
//                   padding: const EdgeInsets.all(16.0),
//                   child: TextField(
//                     controller: _searchController,
//                     onChanged: (value) {
//                       filterProjects(
//                           value); // Filter projects based on search input
//                     },
//                     decoration: InputDecoration(
//                       prefixIcon: const Icon(Icons.search, color: Colors.green),
//                       hintText: AppLocalizations.of(context)!
//                           .searchlabour, // Replace with AppLocalizations if needed
//                       fillColor: Colors.white,
//                       filled: true,
//                       border: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(15.0),
//                         borderSide: const BorderSide(color: Colors.green),
//                       ),
//                       focusedBorder: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(15.0),
//                         borderSide:
//                             const BorderSide(color: Colors.green, width: 2),
//                       ),
//                       suffixIcon: MicIconButton(controller: _searchController),
//                     ),
//                   ),
//                 ),
//                 // Project List
//                 Expanded(
//                   child: isLoading
//                       ? const Center(child: CircularProgressIndicator())
//                       : filteredProjects.isEmpty
//                           ? Center(
//                               child: Text(
//                                 AppLocalizations.of(context)!.noProjectsFound,
//                                 style: TextStyle(
//                                   fontSize: 18,
//                                   fontWeight: FontWeight.w500,
//                                   color: Colors.brown,
//                                 ),
//                               ),
//                             )
//                           : ListView.builder(
//                               itemCount: filteredProjects.length,
//                               itemBuilder: (context, index) {
//                                 final project = filteredProjects[index];
//                                 return Container(
//                                   margin: const EdgeInsets.symmetric(
//                                       vertical: 10, horizontal: 15),
//                                   decoration: BoxDecoration(
//                                     color: Colors
//                                         .white, // Background color of the container
//                                     borderRadius: BorderRadius.circular(
//                                         8), // Rounds the corners
//                                     boxShadow: [
//                                       BoxShadow(
//                                         color: Colors.black.withOpacity(
//                                             0.1), // Shadow color with transparency
//                                         blurRadius: 8, // How soft the shadow is
//                                         spreadRadius:
//                                             3, // How much the shadow expands
//                                         offset: Offset(0,
//                                             4), // Vertical and horizontal offset for the shadow
//                                       ),
//                                     ],
//                                   ),
//                                   child: Padding(
//                                     padding: const EdgeInsets.all(15.0),
//                                     child: Column(
//                                       crossAxisAlignment:
//                                           CrossAxisAlignment.start,
//                                       children: [
//                                         // Title with semi-bold
//                                         Row(
//                                           children: [
//                                             Padding(
//                                               padding: const EdgeInsets.only(
//                                                   left: 4.0),
//                                               child: Text(
//                                                 translateText(
//                                                     project['title'] ?? 'N/A'),
//                                                 style: const TextStyle(
//                                                   fontSize: 16,
//                                                   fontWeight: FontWeight
//                                                       .w600, // Semi-bold
//                                                 ),
//                                                 maxLines:
//                                                     2, // Limit to two lines
//                                                 overflow: TextOverflow
//                                                     .ellipsis, // Show ellipsis after two lines
//                                                 softWrap:
//                                                     true, // Enable text wrapping
//                                               ),
//                                             ),
//                                           ],
//                                         ),
//
//                                         Row(
//                                           children: [
//                                             Padding(
//                                               padding: const EdgeInsets.only(
//                                                   left: 4.0),
//                                               child: Text(
//                                                 AppLocalizations.of(
//                                                             context)!
//                                                         .location +
//                                                     " : ",
//                                                 style: const TextStyle(
//                                                   fontSize: 14,
//                                                   fontWeight: FontWeight
//                                                       .w600, // Semi-bold for title
//                                                 ),
//                                               ),
//                                             ),
//                                             Expanded(
//                                               child: Text(
//                                                 "${translateText(project['city'] ?? 'N/A')} ${translateText(project['state'] ?? 'N/A')} ${project['pincode'] ?? 'N/A'}",
//                                                 style: const TextStyle(
//                                                     fontSize: 16),
//                                               ),
//                                             ),
//                                           ],
//                                          ),
//                                         // Project Type and Labours Required
//                                         Row(
//                                           children: [
//                                             Padding(
//                                               padding: const EdgeInsets.only(
//                                                   left: 4.0),
//                                               child: Row(
//                                                 children: [
//                                                   Text(
//                                                     AppLocalizations.of(
//                                                                 context)!
//                                                             .projectType +
//                                                         " : ",
//                                                     style: const TextStyle(
//                                                       fontSize: 14,
//                                                       fontWeight: FontWeight
//                                                           .w600, // Semi-bold for title
//                                                     ),
//                                                   ),
//                                                   Text(
//                                                     translateText('On ' +
//                                                         (project[
//                                                                 'project_type'] ??
//                                                             'N/A')),
//                                                     style: const TextStyle(
//                                                         fontSize: 16),
//                                                   ),
//                                                 ],
//                                               ),
//                                             ),
//                                           ],
//                                         ),
//                                         Row(
//                                           children: [
//                                             Padding(
//                                               padding: const EdgeInsets.only(
//                                                   left: 4.0),
//                                               child: Row(
//                                                 children: [
//                                                   Text(
//                                                     AppLocalizations.of(
//                                                                 context)!
//                                                             .noOfLaboursRequired +
//                                                         " : ",
//                                                     style: const TextStyle(
//                                                       fontSize: 14,
//                                                       fontWeight: FontWeight
//                                                           .w600, // Semi-bold for title
//                                                     ),
//                                                   ),
//                                                   Text(
//                                                     (project['qty_labours'] ??
//                                                         'N/A'),
//                                                     style: const TextStyle(
//                                                         fontSize: 16),
//                                                   ),
//                                                 ],
//                                               ),
//                                             ),
//                                           ],
//                                         ),
//                                         Row(
//                                           crossAxisAlignment:
//                                               CrossAxisAlignment.start,
//                                           children: [
//                                             Padding(
//                                               padding: const EdgeInsets.only(
//                                                   left: 4.0),
//                                               child: Row(
//                                                 crossAxisAlignment:
//                                                     CrossAxisAlignment.start,
//                                                 children: [
//                                                   Text(
//                                                     AppLocalizations.of(
//                                                                 context)!
//                                                             .requiredSkills +
//                                                         " : ",
//                                                     style: const TextStyle(
//                                                       fontSize: 14,
//                                                       fontWeight: FontWeight
//                                                           .w600, // Semi-bold for title
//                                                     ),
//                                                   ),
//                                                   Container(
//                                                     constraints: BoxConstraints(
//                                                       maxWidth:
//                                                           MediaQuery.of(context)
//                                                                   .size
//                                                                   .width -
//                                                               170,
//                                                     ),
//                                                     child: Column(
//                                                       mainAxisAlignment:
//                                                           MainAxisAlignment
//                                                               .start,
//                                                       crossAxisAlignment:
//                                                           CrossAxisAlignment
//                                                               .start,
//                                                       children: [
//                                                         Text(
//                                                           (translateText(project[
//                                                                   'required_skills'] ??
//                                                               'N/A')),
//                                                           style:
//                                                               const TextStyle(
//                                                                   fontSize: 16),
//                                                         ),
//                                                       ],
//                                                     ),
//                                                   ),
//                                                 ],
//                                               ),
//                                             ),
//                                           ],
//                                         ),
//                                         Row(
//                                           children: [
//                                             Padding(
//                                               padding: const EdgeInsets.only(
//                                                   left: 4.0),
//                                               child: Row(
//                                                 children: [
//                                                   Text(
//                                                     AppLocalizations.of(
//                                                                 context)!
//                                                             .budget +
//                                                         " : ",
//                                                     style: const TextStyle(
//                                                       fontSize: 14,
//                                                       fontWeight: FontWeight
//                                                           .w600, // Semi-bold for title
//                                                     ),
//                                                   ),
//                                                   Text(
//                                                     (project['budget']
//                                                                 .toString() ??
//                                                             'N/A') +
//                                                         "  ",
//                                                     style: const TextStyle(
//                                                         fontSize: 16),
//                                                   ),
//                                                   Text(
//                                                     AppLocalizations.of(
//                                                                 context)!
//                                                             .duration +
//                                                         " : ",
//                                                     style: const TextStyle(
//                                                       fontSize: 14,
//                                                       fontWeight: FontWeight
//                                                           .w600, // Semi-bold for title
//                                                     ),
//                                                   ),
//                                                   Text(
//                                                     (project['days']
//                                                             .toString() ??
//                                                         'N/A'),
//                                                     style: const TextStyle(
//                                                         fontSize: 16),
//                                                   ),
//                                                 ],
//                                               ),
//                                             ),
//                                           ],
//                                         ),
//
//                                         const SizedBox(height: 10),
//                                         Row(
//                                           children: [
//                                             if (project['applicants']
//                                                     .toString() ==
//                                                 "1")
//                                               ElevatedButton(
//                                                 onPressed: () {
//                                                   Navigator.push(
//                                                     context,
//                                                     MaterialPageRoute(
//                                                       builder: (context) =>
//                                                           ProjectApplicationsPage(
//                                                         projectId: project['id']
//                                                             .toString(),
//                                                       ),
//                                                     ),
//                                                   );
//                                                 },
//                                                 style: ElevatedButton.styleFrom(
//                                                   backgroundColor:
//                                                       const Color.fromARGB(
//                                                           255, 19, 70, 27),
//                                                   foregroundColor: Colors.green,
//                                                   shape: RoundedRectangleBorder(
//                                                     borderRadius:
//                                                         BorderRadius.all(
//                                                       Radius.circular(
//                                                           2.0), // Curves all corners
//                                                     ),
//                                                   ),
//                                                 ),
//                                                 child: Text(
//                                                   AppLocalizations.of(context)!
//                                                       .viewApplications,
//                                                   style: const TextStyle(
//                                                       color: Colors.white),
//                                                 ),
//                                               ),
//                                             if (project['applicants']
//                                                     .toString() ==
//                                                 "1")
//                                               const SizedBox(width: 10),
//                                             ElevatedButton(
//                                               onPressed:
//                                                   project['applicants']
//                                                               .toString() ==
//                                                           "1"
//                                                       ? () {
//                                                           Navigator.push(
//                                                             context,
//                                                             MaterialPageRoute(
//                                                               builder: (context) =>
//                                                                   ProjectDetails(
//                                                                       projectId:
//                                                                           project['id']
//                                                                               .toString()),
//                                                             ),
//                                                           );
//                                                         }
//                                                       : () {
//                                                           Navigator.push(
//                                                             context,
//                                                             MaterialPageRoute(
//                                                               builder: (context) =>
//                                                                   UpdateProject(
//                                                                       projectId:
//                                                                           project['id']
//                                                                               .toString()),
//                                                             ),
//                                                           );
//                                                         },
//                                               style: ElevatedButton.styleFrom(
//                                                 backgroundColor:
//                                                     const Color.fromARGB(
//                                                         255, 19, 70, 27),
//                                                 foregroundColor: Colors.green,
//                                                 shape: RoundedRectangleBorder(
//                                                   borderRadius:
//                                                       BorderRadius.all(
//                                                           Radius.circular(2.0)),
//                                                 ),
//                                               ),
//                                               child: Text(
//                                                 translateText('Details'),
//                                                 style: const TextStyle(
//                                                     color: Colors.white),
//                                               ),
//                                             ),
//                                           ],
//                                         ),
//                                       ],
//                                     ),
//                                   ),
//                                 );
//                               },
//                             ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
//
// class ProfilePage extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Center(
//       child: Text(
//         "This is the Profile Page",
//         style: TextStyle(fontSize: 24, color: Colors.blue),
//       ),
//     );
//   }
// }
//
// class ProjectApplicationsPage extends StatefulWidget {
//   final String projectId;
//
//   ProjectApplicationsPage({required this.projectId});
//
//   @override
//   _ProjectApplicationsPageState createState() =>
//       _ProjectApplicationsPageState();
// }
//
// class _ProjectApplicationsPageState extends State<ProjectApplicationsPage> {
//   bool isLoading = true;
//   List<dynamic> applications = [];
//
//   final _secureStorage = const FlutterSecureStorage();
//   bool _isProcessing = false;
//   late stt.SpeechToText _speech;
//
//   @override
//   void initState() {
//     super.initState();
//     _speech = stt.SpeechToText();
//     loadLanguage();
//     fetchProjectApplications();
//   }
//
//   Future<void> fetchProjectApplications() async {
//     final String apiUrl =
//         '${Constants.AppConstants.apiUrl}farmer/farmerProjectDetails';
//     String? userId = await _secureStorage.read(key: 'id');
//     if (userId == null) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('User ID not found in secure storage')),
//       );
//       return;
//     }
//
//     // Prepare the request body
//     final Map<String, dynamic> requestBody = {
//       'id': userId,
//       'project_id': widget.projectId,
//     };
//     print(
//       jsonEncode(requestBody),
//     );
//     try {
//       final response = await http.post(
//         Uri.parse(apiUrl),
//         headers: {'Content-Type': 'application/json'},
//         body: jsonEncode(requestBody),
//       );
//
//       if (response.statusCode == 200) {
//         final responseData = json.decode(response.body);
//         if (responseData['success'] == true) {
//           setState(() {
//             applications = responseData['data']['applications'];
//             print(applications);
//             isLoading = false;
//           });
//         } else {
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(content: Text('Failed to fetch project details')),
//           );
//         }
//       } else {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Failed to fetch project details')),
//         );
//       }
//     } catch (e) {}
//   }
//
//   Future<void> unassignProject(String labourId, String projectId) async {
//     setState(() {
//       _isProcessing = true; // Show loading indicator
//     });
//
//     // API URL
//     String url = '${Constants.AppConstants.apiUrl}farmer/unassignProject';
//
//     // Sending POST request
//     try {
//       final response = await http.post(
//         Uri.parse(url),
//         headers: {'Content-Type': 'application/json'},
//         body: json.encode({
//           'labourids': labourId,
//           'projectids': projectId,
//         }),
//       );
//
//       if (response.statusCode == 200) {
//         // Success, show message and update UI
//         final data = json.decode(response.body);
//         if (data['status'] == '1') {
//           await fetchProjectApplications();
//           setState(() {
//             _isProcessing = false; // Hide loading indicator
//           });
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(content: Text(data['message'])),
//           );
//         }
//       } else {
//         setState(() {
//           _isProcessing = false; // Hide loading indicator
//         });
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Failed to unassign job')),
//         );
//       }
//     } catch (e) {
//       setState(() {
//         _isProcessing = false; // Hide loading indicator
//       });
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Error: $e')),
//       );
//     }
//   }
//
//   Future<void> cancelConfirm(
//       String projectId, String labourId, String cancelRemark) async {
//     setState(() {
//       _isProcessing = true; // Show loading indicator
//     });
//
//     // API URL
//     String url = '${Constants.AppConstants.apiUrl}farmer/cancelConfirm';
//
//     // Sending POST request
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
//
//       if (response.statusCode == 200) {
//         // Success, show message and update UI
//         final data = json.decode(response.body);
//         if (data['status'] == '1') {
//           await fetchProjectApplications();
//           setState(() {
//             _isProcessing = false; // Hide loading indicator
//           });
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(content: Text(data['message'])),
//           );
//         }
//       } else {
//         setState(() {
//           _isProcessing = false; // Hide loading indicator
//         });
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Failed to send cancel request')),
//         );
//       }
//     } catch (e) {
//       setState(() {
//         _isProcessing = false; // Hide loading indicator
//       });
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Error: $e')),
//       );
//     }
//   }
//
//   // Function to show the dialog for cancel remarks
//   void showCancelDialog(BuildContext context, String labourId) {
//     TextEditingController _cancelRemarkController = TextEditingController();
//
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: const Text('Cancel Remark'),
//           content: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               TextField(
//                 controller: _cancelRemarkController,
//                 decoration: InputDecoration(
//                   labelText: 'Enter Cancel Remark',
//                   border: OutlineInputBorder(),
//                   suffixIcon: MicIconButton(controller: _cancelRemarkController),
//                 ),
//                 maxLines: 3,
//               ),
//             ],
//           ),
//           actions: <Widget>[
//             TextButton(
//               onPressed: () {
//                 Navigator.of(context).pop();
//               },
//               child: const Text('Cancel'),
//             ),
//             TextButton(
//               onPressed: () {
//                 if (_cancelRemarkController.text.isNotEmpty) {
//                   cancelConfirm(
//                     widget.projectId,
//                     labourId,
//                     _cancelRemarkController.text,
//                   );
//                   Navigator.of(context).pop(); // Close the dialog
//                 } else {
//                   ScaffoldMessenger.of(context).showSnackBar(
//                     const SnackBar(content: Text('Remark cannot be empty')),
//                   );
//                 }
//               },
//               child: const Text('Submit'),
//             ),
//           ],
//         );
//       },
//     );
//   }
//
//   Future<void> confirmComplete(String projectId, String labourId) async {
//     setState(() {
//       _isProcessing = true; // Show loading indicator
//     });
//
//     // API URL
//     String url = '${Constants.AppConstants.apiUrl}farmer/confirmComplete';
//
//     // Sending POST request
//     try {
//       final response = await http.post(
//         Uri.parse(url),
//         headers: {'Content-Type': 'application/json'},
//         body: json.encode({
//           'projectid': projectId,
//           'labourid': labourId,
//         }),
//       );
//
//       if (response.statusCode == 200) {
//         // Success, show message and update UI
//         final data = json.decode(response.body);
//         if (data['status'] == '1') {
//           await fetchProjectApplications();
//           setState(() {
//             _isProcessing = false; // Hide loading indicator
//           });
//
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(content: Text(data['message'])),
//           );
//         }
//       } else {
//         setState(() {
//           _isProcessing = false; // Hide loading indicator
//         });
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Failed to confirm completion')),
//         );
//       }
//     } catch (e) {
//       setState(() {
//         _isProcessing = false; // Hide loading indicator
//       });
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Error: $e')),
//       );
//     }
//   }
//
//   Future<void> assignProject(String labourId) async {
//     final String apiUrl =
//         '${Constants.AppConstants.apiUrl}farmer/projectAssigned';
//     String? userId = await _secureStorage.read(key: 'id');
//     if (userId == null) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('User ID not found in secure storage')),
//       );
//       return;
//     }
//
//     // Prepare the request body
//     final Map<String, dynamic> requestBody = {
//       'labourid': labourId,
//       'projectid': widget.projectId,
//     };
//
//     try {
//       final response = await http.post(
//         Uri.parse(apiUrl),
//         headers: {'Content-Type': 'application/json'},
//         body: jsonEncode(requestBody),
//       );
//
//       if (response.statusCode == 200) {
//         final responseData = json.decode(response.body);
//         if (responseData['status'] == 1) {
//           await fetchProjectApplications();
//           setState(() {});
//           ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(content: Text('Project assigned successfully')),
//           );
//           Future.delayed(Duration(seconds: 1), () {
//             Navigator.pushReplacement(
//               context,
//               MaterialPageRoute(
//                 builder: (context) => HomePage(),
//               ),
//             );
//           });
//         } else {
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(
//                 content: Text(
//                     'Failed to assign project: ${responseData['message']}')),
//           );
//         }
//       } else {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Failed to assign project')),
//         );
//       }
//     } catch (e) {}
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
//
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
//           targetLang]!; // Return cached translation
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
//   String _formatDate(String dateString) {
//     try {
//       // Parse the date string to DateTime object
//       DateTime dateTime = DateTime.parse(dateString);
//       // Format the DateTime object to "dd-MM-yyyy"
//       return DateFormat('dd-MM-yyyy').format(dateTime);
//     } catch (e) {
//       // In case of any error, return the original date string
//       return dateString;
//     }
//   }
//
//   String getStatusText(String status) {
//     switch (status) {
//       case '0':
//         return AppLocalizations.of(context)!.notAssigned;
//       case '1':
//         return AppLocalizations.of(context)!.assigned;
//       case '2':
//         return AppLocalizations.of(context)!.workStarted;
//       case '3':
//         return AppLocalizations.of(context)!.completed;
//       default:
//         return AppLocalizations.of(context)!.cancelled;
//     }
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
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(
//           AppLocalizations.of(context)!
//               .projectApplications, // Corrected to use localization key
//           style: const TextStyle(color: Colors.white),
//         ),
//         iconTheme: const IconThemeData(color: Colors.white),
//         flexibleSpace: Container(
//           decoration: const BoxDecoration(
//             gradient: Constants.AppColors.brandGradient,
//           ),
//         ),
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back), // Default back arrow icon
//           onPressed: () {
//             Navigator.push(
//               context,
//               MaterialPageRoute(
//                 builder: (context) => HomePage(),
//               ),
//             ); // This will pop the current page and go back to the previous screen
//           },
//         ),
//       ),
//       body: isLoading
//           ? const Center(child: CircularProgressIndicator())
//           : applications.isEmpty
//               ? Center(
//                   child: Text(AppLocalizations.of(context)!
//                       .noApplicationsFound)) // Localized "No applications found"
//               : ListView.builder(
//                   itemCount: applications.length,
//                   itemBuilder: (context, index) {
//                     final application = applications[index];
//                     return Card(
//                       margin:
//                           EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
//                       elevation: 4.0,
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(8.0),
//                       ),
//                       child: Stack(
//                         children: [
//                           Padding(
//                             padding: const EdgeInsets.all(8.0),
//                             child: ListTile(
//                               contentPadding: EdgeInsets.all(16.0),
//                               title: Column(
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: [
//                                   Text(
//                                     "${translate('Worker Name', 'श्रमिक का नाम')}: ${translateText(application['labour_name'] ?? 'N/A')}",
//                                     style:
//                                         TextStyle(fontWeight: FontWeight.bold),
//                                   ),
//                                   // Comment
//                                   Row(
//                                     crossAxisAlignment: CrossAxisAlignment.center,
//                                     children: [
//                                       Expanded(
//                                         child: Text(
//                                           "${AppLocalizations.of(context)!.comment}: ${translateText(application['comment'] ?? 'N/A')}",
//                                         ),
//                                       ),
//                                       SpeakerIconButton(
//                                         text: translateText(application['comment'] ?? 'N/A') ?? 'N/A',
//                                       ),
//                                     ],
//                                   ),
//                                   // Date
//                                   Text(
//                                     "${translateText('Date')}: ${_formatDate(application['created_at'])}",
//                                   ),
//                                   // Location
//                                   Text(
//                                     "${AppLocalizations.of(context)!.location}: ${translateText('${application['labour_address']}, ${application['labour_city']}, ${application['labour_state']}')}",
//                                   ),
//                                   // Status
//                                   Text(
//                                     "${translateText('Status')}: ${getStatusText(application['status'])}",
//                                   ),
//                                 ],
//                               ),
//                             ),
//                           ),
//                           Positioned(
//                             bottom: 8.0,
//                             right: 8.0,
//                             child: ElevatedButton(
//                               onPressed: () {
//                                 // Navigate to the ApplicationDetailPage when clicking on 'View Details'
//                                 Navigator.push(
//                                   context,
//                                   MaterialPageRoute(
//                                     builder: (context) => ApplicationDetailPage(
//                                       application: application,
//                                     ),
//                                   ),
//                                 );
//                               },
//                               style: ElevatedButton.styleFrom(
//                                 shape: RoundedRectangleBorder(
//                                   borderRadius:
//                                       BorderRadius.all(Radius.circular(8.0)),
//                                 ),
//                                 disabledBackgroundColor: Colors.red,
//                                 backgroundColor:
//                                     const Color.fromARGB(255, 19, 70, 27),
//                                 foregroundColor: Colors.white,
//                               ),
//                               child: Text(
//                                 AppLocalizations.of(context)!.viewDetails,
//                                 style: TextStyle(color: Colors.white),
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                     );
//                   },
//                 ),
//     );
//   }
// }
import 'dart:async';
import 'package:greencollar/speech_helper.dart';
import 'dart:convert';
import 'dart:io';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:greencollar/l10n/app_localizations.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:greencollar/Addproject.dart';
import 'package:greencollar/NearbyProject.dart';
import 'package:greencollar/Nearbylabours.dart';
import 'package:greencollar/ProjectDetails.dart';
import 'package:greencollar/UpdateProject.dart';
import 'package:greencollar/application_detaill.dart';
import 'package:greencollar/main.dart';
import 'package:greencollar/noti.dart';
import 'package:greencollar/updateprofile.dart';
import 'package:greencollar/workerdetails.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:greencollar/location_provider.dart';
import 'package:http/http.dart' as http;
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:translator/translator.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:greencollar/constants.dart' as Constants;
import 'package:carousel_slider/carousel_slider.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:greencollar/wallet_helper.dart';
import 'package:greencollar/api_logger.dart';

class JobType {
  final int id;
  final String jobname;
  final String image;
  final String status;

  JobType(
      {required this.id,
        required this.jobname,
        required this.image,
        required this.status});

  factory JobType.fromJson(Map<String, dynamic> json) {
    return JobType(
      id: json['id'],
      jobname: json['jobname'],
      image: json['image'],
      status: json['status'],
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;
  final _secureStorage = const FlutterSecureStorage();

  String _selectedLanguage = 'en'; // Default language is English
  String _userName = '';
  String _userType = '';
  int _walletCoins = 0;

  Future<void> _loadWalletBalance() async {
    int coins = await WalletHelper.getCoins();
    if (mounted) {
      setState(() {
        _walletCoins = coins;
      });
    }
  }

  Future<void> _loadUserInfo() async {
    String? name = await _secureStorage.read(key: 'name');
    String? userType = await _secureStorage.read(key: 'userType');
    setState(() {
      _userName = name ?? '';
      _userType = userType ?? 'farmer';
    });
  }

  Future<void> loadLanguage() async {
    await fetchUnreadNotificationsCount();

    // Read the selected language from FlutterSecureStorage
    String? language = await _secureStorage.read(key: 'selectedLanguage');
    _selectedLanguage = language ?? 'en';
  }

  Map<String, Map<String, String>> _cachedTranslations = {};
  int unreadNotificationsCount = 0; // To store unread notifications count

  Map<String, Map<String, String>> translations =
      Constants.AppConstants.translations;
  final GoogleTranslator _translator = GoogleTranslator();
  @override
  void initState() {
    super.initState();
    loadLanguage();
    _loadUserInfo();
    _loadWalletBalance();
    ApiLogger.logScreenOpened('CombinedPage');
  }

  Future<void> fetchUnreadNotificationsCount() async {
    print("Fetching unread notifications count...");

    // Retrieve the userId from secure storage
    String? userId = await _secureStorage.read(key: 'id');
    if (userId == null) {
      // Handle case if user id is not found
      print('User ID not found.');
      return;
    }

    // Construct the URL for the API call
    final url = Uri.parse(
        '${Constants.AppConstants.apiUrl}farmer/getUnreadNotificationsCount');
    print('URL: $url');

    // Print the request body
    print('Request Body: {\'id\': $userId}');

    try {
      print(url);
      final response = await http.post(
        url,
        body: {
          'id': userId, // Sending userId as part of the request body
        },
      );

      print('Response Sttatus: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData['status'] == 'success') {
          setState(() {
            unreadNotificationsCount =
            responseData['unread_notifications_count'];
            print('Unread notifications count: $unreadNotificationsCount');
          });
        } else {
          // Handle case where the response is not success
          print(
              'Failed to fetch notifications count: ${responseData['message']}');
        }
      } else {
        // Handle case when the server response is not 200 (OK)
        print('Failed to connect to the server: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<String> translateText(String text) async {
    if (text.isEmpty) return "";

    String targetLang = _selectedLanguage ?? 'en'; // Default to English

    // ✅ Check manual translations first
    if (translations.containsKey(text) &&
        translations[text]!.containsKey(targetLang)) {
      return translations[text]![targetLang]!;
    }

    // ✅ Check cached translations
    if (_cachedTranslations.containsKey(text) &&
        _cachedTranslations[text]!.containsKey(targetLang)) {
      return _cachedTranslations[text]![targetLang]!;
    }

    // ✅ Fetch translation dynamically (NOW WITH AWAIT)
    String translatedText =
    await _fetchTranslation(text, targetLang); // 🚀 Always waits
    return translatedText;
  }

  Future<String> _fetchTranslation(String text, String targetLang) async {
    try {
      // ✅ Check if translation already exists in constants
      if (Constants.AppConstants.translations.containsKey(text) &&
          Constants.AppConstants.translations[text]!.containsKey(targetLang)) {
        return Constants.AppConstants.translations[text]![targetLang]!;
      }

      // ✅ Fetch translation dynamically
      final translation = await _translator.translate(text, to: targetLang);

      // ✅ Store in local translations
      translations.putIfAbsent(text, () => {});
      translations[text]![targetLang] = translation.text;

      // ✅ Store in cache
      _cachedTranslations.putIfAbsent(text, () => {});
      _cachedTranslations[text]![targetLang] = translation.text;

      // ✅ Store in global constants map
      Constants.AppConstants.translations.putIfAbsent(text, () => {});
      Constants.AppConstants.translations[text]![targetLang] = translation.text;

      setState(() {}); // ✅ Update UI with translated text

      return translation.text;
    } catch (e) {
      return text; // Return original text if translation fails
    }
  }

  final List<Widget> _pages = [
    CombinedPage(),
    LabourPage(),
    ProjectPage(),
  ];
  Future<void> _logout(BuildContext context) async {
    await _secureStorage.delete(key: 'id'); // Clear the user ID from storage
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
          child: Icon(
            icon,
            color: iconColor,
            size: 20,
          ),
        ),
        title: title,
        trailing: trailing ?? Icon(
          Icons.chevron_right_rounded,
          color: isLogout ? const Color(0xFFEF4444) : const Color(0xFF9CA3AF),
          size: 20,
        ),
        onTap: onTap,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        SystemNavigator.pop();
        return false;
      },
      child: Scaffold(
        extendBody: true,
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
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.20),
                                borderRadius: BorderRadius.circular(Constants.AppRadii.sm),
                                border: Border.all(color: Colors.white30, width: 0.5),
                              ),
                              child: Text(
                                _selectedLanguage == 'en' ? 'Farmer' : 'किसान',
                                style: Constants.AppTypography.micro.copyWith(
                                  color: Colors.white,
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
                ? AppLocalizations.of(context)!.nearbylabours
                : _currentIndex == 2
                ? AppLocalizations.of(context)!.yourprojects
                : 'Default Title',
            style: Constants.AppTypography.h1.copyWith(color: Colors.white),
          ),
          iconTheme: const IconThemeData(color: Colors.white),
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: Constants.AppColors.brandGradient,
            ),
          ),
          actions: [
            // Show the unread notification count in the AppBar using a badge
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
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => NotificationsPage()),
                );
                print('Notifications tapped');
              },
            ),
          ],
        ),
        drawer: Drawer(
          backgroundColor: Colors.white,
          child: Column(
            children: [
              // Premium Brand Header Container
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
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              _userType == 'labour'
                                  ? (context.watch<LanguageProvider>().selectedLanguage == 'en' ? 'Worker' : 'श्रमिक')
                                  : (context.watch<LanguageProvider>().selectedLanguage == 'en' ? 'Farmer' : 'किसान'),
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
                    // Elegant Close Button
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        height: 36,
                        width: 36,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.close,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Scrollable Menu List
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  children: [
                    // Home
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
                        setState(() {
                          _currentIndex = 0;
                        });
                        Navigator.pop(context);
                      },
                    ),

                    // Search
                    _buildDrawerTile(
                      icon: Icons.search,
                      title: FutureBuilder<String>(
                        future: translateText('Search'),
                        builder: (context, snapshot) {
                          return Text(
                            snapshot.data ?? 'Search',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          );
                        },
                      ),
                      onTap: () {
                        setState(() {
                          _currentIndex = 1;
                        });
                        Navigator.pop(context);
                      },
                    ),

                    // Notifications
                    _buildDrawerTile(
                      icon: Icons.notifications,
                      title: FutureBuilder<String>(
                        future: translateText('Notifications'),
                        builder: (context, snapshot) {
                          return Row(
                            children: [
                              Text(
                                snapshot.data ?? 'Notifications',
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              if (unreadNotificationsCount > 0)
                                Padding(
                                  padding: const EdgeInsets.only(left: 8.0),
                                  child: CircleAvatar(
                                    radius: 10,
                                    backgroundColor: Colors.red,
                                    child: Text(
                                      unreadNotificationsCount.toString(),
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          );
                        },
                      ),
                      onTap: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) => NotificationsPage()),
                        );
                      },
                    ),

                    // Select Language
                    _buildDrawerTile(
                      icon: Icons.language,
                      title: FutureBuilder<String>(
                        future: translateText(' Select Language'),
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
                          MaterialPageRoute(
                            builder: (context) => LanguageSelectionScreen(),
                          ),
                        );
                      },
                    ),

                    // Projects
                    _buildDrawerTile(
                      icon: Icons.notes,
                      title: FutureBuilder<String>(
                        future: translateText('Projects'),
                        builder: (context, snapshot) {
                          return Text(
                            snapshot.data ?? 'Projects',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          );
                        },
                      ),
                      onTap: () {
                        setState(() {
                          _currentIndex = 2;
                        });
                        Navigator.pop(context);
                      },
                    ),

                    // Wallet
                    _buildDrawerTile(
                      icon: Icons.account_balance_wallet,
                      title: FutureBuilder<String>(
                        future: translateText('Wallet'),
                        builder: (context, snapshot) {
                          final walletTitle = snapshot.data ?? 'Wallet';
                          final coinsText = _selectedLanguage == 'en'
                              ? '($_walletCoins coins)'
                              : '($_walletCoins सिक्के)';
                          return Text(
                            '$walletTitle $coinsText',
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

                    // Profile
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
                          MaterialPageRoute(
                            builder: (context) => UpdateLabourProfile(),
                          ),
                        );
                      },
                    ),

                    const Divider(color: Constants.AppColors.border, height: 24, thickness: 1),

                    // Logout
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
            decoration: BoxDecoration(
              gradient: Constants.AppColors.brandGradient,
              borderRadius: BorderRadius.circular(28),
              boxShadow: const [Constants.AppShadows.fab],
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
                      label: AppLocalizations.of(context)!.homepage),
                  BottomNavigationBarItem(
                      icon: const Icon(Icons.search),
                      label: AppLocalizations.of(context)!.nearbylabours),
                  BottomNavigationBarItem(
                      icon: const Icon(Icons.person),
                      label: AppLocalizations.of(context)!.yourprojects),
                ],
                onTap: (index) {
                  setState(() {
                    _currentIndex = index;
                  });
                  final pages = ['CombinedPage', 'LabourPage', 'ProjectPage'];
                  if (index >= 0 && index < pages.length) {
                    ApiLogger.logScreenOpened(pages[index]);
                  }
                },
              ),
            ),
          ),
        ),
        floatingActionButton: Container(
          decoration: BoxDecoration(
            gradient: Constants.AppColors.brandGradient,
            borderRadius: BorderRadius.circular(999),
            boxShadow: const [Constants.AppShadows.fab],
          ),
          child: FloatingActionButton.extended(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddProjectForm(),
                ),
              );
            },
            backgroundColor: Colors.transparent,
            elevation: 0,
            highlightElevation: 0,
            label: Text(
              AppLocalizations.of(context)!.addProject,
              style: Constants.AppTypography.body.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      ),
    );
  }
}

class Dashboard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        "Welcome to the Home Page",
        style: TextStyle(fontSize: 24, color: Constants.AppColors.brand),
      ),
    );
  }
}

class SearchPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        "Search for something here!",
        style: TextStyle(fontSize: 24, color: Constants.AppColors.brand),
      ),
    );
  }
}

class CombinedPage extends StatefulWidget {
  @override
  _CombinedPageState createState() => _CombinedPageState();
}

class _CombinedPageState extends State<CombinedPage> with WidgetsBindingObserver {
  static String _cachedCity = '';
  static String _cachedState = '';
  static String _cachedError = '';

  final FlutterSecureStorage _secureStorage = FlutterSecureStorage();
  final TextEditingController _projectSearchController =
  TextEditingController();
  final TextEditingController _labourSearchController = TextEditingController();
  late Future<List<JobType>> _jobTypes;

  List<dynamic> projects = [];
  List<dynamic> filteredProjects = [];
  List<dynamic> labours = [];
  bool isLoading = false;
  int _currentIndex = 0; // To track the current index of the carousel
// Use PageController here
  String _selectedLanguage = 'en'; // Default language is English
  int _coinCharge = 5;

  Future<void> _loadCoinCharge() async {
    int charge = await WalletHelper.getCoinCharge();
    if (mounted) {
      setState(() {
        _coinCharge = charge;
      });
    }
  }

  Future<void> loadLanguage() async {
    // Read the selected language from FlutterSecureStorage
    String? language = await _secureStorage.read(key: 'selectedLanguage');
    _selectedLanguage = language ?? 'en';
  }

  Map<String, Map<String, String>> _cachedTranslations = {};

  Map<String, Map<String, String>> translations =
      Constants.AppConstants.translations;
  final GoogleTranslator _translator = GoogleTranslator();
  late stt.SpeechToText _speech;
  late PageController _pageController;
  late Timer _timer;

  // Location state variables
  String _currentCity = '';
  String _currentState = '';
  bool _isLoadingLocation = true;
  String _locationError = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _speech = stt.SpeechToText();

    _pageController = PageController();

    _jobTypes =
        fetchJobTypes(); // Assuming you have this function to fetch the job types
    fetchLabours();
    _fetchCurrentLocation();
    _loadCoinCharge();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _pageController.dispose();
    _timer.cancel();
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

      // Get current position
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      // Reverse geocode to get city and state
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

  // Function to automatically scroll the carousel every 3 seconds
  void _startAutoScroll() {
    Timer.periodic(Duration(seconds: 3), (Timer timer) {
      if (_pageController.hasClients) {
        // Scroll to the next index
        _currentIndex = (_currentIndex + 1) %
            1; // Change 5 with the number of items in your list

        // Looping back to the first index when it reaches the end
        _pageController.animateToPage(
          _currentIndex,
          duration: Duration(seconds: 1),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  bool _isListening = false;
  String _searchText = '';

  void _startListening() async {
    // Get selected language from the provider
    final language =
        Provider.of<LanguageProvider>(context, listen: false).selectedLanguage;

    // Set the locale based on the selected language
    String localeId = language == 'en'
        ? 'en_US'
        : 'hi_IN'; // 'en' for English, 'hi' for Hindi

    bool available = await _speech.initialize();
    if (available) {
      setState(() {
        _isListening = true;
      });

      // Start listening and use the localeId based on selected language
      _speech.listen(
        localeId: localeId,
        onResult: (result) {
          setState(() {
            _searchText = result.recognizedWords;
            _labourSearchController.text = _searchText;
            fetchLabours(searchQuery: _searchText);
          });
        },
      );
    } else {
      // Handle speech recognition not available
      print("Speech recognition is not available.");
    }
  }

  void _stopListening() {
    setState(() {
      _isListening = false;
    });
    _speech.stop();
  }

  Future<List<JobType>> fetchJobTypes() async {
    final response = await http
        .post(Uri.parse('${Constants.AppConstants.apiUrl}farmer/jobtype'));

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      List<dynamic> jobData = data['data'];
      return jobData.map((job) => JobType.fromJson(job)).toList();
    } else {
      throw Exception('Failed to load job types');
    }
  }

  String _formatDate(String dateString) {
    try {
      // Parse the date string to DateTime object
      DateTime dateTime = DateTime.parse(dateString);
      // Format the DateTime object to "dd-MM-yyyy"
      return DateFormat('dd-MM-yyyy').format(dateTime);
    } catch (e) {
      // In case of any error, return the original date string
      return dateString;
    }
  }

  Future<void> fetchLabours({String? searchQuery}) async {
    setState(() {
      isLoading = true;
    });

    String? userId = await _secureStorage.read(key: 'id');
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User ID not found in secure storage')),
      );
      setState(() {
        isLoading = false;
      });
      return;
    }

    // Define the API URL
    final apiUrl = (searchQuery != null && searchQuery.isNotEmpty)
        ? '${Constants.AppConstants.apiUrl}farmer/searchnearbylabours'
        : '${Constants.AppConstants.apiUrl}farmer/nearbylabours';

    // Define the request body based on the condition
    final Map<String, dynamic> requestBody =
    (searchQuery != null && searchQuery.isNotEmpty)
        ? {'search': searchQuery}
        : {'id': userId};
    print(jsonEncode(requestBody));
    print(jsonEncode(apiUrl));

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData['success'] == true) {
          setState(() {
            labours = responseData['data'];
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(responseData['message'] ?? 'No labours found')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to fetch labours')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void filterProjects(String query) {
    setState(() {
      filteredProjects = projects.where((project) {
        String title = project['title'] ?? '';
        String budget = project['budget']?.toString() ?? '';
        String city = project['city'] ?? '';
        String state = project['state'] ?? '';

        return title.toLowerCase().contains(query.toLowerCase()) ||
            budget.toLowerCase().contains(query.toLowerCase()) ||
            city.toLowerCase().contains(query.toLowerCase()) ||
            state.toLowerCase().contains(query.toLowerCase());
      }).toList();
    });
  }

  final List<String> imageUrls = [
    'assets/slider1.png',
    'assets/slider2.png',
    'assets/slider4.jpg',
    'assets/slider3.png',
    'assets/slider5.png',
  ];
  Future<void> fetchProjects() async {
    final String apiUrl = '${Constants.AppConstants.apiUrl}farmer/getprojects';

    String? userId = await _secureStorage.read(key: 'id');
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User ID not found in secure storage')),
      );
      return;
    }

    final Map<String, dynamic> requestBody = {'id': userId};

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        setState(() {
          projects = responseData['data'];
          filteredProjects = projects;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to fetch projects: ${response.body}')),
        );
      }
    } catch (e) {}
  }

  void _startAutoScrolling(int itemCount) {
    _timer = Timer.periodic(Duration(seconds: 3), (Timer timer) {
      if (_pageController.hasClients) {
        setState(() {
          _currentIndex = (_currentIndex + 1) % itemCount; // Loop through items
        });

        // Animate to the next page (next job type)
        _pageController.animateToPage(
          _currentIndex,
          duration: Duration(seconds: 1),
          curve: Curves.easeInOut,
        );
      }
    });
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
            // Assuming loadLanguage, fetchProjects, and fetchJobTypes are async functions.
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => HomePage(),
              ),
            );

            setState(() {
              // If you need to update the UI state, you can do it here after all async tasks are done.
            });
          },
          child: Scaffold(
            body: Container(
              width: double.infinity,
              height: double.infinity,
              decoration: BoxDecoration(color: Colors.white),
              child: SingleChildScrollView(
                // Using SingleChildScrollView for the main scrolling
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    Container(
                      width: double.infinity,
                      height: 200,
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: const [Constants.AppShadows.card],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: CarouselSlider.builder(
                          itemCount: imageUrls.length,
                          itemBuilder:
                              (BuildContext context, int index, int realIndex) {
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
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                      child: _buildSectionTitle(
                        translate('Select category for job/Work',
                            'नौकरी/कार्य के लिए श्रेणी चुनें'),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: FutureBuilder<List<JobType>>(
                        future:
                        _jobTypes, // Replace with your future call to fetch data
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                                child: CircularProgressIndicator());
                          } else if (snapshot.hasError) {
                            return const Center(
                                child: Text('Error fetching job types'));
                          } else if (!snapshot.hasData ||
                              snapshot.data!.isEmpty) {
                            return const Center(
                                child: Text('No data available'));
                          } else {
                            List<JobType> jobTypes = snapshot.data!;
                            _startAutoScrolling(jobTypes
                                .length); // Start the auto-scrolling logic

                            return Container(
                              height: 128,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                itemCount: jobTypes.length,
                                itemBuilder: (context, index) {
                                  JobType job = jobTypes[index];

                                  return InkWell(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => AddProjectForm(
                                            projectType: job.jobname,
                                          ),
                                        ),
                                      );
                                    },
                                    child: SizedBox(
                                      width: 90,
                                      child: Column(
                                        children: [
                                          Container(
                                            width: 70,
                                            height: 70,
                                            margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                                            decoration: const BoxDecoration(
                                              color: Constants.AppColors.brandTint,
                                              shape: BoxShape.circle,
                                            ),
                                            child: Center(
                                              child: CachedNetworkImage(
                                                imageUrl:
                                                '${Constants.AppConstants.folderUrl}storage/upload/jobtypes/${job.image}',
                                                width: 42,
                                                height: 42,
                                                placeholder: (context, url) => const Center(
                                                  child: SizedBox(
                                                    width: 20,
                                                    height: 20,
                                                    child: CircularProgressIndicator(strokeWidth: 2),
                                                  ),
                                                ),
                                                errorWidget: (context, url, error) => const Icon(
                                                    Icons.error, color: Constants.AppColors.brand),
                                              ),
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.only(left: 4.0, right: 4.0, top: 4.0),
                                            child: Text(
                                              translateText(job.jobname),
                                              style: Constants.AppTypography.label.copyWith(
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
                            );
                          }
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Constants.AppColors.card,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: const [Constants.AppShadows.soft],
                        ),
                        child: TextField(
                          controller: _labourSearchController,
                          onChanged: (value) {
                            fetchLabours(searchQuery: value);
                          },
                          style: Constants.AppTypography.body,
                          decoration: InputDecoration(
                            prefixIcon: const Icon(
                              Icons.search,
                              color: Constants.AppColors.brand,
                              size: 20,
                            ),
                            suffixIcon: MicIconButton(controller: _labourSearchController),
                            hintText: AppLocalizations.of(context)!.searchlabour,
                            hintStyle: Constants.AppTypography.body.copyWith(
                              color: Constants.AppColors.inkSoft,
                            ),
                            fillColor: Colors.transparent,
                            filled: true,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: const BorderSide(color: Constants.AppColors.border),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: const BorderSide(color: Constants.AppColors.border),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: const BorderSide(color: Constants.AppColors.brand, width: 1.5),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const Divider(), // Divider to separate search field from list
                    // Labours List - updated design
                    labours.isEmpty
                        ? Center(
                      child: Text(
                        translate('Looking for nearby workers',
                            'आसपास के मजदूरों की तलाश की जा रही है'),
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          color: Colors.brown,
                        ),
                      ),
                    )
                        : Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: labours.length,
                        itemBuilder: (context, index) {
                          final labour = labours[index];

                          // Helper to determine type
                          String labourType = labour['type'] == '0'
                              ? translateText('Individual')
                              : translateText('Agency');

                          // Get skills or aboutme as subtitle
                          String subtitle = labour['skills']?.toString() ?? '';
                          if (subtitle.isEmpty) {
                            subtitle = labour['aboutme']?.toString() ?? '';
                          }

                          // Split skills into tags (if any)
                          List<String> skillTags = [];
                          if (labour['skills'] != null && labour['skills'].toString().isNotEmpty) {
                            skillTags = labour['skills'].toString().split(',').map((s) => s.trim()).where((s) => s.isNotEmpty).toList();
                          }

                          // If no skills, we can show education or certifications as fallback tags
                          if (skillTags.isEmpty && labour['education'] != null && labour['education'].toString().isNotEmpty) {
                            skillTags.add(labour['education'].toString());
                          }
                          // Limit to 2 tags
                          if (skillTags.length > 2) skillTags = skillTags.sublist(0, 2);

                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => LabourDetailsPage(
                                    labour: labour,
                                  ),
                                ),
                              );
                            },
                            child: Container(
                              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                              decoration: BoxDecoration(
                                color: Constants.AppColors.card,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: Constants.AppColors.border, width: 1.0),
                                boxShadow: const [Constants.AppShadows.soft],
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(10.0),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Avatar
                                    Stack(
                                      children: [
                                        Container(
                                          width: 54,
                                          height: 54,
                                          decoration: BoxDecoration(
                                            color: Constants.AppColors.brandTint,
                                            borderRadius: BorderRadius.circular(27),
                                            border: Border.all(color: Constants.AppColors.brandSoft, width: 1.5),
                                          ),
                                          child: ClipRRect(
                                            borderRadius: BorderRadius.circular(27),
                                            child: (labour['profile_image'] != null && labour['profile_image'].toString().isNotEmpty)
                                                ? Image.network(
                                              labour['profile_image'].toString(),
                                              fit: BoxFit.cover,
                                              errorBuilder: (context, error, stackTrace) {
                                                return const Icon(Icons.person, color: Constants.AppColors.brand, size: 28);
                                              },
                                            )
                                                : const Icon(Icons.person, color: Constants.AppColors.brand, size: 28),
                                          ),
                                        ),
                                        Positioned(
                                          bottom: 0,
                                          right: 0,
                                          child: Container(
                                            padding: const EdgeInsets.all(1),
                                            decoration: const BoxDecoration(
                                              color: Colors.white,
                                              shape: BoxShape.circle,
                                            ),
                                            child: Container(
                                              padding: const EdgeInsets.all(2),
                                              decoration: const BoxDecoration(
                                                color: Colors.green,
                                                shape: BoxShape.circle,
                                              ),
                                              child: const Icon(
                                                Icons.check,
                                                color: Colors.white,
                                                size: 8,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(width: 12),
                                    // Info
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              // Name and type badge
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      translateText(labour['name'] ?? 'Unknown'),
                                                      style: Constants.AppTypography.h3.copyWith(
                                                        color: Constants.AppColors.ink,
                                                        fontWeight: FontWeight.bold,
                                                        fontSize: 15,
                                                      ),
                                                      overflow: TextOverflow.ellipsis,
                                                    ),
                                                    const SizedBox(height: 2),
                                                    Container(
                                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                                      decoration: BoxDecoration(
                                                        color: labour['type'] == '0'
                                                            ? const Color(0xFFE8F5E9)
                                                            : const Color(0xFFE3F2FD),
                                                        borderRadius: BorderRadius.circular(4),
                                                      ),
                                                      child: Text(
                                                        labourType,
                                                        style: Constants.AppTypography.micro.copyWith(
                                                          color: labour['type'] == '0'
                                                              ? const Color(0xFF2E7D32)
                                                              : const Color(0xFF1565C0),
                                                          fontSize: 10,
                                                          fontWeight: FontWeight.bold,
                                                        ),
                                                      ),
                                                    ),
                                                    if (labour['phone_view'] != 1) ...[
                                                      const SizedBox(height: 4),
                                                      Container(
                                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                                        decoration: BoxDecoration(
                                                          color: const Color(0xFFFFF3E0),
                                                          borderRadius: BorderRadius.circular(4),
                                                          border: Border.all(color: const Color(0xFFFFB74D), width: 0.5),
                                                        ),
                                                        child: Row(
                                                          mainAxisSize: MainAxisSize.min,
                                                          children: [
                                                            const Icon(Icons.monetization_on, color: Color(0xFFFFA500), size: 10),
                                                            const SizedBox(width: 3),
                                                            Text(
                                                              '$_coinCharge ${translateText("Coins")}',
                                                              style: Constants.AppTypography.micro.copyWith(
                                                                color: const Color(0xFFE65100),
                                                                fontSize: 9,
                                                                fontWeight: FontWeight.bold,
                                                              ),
                                                              overflow: TextOverflow.ellipsis,
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ],
                                                  ],
                                                ),
                                              ),
                                              // Tags (skills) in top right
                                              if (skillTags.isNotEmpty)
                                                Flexible(
                                                  child: Wrap(
                                                    alignment: WrapAlignment.end,
                                                    spacing: 4,
                                                    runSpacing: 2,
                                                    children: skillTags.map((tag) {
                                                      return Container(
                                                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                                                        decoration: BoxDecoration(
                                                          color: Constants.AppColors.surface2,
                                                          borderRadius: BorderRadius.circular(6),
                                                          border: Border.all(color: Constants.AppColors.border, width: 0.5),
                                                        ),
                                                        child: Text(
                                                          translateText(tag),
                                                          style: Constants.AppTypography.micro.copyWith(
                                                            color: Constants.AppColors.ink,
                                                            fontSize: 9,
                                                            fontWeight: FontWeight.w600,
                                                          ),
                                                        ),
                                                      );
                                                    }).toList(),
                                                  ),
                                                ),
                                            ],
                                          ),
                                          const SizedBox(height: 4),
                                          // Location
                                          Row(
                                            children: [
                                              const Icon(
                                                Icons.location_on_outlined,
                                                size: 12,
                                                color: Constants.AppColors.inkSoft,
                                              ),
                                              const SizedBox(width: 4),
                                              Expanded(
                                                child: Text(
                                                  '${translateText(labour['city'] ?? 'Unknown City')}, ${translateText(labour['state'] ?? '')}',
                                                  style: Constants.AppTypography.body.copyWith(
                                                    color: Constants.AppColors.inkSoft,
                                                    fontSize: 12,
                                                  ),
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ),
                                            ],
                                          ),
                                          // Subtitle (skills or aboutme)
                                          if (subtitle.isNotEmpty) ...[
                                            const SizedBox(height: 4),
                                            Row(
                                              children: [
                                                const Icon(
                                                  Icons.work_outline,
                                                  size: 12,
                                                  color: Constants.AppColors.brand,
                                                ),
                                                const SizedBox(width: 4),
                                                Expanded(
                                                  child: Text(
                                                    subtitle.length > 40 ? '${subtitle.substring(0, 40)}...' : subtitle,
                                                    style: Constants.AppTypography.body.copyWith(
                                                      color: Constants.AppColors.inkSoft,
                                                      fontSize: 11,
                                                    ),
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        title,
        style: Constants.AppTypography.h2,
      ),
    );
  }

  Widget _buildProjectList() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: filteredProjects.length,
      itemBuilder: (context, index) {
        var project = filteredProjects[index];
        return Card(
          elevation: 4.0,
          margin: const EdgeInsets.symmetric(vertical: 8.0),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(project['title'] ?? 'Untitled Project'),
                const SizedBox(height: 8.0),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(project['description'] ?? 'No description'),
                    ),
                    SpeakerIconButton(text: project['description'] ?? 'No description'),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class LabourAnimated extends StatefulWidget {
  final dynamic labour;
  final int index;
  const LabourAnimated({required this.labour, required this.index});

  @override
  State<LabourAnimated> createState() => _LabourAnimatedState();
}

class _LabourAnimatedState extends State<LabourAnimated> {
  Map<String, Map<String, String>> _cachedTranslations = {};

  Map<String, Map<String, String>> translations =
      Constants.AppConstants.translations;

  final GoogleTranslator _translator = GoogleTranslator();
  final _secureStorage = const FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    loadLanguage();
  }

  String _selectedLanguage = 'en'; // Default language is English

  Future<void> loadLanguage() async {
    // Read the selected language from FlutterSecureStorage
    String? language = await _secureStorage.read(key: 'selectedLanguage');
    _selectedLanguage = language ?? 'en';
    print(language); // Default to English if null
  }

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
    } catch (e) {
      print("Translation error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFEBF5F0),
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 5,
          ),
        ],
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.green,
          child: Text(
            translateText(widget.labour['name'][0].toUpperCase()),
            style: const TextStyle(color: Colors.white),
          ),
        ),
        title: Text(
          translateText(widget.labour['name'] ?? 'Unknown'),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          '${translateText(widget.labour['city'] ?? 'Unknown City')}, ${translateText(widget.labour['state'] ?? 'Unknown State')}',
        ),
        trailing: Column(
          children: [
            Text(
              widget.labour['type'] == '0'
                  ? translateText('Individual')
                  : translateText('Agency'),
            ),
            if (widget.labour['type'] == '1')
              Text(
                '${translateText(widget.labour['agency_name'])}',
              ),
            // GestureDetector(
            //   onTap: () {
            //     // Trigger dialer when phone number is tapped
            //     if (labour['phone'] != null) {
            //       _launchPhoneDialer(labour['phone']);
            //     }
            //   },
            //   child: Text(
            //     labour['phone'] ?? 'N/A',
            //     style: const TextStyle(color: Colors.green),
            //   ),
            // ),
          ],
        ),
      ),
    );
  }
}

class ProjectPage extends StatefulWidget {
  @override
  _ProjectPageState createState() => _ProjectPageState();
}

class _ProjectPageState extends State<ProjectPage> {
  final _secureStorage = const FlutterSecureStorage();
  List<dynamic> projects = [];
  List<dynamic> filteredProjects = []; // To store filtered results
  bool isLoading = true;
  TextEditingController _searchController = TextEditingController();
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
  late stt.SpeechToText _speech;

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();

    fetchProjects();
    loadLanguage();
  }

  String translateText(String text) {
    final language =
        Provider.of<LanguageProvider>(context, listen: false).selectedLanguage;
    if (text.isEmpty) return "";

    // ✅ Ensure `_selectedLanguage` is set before calling `translateText()`
    String targetLang = language ?? 'en'; // Default to English if null

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

  Future<void> fetchProjects() async {
    final String apiUrl = '${Constants.AppConstants.apiUrl}farmer/getprojects';

    // Get user ID from secure storage
    String? userId = await _secureStorage.read(key: 'id');
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User ID not found in secure storage')),
      );
      return;
    }

    final Map<String, dynamic> requestBody = {
      'id': userId,
    };

    print(jsonEncode(requestBody));

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );
      print(json.decode(response.body)['data']);
      if (response.statusCode == 200) {
        setState(() {
          projects = json.decode(response.body)['data'];
          filteredProjects =
              projects; // Set the filtered list to all projects initially
          isLoading = false;
        });
      } else {
        setState(() {
          // Set the filtered list to all projects initially
          isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('No Projects Created Yet')),
        );
      }
    } catch (e) {
      isLoading = false;
    }
  }

  void filterProjects(String query) {
    setState(() {
      filteredProjects = projects.where((project) {
        String title =
            project['title'] ?? ''; // Default to empty string if null
        String budget =
            project['budget']?.toString() ?? ''; // Convert to string if null
        String city = project['city'] ?? ''; // Default to empty string if null
        String state =
            project['state'] ?? ''; // Default to empty string if null

        // Perform the filtering check
        return title.toLowerCase().contains(query.toLowerCase()) ||
            budget.toLowerCase().contains(query.toLowerCase()) ||
            city.toLowerCase().contains(query.toLowerCase()) ||
            state.toLowerCase().contains(query.toLowerCase());
      }).toList();
    });
  }

  bool _isListening = false;
  String _searchText = '';

  void _startListening() async {
    // Get selected language from the provider
    final language =
        Provider.of<LanguageProvider>(context, listen: false).selectedLanguage;

    // Set the locale based on the selected language
    String localeId = language == 'en'
        ? 'en_US'
        : 'hi_IN'; // 'en' for English, 'hi' for Hindi

    bool available = await _speech.initialize();
    if (available) {
      setState(() {
        _isListening = true;
      });

      // Start listening and use the localeId based on selected language
      _speech.listen(
        localeId: localeId,
        onResult: (result) {
          setState(() {
            _searchText = result.recognizedWords;
            _searchController.text = _searchText;
            filterProjects(_searchText);
          });
        },
      );
    } else {
      // Handle speech recognition not available
      print("Speech recognition is not available.");
    }
  }

  void _stopListening() {
    setState(() {
      _isListening = false;
    });
    _speech.stop();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        SystemNavigator.pop();
        return false;
      },
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(color: Colors.white),
          child: SafeArea(
            child: Column(
              children: [
                // Search Bar
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (value) {
                      filterProjects(
                          value); // Filter projects based on search input
                    },
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.search, color: Colors.green),
                      hintText: AppLocalizations.of(context)!
                          .searchlabour, // Replace with AppLocalizations if needed
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
                      suffixIcon: MicIconButton(controller: _searchController),
                    ),
                  ),
                ),
                // Project List
                Expanded(
                  child: isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : filteredProjects.isEmpty
                      ? Center(
                    child: Text(
                      AppLocalizations.of(context)!.noProjectsFound,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: Colors.brown,
                      ),
                    ),
                  )
                      : ListView.builder(
                    itemCount: filteredProjects.length,
                    itemBuilder: (context, index) {
                      final project = filteredProjects[index];
                      return Container(
                        margin: const EdgeInsets.symmetric(
                            vertical: 10, horizontal: 15),
                        decoration: BoxDecoration(
                          color: Colors
                              .white, // Background color of the container
                          borderRadius: BorderRadius.circular(
                              8), // Rounds the corners
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(
                                  0.1), // Shadow color with transparency
                              blurRadius: 8, // How soft the shadow is
                              spreadRadius:
                              3, // How much the shadow expands
                              offset: Offset(0,
                                  4), // Vertical and horizontal offset for the shadow
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(15.0),
                          child: Column(
                            crossAxisAlignment:
                            CrossAxisAlignment.start,
                            children: [
                              // Title with semi-bold
                              Row(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        left: 4.0),
                                    child: Text(
                                      translateText(
                                          project['title'] ?? 'N/A'),
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight
                                            .w600, // Semi-bold
                                      ),
                                      maxLines:
                                      2, // Limit to two lines
                                      overflow: TextOverflow
                                          .ellipsis, // Show ellipsis after two lines
                                      softWrap:
                                      true, // Enable text wrapping
                                    ),
                                  ),
                                ],
                              ),

                              Row(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        left: 4.0),
                                    child: Text(
                                      AppLocalizations.of(
                                          context)!
                                          .location +
                                          " : ",
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight
                                            .w600, // Semi-bold for title
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Text(
                                      "${translateText(project['city'] ?? 'N/A')} ${translateText(project['state'] ?? 'N/A')} ${project['pincode'] ?? 'N/A'}",
                                      style: const TextStyle(
                                          fontSize: 16),
                                    ),
                                  ),
                                ],
                              ),
                              // Project Type and Labours Required
                              Row(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        left: 4.0),
                                    child: Row(
                                      children: [
                                        Text(
                                          AppLocalizations.of(
                                              context)!
                                              .projectType +
                                              " : ",
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight
                                                .w600, // Semi-bold for title
                                          ),
                                        ),
                                        Text(
                                          translateText('On ' +
                                              (project[
                                              'project_type'] ??
                                                  'N/A')),
                                          style: const TextStyle(
                                              fontSize: 16),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        left: 4.0),
                                    child: Row(
                                      children: [
                                        Text(
                                          AppLocalizations.of(
                                              context)!
                                              .noOfLaboursRequired +
                                              " : ",
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight
                                                .w600, // Semi-bold for title
                                          ),
                                        ),
                                        Text(
                                          (project['qty_labours'] ??
                                              'N/A'),
                                          style: const TextStyle(
                                              fontSize: 16),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                crossAxisAlignment:
                                CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        left: 4.0),
                                    child: Row(
                                      crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          AppLocalizations.of(
                                              context)!
                                              .requiredSkills +
                                              " : ",
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight
                                                .w600, // Semi-bold for title
                                          ),
                                        ),
                                        Container(
                                          constraints: BoxConstraints(
                                            maxWidth:
                                            MediaQuery.of(context)
                                                .size
                                                .width -
                                                170,
                                          ),
                                          child: Column(
                                            mainAxisAlignment:
                                            MainAxisAlignment
                                                .start,
                                            crossAxisAlignment:
                                            CrossAxisAlignment
                                                .start,
                                            children: [
                                              Text(
                                                (translateText(project[
                                                'required_skills'] ??
                                                    'N/A')),
                                                style:
                                                const TextStyle(
                                                    fontSize: 16),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        left: 4.0),
                                    child: Row(
                                      children: [
                                        Text(
                                          AppLocalizations.of(
                                              context)!
                                              .budget +
                                              " : ",
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight
                                                .w600, // Semi-bold for title
                                          ),
                                        ),
                                        Text(
                                          (project['budget']
                                              .toString() ??
                                              'N/A') +
                                              "  ",
                                          style: const TextStyle(
                                              fontSize: 16),
                                        ),
                                        Text(
                                          AppLocalizations.of(
                                              context)!
                                              .duration +
                                              " : ",
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight
                                                .w600, // Semi-bold for title
                                          ),
                                        ),
                                        Text(
                                          (project['days']
                                              .toString() ??
                                              'N/A'),
                                          style: const TextStyle(
                                              fontSize: 16),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 10),
                              Row(
                                children: [
                                  if (project['applicants']
                                      .toString() ==
                                      "1")
                                    ElevatedButton(
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                ProjectApplicationsPage(
                                                  projectId: project['id']
                                                      .toString(),
                                                ),
                                          ),
                                        );
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor:
                                        const Color.fromARGB(
                                            255, 19, 70, 27),
                                        foregroundColor: Colors.green,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                          BorderRadius.all(
                                            Radius.circular(
                                                2.0), // Curves all corners
                                          ),
                                        ),
                                      ),
                                      child: Text(
                                        AppLocalizations.of(context)!
                                            .viewApplications,
                                        style: const TextStyle(
                                            color: Colors.white),
                                      ),
                                    ),
                                  if (project['applicants']
                                      .toString() ==
                                      "1")
                                    const SizedBox(width: 10),
                                  ElevatedButton(
                                    onPressed:
                                    project['applicants']
                                        .toString() ==
                                        "1"
                                        ? () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              ProjectDetails(
                                                  projectId:
                                                  project['id']
                                                      .toString()),
                                        ),
                                      );
                                    }
                                        : () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              UpdateProject(
                                                  projectId:
                                                  project['id']
                                                      .toString()),
                                        ),
                                      );
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor:
                                      const Color.fromARGB(
                                          255, 19, 70, 27),
                                      foregroundColor: Colors.green,
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                        BorderRadius.all(
                                            Radius.circular(2.0)),
                                      ),
                                    ),
                                    child: Text(
                                      translateText('Details'),
                                      style: const TextStyle(
                                          color: Colors.white),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
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

class ProfilePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        "This is the Profile Page",
        style: TextStyle(fontSize: 24, color: Colors.blue),
      ),
    );
  }
}

class ProjectApplicationsPage extends StatefulWidget {
  final String projectId;

  ProjectApplicationsPage({required this.projectId});

  @override
  _ProjectApplicationsPageState createState() =>
      _ProjectApplicationsPageState();
}

class _ProjectApplicationsPageState extends State<ProjectApplicationsPage> {
  bool isLoading = true;
  List<dynamic> applications = [];

  final _secureStorage = const FlutterSecureStorage();
  bool _isProcessing = false;
  late stt.SpeechToText _speech;

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    loadLanguage();
    fetchProjectApplications();
  }

  Future<void> fetchProjectApplications() async {
    final String apiUrl =
        '${Constants.AppConstants.apiUrl}farmer/farmerProjectDetails';
    String? userId = await _secureStorage.read(key: 'id');
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User ID not found in secure storage')),
      );
      return;
    }

    // Prepare the request body
    final Map<String, dynamic> requestBody = {
      'id': userId,
      'project_id': widget.projectId,
    };
    print(
      jsonEncode(requestBody),
    );
    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData['success'] == true) {
          setState(() {
            applications = responseData['data']['applications'];
            print(applications);
            isLoading = false;
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to fetch project details')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to fetch project details')),
        );
      }
    } catch (e) {}
  }

  Future<void> unassignProject(String labourId, String projectId) async {
    setState(() {
      _isProcessing = true; // Show loading indicator
    });

    // API URL
    String url = '${Constants.AppConstants.apiUrl}farmer/unassignProject';

    // Sending POST request
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
        // Success, show message and update UI
        final data = json.decode(response.body);
        if (data['status'] == '1') {
          await fetchProjectApplications();
          setState(() {
            _isProcessing = false; // Hide loading indicator
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(data['message'])),
          );
        }
      } else {
        setState(() {
          _isProcessing = false; // Hide loading indicator
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to unassign job')),
        );
      }
    } catch (e) {
      setState(() {
        _isProcessing = false; // Hide loading indicator
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  Future<void> cancelConfirm(
      String projectId, String labourId, String cancelRemark) async {
    setState(() {
      _isProcessing = true; // Show loading indicator
    });

    // API URL
    String url = '${Constants.AppConstants.apiUrl}farmer/cancelConfirm';

    // Sending POST request
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
        // Success, show message and update UI
        final data = json.decode(response.body);
        if (data['status'] == '1') {
          await fetchProjectApplications();
          setState(() {
            _isProcessing = false; // Hide loading indicator
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(data['message'])),
          );
        }
      } else {
        setState(() {
          _isProcessing = false; // Hide loading indicator
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to send cancel request')),
        );
      }
    } catch (e) {
      setState(() {
        _isProcessing = false; // Hide loading indicator
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  // Function to show the dialog for cancel remarks
  void showCancelDialog(BuildContext context, String labourId) {
    TextEditingController _cancelRemarkController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Cancel Remark'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _cancelRemarkController,
                decoration: InputDecoration(
                  labelText: 'Enter Cancel Remark',
                  border: OutlineInputBorder(),
                  suffixIcon: MicIconButton(controller: _cancelRemarkController),
                ),
                maxLines: 3,
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (_cancelRemarkController.text.isNotEmpty) {
                  cancelConfirm(
                    widget.projectId,
                    labourId,
                    _cancelRemarkController.text,
                  );
                  Navigator.of(context).pop(); // Close the dialog
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Remark cannot be empty')),
                  );
                }
              },
              child: const Text('Submit'),
            ),
          ],
        );
      },
    );
  }

  Future<void> confirmComplete(String projectId, String labourId) async {
    setState(() {
      _isProcessing = true; // Show loading indicator
    });

    // API URL
    String url = '${Constants.AppConstants.apiUrl}farmer/confirmComplete';

    // Sending POST request
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
        // Success, show message and update UI
        final data = json.decode(response.body);
        if (data['status'] == '1') {
          await fetchProjectApplications();
          setState(() {
            _isProcessing = false; // Hide loading indicator
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(data['message'])),
          );
        }
      } else {
        setState(() {
          _isProcessing = false; // Hide loading indicator
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to confirm completion')),
        );
      }
    } catch (e) {
      setState(() {
        _isProcessing = false; // Hide loading indicator
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  Future<void> assignProject(String labourId) async {
    final String apiUrl =
        '${Constants.AppConstants.apiUrl}farmer/projectAssigned';
    String? userId = await _secureStorage.read(key: 'id');
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User ID not found in secure storage')),
      );
      return;
    }

    // Prepare the request body
    final Map<String, dynamic> requestBody = {
      'labourid': labourId,
      'projectid': widget.projectId,
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
          await fetchProjectApplications();
          setState(() {});
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Project assigned successfully')),
          );
          Future.delayed(Duration(seconds: 1), () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => HomePage(),
              ),
            );
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(
                    'Failed to assign project: ${responseData['message']}')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to assign project')),
        );
      }
    } catch (e) {}
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

  String _formatDate(String dateString) {
    try {
      // Parse the date string to DateTime object
      DateTime dateTime = DateTime.parse(dateString);
      // Format the DateTime object to "dd-MM-yyyy"
      return DateFormat('dd-MM-yyyy').format(dateTime);
    } catch (e) {
      // In case of any error, return the original date string
      return dateString;
    }
  }

  String getStatusText(String status) {
    switch (status) {
      case '0':
        return AppLocalizations.of(context)!.notAssigned;
      case '1':
        return AppLocalizations.of(context)!.assigned;
      case '2':
        return AppLocalizations.of(context)!.workStarted;
      case '3':
        return AppLocalizations.of(context)!.completed;
      default:
        return AppLocalizations.of(context)!.cancelled;
    }
  }

  @override
  Widget build(BuildContext context) {
    final language =
        Provider.of<LanguageProvider>(context, listen: false).selectedLanguage;

    String translate(String enText, String hiText) {
      return language == 'en' ? enText : hiText;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context)!
              .projectApplications, // Corrected to use localization key
          style: const TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: Constants.AppColors.brandGradient,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back), // Default back arrow icon
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => HomePage(),
              ),
            ); // This will pop the current page and go back to the previous screen
          },
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : applications.isEmpty
          ? Center(
          child: Text(AppLocalizations.of(context)!
              .noApplicationsFound)) // Localized "No applications found"
          : ListView.builder(
        itemCount: applications.length,
        itemBuilder: (context, index) {
          final application = applications[index];
          return Card(
            margin:
            EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
            elevation: 4.0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ListTile(
                    contentPadding: EdgeInsets.all(16.0),
                    title: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "${translate('Worker Name', 'श्रमिक का नाम')}: ${translateText(application['labour_name'] ?? 'N/A')}",
                          style:
                          TextStyle(fontWeight: FontWeight.bold),
                        ),
                        // Comment
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                              child: Text(
                                "${AppLocalizations.of(context)!.comment}: ${translateText(application['comment'] ?? 'N/A')}",
                              ),
                            ),
                            SpeakerIconButton(
                              text: translateText(application['comment'] ?? 'N/A') ?? 'N/A',
                            ),
                          ],
                        ),
                        // Date
                        Text(
                          "${translateText('Date')}: ${_formatDate(application['created_at'])}",
                        ),
                        // Location
                        Text(
                          "${AppLocalizations.of(context)!.location}: ${translateText('${application['labour_address']}, ${application['labour_city']}, ${application['labour_state']}')}",
                        ),
                        // Status
                        Text(
                          "${translateText('Status')}: ${getStatusText(application['status'])}",
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  bottom: 8.0,
                  right: 8.0,
                  child: ElevatedButton(
                    onPressed: () {
                      // Navigate to the ApplicationDetailPage when clicking on 'View Details'
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ApplicationDetailPage(
                            application: application,
                          ),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius:
                        BorderRadius.all(Radius.circular(8.0)),
                      ),
                      disabledBackgroundColor: Colors.red,
                      backgroundColor:
                      const Color.fromARGB(255, 19, 70, 27),
                      foregroundColor: Colors.white,
                    ),
                    child: Text(
                      AppLocalizations.of(context)!.viewDetails,
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}