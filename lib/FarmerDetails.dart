// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:flutter_secure_storage/flutter_secure_storage.dart';
// import 'package:greencollar/constants.dart' as Constants;
// import 'package:http/http.dart' as http;
// import 'package:translator/translator.dart' show GoogleTranslator;
// import 'package:url_launcher/url_launcher.dart';
// import 'package:greencollar/wallet_helper.dart';
//
// class FarmerDetailsPage extends StatefulWidget {
//   final Map<String, dynamic> farmer;
//
//   FarmerDetailsPage({required this.farmer});
//
//   @override
//   _FarmerDetailsPageState createState() => _FarmerDetailsPageState();
// }
//
// class _FarmerDetailsPageState extends State<FarmerDetailsPage> {
//   late Map<String, dynamic> farmer;
//   final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
//   final GoogleTranslator _translator = GoogleTranslator();
//
//   Map<String, Map<String, String>> _cachedTranslations = {};
//   Map<String, Map<String, String>> translations =
//       Constants.AppConstants.translations;
//   String _selectedLanguage = 'en';
//
//   bool _isUnlocked = false;
//
//   Future<void> _checkUnlockStatus() async {
//     String phone = widget.farmer['phone']?.toString() ?? '';
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
//     String phone = widget.farmer['phone']?.toString() ?? '';
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
//     farmer = widget.farmer;
//     _checkUnlockStatus();
//   }
//
//   Future<void> loadLanguage() async {
//     String? language = await _secureStorage.read(key: 'selectedLanguage');
//     if (mounted) {
//       setState(() {
//         _selectedLanguage = language ?? 'en';
//       });
//     }
//   }
//
//   String translateText(String text) {
//     if (text.isEmpty) return "";
//     String targetLang = _selectedLanguage ?? 'en';
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
//         translations[text] = {"en": text, "hi": text};
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
//       _cachedTranslations.putIfAbsent(text, () => {})[targetLang] =
//           translation.text;
//       if (mounted) {
//         setState(() {});
//       }
//     } catch (e) {
//       print("Translation error: $e");
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
//   Widget _buildInfoRow(IconData icon, String label, String value, {VoidCallback? onTap}) {
//     return InkWell(
//       onTap: onTap,
//       child: Padding(
//         padding: const EdgeInsets.symmetric(vertical: 10.0),
//         child: Row(
//           children: [
//             Container(
//               padding: const EdgeInsets.all(8),
//               decoration: BoxDecoration(
//                 color: Constants.AppColors.brandTint,
//                 borderRadius: BorderRadius.circular(Constants.AppRadii.sm),
//               ),
//               child: Icon(icon, color: Constants.AppColors.brand, size: 20),
//             ),
//             const SizedBox(width: 16),
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     translateText(label),
//                     style: Constants.AppTypography.label.copyWith(color: Constants.AppColors.inkSoft),
//                   ),
//                   const SizedBox(height: 2),
//                   Text(
//                     translateText(value),
//                     style: Constants.AppTypography.body.copyWith(
//                       color: onTap != null ? Constants.AppColors.brand : Constants.AppColors.ink,
//                       fontWeight: FontWeight.w600,
//                       decoration: onTap != null ? TextDecoration.underline : TextDecoration.none,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             if (onTap != null)
//               const Icon(Icons.chevron_right, color: Constants.AppColors.inkSoft, size: 20),
//           ],
//         ),
//       ),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     String cityStr = farmer['city'] ?? '';
//     String stateStr = farmer['state'] ?? '';
//     String pincodeStr = farmer['pincode']?.toString() ?? '';
//
//     List<String> locParts = [];
//     if (cityStr.isNotEmpty) locParts.add(cityStr);
//     if (stateStr.isNotEmpty) locParts.add(stateStr);
//     if (pincodeStr.isNotEmpty) locParts.add(pincodeStr);
//     String locationStr = locParts.isNotEmpty ? locParts.join(', ') : 'Unknown Location';
//
//     return Scaffold(
//       backgroundColor: Constants.AppColors.surface,
//       appBar: AppBar(
//         title: Text(
//           translateText("Farmer Details"),
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
//             Navigator.pop(context);
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
//                       child: farmer['profile'] != null && farmer['profile'].toString().isNotEmpty
//                           ? ClipRRect(
//                               borderRadius: BorderRadius.circular(Constants.AppRadii.xl - 2),
//                               child: Image.network(
//                                 '${Constants.AppConstants.folderUrl}storage/upload/farmerprofile/${farmer['profile']}',
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
//                     // Farmer Name
//                     Text(
//                       farmer['name'] ?? 'Unknown',
//                       style: Constants.AppTypography.h1,
//                       textAlign: TextAlign.center,
//                     ),
//                     const SizedBox(height: 8),
//                     Text(
//                       translateText("Farmer"),
//                       style: Constants.AppTypography.label.copyWith(
//                         color: Constants.AppColors.brandDeep,
//                         fontWeight: FontWeight.w700,
//                       ),
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
//                     _buildPhoneRow(farmer['phone']?.toString() ?? ''),
//                     const Divider(color: Constants.AppColors.border, height: 1),
//                     _buildInfoRow(
//                       Icons.email_outlined,
//                       "Email",
//                       farmer['email']?.toString() ?? 'N/A',
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
//               // About Me Card
//               if (farmer['aboutme'] != null && farmer['aboutme'].toString().trim().isNotEmpty) ...[
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
//                         translateText(farmer['aboutme'].toString()),
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
import 'package:greencollar/constants.dart' as Constants;
import 'package:http/http.dart' as http;
import 'package:translator/translator.dart' show GoogleTranslator;
import 'package:url_launcher/url_launcher.dart';

