// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:greencollar/speech_helper.dart';
// import 'package:flutter/services.dart';
// import 'package:greencollar/l10n/app_localizations.dart';
// import 'package:greencollar/main.dart';
// import 'package:greencollar/workerdetails.dart';
// import 'package:http/http.dart' as http;
// import 'package:flutter_secure_storage/flutter_secure_storage.dart';
// import 'package:provider/provider.dart';
// import 'package:translator/translator.dart';
// import 'package:url_launcher/url_launcher.dart';
// import 'package:greencollar/constants.dart' as Constants;
//
// class LabourPage extends StatefulWidget {
//   @override
//   _LabourPageState createState() => _LabourPageState();
// }
//
// class _LabourPageState extends State<LabourPage> {
//   final _secureStorage = const FlutterSecureStorage();
//   final TextEditingController _searchController = TextEditingController();
//   List<dynamic> labours = [];
//   bool isLoading = false;
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
//   @override
//   void initState() {
//     super.initState();
//     loadLanguage();
//     fetchLabours();
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
//   List<bool> isExpandedList = [];
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
//                 content: Text(responseData['message'] ?? 'No Workers found')),
//           );
//         }
//       } else {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('Failed to fetch labours')),
//         );
//       }
//     } catch (e) {
//     } finally {
//       setState(() {
//         isLoading = false;
//       });
//     }
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
//           decoration: const BoxDecoration(color: Colors.white
//               // gradient: LinearGradient(
//               //   begin: Alignment.topLeft,
//               //   end: Alignment.bottomRight,
//               //   colors: [
//               //     Color(0xFFA8D5BA), // Light green
//               //     Color(0xFF68A691), // Darker green
//               //   ],
//               // ),
//               ),
//           child: SafeArea(
//             child: Column(
//               children: [
//                 // Search Bar
//                 Padding(
//                   padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
//                   child: Container(
//                     decoration: BoxDecoration(
//                       color: Constants.AppColors.card,
//                       borderRadius: BorderRadius.circular(16),
//                       boxShadow: const [Constants.AppShadows.soft],
//                     ),
//                     child: TextField(
//                       controller: _searchController,
//                       onChanged: (value) {
//                         fetchLabours(searchQuery: value);
//                       },
//                       style: Constants.AppTypography.body,
//                       decoration: InputDecoration(
//                         prefixIcon: const Icon(
//                           Icons.search,
//                           color: Constants.AppColors.brand,
//                           size: 20,
//                         ),
//                         suffixIcon: MicIconButton(controller: _searchController),
//                         hintText: AppLocalizations.of(context)!.searchlabour,
//                         hintStyle: Constants.AppTypography.body.copyWith(
//                           color: Constants.AppColors.inkSoft,
//                         ),
//                         fillColor: Colors.transparent,
//                         filled: true,
//                         contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
//                         border: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(16),
//                           borderSide: const BorderSide(color: Constants.AppColors.border),
//                         ),
//                         enabledBorder: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(16),
//                           borderSide: const BorderSide(color: Constants.AppColors.border),
//                         ),
//                         focusedBorder: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(16),
//                           borderSide: const BorderSide(color: Constants.AppColors.brand, width: 1.5),
//                         ),
//                       ),
//                     ),
//                   ),
//                 ),
//                 Expanded(
//                   child: isLoading
//                       ? const Center(child: CircularProgressIndicator())
//                       : labours.isEmpty
//                           ? Center(
//                               child: Text(
//                                 translateText('Looking for nearby workers'),
//                                 style: TextStyle(
//                                   fontSize: 18,
//                                   fontWeight: FontWeight.w500,
//                                   color: Colors.brown,
//                                 ),
//                               ),
//                             )
//                           : ListView.builder(
//                               shrinkWrap:
//                                   true, // Prevent infinite expansion inside a Column
//
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
//                                     margin: const EdgeInsets.only(left: 16, right: 16, bottom: 12),
//                                     decoration: BoxDecoration(
//                                       color: Constants.AppColors.card,
//                                       borderRadius: BorderRadius.circular(20),
//                                       border: Border.all(
//                                         color: Constants.AppColors.border,
//                                         width: 1.0,
//                                       ),
//                                       boxShadow: const [Constants.AppShadows.soft],
//                                     ),
//                                     child: Padding(
//                                       padding: const EdgeInsets.all(12.0),
//                                       child: Column(
//                                         crossAxisAlignment: CrossAxisAlignment.start,
//                                         children: [
//                                           Row(
//                                             crossAxisAlignment: CrossAxisAlignment.center,
//                                             children: [
//                                               // Profile Avatar with tile radius 14
//                                               Container(
//                                                 width: 80,
//                                                 height: 80,
//                                                 decoration: BoxDecoration(
//                                                   color: Constants.AppColors.brand,
//                                                   borderRadius: BorderRadius.circular(14),
//                                                 ),
//                                                 child: labour['profile'] != null && labour['profile'].isNotEmpty
//                                                     ? ClipRRect(
//                                                         borderRadius: BorderRadius.circular(14),
//                                                         child: Image.network(
//                                                           '${Constants.AppConstants.folderUrl}storage/upload/labourprofile/${labour['profile']}',
//                                                           fit: BoxFit.cover,
//                                                           errorBuilder: (context, error, stackTrace) {
//                                                             return const Icon(
//                                                               Icons.person,
//                                                               color: Colors.white,
//                                                               size: 32,
//                                                             );
//                                                           },
//                                                         ),
//                                                       )
//                                                     : const Icon(
//                                                         Icons.person,
//                                                         color: Colors.white,
//                                                         size: 32,
//                                                       ),
//                                               ),
//                                               const SizedBox(width: 12),
//                                               Expanded(
//                                                 child: Column(
//                                                   crossAxisAlignment: CrossAxisAlignment.start,
//                                                   children: [
//                                                     Text(
//                                                       translateText(labour['name'] ?? 'Unknown'),
//                                                       style: Constants.AppTypography.h3.copyWith(
//                                                         color: Constants.AppColors.ink,
//                                                       ),
//                                                     ),
//                                                     const SizedBox(height: 6),
//                                                     Row(
//                                                       children: [
//                                                         Row(
//                                                           children: List.generate(5, (index) {
//                                                             return Icon(
//                                                               index < (labour['review_count'] is int ? labour['review_count'] : 0)
//                                                                   ? Icons.star
//                                                                   : Icons.star_border,
//                                                               color: Constants.AppColors.star,
//                                                               size: 14,
//                                                             );
//                                                           }),
//                                                         ),
//                                                         const SizedBox(width: 4),
//                                                         Text(
//                                                           '${labour['average_rating']}/5',
//                                                           style: Constants.AppTypography.label.copyWith(
//                                                             color: Constants.AppColors.inkSoft,
//                                                             fontWeight: FontWeight.w600,
//                                                           ),
//                                                         ),
//                                                         const SizedBox(width: 10),
//                                                         const Icon(
//                                                           Icons.chat_bubble_outline,
//                                                           size: 14,
//                                                           color: Constants.AppColors.inkSoft,
//                                                         ),
//                                                         const SizedBox(width: 4),
//                                                         Text(
//                                                           '${labour['review_count']}',
//                                                           style: Constants.AppTypography.label.copyWith(
//                                                             color: Constants.AppColors.inkSoft,
//                                                             fontWeight: FontWeight.w600,
//                                                           ),
//                                                         ),
//                                                         const SizedBox(width: 10),
//                                                         const Icon(
//                                                           Icons.assignment_turned_in_outlined,
//                                                           size: 14,
//                                                           color: Constants.AppColors.inkSoft,
//                                                         ),
//                                                         const SizedBox(width: 4),
//                                                         Text(
//                                                           '${labour['project_complete_count']}',
//                                                           style: Constants.AppTypography.label.copyWith(
//                                                             color: Constants.AppColors.inkSoft,
//                                                             fontWeight: FontWeight.w600,
//                                                           ),
//                                                         ),
//                                                       ],
//                                                     ),
//                                                     const SizedBox(height: 8),
//                                                     Row(
//                                                       children: [
//                                                         if (labour['daily_wage'] != null) ...[
//                                                           Text(
//                                                             translateText('Rs ${(labour['daily_wage'] ?? 'N/A')}/Day'),
//                                                             style: Constants.AppTypography.label.copyWith(
//                                                               color: Constants.AppColors.brandDeep,
//                                                               fontWeight: FontWeight.w700,
//                                                             ),
//                                                           ),
//                                                           const SizedBox(width: 12),
//                                                         ],
//                                                         const Icon(
//                                                           Icons.location_on_outlined,
//                                                           size: 14,
//                                                           color: Constants.AppColors.inkSoft,
//                                                         ),
//                                                         const SizedBox(width: 2),
//                                                         Text(
//                                                           translateText(labour['city'] ?? 'Unknown City'),
//                                                           style: Constants.AppTypography.label.copyWith(
//                                                             color: Constants.AppColors.inkSoft,
//                                                             fontWeight: FontWeight.w600,
//                                                           ),
//                                                         ),
//                                                       ],
//                                                     ),
//                                                   ],
//                                                 ),
//                                               ),
//                                             ],
//                                           ),
//                                           if (labour['aboutme'] != null && labour['aboutme'].toString().isNotEmpty) ...[
//                                             const SizedBox(height: 8),
//                                             const Divider(color: Constants.AppColors.border, height: 1),
//                                             const SizedBox(height: 8),
//                                             Text(
//                                               translateText(labour['aboutme'] ?? 'N/A'),
//                                               style: Constants.AppTypography.body.copyWith(
//                                                 color: Constants.AppColors.inkSoft,
//                                               ),
//                                               maxLines: isExpandedList[index] ? null : 2,
//                                               overflow: isExpandedList[index] ? TextOverflow.visible : TextOverflow.ellipsis,
//                                             ),
//                                             if ((labour['aboutme'] ?? "").split(' ').length > 50) ...[
//                                               const SizedBox(height: 4),
//                                               InkWell(
//                                                 onTap: () {
//                                                   setState(() {
//                                                     isExpandedList[index] = !isExpandedList[index];
//                                                   });
//                                                 },
//                                                 child: Text(
//                                                   isExpandedList[index]
//                                                       ? translateText('Read Less')
//                                                       : translateText('Read More'),
//                                                   style: Constants.AppTypography.label.copyWith(
//                                                     color: Constants.AppColors.brand,
//                                                     fontWeight: FontWeight.bold,
//                                                   ),
//                                                 ),
//                                               ),
//                                             ],
//                                           ],
//                                         ],
//                                       ),
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
// class AnimatedCard extends StatefulWidget {
//   final dynamic labour;
//   final int index;
//   const AnimatedCard({required this.labour, required this.index});
//
//   @override
//   State<AnimatedCard> createState() => _AnimatedCardState();
// }
//
// class _AnimatedCardState extends State<AnimatedCard> {
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
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:greencollar/speech_helper.dart';
import 'package:flutter/services.dart';
import 'package:greencollar/l10n/app_localizations.dart';
import 'package:greencollar/main.dart';
import 'package:greencollar/workerdetails.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart';
import 'package:translator/translator.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:greencollar/constants.dart' as Constants;
import 'package:greencollar/wallet_helper.dart';

