// // import 'dart:async';
// // import 'package:greencollar/speech_helper.dart';
// // import 'dart:convert';
// // import 'dart:io';
// // import 'package:geolocator/geolocator.dart';
// // import 'package:geocoding/geocoding.dart';
// // import 'package:greencollar/l10n/app_localizations.dart';
// //
// // import 'package:flutter/material.dart';
// // import 'package:flutter/services.dart';
// // import 'package:flutter_secure_storage/flutter_secure_storage.dart';
// // import 'package:greencollar/Addproject.dart';
// // import 'package:greencollar/NearbyProject.dart';
// // import 'package:greencollar/Nearbylabours.dart';
// // import 'package:greencollar/ProjectDetails.dart';
// // import 'package:greencollar/UpdateProject.dart';
// // import 'package:greencollar/application_detaill.dart';
// // import 'package:greencollar/main.dart';
// // import 'package:greencollar/noti.dart';
// // import 'package:greencollar/updateprofile.dart';
// // import 'package:greencollar/workerdetails.dart';
// // import 'package:intl/intl.dart';
// // import 'package:permission_handler/permission_handler.dart';
// // import 'package:provider/provider.dart';
// // import 'package:greencollar/location_provider.dart';
// // import 'package:http/http.dart' as http;
// // import 'package:speech_to_text/speech_to_text.dart' as stt;
// // import 'package:translator/translator.dart';
// // import 'package:url_launcher/url_launcher.dart';
// // import 'package:cached_network_image/cached_network_image.dart';
// // import 'package:greencollar/constants.dart' as Constants;
// // import 'package:carousel_slider/carousel_slider.dart';
// // import 'package:smooth_page_indicator/smooth_page_indicator.dart';
// // import 'package:greencollar/wallet_helper.dart';
// // import 'package:greencollar/api_logger.dart';
// //
// // class JobType {
// //   final int id;
// //   final String jobname;
// //   final String image;
// //   final String status;
// //
// //   JobType({
// //     required this.id,
// //     required this.jobname,
// //     required this.image,
// //     required this.status,
// //   });
// //
// //   factory JobType.fromJson(Map<String, dynamic> json) {
// //     return JobType(
// //       id: json['id'],
// //       jobname: json['jobname'],
// //       image: json['image'],
// //       status: json['status'],
// //     );
// //   }
// // }
// //
// // class HomePage extends StatefulWidget {
// //   @override
// //   _HomePageState createState() => _HomePageState();
// // }
// //
// // class _HomePageState extends State<HomePage> {
// //   int _currentIndex = 0;
// //   final _secureStorage = const FlutterSecureStorage();
// //
// //   String _selectedLanguage = 'en';
// //   String _userName = '';
// //   String _userType = '';
// //   int _walletCoins = 0;
// //
// //   Future<void> _loadWalletBalance() async {
// //     int coins = await WalletHelper.syncCoinBalance();
// //     if (mounted) {
// //       setState(() {
// //         _walletCoins = coins;
// //       });
// //     }
// //   }
// //
// //   Future<void> _loadUserInfo() async {
// //     String? name = await _secureStorage.read(key: 'name');
// //     String? userType = await _secureStorage.read(key: 'userType');
// //     setState(() {
// //       _userName = name ?? '';
// //       _userType = userType ?? 'farmer';
// //     });
// //   }
// //
// //   Future<void> loadLanguage() async {
// //     await fetchUnreadNotificationsCount();
// //     String? language = await _secureStorage.read(key: 'selectedLanguage');
// //     _selectedLanguage = language ?? 'en';
// //   }
// //
// //   Map<String, Map<String, String>> _cachedTranslations = {};
// //   int unreadNotificationsCount = 0;
// //
// //   Map<String, Map<String, String>> translations =
// //       Constants.AppConstants.translations;
// //   final GoogleTranslator _translator = GoogleTranslator();
// //
// //   @override
// //   void initState() {
// //     super.initState();
// //     loadLanguage();
// //     _loadUserInfo();
// //     _loadWalletBalance();
// //     ApiLogger.logScreenOpened('CombinedPage');
// //   }
// //
// //   Future<void> fetchUnreadNotificationsCount() async {
// //     String? userId = await _secureStorage.read(key: 'id');
// //     if (userId == null) return;
// //     final url = Uri.parse(
// //         '${Constants.AppConstants.apiUrl}farmer/getUnreadNotificationsCount');
// //     try {
// //       final response = await http.post(url, body: {'id': userId});
// //       if (response.statusCode == 200) {
// //         final responseData = json.decode(response.body);
// //         if (responseData['status'] == 'success') {
// //           setState(() {
// //             unreadNotificationsCount =
// //             responseData['unread_notifications_count'];
// //           });
// //         }
// //       }
// //     } catch (e) {
// //       print('Error: $e');
// //     }
// //   }
// //
// //   Future<String> translateText(String text) async {
// //     if (text.isEmpty) return "";
// //     String targetLang = _selectedLanguage ?? 'en';
// //     if (translations.containsKey(text) &&
// //         translations[text]!.containsKey(targetLang)) {
// //       return translations[text]![targetLang]!;
// //     }
// //     if (_cachedTranslations.containsKey(text) &&
// //         _cachedTranslations[text]!.containsKey(targetLang)) {
// //       return _cachedTranslations[text]![targetLang]!;
// //     }
// //     String translatedText = await _fetchTranslation(text, targetLang);
// //     return translatedText;
// //   }
// //
// //   Future<String> _fetchTranslation(String text, String targetLang) async {
// //     try {
// //       if (Constants.AppConstants.translations.containsKey(text) &&
// //           Constants.AppConstants.translations[text]!.containsKey(targetLang)) {
// //         return Constants.AppConstants.translations[text]![targetLang]!;
// //       }
// //       final translation = await _translator.translate(text, to: targetLang);
// //       translations.putIfAbsent(text, () => {});
// //       translations[text]![targetLang] = translation.text;
// //       _cachedTranslations.putIfAbsent(text, () => {});
// //       _cachedTranslations[text]![targetLang] = translation.text;
// //       Constants.AppConstants.translations.putIfAbsent(text, () => {});
// //       Constants.AppConstants.translations[text]![targetLang] = translation.text;
// //       setState(() {});
// //       return translation.text;
// //     } catch (e) {
// //       return text;
// //     }
// //   }
// //
// //   final List<Widget> _pages = [
// //     CombinedPage(),
// //     LabourPage(),
// //     ProjectPage(),
// //   ];
// //
// //   Future<void> _logout(BuildContext context) async {
// //     await _secureStorage.delete(key: 'id');
// //     await _secureStorage.delete(key: 'token');
// //     await _secureStorage.delete(key: 'name');
// //     await _secureStorage.delete(key: 'phone');
// //     await _secureStorage.delete(key: 'userType');
// //     Navigator.pushReplacement(
// //       context,
// //       MaterialPageRoute(builder: (context) => const LoginScreen()),
// //     );
// //   }
// //
// //   Widget _buildDrawerTile({
// //     required IconData icon,
// //     required Widget title,
// //     required VoidCallback onTap,
// //     Widget? trailing,
// //     bool isLogout = false,
// //   }) {
// //     final Color tintColor = isLogout ? const Color(0xFFFEF2F2) : Constants.AppColors.brandTint;
// //     final Color iconColor = isLogout ? const Color(0xFFEF4444) : Constants.AppColors.brand;
// //
// //     return Padding(
// //       padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
// //       child: ListTile(
// //         shape: RoundedRectangleBorder(
// //           borderRadius: BorderRadius.circular(Constants.AppRadii.sm),
// //         ),
// //         leading: Container(
// //           height: 40,
// //           width: 40,
// //           decoration: BoxDecoration(
// //             color: tintColor,
// //             borderRadius: BorderRadius.circular(10),
// //           ),
// //           child: Icon(icon, color: iconColor, size: 20),
// //         ),
// //         title: title,
// //         trailing: trailing ??
// //             Icon(
// //               Icons.chevron_right_rounded,
// //               color: isLogout ? const Color(0xFFEF4444) : const Color(0xFF9CA3AF),
// //               size: 20,
// //             ),
// //         onTap: onTap,
// //       ),
// //     );
// //   }
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     return WillPopScope(
// //       onWillPop: () async {
// //         SystemNavigator.pop();
// //         return false;
// //       },
// //       child: Scaffold(
// //         extendBody: true,
// //         appBar: AppBar(
// //           title: _currentIndex == 0
// //               ? Consumer<LocationProvider>(
// //             builder: (context, locationProvider, child) {
// //               Widget locationWidget;
// //               if (locationProvider.isLoading) {
// //                 locationWidget = Row(
// //                   mainAxisSize: MainAxisSize.min,
// //                   children: [
// //                     const SizedBox(
// //                       width: 12,
// //                       height: 12,
// //                       child: CircularProgressIndicator(
// //                         strokeWidth: 1.5,
// //                         valueColor: AlwaysStoppedAnimation<Color>(
// //                             Colors.white70),
// //                       ),
// //                     ),
// //                     const SizedBox(width: 6),
// //                     Text(
// //                       _selectedLanguage == 'en'
// //                           ? 'Finding location...'
// //                           : 'स्थान खोज रहे हैं...',
// //                       style: TextStyle(
// //                         fontSize: 12,
// //                         color: Colors.white.withOpacity(0.8),
// //                       ),
// //                     ),
// //                   ],
// //                 );
// //               } else if (locationProvider.error.isNotEmpty ||
// //                   (locationProvider.city.isEmpty &&
// //                       locationProvider.state.isEmpty)) {
// //                 locationWidget = Row(
// //                   mainAxisSize: MainAxisSize.min,
// //                   children: [
// //                     const Icon(Icons.location_off,
// //                         size: 14, color: Colors.white70),
// //                     const SizedBox(width: 4),
// //                     Text(
// //                       _selectedLanguage == 'en'
// //                           ? 'Location unavailable'
// //                           : 'स्थान अनुपलब्ध',
// //                       style: TextStyle(
// //                         fontSize: 12,
// //                         color: Colors.white.withOpacity(0.8),
// //                       ),
// //                     ),
// //                   ],
// //                 );
// //               } else {
// //                 locationWidget = Row(
// //                   mainAxisSize: MainAxisSize.min,
// //                   children: [
// //                     const Icon(Icons.location_on,
// //                         size: 14, color: Colors.white),
// //                     const SizedBox(width: 4),
// //                     Flexible(
// //                       child: Text(
// //                         '${locationProvider.city}, ${locationProvider.state}',
// //                         style: const TextStyle(
// //                           fontSize: 13,
// //                           color: Colors.white,
// //                           fontWeight: FontWeight.w500,
// //                         ),
// //                         overflow: TextOverflow.ellipsis,
// //                       ),
// //                     ),
// //                   ],
// //                 );
// //               }
// //
// //               return Column(
// //                 crossAxisAlignment: CrossAxisAlignment.start,
// //                 mainAxisSize: MainAxisSize.min,
// //                 children: [
// //                   Row(
// //                     mainAxisSize: MainAxisSize.min,
// //                     children: [
// //                       Container(
// //                         padding: const EdgeInsets.symmetric(
// //                             horizontal: 8, vertical: 3),
// //                         decoration: BoxDecoration(
// //                           color: Colors.transparent,
// //                           borderRadius: BorderRadius.circular(
// //                               Constants.AppRadii.sm),
// //                           border: Border.all(
// //                               color: Colors.white, width: 1.0),
// //                         ),
// //                         child: Text(
// //                           _selectedLanguage == 'en'
// //                               ? 'Farmer'
// //                               : 'किसान',
// //                           style: Constants.AppTypography.micro.copyWith(
// //                             color: Colors.white,
// //                           ),
// //                         ),
// //                       ),
// //                     ],
// //                   ),
// //                   const SizedBox(height: 4),
// //                   locationWidget,
// //                 ],
// //               );
// //             },
// //           )
// //               : Text(
// //             _currentIndex == 1
// //                 ? AppLocalizations.of(context)!.nearbylabours
// //                 : _currentIndex == 2
// //                 ? AppLocalizations.of(context)!.yourprojects
// //                 : 'Default Title',
// //             style: Constants.AppTypography.h1
// //                 .copyWith(color: Colors.white),
// //           ),
// //           iconTheme: const IconThemeData(color: Colors.white),
// //           backgroundColor: Constants.AppColors.brand,
// //           actions: [
// //             IconButton(
// //               icon: Stack(
// //                 children: [
// //                   const Icon(Icons.notifications),
// //                   if (unreadNotificationsCount > 0)
// //                     Positioned(
// //                       right: 0,
// //                       top: 0,
// //                       child: CircleAvatar(
// //                         radius: 8,
// //                         backgroundColor: Colors.red,
// //                         child: Text(
// //                           unreadNotificationsCount.toString(),
// //                           style: const TextStyle(
// //                             fontSize: 12,
// //                             color: Colors.white,
// //                           ),
// //                         ),
// //                       ),
// //                     ),
// //                 ],
// //               ),
// //               onPressed: () {
// //                 Navigator.pushReplacement(
// //                   context,
// //                   MaterialPageRoute(builder: (context) => NotificationsPage()),
// //                 );
// //               },
// //             ),
// //           ],
// //         ),
// //         drawer: Drawer(
// //           backgroundColor: Colors.white,
// //           child: Column(
// //             children: [
// //               Container(
// //                 padding: EdgeInsets.only(
// //                   top: MediaQuery.of(context).padding.top + 20,
// //                   bottom: 24,
// //                   left: 20,
// //                   right: 20,
// //                 ),
// //                 decoration: const BoxDecoration(
// //                   gradient: LinearGradient(
// //                     begin: Alignment.topCenter,
// //                     end: Alignment.bottomCenter,
// //                     colors: [
// //                       Constants.AppColors.brandDeep,
// //                       Constants.AppColors.brand,
// //                     ],
// //                   ),
// //                   borderRadius: BorderRadius.only(
// //                     bottomLeft: Radius.circular(24),
// //                     bottomRight: Radius.circular(24),
// //                   ),
// //                 ),
// //                 child: Row(
// //                   children: [
// //                     Container(
// //                       padding: const EdgeInsets.all(2),
// //                       decoration: const BoxDecoration(
// //                         color: Colors.white24,
// //                         shape: BoxShape.circle,
// //                       ),
// //                       child: CircleAvatar(
// //                         radius: 28,
// //                         backgroundColor: Colors.white,
// //                         child: Text(
// //                           _userName.isNotEmpty
// //                               ? _userName[0].toUpperCase()
// //                               : 'U',
// //                           style: const TextStyle(
// //                             color: Constants.AppColors.brandDeep,
// //                             fontSize: 24,
// //                             fontWeight: FontWeight.bold,
// //                           ),
// //                         ),
// //                       ),
// //                     ),
// //                     const SizedBox(width: 16),
// //                     Expanded(
// //                       child: Column(
// //                         crossAxisAlignment: CrossAxisAlignment.start,
// //                         mainAxisSize: MainAxisSize.min,
// //                         children: [
// //                           Text(
// //                             _userName.isNotEmpty ? _userName : 'User',
// //                             style: const TextStyle(
// //                               color: Colors.white,
// //                               fontSize: 18,
// //                               fontWeight: FontWeight.bold,
// //                             ),
// //                             overflow: TextOverflow.ellipsis,
// //                           ),
// //                           const SizedBox(height: 4),
// //                           Container(
// //                             padding: const EdgeInsets.symmetric(
// //                                 horizontal: 8, vertical: 4),
// //                             decoration: BoxDecoration(
// //                               color: Colors.white.withOpacity(0.15),
// //                               borderRadius: BorderRadius.circular(12),
// //                             ),
// //                             child: Text(
// //                               _userType == 'labour'
// //                                   ? (context
// //                                   .watch<LanguageProvider>()
// //                                   .selectedLanguage ==
// //                                   'en'
// //                                   ? 'Worker'
// //                                   : 'श्रमिक')
// //                                   : (context
// //                                   .watch<LanguageProvider>()
// //                                   .selectedLanguage ==
// //                                   'en'
// //                                   ? 'Farmer'
// //                                   : 'किसान'),
// //                               style: const TextStyle(
// //                                 color: Colors.white,
// //                                 fontSize: 11,
// //                                 fontWeight: FontWeight.w500,
// //                               ),
// //                             ),
// //                           ),
// //                         ],
// //                       ),
// //                     ),
// //                     GestureDetector(
// //                       onTap: () => Navigator.pop(context),
// //                       child: Container(
// //                         height: 36,
// //                         width: 36,
// //                         decoration: BoxDecoration(
// //                           color: Colors.white.withOpacity(0.15),
// //                           shape: BoxShape.circle,
// //                         ),
// //                         child: const Icon(
// //                           Icons.close,
// //                           color: Colors.white,
// //                           size: 18,
// //                         ),
// //                       ),
// //                     ),
// //                   ],
// //                 ),
// //               ),
// //               Expanded(
// //                 child: ListView(
// //                   padding: const EdgeInsets.symmetric(vertical: 12),
// //                   children: [
// //                     _buildDrawerTile(
// //                       icon: Icons.home,
// //                       title: FutureBuilder<String>(
// //                         future: translateText('Home'),
// //                         builder: (context, snapshot) {
// //                           return Text(
// //                             snapshot.data ?? 'Home',
// //                             style: const TextStyle(
// //                                 fontWeight: FontWeight.bold),
// //                           );
// //                         },
// //                       ),
// //                       onTap: () {
// //                         setState(() {
// //                           _currentIndex = 0;
// //                         });
// //                         Navigator.pop(context);
// //                       },
// //                     ),
// //                     _buildDrawerTile(
// //                       icon: Icons.search,
// //                       title: FutureBuilder<String>(
// //                         future: translateText('Search'),
// //                         builder: (context, snapshot) {
// //                           return Text(
// //                             snapshot.data ?? 'Search',
// //                             style: const TextStyle(
// //                                 fontWeight: FontWeight.bold),
// //                           );
// //                         },
// //                       ),
// //                       onTap: () {
// //                         setState(() {
// //                           _currentIndex = 1;
// //                         });
// //                         Navigator.pop(context);
// //                       },
// //                     ),
// //                     _buildDrawerTile(
// //                       icon: Icons.notifications,
// //                       title: FutureBuilder<String>(
// //                         future: translateText('Notifications'),
// //                         builder: (context, snapshot) {
// //                           return Row(
// //                             children: [
// //                               Text(
// //                                 snapshot.data ?? 'Notifications',
// //                                 style: const TextStyle(
// //                                     fontWeight: FontWeight.bold),
// //                               ),
// //                               if (unreadNotificationsCount > 0)
// //                                 Padding(
// //                                   padding: const EdgeInsets.only(left: 8.0),
// //                                   child: CircleAvatar(
// //                                     radius: 10,
// //                                     backgroundColor: Colors.red,
// //                                     child: Text(
// //                                       unreadNotificationsCount.toString(),
// //                                       style: const TextStyle(
// //                                         fontSize: 12,
// //                                         color: Colors.white,
// //                                       ),
// //                                     ),
// //                                   ),
// //                                 ),
// //                             ],
// //                           );
// //                         },
// //                       ),
// //                       onTap: () {
// //                         Navigator.pushReplacement(
// //                           context,
// //                           MaterialPageRoute(
// //                               builder: (context) => NotificationsPage()),
// //                         );
// //                       },
// //                     ),
// //                     _buildDrawerTile(
// //                       icon: Icons.language,
// //                       title: FutureBuilder<String>(
// //                         future: translateText(' Select Language'),
// //                         builder: (context, snapshot) {
// //                           return Text(
// //                             snapshot.data ?? 'Language',
// //                             style: const TextStyle(
// //                                 fontWeight: FontWeight.bold),
// //                           );
// //                         },
// //                       ),
// //                       onTap: () {
// //                         Navigator.push(
// //                           context,
// //                           MaterialPageRoute(
// //                             builder: (context) => LanguageSelectionScreen(),
// //                           ),
// //                         );
// //                       },
// //                     ),
// //                     _buildDrawerTile(
// //                       icon: Icons.notes,
// //                       title: FutureBuilder<String>(
// //                         future: translateText('Projects'),
// //                         builder: (context, snapshot) {
// //                           return Text(
// //                             snapshot.data ?? 'Projects',
// //                             style: const TextStyle(
// //                                 fontWeight: FontWeight.bold),
// //                           );
// //                         },
// //                       ),
// //                       onTap: () {
// //                         setState(() {
// //                           _currentIndex = 2;
// //                         });
// //                         Navigator.pop(context);
// //                       },
// //                     ),
// //                     _buildDrawerTile(
// //                       icon: Icons.account_balance_wallet,
// //                       title: FutureBuilder<String>(
// //                         future: translateText('Wallet'),
// //                         builder: (context, snapshot) {
// //                           final walletTitle = snapshot.data ?? 'Wallet';
// //                           return Text(
// //                             walletTitle,
// //                             style: const TextStyle(
// //                                 fontWeight: FontWeight.bold),
// //                           );
// //                         },
// //                       ),
// //                       onTap: () {
// //                         Navigator.pop(context);
// //                         WalletHelper.showCoinShop(context,
// //                             onCoinsAdded: (newBalance) {
// //                               setState(() => _walletCoins = newBalance);
// //                             });
// //                       },
// //                     ),
// //                     _buildDrawerTile(
// //                       icon: Icons.person,
// //                       title: FutureBuilder<String>(
// //                         future: translateText('Profile'),
// //                         builder: (context, snapshot) {
// //                           return Text(
// //                             snapshot.data ?? 'Profile',
// //                             style: const TextStyle(
// //                                 fontWeight: FontWeight.bold),
// //                           );
// //                         },
// //                       ),
// //                       onTap: () {
// //                         Navigator.push(
// //                           context,
// //                           MaterialPageRoute(
// //                             builder: (context) => UpdateLabourProfile(),
// //                           ),
// //                         );
// //                       },
// //                     ),
// //                     const Divider(
// //                         color: Constants.AppColors.border,
// //                         height: 24,
// //                         thickness: 1),
// //                     _buildDrawerTile(
// //                       icon: Icons.logout,
// //                       isLogout: true,
// //                       title: FutureBuilder<String>(
// //                         future: translateText('Logout'),
// //                         builder: (context, snapshot) {
// //                           return Text(
// //                             snapshot.data ?? 'Logout',
// //                             style: const TextStyle(
// //                                 fontWeight: FontWeight.bold),
// //                           );
// //                         },
// //                       ),
// //                       onTap: () => _logout(context),
// //                     ),
// //                   ],
// //                 ),
// //               ),
// //             ],
// //           ),
// //         ),
// //         body: SafeArea(
// //           child: _pages[_currentIndex],
// //         ),
// //         bottomNavigationBar: Container(
// //           decoration: BoxDecoration(
// //             gradient: Constants.AppColors.brandGradient,
// //             borderRadius: const BorderRadius.only(
// //               topLeft: Radius.circular(28),
// //               topRight: Radius.circular(28),
// //             ),
// //             boxShadow: const [Constants.AppShadows.fab],
// //           ),
// //           child: ClipRRect(
// //             borderRadius: const BorderRadius.only(
// //               topLeft: Radius.circular(28),
// //               topRight: Radius.circular(28),
// //             ),
// //             child: BottomNavigationBar(
// //               backgroundColor: Colors.transparent,
// //                 currentIndex: _currentIndex,
// //                 selectedItemColor: Colors.white,
// //                 unselectedItemColor: Colors.white70,
// //                 selectedLabelStyle: Constants.AppTypography.label.copyWith(
// //                   color: Colors.white,
// //                   fontWeight: FontWeight.bold,
// //                 ),
// //                 unselectedLabelStyle: Constants.AppTypography.label.copyWith(
// //                   color: Colors.white70,
// //                 ),
// //                 showUnselectedLabels: false,
// //                 elevation: 0,
// //                 type: BottomNavigationBarType.fixed,
// //                 items: [
// //                   BottomNavigationBarItem(
// //                       icon: const Icon(Icons.home),
// //                       label: AppLocalizations.of(context)!.homepage),
// //                   BottomNavigationBarItem(
// //                       icon: const Icon(Icons.search),
// //                       label: AppLocalizations.of(context)!.nearbylabours),
// //                   BottomNavigationBarItem(
// //                       icon: const Icon(Icons.person),
// //                       label: AppLocalizations.of(context)!.yourprojects),
// //                 ],
// //                 onTap: (index) {
// //                   setState(() {
// //                     _currentIndex = index;
// //                   });
// //                   final pages = ['CombinedPage', 'LabourPage', 'ProjectPage'];
// //                   if (index >= 0 && index < pages.length) {
// //                     ApiLogger.logScreenOpened(pages[index]);
// //                   }
// //                 },
// //               ),
// //             ),
// //           ),
// //         floatingActionButton: Container(
// //           decoration: BoxDecoration(
// //             gradient: Constants.AppColors.brandGradient,
// //             borderRadius: BorderRadius.circular(999),
// //             boxShadow: const [Constants.AppShadows.fab],
// //           ),
// //           child: FloatingActionButton.extended(
// //             onPressed: () {
// //               Navigator.push(
// //                 context,
// //                 MaterialPageRoute(
// //                   builder: (context) => AddProjectForm(),
// //                 ),
// //               );
// //             },
// //             backgroundColor: Colors.transparent,
// //             elevation: 0,
// //             highlightElevation: 0,
// //             label: Text(
// //               AppLocalizations.of(context)!.addProject,
// //               style: Constants.AppTypography.body.copyWith(
// //                 color: Colors.white,
// //                 fontWeight: FontWeight.w700,
// //               ),
// //             ),
// //           ),
// //         ),
// //         floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
// //       ),
// //     );
// //   }
// // }
// //
// // class Dashboard extends StatelessWidget {
// //   @override
// //   Widget build(BuildContext context) {
// //     return Center(
// //       child: Text(
// //         "Welcome to the Home Page",
// //         style: TextStyle(fontSize: 24, color: Constants.AppColors.brand),
// //       ),
// //     );
// //   }
// // }
// //
// // class SearchPage extends StatelessWidget {
// //   @override
// //   Widget build(BuildContext context) {
// //     return Center(
// //       child: Text(
// //         "Search for something here!",
// //         style: TextStyle(fontSize: 24, color: Constants.AppColors.brand),
// //       ),
// //     );
// //   }
// // }
// //
// // class CombinedPage extends StatefulWidget {
// //   @override
// //   _CombinedPageState createState() => _CombinedPageState();
// // }
// //
// // class _CombinedPageState extends State<CombinedPage>
// //     with WidgetsBindingObserver {
// //   static String _cachedCity = '';
// //   static String _cachedState = '';
// //   static String _cachedError = '';
// //
// //   final FlutterSecureStorage _secureStorage = FlutterSecureStorage();
// //   final TextEditingController _projectSearchController =
// //   TextEditingController();
// //   final TextEditingController _labourSearchController = TextEditingController();
// //   late Future<List<JobType>> _jobTypes;
// //
// //   List<dynamic> projects = [];
// //   List<dynamic> filteredProjects = [];
// //   List<dynamic> labours = [];
// //   bool isLoading = false;
// //   int _currentIndex = 0;
// //   String _selectedLanguage = 'en';
// //   int _coinCharge = 5;
// //
// //   Future<void> _loadCoinCharge() async {
// //     int charge = await WalletHelper.getCoinCharge();
// //     if (mounted) {
// //       setState(() {
// //         _coinCharge = charge;
// //       });
// //     }
// //   }
// //
// //   IconData _getCategoryIcon(String jobname) {
// //     final name = jobname.toLowerCase();
// //     if (name.contains('crop') || name.contains('farm') || name.contains('कृषि') || name.contains('फसल')) {
// //       return Icons.grass;
// //     } else if (name.contains('cow') || name.contains('animal') || name.contains('dairy') || name.contains('husbandry') || name.contains('पशु') || name.contains('गाय')) {
// //       return Icons.pets;
// //     } else if (name.contains('tractor') || name.contains('driver') || name.contains('ट्रैक्टर')) {
// //       return Icons.agriculture;
// //     } else if (name.contains('box') || name.contains('pack') || name.contains('warehouse') || name.contains('logistics') || name.contains('डिब्बा') || name.contains('पैकिंग')) {
// //       return Icons.inventory_2;
// //     }
// //     return Icons.category;
// //   }
// //
// //   Future<void> loadLanguage() async {
// //     String? language = await _secureStorage.read(key: 'selectedLanguage');
// //     _selectedLanguage = language ?? 'en';
// //   }
// //
// //   Map<String, Map<String, String>> _cachedTranslations = {};
// //   Map<String, Map<String, String>> translations =
// //       Constants.AppConstants.translations;
// //   final GoogleTranslator _translator = GoogleTranslator();
// //   late stt.SpeechToText _speech;
// //   late PageController _pageController;
// //   late Timer _timer;
// //
// //   String _currentCity = '';
// //   String _currentState = '';
// //   bool _isLoadingLocation = true;
// //   String _locationError = '';
// //
// //   @override
// //   void initState() {
// //     super.initState();
// //     WidgetsBinding.instance.addObserver(this);
// //     _speech = stt.SpeechToText();
// //     _pageController = PageController();
// //     _jobTypes = fetchJobTypes();
// //     fetchLabours();
// //     _fetchCurrentLocation();
// //     _loadCoinCharge();
// //   }
// //
// //   @override
// //   void dispose() {
// //     WidgetsBinding.instance.removeObserver(this);
// //     _pageController.dispose();
// //     _timer.cancel();
// //     super.dispose();
// //   }
// //
// //   @override
// //   void didChangeAppLifecycleState(AppLifecycleState state) {
// //     if (state == AppLifecycleState.resumed) {
// //       _fetchCurrentLocation(force: true);
// //     }
// //   }
// //
// //   Future<void> _fetchCurrentLocation({bool force = false}) async {
// //     if (!force && (_cachedCity.isNotEmpty || _cachedState.isNotEmpty)) {
// //       if (mounted) {
// //         setState(() {
// //           _currentCity = _cachedCity;
// //           _currentState = _cachedState;
// //           _isLoadingLocation = false;
// //           _locationError = _cachedError;
// //         });
// //         WidgetsBinding.instance.addPostFrameCallback((_) {
// //           if (mounted) {
// //             final locProv =
// //             Provider.of<LocationProvider>(context, listen: false);
// //             if (_cachedError.isNotEmpty) {
// //               locProv.setError(_cachedError);
// //             } else {
// //               locProv.setLocation(city: _currentCity, state: _currentState);
// //             }
// //           }
// //         });
// //       }
// //       return;
// //     }
// //
// //     WidgetsBinding.instance.addPostFrameCallback((_) {
// //       if (mounted) {
// //         Provider.of<LocationProvider>(context, listen: false).setLoading(true);
// //       }
// //     });
// //
// //     try {
// //       bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
// //       if (!serviceEnabled) {
// //         if (mounted) {
// //           setState(() {
// //             _isLoadingLocation = false;
// //             _locationError = 'Location services are disabled';
// //           });
// //           WidgetsBinding.instance.addPostFrameCallback((_) {
// //             if (mounted) {
// //               Provider.of<LocationProvider>(context, listen: false)
// //                   .setError('Location services are disabled');
// //             }
// //           });
// //         }
// //         return;
// //       }
// //
// //       LocationPermission permission = await Geolocator.checkPermission();
// //       if (permission == LocationPermission.denied) {
// //         permission = await Geolocator.requestPermission();
// //         if (permission == LocationPermission.denied) {
// //           if (mounted) {
// //             setState(() {
// //               _isLoadingLocation = false;
// //               _locationError = 'Location permission denied';
// //             });
// //             WidgetsBinding.instance.addPostFrameCallback((_) {
// //               if (mounted) {
// //                 Provider.of<LocationProvider>(context, listen: false)
// //                     .setError('Location permission denied');
// //               }
// //             });
// //           }
// //           return;
// //         }
// //       }
// //
// //       if (permission == LocationPermission.deniedForever) {
// //         if (mounted) {
// //           setState(() {
// //             _isLoadingLocation = false;
// //             _locationError = 'Location permission permanently denied';
// //           });
// //           WidgetsBinding.instance.addPostFrameCallback((_) {
// //             if (mounted) {
// //               Provider.of<LocationProvider>(context, listen: false)
// //                   .setError('Location permission permanently denied');
// //             }
// //           });
// //         }
// //         return;
// //       }
// //
// //       Position position = await Geolocator.getCurrentPosition(
// //         desiredAccuracy: LocationAccuracy.high,
// //       );
// //       List<Placemark> placemarks = await placemarkFromCoordinates(
// //         position.latitude,
// //         position.longitude,
// //       );
// //
// //       if (placemarks.isNotEmpty && mounted) {
// //         Placemark place = placemarks[0];
// //         _cachedCity = place.locality ?? place.subAdministrativeArea ?? '';
// //         _cachedState = place.administrativeArea ?? '';
// //         _cachedError = '';
// //         setState(() {
// //           _currentCity = _cachedCity;
// //           _currentState = _cachedState;
// //           _isLoadingLocation = false;
// //         });
// //         WidgetsBinding.instance.addPostFrameCallback((_) {
// //           if (mounted) {
// //             Provider.of<LocationProvider>(context, listen: false)
// //                 .setLocation(city: _currentCity, state: _currentState);
// //           }
// //         });
// //       }
// //     } catch (e) {
// //       print('Error fetching location: $e');
// //       _cachedError = 'Unable to fetch location';
// //       if (mounted) {
// //         setState(() {
// //           _isLoadingLocation = false;
// //           _locationError = _cachedError;
// //         });
// //         WidgetsBinding.instance.addPostFrameCallback((_) {
// //           if (mounted) {
// //             Provider.of<LocationProvider>(context, listen: false)
// //                 .setError(_cachedError);
// //           }
// //         });
// //       }
// //     }
// //   }
// //
// //   String translateText(String text) {
// //     if (text.isEmpty) return "";
// //     String targetLang = _selectedLanguage ?? 'en';
// //     if (translations.containsKey(text) &&
// //         translations[text]!.containsKey(targetLang)) {
// //       return translations[text]![targetLang]!;
// //     }
// //     if (_cachedTranslations.containsKey(text) &&
// //         _cachedTranslations[text]!.containsKey(targetLang)) {
// //       return _cachedTranslations[text]![targetLang]!;
// //     }
// //     _fetchTranslation(text, targetLang);
// //     return text;
// //   }
// //
// //   Future<void> _fetchTranslation(String text, String targetLang) async {
// //     try {
// //       if (Constants.AppConstants.translations.containsKey(text) &&
// //           Constants.AppConstants.translations[text]!.containsKey(targetLang)) {
// //         return;
// //       }
// //       final translation = await _translator.translate(text, to: targetLang);
// //       if (!translations.containsKey(text)) {
// //         translations[text] = {"en": text, "hi": text};
// //       }
// //       translations[text]![targetLang] = translation.text;
// //       _cachedTranslations = translations;
// //       if (!Constants.AppConstants.translations.containsKey(text)) {
// //         Constants.AppConstants.translations[text] = {};
// //       }
// //       Constants.AppConstants.translations[text]![targetLang] = translation.text;
// //       _cachedTranslations.putIfAbsent(text, () => {})[targetLang] =
// //           translation.text;
// //       setState(() {});
// //     } catch (e) {
// //       print("Translation error: $e");
// //     }
// //   }
// //
// //   void _startAutoScroll() {
// //     Timer.periodic(Duration(seconds: 3), (Timer timer) {
// //       if (_pageController.hasClients) {
// //         _currentIndex = (_currentIndex + 1) % 1;
// //         _pageController.animateToPage(
// //           _currentIndex,
// //           duration: Duration(seconds: 1),
// //           curve: Curves.easeInOut,
// //         );
// //       }
// //     });
// //   }
// //
// //   bool _isListening = false;
// //   String _searchText = '';
// //
// //   void _startListening() async {
// //     final language =
// //         Provider.of<LanguageProvider>(context, listen: false).selectedLanguage;
// //     String localeId = language == 'en' ? 'en_US' : 'hi_IN';
// //     bool available = await _speech.initialize();
// //     if (available) {
// //       setState(() => _isListening = true);
// //       _speech.listen(
// //         localeId: localeId,
// //         onResult: (result) {
// //           setState(() {
// //             _searchText = result.recognizedWords;
// //             _labourSearchController.text = _searchText;
// //             fetchLabours(searchQuery: _searchText);
// //           });
// //         },
// //       );
// //     }
// //   }
// //
// //   void _stopListening() {
// //     setState(() => _isListening = false);
// //     _speech.stop();
// //   }
// //
// //   Future<List<JobType>> fetchJobTypes() async {
// //     final response = await http
// //         .post(Uri.parse('${Constants.AppConstants.apiUrl}farmer/jobtype'));
// //     if (response.statusCode == 200) {
// //       final Map<String, dynamic> data = json.decode(response.body);
// //       List<dynamic> jobData = data['data'];
// //       return jobData.map((job) => JobType.fromJson(job)).toList();
// //     } else {
// //       throw Exception('Failed to load job types');
// //     }
// //   }
// //
// //   String _formatDate(String dateString) {
// //     try {
// //       DateTime dateTime = DateTime.parse(dateString);
// //       return DateFormat('dd-MM-yyyy').format(dateTime);
// //     } catch (e) {
// //       return dateString;
// //     }
// //   }
// //
// //   Future<void> fetchLabours({String? searchQuery}) async {
// //     setState(() {
// //       isLoading = true;
// //     });
// //     String? userId = await _secureStorage.read(key: 'id');
// //     if (!mounted) return;
// //     if (userId == null) {
// //       ScaffoldMessenger.of(context).showSnackBar(
// //         const SnackBar(content: Text('User ID not found in secure storage')),
// //       );
// //       setState(() => isLoading = false);
// //       return;
// //     }
// //     final apiUrl = (searchQuery != null && searchQuery.isNotEmpty)
// //         ? '${Constants.AppConstants.apiUrl}farmer/searchnearbylabours'
// //         : '${Constants.AppConstants.apiUrl}farmer/nearbylabours';
// //     final Map<String, dynamic> requestBody = (searchQuery != null &&
// //         searchQuery.isNotEmpty)
// //         ? {'search': searchQuery}
// //         : {'id': userId};
// //     try {
// //       final response = await http.post(
// //         Uri.parse(apiUrl),
// //         headers: {'Content-Type': 'application/json'},
// //         body: jsonEncode(requestBody),
// //       );
// //       if (!mounted) return;
// //       if (response.statusCode == 200) {
// //         final responseData = jsonDecode(response.body);
// //         if (responseData['success'] == true) {
// //           setState(() {
// //             labours = responseData['data'];
// //           });
// //         } else {
// //           ScaffoldMessenger.of(context).showSnackBar(
// //             SnackBar(
// //                 content: Text(responseData['message'] ?? 'No labours found')),
// //           );
// //         }
// //       } else {
// //         ScaffoldMessenger.of(context).showSnackBar(
// //           const SnackBar(content: Text('Failed to fetch labours')),
// //         );
// //       }
// //     } catch (e) {
// //       if (!mounted) return;
// //       ScaffoldMessenger.of(context).showSnackBar(
// //         SnackBar(content: Text('Error: $e')),
// //       );
// //     } finally {
// //       if (mounted) {
// //         setState(() => isLoading = false);
// //       }
// //     }
// //   }
// //
// //   void filterProjects(String query) {
// //     setState(() {
// //       filteredProjects = projects.where((project) {
// //         String title = project['title'] ?? '';
// //         String budget = project['budget']?.toString() ?? '';
// //         String city = project['city'] ?? '';
// //         String state = project['state'] ?? '';
// //         return title.toLowerCase().contains(query.toLowerCase()) ||
// //             budget.toLowerCase().contains(query.toLowerCase()) ||
// //             city.toLowerCase().contains(query.toLowerCase()) ||
// //             state.toLowerCase().contains(query.toLowerCase());
// //       }).toList();
// //     });
// //   }
// //
// //   final List<String> imageUrls = [
// //     'assets/slider1.png',
// //     'assets/slider2.png',
// //     'assets/slider4.jpg',
// //     'assets/slider3.png',
// //     'assets/slider5.png',
// //   ];
// //
// //   Future<void> fetchProjects() async {
// //     final String apiUrl = '${Constants.AppConstants.apiUrl}farmer/getprojects';
// //     String? userId = await _secureStorage.read(key: 'id');
// //     if (!mounted) return;
// //     if (userId == null) {
// //       ScaffoldMessenger.of(context).showSnackBar(
// //         const SnackBar(content: Text('User ID not found in secure storage')),
// //       );
// //       return;
// //     }
// //     final Map<String, dynamic> requestBody = {'id': userId};
// //     try {
// //       final response = await http.post(
// //         Uri.parse(apiUrl),
// //         headers: {'Content-Type': 'application/json'},
// //         body: jsonEncode(requestBody),
// //       );
// //       if (!mounted) return;
// //       if (response.statusCode == 200) {
// //         final responseData = jsonDecode(response.body);
// //         setState(() {
// //           projects = responseData['data'];
// //           filteredProjects = projects;
// //         });
// //       } else {
// //         ScaffoldMessenger.of(context).showSnackBar(
// //           SnackBar(content: Text('Failed to fetch projects: ${response.body}')),
// //         );
// //       }
// //     } catch (e) {}
// //   }
// //
// //   void _startAutoScrolling(int itemCount) {
// //     _timer = Timer.periodic(Duration(seconds: 3), (Timer timer) {
// //       if (_pageController.hasClients) {
// //         setState(() {
// //           _currentIndex = (_currentIndex + 1) % itemCount;
// //         });
// //         _pageController.animateToPage(
// //           _currentIndex,
// //           duration: Duration(seconds: 1),
// //           curve: Curves.easeInOut,
// //         );
// //       }
// //     });
// //   }
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     final language =
// //         Provider.of<LanguageProvider>(context, listen: false).selectedLanguage;
// //
// //     String translate(String enText, String hiText) {
// //       return language == 'en' ? enText : hiText;
// //     }
// //
// //     return WillPopScope(
// //       onWillPop: () async {
// //         SystemNavigator.pop();
// //         return false;
// //       },
// //       child: RefreshIndicator(
// //         onRefresh: () async {
// //           setState(() {
// //             _jobTypes = fetchJobTypes();
// //           });
// //           await fetchLabours();
// //           await _fetchCurrentLocation();
// //           await _loadCoinCharge();
// //         },
// //         child: Scaffold(
// //           body: Container(
// //             width: double.infinity,
// //             height: double.infinity,
// //             decoration: BoxDecoration(color: Colors.white),
// //             child: SingleChildScrollView(
// //               child: Column(
// //                 crossAxisAlignment: CrossAxisAlignment.start,
// //                 children: [
// //                   Container(
// //                     width: double.infinity,
// //                     height: 200,
// //                     margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
// //                     decoration: BoxDecoration(
// //                       borderRadius: BorderRadius.circular(20),
// //                       boxShadow: const [Constants.AppShadows.card],
// //                     ),
// //                     child: ClipRRect(
// //                       borderRadius: BorderRadius.circular(20),
// //                       child: CarouselSlider.builder(
// //                         itemCount: imageUrls.length,
// //                         itemBuilder:
// //                             (BuildContext context, int index, int realIndex) {
// //                           return SizedBox(
// //                             width: double.infinity,
// //                             child: Image.asset(
// //                               imageUrls[index],
// //                               fit: BoxFit.cover,
// //                             ),
// //                           );
// //                         },
// //                         options: CarouselOptions(
// //                           height: 200,
// //                           enlargeCenterPage: false,
// //                           autoPlay: true,
// //                           aspectRatio: 16 / 9,
// //                           viewportFraction: 1.0,
// //                         ),
// //                       ),
// //                     ),
// //                   ),
// //                   Padding(
// //                     padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
// //                     child: _buildSectionTitle(
// //                       translate('Select category for job/Work',
// //                           'नौकरी/कार्य के लिए श्रेणी चुनें'),
// //                     ),
// //                   ),
// //                   Padding(
// //                     padding: const EdgeInsets.symmetric(vertical: 8.0),
// //                     child: FutureBuilder<List<JobType>>(
// //                       future: _jobTypes,
// //                       builder: (context, snapshot) {
// //                         if (snapshot.connectionState ==
// //                             ConnectionState.waiting) {
// //                           return const Center(
// //                               child: CircularProgressIndicator());
// //                         } else if (snapshot.hasError) {
// //                           return const Center(
// //                               child: Text('Error fetching job types'));
// //                         } else if (!snapshot.hasData ||
// //                             snapshot.data!.isEmpty) {
// //                           return const Center(
// //                               child: Text('No data available'));
// //                         } else {
// //                           List<JobType> jobTypes = snapshot.data!;
// //                           _startAutoScrolling(jobTypes.length);
// //                           return Container(
// //                             height: 128,
// //                             child: ListView.builder(
// //                               scrollDirection: Axis.horizontal,
// //                               padding:
// //                               const EdgeInsets.symmetric(horizontal: 16),
// //                               itemCount: jobTypes.length,
// //                               itemBuilder: (context, index) {
// //                                 JobType job = jobTypes[index];
// //                                 return InkWell(
// //                                   onTap: () {
// //                                     Navigator.push(
// //                                       context,
// //                                       MaterialPageRoute(
// //                                         builder: (context) => AddProjectForm(
// //                                           projectType: job.jobname,
// //                                         ),
// //                                       ),
// //                                     );
// //                                   },
// //                                   child: SizedBox(
// //                                     width: 90,
// //                                     child: Column(
// //                                       children: [
// //                                         Container(
// //                                           width: 70,
// //                                           height: 70,
// //                                           margin: const EdgeInsets.symmetric(
// //                                               horizontal: 4, vertical: 2),
// //                                           decoration: const BoxDecoration(
// //                                             color: Color(0xFFE8F2E6),
// //                                             shape: BoxShape.circle,
// //                                           ),
// //                                           child: Center(
// //                                             child: CachedNetworkImage(
// //                                               imageUrl:
// //                                               '${Constants.AppConstants.folderUrl}storage/upload/jobtypes/${job.image}',
// //                                               width: 42,
// //                                               height: 42,
// //                                               placeholder: (context, url) =>
// //                                               const Center(
// //                                                 child: SizedBox(
// //                                                   width: 16,
// //                                                   height: 16,
// //                                                   child:
// //                                                   CircularProgressIndicator(
// //                                                       strokeWidth: 2),
// //                                                 ),
// //                                               ),
// //                                               errorWidget:
// //                                                   (context, url, error) =>
// //                                               Icon(
// //                                                 _getCategoryIcon(job.jobname),
// //                                                 color: const Color(0xFF0E6805),
// //                                                 size: 32,
// //                                               ),
// //                                             ),
// //                                           ),
// //                                         ),
// //                                         Padding(
// //                                           padding: const EdgeInsets.only(
// //                                               left: 4.0,
// //                                               right: 4.0,
// //                                               top: 4.0),
// //                                           child: Text(
// //                                             translateText(job.jobname),
// //                                             style: Constants.AppTypography
// //                                                 .label
// //                                                 .copyWith(
// //                                               color: Constants.AppColors.button,
// //                                               fontWeight: FontWeight.bold,
// //                                             ),
// //                                             textAlign: TextAlign.center,
// //                                             maxLines: 2,
// //                                             overflow: TextOverflow.ellipsis,
// //                                           ),
// //                                         ),
// //                                       ],
// //                                     ),
// //                                   ),
// //                                 );
// //                               },
// //                             ),
// //                           );
// //                         }
// //                       },
// //                     ),
// //                   ),
// //                   Padding(
// //                     padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
// //                     child: Container(
// //                       decoration: BoxDecoration(
// //                         color: Constants.AppColors.card,
// //                         borderRadius: BorderRadius.circular(16),
// //                         boxShadow: const [Constants.AppShadows.soft],
// //                       ),
// //                       child: TextField(
// //                         controller: _labourSearchController,
// //                         onChanged: (value) {
// //                           fetchLabours(searchQuery: value);
// //                         },
// //                         style: Constants.AppTypography.body,
// //                         decoration: InputDecoration(
// //                           prefixIcon: const Icon(
// //                             Icons.search,
// //                             color: Constants.AppColors.brand,
// //                             size: 20,
// //                           ),
// //                           suffixIcon: MicIconButton(
// //                               controller: _labourSearchController),
// //                           hintText: AppLocalizations.of(context)!.searchlabour,
// //                           hintStyle: Constants.AppTypography.body.copyWith(
// //                             color: Constants.AppColors.inkSoft,
// //                           ),
// //                           fillColor: Colors.transparent,
// //                           filled: true,
// //                           contentPadding: const EdgeInsets.symmetric(
// //                               horizontal: 16, vertical: 14),
// //                           border: OutlineInputBorder(
// //                             borderRadius: BorderRadius.circular(16),
// //                             borderSide: const BorderSide(
// //                                 color: Constants.AppColors.border),
// //                           ),
// //                           enabledBorder: OutlineInputBorder(
// //                             borderRadius: BorderRadius.circular(16),
// //                             borderSide: const BorderSide(
// //                                 color: Constants.AppColors.border),
// //                           ),
// //                           focusedBorder: OutlineInputBorder(
// //                             borderRadius: BorderRadius.circular(16),
// //                             borderSide: const BorderSide(
// //                                 color: Constants.AppColors.brand, width: 1.5),
// //                           ),
// //                         ),
// //                       ),
// //                     ),
// //                   ),
// //                   const Divider(),
// //                   labours.isEmpty
// //                       ? Center(
// //                     child: Text(
// //                       translate('Looking for nearby workers',
// //                           'आसपास के मजदूरों की तलाश की जा रही है'),
// //                       style: TextStyle(
// //                         fontSize: 18,
// //                         fontWeight: FontWeight.w500,
// //                         color: Colors.brown,
// //                       ),
// //                     ),
// //                   )
// //                       : Padding(
// //                     padding: const EdgeInsets.all(8.0),
// //                     child: ListView.builder(
// //                       shrinkWrap: true,
// //                       physics: const NeverScrollableScrollPhysics(),
// //                       itemCount: labours.length,
// //                       itemBuilder: (context, index) {
// //                         final labour = labours[index];
// //
// //                         String labourType = labour['type'] == '0'
// //                             ? translateText('Individual')
// //                             : translateText('Agency');
// //
// //                         String subtitle = labour['skills']?.toString() ??
// //                             '';
// //                         if (subtitle.isEmpty) {
// //                           subtitle = labour['aboutme']?.toString() ?? '';
// //                         }
// //
// //                         List<String> skillTags = [];
// //                         if (labour['skills'] != null &&
// //                             labour['skills'].toString().isNotEmpty) {
// //                           skillTags = labour['skills']
// //                               .toString()
// //                               .split(',')
// //                               .map((s) => s.trim())
// //                               .where((s) => s.isNotEmpty)
// //                               .toList();
// //                         }
// //                         if (skillTags.isEmpty &&
// //                             labour['education'] != null &&
// //                             labour['education'].toString().isNotEmpty) {
// //                           skillTags.add(labour['education'].toString());
// //                         }
// //                         if (skillTags.length > 2) {
// //                           skillTags = skillTags.sublist(0, 2);
// //                         }
// //
// //                         return GestureDetector(
// //                           onTap: () {
// //                             Navigator.push(
// //                               context,
// //                               MaterialPageRoute(
// //                                 builder: (context) => LabourDetailsPage(
// //                                   labour: labour,
// //                                 ),
// //                               ),
// //                             );
// //                           },
// //                           child: Container(
// //                             margin: const EdgeInsets.symmetric(
// //                                 horizontal: 16, vertical: 6),
// //                             decoration: BoxDecoration(
// //                               color: Constants.AppColors.card,
// //                               borderRadius: BorderRadius.circular(16),
// //                               border: Border.all(
// //                                   color: Constants.AppColors.border,
// //                                   width: 1.0),
// //                               boxShadow: const [
// //                                 Constants.AppShadows.soft
// //                               ],
// //                             ),
// //                             child: Padding(
// //                               padding: const EdgeInsets.all(10.0),
// //                               child: Row(
// //                                 crossAxisAlignment:
// //                                 CrossAxisAlignment.start,
// //                                 children: [
// //                                   Stack(
// //                                     children: [
// //                                       Container(
// //                                         width: 54,
// //                                         height: 54,
// //                                         decoration: BoxDecoration(
// //                                           color: Constants
// //                                               .AppColors.brandTint,
// //                                           borderRadius:
// //                                           BorderRadius.circular(27),
// //                                           border: Border.all(
// //                                               color: Constants
// //                                                   .AppColors.brandSoft,
// //                                               width: 1.5),
// //                                         ),
// //                                         child: ClipRRect(
// //                                           borderRadius:
// //                                           BorderRadius.circular(27),
// //                                           child: (labour[
// //                                           'profile_image'] !=
// //                                               null &&
// //                                               labour['profile_image']
// //                                                   .toString()
// //                                                   .isNotEmpty)
// //                                               ? Image.network(
// //                                             labour['profile_image']
// //                                                 .toString(),
// //                                             fit: BoxFit.cover,
// //                                             errorBuilder: (context,
// //                                                 error,
// //                                                 stackTrace) {
// //                                               return const Icon(
// //                                                   Icons.person,
// //                                                   color: Constants
// //                                                       .AppColors
// //                                                       .brand,
// //                                                   size: 28);
// //                                             },
// //                                           )
// //                                               : const Icon(Icons.person,
// //                                               color: Constants
// //                                                   .AppColors.brand,
// //                                               size: 28),
// //                                         ),
// //                                       ),
// //                                       Positioned(
// //                                         bottom: 0,
// //                                         right: 0,
// //                                         child: Container(
// //                                           padding:
// //                                           const EdgeInsets.all(1),
// //                                           decoration: const BoxDecoration(
// //                                             color: Colors.white,
// //                                             shape: BoxShape.circle,
// //                                           ),
// //                                           child: Container(
// //                                             padding:
// //                                             const EdgeInsets.all(2),
// //                                             decoration: const BoxDecoration(
// //                                               color: Colors.green,
// //                                               shape: BoxShape.circle,
// //                                             ),
// //                                             child: const Icon(
// //                                               Icons.check,
// //                                               color: Colors.white,
// //                                               size: 8,
// //                                             ),
// //                                           ),
// //                                         ),
// //                                       ),
// //                                     ],
// //                                   ),
// //                                   const SizedBox(width: 12),
// //                                   Expanded(
// //                                     child: Column(
// //                                       crossAxisAlignment:
// //                                       CrossAxisAlignment.start,
// //                                       children: [
// //                                         Row(
// //                                           crossAxisAlignment:
// //                                           CrossAxisAlignment.start,
// //                                           children: [
// //                                             Expanded(
// //                                               child: Column(
// //                                                 crossAxisAlignment:
// //                                                 CrossAxisAlignment
// //                                                     .start,
// //                                                 children: [
// //                                                   Text(
// //                                                     translateText(labour[
// //                                                     'name'] ??
// //                                                         'Unknown'),
// //                                                     style: Constants
// //                                                         .AppTypography
// //                                                         .h3
// //                                                         .copyWith(
// //                                                       color: Constants
// //                                                           .AppColors.ink,
// //                                                       fontWeight:
// //                                                       FontWeight.bold,
// //                                                       fontSize: 15,
// //                                                     ),
// //                                                     overflow: TextOverflow
// //                                                         .ellipsis,
// //                                                   ),
// //                                                   const SizedBox(
// //                                                       height: 2),
// //                                                   Container(
// //                                                     padding: const EdgeInsets
// //                                                         .symmetric(
// //                                                         horizontal: 6,
// //                                                         vertical: 2),
// //                                                     decoration:
// //                                                     BoxDecoration(
// //                                                       color: labour[
// //                                                       'type'] ==
// //                                                           '0'
// //                                                           ? const Color(
// //                                                           0xFFE8F5E9)
// //                                                           : const Color(
// //                                                           0xFFE3F2FD),
// //                                                       borderRadius:
// //                                                       BorderRadius
// //                                                           .circular(4),
// //                                                     ),
// //                                                     child: Text(
// //                                                       labourType,
// //                                                       style: Constants
// //                                                           .AppTypography
// //                                                           .micro
// //                                                           .copyWith(
// //                                                         color: labour[
// //                                                         'type'] ==
// //                                                             '0'
// //                                                             ? const Color(
// //                                                             0xFF2E7D32)
// //                                                             : const Color(
// //                                                             0xFF1565C0),
// //                                                         fontSize: 10,
// //                                                         fontWeight:
// //                                                         FontWeight
// //                                                             .bold,
// //                                                       ),
// //                                                     ),
// //                                                   ),
// //                                                 ],
// //                                               ),
// //                                             ),
// //                                             if (skillTags.isNotEmpty)
// //                                               Flexible(
// //                                                 child: Wrap(
// //                                                   alignment: WrapAlignment
// //                                                       .end,
// //                                                   spacing: 4,
// //                                                   runSpacing: 2,
// //                                                   children: skillTags
// //                                                       .map((tag) {
// //                                                     return Container(
// //                                                       padding: const EdgeInsets
// //                                                           .symmetric(
// //                                                           horizontal: 5,
// //                                                           vertical: 2),
// //                                                       decoration:
// //                                                       BoxDecoration(
// //                                                         color: Constants
// //                                                             .AppColors
// //                                                             .surface2,
// //                                                         borderRadius:
// //                                                         BorderRadius
// //                                                             .circular(
// //                                                             6),
// //                                                         border: Border
// //                                                             .all(
// //                                                             color: Constants
// //                                                                 .AppColors
// //                                                                 .border,
// //                                                             width: 0.5),
// //                                                       ),
// //                                                       child: Text(
// //                                                         translateText(tag),
// //                                                         style: Constants
// //                                                             .AppTypography
// //                                                             .micro
// //                                                             .copyWith(
// //                                                           color: Constants
// //                                                               .AppColors
// //                                                               .ink,
// //                                                           fontSize: 9,
// //                                                           fontWeight:
// //                                                           FontWeight
// //                                                               .w600,
// //                                                         ),
// //                                                       ),
// //                                                     );
// //                                                   }).toList(),
// //                                                 ),
// //                                               ),
// //                                           ],
// //                                         ),
// //                                         const SizedBox(height: 4),
// //                                         Row(
// //                                           children: [
// //                                             const Icon(
// //                                               Icons
// //                                                   .location_on_outlined,
// //                                               size: 12,
// //                                               color: Constants
// //                                                   .AppColors.inkSoft,
// //                                             ),
// //                                             const SizedBox(width: 4),
// //                                             Expanded(
// //                                               child: Text(
// //                                                 '${translateText(labour['city'] ?? 'Unknown City')}, ${translateText(labour['state'] ?? '')}',
// //                                                 style: Constants
// //                                                     .AppTypography.body
// //                                                     .copyWith(
// //                                                   color: Constants
// //                                                       .AppColors.inkSoft,
// //                                                   fontSize: 12,
// //                                                 ),
// //                                                 overflow: TextOverflow
// //                                                     .ellipsis,
// //                                               ),
// //                                             ),
// //                                           ],
// //                                         ),
// //                                         if (subtitle.isNotEmpty) ...[
// //                                           const SizedBox(height: 4),
// //                                           Row(
// //                                             children: [
// //                                               const Icon(
// //                                                 Icons.work_outline,
// //                                                 size: 12,
// //                                                 color: Constants
// //                                                     .AppColors.brand,
// //                                               ),
// //                                               const SizedBox(width: 4),
// //                                               Expanded(
// //                                                 child: Text(
// //                                                   subtitle.length > 40
// //                                                       ? '${subtitle.substring(0, 40)}...'
// //                                                       : subtitle,
// //                                                   style: Constants
// //                                                       .AppTypography.body
// //                                                       .copyWith(
// //                                                     color: Constants
// //                                                         .AppColors
// //                                                         .inkSoft,
// //                                                     fontSize: 11,
// //                                                   ),
// //                                                   overflow: TextOverflow
// //                                                       .ellipsis,
// //                                                 ),
// //                                               ),
// //                                             ],
// //                                           ),
// //                                         ],
// //                                       ],
// //                                     ),
// //                                   ),
// //                                 ],
// //                               ),
// //                             ),
// //                           ),
// //                         );
// //                       },
// //                     ),
// //                   ),
// //                 ],
// //               ),
// //             ),
// //           ),
// //         ),
// //       ),
// //     );
// //   }
// //
// //   Widget _buildSectionTitle(String title) {
// //     return Padding(
// //       padding: const EdgeInsets.symmetric(vertical: 8.0),
// //       child: Text(
// //         title,
// //         style: Constants.AppTypography.h2,
// //       ),
// //     );
// //   }
// //
// //   Widget _buildProjectList() {
// //     return ListView.builder(
// //       shrinkWrap: true,
// //       physics: const NeverScrollableScrollPhysics(),
// //       itemCount: filteredProjects.length,
// //       itemBuilder: (context, index) {
// //         var project = filteredProjects[index];
// //         return Card(
// //           elevation: 4.0,
// //           margin: const EdgeInsets.symmetric(vertical: 8.0),
// //           child: Padding(
// //             padding: const EdgeInsets.all(16.0),
// //             child: Column(
// //               crossAxisAlignment: CrossAxisAlignment.start,
// //               children: [
// //                 Text(project['title'] ?? 'Untitled Project'),
// //                 const SizedBox(height: 8.0),
// //                 Row(
// //                   crossAxisAlignment: CrossAxisAlignment.start,
// //                   children: [
// //                     Expanded(
// //                       child: Text(project['description'] ?? 'No description'),
// //                     ),
// //                     SpeakerIconButton(
// //                         text: project['description'] ?? 'No description'),
// //                   ],
// //                 ),
// //               ],
// //             ),
// //           ),
// //         );
// //       },
// //     );
// //   }
// // }
// //
// // class LabourAnimated extends StatefulWidget {
// //   final dynamic labour;
// //   final int index;
// //   const LabourAnimated({required this.labour, required this.index});
// //
// //   @override
// //   State<LabourAnimated> createState() => _LabourAnimatedState();
// // }
// //
// // class _LabourAnimatedState extends State<LabourAnimated> {
// //   Map<String, Map<String, String>> _cachedTranslations = {};
// //   Map<String, Map<String, String>> translations =
// //       Constants.AppConstants.translations;
// //   final GoogleTranslator _translator = GoogleTranslator();
// //   final _secureStorage = const FlutterSecureStorage();
// //
// //   @override
// //   void initState() {
// //     super.initState();
// //     loadLanguage();
// //   }
// //
// //   String _selectedLanguage = 'en';
// //
// //   Future<void> loadLanguage() async {
// //     String? language = await _secureStorage.read(key: 'selectedLanguage');
// //     _selectedLanguage = language ?? 'en';
// //   }
// //
// //   String translateText(String text) {
// //     if (text.isEmpty) return "";
// //     String targetLang = _selectedLanguage ?? 'en';
// //     if (translations.containsKey(text) &&
// //         translations[text]!.containsKey(targetLang)) {
// //       return translations[text]![targetLang]!;
// //     }
// //     if (_cachedTranslations.containsKey(text) &&
// //         _cachedTranslations[text]!.containsKey(targetLang)) {
// //       return _cachedTranslations[text]![targetLang]!;
// //     }
// //     _fetchTranslation(text, targetLang);
// //     return text;
// //   }
// //
// //   Future<void> _fetchTranslation(String text, String targetLang) async {
// //     try {
// //       if (Constants.AppConstants.translations.containsKey(text) &&
// //           Constants.AppConstants.translations[text]!.containsKey(targetLang)) {
// //         return;
// //       }
// //       final translation = await _translator.translate(text, to: targetLang);
// //       if (!translations.containsKey(text)) {
// //         translations[text] = {"en": text, "hi": text};
// //       }
// //       translations[text]![targetLang] = translation.text;
// //       _cachedTranslations = translations;
// //       if (!Constants.AppConstants.translations.containsKey(text)) {
// //         Constants.AppConstants.translations[text] = {};
// //       }
// //       Constants.AppConstants.translations[text]![targetLang] = translation.text;
// //       _cachedTranslations.putIfAbsent(text, () => {})[targetLang] =
// //           translation.text;
// //     } catch (e) {
// //       print("Translation error: $e");
// //     }
// //   }
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     return AnimatedContainer(
// //       duration: const Duration(milliseconds: 500),
// //       curve: Curves.easeInOut,
// //       margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
// //       decoration: BoxDecoration(
// //         color: const Color(0xFFEBF5F0),
// //         borderRadius: BorderRadius.circular(15),
// //         boxShadow: [
// //           BoxShadow(
// //             color: Colors.green.withOpacity(0.2),
// //             spreadRadius: 2,
// //             blurRadius: 5,
// //           ),
// //         ],
// //       ),
// //       child: ListTile(
// //         leading: CircleAvatar(
// //           backgroundColor: Colors.green,
// //           child: Text(
// //             translateText(widget.labour['name'][0].toUpperCase()),
// //             style: const TextStyle(color: Colors.white),
// //           ),
// //         ),
// //         title: Text(
// //           translateText(widget.labour['name'] ?? 'Unknown'),
// //           style: const TextStyle(fontWeight: FontWeight.bold),
// //         ),
// //         subtitle: Text(
// //           '${translateText(widget.labour['city'] ?? 'Unknown City')}, ${translateText(widget.labour['state'] ?? 'Unknown State')}',
// //         ),
// //         trailing: Column(
// //           children: [
// //             Text(
// //               widget.labour['type'] == '0'
// //                   ? translateText('Individual')
// //                   : translateText('Agency'),
// //             ),
// //             if (widget.labour['type'] == '1')
// //               Text(
// //                 '${translateText(widget.labour['agency_name'])}',
// //               ),
// //           ],
// //         ),
// //       ),
// //     );
// //   }
// // }
// //
// // class ProjectPage extends StatefulWidget {
// //   @override
// //   _ProjectPageState createState() => _ProjectPageState();
// // }
// //
// // class _ProjectPageState extends State<ProjectPage> {
// //   final _secureStorage = const FlutterSecureStorage();
// //   List<dynamic> projects = [];
// //   List<dynamic> filteredProjects = [];
// //   bool isLoading = true;
// //   final TextEditingController _searchController = TextEditingController();
// //   String _selectedLanguage = 'en';
// //
// //   Map<String, Map<String, String>> _cachedTranslations = {};
// //   Map<String, Map<String, String>> translations =
// //       Constants.AppConstants.translations;
// //   final GoogleTranslator _translator = GoogleTranslator();
// //   late stt.SpeechToText _speech;
// //
// //   @override
// //   void initState() {
// //     super.initState();
// //     _speech = stt.SpeechToText();
// //     fetchProjects();
// //     loadLanguage();
// //   }
// //
// //   Future<void> loadLanguage() async {
// //     String? language = await _secureStorage.read(key: 'selectedLanguage');
// //     _selectedLanguage = language ?? 'en';
// //   }
// //
// //   String translateText(String text) {
// //     if (text.isEmpty) return "";
// //     String targetLang = _selectedLanguage ?? 'en';
// //     if (translations.containsKey(text) &&
// //         translations[text]!.containsKey(targetLang)) {
// //       return translations[text]![targetLang]!;
// //     }
// //     if (_cachedTranslations.containsKey(text) &&
// //         _cachedTranslations[text]!.containsKey(targetLang)) {
// //       return _cachedTranslations[text]![targetLang]!;
// //     }
// //     _fetchTranslation(text, targetLang);
// //     return text;
// //   }
// //
// //   Future<void> _fetchTranslation(String text, String targetLang) async {
// //     try {
// //       if (Constants.AppConstants.translations.containsKey(text) &&
// //           Constants.AppConstants.translations[text]!.containsKey(targetLang)) {
// //         return;
// //       }
// //       final translation = await _translator.translate(text, to: targetLang);
// //       if (!translations.containsKey(text)) {
// //         translations[text] = {"en": text, "hi": text};
// //       }
// //       translations[text]![targetLang] = translation.text;
// //       _cachedTranslations = translations;
// //       if (!Constants.AppConstants.translations.containsKey(text)) {
// //         Constants.AppConstants.translations[text] = {};
// //       }
// //       Constants.AppConstants.translations[text]![targetLang] = translation.text;
// //       _cachedTranslations.putIfAbsent(text, () => {})[targetLang] =
// //           translation.text;
// //       setState(() {});
// //     } catch (e) {
// //       print("Translation error: $e");
// //     }
// //   }
// //
// //   Future<void> fetchProjects() async {
// //     final String apiUrl = '${Constants.AppConstants.apiUrl}farmer/getprojects';
// //     String? userId = await _secureStorage.read(key: 'id');
// //     if (userId == null) {
// //       ScaffoldMessenger.of(context).showSnackBar(
// //         const SnackBar(content: Text('User ID not found in secure storage')),
// //       );
// //       return;
// //     }
// //     final Map<String, dynamic> requestBody = {'id': userId};
// //     try {
// //       final response = await http.post(
// //         Uri.parse(apiUrl),
// //         headers: {'Content-Type': 'application/json'},
// //         body: jsonEncode(requestBody),
// //       );
// //       if (response.statusCode == 200) {
// //         setState(() {
// //           projects = json.decode(response.body)['data'];
// //           filteredProjects = projects;
// //           isLoading = false;
// //         });
// //       } else {
// //         setState(() => isLoading = false);
// //         ScaffoldMessenger.of(context).showSnackBar(
// //           const SnackBar(content: Text('No Projects Created Yet')),
// //         );
// //       }
// //     } catch (e) {
// //       setState(() => isLoading = false);
// //     }
// //   }
// //
// //   void filterProjects(String query) {
// //     setState(() {
// //       filteredProjects = projects.where((project) {
// //         String title = project['title'] ?? '';
// //         String budget = project['budget']?.toString() ?? '';
// //         String city = project['city'] ?? '';
// //         String state = project['state'] ?? '';
// //         return title.toLowerCase().contains(query.toLowerCase()) ||
// //             budget.toLowerCase().contains(query.toLowerCase()) ||
// //             city.toLowerCase().contains(query.toLowerCase()) ||
// //             state.toLowerCase().contains(query.toLowerCase());
// //       }).toList();
// //     });
// //   }
// //
// //   bool _isListening = false;
// //   String _searchText = '';
// //
// //   void _startListening() async {
// //     final language =
// //         Provider.of<LanguageProvider>(context, listen: false).selectedLanguage;
// //     String localeId = language == 'en' ? 'en_US' : 'hi_IN';
// //     bool available = await _speech.initialize();
// //     if (available) {
// //       setState(() => _isListening = true);
// //       _speech.listen(
// //         localeId: localeId,
// //         onResult: (result) {
// //           setState(() {
// //             _searchText = result.recognizedWords;
// //             _searchController.text = _searchText;
// //             filterProjects(_searchText);
// //           });
// //         },
// //       );
// //     }
// //   }
// //
// //   void _stopListening() {
// //     setState(() => _isListening = false);
// //     _speech.stop();
// //   }
// //
// //   String _formatDate(String dateString) {
// //     if (dateString.isEmpty) return 'N/A';
// //     try {
// //       DateTime dateTime = DateTime.parse(dateString);
// //       return DateFormat('dd MMM yyyy').format(dateTime);
// //     } catch (e) {
// //       return dateString;
// //     }
// //   }
// //
// //   Widget _buildPremiumChip({
// //     required IconData icon,
// //     required String label,
// //     required Color bgColor,
// //     required Color iconColor,
// //     required Color labelColor,
// //   }) {
// //     return Container(
// //       padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
// //       decoration: BoxDecoration(
// //         color: bgColor,
// //         borderRadius: BorderRadius.circular(10),
// //         border: Border.all(color: bgColor.withOpacity(0.5), width: 0.5),
// //       ),
// //       child: Row(
// //         mainAxisSize: MainAxisSize.min,
// //         children: [
// //           Icon(icon, size: 13, color: iconColor),
// //           const SizedBox(width: 4),
// //           Text(
// //             label,
// //             style: TextStyle(
// //               fontSize: 11,
// //               fontWeight: FontWeight.w700,
// //               color: labelColor,
// //               letterSpacing: 0.3,
// //             ),
// //           ),
// //         ],
// //       ),
// //     );
// //   }
// //
// //   Widget _buildProjectStatusBadge(Map<String, dynamic> project) {
// //     final status = project['status']?.toString() ?? '1';
// //     final labourId = project['labourId']?.toString() ?? '';
// //     final bool isAssigned = labourId.trim().isNotEmpty;
// //
// //     String label;
// //     Color bgColor;
// //     Color textColor;
// //     IconData icon;
// //
// //     switch (status) {
// //       case '1':
// //         if (isAssigned) {
// //           label = translateText('Assigned');
// //           bgColor = const Color(0xFFEFF6FF);
// //           textColor = const Color(0xFF1E40AF);
// //           icon = Icons.assignment_ind_outlined;
// //         } else {
// //           label = translateText('Open');
// //           bgColor = const Color(0xFFEAF4E8);
// //           textColor = const Color(0xFF0E6805);
// //           icon = Icons.check_circle_outline;
// //         }
// //         break;
// //       case '2':
// //         label = translateText('Work Started');
// //         bgColor = const Color(0xFFFFF7ED);
// //         textColor = const Color(0xFFC2410C);
// //         icon = Icons.hourglass_top_outlined;
// //         break;
// //       case '3':
// //         label = translateText('Completed');
// //         bgColor = const Color(0xFFF0FDF4);
// //         textColor = const Color(0xFF15803D);
// //         icon = Icons.check_circle_outline;
// //         break;
// //       case '4':
// //         label = translateText('Cancelled');
// //         bgColor = const Color(0xFFFEF2F2);
// //         textColor = const Color(0xFF991B1B);
// //         icon = Icons.cancel_outlined;
// //         break;
// //       default:
// //         label = translateText('Unknown');
// //         bgColor = const Color(0xFFF1F5F9);
// //         textColor = const Color(0xFF64748B);
// //         icon = Icons.help_outline;
// //     }
// //
// //     return Container(
// //       padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
// //       decoration: BoxDecoration(
// //         color: bgColor,
// //         borderRadius: BorderRadius.circular(20),
// //         border: Border.all(color: textColor.withOpacity(0.2), width: 0.8),
// //       ),
// //       child: Row(
// //         mainAxisSize: MainAxisSize.min,
// //         children: [
// //           Icon(icon, size: 11, color: textColor),
// //           const SizedBox(width: 4),
// //           Text(
// //             label,
// //             style: TextStyle(
// //               fontSize: 10,
// //               fontWeight: FontWeight.bold,
// //               color: textColor,
// //             ),
// //           ),
// //         ],
// //       ),
// //     );
// //   }
// //
// //   String _getDurationLabel(dynamic days) {
// //     if (days == null) return translateText('N/A');
// //     String daysStr = days.toString();
// //     int? daysInt = int.tryParse(daysStr);
// //     if (daysInt != null && daysInt > 0) {
// //       return '$daysInt ${translateText('days')}';
// //     }
// //     return translateText(daysStr);
// //   }
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     final language =
// //         Provider.of<LanguageProvider>(context, listen: false).selectedLanguage;
// //     String translate(String enText, String hiText) {
// //       return language == 'en' ? enText : hiText;
// //     }
// //
// //     return WillPopScope(
// //       onWillPop: () async {
// //         SystemNavigator.pop();
// //         return false;
// //       },
// //       child: Scaffold(
// //         body: Container(
// //           color: Constants.AppColors.surface,
// //           child: SafeArea(
// //             child: Column(
// //               children: [
// //                 Padding(
// //                   padding: const EdgeInsets.all(16.0),
// //                   child: TextField(
// //                     controller: _searchController,
// //                     onChanged: filterProjects,
// //                     decoration: InputDecoration(
// //                       prefixIcon: const Icon(Icons.search,
// //                           color: Constants.AppColors.brand),
// //                       hintText: AppLocalizations.of(context)!.searchlabour,
// //                       fillColor: Colors.white,
// //                       filled: true,
// //                       border: OutlineInputBorder(
// //                         borderRadius: BorderRadius.circular(15.0),
// //                         borderSide:
// //                         const BorderSide(color: Constants.AppColors.border),
// //                       ),
// //                       focusedBorder: OutlineInputBorder(
// //                         borderRadius: BorderRadius.circular(15.0),
// //                         borderSide: const BorderSide(
// //                             color: Constants.AppColors.brand, width: 2),
// //                       ),
// //                       suffixIcon: MicIconButton(controller: _searchController),
// //                     ),
// //                   ),
// //                 ),
// //                 Expanded(
// //                   child: isLoading
// //                       ? const Center(child: CircularProgressIndicator())
// //                       : filteredProjects.isEmpty
// //                       ? Center(
// //                     child: Text(
// //                       AppLocalizations.of(context)!.noProjectsFound,
// //                       style: const TextStyle(
// //                         fontSize: 18,
// //                         fontWeight: FontWeight.w500,
// //                         color: Colors.brown,
// //                       ),
// //                     ),
// //                   )
// //                       : ListView.builder(
// //                     padding: const EdgeInsets.symmetric(
// //                         horizontal: 16, vertical: 8),
// //                     itemCount: filteredProjects.length,
// //                     itemBuilder: (context, index) {
// //                       final project = filteredProjects[index];
// //                       String iconEmoji = '📋';
// //                       String projectType =
// //                           project['project_type'] ?? '';
// //                       if (projectType.contains('Crop'))
// //                         iconEmoji = '🌾';
// //                       else if (projectType.contains('Live'))
// //                         iconEmoji = '🐄';
// //                       else if (projectType.contains('Mach'))
// //                         iconEmoji = '🚜';
// //                       else if (projectType.contains('Post'))
// //                         iconEmoji = '📦';
// //                       else if (projectType.contains('Manage'))
// //                         iconEmoji = '📊';
// //
// //                       String durationLabel =
// //                       _getDurationLabel(project['days']);
// //                       String budgetFormatted = NumberFormat('#,##0')
// //                           .format(project['budget'] ?? 0);
// //                       int applicants = project['applicants'] ?? 0;
// //
// //                       return Container(
// //                         margin: const EdgeInsets.only(bottom: 12),
// //                         decoration: BoxDecoration(
// //                           color: Colors.white,
// //                           borderRadius: BorderRadius.circular(20),
// //                           border: Border.all(
// //                             color: Constants.AppColors.brand
// //                                 .withOpacity(0.12),
// //                             width: 1.2,
// //                           ),
// //                           boxShadow: [
// //                             BoxShadow(
// //                               color: Constants.AppColors.brand
// //                                   .withOpacity(0.06),
// //                               blurRadius: 20,
// //                               offset: const Offset(0, 6),
// //                               spreadRadius: 2,
// //                             ),
// //                           ],
// //                         ),
// //                         child: ClipRRect(
// //                           borderRadius: BorderRadius.circular(20),
// //                           child: Material(
// //                             color: Colors.transparent,
// //                             child: InkWell(
// //                               onTap: () {
// //                                 Navigator.push(
// //                                   context,
// //                                   MaterialPageRoute(
// //                                     builder: (context) =>
// //                                         ProjectDetails(
// //                                           projectId: project['id']
// //                                               .toString(),
// //                                         ),
// //                                   ),
// //                                 );
// //                               },
// //                               splashColor: Constants.AppColors.brand
// //                                   .withOpacity(0.1),
// //                               highlightColor: Constants.AppColors.brand
// //                                   .withOpacity(0.05),
// //                               child: Padding(
// //                                 padding:
// //                                 const EdgeInsets.all(18.0),
// //                                 child: Column(
// //                                   crossAxisAlignment:
// //                                   CrossAxisAlignment.start,
// //                                   children: [
// //                                     Row(
// //                                       crossAxisAlignment:
// //                                       CrossAxisAlignment.start,
// //                                       children: [
// //                                         Container(
// //                                           width: 48,
// //                                           height: 48,
// //                                           decoration: BoxDecoration(
// //                                             gradient:
// //                                             LinearGradient(
// //                                               begin: Alignment
// //                                                   .topLeft,
// //                                               end: Alignment
// //                                                   .bottomRight,
// //                                               colors: [
// //                                                 Constants
// //                                                     .AppColors
// //                                                     .brandTint,
// //                                                 Constants
// //                                                     .AppColors
// //                                                     .brandSoft
// //                                                     .withOpacity(
// //                                                     0.3),
// //                                               ],
// //                                             ),
// //                                             borderRadius:
// //                                             BorderRadius.circular(
// //                                                 14),
// //                                           ),
// //                                           child: Center(
// //                                             child: Text(
// //                                               iconEmoji,
// //                                               style: const TextStyle(
// //                                                   fontSize: 22),
// //                                             ),
// //                                           ),
// //                                         ),
// //                                         const SizedBox(width: 14),
// //                                         Expanded(
// //                                           child: Column(
// //                                             crossAxisAlignment:
// //                                             CrossAxisAlignment
// //                                                 .start,
// //                                             children: [
// //                                               Text(
// //                                                 translateText(project[
// //                                                 'title']
// //                                                     ?.toString() ??
// //                                                     'No Title'),
// //                                                 style: const TextStyle(
// //                                                   fontSize: 16,
// //                                                   fontWeight:
// //                                                   FontWeight.w700,
// //                                                   color: Constants.AppColors.brand,
// //                                                   height: 1.3,
// //                                                 ),
// //                                                 maxLines: 2,
// //                                                 overflow: TextOverflow
// //                                                     .ellipsis,
// //                                               ),
// //                                               const SizedBox(
// //                                                   height: 4),
// //                                               Container(
// //                                                 padding:
// //                                                 const EdgeInsets
// //                                                     .symmetric(
// //                                                     horizontal:
// //                                                     10,
// //                                                     vertical: 4),
// //                                                 decoration:
// //                                                 BoxDecoration(
// //                                                   color: Constants
// //                                                       .AppColors
// //                                                       .brandTint
// //                                                       .withOpacity(
// //                                                       0.5),
// //                                                   borderRadius:
// //                                                   BorderRadius
// //                                                       .circular(
// //                                                       20),
// //                                                 ),
// //                                                 child: Row(
// //                                                   mainAxisSize:
// //                                                   MainAxisSize
// //                                                       .min,
// //                                                   children: [
// //                                                     const Text('🌾',
// //                                                         style: TextStyle(
// //                                                             fontSize:
// //                                                             12)),
// //                                                     const SizedBox(
// //                                                         width: 4),
// //                                                     Text(
// //                                                       translateText(project[
// //                                                       'project_type'] ??
// //                                                           'N/A'),
// //                                                       style: TextStyle(
// //                                                         fontSize: 11,
// //                                                         fontWeight:
// //                                                         FontWeight
// //                                                             .w600,
// //                                                         color: Constants
// //                                                             .AppColors
// //                                                             .brandDeep,
// //                                                       ),
// //                                                     ),
// //                                                   ],
// //                                                 ),
// //                                               ),
// //                                             ],
// //                                           ),
// //                                         ),
// //                                         _buildProjectStatusBadge(
// //                                             project),
// //                                       ],
// //                                     ),
// //                                     const SizedBox(height: 12),
// //                                     const Divider(
// //                                         color: Color(0xFFF1F5EE),
// //                                         height: 1),
// //                                     const SizedBox(height: 10),
// //                                     Row(
// //                                       children: [
// //                                         const Icon(
// //                                             Icons
// //                                                 .location_on_outlined,
// //                                             size: 14,
// //                                             color: Color(0xFF64748B)),
// //                                         const SizedBox(width: 6),
// //                                         Expanded(
// //                                           child: Text(
// //                                             "${translateText(project['city'] ?? 'N/A')}, ${translateText(project['state'] ?? 'N/A')}",
// //                                             style: const TextStyle(
// //                                               fontSize: 13,
// //                                               fontWeight:
// //                                               FontWeight.w500,
// //                                               color: Color(
// //                                                   0xFF475569),
// //                                             ),
// //                                           ),
// //                                         ),
// //                                         if (applicants > 0)
// //                                           Container(
// //                                             padding:
// //                                             const EdgeInsets
// //                                                 .symmetric(
// //                                                 horizontal: 8,
// //                                                 vertical: 3),
// //                                             decoration: BoxDecoration(
// //                                               color: const Color(
// //                                                   0xFFF3E8FF),
// //                                               borderRadius:
// //                                               BorderRadius
// //                                                   .circular(12),
// //                                               border: Border.all(
// //                                                   color: const Color(
// //                                                       0xFFD8B4FE),
// //                                                   width: 0.5),
// //                                             ),
// //                                             child: Row(
// //                                               mainAxisSize:
// //                                               MainAxisSize.min,
// //                                               children: [
// //                                                 Icon(
// //                                                     Icons
// //                                                         .person_add_alt_1,
// //                                                     size: 11,
// //                                                     color: const Color(
// //                                                         0xFF7C3AED)),
// //                                                 const SizedBox(
// //                                                     width: 3),
// //                                                 Text(
// //                                                   '$applicants',
// //                                                   style:
// //                                                   const TextStyle(
// //                                                     fontSize: 10,
// //                                                     fontWeight:
// //                                                     FontWeight
// //                                                         .bold,
// //                                                     color: Color(
// //                                                         0xFF4C1D95),
// //                                                   ),
// //                                                 ),
// //                                               ],
// //                                             ),
// //                                           ),
// //                                       ],
// //                                     ),
// //                                     const SizedBox(height: 12),
// //                                     Row(
// //                                       children: [
// //                                         _buildPremiumChip(
// //                                           icon: Icons
// //                                               .people_outline,
// //                                           label:
// //                                           '${project['qty_labours'] ?? '0'} ${translate('Workers', 'मजदूर')}',
// //                                           bgColor: const Color(
// //                                               0xFFF3E8DC),
// //                                           iconColor: const Color(
// //                                               0xFF865E2A),
// //                                           labelColor: const Color(
// //                                               0xFF865E2A),
// //                                         ),
// //                                         const SizedBox(width: 8),
// //                                         _buildPremiumChip(
// //                                           icon:
// //                                           Icons.currency_rupee,
// //                                           label:
// //                                           '$budgetFormatted',
// //                                           bgColor: const Color(
// //                                               0xFFF3E8DC),
// //                                           iconColor: const Color(
// //                                               0xFF865E2A),
// //                                           labelColor: const Color(
// //                                               0xFF865E2A),
// //                                         ),
// //                                         const SizedBox(width: 8),
// //                                         _buildPremiumChip(
// //                                           icon: Icons
// //                                               .access_time_outlined,
// //                                           label: durationLabel,
// //                                           bgColor: const Color(
// //                                               0xFFF3E8DC),
// //                                           iconColor: const Color(
// //                                               0xFF865E2A),
// //                                           labelColor: const Color(
// //                                               0xFF865E2A),
// //                                         ),
// //                                       ],
// //                                     ),
// //                                     const SizedBox(height: 16),
// //                                     Row(
// //                                       children: [
// //                                         if (applicants > 0)
// //                                           Expanded(
// //                                             child: SizedBox(
// //                                               height: 44,
// //                                               child: ElevatedButton(
// //                                                 onPressed: () {
// //                                                   Navigator.push(
// //                                                     context,
// //                                                     MaterialPageRoute(
// //                                                       builder: (context) =>
// //                                                           ProjectApplicationsPage(
// //                                                             projectId: project[
// //                                                             'id']
// //                                                                 .toString(),
// //                                                           ),
// //                                                     ),
// //                                                   ).then((_) {
// //                                                     fetchProjects();
// //                                                   });
// //                                                 },
// //                                                 style: ElevatedButton
// //                                                     .styleFrom(
// //                                                   backgroundColor:
// //                                                   Constants
// //                                                       .AppColors
// //                                                       .button,
// //                                                   foregroundColor:
// //                                                   Colors.white,
// //                                                   shape:
// //                                                   RoundedRectangleBorder(
// //                                                     borderRadius:
// //                                                     BorderRadius
// //                                                         .circular(
// //                                                         10),
// //                                                   ),
// //                                                   padding:
// //                                                   EdgeInsets.zero,
// //                                                 ),
// //                                                 child: FittedBox(
// //                                                   fit: BoxFit
// //                                                       .scaleDown,
// //                                                   child: Text(
// //                                                     AppLocalizations.of(
// //                                                         context)!
// //                                                         .viewApplications,
// //                                                     style:
// //                                                     const TextStyle(
// //                                                       fontSize: 13,
// //                                                       fontWeight:
// //                                                       FontWeight
// //                                                           .bold,
// //                                                       color: Colors
// //                                                           .white,
// //                                                     ),
// //                                                   ),
// //                                                 ),
// //                                               ),
// //                                             ),
// //                                           ),
// //                                         if (applicants > 0)
// //                                           const SizedBox(width: 8),
// //                                         Expanded(
// //                                           child: SizedBox(
// //                                             height: 44,
// //                                             child: ElevatedButton(
// //                                               onPressed: () {
// //                                                 Navigator.push(
// //                                                   context,
// //                                                   MaterialPageRoute(
// //                                                     builder: (context) =>
// //                                                         ProjectDetails(
// //                                                           projectId: project[
// //                                                           'id']
// //                                                               .toString(),
// //                                                         ),
// //                                                   ),
// //                                                 ).then((_) {
// //                                                   fetchProjects();
// //                                                 });
// //                                               },
// //                                               style: ElevatedButton
// //                                                   .styleFrom(
// //                                                 backgroundColor:
// //                                                 Constants
// //                                                     .AppColors
// //                                                     .button,
// //                                                 foregroundColor:
// //                                                 Colors.white,
// //                                                 shape:
// //                                                 RoundedRectangleBorder(
// //                                                   borderRadius:
// //                                                   BorderRadius
// //                                                       .circular(
// //                                                       10),
// //                                                 ),
// //                                                 padding:
// //                                                 EdgeInsets.zero,
// //                                               ),
// //                                               child: FittedBox(
// //                                                 fit: BoxFit
// //                                                     .scaleDown,
// //                                                 child: Text(
// //                                                   translateText(
// //                                                       'Details'),
// //                                                   style:
// //                                                   const TextStyle(
// //                                                     fontSize: 13,
// //                                                     fontWeight:
// //                                                     FontWeight
// //                                                         .bold,
// //                                                     color: Colors
// //                                                         .white,
// //                                                   ),
// //                                                 ),
// //                                               ),
// //                                             ),
// //                                           ),
// //                                         ),
// //                                       ],
// //                                     ),
// //                                   ],
// //                                 ),
// //                               ),
// //                             ),
// //                           ),
// //                         ),
// //                       );
// //                     },
// //                   ),
// //                 ),
// //               ],
// //             ),
// //           ),
// //         ),
// //       ),
// //     );
// //   }
// // }
// //
// // class ProfilePage extends StatelessWidget {
// //   @override
// //   Widget build(BuildContext context) {
// //     return Center(
// //       child: Text(
// //         "This is the Profile Page",
// //         style: TextStyle(fontSize: 24, color: Colors.blue),
// //       ),
// //     );
// //   }
// // }
// //
// // class ProjectApplicationsPage extends StatefulWidget {
// //   final String projectId;
// //
// //   ProjectApplicationsPage({required this.projectId});
// //
// //   @override
// //   _ProjectApplicationsPageState createState() =>
// //       _ProjectApplicationsPageState();
// // }
// //
// // class _ProjectApplicationsPageState extends State<ProjectApplicationsPage> {
// //   bool isLoading = true;
// //   List<dynamic> applications = [];
// //   final _secureStorage = const FlutterSecureStorage();
// //   bool _isProcessing = false;
// //
// //   String _selectedLanguage = 'en';
// //   Map<String, Map<String, String>> _cachedTranslations = {};
// //   Map<String, Map<String, String>> translations =
// //       Constants.AppConstants.translations;
// //   final GoogleTranslator _translator = GoogleTranslator();
// //
// //   Future<void> loadLanguage() async {
// //     String? language = await _secureStorage.read(key: 'selectedLanguage');
// //     _selectedLanguage = language ?? 'en';
// //   }
// //
// //   String translateText(String text) {
// //     if (text.isEmpty) return "";
// //     String targetLang = _selectedLanguage ?? 'en';
// //     if (translations.containsKey(text) &&
// //         translations[text]!.containsKey(targetLang)) {
// //       return translations[text]![targetLang]!;
// //     }
// //     if (_cachedTranslations.containsKey(text) &&
// //         _cachedTranslations[text]!.containsKey(targetLang)) {
// //       return _cachedTranslations[text]![targetLang]!;
// //     }
// //     _fetchTranslation(text, targetLang);
// //     return text;
// //   }
// //
// //   Future<void> _fetchTranslation(String text, String targetLang) async {
// //     try {
// //       if (Constants.AppConstants.translations.containsKey(text) &&
// //           Constants.AppConstants.translations[text]!.containsKey(targetLang)) {
// //         return;
// //       }
// //       final translation = await _translator.translate(text, to: targetLang);
// //       if (!translations.containsKey(text)) {
// //         translations[text] = {"en": text, "hi": text};
// //       }
// //       translations[text]![targetLang] = translation.text;
// //       _cachedTranslations = translations;
// //       if (!Constants.AppConstants.translations.containsKey(text)) {
// //         Constants.AppConstants.translations[text] = {};
// //       }
// //       Constants.AppConstants.translations[text]![targetLang] = translation.text;
// //       _cachedTranslations.putIfAbsent(text, () => {})[targetLang] =
// //           translation.text;
// //       setState(() {});
// //     } catch (e) {
// //       print("Translation error: $e");
// //     }
// //   }
// //
// //   String translate(String enText, String hiText) {
// //     return _selectedLanguage == 'en' ? enText : hiText;
// //   }
// //
// //   @override
// //   void initState() {
// //     super.initState();
// //     loadLanguage();
// //     fetchProjectApplications();
// //   }
// //
// //   Future<void> fetchProjectApplications() async {
// //     final String apiUrl =
// //         '${Constants.AppConstants.apiUrl}farmer/farmerProjectDetails';
// //     String? userId = await _secureStorage.read(key: 'id');
// //     if (userId == null) {
// //       ScaffoldMessenger.of(context).showSnackBar(
// //         const SnackBar(content: Text('User ID not found in secure storage')),
// //       );
// //       return;
// //     }
// //     final Map<String, dynamic> requestBody = {
// //       'id': userId,
// //       'project_id': widget.projectId,
// //     };
// //     try {
// //       final response = await http.post(
// //         Uri.parse(apiUrl),
// //         headers: {'Content-Type': 'application/json'},
// //         body: jsonEncode(requestBody),
// //       );
// //       if (response.statusCode == 200) {
// //         final responseData = json.decode(response.body);
// //         if (responseData['success'] == true) {
// //           setState(() {
// //             applications = responseData['data']['applications'];
// //             isLoading = false;
// //           });
// //         } else {
// //           setState(() => isLoading = false);
// //           ScaffoldMessenger.of(context).showSnackBar(
// //             const SnackBar(content: Text('Failed to fetch project details')),
// //           );
// //         }
// //       } else {
// //         setState(() => isLoading = false);
// //         ScaffoldMessenger.of(context).showSnackBar(
// //           const SnackBar(content: Text('Failed to fetch project details')),
// //         );
// //       }
// //     } catch (e) {
// //       setState(() => isLoading = false);
// //     }
// //   }
// //
// //   Future<void> unassignProject(String labourId, String projectId) async {
// //     setState(() => _isProcessing = true);
// //     String url = '${Constants.AppConstants.apiUrl}farmer/unassignProject';
// //     try {
// //       final response = await http.post(
// //         Uri.parse(url),
// //         headers: {'Content-Type': 'application/json'},
// //         body: json.encode({
// //           'labourids': labourId,
// //           'projectids': projectId,
// //         }),
// //       );
// //       if (response.statusCode == 200) {
// //         final data = json.decode(response.body);
// //         if (data['status'] == '1') {
// //           await fetchProjectApplications();
// //           ScaffoldMessenger.of(context).showSnackBar(
// //             SnackBar(content: Text(data['message'])),
// //           );
// //         }
// //       }
// //     } catch (e) {
// //       // ignore
// //     } finally {
// //       setState(() => _isProcessing = false);
// //     }
// //   }
// //
// //   Future<void> cancelConfirm(
// //       String projectId, String labourId, String cancelRemark) async {
// //     setState(() => _isProcessing = true);
// //     String url = '${Constants.AppConstants.apiUrl}farmer/cancelConfirm';
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
// //       if (response.statusCode == 200) {
// //         final data = json.decode(response.body);
// //         if (data['status'] == '1') {
// //           await fetchProjectApplications();
// //           ScaffoldMessenger.of(context).showSnackBar(
// //             SnackBar(content: Text(data['message'])),
// //           );
// //         }
// //       }
// //     } catch (e) {
// //       // ignore
// //     } finally {
// //       setState(() => _isProcessing = false);
// //     }
// //   }
// //
// //   void showCancelDialog(BuildContext context, String labourId) {
// //     TextEditingController _cancelRemarkController = TextEditingController();
// //     showDialog(
// //       context: context,
// //       builder: (BuildContext context) {
// //         return AlertDialog(
// //           title: Text(translate('Cancel Remark', 'रद्द करने का कारण')),
// //           content: Column(
// //             mainAxisSize: MainAxisSize.min,
// //             children: [
// //               TextField(
// //                 controller: _cancelRemarkController,
// //                 decoration: InputDecoration(
// //                   labelText: translate(
// //                       'Enter Cancel Remark', 'रद्द करने का कारण दर्ज करें'),
// //                   border: OutlineInputBorder(),
// //                   suffixIcon:
// //                   MicIconButton(controller: _cancelRemarkController),
// //                 ),
// //                 maxLines: 3,
// //               ),
// //             ],
// //           ),
// //           actions: <Widget>[
// //             TextButton(
// //               onPressed: () => Navigator.of(context).pop(),
// //               child: Text(translate('Cancel', 'रद्द करें')),
// //             ),
// //             TextButton(
// //               onPressed: () {
// //                 if (_cancelRemarkController.text.isNotEmpty) {
// //                   cancelConfirm(
// //                     widget.projectId,
// //                     labourId,
// //                     _cancelRemarkController.text,
// //                   );
// //                   Navigator.of(context).pop();
// //                 } else {
// //                   ScaffoldMessenger.of(context).showSnackBar(
// //                     const SnackBar(content: Text('Remark cannot be empty')),
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
// //     setState(() => _isProcessing = true);
// //     String url = '${Constants.AppConstants.apiUrl}farmer/confirmComplete';
// //     try {
// //       final response = await http.post(
// //         Uri.parse(url),
// //         headers: {'Content-Type': 'application/json'},
// //         body: json.encode({
// //           'projectid': projectId,
// //           'labourid': labourId,
// //         }),
// //       );
// //       if (response.statusCode == 200) {
// //         final data = json.decode(response.body);
// //         if (data['status'] == '1') {
// //           await fetchProjectApplications();
// //           ScaffoldMessenger.of(context).showSnackBar(
// //             SnackBar(content: Text(data['message'])),
// //           );
// //         }
// //       }
// //     } catch (e) {
// //       // ignore
// //     } finally {
// //       setState(() => _isProcessing = false);
// //     }
// //   }
// //
// //   Future<void> _assignWithConfirmation(String labourId) async {
// //     bool? confirm = await _showAssignConfirmationDialog();
// //     if (confirm == true) {
// //       await assignProject(labourId);
// //     }
// //   }
// //
// //   Future<bool?> _showAssignConfirmationDialog() {
// //     return showDialog<bool>(
// //       context: context,
// //       builder: (context) => AlertDialog(
// //         title: Text(translate('Assign Project', 'परियोजना असाइन करें')),
// //         content: Text(translate(
// //             'Are you sure you want to assign this project to the selected worker?',
// //             'क्या आप सुनिश्चित हैं कि आप इस परियोजना को चयनित कार्यकर्ता को असाइन करना चाहते हैं?')),
// //         actions: [
// //           TextButton(
// //             onPressed: () => Navigator.pop(context, false),
// //             child: Text(translate('Cancel', 'रद्द करें')),
// //           ),
// //           TextButton(
// //             onPressed: () => Navigator.pop(context, true),
// //             child: Text(translate('Yes', 'हाँ')),
// //           ),
// //         ],
// //       ),
// //     );
// //   }
// //
// //   Future<void> assignProject(String labourId) async {
// //     final String apiUrl =
// //         '${Constants.AppConstants.apiUrl}farmer/projectAssigned';
// //     String? userId = await _secureStorage.read(key: 'id');
// //     if (userId == null) {
// //       ScaffoldMessenger.of(context).showSnackBar(
// //         const SnackBar(content: Text('User ID not found in secure storage')),
// //       );
// //       return;
// //     }
// //     final Map<String, dynamic> requestBody = {
// //       'labourid': labourId,
// //       'projectid': widget.projectId,
// //     };
// //     try {
// //       final response = await http.post(
// //         Uri.parse(apiUrl),
// //         headers: {'Content-Type': 'application/json'},
// //         body: jsonEncode(requestBody),
// //       );
// //       if (response.statusCode == 200) {
// //         final responseData = json.decode(response.body);
// //         if (responseData['status'] == 1) {
// //           await fetchProjectApplications();
// //           ScaffoldMessenger.of(context).showSnackBar(
// //             const SnackBar(content: Text('Project assigned successfully')),
// //           );
// //           Future.delayed(const Duration(seconds: 1), () {
// //             Navigator.pop(context, true);
// //           });
// //         } else {
// //           ScaffoldMessenger.of(context).showSnackBar(
// //             SnackBar(
// //                 content: Text(
// //                     'Failed to assign project: ${responseData['message']}')),
// //           );
// //         }
// //       }
// //     } catch (e) {
// //       // ignore
// //     }
// //   }
// //
// //   Future<void> _unassignWithConfirmation(String labourId) async {
// //     bool? confirm = await _showUnassignConfirmationDialog();
// //     if (confirm == true) {
// //       await unassignProject(labourId, widget.projectId);
// //     }
// //   }
// //
// //   Future<bool?> _showUnassignConfirmationDialog() {
// //     return showDialog<bool>(
// //       context: context,
// //       builder: (context) => AlertDialog(
// //         title: Text(translate('Unassign Project', 'परियोजना अनअसाइन करें')),
// //         content: Text(translate(
// //             'Are you sure you want to unassign this project from the worker?',
// //             'क्या आप सुनिश्चित हैं कि आप इस परियोजना को कार्यकर्ता से अनअसाइन करना चाहते हैं?')),
// //         actions: [
// //           TextButton(
// //             onPressed: () => Navigator.pop(context, false),
// //             child: Text(translate('Cancel', 'रद्द करें')),
// //           ),
// //           TextButton(
// //             onPressed: () => Navigator.pop(context, true),
// //             child: Text(translate('Yes', 'हाँ')),
// //           ),
// //         ],
// //       ),
// //     );
// //   }
// //
// //   String getStatusText(String status) {
// //     switch (status) {
// //       case '0':
// //         return AppLocalizations.of(context)!.notAssigned;
// //       case '1':
// //         return AppLocalizations.of(context)!.assigned;
// //       case '2':
// //         return AppLocalizations.of(context)!.workStarted;
// //       case '3':
// //         return AppLocalizations.of(context)!.completed;
// //       default:
// //         return AppLocalizations.of(context)!.cancelled;
// //     }
// //   }
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     final language =
// //         Provider.of<LanguageProvider>(context, listen: false).selectedLanguage;
// //
// //     String translate(String enText, String hiText) {
// //       return language == 'en' ? enText : hiText;
// //     }
// //
// //     return Scaffold(
// //       backgroundColor: Constants.AppColors.surface,
// //       appBar: AppBar(
// //         title: Text(
// //           AppLocalizations.of(context)!.projectApplications,
// //           style: Constants.AppTypography.h2.copyWith(color: Colors.white),
// //         ),
// //         iconTheme: const IconThemeData(color: Colors.white),
// //         flexibleSpace: Container(
// //           decoration: const BoxDecoration(
// //             gradient: Constants.AppColors.brandGradient,
// //           ),
// //         ),
// //         leading: IconButton(
// //           icon: const Icon(Icons.arrow_back),
// //           onPressed: () {
// //             Navigator.pop(context);
// //           },
// //         ),
// //         elevation: 0,
// //       ),
// //       body: RefreshIndicator(
// //         onRefresh: fetchProjectApplications,
// //         child: isLoading
// //             ? const Center(child: CircularProgressIndicator())
// //             : applications.isEmpty
// //             ? Center(
// //           child: Column(
// //             mainAxisAlignment: MainAxisAlignment.center,
// //             children: [
// //               Icon(
// //                 Icons.person_off_outlined,
// //                 size: 72,
// //                 color: Constants.AppColors.inkSoft,
// //               ),
// //               const SizedBox(height: 16),
// //               Text(
// //                 translateText('No applications found'),
// //                 style: Constants.AppTypography.h3.copyWith(
// //                   color: Constants.AppColors.inkSoft,
// //                 ),
// //               ),
// //             ],
// //           ),
// //         )
// //             : ListView.builder(
// //           padding:
// //           const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
// //           itemCount: applications.length,
// //           itemBuilder: (context, index) {
// //             final application = applications[index];
// //             String status = application['status']?.toString() ?? '0';
// //             Color statusColor;
// //             Color statusBg;
// //             switch (status) {
// //               case '0':
// //                 statusColor = const Color(0xFF64748B);
// //                 statusBg = const Color(0xFFF1F5F9);
// //                 break;
// //               case '1':
// //                 statusColor = const Color(0xFF0E6805);
// //                 statusBg = const Color(0xFFEAF4E8);
// //                 break;
// //               case '2':
// //                 statusColor = const Color(0xFFC2410C);
// //                 statusBg = const Color(0xFFFFF7ED);
// //                 break;
// //               case '3':
// //                 statusColor = const Color(0xFF15803D);
// //                 statusBg = const Color(0xFFF0FDF4);
// //                 break;
// //               default:
// //                 statusColor = const Color(0xFF991B1B);
// //                 statusBg = const Color(0xFFFEF2F2);
// //             }
// //
// //             return Container(
// //               margin: const EdgeInsets.only(bottom: 12),
// //               decoration: BoxDecoration(
// //                 color: Colors.white,
// //                 borderRadius: BorderRadius.circular(16),
// //                 border: Border.all(
// //                   color: Constants.AppColors.border,
// //                   width: 1.0,
// //                 ),
// //                 boxShadow: [
// //                   BoxShadow(
// //                     color: Colors.black.withOpacity(0.04),
// //                     blurRadius: 12,
// //                     offset: const Offset(0, 4),
// //                   ),
// //                 ],
// //               ),
// //               child: Padding(
// //                 padding: const EdgeInsets.all(16),
// //                 child: Column(
// //                   crossAxisAlignment: CrossAxisAlignment.start,
// //                   children: [
// //                     Row(
// //                       crossAxisAlignment: CrossAxisAlignment.start,
// //                       children: [
// //                         Container(
// //                           width: 48,
// //                           height: 48,
// //                           decoration: const BoxDecoration(
// //                             color: Color(0xFFEAF4E8),
// //                             shape: BoxShape.circle,
// //                           ),
// //                           child: Center(
// //                             child: Text(
// //                               (application['labour_name'] ?? 'W')[0]
// //                                   .toUpperCase(),
// //                               style: const TextStyle(
// //                                 fontSize: 18,
// //                                 fontWeight: FontWeight.bold,
// //                                 color: Constants.AppColors.brand,
// //                               ),
// //                             ),
// //                           ),
// //                         ),
// //                         const SizedBox(width: 12),
// //                         Expanded(
// //                           child: Column(
// //                             crossAxisAlignment:
// //                             CrossAxisAlignment.start,
// //                             children: [
// //                               Text(
// //                                 translateText(application[
// //                                 'labour_name'] ??
// //                                     'Unknown'),
// //                                 style: const TextStyle(
// //                                   fontSize: 16,
// //                                   fontWeight: FontWeight.bold,
// //                                   color: Color(0xFF1A1A2E),
// //                                 ),
// //                               ),
// //                               const SizedBox(height: 4),
// //                               Row(
// //                                 children: [
// //                                   Container(
// //                                     padding:
// //                                     const EdgeInsets.symmetric(
// //                                         horizontal: 8,
// //                                         vertical: 3),
// //                                     decoration: BoxDecoration(
// //                                       color: statusBg,
// //                                       borderRadius:
// //                                       BorderRadius.circular(12),
// //                                       border: Border.all(
// //                                         color: statusColor
// //                                             .withOpacity(0.3),
// //                                         width: 0.5,
// //                                       ),
// //                                     ),
// //                                     child: Text(
// //                                       translateText(
// //                                           getStatusText(status)),
// //                                       style: TextStyle(
// //                                         fontSize: 11,
// //                                         fontWeight: FontWeight.bold,
// //                                         color: statusColor,
// //                                       ),
// //                                     ),
// //                                   ),
// //                                   const SizedBox(width: 8),
// //                                   Icon(
// //                                     Icons.calendar_today_outlined,
// //                                     size: 12,
// //                                     color: Colors.grey[500],
// //                                   ),
// //                                   const SizedBox(width: 4),
// //                                   Text(
// //                                     _formatDate(
// //                                         application['created_at'] ??
// //                                             ''),
// //                                     style: const TextStyle(
// //                                       fontSize: 11,
// //                                       color: Colors.grey,
// //                                     ),
// //                                   ),
// //                                 ],
// //                               ),
// //                             ],
// //                           ),
// //                         ),
// //                       ],
// //                     ),
// //                     const SizedBox(height: 12),
// //                     const Divider(color: Color(0xFFF1F5EE), height: 1),
// //                     const SizedBox(height: 10),
// //                     Row(
// //                       children: [
// //                         Icon(Icons.chat_bubble_outline,
// //                             size: 16, color: Colors.grey[500]),
// //                         const SizedBox(width: 6),
// //                         Expanded(
// //                           child: Text(
// //                             translateText(
// //                                 application['comment'] ?? 'N/A'),
// //                             style: const TextStyle(
// //                               fontSize: 13,
// //                               color: Color(0xFF475569),
// //                             ),
// //                           ),
// //                         ),
// //                         SpeakerIconButton(
// //                           text: translateText(
// //                               application['comment'] ?? 'N/A'),
// //                           size: 16,
// //                         ),
// //                       ],
// //                     ),
// //                     const SizedBox(height: 8),
// //                     Row(
// //                       children: [
// //                         Icon(Icons.location_on_outlined,
// //                             size: 16, color: Colors.grey[500]),
// //                         const SizedBox(width: 6),
// //                         Expanded(
// //                           child: Text(
// //                             translateText(
// //                                 '${application['labour_address'] ?? ''}, ${application['labour_city'] ?? ''}, ${application['labour_state'] ?? ''}'),
// //                             style: const TextStyle(
// //                               fontSize: 13,
// //                               color: Color(0xFF475569),
// //                             ),
// //                             maxLines: 1,
// //                             overflow: TextOverflow.ellipsis,
// //                           ),
// //                         ),
// //                       ],
// //                     ),
// //                     const SizedBox(height: 12),
// //                     Row(
// //                       mainAxisAlignment:
// //                       MainAxisAlignment.spaceEvenly,
// //                       children: [
// //                         Expanded(
// //                           child: SizedBox(
// //                             height: 40,
// //                             child: OutlinedButton(
// //                               onPressed: () {
// //                                 Navigator.push(
// //                                   context,
// //                                   MaterialPageRoute(
// //                                     builder: (context) =>
// //                                         ApplicationDetailPage(
// //                                           application: application,
// //                                         ),
// //                                   ),
// //                                 );
// //                               },
// //                               style: OutlinedButton.styleFrom(
// //                                 side: BorderSide(
// //                                     color: Constants.AppColors.brand,
// //                                     width: 1.2),
// //                                 shape: RoundedRectangleBorder(
// //                                   borderRadius:
// //                                   BorderRadius.circular(10),
// //                                 ),
// //                                 padding: const EdgeInsets.symmetric(
// //                                     horizontal: 4),
// //                               ),
// //                               child: FittedBox(
// //                                 fit: BoxFit.scaleDown,
// //                                 child: Text(
// //                                   AppLocalizations.of(context)!
// //                                       .viewDetails,
// //                                   style: TextStyle(
// //                                     color: Constants.AppColors.brand,
// //                                     fontWeight: FontWeight.bold,
// //                                     fontSize: 12,
// //                                   ),
// //                                 ),
// //                               ),
// //                             ),
// //                           ),
// //                         ),
// //                         const SizedBox(width: 8),
// //                         if (status == "0")
// //                           Expanded(
// //                             child: SizedBox(
// //                               height: 40,
// //                               child: ElevatedButton(
// //                                 onPressed: _isProcessing
// //                                     ? null
// //                                     : () =>
// //                                     _assignWithConfirmation(
// //                                         application['labour_id']
// //                                             .toString()),
// //                                 style: ElevatedButton.styleFrom(
// //                                   backgroundColor:
// //                                   Constants.AppColors.brand,
// //                                   foregroundColor: Colors.white,
// //                                   shape: RoundedRectangleBorder(
// //                                     borderRadius:
// //                                     BorderRadius.circular(10),
// //                                   ),
// //                                   padding: const EdgeInsets.symmetric(
// //                                       horizontal: 4),
// //                                 ),
// //                                 child: FittedBox(
// //                                   fit: BoxFit.scaleDown,
// //                                   child: Text(
// //                                     translateText('Assign'),
// //                                     style: const TextStyle(
// //                                       fontWeight: FontWeight.bold,
// //                                       fontSize: 12,
// //                                       color: Colors.white,
// //                                     ),
// //                                   ),
// //                                 ),
// //                               ),
// //                             ),
// //                           )
// //                         else if (status == "1")
// //                           Expanded(
// //                             child: SizedBox(
// //                               height: 40,
// //                               child: ElevatedButton(
// //                                 onPressed: _isProcessing
// //                                     ? null
// //                                     : () =>
// //                                     _unassignWithConfirmation(
// //                                         application['labour_id']
// //                                             .toString()),
// //                                 style: ElevatedButton.styleFrom(
// //                                   backgroundColor: Colors.red,
// //                                   foregroundColor: Colors.white,
// //                                   shape: RoundedRectangleBorder(
// //                                     borderRadius:
// //                                     BorderRadius.circular(10),
// //                                   ),
// //                                   padding: const EdgeInsets.symmetric(
// //                                       horizontal: 4),
// //                                 ),
// //                                 child: FittedBox(
// //                                   fit: BoxFit.scaleDown,
// //                                   child: Text(
// //                                     translateText('Unassign'),
// //                                     style: const TextStyle(
// //                                       fontWeight: FontWeight.bold,
// //                                       fontSize: 12,
// //                                       color: Colors.white,
// //                                     ),
// //                                   ),
// //                                 ),
// //                               ),
// //                             ),
// //                           )
// //                         else if (status == "2")
// //                             Expanded(
// //                               child: SizedBox(
// //                                 height: 40,
// //                                 child: ElevatedButton(
// //                                   onPressed: _isProcessing
// //                                       ? null
// //                                       : () => confirmComplete(
// //                                       widget.projectId,
// //                                       application['labour_id']
// //                                           .toString()),
// //                                   style: ElevatedButton.styleFrom(
// //                                     backgroundColor: Colors.green,
// //                                     foregroundColor: Colors.white,
// //                                     shape: RoundedRectangleBorder(
// //                                       borderRadius:
// //                                       BorderRadius.circular(10),
// //                                     ),
// //                                     padding: const EdgeInsets.symmetric(
// //                                         horizontal: 4),
// //                                   ),
// //                                   child: FittedBox(
// //                                     fit: BoxFit.scaleDown,
// //                                     child: Text(
// //                                       translateText('Complete'),
// //                                       style: const TextStyle(
// //                                         fontWeight: FontWeight.bold,
// //                                         fontSize: 12,
// //                                         color: Colors.white,
// //                                       ),
// //                                     ),
// //                                   ),
// //                                 ),
// //                               ),
// //                             )
// //                           else
// //                             const SizedBox.shrink(),
// //                       ],
// //                     ),
// //                   ],
// //                 ),
// //               ),
// //             );
// //           },
// //         ),
// //       ),
// //     );
// //   }
// //
// //   String _formatDate(String dateString) {
// //     if (dateString.isEmpty) return 'N/A';
// //     try {
// //       DateTime dateTime = DateTime.parse(dateString);
// //       return DateFormat('dd MMM yyyy').format(dateTime);
// //     } catch (e) {
// //       return dateString;
// //     }
// //   }
// // }
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
// import 'package:greencollar/location_provider.dart';
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
// // --- NEW BRAND COLORS APPLIED DIRECTLY HERE ---
// const Color kBrandGreen = Color(0xFF0E6805);
// const Color kBrandBrown = Color(0xFF865E2A);
// const Color kBrandGreenTint = Color(0x190E6805); // 10% opacity
// const Color kBrandBrownTint = Color(0x19865E2A); // 10% opacity
// const Color kSurfaceBackground = Color(0xFFF9FAFB);
// const Color kBorderColor = Color(0xFFE5E7EB);
// const Color kTextGrey = Color(0xFF6B7280);
// // ----------------------------------------------
//
// class JobType {
//   final int id;
//   final String jobname;
//   final String image;
//   final String status;
//
//   JobType({
//     required this.id,
//     required this.jobname,
//     required this.image,
//     required this.status,
//   });
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
//   String _selectedLanguage = 'en';
//   String _userName = '';
//   String _userType = '';
//   int _walletCoins = 0;
//
//   Future<void> _loadWalletBalance() async {
//     int coins = await WalletHelper.syncCoinBalance();
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
//     String? language = await _secureStorage.read(key: 'selectedLanguage');
//     _selectedLanguage = language ?? 'en';
//   }
//
//   Map<String, Map<String, String>> _cachedTranslations = {};
//   int unreadNotificationsCount = 0;
//
//   Map<String, Map<String, String>> translations =
//       Constants.AppConstants.translations;
//   final GoogleTranslator _translator = GoogleTranslator();
//
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
//     String? userId = await _secureStorage.read(key: 'id');
//     if (userId == null) return;
//     final url = Uri.parse(
//         '${Constants.AppConstants.apiUrl}farmer/getUnreadNotificationsCount');
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
//     String translatedText = await _fetchTranslation(text, targetLang);
//     return translatedText;
//   }
//
//   Future<String> _fetchTranslation(String text, String targetLang) async {
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
//   final List<Widget> _pages = [
//     CombinedPage(),
//     LabourPage(),
//     ProjectPage(),
//   ];
//
//   Future<void> _logout(BuildContext context) async {
//     await _secureStorage.delete(key: 'id');
//     await _secureStorage.delete(key: 'token');
//     await _secureStorage.delete(key: 'name');
//     await _secureStorage.delete(key: 'phone');
//     await _secureStorage.delete(key: 'userType');
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
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
//       child: ListTile(
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(12),
//         ),
//         leading: Container(
//           height: 40,
//           width: 40,
//           decoration: BoxDecoration(
//             color: isLogout ? const Color(0xFFFEF2F2) : kBrandGreenTint,
//             borderRadius: BorderRadius.circular(10),
//           ),
//           child: Icon(
//               icon,
//               color: isLogout ? const Color(0xFFEF4444) : kBrandGreen,
//               size: 20
//           ),
//         ),
//         title: title,
//         trailing: trailing ??
//             Icon(
//               Icons.chevron_right_rounded,
//               color: isLogout ? const Color(0xFFEF4444) : kTextGrey,
//               size: 20,
//             ),
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
//               ? Consumer<LocationProvider>(
//             builder: (context, locationProvider, child) {
//               Widget locationWidget;
//               if (locationProvider.isLoading) {
//                 locationWidget = Row(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     const SizedBox(
//                       width: 12,
//                       height: 12,
//                       child: CircularProgressIndicator(
//                         strokeWidth: 1.5,
//                         valueColor: AlwaysStoppedAnimation<Color>(
//                             Colors.white70),
//                       ),
//                     ),
//                     const SizedBox(width: 6),
//                     Text(
//                       _selectedLanguage == 'en'
//                           ? 'Finding location...'
//                           : 'स्थान खोज रहे हैं...',
//                       style: TextStyle(
//                         fontSize: 12,
//                         color: Colors.white.withOpacity(0.8),
//                       ),
//                     ),
//                   ],
//                 );
//               } else if (locationProvider.error.isNotEmpty ||
//                   (locationProvider.city.isEmpty &&
//                       locationProvider.state.isEmpty)) {
//                 locationWidget = Row(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     const Icon(Icons.location_off,
//                         size: 14, color: Colors.white70),
//                     const SizedBox(width: 4),
//                     Text(
//                       _selectedLanguage == 'en'
//                           ? 'Location unavailable'
//                           : 'स्थान अनुपलब्ध',
//                       style: TextStyle(
//                         fontSize: 12,
//                         color: Colors.white.withOpacity(0.8),
//                       ),
//                     ),
//                   ],
//                 );
//               } else {
//                 locationWidget = Row(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     const Icon(Icons.location_on,
//                         size: 14, color: Colors.white),
//                     const SizedBox(width: 4),
//                     Flexible(
//                       child: Text(
//                         '${locationProvider.city}, ${locationProvider.state}',
//                         style: const TextStyle(
//                           fontSize: 13,
//                           color: Colors.white,
//                           fontWeight: FontWeight.w500,
//                         ),
//                         overflow: TextOverflow.ellipsis,
//                       ),
//                     ),
//                   ],
//                 );
//               }
//
//               return Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   Row(
//                     mainAxisSize: MainAxisSize.min,
//                     children: [
//                       Container(
//                         padding: const EdgeInsets.symmetric(
//                             horizontal: 10, vertical: 4),
//                         decoration: BoxDecoration(
//                           color: Colors.transparent,
//                           borderRadius: BorderRadius.circular(20),
//                           border: Border.all(
//                               color: Colors.white, width: 1.0),
//                         ),
//                         child: Text(
//                           _selectedLanguage == 'en'
//                               ? 'Farmer'
//                               : 'किसान',
//                           style: TextStyle(
//                             fontSize: 11,
//                             color: Colors.white,
//                             fontWeight: FontWeight.w500,
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                   const SizedBox(height: 6),
//                   locationWidget,
//                 ],
//               );
//             },
//           )
//               : Text(
//             _currentIndex == 1
//                 ? AppLocalizations.of(context)!.nearbylabours
//                 : _currentIndex == 2
//                 ? AppLocalizations.of(context)!.yourprojects
//                 : 'Default Title',
//             style: TextStyle(
//                 fontSize: 18,
//                 fontWeight: FontWeight.bold,
//                 color: Colors.white
//             ),
//           ),
//           iconTheme: const IconThemeData(color: Colors.white),
//           backgroundColor: kBrandGreen,
//           actions: [
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
//               },
//             ),
//           ],
//         ),
//         drawer: Drawer(
//           backgroundColor: Colors.white,
//           child: Column(
//             children: [
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
//                       Color(0xFF075503), // Slightly darker brand green
//                       kBrandGreen,
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
//                           _userName.isNotEmpty
//                               ? _userName[0].toUpperCase()
//                               : 'U',
//                           style: const TextStyle(
//                             color: kBrandGreen,
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
//                                 horizontal: 10, vertical: 4),
//                             decoration: BoxDecoration(
//                               color: Colors.white.withOpacity(0.15),
//                               borderRadius: BorderRadius.circular(12),
//                             ),
//                             child: Text(
//                               _userType == 'labour'
//                                   ? (context
//                                   .watch<LanguageProvider>()
//                                   .selectedLanguage ==
//                                   'en'
//                                   ? 'Worker'
//                                   : 'श्रमिक')
//                                   : (context
//                                   .watch<LanguageProvider>()
//                                   .selectedLanguage ==
//                                   'en'
//                                   ? 'Farmer'
//                                   : 'किसान'),
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
//                             style: const TextStyle(
//                                 fontWeight: FontWeight.bold,
//                                 color: Color(0xFF1F2937)),
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
//                     _buildDrawerTile(
//                       icon: Icons.search,
//                       title: FutureBuilder<String>(
//                         future: translateText('Search'),
//                         builder: (context, snapshot) {
//                           return Text(
//                             snapshot.data ?? 'Search',
//                             style: const TextStyle(
//                                 fontWeight: FontWeight.bold,
//                                 color: Color(0xFF1F2937)),
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
//                     _buildDrawerTile(
//                       icon: Icons.notifications,
//                       title: FutureBuilder<String>(
//                         future: translateText('Notifications'),
//                         builder: (context, snapshot) {
//                           return Row(
//                             children: [
//                               Text(
//                                 snapshot.data ?? 'Notifications',
//                                 style: const TextStyle(
//                                     fontWeight: FontWeight.bold,
//                                     color: Color(0xFF1F2937)),
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
//                     _buildDrawerTile(
//                       icon: Icons.language,
//                       title: FutureBuilder<String>(
//                         future: translateText(' Select Language'),
//                         builder: (context, snapshot) {
//                           return Text(
//                             snapshot.data ?? 'Language',
//                             style: const TextStyle(
//                                 fontWeight: FontWeight.bold,
//                                 color: Color(0xFF1F2937)),
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
//                     _buildDrawerTile(
//                       icon: Icons.notes,
//                       title: FutureBuilder<String>(
//                         future: translateText('Projects'),
//                         builder: (context, snapshot) {
//                           return Text(
//                             snapshot.data ?? 'Projects',
//                             style: const TextStyle(
//                                 fontWeight: FontWeight.bold,
//                                 color: Color(0xFF1F2937)),
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
//                     _buildDrawerTile(
//                       icon: Icons.account_balance_wallet,
//                       title: FutureBuilder<String>(
//                         future: translateText('Wallet'),
//                         builder: (context, snapshot) {
//                           final walletTitle = snapshot.data ?? 'Wallet';
//                           return Text(
//                             walletTitle,
//                             style: const TextStyle(
//                                 fontWeight: FontWeight.bold,
//                                 color: Color(0xFF1F2937)),
//                           );
//                         },
//                       ),
//                       onTap: () {
//                         Navigator.pop(context);
//                         WalletHelper.showCoinShop(context,
//                             onCoinsAdded: (newBalance) {
//                               setState(() => _walletCoins = newBalance);
//                             });
//                       },
//                     ),
//                     _buildDrawerTile(
//                       icon: Icons.person,
//                       title: FutureBuilder<String>(
//                         future: translateText('Profile'),
//                         builder: (context, snapshot) {
//                           return Text(
//                             snapshot.data ?? 'Profile',
//                             style: const TextStyle(
//                                 fontWeight: FontWeight.bold,
//                                 color: Color(0xFF1F2937)),
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
//                     const Divider(
//                         color: kBorderColor,
//                         height: 24,
//                         thickness: 1),
//                     _buildDrawerTile(
//                       icon: Icons.logout,
//                       isLogout: true,
//                       title: FutureBuilder<String>(
//                         future: translateText('Logout'),
//                         builder: (context, snapshot) {
//                           return Text(
//                             snapshot.data ?? 'Logout',
//                             style: const TextStyle(
//                                 fontWeight: FontWeight.bold,
//                                 color: Color(0xFF1F2937)),
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
//         body: SafeArea(
//           child: _pages[_currentIndex],
//         ),
//         bottomNavigationBar: Container(
//           decoration: BoxDecoration(
//             color: kBrandGreen,
//             borderRadius: const BorderRadius.only(
//               topLeft: Radius.circular(28),
//               topRight: Radius.circular(28),
//             ),
//             boxShadow: [
//               BoxShadow(
//                 color: kBrandGreen.withOpacity(0.2),
//                 blurRadius: 10,
//                 offset: const Offset(0, -4),
//               ),
//             ],
//           ),
//           child: ClipRRect(
//             borderRadius: const BorderRadius.only(
//               topLeft: Radius.circular(28),
//               topRight: Radius.circular(28),
//             ),
//             child: BottomNavigationBar(
//               backgroundColor: Colors.transparent,
//               currentIndex: _currentIndex,
//               selectedItemColor: Colors.white,
//               unselectedItemColor: Colors.white70,
//               selectedLabelStyle: const TextStyle(
//                 fontSize: 12,
//                 color: Colors.white,
//                 fontWeight: FontWeight.bold,
//               ),
//               unselectedLabelStyle: const TextStyle(
//                 fontSize: 12,
//                 color: Colors.white70,
//               ),
//               showUnselectedLabels: false,
//               elevation: 0,
//               type: BottomNavigationBarType.fixed,
//               items: [
//                 BottomNavigationBarItem(
//                     icon: const Icon(Icons.home),
//                     label: AppLocalizations.of(context)!.homepage),
//                 BottomNavigationBarItem(
//                     icon: const Icon(Icons.search),
//                     label: AppLocalizations.of(context)!.nearbylabours),
//                 BottomNavigationBarItem(
//                     icon: const Icon(Icons.person),
//                     label: AppLocalizations.of(context)!.yourprojects),
//               ],
//               onTap: (index) {
//                 setState(() {
//                   _currentIndex = index;
//                 });
//                 final pages = ['CombinedPage', 'LabourPage', 'ProjectPage'];
//                 if (index >= 0 && index < pages.length) {
//                   ApiLogger.logScreenOpened(pages[index]);
//                 }
//               },
//             ),
//           ),
//         ),
//         floatingActionButton: FloatingActionButton.extended(
//           onPressed: () {
//             Navigator.push(
//               context,
//               MaterialPageRoute(
//                 builder: (context) => AddProjectForm(),
//               ),
//             );
//           },
//           backgroundColor: kBrandGreen,
//           elevation: 4,
//           label: Text(
//             AppLocalizations.of(context)!.addProject,
//             style: const TextStyle(
//               color: Colors.white,
//               fontWeight: FontWeight.w700,
//               fontSize: 14,
//             ),
//           ),
//           icon: const Icon(Icons.add, color: Colors.white, size: 20),
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
//         style: TextStyle(fontSize: 24, color: kBrandGreen),
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
//         style: TextStyle(fontSize: 24, color: kBrandGreen),
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
// class _CombinedPageState extends State<CombinedPage>
//     with WidgetsBindingObserver {
//   static String _cachedCity = '';
//   static String _cachedState = '';
//   static String _cachedError = '';
//
//   final FlutterSecureStorage _secureStorage = FlutterSecureStorage();
//   final TextEditingController _projectSearchController =
//   TextEditingController();
//   final TextEditingController _labourSearchController = TextEditingController();
//   late Future<List<JobType>> _jobTypes;
//
//   List<dynamic> projects = [];
//   List<dynamic> filteredProjects = [];
//   List<dynamic> labours = [];
//   bool isLoading = false;
//   int _currentIndex = 0;
//   String _selectedLanguage = 'en';
//   int _coinCharge = 5;
//
//   Future<void> _loadCoinCharge() async {
//     int charge = await WalletHelper.getCoinCharge();
//     if (mounted) {
//       setState(() {
//         _coinCharge = charge;
//       });
//     }
//   }
//
//   IconData _getCategoryIcon(String jobname) {
//     final name = jobname.toLowerCase();
//     if (name.contains('crop') || name.contains('farm') || name.contains('कृषि') || name.contains('फसल')) {
//       return Icons.grass;
//     } else if (name.contains('cow') || name.contains('animal') || name.contains('dairy') || name.contains('husbandry') || name.contains('पशु') || name.contains('गाय')) {
//       return Icons.pets;
//     } else if (name.contains('tractor') || name.contains('driver') || name.contains('ट्रैक्टर')) {
//       return Icons.agriculture;
//     } else if (name.contains('box') || name.contains('pack') || name.contains('warehouse') || name.contains('logistics') || name.contains('डिब्बा') || name.contains('पैकिंग')) {
//       return Icons.inventory_2;
//     }
//     return Icons.category;
//   }
//
//   Future<void> loadLanguage() async {
//     String? language = await _secureStorage.read(key: 'selectedLanguage');
//     _selectedLanguage = language ?? 'en';
//   }
//
//   Map<String, Map<String, String>> _cachedTranslations = {};
//   Map<String, Map<String, String>> translations =
//       Constants.AppConstants.translations;
//   final GoogleTranslator _translator = GoogleTranslator();
//   late stt.SpeechToText _speech;
//   late PageController _pageController;
//   late Timer _timer;
//
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
//     _pageController = PageController();
//     _jobTypes = fetchJobTypes();
//     fetchLabours();
//     _fetchCurrentLocation();
//     _loadCoinCharge();
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
//         WidgetsBinding.instance.addPostFrameCallback((_) {
//           if (mounted) {
//             final locProv =
//             Provider.of<LocationProvider>(context, listen: false);
//             if (_cachedError.isNotEmpty) {
//               locProv.setError(_cachedError);
//             } else {
//               locProv.setLocation(city: _currentCity, state: _currentState);
//             }
//           }
//         });
//       }
//       return;
//     }
//
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       if (mounted) {
//         Provider.of<LocationProvider>(context, listen: false).setLoading(true);
//       }
//     });
//
//     try {
//       bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
//       if (!serviceEnabled) {
//         if (mounted) {
//           setState(() {
//             _isLoadingLocation = false;
//             _locationError = 'Location services are disabled';
//           });
//           WidgetsBinding.instance.addPostFrameCallback((_) {
//             if (mounted) {
//               Provider.of<LocationProvider>(context, listen: false)
//                   .setError('Location services are disabled');
//             }
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
//             WidgetsBinding.instance.addPostFrameCallback((_) {
//               if (mounted) {
//                 Provider.of<LocationProvider>(context, listen: false)
//                     .setError('Location permission denied');
//               }
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
//           WidgetsBinding.instance.addPostFrameCallback((_) {
//             if (mounted) {
//               Provider.of<LocationProvider>(context, listen: false)
//                   .setError('Location permission permanently denied');
//             }
//           });
//         }
//         return;
//       }
//
//       Position position = await Geolocator.getCurrentPosition(
//         desiredAccuracy: LocationAccuracy.high,
//       );
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
//         WidgetsBinding.instance.addPostFrameCallback((_) {
//           if (mounted) {
//             Provider.of<LocationProvider>(context, listen: false)
//                 .setLocation(city: _currentCity, state: _currentState);
//           }
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
//         WidgetsBinding.instance.addPostFrameCallback((_) {
//           if (mounted) {
//             Provider.of<LocationProvider>(context, listen: false)
//                 .setError(_cachedError);
//           }
//         });
//       }
//     }
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
//   void _startAutoScroll() {
//     Timer.periodic(Duration(seconds: 3), (Timer timer) {
//       if (_pageController.hasClients) {
//         _currentIndex = (_currentIndex + 1) % 1;
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
//     final language =
//         Provider.of<LanguageProvider>(context, listen: false).selectedLanguage;
//     String localeId = language == 'en' ? 'en_US' : 'hi_IN';
//     bool available = await _speech.initialize();
//     if (available) {
//       setState(() => _isListening = true);
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
//     }
//   }
//
//   void _stopListening() {
//     setState(() => _isListening = false);
//     _speech.stop();
//   }
//
//   Future<List<JobType>> fetchJobTypes() async {
//     final response = await http
//         .post(Uri.parse('${Constants.AppConstants.apiUrl}farmer/jobtype'));
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
//       DateTime dateTime = DateTime.parse(dateString);
//       return DateFormat('dd-MM-yyyy').format(dateTime);
//     } catch (e) {
//       return dateString;
//     }
//   }
//
//   Future<void> fetchLabours({String? searchQuery}) async {
//     setState(() {
//       isLoading = true;
//     });
//     String? userId = await _secureStorage.read(key: 'id');
//     if (!mounted) return;
//     if (userId == null) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('User ID not found in secure storage')),
//       );
//       setState(() => isLoading = false);
//       return;
//     }
//     final apiUrl = (searchQuery != null && searchQuery.isNotEmpty)
//         ? '${Constants.AppConstants.apiUrl}farmer/searchnearbylabours'
//         : '${Constants.AppConstants.apiUrl}farmer/nearbylabours';
//     final Map<String, dynamic> requestBody = (searchQuery != null &&
//         searchQuery.isNotEmpty)
//         ? {'search': searchQuery}
//         : {'id': userId};
//     try {
//       final response = await http.post(
//         Uri.parse(apiUrl),
//         headers: {'Content-Type': 'application/json'},
//         body: jsonEncode(requestBody),
//       );
//       if (!mounted) return;
//       if (response.statusCode == 200) {
//         final responseData = jsonDecode(response.body);
//         if (responseData['success'] == true) {
//           setState(() {
//             labours = responseData['data'];
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
//       if (!mounted) return;
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Error: $e')),
//       );
//     } finally {
//       if (mounted) {
//         setState(() => isLoading = false);
//       }
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
//
//   Future<void> fetchProjects() async {
//     final String apiUrl = '${Constants.AppConstants.apiUrl}farmer/getprojects';
//     String? userId = await _secureStorage.read(key: 'id');
//     if (!mounted) return;
//     if (userId == null) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('User ID not found in secure storage')),
//       );
//       return;
//     }
//     final Map<String, dynamic> requestBody = {'id': userId};
//     try {
//       final response = await http.post(
//         Uri.parse(apiUrl),
//         headers: {'Content-Type': 'application/json'},
//         body: jsonEncode(requestBody),
//       );
//       if (!mounted) return;
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
//           _currentIndex = (_currentIndex + 1) % itemCount;
//         });
//         _pageController.animateToPage(
//           _currentIndex,
//           duration: Duration(seconds: 1),
//           curve: Curves.easeInOut,
//         );
//       }
//     });
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
//           setState(() {
//             _jobTypes = fetchJobTypes();
//           });
//           await fetchLabours();
//           await _fetchCurrentLocation();
//           await _loadCoinCharge();
//         },
//         child: Scaffold(
//           body: Container(
//             width: double.infinity,
//             height: double.infinity,
//             decoration: BoxDecoration(color: kSurfaceBackground),
//             child: SingleChildScrollView(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Container(
//                     width: double.infinity,
//                     height: 200,
//                     margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//                     decoration: BoxDecoration(
//                       borderRadius: BorderRadius.circular(20),
//                       boxShadow: [
//                         BoxShadow(
//                             color: kBrandGreen.withOpacity(0.1),
//                             blurRadius: 10,
//                             offset: const Offset(0, 4)
//                         )
//                       ],
//                     ),
//                     child: ClipRRect(
//                       borderRadius: BorderRadius.circular(20),
//                       child: CarouselSlider.builder(
//                         itemCount: imageUrls.length,
//                         itemBuilder:
//                             (BuildContext context, int index, int realIndex) {
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
//                   Padding(
//                     padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
//                     child: _buildSectionTitle(
//                       translate('Select category for job/Work',
//                           'नौकरी/कार्य के लिए श्रेणी चुनें'),
//                     ),
//                   ),
//                   Padding(
//                     padding: const EdgeInsets.symmetric(vertical: 8.0),
//                     child: FutureBuilder<List<JobType>>(
//                       future: _jobTypes,
//                       builder: (context, snapshot) {
//                         if (snapshot.connectionState ==
//                             ConnectionState.waiting) {
//                           return const Center(
//                               child: CircularProgressIndicator());
//                         } else if (snapshot.hasError) {
//                           return const Center(
//                               child: Text('Error fetching job types'));
//                         } else if (!snapshot.hasData ||
//                             snapshot.data!.isEmpty) {
//                           return const Center(
//                               child: Text('No data available'));
//                         } else {
//                           List<JobType> jobTypes = snapshot.data!;
//                           _startAutoScrolling(jobTypes.length);
//                           return Container(
//                             height: 128,
//                             child: ListView.builder(
//                               scrollDirection: Axis.horizontal,
//                               padding:
//                               const EdgeInsets.symmetric(horizontal: 16),
//                               itemCount: jobTypes.length,
//                               itemBuilder: (context, index) {
//                                 JobType job = jobTypes[index];
//                                 return InkWell(
//                                   onTap: () {
//                                     Navigator.push(
//                                       context,
//                                       MaterialPageRoute(
//                                         builder: (context) => AddProjectForm(
//                                           projectType: job.jobname,
//                                         ),
//                                       ),
//                                     );
//                                   },
//                                   child: SizedBox(
//                                     width: 90,
//                                     child: Column(
//                                       children: [
//                                         Container(
//                                           width: 70,
//                                           height: 70,
//                                           margin: const EdgeInsets.symmetric(
//                                               horizontal: 4, vertical: 2),
//                                           decoration: BoxDecoration(
//                                             color: kBrandGreenTint,
//                                             shape: BoxShape.circle,
//                                           ),
//                                           child: Center(
//                                             child: CachedNetworkImage(
//                                               imageUrl:
//                                               '${Constants.AppConstants.folderUrl}storage/upload/jobtypes/${job.image}',
//                                               width: 42,
//                                               height: 42,
//                                               placeholder: (context, url) =>
//                                               const Center(
//                                                 child: SizedBox(
//                                                   width: 16,
//                                                   height: 16,
//                                                   child:
//                                                   CircularProgressIndicator(
//                                                       strokeWidth: 2),
//                                                 ),
//                                               ),
//                                               errorWidget:
//                                                   (context, url, error) =>
//                                                   Icon(
//                                                     _getCategoryIcon(job.jobname),
//                                                     color: kBrandGreen,
//                                                     size: 32,
//                                                   ),
//                                             ),
//                                           ),
//                                         ),
//                                         Padding(
//                                           padding: const EdgeInsets.only(
//                                               left: 4.0,
//                                               right: 4.0,
//                                               top: 4.0),
//                                           child: Text(
//                                             translateText(job.jobname),
//                                             style: const TextStyle(
//                                               fontSize: 12,
//                                               color: kBrandBrown,
//                                               fontWeight: FontWeight.bold,
//                                             ),
//                                             textAlign: TextAlign.center,
//                                             maxLines: 2,
//                                             overflow: TextOverflow.ellipsis,
//                                           ),
//                                         ),
//                                       ],
//                                     ),
//                                   ),
//                                 );
//                               },
//                             ),
//                           );
//                         }
//                       },
//                     ),
//                   ),
//                   Padding(
//                     padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
//                     child: Container(
//                       decoration: BoxDecoration(
//                         color: Colors.white,
//                         borderRadius: BorderRadius.circular(16),
//                         boxShadow: [
//                           BoxShadow(
//                             color: kBrandGreen.withOpacity(0.05),
//                             blurRadius: 10,
//                             offset: const Offset(0, 2),
//                           )
//                         ],
//                       ),
//                       child: TextField(
//                         controller: _labourSearchController,
//                         onChanged: (value) {
//                           fetchLabours(searchQuery: value);
//                         },
//                         style: const TextStyle(color: Color(0xFF1F2937)),
//                         decoration: InputDecoration(
//                           prefixIcon: const Icon(
//                             Icons.search,
//                             color: kBrandGreen,
//                             size: 20,
//                           ),
//                           suffixIcon: MicIconButton(
//                               controller: _labourSearchController),
//                           hintText: AppLocalizations.of(context)!.searchlabour,
//                           hintStyle: const TextStyle(
//                               color: kTextGrey,
//                               fontSize: 14
//                           ),
//                           fillColor: Colors.transparent,
//                           filled: true,
//                           contentPadding: const EdgeInsets.symmetric(
//                               horizontal: 16, vertical: 14),
//                           border: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(16),
//                             borderSide: const BorderSide(
//                                 color: kBorderColor),
//                           ),
//                           enabledBorder: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(16),
//                             borderSide: const BorderSide(
//                                 color: kBorderColor),
//                           ),
//                           focusedBorder: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(16),
//                             borderSide: const BorderSide(
//                                 color: kBrandGreen, width: 1.5),
//                           ),
//                         ),
//                       ),
//                     ),
//                   ),
//                   const Divider(color: kBorderColor),
//                   labours.isEmpty
//                       ? Center(
//                     child: Text(
//                       translate('Looking for nearby workers',
//                           'आसपास के मजदूरों की तलाश की जा रही है'),
//                       style: const TextStyle(
//                         fontSize: 18,
//                         fontWeight: FontWeight.w500,
//                         color: kBrandBrown,
//                       ),
//                     ),
//                   )
//                       : Padding(
//                     padding: const EdgeInsets.all(8.0),
//                     child: ListView.builder(
//                       shrinkWrap: true,
//                       physics: const NeverScrollableScrollPhysics(),
//                       itemCount: labours.length,
//                       itemBuilder: (context, index) {
//                         final labour = labours[index];
//
//                         String labourType = labour['type'] == '0'
//                             ? translateText('Individual')
//                             : translateText('Agency');
//
//                         String subtitle = labour['skills']?.toString() ??
//                             '';
//                         if (subtitle.isEmpty) {
//                           subtitle = labour['aboutme']?.toString() ?? '';
//                         }
//
//                         List<String> skillTags = [];
//                         if (labour['skills'] != null &&
//                             labour['skills'].toString().isNotEmpty) {
//                           skillTags = labour['skills']
//                               .toString()
//                               .split(',')
//                               .map((s) => s.trim())
//                               .where((s) => s.isNotEmpty)
//                               .toList();
//                         }
//                         if (skillTags.isEmpty &&
//                             labour['education'] != null &&
//                             labour['education'].toString().isNotEmpty) {
//                           skillTags.add(labour['education'].toString());
//                         }
//                         if (skillTags.length > 2) {
//                           skillTags = skillTags.sublist(0, 2);
//                         }
//
//                         return GestureDetector(
//                           onTap: () {
//                             Navigator.push(
//                               context,
//                               MaterialPageRoute(
//                                 builder: (context) => LabourDetailsPage(
//                                   labour: labour,
//                                 ),
//                               ),
//                             );
//                           },
//                           child: Container(
//                             margin: const EdgeInsets.symmetric(
//                                 horizontal: 16, vertical: 6),
//                             decoration: BoxDecoration(
//                               color: Colors.white,
//                               borderRadius: BorderRadius.circular(16),
//                               border: Border.all(
//                                   color: kBrandGreen.withOpacity(0.1),
//                                   width: 1.0),
//                               boxShadow: [
//                                 BoxShadow(
//                                     color: kBrandGreen.withOpacity(0.05),
//                                     blurRadius: 8,
//                                     offset: const Offset(0, 2)
//                                 )
//                               ],
//                             ),
//                             child: Padding(
//                               padding: const EdgeInsets.all(12.0),
//                               child: Row(
//                                 crossAxisAlignment:
//                                 CrossAxisAlignment.start,
//                                 children: [
//                                   Stack(
//                                     children: [
//                                       Container(
//                                         width: 54,
//                                         height: 54,
//                                         decoration: BoxDecoration(
//                                           color: kBrandGreenTint,
//                                           borderRadius:
//                                           BorderRadius.circular(27),
//                                           border: Border.all(
//                                               color: kBrandGreen.withOpacity(0.2),
//                                               width: 1.5),
//                                         ),
//                                         child: ClipRRect(
//                                           borderRadius:
//                                           BorderRadius.circular(27),
//                                           child: (labour[
//                                           'profile_image'] !=
//                                               null &&
//                                               labour['profile_image']
//                                                   .toString()
//                                                   .isNotEmpty)
//                                               ? Image.network(
//                                             labour['profile_image']
//                                                 .toString(),
//                                             fit: BoxFit.cover,
//                                             errorBuilder: (context,
//                                                 error,
//                                                 stackTrace) {
//                                               return const Icon(
//                                                   Icons.person,
//                                                   color: kBrandGreen,
//                                                   size: 28);
//                                             },
//                                           )
//                                               : const Icon(Icons.person,
//                                               color: kBrandGreen,
//                                               size: 28),
//                                         ),
//                                       ),
//                                       Positioned(
//                                         bottom: 0,
//                                         right: 0,
//                                         child: Container(
//                                           padding:
//                                           const EdgeInsets.all(1),
//                                           decoration: const BoxDecoration(
//                                             color: Colors.white,
//                                             shape: BoxShape.circle,
//                                           ),
//                                           child: Container(
//                                             padding:
//                                             const EdgeInsets.all(2),
//                                             decoration: const BoxDecoration(
//                                               color: kBrandGreen,
//                                               shape: BoxShape.circle,
//                                             ),
//                                             child: const Icon(
//                                               Icons.check,
//                                               color: Colors.white,
//                                               size: 8,
//                                             ),
//                                           ),
//                                         ),
//                                       ),
//                                     ],
//                                   ),
//                                   const SizedBox(width: 12),
//                                   Expanded(
//                                     child: Column(
//                                       crossAxisAlignment:
//                                       CrossAxisAlignment.start,
//                                       children: [
//                                         Row(
//                                           crossAxisAlignment:
//                                           CrossAxisAlignment.start,
//                                           children: [
//                                             Expanded(
//                                               child: Column(
//                                                 crossAxisAlignment:
//                                                 CrossAxisAlignment
//                                                     .start,
//                                                 children: [
//                                                   Text(
//                                                     translateText(labour[
//                                                     'name'] ??
//                                                         'Unknown'),
//                                                     style: const TextStyle(
//                                                       color: kBrandGreen,
//                                                       fontWeight:
//                                                       FontWeight.bold,
//                                                       fontSize: 15,
//                                                     ),
//                                                     overflow: TextOverflow
//                                                         .ellipsis,
//                                                   ),
//                                                   const SizedBox(
//                                                       height: 2),
//                                                   Container(
//                                                     padding: const EdgeInsets
//                                                         .symmetric(
//                                                         horizontal: 6,
//                                                         vertical: 2),
//                                                     decoration:
//                                                     BoxDecoration(
//                                                       color: kBrandGreenTint,
//                                                       borderRadius:
//                                                       BorderRadius
//                                                           .circular(4),
//                                                     ),
//                                                     child: Text(
//                                                       labourType,
//                                                       style: const TextStyle(
//                                                         fontSize: 10,
//                                                         color: kBrandGreen,
//                                                         fontWeight:
//                                                         FontWeight
//                                                             .bold,
//                                                       ),
//                                                     ),
//                                                   ),
//                                                 ],
//                                               ),
//                                             ),
//                                             if (skillTags.isNotEmpty)
//                                               Flexible(
//                                                 child: Wrap(
//                                                   alignment: WrapAlignment
//                                                       .end,
//                                                   spacing: 4,
//                                                   runSpacing: 2,
//                                                   children: skillTags
//                                                       .map((tag) {
//                                                     return Container(
//                                                       padding: const EdgeInsets
//                                                           .symmetric(
//                                                           horizontal: 6,
//                                                           vertical: 3),
//                                                       decoration:
//                                                       BoxDecoration(
//                                                         color: kBrandBrownTint,
//                                                         borderRadius:
//                                                         BorderRadius
//                                                             .circular(
//                                                             6),
//                                                         border: Border
//                                                             .all(
//                                                             color: kBrandBrown.withOpacity(0.2),
//                                                             width: 0.5),
//                                                       ),
//                                                       child: Text(
//                                                         translateText(tag),
//                                                         style: const TextStyle(
//                                                           color: kBrandBrown,
//                                                           fontSize: 9,
//                                                           fontWeight:
//                                                           FontWeight
//                                                               .w600,
//                                                         ),
//                                                       ),
//                                                     );
//                                                   }).toList(),
//                                                 ),
//                                               ),
//                                           ],
//                                         ),
//                                         const SizedBox(height: 4),
//                                         Row(
//                                           children: [
//                                             const Icon(
//                                               Icons
//                                                   .location_on_outlined,
//                                               size: 14,
//                                               color: kTextGrey,
//                                             ),
//                                             const SizedBox(width: 4),
//                                             Expanded(
//                                               child: Text(
//                                                 '${translateText(labour['city'] ?? 'Unknown City')}, ${translateText(labour['state'] ?? '')}',
//                                                 style: const TextStyle(
//                                                   color: kTextGrey,
//                                                   fontSize: 12,
//                                                 ),
//                                                 overflow: TextOverflow
//                                                     .ellipsis,
//                                               ),
//                                             ),
//                                           ],
//                                         ),
//                                         if (subtitle.isNotEmpty) ...[
//                                           const SizedBox(height: 4),
//                                           Row(
//                                             children: [
//                                               const Icon(
//                                                 Icons.work_outline,
//                                                 size: 14,
//                                                 color: kBrandGreen,
//                                               ),
//                                               const SizedBox(width: 4),
//                                               Expanded(
//                                                 child: Text(
//                                                   subtitle.length > 40
//                                                       ? '${subtitle.substring(0, 40)}...'
//                                                       : subtitle,
//                                                   style: const TextStyle(
//                                                     color: kTextGrey,
//                                                     fontSize: 11,
//                                                   ),
//                                                   overflow: TextOverflow
//                                                       .ellipsis,
//                                                 ),
//                                               ),
//                                             ],
//                                           ),
//                                         ],
//                                       ],
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ),
//                           ),
//                         );
//                       },
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildSectionTitle(String title) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 8.0),
//       child: Text(
//         title,
//         style: const TextStyle(
//           fontSize: 16,
//           fontWeight: FontWeight.w600,
//           color: kBrandGreen,
//         ),
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
//                     SpeakerIconButton(
//                         text: project['description'] ?? 'No description'),
//                   ],
//                 ),
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
//   Map<String, Map<String, String>> translations =
//       Constants.AppConstants.translations;
//   final GoogleTranslator _translator = GoogleTranslator();
//   final _secureStorage = const FlutterSecureStorage();
//
//   @override
//   void initState() {
//     super.initState();
//     loadLanguage();
//   }
//
//   String _selectedLanguage = 'en';
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
//         color: kBrandGreenTint,
//         borderRadius: BorderRadius.circular(15),
//         boxShadow: [
//           BoxShadow(
//             color: kBrandGreen.withOpacity(0.2),
//             spreadRadius: 2,
//             blurRadius: 5,
//           ),
//         ],
//       ),
//       child: ListTile(
//         leading: CircleAvatar(
//           backgroundColor: kBrandGreen,
//           child: Text(
//             translateText(widget.labour['name'][0].toUpperCase()),
//             style: const TextStyle(color: Colors.white),
//           ),
//         ),
//         title: Text(
//           translateText(widget.labour['name'] ?? 'Unknown'),
//           style: const TextStyle(fontWeight: FontWeight.bold, color: kBrandGreen),
//         ),
//         subtitle: Text(
//           '${translateText(widget.labour['city'] ?? 'Unknown City')}, ${translateText(widget.labour['state'] ?? 'Unknown State')}',
//           style: const TextStyle(color: kTextGrey),
//         ),
//         trailing: Column(
//           children: [
//             Text(
//               widget.labour['type'] == '0'
//                   ? translateText('Individual')
//                   : translateText('Agency'),
//               style: const TextStyle(color: kBrandBrown, fontWeight: FontWeight.bold),
//             ),
//             if (widget.labour['type'] == '1')
//               Text(
//                 '${translateText(widget.labour['agency_name'])}',
//                 style: const TextStyle(color: kTextGrey, fontSize: 10),
//               ),
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
//   List<dynamic> filteredProjects = [];
//   bool isLoading = true;
//   final TextEditingController _searchController = TextEditingController();
//   String _selectedLanguage = 'en';
//
//   Map<String, Map<String, String>> _cachedTranslations = {};
//   Map<String, Map<String, String>> translations =
//       Constants.AppConstants.translations;
//   final GoogleTranslator _translator = GoogleTranslator();
//   late stt.SpeechToText _speech;
//
//   @override
//   void initState() {
//     super.initState();
//     _speech = stt.SpeechToText();
//     fetchProjects();
//     loadLanguage();
//   }
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
//   Future<void> fetchProjects() async {
//     final String apiUrl = '${Constants.AppConstants.apiUrl}farmer/getprojects';
//     String? userId = await _secureStorage.read(key: 'id');
//     if (userId == null) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('User ID not found in secure storage')),
//       );
//       return;
//     }
//     final Map<String, dynamic> requestBody = {'id': userId};
//     try {
//       final response = await http.post(
//         Uri.parse(apiUrl),
//         headers: {'Content-Type': 'application/json'},
//         body: jsonEncode(requestBody),
//       );
//       if (response.statusCode == 200) {
//         setState(() {
//           projects = json.decode(response.body)['data'];
//           filteredProjects = projects;
//           isLoading = false;
//         });
//       } else {
//         setState(() => isLoading = false);
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('No Projects Created Yet')),
//         );
//       }
//     } catch (e) {
//       setState(() => isLoading = false);
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
//     final language =
//         Provider.of<LanguageProvider>(context, listen: false).selectedLanguage;
//     String localeId = language == 'en' ? 'en_US' : 'hi_IN';
//     bool available = await _speech.initialize();
//     if (available) {
//       setState(() => _isListening = true);
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
//     }
//   }
//
//   void _stopListening() {
//     setState(() => _isListening = false);
//     _speech.stop();
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
//   Widget _buildPremiumChip({
//     required IconData icon,
//     required String label,
//   }) {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
//       decoration: BoxDecoration(
//         color: kBrandBrownTint,
//         borderRadius: BorderRadius.circular(10),
//         border: Border.all(color: kBrandBrown.withOpacity(0.2), width: 0.5),
//       ),
//       child: Row(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Icon(icon, size: 13, color: kBrandBrown),
//           const SizedBox(width: 4),
//           Text(
//             label,
//             style: const TextStyle(
//               fontSize: 11,
//               fontWeight: FontWeight.w700,
//               color: kBrandBrown,
//               letterSpacing: 0.3,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildProjectStatusBadge(Map<String, dynamic> project) {
//     final status = project['status']?.toString() ?? '1';
//     final labourId = project['labourId']?.toString() ?? '';
//     final bool isAssigned = labourId.trim().isNotEmpty;
//
//     String label;
//     Color bgColor;
//     Color textColor;
//     IconData icon;
//
//     switch (status) {
//       case '1':
//         if (isAssigned) {
//           label = translateText('Assigned');
//           bgColor = kBrandGreenTint;
//           textColor = kBrandGreen;
//           icon = Icons.assignment_ind_outlined;
//         } else {
//           label = translateText('Open');
//           bgColor = kBrandGreenTint;
//           textColor = kBrandGreen;
//           icon = Icons.check_circle_outline;
//         }
//         break;
//       case '2':
//         label = translateText('Work Started');
//         bgColor = kBrandBrownTint;
//         textColor = kBrandBrown;
//         icon = Icons.hourglass_top_outlined;
//         break;
//       case '3':
//         label = translateText('Completed');
//         bgColor = kBrandGreenTint;
//         textColor = kBrandGreen;
//         icon = Icons.check_circle_outline;
//         break;
//       case '4':
//         label = translateText('Cancelled');
//         bgColor = const Color(0xFFFEF2F2);
//         textColor = const Color(0xFF991B1B);
//         icon = Icons.cancel_outlined;
//         break;
//       default:
//         label = translateText('Unknown');
//         bgColor = kSurfaceBackground;
//         textColor = kTextGrey;
//         icon = Icons.help_outline;
//     }
//
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//       decoration: BoxDecoration(
//         color: bgColor,
//         borderRadius: BorderRadius.circular(20),
//         border: Border.all(color: textColor.withOpacity(0.2), width: 0.8),
//       ),
//       child: Row(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Icon(icon, size: 11, color: textColor),
//           const SizedBox(width: 4),
//           Text(
//             label,
//             style: TextStyle(
//               fontSize: 10,
//               fontWeight: FontWeight.bold,
//               color: textColor,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   String _getDurationLabel(dynamic days) {
//     if (days == null) return translateText('N/A');
//     String daysStr = days.toString();
//     int? daysInt = int.tryParse(daysStr);
//     if (daysInt != null && daysInt > 0) {
//       return '$daysInt ${translateText('days')}';
//     }
//     return translateText(daysStr);
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final language =
//         Provider.of<LanguageProvider>(context, listen: false).selectedLanguage;
//     String translate(String enText, String hiText) {
//       return language == 'en' ? enText : hiText;
//     }
//
//     return WillPopScope(
//       onWillPop: () async {
//         SystemNavigator.pop();
//         return false;
//       },
//       child: Scaffold(
//         body: Container(
//           color: kSurfaceBackground,
//           child: SafeArea(
//             child: Column(
//               children: [
//                 Padding(
//                   padding: const EdgeInsets.all(16.0),
//                   child: TextField(
//                     controller: _searchController,
//                     onChanged: filterProjects,
//                     decoration: InputDecoration(
//                       prefixIcon: const Icon(Icons.search,
//                           color: kBrandGreen),
//                       hintText: AppLocalizations.of(context)!.searchlabour,
//                       fillColor: Colors.white,
//                       filled: true,
//                       border: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(15.0),
//                         borderSide:
//                         const BorderSide(color: kBorderColor),
//                       ),
//                       focusedBorder: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(15.0),
//                         borderSide: const BorderSide(
//                             color: kBrandGreen, width: 2),
//                       ),
//                       suffixIcon: MicIconButton(controller: _searchController),
//                     ),
//                   ),
//                 ),
//                 Expanded(
//                   child: isLoading
//                       ? const Center(child: CircularProgressIndicator())
//                       : filteredProjects.isEmpty
//                       ? Center(
//                     child: Text(
//                       AppLocalizations.of(context)!.noProjectsFound,
//                       style: const TextStyle(
//                         fontSize: 18,
//                         fontWeight: FontWeight.w500,
//                         color: kBrandBrown,
//                       ),
//                     ),
//                   )
//                       : ListView.builder(
//                     padding: const EdgeInsets.symmetric(
//                         horizontal: 16, vertical: 8),
//                     itemCount: filteredProjects.length,
//                     itemBuilder: (context, index) {
//                       final project = filteredProjects[index];
//                       String iconEmoji = '📋';
//                       String projectType =
//                           project['project_type'] ?? '';
//                       if (projectType.contains('Crop'))
//                         iconEmoji = '🌾';
//                       else if (projectType.contains('Live'))
//                         iconEmoji = '🐄';
//                       else if (projectType.contains('Mach'))
//                         iconEmoji = '🚜';
//                       else if (projectType.contains('Post'))
//                         iconEmoji = '📦';
//                       else if (projectType.contains('Manage'))
//                         iconEmoji = '📊';
//
//                       String durationLabel =
//                       _getDurationLabel(project['days']);
//                       String budgetFormatted = NumberFormat('#,##0')
//                           .format(project['budget'] ?? 0);
//                       int applicants = project['applicants'] ?? 0;
//
//                       return Container(
//                         margin: const EdgeInsets.only(bottom: 12),
//                         decoration: BoxDecoration(
//                           color: Colors.white,
//                           borderRadius: BorderRadius.circular(20),
//                           border: Border.all(
//                             color: kBrandGreen
//                                 .withOpacity(0.12),
//                             width: 1.2,
//                           ),
//                           boxShadow: [
//                             BoxShadow(
//                               color: kBrandGreen
//                                   .withOpacity(0.06),
//                               blurRadius: 20,
//                               offset: const Offset(0, 6),
//                               spreadRadius: 2,
//                             ),
//                           ],
//                         ),
//                         child: ClipRRect(
//                           borderRadius: BorderRadius.circular(20),
//                           child: Material(
//                             color: Colors.transparent,
//                             child: InkWell(
//                               onTap: () {
//                                 Navigator.push(
//                                   context,
//                                   MaterialPageRoute(
//                                     builder: (context) =>
//                                         ProjectDetails(
//                                           projectId: project['id']
//                                               .toString(),
//                                         ),
//                                   ),
//                                 );
//                               },
//                               splashColor: kBrandGreen
//                                   .withOpacity(0.1),
//                               highlightColor: kBrandGreen
//                                   .withOpacity(0.05),
//                               child: Padding(
//                                 padding:
//                                 const EdgeInsets.all(18.0),
//                                 child: Column(
//                                   crossAxisAlignment:
//                                   CrossAxisAlignment.start,
//                                   children: [
//                                     Row(
//                                       crossAxisAlignment:
//                                       CrossAxisAlignment.start,
//                                       children: [
//                                         Container(
//                                           width: 48,
//                                           height: 48,
//                                           decoration: BoxDecoration(
//                                             gradient:
//                                             LinearGradient(
//                                               begin: Alignment
//                                                   .topLeft,
//                                               end: Alignment
//                                                   .bottomRight,
//                                               colors: [
//                                                 kBrandGreenTint,
//                                                 kBrandGreen.withOpacity(0.05),
//                                               ],
//                                             ),
//                                             borderRadius:
//                                             BorderRadius.circular(
//                                                 14),
//                                           ),
//                                           child: Center(
//                                             child: Text(
//                                               iconEmoji,
//                                               style: const TextStyle(
//                                                   fontSize: 22),
//                                             ),
//                                           ),
//                                         ),
//                                         const SizedBox(width: 14),
//                                         Expanded(
//                                           child: Column(
//                                             crossAxisAlignment:
//                                             CrossAxisAlignment
//                                                 .start,
//                                             children: [
//                                               Text(
//                                                 translateText(project[
//                                                 'title']
//                                                     ?.toString() ??
//                                                     'No Title'),
//                                                 style: const TextStyle(
//                                                   fontSize: 16,
//                                                   fontWeight:
//                                                   FontWeight.w700,
//                                                   color: kBrandGreen,
//                                                   height: 1.3,
//                                                 ),
//                                                 maxLines: 2,
//                                                 overflow: TextOverflow
//                                                     .ellipsis,
//                                               ),
//                                               const SizedBox(
//                                                   height: 4),
//                                               Container(
//                                                 padding:
//                                                 const EdgeInsets
//                                                     .symmetric(
//                                                     horizontal:
//                                                     10,
//                                                     vertical: 4),
//                                                 decoration:
//                                                 BoxDecoration(
//                                                   color: kBrandGreenTint,
//                                                   borderRadius:
//                                                   BorderRadius
//                                                       .circular(
//                                                       20),
//                                                 ),
//                                                 child: Row(
//                                                   mainAxisSize:
//                                                   MainAxisSize
//                                                       .min,
//                                                   children: [
//                                                     const Text('🌾',
//                                                         style: TextStyle(
//                                                             fontSize:
//                                                             12)),
//                                                     const SizedBox(
//                                                         width: 4),
//                                                     Text(
//                                                       translateText(project[
//                                                       'project_type'] ??
//                                                           'N/A'),
//                                                       style: TextStyle(
//                                                         fontSize: 11,
//                                                         fontWeight:
//                                                         FontWeight
//                                                             .w600,
//                                                         color: kBrandGreen,
//                                                       ),
//                                                     ),
//                                                   ],
//                                                 ),
//                                               ),
//                                             ],
//                                           ),
//                                         ),
//                                         _buildProjectStatusBadge(
//                                             project),
//                                       ],
//                                     ),
//                                     const SizedBox(height: 12),
//                                     const Divider(
//                                         color: kBorderColor,
//                                         height: 1),
//                                     const SizedBox(height: 10),
//                                     Row(
//                                       children: [
//                                         const Icon(
//                                             Icons
//                                                 .location_on_outlined,
//                                             size: 14,
//                                             color: kTextGrey),
//                                         const SizedBox(width: 6),
//                                         Expanded(
//                                           child: Text(
//                                             "${translateText(project['city'] ?? 'N/A')}, ${translateText(project['state'] ?? 'N/A')}",
//                                             style: const TextStyle(
//                                               fontSize: 13,
//                                               fontWeight:
//                                               FontWeight.w500,
//                                               color: kTextGrey,
//                                             ),
//                                           ),
//                                         ),
//                                         if (applicants > 0)
//                                           Container(
//                                             padding:
//                                             const EdgeInsets
//                                                 .symmetric(
//                                                 horizontal: 8,
//                                                 vertical: 3),
//                                             decoration: BoxDecoration(
//                                               color: kBrandGreenTint,
//                                               borderRadius:
//                                               BorderRadius
//                                                   .circular(12),
//                                               border: Border.all(
//                                                   color: kBrandGreen.withOpacity(0.2),
//                                                   width: 0.5),
//                                             ),
//                                             child: Row(
//                                               mainAxisSize:
//                                               MainAxisSize.min,
//                                               children: [
//                                                 Icon(
//                                                     Icons
//                                                         .person_add_alt_1,
//                                                     size: 11,
//                                                     color: kBrandGreen),
//                                                 const SizedBox(
//                                                     width: 3),
//                                                 Text(
//                                                   '$applicants',
//                                                   style:
//                                                   const TextStyle(
//                                                     fontSize: 10,
//                                                     fontWeight:
//                                                     FontWeight
//                                                         .bold,
//                                                     color: kBrandGreen,
//                                                   ),
//                                                 ),
//                                               ],
//                                             ),
//                                           ),
//                                       ],
//                                     ),
//                                     const SizedBox(height: 12),
//                                     Row(
//                                       children: [
//                                         _buildPremiumChip(
//                                           icon: Icons
//                                               .people_outline,
//                                           label:
//                                           '${project['qty_labours'] ?? '0'} ${translate('Workers', 'मजदूर')}',
//                                         ),
//                                         const SizedBox(width: 8),
//                                         _buildPremiumChip(
//                                           icon:
//                                           Icons.currency_rupee,
//                                           label:
//                                           '$budgetFormatted',
//                                         ),
//                                         const SizedBox(width: 8),
//                                         _buildPremiumChip(
//                                           icon: Icons
//                                               .access_time_outlined,
//                                           label: durationLabel,
//                                         ),
//                                       ],
//                                     ),
//                                     const SizedBox(height: 16),
//                                     Row(
//                                       children: [
//                                         if (applicants > 0)
//                                           Expanded(
//                                             child: SizedBox(
//                                               height: 44,
//                                               child: ElevatedButton(
//                                                 onPressed: () {
//                                                   Navigator.push(
//                                                     context,
//                                                     MaterialPageRoute(
//                                                       builder: (context) =>
//                                                           ProjectApplicationsPage(
//                                                             projectId: project[
//                                                             'id']
//                                                                 .toString(),
//                                                           ),
//                                                     ),
//                                                   ).then((_) {
//                                                     fetchProjects();
//                                                   });
//                                                 },
//                                                 style: ElevatedButton
//                                                     .styleFrom(
//                                                   backgroundColor:
//                                                   kBrandBrown,
//                                                   foregroundColor:
//                                                   Colors.white,
//                                                   shape:
//                                                   RoundedRectangleBorder(
//                                                     borderRadius:
//                                                     BorderRadius
//                                                         .circular(
//                                                         10),
//                                                   ),
//                                                   padding:
//                                                   EdgeInsets.zero,
//                                                 ),
//                                                 child: FittedBox(
//                                                   fit: BoxFit
//                                                       .scaleDown,
//                                                   child: Text(
//                                                     AppLocalizations.of(
//                                                         context)!
//                                                         .viewApplications,
//                                                     style:
//                                                     const TextStyle(
//                                                       fontSize: 13,
//                                                       fontWeight:
//                                                       FontWeight
//                                                           .bold,
//                                                       color: Colors
//                                                           .white,
//                                                     ),
//                                                   ),
//                                                 ),
//                                               ),
//                                             ),
//                                           ),
//                                         if (applicants > 0)
//                                           const SizedBox(width: 8),
//                                         Expanded(
//                                           child: SizedBox(
//                                             height: 44,
//                                             child: ElevatedButton(
//                                               onPressed: () {
//                                                 Navigator.push(
//                                                   context,
//                                                   MaterialPageRoute(
//                                                     builder: (context) =>
//                                                         ProjectDetails(
//                                                           projectId: project[
//                                                           'id']
//                                                               .toString(),
//                                                         ),
//                                                   ),
//                                                 ).then((_) {
//                                                   fetchProjects();
//                                                 });
//                                               },
//                                               style: ElevatedButton
//                                                   .styleFrom(
//                                                 backgroundColor:
//                                                 kBrandBrown,
//                                                 foregroundColor:
//                                                 Colors.white,
//                                                 shape:
//                                                 RoundedRectangleBorder(
//                                                   borderRadius:
//                                                   BorderRadius
//                                                       .circular(
//                                                       10),
//                                                 ),
//                                                 padding:
//                                                 EdgeInsets.zero,
//                                               ),
//                                               child: FittedBox(
//                                                 fit: BoxFit
//                                                     .scaleDown,
//                                                 child: Text(
//                                                   translateText(
//                                                       'Details'),
//                                                   style:
//                                                   const TextStyle(
//                                                     fontSize: 13,
//                                                     fontWeight:
//                                                     FontWeight
//                                                         .bold,
//                                                     color: Colors
//                                                         .white,
//                                                   ),
//                                                 ),
//                                               ),
//                                             ),
//                                           ),
//                                         ),
//                                       ],
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                             ),
//                           ),
//                         ),
//                       );
//                     },
//                   ),
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
//   final _secureStorage = const FlutterSecureStorage();
//   bool _isProcessing = false;
//
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
//   @override
//   void initState() {
//     super.initState();
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
//     final Map<String, dynamic> requestBody = {
//       'id': userId,
//       'project_id': widget.projectId,
//     };
//     try {
//       final response = await http.post(
//         Uri.parse(apiUrl),
//         headers: {'Content-Type': 'application/json'},
//         body: jsonEncode(requestBody),
//       );
//       if (response.statusCode == 200) {
//         final responseData = json.decode(response.body);
//         if (responseData['success'] == true) {
//           setState(() {
//             applications = responseData['data']['applications'];
//             isLoading = false;
//           });
//         } else {
//           setState(() => isLoading = false);
//           ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(content: Text('Failed to fetch project details')),
//           );
//         }
//       } else {
//         setState(() => isLoading = false);
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('Failed to fetch project details')),
//         );
//       }
//     } catch (e) {
//       setState(() => isLoading = false);
//     }
//   }
//
//   Future<void> unassignProject(String labourId, String projectId) async {
//     setState(() => _isProcessing = true);
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
//           await fetchProjectApplications();
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(content: Text(data['message'])),
//           );
//         }
//       }
//     } catch (e) {
//       // ignore
//     } finally {
//       setState(() => _isProcessing = false);
//     }
//   }
//
//   Future<void> cancelConfirm(
//       String projectId, String labourId, String cancelRemark) async {
//     setState(() => _isProcessing = true);
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
//           await fetchProjectApplications();
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(content: Text(data['message'])),
//           );
//         }
//       }
//     } catch (e) {
//       // ignore
//     } finally {
//       setState(() => _isProcessing = false);
//     }
//   }
//
//   void showCancelDialog(BuildContext context, String labourId) {
//     TextEditingController _cancelRemarkController = TextEditingController();
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: Text(translate('Cancel Remark', 'रद्द करने का कारण')),
//           content: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               TextField(
//                 controller: _cancelRemarkController,
//                 decoration: InputDecoration(
//                   labelText: translate(
//                       'Enter Cancel Remark', 'रद्द करने का कारण दर्ज करें'),
//                   border: OutlineInputBorder(),
//                   suffixIcon:
//                   MicIconButton(controller: _cancelRemarkController),
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
//                     widget.projectId,
//                     labourId,
//                     _cancelRemarkController.text,
//                   );
//                   Navigator.of(context).pop();
//                 } else {
//                   ScaffoldMessenger.of(context).showSnackBar(
//                     const SnackBar(content: Text('Remark cannot be empty')),
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
//     setState(() => _isProcessing = true);
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
//           await fetchProjectApplications();
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(content: Text(data['message'])),
//           );
//         }
//       }
//     } catch (e) {
//       // ignore
//     } finally {
//       setState(() => _isProcessing = false);
//     }
//   }
//
//   Future<void> _assignWithConfirmation(String labourId) async {
//     bool? confirm = await _showAssignConfirmationDialog();
//     if (confirm == true) {
//       await assignProject(labourId);
//     }
//   }
//
//   Future<bool?> _showAssignConfirmationDialog() {
//     return showDialog<bool>(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: Text(translate('Assign Project', 'परियोजना असाइन करें')),
//         content: Text(translate(
//             'Are you sure you want to assign this project to the selected worker?',
//             'क्या आप सुनिश्चित हैं कि आप इस परियोजना को चयनित कार्यकर्ता को असाइन करना चाहते हैं?')),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context, false),
//             child: Text(translate('Cancel', 'रद्द करें')),
//           ),
//           TextButton(
//             onPressed: () => Navigator.pop(context, true),
//             child: Text(translate('Yes', 'हाँ')),
//           ),
//         ],
//       ),
//     );
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
//     final Map<String, dynamic> requestBody = {
//       'labourid': labourId,
//       'projectid': widget.projectId,
//     };
//     try {
//       final response = await http.post(
//         Uri.parse(apiUrl),
//         headers: {'Content-Type': 'application/json'},
//         body: jsonEncode(requestBody),
//       );
//       if (response.statusCode == 200) {
//         final responseData = json.decode(response.body);
//         if (responseData['status'] == 1) {
//           await fetchProjectApplications();
//           ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(content: Text('Project assigned successfully')),
//           );
//           Future.delayed(const Duration(seconds: 1), () {
//             Navigator.pop(context, true);
//           });
//         } else {
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(
//                 content: Text(
//                     'Failed to assign project: ${responseData['message']}')),
//           );
//         }
//       }
//     } catch (e) {
//       // ignore
//     }
//   }
//
//   Future<void> _unassignWithConfirmation(String labourId) async {
//     bool? confirm = await _showUnassignConfirmationDialog();
//     if (confirm == true) {
//       await unassignProject(labourId, widget.projectId);
//     }
//   }
//
//   Future<bool?> _showUnassignConfirmationDialog() {
//     return showDialog<bool>(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: Text(translate('Unassign Project', 'परियोजना अनअसाइन करें')),
//         content: Text(translate(
//             'Are you sure you want to unassign this project from the worker?',
//             'क्या आप सुनिश्चित हैं कि आप इस परियोजना को कार्यकर्ता से अनअसाइन करना चाहते हैं?')),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context, false),
//             child: Text(translate('Cancel', 'रद्द करें')),
//           ),
//           TextButton(
//             onPressed: () => Navigator.pop(context, true),
//             child: Text(translate('Yes', 'हाँ')),
//           ),
//         ],
//       ),
//     );
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
//       backgroundColor: kSurfaceBackground,
//       appBar: AppBar(
//         title: Text(
//           AppLocalizations.of(context)!.projectApplications,
//           style: const TextStyle(
//             fontSize: 18,
//             fontWeight: FontWeight.bold,
//             color: Colors.white,
//           ),
//         ),
//         iconTheme: const IconThemeData(color: Colors.white),
//         backgroundColor: kBrandGreen,
//         elevation: 0,
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back),
//           onPressed: () {
//             Navigator.pop(context);
//           },
//         ),
//       ),
//       body: RefreshIndicator(
//         onRefresh: fetchProjectApplications,
//         child: isLoading
//             ? const Center(child: CircularProgressIndicator())
//             : applications.isEmpty
//             ? Center(
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Icon(
//                 Icons.person_off_outlined,
//                 size: 72,
//                 color: kTextGrey,
//               ),
//               const SizedBox(height: 16),
//               Text(
//                 translateText('No applications found'),
//                 style: const TextStyle(
//                   fontSize: 18,
//                   fontWeight: FontWeight.w500,
//                   color: kTextGrey,
//                 ),
//               ),
//             ],
//           ),
//         )
//             : ListView.builder(
//           padding:
//           const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
//           itemCount: applications.length,
//           itemBuilder: (context, index) {
//             final application = applications[index];
//             String status = application['status']?.toString() ?? '0';
//             Color statusColor;
//             Color statusBg;
//             switch (status) {
//               case '0':
//                 statusColor = kTextGrey;
//                 statusBg = kSurfaceBackground;
//                 break;
//               case '1':
//                 statusColor = kBrandGreen;
//                 statusBg = kBrandGreenTint;
//                 break;
//               case '2':
//                 statusColor = kBrandBrown;
//                 statusBg = kBrandBrownTint;
//                 break;
//               case '3':
//                 statusColor = kBrandGreen;
//                 statusBg = kBrandGreenTint;
//                 break;
//               default:
//                 statusColor = const Color(0xFF991B1B);
//                 statusBg = const Color(0xFFFEF2F2);
//             }
//
//             return Container(
//               margin: const EdgeInsets.only(bottom: 12),
//               decoration: BoxDecoration(
//                 color: Colors.white,
//                 borderRadius: BorderRadius.circular(16),
//                 border: Border.all(
//                   color: kBorderColor,
//                   width: 1.0,
//                 ),
//                 boxShadow: [
//                   BoxShadow(
//                     color: Colors.black.withOpacity(0.04),
//                     blurRadius: 12,
//                     offset: const Offset(0, 4),
//                   ),
//                 ],
//               ),
//               child: Padding(
//                 padding: const EdgeInsets.all(16),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Row(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Container(
//                           width: 48,
//                           height: 48,
//                           decoration: BoxDecoration(
//                             color: kBrandGreenTint,
//                             shape: BoxShape.circle,
//                           ),
//                           child: Center(
//                             child: Text(
//                               (application['labour_name'] ?? 'W')[0]
//                                   .toUpperCase(),
//                               style: const TextStyle(
//                                 fontSize: 18,
//                                 fontWeight: FontWeight.bold,
//                                 color: kBrandGreen,
//                               ),
//                             ),
//                           ),
//                         ),
//                         const SizedBox(width: 12),
//                         Expanded(
//                           child: Column(
//                             crossAxisAlignment:
//                             CrossAxisAlignment.start,
//                             children: [
//                               Text(
//                                 translateText(application[
//                                 'labour_name'] ??
//                                     'Unknown'),
//                                 style: const TextStyle(
//                                   fontSize: 16,
//                                   fontWeight: FontWeight.bold,
//                                   color: kBrandGreen,
//                                 ),
//                               ),
//                               const SizedBox(height: 4),
//                               Row(
//                                 children: [
//                                   Container(
//                                     padding:
//                                     const EdgeInsets.symmetric(
//                                         horizontal: 8,
//                                         vertical: 3),
//                                     decoration: BoxDecoration(
//                                       color: statusBg,
//                                       borderRadius:
//                                       BorderRadius.circular(12),
//                                       border: Border.all(
//                                         color: statusColor
//                                             .withOpacity(0.3),
//                                         width: 0.5,
//                                       ),
//                                     ),
//                                     child: Text(
//                                       translateText(
//                                           getStatusText(status)),
//                                       style: TextStyle(
//                                         fontSize: 11,
//                                         fontWeight: FontWeight.bold,
//                                         color: statusColor,
//                                       ),
//                                     ),
//                                   ),
//                                   const SizedBox(width: 8),
//                                   Icon(
//                                     Icons.calendar_today_outlined,
//                                     size: 12,
//                                     color: kTextGrey,
//                                   ),
//                                   const SizedBox(width: 4),
//                                   Text(
//                                     _formatDate(
//                                         application['created_at'] ??
//                                             ''),
//                                     style: const TextStyle(
//                                       fontSize: 11,
//                                       color: kTextGrey,
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ],
//                           ),
//                         ),
//                       ],
//                     ),
//                     const SizedBox(height: 12),
//                     const Divider(color: kBorderColor, height: 1),
//                     const SizedBox(height: 10),
//                     Row(
//                       children: [
//                         Icon(Icons.chat_bubble_outline,
//                             size: 16, color: kTextGrey),
//                         const SizedBox(width: 6),
//                         Expanded(
//                           child: Text(
//                             translateText(
//                                 application['comment'] ?? 'N/A'),
//                             style: const TextStyle(
//                               fontSize: 13,
//                               color: Color(0xFF475569),
//                             ),
//                           ),
//                         ),
//                         SpeakerIconButton(
//                           text: translateText(
//                               application['comment'] ?? 'N/A'),
//                           size: 16,
//                         ),
//                       ],
//                     ),
//                     const SizedBox(height: 8),
//                     Row(
//                       children: [
//                         Icon(Icons.location_on_outlined,
//                             size: 16, color: kTextGrey),
//                         const SizedBox(width: 6),
//                         Expanded(
//                           child: Text(
//                             translateText(
//                                 '${application['labour_address'] ?? ''}, ${application['labour_city'] ?? ''}, ${application['labour_state'] ?? ''}'),
//                             style: const TextStyle(
//                               fontSize: 13,
//                               color: Color(0xFF475569),
//                             ),
//                             maxLines: 1,
//                             overflow: TextOverflow.ellipsis,
//                           ),
//                         ),
//                       ],
//                     ),
//                     const SizedBox(height: 12),
//                     Row(
//                       mainAxisAlignment:
//                       MainAxisAlignment.spaceEvenly,
//                       children: [
//                         Expanded(
//                           child: SizedBox(
//                             height: 40,
//                             child: OutlinedButton(
//                               onPressed: () {
//                                 Navigator.push(
//                                   context,
//                                   MaterialPageRoute(
//                                     builder: (context) =>
//                                         ApplicationDetailPage(
//                                           application: application,
//                                         ),
//                                   ),
//                                 );
//                               },
//                               style: OutlinedButton.styleFrom(
//                                 side: const BorderSide(
//                                     color: kBrandBrown, // <--- UPDATED TO BROWN
//                                     width: 1.2),
//                                 shape: RoundedRectangleBorder(
//                                   borderRadius:
//                                   BorderRadius.circular(10),
//                                 ),
//                                 padding: const EdgeInsets.symmetric(
//                                     horizontal: 4),
//                               ),
//                               child: FittedBox(
//                                 fit: BoxFit.scaleDown,
//                                 child: Text(
//                                   AppLocalizations.of(context)!
//                                       .viewDetails,
//                                   style: const TextStyle(
//                                     color: kBrandBrown, // <--- UPDATED TO BROWN
//                                     fontWeight: FontWeight.bold,
//                                     fontSize: 12,
//                                   ),
//                                 ),
//                               ),
//                             ),
//                           ),
//                         ),
//                         const SizedBox(width: 8),
//                         if (status == "0")
//                           Expanded(
//                             child: SizedBox(
//                               height: 40,
//                               child: ElevatedButton(
//                                 onPressed: _isProcessing
//                                     ? null
//                                     : () =>
//                                     _assignWithConfirmation(
//                                         application['labour_id']
//                                             .toString()),
//                                 style: ElevatedButton.styleFrom(
//                                   backgroundColor:
//                                   kBrandBrown, // <--- UPDATED TO BROWN
//                                   foregroundColor: Colors.white,
//                                   shape: RoundedRectangleBorder(
//                                     borderRadius:
//                                     BorderRadius.circular(10),
//                                   ),
//                                   padding: const EdgeInsets.symmetric(
//                                       horizontal: 4),
//                                 ),
//                                 child: FittedBox(
//                                   fit: BoxFit.scaleDown,
//                                   child: Text(
//                                     translateText('Assign'),
//                                     style: const TextStyle(
//                                       fontWeight: FontWeight.bold,
//                                       fontSize: 12,
//                                       color: Colors.white,
//                                     ),
//                                   ),
//                                 ),
//                               ),
//                             ),
//                           )
//                         else if (status == "1")
//                           Expanded(
//                             child: SizedBox(
//                               height: 40,
//                               child: ElevatedButton(
//                                 onPressed: _isProcessing
//                                     ? null
//                                     : () =>
//                                     _unassignWithConfirmation(
//                                         application['labour_id']
//                                             .toString()),
//                                 style: ElevatedButton.styleFrom(
//                                   backgroundColor: Colors.red,
//                                   foregroundColor: Colors.white,
//                                   shape: RoundedRectangleBorder(
//                                     borderRadius:
//                                     BorderRadius.circular(10),
//                                   ),
//                                   padding: const EdgeInsets.symmetric(
//                                       horizontal: 4),
//                                 ),
//                                 child: FittedBox(
//                                   fit: BoxFit.scaleDown,
//                                   child: Text(
//                                     translateText('Unassign'),
//                                     style: const TextStyle(
//                                       fontWeight: FontWeight.bold,
//                                       fontSize: 12,
//                                       color: Colors.white,
//                                     ),
//                                   ),
//                                 ),
//                               ),
//                             ),
//                           )
//                         else if (status == "2")
//                             Expanded(
//                               child: SizedBox(
//                                 height: 40,
//                                 child: ElevatedButton(
//                                   onPressed: _isProcessing
//                                       ? null
//                                       : () => confirmComplete(
//                                       widget.projectId,
//                                       application['labour_id']
//                                           .toString()),
//                                   style: ElevatedButton.styleFrom(
//                                     backgroundColor: kBrandBrown, // <--- UPDATED TO BROWN
//                                     foregroundColor: Colors.white,
//                                     shape: RoundedRectangleBorder(
//                                       borderRadius:
//                                       BorderRadius.circular(10),
//                                     ),
//                                     padding: const EdgeInsets.symmetric(
//                                         horizontal: 4),
//                                   ),
//                                   child: FittedBox(
//                                     fit: BoxFit.scaleDown,
//                                     child: Text(
//                                       translateText('Complete'),
//                                       style: const TextStyle(
//                                         fontWeight: FontWeight.bold,
//                                         fontSize: 12,
//                                         color: Colors.white,
//                                       ),
//                                     ),
//                                   ),
//                                 ),
//                               ),
//                             )
//                           else
//                             const SizedBox.shrink(),
//                       ],
//                     ),
//                   ],
//                 ),
//               ),
//             );
//           },
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

