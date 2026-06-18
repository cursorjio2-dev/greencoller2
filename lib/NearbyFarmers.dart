// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:greencollar/speech_helper.dart';
// import 'package:flutter/services.dart';
// import 'package:greencollar/l10n/app_localizations.dart';
// import 'package:greencollar/main.dart' show LanguageProvider;
// import 'package:http/http.dart' as http;
// import 'package:flutter_secure_storage/flutter_secure_storage.dart';
// import 'package:provider/provider.dart';
// import 'package:translator/translator.dart';
// import 'package:url_launcher/url_launcher.dart';
// import 'package:greencollar/constants.dart' as Constants;
// import 'package:greencollar/FarmerDetails.dart';
//
// class FarmerPage extends StatefulWidget {
//   @override
//   _FarmerPageState createState() => _FarmerPageState();
// }
//
// class _FarmerPageState extends State<FarmerPage> {
//   final _secureStorage = const FlutterSecureStorage();
//   final TextEditingController _searchController = TextEditingController();
//   List<dynamic> farmers = [];
//   List<dynamic> filteredFarmers = [];
//   bool isLoading = false;
//   String _selectedLanguage = 'en';
//
//   // Active Filter state variables
//   String selectedFarmerType = 'All'; // 'All', 'progressive', 'verified'
//   String selectedCrop = 'All'; // 'All', crop name in English
//   String selectedAcresRange = 'All'; // 'All', '< 15 acres', '15-25 acres', '> 25 acres'
//   double selectedMaxDistance = 5.0; // Slider from 1.0 to 5.0 km
//
//   @override
//   void initState() {
//     super.initState();
//     loadLanguage();
//     fetchfarmers();
//   }
//
//   Future<void> loadLanguage() async {
//     String? language = await _secureStorage.read(key: 'selectedLanguage');
//     _selectedLanguage = language ?? 'en';
//   }
//
//   Map<String, Map<String, String>> _cachedTranslations = {};
//   Map<String, Map<String, String>> translations = Constants.AppConstants.translations;
//   final GoogleTranslator _translator = GoogleTranslator();
//
//   String translateText(String text) {
//     if (text.isEmpty) return "";
//     String targetLang = _selectedLanguage;
//
//     if (translations.containsKey(text) &&
//         translations[text]!.containsKey(targetLang)) {
//       return translations[text]![targetLang]!;
//     }
//
//     if (_cachedTranslations.containsKey(text) &&
//         _cachedTranslations[text]!.containsKey(targetLang)) {
//       return _cachedTranslations[text]![targetLang]!;
//     }
//
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
//
//       final translation = await _translator.translate(text, to: targetLang);
//
//       if (!translations.containsKey(text)) {
//         translations[text] = {
//           "en": text,
//           "hi": text
//         };
//       }
//
//       translations[text]![targetLang] = translation.text;
//       _cachedTranslations = translations;
//
//       if (!Constants.AppConstants.translations.containsKey(text)) {
//         Constants.AppConstants.translations[text] = {};
//       }
//       Constants.AppConstants.translations[text]![targetLang] = translation.text;
//
//       _cachedTranslations.putIfAbsent(text, () => {})[targetLang] = translation.text;
//       if (mounted) {
//         setState(() {});
//       }
//     } catch (e) {
//       print("Translation error: $e");
//     }
//   }
//
//   Map<String, dynamic> _enrichFarmer(Map<String, dynamic> farmer, int index) {
//     final String name = farmer['name'] ?? 'Unknown';
//     final int hash = name.hashCode;
//
//     // 1. Farmer Type / Tag
//     String farmerTypeEn = 'Verified Farmer';
//     String farmerTypeHi = 'सत्यापित किसान';
//     if (index % 2 == 0) {
//       farmerTypeEn = 'Progressive Farmer';
//       farmerTypeHi = 'प्रगतिशील किसान';
//     }
//
//     // 2. Distance: mock distance between 1.0 km and 5.0 km
//     final double distVal = 1.0 + (hash.abs() % 40) / 10.0;
//     final String distance = '${distVal.toStringAsFixed(1)} km';
//
//     // 3. Acres: mock land size
//     final int acres = 10 + (hash.abs() % 25);
//
//     // 4. Crops: select 1-2 crops deterministically
//     final List<Map<String, String>> cropOptions = [
//       {'en': 'Wheat', 'hi': 'गेहूँ', 'emoji': '🌾'},
//       {'en': 'Mustard', 'hi': 'सरसों', 'emoji': '🌼'},
//       {'en': 'Bajra', 'hi': 'बाजरा', 'emoji': '🌾'},
//       {'en': 'Sesame', 'hi': 'तिल', 'emoji': '🌾'},
//       {'en': 'Vegetables', 'hi': 'सब्जियाँ', 'emoji': '🥦'},
//       {'en': 'Tomato', 'hi': 'टमाटर', 'emoji': '🍅'},
//       {'en': 'Chickpea', 'hi': 'चना', 'emoji': '🥥'},
//       {'en': 'Groundnut', 'hi': 'मूंगफली', 'emoji': '🥜'},
//       {'en': 'Cotton', 'hi': 'कपास', 'emoji': '💮'},
//     ];
//
//     final int c1Idx = hash.abs() % cropOptions.length;
//     final int c2Idx = (hash.abs() + 3) % cropOptions.length;
//
//     final List<Map<String, String>> crops = [];
//     crops.add(cropOptions[c1Idx]);
//     if (hash.abs() % 10 < 8 && c1Idx != c2Idx) {
//       crops.add(cropOptions[c2Idx]);
//     }
//
//     return {
//       ...farmer,
//       'enriched': true,
//       'farmer_type_en': farmerTypeEn,
//       'farmer_type_hi': farmerTypeHi,
//       'distance': distance,
//       'distance_val': distVal,
//       'acres': acres,
//       'crops': crops,
//     };
//   }
//
//   void _applyFilters() {
//     setState(() {
//       filteredFarmers = farmers.where((farmer) {
//         // 1. Farmer Type Filter
//         if (selectedFarmerType != 'All') {
//           final isProgressive = farmer['farmer_type_hi'] == 'प्रगतिशील किसान' || farmer['farmer_type_en'] == 'Progressive Farmer';
//           if (selectedFarmerType == 'progressive' && !isProgressive) return false;
//           if (selectedFarmerType == 'verified' && isProgressive) return false;
//         }
//
//         // 2. Crop Type Filter
//         if (selectedCrop != 'All') {
//           final List<dynamic> cropsList = farmer['crops'] ?? [];
//           final hasCrop = cropsList.any((c) => c['en'] == selectedCrop || c['hi'] == selectedCrop);
//           if (!hasCrop) return false;
//         }
//
//         // 3. Acres / Land Area Filter
//         if (selectedAcresRange != 'All') {
//           final int acres = farmer['acres'] ?? 0;
//           if (selectedAcresRange == '< 15 acres' && acres >= 15) return false;
//           if (selectedAcresRange == '15-25 acres' && (acres < 15 || acres > 25)) return false;
//           if (selectedAcresRange == '> 25 acres' && acres <= 25) return false;
//         }
//
//         // 4. Max Distance Filter
//         final double distVal = farmer['distance_val'] ?? 0.0;
//         if (distVal > selectedMaxDistance) return false;
//
//         return true;
//       }).toList();
//     });
//   }
//
//   Future<void> fetchfarmers({String? searchQuery}) async {
//     setState(() {
//       isLoading = true;
//     });
//
//     String? userId = await _secureStorage.read(key: 'id');
//     if (userId == null && searchQuery == null) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('User ID not found in secure storage')),
//       );
//       setState(() {
//         isLoading = false;
//       });
//       return;
//     }
//
//     final Map<String, dynamic> requestBody =
//         (searchQuery != null && searchQuery.isNotEmpty)
//             ? {'searchquery': searchQuery}
//             : {'id': userId};
//
//     final apiUrl = (searchQuery != null && searchQuery.isNotEmpty)
//         ? '${Constants.AppConstants.apiUrl}labour/searchnearbyfarmers'
//         : '${Constants.AppConstants.apiUrl}labour/nearbyfarmers';
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
//           final rawData = responseData['data'] as List<dynamic>;
//           setState(() {
//             farmers = List.generate(rawData.length, (index) {
//               return _enrichFarmer(rawData[index] as Map<String, dynamic>, index);
//             });
//           });
//           _applyFilters();
//         } else {
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(content: Text(responseData['message'] ?? 'No farmers found')),
//           );
//         }
//       }
//     } catch (e) {
//       print(e);
//     } finally {
//       setState(() {
//         isLoading = false;
//       });
//     }
//   }
//
//   Future<void> _launchPhoneDialer(String phoneNumber) async {
//     final Uri url = Uri.parse('tel:$phoneNumber');
//     if (!await launchUrl(url)) {
//       throw 'Could not launch $url';
//     }
//   }
//
//   void _showFilterDialog() {
//     final language = Provider.of<LanguageProvider>(context, listen: false).selectedLanguage;
//
//     String translate(String enText, String hiText) {
//       return language == 'en' ? enText : hiText;
//     }
//
//     showDialog(
//       context: context,
//       builder: (context) => StatefulBuilder(
//         builder: (context, setStateDialog) {
//           return AlertDialog(
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(20),
//             ),
//             title: Row(
//               children: [
//                 const Icon(Icons.filter_list, color: Constants.AppColors.brand),
//                 const SizedBox(width: 10),
//                 Text(
//                   translate('Filter Farmers', 'किसान फ़िल्टर करें'),
//                   style: Constants.AppTypography.h2,
//                 ),
//               ],
//             ),
//             content: SingleChildScrollView(
//               child: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   // 1. Farmer Type Filter
//                   Padding(
//                     padding: const EdgeInsets.symmetric(vertical: 8.0),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           translate('Farmer Type', 'किसान का प्रकार'),
//                           style: Constants.AppTypography.label.copyWith(fontWeight: FontWeight.bold),
//                         ),
//                         const SizedBox(height: 6),
//                         DropdownButtonFormField<String>(
//                           value: selectedFarmerType,
//                           decoration: InputDecoration(
//                             contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//                             border: OutlineInputBorder(
//                               borderRadius: BorderRadius.circular(10),
//                             ),
//                           ),
//                           items: [
//                             DropdownMenuItem(value: 'All', child: Text(translate('All', 'सभी'))),
//                             DropdownMenuItem(value: 'progressive', child: Text(translate('Progressive Farmer', 'प्रगतिशील किसान'))),
//                             DropdownMenuItem(value: 'verified', child: Text(translate('Verified Farmer', 'सत्यापित किसान'))),
//                           ],
//                           onChanged: (value) {
//                             setStateDialog(() {
//                               selectedFarmerType = value!;
//                             });
//                           },
//                         ),
//                       ],
//                     ),
//                   ),
//
//                   // 2. Crop Type Filter
//                   Padding(
//                     padding: const EdgeInsets.symmetric(vertical: 8.0),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           translate('Crop Type', 'फसल का प्रकार'),
//                           style: Constants.AppTypography.label.copyWith(fontWeight: FontWeight.bold),
//                         ),
//                         const SizedBox(height: 6),
//                         DropdownButtonFormField<String>(
//                           value: selectedCrop,
//                           decoration: InputDecoration(
//                             contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//                             border: OutlineInputBorder(
//                               borderRadius: BorderRadius.circular(10),
//                             ),
//                           ),
//                           items: [
//                             DropdownMenuItem(value: 'All', child: Text(translate('All', 'सभी'))),
//                             ...[
//                               {'en': 'Wheat', 'hi': 'गेहूँ'},
//                               {'en': 'Mustard', 'hi': 'सरसों'},
//                               {'en': 'Bajra', 'hi': 'बाजरा'},
//                               {'en': 'Sesame', 'hi': 'तिल'},
//                               {'en': 'Vegetables', 'hi': 'सब्जियाँ'},
//                               {'en': 'Tomato', 'hi': 'टमाटर'},
//                               {'en': 'Chickpea', 'hi': 'चना'},
//                               {'en': 'Groundnut', 'hi': 'मूंगफली'},
//                               {'en': 'Cotton', 'hi': 'कपास'},
//                             ].map((crop) => DropdownMenuItem(
//                                   value: crop['en']!,
//                                   child: Text(translate(crop['en']!, crop['hi']!)),
//                                 )),
//                           ],
//                           onChanged: (value) {
//                             setStateDialog(() {
//                               selectedCrop = value!;
//                             });
//                           },
//                         ),
//                       ],
//                     ),
//                   ),
//
//                   // 3. Acres / Land Area Range Filter
//                   Padding(
//                     padding: const EdgeInsets.symmetric(vertical: 8.0),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           translate('Land Area (Acres)', 'भूमि क्षेत्र (एकड़)'),
//                           style: Constants.AppTypography.label.copyWith(fontWeight: FontWeight.bold),
//                         ),
//                         const SizedBox(height: 6),
//                         DropdownButtonFormField<String>(
//                           value: selectedAcresRange,
//                           decoration: InputDecoration(
//                             contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//                             border: OutlineInputBorder(
//                               borderRadius: BorderRadius.circular(10),
//                             ),
//                           ),
//                           items: [
//                             DropdownMenuItem(value: 'All', child: Text(translate('All', 'सभी'))),
//                             DropdownMenuItem(value: '< 15 acres', child: Text(translate('< 15 acres', '< 15 एकड़'))),
//                             DropdownMenuItem(value: '15-25 acres', child: Text(translate('15-25 acres', '15-25 एकड़'))),
//                             DropdownMenuItem(value: '> 25 acres', child: Text(translate('> 25 acres', '> 25 एकड़'))),
//                           ],
//                           onChanged: (value) {
//                             setStateDialog(() {
//                               selectedAcresRange = value!;
//                             });
//                           },
//                         ),
//                       ],
//                     ),
//                   ),
//
//                   // 4. Max Distance Filter
//                   Padding(
//                     padding: const EdgeInsets.symmetric(vertical: 8.0),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                           children: [
//                             Text(
//                               translate('Max Distance', 'अधिकतम दूरी'),
//                               style: Constants.AppTypography.label.copyWith(fontWeight: FontWeight.bold),
//                             ),
//                             Text(
//                               '${selectedMaxDistance.toStringAsFixed(1)} km',
//                               style: Constants.AppTypography.body.copyWith(
//                                 color: Constants.AppColors.brand,
//                                 fontWeight: FontWeight.bold,
//                               ),
//                             ),
//                           ],
//                         ),
//                         Slider(
//                           value: selectedMaxDistance,
//                           min: 1.0,
//                           max: 5.0,
//                           divisions: 8,
//                           activeColor: Constants.AppColors.brand,
//                           inactiveColor: Constants.AppColors.brandTint,
//                           onChanged: (value) {
//                             setStateDialog(() {
//                               selectedMaxDistance = value;
//                             });
//                           },
//                         ),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             actions: [
//               TextButton(
//                 onPressed: () {
//                   setStateDialog(() {
//                     selectedFarmerType = 'All';
//                     selectedCrop = 'All';
//                     selectedAcresRange = 'All';
//                     selectedMaxDistance = 5.0;
//                   });
//                   _applyFilters();
//                   Navigator.of(context).pop();
//                 },
//                 child: Text(
//                   translate('Reset', 'रीसेट'),
//                   style: const TextStyle(color: Colors.red),
//                 ),
//               ),
//               ElevatedButton(
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: Constants.AppColors.brand,
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(8),
//                   ),
//                 ),
//                 onPressed: () {
//                   _applyFilters();
//                   Navigator.of(context).pop();
//                 },
//                 child: Text(
//                   translate('Apply', 'लागू करें'),
//                   style: const TextStyle(color: Colors.white),
//                 ),
//               ),
//             ],
//           );
//         },
//       ),
//     );
//   }
//
//   List<bool> isExpandedList = [];
//   @override
//   Widget build(BuildContext context) {
//     final language = Provider.of<LanguageProvider>(context, listen: false).selectedLanguage;
//
//     return RefreshIndicator(
//       onRefresh: () async {
//         await loadLanguage();
//         await fetchfarmers();
//       },
//       child: WillPopScope(
//         onWillPop: () async {
//           SystemNavigator.pop();
//           return false;
//         },
//         child: Scaffold(
//           backgroundColor: Colors.white,
//           body: SafeArea(
//             child: ListView(
//               children: [
//                 Column(
//                   children: [
//                     // Header section containing Title, Location, and Filter Button
//                     Padding(
//                       padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
//                       child: Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         crossAxisAlignment: CrossAxisAlignment.center,
//                         children: [
//                           Expanded(
//                             child: Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 Text(
//                                   translateText('Nearby Farmers'),
//                                   style: Constants.AppTypography.display.copyWith(
//                                     fontSize: 22,
//                                     fontWeight: FontWeight.w800,
//                                     color: Constants.AppColors.ink,
//                                   ),
//                                 ),
//                                 const SizedBox(height: 4),
//                                 Row(
//                                   children: [
//                                     const Icon(
//                                       Icons.location_on,
//                                       size: 14,
//                                       color: Constants.AppColors.brand,
//                                     ),
//                                     const SizedBox(width: 4),
//                                     Expanded(
//                                       child: Text(
//                                         translateText('Near You • Jaipur, Rajasthan'),
//                                         style: Constants.AppTypography.subhead.copyWith(
//                                           fontSize: 13,
//                                           fontWeight: FontWeight.w600,
//                                           color: Constants.AppColors.inkSoft,
//                                         ),
//                                         overflow: TextOverflow.ellipsis,
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                               ],
//                             ),
//                           ),
//                           const SizedBox(width: 12),
//                           // Filter Button
//                           OutlinedButton.icon(
//                             onPressed: _showFilterDialog,
//                             icon: const Icon(
//                               Icons.filter_list,
//                               size: 16,
//                               color: Constants.AppColors.brand,
//                             ),
//                             label: Text(
//                               translateText('Filter'),
//                               style: Constants.AppTypography.label.copyWith(
//                                 color: Constants.AppColors.brandDeep,
//                                 fontWeight: FontWeight.bold,
//                               ),
//                             ),
//                             style: OutlinedButton.styleFrom(
//                               side: const BorderSide(color: Constants.AppColors.border, width: 1.0),
//                               padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
//                               shape: RoundedRectangleBorder(
//                                 borderRadius: BorderRadius.circular(14),
//                               ),
//                               backgroundColor: Constants.AppColors.brandTint,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//
//                     // Search Bar
//                     Padding(
//                       padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
//                       child: Container(
//                         decoration: const BoxDecoration(
//                           boxShadow: [Constants.AppShadows.soft],
//                         ),
//                         child: TextField(
//                           controller: _searchController,
//                           onChanged: (value) => fetchfarmers(searchQuery: value),
//                           style: Constants.AppTypography.body,
//                           decoration: InputDecoration(
//                             prefixIcon: const Icon(Icons.search, color: Constants.AppColors.inkSoft),
//                             suffixIcon: MicIconButton(controller: _searchController),
//                             hintText: translateText('Search farmer name...'),
//                             hintStyle: Constants.AppTypography.body.copyWith(color: Constants.AppColors.inkSoft),
//                             fillColor: Constants.AppColors.card,
//                             filled: true,
//                             contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
//                             enabledBorder: OutlineInputBorder(
//                               borderRadius: BorderRadius.circular(16),
//                               borderSide: const BorderSide(color: Constants.AppColors.border, width: 1.0),
//                             ),
//                             focusedBorder: OutlineInputBorder(
//                               borderRadius: BorderRadius.circular(16),
//                               borderSide: const BorderSide(color: Constants.AppColors.brand, width: 1.5),
//                             ),
//                           ),
//                         ),
//                       ),
//                     ),
//                     const SizedBox(height: 8),
//
//                     isLoading
//                         ? const Center(child: Padding(
//                             padding: EdgeInsets.all(40.0),
//                             child: CircularProgressIndicator(),
//                           ))
//                         : filteredFarmers.isEmpty
//                             ? Center(
//                                 child: Padding(
//                                   padding: const EdgeInsets.all(40.0),
//                                   child: Text(
//                                     translateText('No farmers found'),
//                                     style: Constants.AppTypography.h3.copyWith(
//                                       color: Constants.AppColors.inkSoft,
//                                     ),
//                                   ),
//                                 ),
//                               )
//                             : ListView.builder(
//                                 shrinkWrap: true,
//                                 physics: const NeverScrollableScrollPhysics(),
//                                 itemCount: filteredFarmers.length,
//                                 itemBuilder: (context, index) {
//                                   final farmer = filteredFarmers[index];
//                                   final String name = farmer['name'] ?? 'Unknown';
//                                   final String farmerType = translateText(farmer['farmer_type_hi'] ?? 'सत्यापित किसान');
//                                   final String distance = farmer['distance'] ?? '1.2 km';
//                                   final String city = translateText(farmer['city'] ?? 'Unknown');
//                                   final List<dynamic> crops = farmer['crops'] ?? [];
//                                   final int acres = farmer['acres'] ?? 0;
//                                   final bool isProgressive = farmer['farmer_type_en'] == 'Progressive Farmer';
//
//                                   return GestureDetector(
//                                     onTap: () {
//                                       Navigator.push(
//                                         context,
//                                         MaterialPageRoute(
//                                           builder: (context) => FarmerDetailsPage(farmer: farmer),
//                                         ),
//                                       );
//                                     },
//                                     child: Container(
//                                       margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
//                                       decoration: BoxDecoration(
//                                         color: Constants.AppColors.card,
//                                         borderRadius: BorderRadius.circular(16),
//                                         border: Border.all(color: Constants.AppColors.border, width: 1.0),
//                                         boxShadow: const [Constants.AppShadows.soft],
//                                       ),
//                                       child: Padding(
//                                         padding: const EdgeInsets.all(10.0),
//                                         child: Row(
//                                           crossAxisAlignment: CrossAxisAlignment.start,
//                                           children: [
//                                             // Profile Avatar with green check badge overlay
//                                             Stack(
//                                               children: [
//                                                 Container(
//                                                   width: 54,
//                                                   height: 54,
//                                                   decoration: BoxDecoration(
//                                                     color: Constants.AppColors.brandTint,
//                                                     borderRadius: BorderRadius.circular(27),
//                                                     border: Border.all(color: Constants.AppColors.brandSoft, width: 1.5),
//                                                   ),
//                                                   child: ClipRRect(
//                                                     borderRadius: BorderRadius.circular(27),
//                                                     child: (farmer['profile'] != null && farmer['profile'].toString().isNotEmpty)
//                                                         ? Image.network(
//                                                             '${Constants.AppConstants.folderUrl}storage/upload/farmerprofile/${farmer['profile']}',
//                                                             fit: BoxFit.cover,
//                                                             errorBuilder: (context, error, stackTrace) {
//                                                               return const Icon(Icons.person, color: Constants.AppColors.brand, size: 28);
//                                                             },
//                                                           )
//                                                         : const Icon(Icons.person, color: Constants.AppColors.brand, size: 28),
//                                                   ),
//                                                 ),
//                                                 Positioned(
//                                                   bottom: 0,
//                                                   right: 0,
//                                                   child: Container(
//                                                     padding: const EdgeInsets.all(1),
//                                                     decoration: const BoxDecoration(
//                                                       color: Colors.white,
//                                                       shape: BoxShape.circle,
//                                                     ),
//                                                     child: Container(
//                                                       padding: const EdgeInsets.all(2),
//                                                       decoration: const BoxDecoration(
//                                                         color: Colors.green,
//                                                         shape: BoxShape.circle,
//                                                       ),
//                                                       child: const Icon(
//                                                         Icons.check,
//                                                         color: Colors.white,
//                                                         size: 8,
//                                                       ),
//                                                     ),
//                                                   ),
//                                                 ),
//                                               ],
//                                             ),
//                                             const SizedBox(width: 12),
//                                             // Info Details
//                                             Expanded(
//                                               child: Column(
//                                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                                 children: [
//                                                   // Name, distance and location pin
//                                                   Row(
//                                                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                                                     crossAxisAlignment: CrossAxisAlignment.start,
//                                                     children: [
//                                                       Expanded(
//                                                         child: Column(
//                                                           crossAxisAlignment: CrossAxisAlignment.start,
//                                                           children: [
//                                                             Text(
//                                                               name,
//                                                               style: Constants.AppTypography.h3.copyWith(
//                                                                 color: Constants.AppColors.ink,
//                                                                 fontWeight: FontWeight.bold,
//                                                                 fontSize: 15,
//                                                               ),
//                                                               overflow: TextOverflow.ellipsis,
//                                                             ),
//                                                             const SizedBox(height: 2),
//                                                             Container(
//                                                               padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
//                                                               decoration: BoxDecoration(
//                                                                 color: isProgressive
//                                                                     ? const Color(0xFFE8F5E9)
//                                                                     : const Color(0xFFE3F2FD),
//                                                                 borderRadius: BorderRadius.circular(4),
//                                                               ),
//                                                               child: Text(
//                                                                 farmerType,
//                                                                 style: Constants.AppTypography.micro.copyWith(
//                                                                   color: isProgressive
//                                                                       ? const Color(0xFF2E7D32)
//                                                                       : const Color(0xFF1565C0),
//                                                                   fontSize: 10,
//                                                                   fontWeight: FontWeight.bold,
//                                                                 ),
//                                                               ),
//                                                             ),
//                                                           ],
//                                                         ),
//                                                       ),
//                                                       const SizedBox(width: 6),
//                                                       Row(
//                                                         mainAxisSize: MainAxisSize.min,
//                                                         children: [
//                                                           Text(
//                                                             distance,
//                                                             style: Constants.AppTypography.label.copyWith(
//                                                               color: Constants.AppColors.inkSoft,
//                                                               fontSize: 11,
//                                                             ),
//                                                           ),
//                                                           const SizedBox(width: 2),
//                                                           const Icon(
//                                                             Icons.location_on,
//                                                             size: 11,
//                                                             color: Constants.AppColors.inkSoft,
//                                                           ),
//                                                         ],
//                                                       ),
//                                                     ],
//                                                   ),
//                                                   const SizedBox(height: 4),
//                                                   // Location
//                                                   Row(
//                                                     children: [
//                                                       const Icon(
//                                                         Icons.location_on_outlined,
//                                                         size: 12,
//                                                         color: Constants.AppColors.inkSoft,
//                                                       ),
//                                                       const SizedBox(width: 4),
//                                                       Expanded(
//                                                         child: Text(
//                                                           city,
//                                                           style: Constants.AppTypography.body.copyWith(
//                                                             color: Constants.AppColors.inkSoft,
//                                                             fontSize: 12,
//                                                           ),
//                                                           overflow: TextOverflow.ellipsis,
//                                                         ),
//                                                       ),
//                                                     ],
//                                                   ),
//                                                   const SizedBox(height: 6),
//                                                   // Crop Tags
//                                                   if (crops.isNotEmpty)
//                                                     Padding(
//                                                       padding: const EdgeInsets.only(bottom: 6.0),
//                                                       child: Wrap(
//                                                         spacing: 4,
//                                                         runSpacing: 4,
//                                                         children: crops.map<Widget>((crop) {
//                                                           final String cropName = translateText(crop['hi'] ?? '');
//                                                           final String emoji = crop['emoji'] ?? '';
//                                                           return Container(
//                                                             padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
//                                                             decoration: BoxDecoration(
//                                                               color: Constants.AppColors.surface2,
//                                                               borderRadius: BorderRadius.circular(6),
//                                                               border: Border.all(color: Constants.AppColors.border, width: 0.5),
//                                                             ),
//                                                             child: Row(
//                                                               mainAxisSize: MainAxisSize.min,
//                                                               children: [
//                                                                 Text(emoji, style: const TextStyle(fontSize: 10)),
//                                                                 const SizedBox(width: 3),
//                                                                 Text(
//                                                                   cropName,
//                                                                   style: Constants.AppTypography.label.copyWith(
//                                                                     color: Constants.AppColors.ink,
//                                                                     fontSize: 10,
//                                                                     fontWeight: FontWeight.w600,
//                                                                   ),
//                                                                 ),
//                                                               ],
//                                                             ),
//                                                           );
//                                                         }).toList(),
//                                                       ),
//                                                     ),
//                                                   // Land Area
//                                                   Row(
//                                                     children: [
//                                                       const Icon(
//                                                         Icons.agriculture,
//                                                         size: 12,
//                                                         color: Constants.AppColors.brand,
//                                                       ),
//                                                       const SizedBox(width: 4),
//                                                       Text(
//                                                         '$acres ${translateText('acres')}',
//                                                         style: Constants.AppTypography.body.copyWith(
//                                                           color: Constants.AppColors.ink,
//                                                           fontSize: 12,
//                                                           fontWeight: FontWeight.w500,
//                                                         ),
//                                                       ),
//                                                     ],
//                                                   ),
//                                                 ],
//                                               ),
//                                             ),
//                                           ],
//                                         ),
//                                       ),
//                                     ),
//                                   );
//                                 },
//                               ),
//                   ],
//                 ),
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
import 'package:flutter/services.dart';
import 'package:greencollar/l10n/app_localizations.dart';
import 'package:greencollar/main.dart' show LanguageProvider;
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart';
import 'package:translator/translator.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:greencollar/constants.dart' as Constants;
import 'package:greencollar/FarmerDetails.dart';