class FarmerDetailsPage extends StatefulWidget {
  final Map<String, dynamic> farmer;

  FarmerDetailsPage({required this.farmer});

  @override
  _FarmerDetailsPageState createState() => _FarmerDetailsPageState();
}

class _FarmerDetailsPageState extends State<FarmerDetailsPage> {
  late Map<String, dynamic> farmer;
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  final GoogleTranslator _translator = GoogleTranslator();

  Map<String, Map<String, String>> _cachedTranslations = {};
  Map<String, Map<String, String>> translations =
      Constants.AppConstants.translations;
  String _selectedLanguage = 'en';

  Widget _buildPhoneRow(String phone) {
    if (phone.isEmpty) {
      return _buildInfoRow(Icons.phone_outlined, "Phone", "N/A");
    }

    return InkWell(
      onTap: () => _launchPhoneDialer(phone),
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
                    phone,
                    style: Constants.AppTypography.body.copyWith(
                      color: Constants.AppColors.brandDeep,
                      fontWeight: FontWeight.w600,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Constants.AppColors.inkSoft, size: 20),
          ],
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    loadLanguage();
    farmer = widget.farmer;
  }

  Future<void> loadLanguage() async {
    String? language = await _secureStorage.read(key: 'selectedLanguage');
    if (mounted) {
      setState(() {
        _selectedLanguage = language ?? 'en';
      });
    }
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
      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      print("Translation error: $e");
    }
  }

  Future<void> _launchPhoneDialer(String phoneNumber) async {
    final Uri url = Uri.parse('tel:$phoneNumber');
    if (!await launchUrl(url)) {
      throw 'Could not launch $url';
    }
  }

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

  // Helper to build a section with title and children
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

  @override
  Widget build(BuildContext context) {
    // Build location string
    String cityStr = farmer['city'] ?? '';
    String stateStr = farmer['state'] ?? '';
    String pincodeStr = farmer['pincode']?.toString() ?? '';
    List<String> locParts = [];
    if (cityStr.isNotEmpty) locParts.add(cityStr);
    if (stateStr.isNotEmpty) locParts.add(stateStr);
    if (pincodeStr.isNotEmpty) locParts.add(pincodeStr);
    String locationStr = locParts.isNotEmpty ? locParts.join(', ') : 'Unknown Location';

    // Full address (if available)
    String addressStr = farmer['address']?.toString() ?? '';
    String fullAddress = addressStr.isNotEmpty ? '$addressStr, $locationStr' : locationStr;

    // Gather non‑null fields for display (excluding Farmer ID)
    List<Widget> personalInfoItems = [];
    if (farmer['age'] != null && farmer['age'].toString().isNotEmpty) {
      personalInfoItems.add(_buildInfoRow(Icons.cake_outlined, "Age", farmer['age'].toString()));
    }
    if (farmer['gender'] != null && farmer['gender'].toString().isNotEmpty) {
      personalInfoItems.add(_buildInfoRow(Icons.person_outline, "Gender", farmer['gender'].toString()));
    }
    // Farmer ID removed intentionally

    // Contact info (excluding phone which is handled separately)
    List<Widget> contactItems = [];
    if (farmer['email'] != null && farmer['email'].toString().isNotEmpty) {
      contactItems.add(_buildInfoRow(Icons.email_outlined, "Email", farmer['email'].toString()));
    }
    if (fullAddress.isNotEmpty && fullAddress != 'Unknown Location') {
      contactItems.add(_buildInfoRow(Icons.location_on_outlined, "Address", fullAddress));
    }

    // Professional info
    List<Widget> professionalItems = [];
    if (farmer['education'] != null && farmer['education'].toString().isNotEmpty) {
      professionalItems.add(_buildInfoRow(Icons.school_outlined, "Education", farmer['education'].toString()));
    }
    if (farmer['skills'] != null && farmer['skills'].toString().isNotEmpty) {
      professionalItems.add(_buildInfoRow(Icons.construction_outlined, "Skills", farmer['skills'].toString()));
    }
    if (farmer['certifications'] != null && farmer['certifications'].toString().isNotEmpty) {
      professionalItems.add(_buildInfoRow(Icons.verified_outlined, "Certifications", farmer['certifications'].toString()));
    }

    // Agency info (if type is not 0, but we keep it anyway)
    List<Widget> agencyItems = [];
    if (farmer['type'] != null && farmer['type'].toString() != '0') {
      if (farmer['agency_name'] != null && farmer['agency_name'].toString().isNotEmpty) {
        agencyItems.add(_buildInfoRow(Icons.business_outlined, "Agency Name", farmer['agency_name'].toString()));
      }
      if (farmer['agency_type'] != null && farmer['agency_type'].toString().isNotEmpty) {
        agencyItems.add(_buildInfoRow(Icons.category_outlined, "Agency Type", farmer['agency_type'].toString()));
      }
      if (farmer['agency_reg_no'] != null && farmer['agency_reg_no'].toString().isNotEmpty) {
        agencyItems.add(_buildInfoRow(Icons.numbers_outlined, "Reg. No.", farmer['agency_reg_no'].toString()));
      }
      if (farmer['agency_reg_year'] != null && farmer['agency_reg_year'].toString().isNotEmpty) {
        agencyItems.add(_buildInfoRow(Icons.calendar_today_outlined, "Reg. Year", farmer['agency_reg_year'].toString()));
      }
      if (farmer['members'] != null && farmer['members'].toString().isNotEmpty) {
        agencyItems.add(_buildInfoRow(Icons.people_outline, "Members", farmer['members'].toString()));
      }
    }

    return Scaffold(
      backgroundColor: Constants.AppColors.surface,
      appBar: AppBar(
        title: Text(
          translateText("Farmer Details"),
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
            Navigator.pop(context);
          },
        ),
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Main Profile Card - reduced avatar size
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
                      width: 70, // reduced from 100
                      height: 70, // reduced from 100
                      decoration: BoxDecoration(
                        color: Constants.AppColors.brandTint,
                        borderRadius: BorderRadius.circular(Constants.AppRadii.xl),
                        border: Border.all(color: Constants.AppColors.brandSoft, width: 2),
                        boxShadow: const [Constants.AppShadows.soft],
                      ),
                      child: farmer['profile'] != null && farmer['profile'].toString().isNotEmpty
                          ? ClipRRect(
                        borderRadius: BorderRadius.circular(Constants.AppRadii.xl - 2),
                        child: Image.network(
                          '${Constants.AppConstants.folderUrl}storage/upload/farmerprofile/${farmer['profile']}',
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(
                              Icons.person,
                              color: Constants.AppColors.brand,
                              size: 30, // adjusted icon size
                            );
                          },
                        ),
                      )
                          : const Icon(
                        Icons.person,
                        color: Constants.AppColors.brand,
                        size: 30, // adjusted icon size
                      ),
                    ),
                    const SizedBox(height: 12), // reduced spacing
                    // Farmer Name
                    Text(
                      farmer['name'] ?? 'Unknown',
                      style: Constants.AppTypography.h1.copyWith(fontSize: 20), // slightly smaller
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      translateText("Farmer"),
                      style: Constants.AppTypography.label.copyWith(
                        color: Constants.AppColors.brandDeep,
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Contact Section (Phone + Email + Address)
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
                    _buildPhoneRow(farmer['phone']?.toString() ?? ''),
                    const Divider(color: Constants.AppColors.border, height: 1),
                    ...contactItems,
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Personal Information Section (without Farmer ID)
              if (personalInfoItems.isNotEmpty)
                _buildSection("Personal Information", personalInfoItems),

              // Professional Information Section
              if (professionalItems.isNotEmpty)
                _buildSection("Professional Details", professionalItems),

              // Agency Information Section (if applicable)
              if (agencyItems.isNotEmpty)
                _buildSection("Agency Details", agencyItems),

              // About Me Section
              if (farmer['aboutme'] != null && farmer['aboutme'].toString().trim().isNotEmpty)
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
                        translateText(farmer['aboutme'].toString()),
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
      ),
    );
  }
}