// // --- NEW BRAND COLORS APPLIED DIRECTLY HERE ---
// const Color kBrandGreen = Color(0xFF0E6805);
// const Color kBrandBrown = Color(0xFF865E2A);
// const Color kBrandGreenTint = Color(0x190E6805); // 10% opacity
// const Color kBrandBrownTint = Color(0x19865E2A); // 10% opacity
// const Color kSurfaceBackground = Color(0xFFF9FAFB);
// const Color kBorderColor = Color(0xFFE5E7EB);
// const Color kTextGrey = Color(0xFF6B7280);


// ============================================================
// NEW BRAND COLORS BASED ON RGB(203, 157, 35)
// ============================================================


const Color kBrandGreen = Color(0xFF0E6805);

// Secondary/darker shade (for contrast, e.g., shadows or dark text)
const Color kBrandBrown = Color.fromRGBO(170, 125, 20, 1);

// Tints with 10% opacity (for backgrounds, hover states, etc.)
const Color kBrandGreenTint = Color.fromRGBO(203, 157, 35, 0.1);
const Color kBrandBrownTint = Color.fromRGBO(170, 125, 20, 0.1);

// Neutral colors – these can stay unchanged
const Color kSurfaceBackground = Color(0xFFF9FAFB);
const Color kBorderColor = Color(0xFFE5E7EB);
const Color kTextGrey = Color(0xFF6B7280);
// ----------------------------------------------

