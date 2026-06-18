// import 'dart:convert';
//
// import 'package:flutter/material.dart';
// import 'package:flutter_secure_storage/flutter_secure_storage.dart';
// import 'package:greencollar/HomeScree.dart';
// import 'package:greencollar/constants.dart' as Constants;
// import 'package:http/http.dart' as http;
// import 'package:greencollar/wallet_helper.dart';
// import 'package:url_launcher/url_launcher.dart';
// import 'package:translator/translator.dart' show GoogleTranslator;
//
// class LabourDetailsPage extends StatefulWidget {
//   final Map<String, dynamic> labour;
//
//   LabourDetailsPage({required this.labour});
//
//   @override
//   _LabourDetailsPageState createState() => _LabourDetailsPageState();
// }
//
// class _LabourDetailsPageState extends State<LabourDetailsPage> {
//   late Map<String, dynamic> labour;
//   FlutterSecureStorage _secureStorage = FlutterSecureStorage();
//   final GoogleTranslator _translator = GoogleTranslator();
//
//   Map<String, Map<String, String>> _cachedTranslations = {};
//
//   Map<String, Map<String, String>> translations =
//       Constants.AppConstants.translations;
//   String _selectedLanguage = 'en'; // Default language is English
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
//   Widget _buildStatItem(IconData icon, String value, String label) {
//     return Column(
//       children: [
//         Icon(icon, color: Constants.AppColors.brand, size: 20),
//         const SizedBox(height: 6),
//         Text(
//           value,
//           style: Constants.AppTypography.h3.copyWith(color: Constants.AppColors.ink),
//         ),
//         const SizedBox(height: 2),
//         Text(
//           translateText(label),
//           style: Constants.AppTypography.micro.copyWith(color: Constants.AppColors.inkSoft),
//         ),
//       ],
//     );
//   }
//
//   bool _isUnlocked = false;
//
//   Future<void> _checkUnlockStatus() async {
//     String phone = widget.labour['phone']?.toString() ?? '';
//     if (phone.isEmpty) return;
//     bool unlocked = await WalletHelper.isContactUnlocked(phone);
//     if (mounted) {
//       setState(() {
//         _isUnlocked = unlocked;
//       });
//     }
//   }
//
//   Future<void> _handleUnlock() async {
//     String phone = widget.labour['phone']?.toString() ?? '';
//     if (phone.isEmpty) return;
//
//     bool success = await WalletHelper.showUnlockDialog(
//       context,
//       contactId: phone,
//       onInsufficientFunds: () {
//         WalletHelper.showInsufficientFundsDialog(
//           context,
//           onBuyCoins: () {
//             WalletHelper.showCoinShop(context, onCoinsAdded: (newBalance) {
//               // Refresh or take action if required
//             });
//           },
//         );
//       },
//     );
//
//     if (success) {
//       if (mounted) {
//         setState(() {
//           _isUnlocked = true;
//         });
//       }
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
//   Widget _buildPhoneRow(String phone) {
//     if (phone.isEmpty) {
//       return _buildInfoRow(Icons.phone_outlined, "Phone", "N/A");
//     }
//
//     String displayText = _isUnlocked
//         ? phone
//         : WalletHelper.maskPhone(phone);
//
//     return InkWell(
//       onTap: _isUnlocked ? () => _launchPhoneDialer(phone) : _handleUnlock,
//       borderRadius: BorderRadius.circular(Constants.AppRadii.sm),
//       child: Padding(
//         padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 4.0),
//         child: Row(
//           children: [
//             Container(
//               padding: const EdgeInsets.all(8),
//               decoration: BoxDecoration(
//                 color: Constants.AppColors.brandTint,
//                 borderRadius: BorderRadius.circular(Constants.AppRadii.sm),
//               ),
//               child: const Icon(Icons.phone_outlined, color: Constants.AppColors.brand, size: 20),
//             ),
//             const SizedBox(width: 16),
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     translateText("Phone"),
//                     style: Constants.AppTypography.label.copyWith(color: Constants.AppColors.inkSoft),
//                   ),
//                   const SizedBox(height: 2),
//                   Text(
//                     displayText,
//                     style: Constants.AppTypography.body.copyWith(
//                       color: _isUnlocked ? Constants.AppColors.brandDeep : Constants.AppColors.ink,
//                       fontWeight: FontWeight.w600,
//                       decoration: _isUnlocked ? TextDecoration.underline : TextDecoration.none,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             if (!_isUnlocked)
//               Container(
//                 padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
//                 decoration: BoxDecoration(
//                   color: const Color(0xFFFFF3E0),
//                   borderRadius: BorderRadius.circular(8),
//                   border: Border.all(color: const Color(0xFFFFB74D), width: 1),
//                 ),
//                 child: Row(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     const Icon(Icons.lock, color: Color(0xFFE65100), size: 14),
//                     const SizedBox(width: 4),
//                     Text(
//                       translateText("Unlock"),
//                       style: const TextStyle(
//                         color: Color(0xFFE65100),
//                         fontSize: 12,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                   ],
//                 ),
//               )
//             else
//               const Icon(Icons.chevron_right, color: Constants.AppColors.inkSoft, size: 20),
//           ],
//         ),
//       ),
//     );
//   }
//
//   @override
//   void initState() {
//     super.initState();
//     loadLanguage();
//     labour = widget.labour;
//     _checkUnlockStatus();
//     print(labour);
//   }
//
//   Widget _buildInfoRow(IconData icon, String label, String value) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 10.0),
//       child: Row(
//         children: [
//           Container(
//             padding: const EdgeInsets.all(8),
//             decoration: BoxDecoration(
//               color: Constants.AppColors.brandTint,
//               borderRadius: BorderRadius.circular(Constants.AppRadii.sm),
//             ),
//             child: Icon(icon, color: Constants.AppColors.brand, size: 20),
//           ),
//           const SizedBox(width: 16),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   translateText(label),
//                   style: Constants.AppTypography.label.copyWith(color: Constants.AppColors.inkSoft),
//                 ),
//                 const SizedBox(height: 2),
//                 Text(
//                   translateText(value),
//                   style: Constants.AppTypography.body.copyWith(
//                     color: Constants.AppColors.ink,
//                     fontWeight: FontWeight.w600,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildChip(String text) {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//       decoration: BoxDecoration(
//         color: Constants.AppColors.brandTint,
//         borderRadius: BorderRadius.circular(Constants.AppRadii.sm),
//         border: Border.all(color: Constants.AppColors.border),
//       ),
//       child: Text(
//         text,
//         style: Constants.AppTypography.body.copyWith(
//           color: Constants.AppColors.brandDeep,
//           fontWeight: FontWeight.w600,
//         ),
//       ),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     // Parse location
//     String cityStr = labour['city'] ?? '';
//     String stateStr = labour['state'] ?? '';
//     String locationStr = '';
//     if (cityStr.isNotEmpty && stateStr.isNotEmpty) {
//       locationStr = '$cityStr, $stateStr';
//     } else {
//       locationStr = cityStr.isNotEmpty ? cityStr : (stateStr.isNotEmpty ? stateStr : 'Unknown Location');
//     }
//
//     // Split skills and certifications if present
//     List<String> skillList = [];
//     if (labour['skills'] != null && labour['skills'] is String) {
//       skillList = (labour['skills'] as String)
//           .split(',')
//           .map((e) => e.trim())
//           .where((e) => e.isNotEmpty)
//           .toList();
//     }
//     List<String> certList = [];
//     if (labour['certifications'] != null && labour['certifications'] is String) {
//       certList = (labour['certifications'] as String)
//           .split(',')
//           .map((e) => e.trim())
//           .where((e) => e.isNotEmpty)
//           .toList();
//     }
//
//     return Scaffold(
//       backgroundColor: Constants.AppColors.surface,
//       appBar: AppBar(
//         title: Text(
//           translateText("Worker Details"),
//           style: Constants.AppTypography.h2.copyWith(color: Colors.white),
//         ),
//         iconTheme: const IconThemeData(color: Colors.white),
//         flexibleSpace: Container(
//           decoration: const BoxDecoration(
//             gradient: Constants.AppColors.brandGradient,
//           ),
//         ),
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back),
//           onPressed: () {
//             Navigator.pushReplacement(
//               context,
//               MaterialPageRoute(
//                 builder: (context) => HomePage(),
//               ),
//             );
//           },
//         ),
//         elevation: 0,
//       ),
//       body: SingleChildScrollView(
//         child: Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.stretch,
//             children: [
//               // Main Profile Card
//               Container(
//                 padding: const EdgeInsets.all(20.0),
//                 decoration: BoxDecoration(
//                   color: Constants.AppColors.card,
//                   borderRadius: BorderRadius.circular(Constants.AppRadii.lg),
//                   border: Border.all(color: Constants.AppColors.border),
//                   boxShadow: const [Constants.AppShadows.card],
//                 ),
//                 child: Column(
//                   children: [
//                     // Large Avatar
//                     Container(
//                       width: 100,
//                       height: 100,
//                       decoration: BoxDecoration(
//                         color: Constants.AppColors.brandTint,
//                         borderRadius: BorderRadius.circular(Constants.AppRadii.xl),
//                         border: Border.all(color: Constants.AppColors.brandSoft, width: 2),
//                         boxShadow: const [Constants.AppShadows.soft],
//                       ),
//                       child: labour['profile'] != null && labour['profile'].toString().isNotEmpty
//                           ? ClipRRect(
//                               borderRadius: BorderRadius.circular(Constants.AppRadii.xl - 2),
//                               child: Image.network(
//                                 '${Constants.AppConstants.folderUrl}storage/upload/labourprofile/${labour['profile']}',
//                                 fit: BoxFit.cover,
//                                 errorBuilder: (context, error, stackTrace) {
//                                   return const Icon(
//                                     Icons.person,
//                                     color: Constants.AppColors.brand,
//                                     size: 40,
//                                   );
//                                 },
//                               ),
//                             )
//                           : const Icon(
//                               Icons.person,
//                               color: Constants.AppColors.brand,
//                               size: 40,
//                             ),
//                     ),
//                     const SizedBox(height: 16),
//                     // Worker Name
//                     Text(
//                       labour['name'] ?? 'Unknown',
//                       style: Constants.AppTypography.h1,
//                       textAlign: TextAlign.center,
//                     ),
//                     const SizedBox(height: 12),
//                     // Rating/Wages Row
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         if (labour['daily_wage'] != null) ...[
//                           Container(
//                             padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
//                             decoration: BoxDecoration(
//                               color: Constants.AppColors.brandTint,
//                               borderRadius: BorderRadius.circular(Constants.AppRadii.xs),
//                             ),
//                             child: Text(
//                               '₹${labour['daily_wage']}/Day',
//                               style: Constants.AppTypography.label.copyWith(
//                                 color: Constants.AppColors.brandDeep,
//                                 fontWeight: FontWeight.w800,
//                               ),
//                             ),
//                           ),
//                           const SizedBox(width: 12),
//                         ],
//                         // Small stars for rating
//                         Row(
//                           children: List.generate(5, (index) {
//                             double rating = double.tryParse(labour['average_rating']?.toString() ?? '0') ?? 0;
//                             return Icon(
//                               index < rating.floor() ? Icons.star : Icons.star_border,
//                               color: Constants.AppColors.star,
//                               size: 18,
//                             );
//                           }),
//                         ),
//                       ],
//                     ),
//                     const SizedBox(height: 20),
//                     const Divider(color: Constants.AppColors.border, height: 1),
//                     const SizedBox(height: 16),
//                     // Stats Row
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                       children: [
//                         _buildStatItem(
//                           Icons.star_half,
//                           '${labour['average_rating'] ?? 0}/5',
//                           'Rating',
//                         ),
//                         _buildStatItem(
//                           Icons.chat_bubble_outline,
//                           '${labour['review_count'] ?? 0}',
//                           'Reviews',
//                         ),
//                         _buildStatItem(
//                           Icons.task_alt,
//                           '${labour['project_complete_count'] ?? 0}',
//                           'Completed',
//                         ),
//                       ],
//                     ),
//                   ],
//                 ),
//               ),
//               const SizedBox(height: 16),
//
//               // Contact & Details Card
//               Container(
//                 padding: const EdgeInsets.all(16.0),
//                 decoration: BoxDecoration(
//                   color: Constants.AppColors.card,
//                   borderRadius: BorderRadius.circular(Constants.AppRadii.lg),
//                   border: Border.all(color: Constants.AppColors.border),
//                   boxShadow: const [Constants.AppShadows.soft],
//                 ),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       translateText("Contact Information"),
//                       style: Constants.AppTypography.h3,
//                     ),
//                     const SizedBox(height: 12),
//                     _buildPhoneRow(labour['phone']?.toString() ?? ''),
//                     const Divider(color: Constants.AppColors.border, height: 1),
//                     _buildInfoRow(
//                       Icons.email_outlined,
//                       "Email",
//                       labour['email']?.toString() ?? 'N/A',
//                     ),
//                     const Divider(color: Constants.AppColors.border, height: 1),
//                     _buildInfoRow(
//                       Icons.location_on_outlined,
//                       "Location",
//                       locationStr,
//                     ),
//                   ],
//                 ),
//               ),
//               const SizedBox(height: 16),
//
//               // Skills Card (If not empty)
//               if (skillList.isNotEmpty) ...[
//                 Container(
//                   padding: const EdgeInsets.all(16.0),
//                   decoration: BoxDecoration(
//                     color: Constants.AppColors.card,
//                     borderRadius: BorderRadius.circular(Constants.AppRadii.lg),
//                     border: Border.all(color: Constants.AppColors.border),
//                     boxShadow: const [Constants.AppShadows.soft],
//                   ),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         translateText("Skills"),
//                         style: Constants.AppTypography.h3,
//                       ),
//                       const SizedBox(height: 12),
//                       Wrap(
//                         spacing: 8.0,
//                         runSpacing: 8.0,
//                         children: skillList.map((skill) => _buildChip(skill)).toList(),
//                       ),
//                     ],
//                   ),
//                 ),
//                 const SizedBox(height: 16),
//               ],
//
//               // Certifications Card (If not empty)
//               if (certList.isNotEmpty) ...[
//                 Container(
//                   padding: const EdgeInsets.all(16.0),
//                   decoration: BoxDecoration(
//                     color: Constants.AppColors.card,
//                     borderRadius: BorderRadius.circular(Constants.AppRadii.lg),
//                     border: Border.all(color: Constants.AppColors.border),
//                     boxShadow: const [Constants.AppShadows.soft],
//                   ),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         translateText("Certifications"),
//                         style: Constants.AppTypography.h3,
//                       ),
//                       const SizedBox(height: 12),
//                       Wrap(
//                         spacing: 8.0,
//                         runSpacing: 8.0,
//                         children: certList.map((cert) => _buildChip(cert)).toList(),
//                       ),
//                     ],
//                   ),
//                 ),
//                 const SizedBox(height: 16),
//               ],
//
//               // About Me Card (If not empty)
//               if (labour['aboutme'] != null && labour['aboutme'].toString().trim().isNotEmpty) ...[
//                 Container(
//                   padding: const EdgeInsets.all(16.0),
//                   decoration: BoxDecoration(
//                     color: Constants.AppColors.card,
//                     borderRadius: BorderRadius.circular(Constants.AppRadii.lg),
//                     border: Border.all(color: Constants.AppColors.border),
//                     boxShadow: const [Constants.AppShadows.soft],
//                   ),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         translateText("About Me"),
//                         style: Constants.AppTypography.h3,
//                       ),
//                       const SizedBox(height: 12),
//                       Text(
//                         translateText(labour['aboutme'].toString()),
//                         style: Constants.AppTypography.body.copyWith(
//                           color: Constants.AppColors.ink,
//                           height: 1.5,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:greencollar/HomeScree.dart';
import 'package:greencollar/constants.dart' as Constants;
import 'package:http/http.dart' as http;
import 'package:greencollar/wallet_helper.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:translator/translator.dart' show GoogleTranslator;

class LabourDetailsPage extends StatefulWidget {
  final Map<String, dynamic> labour;

  LabourDetailsPage({required this.labour});

  @override
  _LabourDetailsPageState createState() => _LabourDetailsPageState();
}

class _LabourDetailsPageState extends State<LabourDetailsPage> {
  late Map<String, dynamic> labour;
  final FlutterSecureStorage _secureStorage = FlutterSecureStorage();
  final GoogleTranslator _translator = GoogleTranslator();

  Map<String, Map<String, String>> _cachedTranslations = {};
  Map<String, Map<String, String>> translations =
      Constants.AppConstants.translations;
  String _selectedLanguage = 'en';

  bool _isUnlocked = false;

  @override
  void initState() {
    super.initState();
    loadLanguage();
    labour = widget.labour;
    _checkUnlockStatus();
    print(labour);
  }

  // ---------- Language & Translation ----------
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
      if (mounted) setState(() {});
    } catch (e) {
      print("Translation error: $e");
    }
  }

  // ---------- Unlock & Phone ----------
  Future<void> _checkUnlockStatus() async {
    String phone = widget.labour['phone']?.toString() ?? '';
    if (phone.isEmpty) return;
    bool unlocked = await WalletHelper.isContactUnlocked(phone);
    if (mounted) {
      setState(() {
        _isUnlocked = unlocked;
      });
    }
  }

  Future<void> _handleUnlock() async {
    String phone = widget.labour['phone']?.toString() ?? '';
    if (phone.isEmpty) return;

    bool success = await WalletHelper.showUnlockDialog(
      context,
      contactId: phone,
      onInsufficientFunds: () {
        WalletHelper.showInsufficientFundsDialog(
          context,
          onBuyCoins: () {
            WalletHelper.showCoinShop(context, onCoinsAdded: (newBalance) {
              // Refresh or take action if required
            });
          },
        );
      },
    );

    if (success && mounted) {
      setState(() {
        _isUnlocked = true;
      });
    }
  }

  Future<void> _launchPhoneDialer(String phoneNumber) async {
    final Uri url = Uri.parse('tel:$phoneNumber');
    if (!await launchUrl(url)) {
      throw 'Could not launch $url';
    }
  }

  Widget _buildPhoneRow(String phone) {
    if (phone.isEmpty) {
      return _buildInfoRow(Icons.phone_outlined, "Phone", "N/A");
    }

    String displayText = _isUnlocked
        ? phone
        : WalletHelper.maskPhone(phone);

    return InkWell(
      onTap: _isUnlocked ? () => _launchPhoneDialer(phone) : _handleUnlock,
      borderRadius: BorderRadius.circular(Constants.AppRadii.sm),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 4.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Constants.AppColors.brandTint,
                borderRadius: BorderRadius.circular(Constants.AppRadii.sm),
              ),
              child: const Icon(Icons.phone_outlined, color: Constants.AppColors.brand, size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    translateText("Phone"),
                    style: Constants.AppTypography.label.copyWith(color: Constants.AppColors.inkSoft),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    displayText,
                    style: Constants.AppTypography.body.copyWith(
                      color: _isUnlocked ? Constants.AppColors.brandDeep : Constants.AppColors.ink,
                      fontWeight: FontWeight.w600,
                      decoration: _isUnlocked ? TextDecoration.underline : TextDecoration.none,
                    ),
                  ),
                ],
              ),
            ),
            if (!_isUnlocked)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF3E0),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFFFB74D), width: 1),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.lock, color: Color(0xFFE65100), size: 14),
                    const SizedBox(width: 4),
                    Text(
                      translateText("Unlock"),
                      style: const TextStyle(
                        color: Color(0xFFE65100),
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              )
            else
              const Icon(Icons.chevron_right, color: Constants.AppColors.inkSoft, size: 20),
          ],
        ),
      ),
    );
  }

  // ---------- Helper Widgets ----------
  Widget _buildInfoRow(IconData icon, String label, String value, {VoidCallback? onTap}) {
    if (value.isEmpty || value == 'null') value = 'N/A';
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Constants.AppColors.brandTint,
                borderRadius: BorderRadius.circular(Constants.AppRadii.sm),
              ),
              child: Icon(icon, color: Constants.AppColors.brand, size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    translateText(label),
                    style: Constants.AppTypography.label.copyWith(color: Constants.AppColors.inkSoft),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    translateText(value),
                    style: Constants.AppTypography.body.copyWith(
                      color: onTap != null ? Constants.AppColors.brand : Constants.AppColors.ink,
                      fontWeight: FontWeight.w600,
                      decoration: onTap != null ? TextDecoration.underline : TextDecoration.none,
                    ),
                  ),
                ],
              ),
            ),
            if (onTap != null)
              const Icon(Icons.chevron_right, color: Constants.AppColors.inkSoft, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildChip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Constants.AppColors.brandTint,
        borderRadius: BorderRadius.circular(Constants.AppRadii.sm),
        border: Border.all(color: Constants.AppColors.border),
      ),
      child: Text(
        translateText(text),
        style: Constants.AppTypography.body.copyWith(
          color: Constants.AppColors.brandDeep,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(icon, color: Constants.AppColors.brand, size: 20),
        const SizedBox(height: 6),
        Text(
          value,
          style: Constants.AppTypography.h3.copyWith(color: Constants.AppColors.ink),
        ),
        const SizedBox(height: 2),
        Text(
          translateText(label),
          style: Constants.AppTypography.micro.copyWith(color: Constants.AppColors.inkSoft),
        ),
      ],
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Constants.AppColors.card,
        borderRadius: BorderRadius.circular(Constants.AppRadii.lg),
        border: Border.all(color: Constants.AppColors.border),
        boxShadow: const [Constants.AppShadows.soft],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            translateText(title),
            style: Constants.AppTypography.h3,
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }

  // ---------- Build ----------
  @override
  Widget build(BuildContext context) {
    // Build location
    String cityStr = labour['city'] ?? '';
    String stateStr = labour['state'] ?? '';
    String pincodeStr = labour['pincode']?.toString() ?? '';
    List<String> locParts = [];
    if (cityStr.isNotEmpty) locParts.add(cityStr);
    if (stateStr.isNotEmpty) locParts.add(stateStr);
    if (pincodeStr.isNotEmpty) locParts.add(pincodeStr);
    String locationStr = locParts.isNotEmpty ? locParts.join(', ') : 'Unknown Location';

    // Full address if available
    String addressStr = labour['address']?.toString() ?? '';
    String fullAddress = addressStr.isNotEmpty ? '$addressStr, $locationStr' : locationStr;

    // Determine worker type label
    String workerType = labour['type'] == '0' ? 'Individual' : 'Agency';
    if (labour['type'] == '0') {
      workerType = translateText('Worker');
    } else {
      workerType = translateText('Agency');
    }

    // Gather non‑null fields
    List<Widget> personalInfoItems = [];
    if (labour['age'] != null && labour['age'].toString().isNotEmpty) {
      personalInfoItems.add(_buildInfoRow(Icons.cake_outlined, "Age", labour['age'].toString()));
    }
    if (labour['gender'] != null && labour['gender'].toString().isNotEmpty) {
      personalInfoItems.add(_buildInfoRow(Icons.person_outline, "Gender", labour['gender'].toString()));
    }
    // Labour ID is intentionally not shown (like Farmer ID)

    // Contact info (excluding phone – handled separately)
    List<Widget> contactItems = [];
    if (labour['email'] != null && labour['email'].toString().isNotEmpty) {
      contactItems.add(_buildInfoRow(Icons.email_outlined, "Email", labour['email'].toString()));
    }
    if (fullAddress.isNotEmpty && fullAddress != 'Unknown Location') {
      contactItems.add(_buildInfoRow(Icons.location_on_outlined, "Address", fullAddress));
    }

    // Skills
    List<String> skillList = [];
    if (labour['skills'] != null && labour['skills'] is String) {
      skillList = (labour['skills'] as String)
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();
    }

    // Certifications
    List<String> certList = [];
    if (labour['certifications'] != null && labour['certifications'] is String) {
      certList = (labour['certifications'] as String)
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();
    }

    // Education
    String education = labour['education']?.toString() ?? '';
    // Experience
    String experience = labour['experience']?.toString() ?? '';

    // Build professional items
    List<Widget> professionalItems = [];
    if (education.isNotEmpty) {
      professionalItems.add(_buildInfoRow(Icons.school_outlined, "Education", education));
    }
    if (experience.isNotEmpty) {
      professionalItems.add(_buildInfoRow(Icons.work_outline, "Experience", experience));
    }

    // Agency details (if type != 0)
    List<Widget> agencyItems = [];
    if (labour['type'] != null && labour['type'].toString() != '0') {
      if (labour['agency_name'] != null && labour['agency_name'].toString().isNotEmpty) {
        agencyItems.add(_buildInfoRow(Icons.business_outlined, "Agency Name", labour['agency_name'].toString()));
      }
      if (labour['agency_type'] != null && labour['agency_type'].toString().isNotEmpty) {
        agencyItems.add(_buildInfoRow(Icons.category_outlined, "Agency Type", labour['agency_type'].toString()));
      }
      if (labour['agency_reg_no'] != null && labour['agency_reg_no'].toString().isNotEmpty) {
        agencyItems.add(_buildInfoRow(Icons.numbers_outlined, "Reg. No.", labour['agency_reg_no'].toString()));
      }
      if (labour['agency_reg_year'] != null && labour['agency_reg_year'].toString().isNotEmpty) {
        agencyItems.add(_buildInfoRow(Icons.calendar_today_outlined, "Reg. Year", labour['agency_reg_year'].toString()));
      }
      if (labour['members'] != null && labour['members'].toString().isNotEmpty) {
        agencyItems.add(_buildInfoRow(Icons.people_outline, "Members", labour['members'].toString()));
      }
    }

    // About Me
    String aboutMe = labour['aboutme']?.toString() ?? '';

    // Daily wage
    String dailyWage = labour['daily_wage']?.toString() ?? '';

    // Stats
    String rating = labour['average_rating']?.toString() ?? '0';
    String reviews = labour['review_count']?.toString() ?? '0';
    String completed = labour['project_complete_count']?.toString() ?? '0';

    return Scaffold(
      backgroundColor: Constants.AppColors.surface,
      appBar: AppBar(
        title: Text(
          translateText("Worker Details"),
          style: Constants.AppTypography.h2.copyWith(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: Constants.AppColors.brandGradient,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => HomePage(),
              ),
            );
          },
        ),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ---- Profile Card (smaller avatar) ----
              Container(
                padding: const EdgeInsets.all(16.0), // reduced from 20
                decoration: BoxDecoration(
                  color: Constants.AppColors.card,
                  borderRadius: BorderRadius.circular(Constants.AppRadii.lg),
                  border: Border.all(color: Constants.AppColors.border),
                  boxShadow: const [Constants.AppShadows.card],
                ),
                child: Column(
                  children: [
                    // Smaller Avatar
                    Container(
                      width: 70,
                      height: 70,
                      decoration: BoxDecoration(
                        color: Constants.AppColors.brandTint,
                        borderRadius: BorderRadius.circular(Constants.AppRadii.xl),
                        border: Border.all(color: Constants.AppColors.brandSoft, width: 2),
                        boxShadow: const [Constants.AppShadows.soft],
                      ),
                      child: labour['profile'] != null && labour['profile'].toString().isNotEmpty
                          ? ClipRRect(
                        borderRadius: BorderRadius.circular(Constants.AppRadii.xl - 2),
                        child: Image.network(
                          '${Constants.AppConstants.folderUrl}storage/upload/labourprofile/${labour['profile']}',
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(
                              Icons.person,
                              color: Constants.AppColors.brand,
                              size: 30,
                            );
                          },
                        ),
                      )
                          : const Icon(
                        Icons.person,
                        color: Constants.AppColors.brand,
                        size: 30,
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Name
                    Text(
                      labour['name'] ?? 'Unknown',
                      style: Constants.AppTypography.h1.copyWith(fontSize: 20),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 4),
                    // Worker type label
                    Text(
                      workerType,
                      style: Constants.AppTypography.label.copyWith(
                        color: Constants.AppColors.brandDeep,
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Daily Wage & Rating
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (dailyWage.isNotEmpty) ...[
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: Constants.AppColors.brandTint,
                              borderRadius: BorderRadius.circular(Constants.AppRadii.xs),
                            ),
                            child: Text(
                              '₹$dailyWage/Day',
                              style: Constants.AppTypography.label.copyWith(
                                color: Constants.AppColors.brandDeep,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                        ],
                        Row(
                          children: List.generate(5, (index) {
                            double ratingVal = double.tryParse(rating) ?? 0;
                            return Icon(
                              index < ratingVal.floor() ? Icons.star : Icons.star_border,
                              color: Constants.AppColors.star,
                              size: 18,
                            );
                          }),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Divider(color: Constants.AppColors.border, height: 1),
                    const SizedBox(height: 14),
                    // Stats Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildStatItem(Icons.star_half, '$rating/5', 'Rating'),
                        _buildStatItem(Icons.chat_bubble_outline, reviews, 'Reviews'),
                        _buildStatItem(Icons.task_alt, completed, 'Completed'),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // ---- Contact Information (with Phone unlock) ----
              Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Constants.AppColors.card,
                  borderRadius: BorderRadius.circular(Constants.AppRadii.lg),
                  border: Border.all(color: Constants.AppColors.border),
                  boxShadow: const [Constants.AppShadows.soft],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      translateText("Contact Information"),
                      style: Constants.AppTypography.h3,
                    ),
                    const SizedBox(height: 12),
                    _buildPhoneRow(labour['phone']?.toString() ?? ''),
                    const Divider(color: Constants.AppColors.border, height: 1),
                    ...contactItems,
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // ---- Personal Information ----
              if (personalInfoItems.isNotEmpty)
                _buildSection("Personal Information", personalInfoItems),

              // ---- Professional Details (Education, Experience, Skills, Certifications) ----
              if (professionalItems.isNotEmpty || skillList.isNotEmpty || certList.isNotEmpty)
                _buildSection(
                  "Professional Details",
                  [
                    ...professionalItems,
                    if (skillList.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        translateText("Skills"),
                        style: Constants.AppTypography.label.copyWith(color: Constants.AppColors.inkSoft),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8.0,
                        runSpacing: 8.0,
                        children: skillList.map((skill) => _buildChip(skill)).toList(),
                      ),
                    ],
                    if (certList.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      Text(
                        translateText("Certifications"),
                        style: Constants.AppTypography.label.copyWith(color: Constants.AppColors.inkSoft),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8.0,
                        runSpacing: 8.0,
                        children: certList.map((cert) => _buildChip(cert)).toList(),
                      ),
                    ],
                  ],
                ),

              // ---- Agency Details ----
              if (agencyItems.isNotEmpty)
                _buildSection("Agency Details", agencyItems),

              // ---- About Me ----
              if (aboutMe.isNotEmpty)
                Container(
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: Constants.AppColors.card,
                    borderRadius: BorderRadius.circular(Constants.AppRadii.lg),
                    border: Border.all(color: Constants.AppColors.border),
                    boxShadow: const [Constants.AppShadows.soft],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        translateText("About Me"),
                        style: Constants.AppTypography.h3,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        translateText(aboutMe),
                        style: Constants.AppTypography.body.copyWith(
                          color: Constants.AppColors.ink,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}