class FarmerPage extends StatefulWidget {
  @override
  _FarmerPageState createState() => _FarmerPageState();
}

class _FarmerPageState extends State<FarmerPage> {
  final _secureStorage = const FlutterSecureStorage();
  final TextEditingController _searchController = TextEditingController();
  List<dynamic> farmers = [];
  List<dynamic> filteredFarmers = [];
  bool isLoading = false;
  bool isLoadingMore = false;
  String _selectedLanguage = 'en';

  // Pagination
  int _currentPage = 1;
  int _totalPages = 1;
  final int _perPage = 20;
  bool _hasMoreData = true;
  final ScrollController _scrollController = ScrollController();

  // Filter state variables
  String selectedFarmerType = 'All';
  String selectedCrop = 'All';

  // Real location from API
  String _userCity = '';
  String _userState = '';

  @override
  void initState() {
    super.initState();
    loadLanguage();
    _loadUserLocation();
    fetchfarmers();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _loadMoreFarmers();
    }
  }

  Future<void> _loadUserLocation() async {
    try {
      String? userId = await _secureStorage.read(key: 'id');
      if (userId != null) {
        // You might have a separate API to get user details
        // For now, we'll extract from first farmer response
      }
    } catch (e) {
      print('Error loading location: $e');
    }
  }

  Future<void> loadLanguage() async {
    String? language = await _secureStorage.read(key: 'selectedLanguage');
    setState(() {
      _selectedLanguage = language ?? 'en';
    });
  }

  Map<String, Map<String, String>> _cachedTranslations = {};
  Map<String, Map<String, String>> translations = Constants.AppConstants.translations;
  final GoogleTranslator _translator = GoogleTranslator();

  String translateText(String text) {
    if (text.isEmpty) return "";
    String targetLang = _selectedLanguage;

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
        translations[text] = {
          "en": text,
          "hi": text
        };
      }

      translations[text]![targetLang] = translation.text;
      _cachedTranslations = translations;

      if (!Constants.AppConstants.translations.containsKey(text)) {
        Constants.AppConstants.translations[text] = {};
      }
      Constants.AppConstants.translations[text]![targetLang] = translation.text;

      _cachedTranslations.putIfAbsent(text, () => {})[targetLang] = translation.text;
      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      print("Translation error: $e");
    }
  }

  // Get real farmer type based on available data
  String _getFarmerType(Map<String, dynamic> farmer) {
    bool hasEducation = farmer['education'] != null && farmer['education'].toString().isNotEmpty;
    bool hasSkills = farmer['skills'] != null && farmer['skills'].toString().isNotEmpty;
    bool hasCertifications = farmer['certifications'] != null && farmer['certifications'].toString().isNotEmpty;

    if (hasSkills || hasCertifications) {
      return 'Progressive Farmer';
    } else if (hasEducation) {
      return 'Verified Farmer';
    }
    return 'Farmer';
  }

  // Get real crops from skills or generate from available data
  List<Map<String, String>> _getCropsFromFarmer(Map<String, dynamic> farmer) {
    List<Map<String, String>> crops = [];

    String? skills = farmer['skills'];
    if (skills != null && skills.isNotEmpty) {
      List<String> skillList = skills.split(',').map((s) => s.trim()).toList();
      for (String skill in skillList) {
        if (skill.isNotEmpty) {
          crops.add({
            'en': skill,
            'hi': skill,
            'emoji': _getEmojiForCrop(skill),
          });
        }
      }
    }

    if (crops.isEmpty) {
      int id = farmer['id'] ?? 0;
      List<String> defaultCrops = ['Wheat', 'Mustard', 'Bajra', 'Vegetables', 'Cotton'];
      int index = id % defaultCrops.length;
      crops.add({
        'en': defaultCrops[index],
        'hi': defaultCrops[index],
        'emoji': _getEmojiForCrop(defaultCrops[index]),
      });
    }

    return crops.take(2).toList();
  }

  String _getEmojiForCrop(String crop) {
    Map<String, String> cropEmojis = {
      'Wheat': '🌾',
      'Mustard': '🌼',
      'Bajra': '🌾',
      'Sesame': '🌾',
      'Vegetables': '🥦',
      'Tomato': '🍅',
      'Chickpea': '🥥',
      'Groundnut': '🥜',
      'Cotton': '💮',
      'Dairy': '🐄',
      'Poultry': '🐔',
      'Goat': '🐐',
      'Sheep': '🐑',
    };

    for (var entry in cropEmojis.entries) {
      if (crop.toLowerCase().contains(entry.key.toLowerCase())) {
        return entry.value;
      }
    }
    return '🌾';
  }

  String _getLocationString(Map<String, dynamic> farmer) {
    String city = farmer['city'] ?? '';
    String state = farmer['state'] ?? '';
    if (city.isNotEmpty && state.isNotEmpty) {
      return '$city, $state';
    } else if (city.isNotEmpty) {
      return city;
    } else if (state.isNotEmpty) {
      return state;
    }
    return 'Location not available';
  }

  void _applyFilters() {
    setState(() {
      filteredFarmers = farmers.where((farmer) {
        if (selectedFarmerType != 'All') {
          final farmerType = _getFarmerType(farmer);
          final isProgressive = farmerType == 'Progressive Farmer';
          if (selectedFarmerType == 'progressive' && !isProgressive) return false;
          if (selectedFarmerType == 'verified' && isProgressive) return false;
        }

        if (selectedCrop != 'All') {
          final List<Map<String, String>> cropsList = _getCropsFromFarmer(farmer);
          final hasCrop = cropsList.any((c) =>
          c['en'] == selectedCrop ||
              c['hi'] == selectedCrop ||
              (farmer['skills']?.toString().toLowerCase() ?? '').contains(selectedCrop.toLowerCase())
          );
          if (!hasCrop) return false;
        }

        return true;
      }).toList();
    });
  }

  Future<void> fetchfarmers({String? searchQuery, bool isLoadMore = false}) async {
    if (isLoadMore && !_hasMoreData) return;
    if (isLoadMore && isLoadingMore) return;

    setState(() {
      if (isLoadMore) {
        isLoadingMore = true;
      } else {
        isLoading = true;
        _currentPage = 1;
        _hasMoreData = true;
      }
    });

    String? userId = await _secureStorage.read(key: 'id');
    if (userId == null && searchQuery == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User ID not found in secure storage')),
      );
      setState(() {
        isLoading = false;
        isLoadingMore = false;
      });
      return;
    }

    final Map<String, dynamic> requestBody = {
      'id': userId,
      'page': _currentPage,
      'per_page': _perPage,
    };

    if (searchQuery != null && searchQuery.isNotEmpty) {
      requestBody['searchquery'] = searchQuery;
    }

    final String apiUrl = (searchQuery != null && searchQuery.isNotEmpty)
        ? '${Constants.AppConstants.apiUrl}labour/searchnearbyfarmers'
        : '${Constants.AppConstants.apiUrl}labour/nearbyfarmers';

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData['success'] == true) {
          final rawData = responseData['data'] as List<dynamic>;

          if (rawData.isNotEmpty && _userCity.isEmpty) {
            final firstFarmer = rawData[0] as Map<String, dynamic>;
            setState(() {
              _userCity = firstFarmer['city'] ?? '';
              _userState = firstFarmer['state'] ?? '';
            });
          }

          setState(() {
            if (isLoadMore) {
              farmers.addAll(rawData);
              _currentPage++;
            } else {
              farmers = rawData;
              _currentPage = 2;
            }

            _hasMoreData = rawData.length >= _perPage;
            _applyFilters();
          });
        } else {
          if (!isLoadMore) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(responseData['message'] ?? 'No farmers found')),
            );
          }
        }
      } else {
        if (!isLoadMore) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to load farmers')),
          );
        }
      }
    } catch (e) {
      print('Error fetching farmers: $e');
      if (!isLoadMore) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    } finally {
      setState(() {
        isLoading = false;
        isLoadingMore = false;
      });
    }
  }

  void _loadMoreFarmers() {
    if (!isLoading && !isLoadingMore && _hasMoreData) {
      fetchfarmers(isLoadMore: true);
    }
  }

  Future<void> _refreshFarmers() async {
    await loadLanguage();
    await fetchfarmers();
  }

  void _showFilterDialog() {
    final language = Provider.of<LanguageProvider>(context, listen: false).selectedLanguage;

    String translate(String enText, String hiText) {
      return language == 'en' ? enText : hiText;
    }

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateDialog) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: Row(
              children: [
                const Icon(Icons.filter_list, color: Constants.AppColors.brand),
                const SizedBox(width: 10),
                Text(
                  translate('Filter Farmers', 'किसान फ़िल्टर करें'),
                  style: Constants.AppTypography.h2,
                ),
              ],
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          translate('Farmer Type', 'किसान का प्रकार'),
                          style: Constants.AppTypography.label.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 6),
                        DropdownButtonFormField<String>(
                          value: selectedFarmerType,
                          decoration: InputDecoration(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          items: [
                            DropdownMenuItem(value: 'All', child: Text(translate('All', 'सभी'))),
                            DropdownMenuItem(value: 'progressive', child: Text(translate('Progressive Farmer', 'प्रगतिशील किसान'))),
                            DropdownMenuItem(value: 'verified', child: Text(translate('Verified Farmer', 'सत्यापित किसान'))),
                          ],
                          onChanged: (value) {
                            setStateDialog(() {
                              selectedFarmerType = value!;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          translate('Crop Type', 'फसल का प्रकार'),
                          style: Constants.AppTypography.label.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 6),
                        DropdownButtonFormField<String>(
                          value: selectedCrop,
                          decoration: InputDecoration(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          items: [
                            DropdownMenuItem(value: 'All', child: Text(translate('All', 'सभी'))),
                            ...[
                              {'en': 'Wheat', 'hi': 'गेहूँ'},
                              {'en': 'Mustard', 'hi': 'सरसों'},
                              {'en': 'Bajra', 'hi': 'बाजरा'},
                              {'en': 'Sesame', 'hi': 'तिल'},
                              {'en': 'Vegetables', 'hi': 'सब्जियाँ'},
                              {'en': 'Tomato', 'hi': 'टमाटर'},
                              {'en': 'Chickpea', 'hi': 'चना'},
                              {'en': 'Groundnut', 'hi': 'मूंगफली'},
                              {'en': 'Cotton', 'hi': 'कपास'},
                            ].map((crop) => DropdownMenuItem(
                              value: crop['en']!,
                              child: Text(translate(crop['en']!, crop['hi']!)),
                            )),
                          ],
                          onChanged: (value) {
                            setStateDialog(() {
                              selectedCrop = value!;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  setStateDialog(() {
                    selectedFarmerType = 'All';
                    selectedCrop = 'All';
                  });
                  _applyFilters();
                  Navigator.of(context).pop();
                },
                child: Text(
                  translate('Reset', 'रीसेट'),
                  style: const TextStyle(color: Colors.red),
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Constants.AppColors.brand,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () {
                  _applyFilters();
                  Navigator.of(context).pop();
                },
                child: Text(
                  translate('Apply', 'लागू करें'),
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final language = Provider.of<LanguageProvider>(context, listen: false).selectedLanguage;

    return RefreshIndicator(
      onRefresh: _refreshFarmers,
      child: WillPopScope(
        onWillPop: () async {
          SystemNavigator.pop();
          return false;
        },
        child: Scaffold(
          backgroundColor: Colors.white,
          body: SafeArea(
            child: Column(
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              translateText('Nearby Farmers'),
                              style: Constants.AppTypography.display.copyWith(
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                                color: Constants.AppColors.ink,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(
                                  Icons.location_on,
                                  size: 14,
                                  color: Constants.AppColors.brand,
                                ),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    _userCity.isNotEmpty
                                        ? translateText('Near You • $_userCity${_userState.isNotEmpty ? ', $_userState' : ''}')
                                        : translateText('Finding location...'),
                                    style: Constants.AppTypography.subhead.copyWith(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: Constants.AppColors.inkSoft,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      OutlinedButton.icon(
                        onPressed: _showFilterDialog,
                        icon: const Icon(
                          Icons.filter_list,
                          size: 16,
                          color: Constants.AppColors.brand,
                        ),
                        label: Text(
                          translateText('Filter'),
                          style: Constants.AppTypography.label.copyWith(
                            color: Constants.AppColors.brandDeep,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Constants.AppColors.border, width: 1.0),
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          backgroundColor: Constants.AppColors.brandTint,
                        ),
                      ),
                    ],
                  ),
                ),

                // Search Bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: Container(
                    decoration: const BoxDecoration(
                      boxShadow: [Constants.AppShadows.soft],
                    ),
                    child: TextField(
                      controller: _searchController,
                      onChanged: (value) {
                        if (value.isEmpty) {
                          fetchfarmers();
                        } else {
                          fetchfarmers(searchQuery: value);
                        }
                      },
                      style: Constants.AppTypography.body,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.search, color: Constants.AppColors.inkSoft),
                        suffixIcon: MicIconButton(controller: _searchController),
                        hintText: translateText('Search farmer name...'),
                        hintStyle: Constants.AppTypography.body.copyWith(color: Constants.AppColors.inkSoft),
                        fillColor: Constants.AppColors.card,
                        filled: true,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(color: Constants.AppColors.border, width: 1.0),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(color: Constants.AppColors.brand, width: 1.5),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),

                // Farmer List
                Expanded(
                  child: isLoading
                      ? const Center(child: Padding(
                    padding: EdgeInsets.all(40.0),
                    child: CircularProgressIndicator(),
                  ))
                      : filteredFarmers.isEmpty
                      ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(40.0),
                      child: Text(
                        translateText('No farmers found'),
                        style: Constants.AppTypography.h3.copyWith(
                          color: Constants.AppColors.inkSoft,
                        ),
                      ),
                    ),
                  )
                      : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.only(bottom: 16),
                    itemCount: filteredFarmers.length + (isLoadingMore ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == filteredFarmers.length) {
                        return const Padding(
                          padding: EdgeInsets.symmetric(vertical: 20.0),
                          child: Center(child: CircularProgressIndicator()),
                        );
                      }

                      final farmer = filteredFarmers[index];
                      final String name = farmer['name'] ?? 'Unknown';
                      final String farmerType = _getFarmerType(farmer);
                      final String translatedType = translateText(farmerType);
                      final String location = _getLocationString(farmer);
                      final List<Map<String, String>> crops = _getCropsFromFarmer(farmer);
                      final bool isProgressive = farmerType == 'Progressive Farmer';

                      String skills = farmer['skills'] ?? '';
                      String education = farmer['education'] ?? '';
                      String aboutMe = farmer['aboutme'] ?? '';

                      String subtitle = '';
                      if (skills.isNotEmpty) {
                        subtitle = skills;
                      } else if (education.isNotEmpty) {
                        subtitle = education;
                      } else if (aboutMe.isNotEmpty) {
                        subtitle = aboutMe;
                      }

                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => FarmerDetailsPage(farmer: farmer),
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
                                // Profile Avatar
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
                                        child: (farmer['profile'] != null && farmer['profile'].toString().isNotEmpty)
                                            ? Image.network(
                                          '${Constants.AppConstants.folderUrl}storage/upload/farmerprofile/${farmer['profile']}',
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
                                // Info Details
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      // Top row: Name + Crop tags (right-aligned)
                                      Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          // Name and type badge
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  name,
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
                                                    color: isProgressive
                                                        ? const Color(0xFFE8F5E9)
                                                        : const Color(0xFFE3F2FD),
                                                    borderRadius: BorderRadius.circular(4),
                                                  ),
                                                  child: Text(
                                                    translatedType,
                                                    style: Constants.AppTypography.micro.copyWith(
                                                      color: isProgressive
                                                          ? const Color(0xFF2E7D32)
                                                          : const Color(0xFF1565C0),
                                                      fontSize: 10,
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          // Crop tags - right top corner
                                          if (crops.isNotEmpty)
                                            Flexible(
                                              child: Wrap(
                                                alignment: WrapAlignment.end,
                                                spacing: 4,
                                                runSpacing: 2,
                                                children: crops.map<Widget>((crop) {
                                                  final String cropName = translateText(crop['en'] ?? '');
                                                  final String emoji = crop['emoji'] ?? '🌾';
                                                  return Container(
                                                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                                                    decoration: BoxDecoration(
                                                      color: Constants.AppColors.surface2,
                                                      borderRadius: BorderRadius.circular(6),
                                                      border: Border.all(color: Constants.AppColors.border, width: 0.5),
                                                    ),
                                                    child: Row(
                                                      mainAxisSize: MainAxisSize.min,
                                                      children: [
                                                        Text(emoji, style: const TextStyle(fontSize: 9)),
                                                        const SizedBox(width: 2),
                                                        Text(
                                                          cropName,
                                                          style: Constants.AppTypography.micro.copyWith(
                                                            color: Constants.AppColors.ink,
                                                            fontSize: 9,
                                                            fontWeight: FontWeight.w600,
                                                          ),
                                                        ),
                                                      ],
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
                                              location,
                                              style: Constants.AppTypography.body.copyWith(
                                                color: Constants.AppColors.inkSoft,
                                                fontSize: 12,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                      // Skills/Subtitle
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
                                      // Removed separate crops section – now in top row
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
      ),
    );
  }
}