class JobType {
  final int id;
  final String jobname;
  final String image;
  final String status;

  JobType({
    required this.id,
    required this.jobname,
    required this.image,
    required this.status,
  });

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

  final int initialTabIndex;

  const HomePage({Key? key, this.initialTabIndex = 0}) : super(key: key);
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;
  final _secureStorage = const FlutterSecureStorage();

  String _selectedLanguage = 'en';
  String _userName = '';
  String _userType = '';
  int _walletCoins = 0;

  Future<void> _loadWalletBalance() async {
    int coins = await WalletHelper.syncCoinBalance();
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
    String? language = await _secureStorage.read(key: 'selectedLanguage');
    _selectedLanguage = language ?? 'en';
  }

  Map<String, Map<String, String>> _cachedTranslations = {};
  int unreadNotificationsCount = 0;

  Map<String, Map<String, String>> translations =
      Constants.AppConstants.translations;
  final GoogleTranslator _translator = GoogleTranslator();

  @override
  void initState() {
    _currentIndex = widget.initialTabIndex;
    super.initState();
    loadLanguage();
    _loadUserInfo();
    _loadWalletBalance();
    ApiLogger.logScreenOpened('CombinedPage');
  }

  Future<void> fetchUnreadNotificationsCount() async {
    String? userId = await _secureStorage.read(key: 'id');
    if (userId == null) return;
    final url = Uri.parse(
        '${Constants.AppConstants.apiUrl}farmer/getUnreadNotificationsCount');
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
    String translatedText = await _fetchTranslation(text, targetLang);
    return translatedText;
  }