class LabourPage extends StatefulWidget {
  @override
  _LabourPageState createState() => _LabourPageState();
}

class _LabourPageState extends State<LabourPage> {
  final _secureStorage = const FlutterSecureStorage();
  final TextEditingController _searchController = TextEditingController();
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

  Future<void> loadLanguage() async {
    String? language = await _secureStorage.read(key: 'selectedLanguage');
    _selectedLanguage = language ?? 'en';
  }

  Map<String, Map<String, String>> _cachedTranslations = {};
  Map<String, Map<String, String>> translations =
      Constants.AppConstants.translations;
  final GoogleTranslator _translator = GoogleTranslator();

  @override
  void initState() {
    super.initState();
    loadLanguage();
    fetchLabours();
    _loadCoinCharge();
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
      if (mounted) setState(() {});
    } catch (e) {
      print("Translation error: $e");
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

    final apiUrl = (searchQuery != null && searchQuery.isNotEmpty)
        ? '${Constants.AppConstants.apiUrl}farmer/searchnearbylabours'
        : '${Constants.AppConstants.apiUrl}farmer/nearbylabours';

    final Map<String, dynamic> requestBody =
    (searchQuery != null && searchQuery.isNotEmpty)
        ? {'search': searchQuery}
        : {'id': userId};

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
                content: Text(responseData['message'] ?? 'No Workers found')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to fetch labours')),
        );
      }
    } catch (e) {
      // ignore
    } finally {
      setState(() {
        isLoading = false;
      });
    }
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
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Constants.AppColors.card,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: const [Constants.AppShadows.soft],
                    ),
                    child: TextField(
                      controller: _searchController,
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
                        suffixIcon: MicIconButton(controller: _searchController),
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
                Expanded(
                  child: isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : labours.isEmpty
                      ? Center(
                    child: Text(
                      translateText('Looking for nearby workers'),
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: Colors.brown,
                      ),
                    ),
                  )
                      : ListView.builder(
                    padding: const EdgeInsets.only(bottom: 16),
                    itemCount: labours.length,
                    itemBuilder: (context, index) {
                      final labour = labours[index];

                      // Determine type label
                      String labourType = labour['type'] == '0'
                          ? translateText('Individual')
                          : translateText('Agency');

                      // Get subtitle: skills or aboutme
                      String subtitle = labour['skills']?.toString() ?? '';
                      if (subtitle.isEmpty) {
                        subtitle = labour['aboutme']?.toString() ?? '';
                      }

                      // Extract skills as tags
                      List<String> skillTags = [];
                      if (labour['skills'] != null &&
                          labour['skills'].toString().isNotEmpty) {
                        skillTags = labour['skills']
                            .toString()
                            .split(',')
                            .map((s) => s.trim())
                            .where((s) => s.isNotEmpty)
                            .toList();
                      }
                      // If no skills, use education as fallback
                      if (skillTags.isEmpty &&
                          labour['education'] != null &&
                          labour['education'].toString().isNotEmpty) {
                        skillTags.add(labour['education'].toString());
                      }
                      // Limit to 2 tags
                      if (skillTags.length > 2) {
                        skillTags = skillTags.sublist(0, 2);
                      }

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
                                        child: (labour['profile_image'] != null &&
                                            labour['profile_image'].toString().isNotEmpty)
                                            ? Image.network(
                                          labour['profile_image'].toString(),
                                          fit: BoxFit.cover,
                                          errorBuilder: (context, error, stackTrace) {
                                            return const Icon(Icons.person,
                                                color: Constants.AppColors.brand, size: 28);
                                          },
                                        )
                                            : const Icon(Icons.person,
                                            color: Constants.AppColors.brand, size: 28),
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
                                      // Top row: Name + type badge | Tags (right)
                                      Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          // Name and badge
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
                                                          '$_coinCharge ' + translateText("Coins"),
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
                                          // Tags (skills) – top right
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
                                                subtitle.length > 40
                                                    ? '${subtitle.substring(0, 40)}...'
                                                    : subtitle,
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
      ),
    );
  }
}