  Future<String> _fetchTranslation(String text, String targetLang) async {
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

  final List<Widget> _pages = [
    CombinedPage(),
    LabourPage(),
    ProjectPage(),
  ];

  Future<void> _logout(BuildContext context) async {
    await _secureStorage.delete(key: 'id');
    await _secureStorage.delete(key: 'token');
    await _secureStorage.delete(key: 'name');
    await _secureStorage.delete(key: 'phone');
    await _secureStorage.delete(key: 'userType');
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: ListTile(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        leading: Container(
          height: 40,
          width: 40,
          decoration: BoxDecoration(
            color: isLogout ? const Color(0xFFFEF2F2) : kBrandGreenTint,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
              icon,
              color: isLogout ? const Color(0xFFEF4444) : kBrandGreen,
              size: 20
          ),
        ),
        title: title,
        trailing: trailing ??
            Icon(
              Icons.chevron_right_rounded,
              color: isLogout ? const Color(0xFFEF4444) : kTextGrey,
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
                        valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white70),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      _selectedLanguage == 'en'
                          ? 'Finding location...'
                          : 'स्थान खोज रहे हैं...',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white.withOpacity(0.8),
                      ),
                    ),
                  ],
                );
              } else if (locationProvider.error.isNotEmpty ||
                  (locationProvider.city.isEmpty &&
                      locationProvider.state.isEmpty)) {
                locationWidget = Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.location_off,
                        size: 14, color: Colors.white70),
                    const SizedBox(width: 4),
                    Text(
                      _selectedLanguage == 'en'
                          ? 'Location unavailable'
                          : 'स्थान अनुपलब्ध',
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
                    const Icon(Icons.location_on,
                        size: 14, color: Colors.white),
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
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.transparent,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                              color: Colors.white, width: 1.0),
                        ),
                        child: Text(
                          _selectedLanguage == 'en'
                              ? 'Farmer'
                              : 'किसान',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
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
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white
            ),
          ),
          iconTheme: const IconThemeData(color: Colors.white),
          backgroundColor: kBrandGreen,
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
                      Color(0xFF075503), // Slightly darker brand green
                      kBrandGreen,
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
                          _userName.isNotEmpty
                              ? _userName[0].toUpperCase()
                              : 'U',
                          style: const TextStyle(
                            color: kBrandGreen,
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
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              _userType == 'labour'
                                  ? (context
                                  .watch<LanguageProvider>()
                                  .selectedLanguage ==
                                  'en'
                                  ? 'Worker'
                                  : 'श्रमिक')
                                  : (context
                                  .watch<LanguageProvider>()
                                  .selectedLanguage ==
                                  'en'
                                  ? 'Farmer'
                                  : 'किसान'),
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
                            style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1F2937)),
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
                    _buildDrawerTile(
                      icon: Icons.search,
                      title: FutureBuilder<String>(
                        future: translateText('Search'),
                        builder: (context, snapshot) {
                          return Text(
                            snapshot.data ?? 'Search',
                            style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1F2937)),
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
                    _buildDrawerTile(
                      icon: Icons.notifications,
                      title: FutureBuilder<String>(
                        future: translateText('Notifications'),
                        builder: (context, snapshot) {
                          return Row(
                            children: [
                              Text(
                                snapshot.data ?? 'Notifications',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF1F2937)),
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
                    _buildDrawerTile(
                      icon: Icons.language,
                      title: FutureBuilder<String>(
                        future: translateText(' Select Language'),
                        builder: (context, snapshot) {
                          return Text(
                            snapshot.data ?? 'Language',
                            style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1F2937)),
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
                    _buildDrawerTile(
                      icon: Icons.notes,
                      title: FutureBuilder<String>(
                        future: translateText('Projects'),
                        builder: (context, snapshot) {
                          return Text(
                            snapshot.data ?? 'Projects',
                            style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1F2937)),
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
                    _buildDrawerTile(
                      icon: Icons.account_balance_wallet,
                      title: FutureBuilder<String>(
                        future: translateText('Wallet'),
                        builder: (context, snapshot) {
                          final walletTitle = snapshot.data ?? 'Wallet';
                          return Text(
                            walletTitle,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1F2937)),
                          );
                        },
                      ),
                      onTap: () {
                        Navigator.pop(context);
                        WalletHelper.showCoinShop(context,
                            onCoinsAdded: (newBalance) {
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
                            style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1F2937)),
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
                    const Divider(
                        color: kBorderColor,
                        height: 24,
                        thickness: 1),
                    _buildDrawerTile(
                      icon: Icons.logout,
                      isLogout: true,
                      title: FutureBuilder<String>(
                        future: translateText('Logout'),
                        builder: (context, snapshot) {
                          return Text(
                            snapshot.data ?? 'Logout',
                            style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1F2937)),
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
        body: SafeArea(
          child: _pages[_currentIndex],
        ),
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            color: kBrandGreen,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(28),
              topRight: Radius.circular(28),
            ),
            boxShadow: [
              BoxShadow(
                color: kBrandGreen.withOpacity(0.2),
                blurRadius: 10,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(28),
              topRight: Radius.circular(28),
            ),
            child: BottomNavigationBar(
              backgroundColor: Colors.transparent,
              currentIndex: _currentIndex,
              selectedItemColor: Colors.white,
              unselectedItemColor: Colors.white70,
              selectedLabelStyle: const TextStyle(
                fontSize: 12,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
              unselectedLabelStyle: const TextStyle(
                fontSize: 12,
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
        // FIXED: Changed to Brand Brown, moved correctly to bottom right
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AddProjectForm(),
              ),
            );
          },
          backgroundColor: kBrandBrown,
          foregroundColor: Colors.white,
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          label: const Text(
            'Post Job',
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
          ),
          icon: const Icon(Icons.add, size: 20),
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
        style: TextStyle(fontSize: 24, color: kBrandGreen),
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
        style: TextStyle(fontSize: 24, color: kBrandGreen),
      ),
    );
  }
}

class CombinedPage extends StatefulWidget {
  @override
  _CombinedPageState createState() => _CombinedPageState();
}

class _CombinedPageState extends State<CombinedPage>
    with WidgetsBindingObserver {
  static String _cachedCity = '';
  static String _cachedState = '';
  static String _cachedError = '';

  final FlutterSecureStorage _secureStorage = FlutterSecureStorage();
  final TextEditingController _labourSearchController = TextEditingController();
  late Future<List<JobType>> _jobTypes;

  List<dynamic> labours = [];
  bool isLoading = false;
  String _selectedLanguage = 'en';
  int _coinCharge = 5;

  Future<void> _loadCoinCharge() async {
    int charge = await WalletHelper.getCoinCharge();
    if (mounted) {
      setState(() {
        _coinCharge = charge;
      });
    }
  }

  IconData _getCategoryIcon(String jobname) {
    final name = jobname.toLowerCase();
    if (name.contains('crop') || name.contains('farm') || name.contains('कृषि') || name.contains('फसल')) {
      return Icons.grass;
    } else if (name.contains('cow') || name.contains('animal') || name.contains('dairy') || name.contains('husbandry') || name.contains('पशु') || name.contains('गाय')) {
      return Icons.pets;
    } else if (name.contains('tractor') || name.contains('driver') || name.contains('ट्रैक्टर')) {
      return Icons.agriculture;
    } else if (name.contains('box') || name.contains('pack') || name.contains('warehouse') || name.contains('logistics') || name.contains('डिब्बा') || name.contains('पैकिंग')) {
      return Icons.inventory_2;
    }
    return Icons.category;
  }

  Future<void> loadLanguage() async {
    String? language = await _secureStorage.read(key: 'selectedLanguage');
    _selectedLanguage = language ?? 'en';
  }

  Map<String, Map<String, String>> _cachedTranslations = {};
  Map<String, Map<String, String>> translations =
      Constants.AppConstants.translations;
  final GoogleTranslator _translator = GoogleTranslator();
  late stt.SpeechToText _speech;
  late Timer _timer;

  String _currentCity = '';
  String _currentState = '';
  bool _isLoadingLocation = true;
  String _locationError = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _speech = stt.SpeechToText();
    _jobTypes = fetchJobTypes();
    fetchLabours();
    _fetchCurrentLocation();
    _loadCoinCharge();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
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
            final locProv =
            Provider.of<LocationProvider>(context, listen: false);
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
    // ... [Your existing geolocation logic remains unchanged] ...
    // Fallback:
    _cachedCity = "Jaipur";
    _cachedState = "Rajasthan";
    _isLoadingLocation = false;
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

  bool _isListening = false;
  String _searchText = '';

  void _startListening() async {
    final language =
        Provider.of<LanguageProvider>(context, listen: false).selectedLanguage;
    String localeId = language == 'en' ? 'en_US' : 'hi_IN';
    bool available = await _speech.initialize();
    if (available) {
      setState(() => _isListening = true);
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
    }
  }

  void _stopListening() {
    setState(() => _isListening = false);
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

  Future<void> fetchLabours({String? searchQuery}) async {
    setState(() { isLoading = true; });
    String? userId = await _secureStorage.read(key: 'id');
    if (!mounted) return;
    if (userId == null) {
      setState(() => isLoading = false);
      return;
    }
    final apiUrl = (searchQuery != null && searchQuery.isNotEmpty)
        ? '${Constants.AppConstants.apiUrl}farmer/searchnearbylabours'
        : '${Constants.AppConstants.apiUrl}farmer/nearbylabours';
    final Map<String, dynamic> requestBody = (searchQuery != null && searchQuery.isNotEmpty)
        ? {'search': searchQuery}
        : {'id': userId};
    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );
      if (!mounted) return;
      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData['success'] == true) {
          setState(() { labours = responseData['data']; });
        }
      }
    } catch (e) {} finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  final List<String> imageUrls = [
    'assets/slider1.png', 'assets/slider2.png', 'assets/slider4.jpg', 'assets/slider3.png', 'assets/slider5.png',
  ];

  @override
  Widget build(BuildContext context) {
    final language = Provider.of<LanguageProvider>(context, listen: false).selectedLanguage;
    String translate(String enText, String hiText) => language == 'en' ? enText : hiText;

    return WillPopScope(
      onWillPop: () async {
        SystemNavigator.pop();
        return false;
      },
      child: RefreshIndicator(
        onRefresh: () async {
          _jobTypes = fetchJobTypes();
          await fetchLabours();
          await _fetchCurrentLocation();
        },
        child: Scaffold(
          body: Container(
            width: double.infinity,
            decoration: BoxDecoration(color: kSurfaceBackground),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    height: 200,
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [BoxShadow(color: kBrandGreen.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 4))],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: CarouselSlider.builder(
                        itemCount: imageUrls.length,
                        itemBuilder: (context, index, realIndex) => Image.asset(imageUrls[index], fit: BoxFit.cover),
                        options: CarouselOptions(height: 200, autoPlay: true, viewportFraction: 1.0),
                      ),
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                    child: Text(
                      translate('Select category for job/Work', 'नौकरी/कार्य के लिए श्रेणी चुनें'),
                      style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: kBrandGreen),
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: FutureBuilder<List<JobType>>(
                      future: _jobTypes,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator());
                        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                          return const Center(child: Text('No data available', style: TextStyle(color: kTextGrey)));
                        } else {
                          return Container(
                            height: 128,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              itemCount: snapshot.data!.length,
                              itemBuilder: (context, index) {
                                final job = snapshot.data![index];
                                return InkWell(
                                  onTap: () {
                                    Navigator.push(context, MaterialPageRoute(builder: (context) => AddProjectForm(projectType: job.jobname)));
                                  },
                                  child: SizedBox(
                                    width: 90,
                                    child: Column(
                                      children: [
                                        Container(
                                          width: 70,
                                          height: 70,
                                          margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                                          decoration: BoxDecoration(color: kBrandGreenTint, shape: BoxShape.circle),
                                          child: Center(
                                            child: CachedNetworkImage(
                                              imageUrl: '${Constants.AppConstants.folderUrl}storage/upload/jobtypes/${job.image}',
                                              width: 42, height: 42,
                                              placeholder: (context, url) => const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)),
                                              errorWidget: (context, url, error) => Icon(_getCategoryIcon(job.jobname), color: kBrandGreen, size: 32),
                                            ),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.only(top: 6.0),
                                          child: Text(
                                            translateText(job.jobname),
                                            textAlign: TextAlign.center,
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(fontSize: 13, color: kBrandBrown, fontWeight: FontWeight.w600),
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
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [BoxShadow(color: kBrandGreen.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 2))],
                      ),
                      child: TextField(
                        controller: _labourSearchController,
                        onChanged: (value) => fetchLabours(searchQuery: value),
                        style: const TextStyle(color: Color(0xFF1F2937)),
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.search, color: kBrandGreen, size: 20),
                          suffixIcon: MicIconButton(controller: _labourSearchController),
                          hintText: AppLocalizations.of(context)!.searchlabour,
                          hintStyle: const TextStyle(color: kTextGrey, fontSize: 14),
                          fillColor: Colors.transparent,
                          filled: true,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: kBorderColor)),
                          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: kBorderColor)),
                          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: kBrandGreen, width: 1.5)),
                        ),
                      ),
                    ),
                  ),

                  const Divider(color: kBorderColor),

                  // FIXED: Worker list padding aligned to 16.0 horizontally to match search bar. Individual card margins adjusted.
                  labours.isEmpty
                      ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32.0),
                      child: Text(
                        translate('Looking for nearby workers', 'आसपास के मजदूरों की तलाश की जा रही है'),
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: kBrandBrown),
                      ),
                    ),
                  )
                      : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 80.0),
                    itemCount: labours.length,
                    itemBuilder: (context, index) {
                      final labour = labours[index];
                      String labourType = labour['type'] == '0' ? translateText('Individual') : translateText('Agency');
                      String subtitle = labour['skills']?.toString() ?? labour['aboutme']?.toString() ?? '';

                      List<String> skillTags = [];
                      if (labour['skills'] != null && labour['skills'].toString().isNotEmpty) {
                        skillTags = labour['skills'].toString().split(',').map((s) => s.trim()).where((s) => s.isNotEmpty).toList();
                      }
                      if (skillTags.length > 2) skillTags = skillTags.sublist(0, 2);

                      return GestureDetector(
                        onTap: () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => LabourDetailsPage(labour: labour)));
                        },
                        child: Container(
                          margin: const EdgeInsets.symmetric(vertical: 6.0),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: kBrandGreen.withOpacity(0.1), width: 1.0),
                            boxShadow: [BoxShadow(color: kBrandGreen.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))],
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Stack(
                                  children: [
                                    Container(
                                      width: 54, height: 54,
                                      decoration: BoxDecoration(color: kBrandGreenTint, borderRadius: BorderRadius.circular(27), border: Border.all(color: kBrandGreen.withOpacity(0.2), width: 1.5)),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(27),
                                        child: (labour['profile_image'] != null && labour['profile_image'].toString().isNotEmpty)
                                            ? Image.network(labour['profile_image'].toString(), fit: BoxFit.cover, errorBuilder: (c, e, s) => const Icon(Icons.person, color: kBrandGreen, size: 28))
                                            : const Icon(Icons.person, color: kBrandGreen, size: 28),
                                      ),
                                    ),
                                    Positioned(
                                      bottom: 0, right: 0,
                                      child: Container(
                                        padding: const EdgeInsets.all(2),
                                        decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                                        child: Container(padding: EdgeInsets.all(2), decoration: BoxDecoration(color: kBrandGreen, shape: BoxShape.circle), child: Icon(Icons.check, color: Colors.white, size: 8)),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(translateText(labour['name'] ?? 'Unknown'), style: const TextStyle(color: kBrandGreen, fontWeight: FontWeight.bold, fontSize: 15), overflow: TextOverflow.ellipsis),
                                                const SizedBox(height: 2),
                                                Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2), decoration: BoxDecoration(color: kBrandGreenTint, borderRadius: BorderRadius.circular(4)), child: Text(labourType, style: const TextStyle(fontSize: 10, color: kBrandGreen, fontWeight: FontWeight.bold))),
                                              ],
                                            ),
                                          ),
                                          if (skillTags.isNotEmpty)
                                            Flexible(
                                              child: Wrap(
                                                alignment: WrapAlignment.end,
                                                spacing: 4,
                                                runSpacing: 2,
                                                children: skillTags.map((tag) {
                                                  return Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3), decoration: BoxDecoration(color: kBrandBrownTint, borderRadius: BorderRadius.circular(6), border: Border.all(color: kBrandBrown.withOpacity(0.2), width: 0.5)), child: Text(translateText(tag), style: const TextStyle(color: kBrandBrown, fontSize: 9, fontWeight: FontWeight.w600)));
                                                }).toList(),
                                              ),
                                            ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Row(children: [const Icon(Icons.location_on_outlined, size: 14, color: kTextGrey), const SizedBox(width: 4), Expanded(child: Text('${translateText(labour['city'] ?? 'Unknown City')}, ${translateText(labour['state'] ?? '')}', style: const TextStyle(color: kTextGrey, fontSize: 12), overflow: TextOverflow.ellipsis))]),
                                      if (subtitle.isNotEmpty) ...[const SizedBox(height: 4), Row(children: [const Icon(Icons.work_outline, size: 14, color: kBrandGreen), const SizedBox(width: 4), Expanded(child: Text(subtitle.length > 40 ? '${subtitle.substring(0, 40)}...' : subtitle, style: const TextStyle(color: kTextGrey, fontSize: 11), overflow: TextOverflow.ellipsis))])],
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
                ],
              ),
            ),
          ),
        ),
      ),
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
        color: kBrandGreenTint,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: kBrandGreen.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 5,
          ),
        ],
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: kBrandGreen,
          child: Text(
            translateText(widget.labour['name'][0].toUpperCase()),
            style: const TextStyle(color: Colors.white),
          ),
        ),
        title: Text(
          translateText(widget.labour['name'] ?? 'Unknown'),
          style: const TextStyle(fontWeight: FontWeight.bold, color: kBrandGreen),
        ),
        subtitle: Text(
          '${translateText(widget.labour['city'] ?? 'Unknown City')}, ${translateText(widget.labour['state'] ?? 'Unknown State')}',
          style: const TextStyle(color: kTextGrey),
        ),
        trailing: Column(
          children: [
            Text(
              widget.labour['type'] == '0'
                  ? translateText('Individual')
                  : translateText('Agency'),
              style: const TextStyle(color: kBrandBrown, fontWeight: FontWeight.bold),
            ),
            if (widget.labour['type'] == '1')
              Text(
                '${translateText(widget.labour['agency_name'])}',
                style: const TextStyle(color: kTextGrey, fontSize: 10),
              ),
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
  List<dynamic> filteredProjects = [];
  bool isLoading = true;
  final TextEditingController _searchController = TextEditingController();
  String _selectedLanguage = 'en';

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
        setState(() {
          projects = json.decode(response.body)['data'];
          filteredProjects = projects;
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No Projects Created Yet')),
        );
      }
    } catch (e) {
      setState(() => isLoading = false);
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

  bool _isListening = false;
  String _searchText = '';

  void _startListening() async {
    final language =
        Provider.of<LanguageProvider>(context, listen: false).selectedLanguage;
    String localeId = language == 'en' ? 'en_US' : 'hi_IN';
    bool available = await _speech.initialize();
    if (available) {
      setState(() => _isListening = true);
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
    }
  }

  void _stopListening() {
    setState(() => _isListening = false);
    _speech.stop();
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

  Widget _buildPremiumChip({
    required IconData icon,
    required String label,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: kBrandBrownTint,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: kBrandBrown.withOpacity(0.2), width: 0.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: kBrandBrown),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: kBrandBrown,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProjectStatusBadge(Map<String, dynamic> project) {
    final status = project['status']?.toString() ?? '1';
    final labourId = project['labourId']?.toString() ?? '';
    final bool isAssigned = labourId.trim().isNotEmpty;

    String label;
    Color bgColor;
    Color textColor;
    IconData icon;

    switch (status) {
      case '1':
        if (isAssigned) {
          label = translateText('Assigned');
          bgColor = kBrandGreenTint;
          textColor = kBrandGreen;
          icon = Icons.assignment_ind_outlined;
        } else {
          label = translateText('Open');
          bgColor = kBrandGreenTint;
          textColor = kBrandGreen;
          icon = Icons.check_circle_outline;
        }
        break;
      case '2':
        label = translateText('Work Started');
        bgColor = kBrandBrownTint;
        textColor = kBrandBrown;
        icon = Icons.hourglass_top_outlined;
        break;
      case '3':
        label = translateText('Completed');
        bgColor = kBrandGreenTint;
        textColor = kBrandGreen;
        icon = Icons.check_circle_outline;
        break;
      case '4':
        label = translateText('Cancelled');
        bgColor = const Color(0xFFFEF2F2);
        textColor = const Color(0xFF991B1B);
        icon = Icons.cancel_outlined;
        break;
      default:
        label = translateText('Unknown');
        bgColor = kSurfaceBackground;
        textColor = kTextGrey;
        icon = Icons.help_outline;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: textColor.withOpacity(0.2), width: 0.8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: textColor),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }

  String _getDurationLabel(dynamic days) {
    if (days == null) return translateText('N/A');
    String daysStr = days.toString();
    int? daysInt = int.tryParse(daysStr);
    if (daysInt != null && daysInt > 0) {
      return '$daysInt ${translateText('days')}';
    }
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
      child: Scaffold(
        body: Container(
          color: kSurfaceBackground,
          child: SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: TextField(
                    controller: _searchController,
                    onChanged: filterProjects,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.search,
                          color: kBrandGreen),
                      hintText: AppLocalizations.of(context)!.searchlabour,
                      fillColor: Colors.white,
                      filled: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15.0),
                        borderSide:
                        const BorderSide(color: kBorderColor),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15.0),
                        borderSide: const BorderSide(
                            color: kBrandGreen, width: 2),
                      ),
                      suffixIcon: MicIconButton(controller: _searchController),
                    ),
                  ),
                ),
                Expanded(
                  child: isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : filteredProjects.isEmpty
                      ? Center(
                    child: Text(
                      AppLocalizations.of(context)!.noProjectsFound,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: kBrandBrown,
                      ),
                    ),
                  )
                      : ListView.builder(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 8),
                    itemCount: filteredProjects.length,
                    itemBuilder: (context, index) {
                      final project = filteredProjects[index];
                      String iconEmoji = '📋';
                      String projectType =
                          project['project_type'] ?? '';
                      if (projectType.contains('Crop'))
                        iconEmoji = '🌾';
                      else if (projectType.contains('Live'))
                        iconEmoji = '🐄';
                      else if (projectType.contains('Mach'))
                        iconEmoji = '🚜';
                      else if (projectType.contains('Post'))
                        iconEmoji = '📦';
                      else if (projectType.contains('Manage'))
                        iconEmoji = '📊';

                      String durationLabel =
                      _getDurationLabel(project['days']);
                      String budgetFormatted = NumberFormat('#,##0')
                          .format(project['budget'] ?? 0);
                      int applicants = project['applicants'] ?? 0;

                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: kBrandGreen
                                .withOpacity(0.12),
                            width: 1.2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: kBrandGreen
                                  .withOpacity(0.06),
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
                                    builder: (context) =>
                                        ProjectDetails(
                                          projectId: project['id']
                                              .toString(),
                                        ),
                                  ),
                                );
                              },
                              splashColor: kBrandGreen
                                  .withOpacity(0.1),
                              highlightColor: kBrandGreen
                                  .withOpacity(0.05),
                              child: Padding(
                                padding:
                                const EdgeInsets.all(18.0),
                                child: Column(
                                  crossAxisAlignment:
                                  CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          width: 48,
                                          height: 48,
                                          decoration: BoxDecoration(
                                            gradient:
                                            LinearGradient(
                                              begin: Alignment
                                                  .topLeft,
                                              end: Alignment
                                                  .bottomRight,
                                              colors: [
                                                kBrandGreenTint,
                                                kBrandGreen.withOpacity(0.05),
                                              ],
                                            ),
                                            borderRadius:
                                            BorderRadius.circular(
                                                14),
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
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                            CrossAxisAlignment
                                                .start,
                                            children: [
                                              Text(
                                                translateText(project[
                                                'title']
                                                    ?.toString() ??
                                                    'No Title'),
                                                style: const TextStyle(
                                                  fontSize: 16,
                                                  fontWeight:
                                                  FontWeight.w700,
                                                  color: kBrandGreen,
                                                  height: 1.3,
                                                ),
                                                maxLines: 2,
                                                overflow: TextOverflow
                                                    .ellipsis,
                                              ),
                                              const SizedBox(
                                                  height: 4),
                                              Container(
                                                padding:
                                                const EdgeInsets
                                                    .symmetric(
                                                    horizontal:
                                                    10,
                                                    vertical: 4),
                                                decoration:
                                                BoxDecoration(
                                                  color: kBrandGreenTint,
                                                  borderRadius:
                                                  BorderRadius
                                                      .circular(
                                                      20),
                                                ),
                                                child: Row(
                                                  mainAxisSize:
                                                  MainAxisSize
                                                      .min,
                                                  children: [
                                                    const Text('🌾',
                                                        style: TextStyle(
                                                            fontSize:
                                                            12)),
                                                    const SizedBox(
                                                        width: 4),
                                                    Text(
                                                      translateText(project[
                                                      'project_type'] ??
                                                          'N/A'),
                                                      style: TextStyle(
                                                        fontSize: 11,
                                                        fontWeight:
                                                        FontWeight
                                                            .w600,
                                                        color: kBrandGreen,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        _buildProjectStatusBadge(
                                            project),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    const Divider(
                                        color: kBorderColor,
                                        height: 1),
                                    const SizedBox(height: 10),
                                    Row(
                                      children: [
                                        const Icon(
                                            Icons
                                                .location_on_outlined,
                                            size: 14,
                                            color: kTextGrey),
                                        const SizedBox(width: 6),
                                        Expanded(
                                          child: Text(
                                            "${translateText(project['city'] ?? 'N/A')}, ${translateText(project['state'] ?? 'N/A')}",
                                            style: const TextStyle(
                                              fontSize: 13,
                                              fontWeight:
                                              FontWeight.w500,
                                              color: kTextGrey,
                                            ),
                                          ),
                                        ),
                                        if (applicants > 0)
                                          Container(
                                            padding:
                                            const EdgeInsets
                                                .symmetric(
                                                horizontal: 8,
                                                vertical: 3),
                                            decoration: BoxDecoration(
                                              color: kBrandGreenTint,
                                              borderRadius:
                                              BorderRadius
                                                  .circular(12),
                                              border: Border.all(
                                                  color: kBrandGreen.withOpacity(0.2),
                                                  width: 0.5),
                                            ),
                                            child: Row(
                                              mainAxisSize:
                                              MainAxisSize.min,
                                              children: [
                                                Icon(
                                                    Icons
                                                        .person_add_alt_1,
                                                    size: 11,
                                                    color: kBrandGreen),
                                                const SizedBox(
                                                    width: 3),
                                                Text(
                                                  '$applicants',
                                                  style:
                                                  const TextStyle(
                                                    fontSize: 10,
                                                    fontWeight:
                                                    FontWeight
                                                        .bold,
                                                    color: kBrandGreen,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    Row(
                                      children: [
                                        _buildPremiumChip(
                                          icon: Icons
                                              .people_outline,
                                          label:
                                          '${project['qty_labours'] ?? '0'} ${translate('Workers', 'मजदूर')}',
                                        ),
                                        const SizedBox(width: 8),
                                        _buildPremiumChip(
                                          icon:
                                          Icons.currency_rupee,
                                          label:
                                          '$budgetFormatted',
                                        ),
                                        const SizedBox(width: 8),
                                        _buildPremiumChip(
                                          icon: Icons
                                              .access_time_outlined,
                                          label: durationLabel,
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 16),
                                    Row(
                                      children: [
                                        if (applicants > 0)
                                          Expanded(
                                            child: SizedBox(
                                              height: 44,
                                              child: ElevatedButton(
                                                onPressed: () {
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) =>
                                                          ProjectApplicationsPage(
                                                            projectId: project[
                                                            'id']
                                                                .toString(),
                                                          ),
                                                    ),
                                                  ).then((_) {
                                                    fetchProjects();
                                                  });
                                                },
                                                style: ElevatedButton
                                                    .styleFrom(
                                                  backgroundColor:
                                                  kBrandBrown,
                                                  foregroundColor:
                                                  Colors.white,
                                                  shape:
                                                  RoundedRectangleBorder(
                                                    borderRadius:
                                                    BorderRadius
                                                        .circular(
                                                        10),
                                                  ),
                                                  padding:
                                                  EdgeInsets.zero,
                                                ),
                                                child: FittedBox(
                                                  fit: BoxFit
                                                      .scaleDown,
                                                  child: Text(
                                                    AppLocalizations.of(
                                                        context)!
                                                        .viewApplications,
                                                    style:
                                                    const TextStyle(
                                                      fontSize: 13,
                                                      fontWeight:
                                                      FontWeight
                                                          .bold,
                                                      color: Colors
                                                          .white,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        if (applicants > 0)
                                          const SizedBox(width: 8),
                                        Expanded(
                                          child: SizedBox(
                                            height: 44,
                                            child: ElevatedButton(
                                              onPressed: () {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        ProjectDetails(
                                                          projectId: project[
                                                          'id']
                                                              .toString(),
                                                        ),
                                                  ),
                                                ).then((_) {
                                                  fetchProjects();
                                                });
                                              },
                                              style: ElevatedButton
                                                  .styleFrom(
                                                backgroundColor:
                                                kBrandBrown,
                                                foregroundColor:
                                                Colors.white,
                                                shape:
                                                RoundedRectangleBorder(
                                                  borderRadius:
                                                  BorderRadius
                                                      .circular(
                                                      10),
                                                ),
                                                padding:
                                                EdgeInsets.zero,
                                              ),
                                              child: FittedBox(
                                                fit: BoxFit
                                                    .scaleDown,
                                                child: Text(
                                                  translateText(
                                                      'Details'),
                                                  style:
                                                  const TextStyle(
                                                    fontSize: 13,
                                                    fontWeight:
                                                    FontWeight
                                                        .bold,
                                                    color: Colors
                                                        .white,
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
                              ),
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

// --- UPDATED WITH BROWN CTA BUTTONS ---
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

  @override
  void initState() {
    super.initState();
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
    final Map<String, dynamic> requestBody = {
      'id': userId,
      'project_id': widget.projectId,
    };
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
            isLoading = false;
          });
        } else {
          setState(() => isLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to fetch project details')),
          );
        }
      } else {
        setState(() => isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to fetch project details')),
        );
      }
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  Future<void> unassignProject(String labourId, String projectId) async {
    setState(() => _isProcessing = true);
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
          await fetchProjectApplications();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(data['message'])),
          );
        }
      }
    } catch (e) {
      // ignore
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  Future<void> cancelConfirm(
      String projectId, String labourId, String cancelRemark) async {
    setState(() => _isProcessing = true);
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
          await fetchProjectApplications();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(data['message'])),
          );
        }
      }
    } catch (e) {
      // ignore
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  void showCancelDialog(BuildContext context, String labourId) {
    TextEditingController _cancelRemarkController = TextEditingController();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(translate('Cancel Remark', 'रद्द करने का कारण')),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _cancelRemarkController,
                decoration: InputDecoration(
                  labelText: translate(
                      'Enter Cancel Remark', 'रद्द करने का कारण दर्ज करें'),
                  border: OutlineInputBorder(),
                  suffixIcon:
                  MicIconButton(controller: _cancelRemarkController),
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
                    widget.projectId,
                    labourId,
                    _cancelRemarkController.text,
                  );
                  Navigator.of(context).pop();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Remark cannot be empty')),
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
    setState(() => _isProcessing = true);
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
          await fetchProjectApplications();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(data['message'])),
          );
        }
      }
    } catch (e) {
      // ignore
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  Future<void> _assignWithConfirmation(String labourId) async {
    bool? confirm = await _showAssignConfirmationDialog();
    if (confirm == true) {
      await assignProject(labourId);
    }
  }

  Future<bool?> _showAssignConfirmationDialog() {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(translate('Assign Project', 'परियोजना असाइन करें')),
        content: Text(translate(
            'Are you sure you want to assign this project to the selected worker?',
            'क्या आप सुनिश्चित हैं कि आप इस परियोजना को चयनित कार्यकर्ता को असाइन करना चाहते हैं?')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(translate('Cancel', 'रद्द करें')),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(translate('Yes', 'हाँ')),
          ),
        ],
      ),
    );
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
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Project assigned successfully')),
          );
          Future.delayed(const Duration(seconds: 1), () {
            Navigator.pop(context, true);
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(
                    'Failed to assign project: ${responseData['message']}')),
          );
        }
      }
    } catch (e) {
      // ignore
    }
  }

  Future<void> _unassignWithConfirmation(String labourId) async {
    bool? confirm = await _showUnassignConfirmationDialog();
    if (confirm == true) {
      await unassignProject(labourId, widget.projectId);
    }
  }

  Future<bool?> _showUnassignConfirmationDialog() {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(translate('Unassign Project', 'परियोजना अनअसाइन करें')),
        content: Text(translate(
            'Are you sure you want to unassign this project from the worker?',
            'क्या आप सुनिश्चित हैं कि आप इस परियोजना को कार्यकर्ता से अनअसाइन करना चाहते हैं?')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(translate('Cancel', 'रद्द करें')),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(translate('Yes', 'हाँ')),
          ),
        ],
      ),
    );
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
      backgroundColor: kSurfaceBackground,
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context)!.projectApplications,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: kBrandGreen,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: RefreshIndicator(
        onRefresh: fetchProjectApplications,
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : applications.isEmpty
            ? Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.person_off_outlined,
                size: 72,
                color: kTextGrey,
              ),
              const SizedBox(height: 16),
              Text(
                translateText('No applications found'),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: kTextGrey,
                ),
              ),
            ],
          ),
        )
            : ListView.builder(
          padding:
          const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          itemCount: applications.length,
          itemBuilder: (context, index) {
            final application = applications[index];
            String status = application['status']?.toString() ?? '0';
            Color statusColor;
            Color statusBg;
            switch (status) {
              case '0':
                statusColor = kTextGrey;
                statusBg = kSurfaceBackground;
                break;
              case '1':
                statusColor = kBrandGreen;
                statusBg = kBrandGreenTint;
                break;
              case '2':
                statusColor = kBrandBrown;
                statusBg = kBrandBrownTint;
                break;
              case '3':
                statusColor = kBrandGreen;
                statusBg = kBrandGreenTint;
                break;
              default:
                statusColor = const Color(0xFF991B1B);
                statusBg = const Color(0xFFFEF2F2);
            }

            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: kBorderColor,
                  width: 1.0,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: kBrandGreenTint,
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              (application['labour_name'] ?? 'W')[0]
                                  .toUpperCase(),
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: kBrandGreen,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                            CrossAxisAlignment.start,
                            children: [
                              Text(
                                translateText(application[
                                'labour_name'] ??
                                    'Unknown'),
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: kBrandGreen,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Container(
                                    padding:
                                    const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 3),
                                    decoration: BoxDecoration(
                                      color: statusBg,
                                      borderRadius:
                                      BorderRadius.circular(12),
                                      border: Border.all(
                                        color: statusColor
                                            .withOpacity(0.3),
                                        width: 0.5,
                                      ),
                                    ),
                                    child: Text(
                                      translateText(
                                          getStatusText(status)),
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: statusColor,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Icon(
                                    Icons.calendar_today_outlined,
                                    size: 12,
                                    color: kTextGrey,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    _formatDate(
                                        application['created_at'] ??
                                            ''),
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: kTextGrey,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Divider(color: kBorderColor, height: 1),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Icon(Icons.chat_bubble_outline,
                            size: 16, color: kTextGrey),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            translateText(
                                application['comment'] ?? 'N/A'),
                            style: const TextStyle(
                              fontSize: 13,
                              color: Color(0xFF475569),
                            ),
                          ),
                        ),
                        SpeakerIconButton(
                          text: translateText(
                              application['comment'] ?? 'N/A'),
                          size: 16,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.location_on_outlined,
                            size: 16, color: kTextGrey),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            translateText(
                                '${application['labour_address'] ?? ''}, ${application['labour_city'] ?? ''}, ${application['labour_state'] ?? ''}'),
                            style: const TextStyle(
                              fontSize: 13,
                              color: Color(0xFF475569),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment:
                      MainAxisAlignment.spaceEvenly,
                      children: [
                        Expanded(
                          child: SizedBox(
                            height: 40,
                            child: OutlinedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        ApplicationDetailPage(
                                          application: application,
                                        ),
                                  ),
                                );
                              },
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(
                                    color: kBrandBrown,
                                    width: 1.2),
                                shape: RoundedRectangleBorder(
                                  borderRadius:
                                  BorderRadius.circular(10),
                                ),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 4),
                              ),
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(
                                  AppLocalizations.of(context)!
                                      .viewDetails,
                                  style: const TextStyle(
                                    color: kBrandBrown,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        if (status == "0")
                          Expanded(
                            child: SizedBox(
                              height: 40,
                              child: ElevatedButton(
                                onPressed: _isProcessing
                                    ? null
                                    : () =>
                                    _assignWithConfirmation(
                                        application['labour_id']
                                            .toString()),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                  kBrandBrown, // BROWN
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius:
                                    BorderRadius.circular(10),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 4),
                                ),
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Text(
                                    translateText('Assign'),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          )
                        else if (status == "1")
                          Expanded(
                            child: SizedBox(
                              height: 40,
                              child: ElevatedButton(
                                onPressed: _isProcessing
                                    ? null
                                    : () =>
                                    _unassignWithConfirmation(
                                        application['labour_id']
                                            .toString()),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius:
                                    BorderRadius.circular(10),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 4),
                                ),
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Text(
                                    translateText('Unassign'),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          )
                        else if (status == "2")
                            Expanded(
                              child: SizedBox(
                                height: 40,
                                child: ElevatedButton(
                                  onPressed: _isProcessing
                                      ? null
                                      : () => confirmComplete(
                                      widget.projectId,
                                      application['labour_id']
                                          .toString()),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: kBrandBrown, // BROWN
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius:
                                      BorderRadius.circular(10),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 4),
                                  ),
                                  child: FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: Text(
                                      translateText('Complete'),
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            )
                          else
                            const SizedBox.shrink(),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
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
}