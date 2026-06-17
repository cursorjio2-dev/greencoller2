import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:greencollar/HomeScree.dart';
import 'package:greencollar/constants.dart' as Constants;
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:translator/translator.dart';

class NotificationsPage extends StatefulWidget {
  @override
  _NotificationsPageState createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  final FlutterSecureStorage _secureStorage = FlutterSecureStorage();
  bool isLoading = true;
  List<dynamic> notifications = [];
  final GoogleTranslator _translator = GoogleTranslator();

  @override
  void initState() {
    super.initState();
    loadLanguage();

    _fetchNotifications();
  }

  Map<String, Map<String, String>> _cachedTranslations = {};

  Map<String, Map<String, String>> translations =
      Constants.AppConstants.translations;
  String _selectedLanguage = 'en';
  Future<void> loadLanguage() async {
    // Read the selected language from FlutterSecureStorage
    String? language = await _secureStorage.read(key: 'selectedLanguage');
    _selectedLanguage = language ?? 'en';
    print(language); // Default to English if null
  }

  Future<Map<String, Map<String, String>>> fetchTranslations() async {
    try {
      final response = await http.post(
          Uri.parse('${Constants.AppConstants.apiUrl}farmer/getTranslations'));

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);

        if (jsonData['status'] == 1) {
          List<dynamic> data = jsonData['data'];

          for (var item in data) {
            String text = item['text'];
            String lang = item['lang'];
            String translation = item['translation'];

            // ✅ Initialize default values if text is not in the map
            if (!translations.containsKey(text)) {
              translations[text] = {
                "en": text,
                "hi": text
              }; // Default both to the same value
            }

            // ✅ Store the translation in the correct language
            translations[text]![lang] = translation;
          }

          // ✅ Store fetched translations in the cache
          _cachedTranslations = translations;

          // ✅ Check for missing translations and fetch dynamically
          for (var text in translations.keys) {
            if (!translations[text]!.containsKey("hi")) {
              _fetchTranslation(text, "hi");
            }
            if (!translations[text]!.containsKey("en")) {
              _fetchTranslation(text, "en");
            }
          }

          return translations;
        } else {
          throw Exception(
              "Failed to load translations: ${jsonData['message']}");
        }
      } else {
        throw Exception("API Error: ${response.statusCode}");
      }
    } catch (e) {
      print("Error fetching translations: $e");
      return {};
    }
  }

  /// ✅ Main function to translate text
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

  Future<void> _fetchNotifications() async {
    // Retrieve the user ID from secure storage
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

    // Make the POST request to fetch the notifications
    final response = await http.post(
      Uri.parse('${Constants.AppConstants.apiUrl}farmer/farmernotifications'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'id': userId}),
    );

    // Check if the response is successful
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['status'] == 1) {
        setState(() {
          notifications = data['notifications'];
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to load notifications')),
        );
      }
    } else {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to load notifications')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Constants.AppColors.surface,
      appBar: AppBar(
        foregroundColor: Constants.AppColors.card,
        elevation: 0,
        title: Text(
          translateText("Notifications"),
          style: Constants.AppTypography.h3.copyWith(color: Constants.AppColors.card),
        ),
        iconTheme: const IconThemeData(color: Constants.AppColors.card),
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
          ? const Center(child: CircularProgressIndicator(color: Constants.AppColors.brand))
          : notifications.isEmpty
              ? Center(
                  child: Text(
                    translateText('No notifications available.'),
                    style: Constants.AppTypography.body.copyWith(
                        color: Constants.AppColors.inkSoft),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: notifications.length,
                  itemBuilder: (context, index) {
                    final notification = notifications[index];
                    return Container(
                      margin: const EdgeInsets.symmetric(
                          vertical: 6, horizontal: 16),
                      decoration: BoxDecoration(
                        color: Constants.AppColors.card,
                        borderRadius: BorderRadius.circular(Constants.AppRadii.lg),
                        border: Border.all(color: Constants.AppColors.border, width: 0.5),
                        boxShadow: const [Constants.AppShadows.soft],
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        title: Text(
                          translateText(notification['message']),
                          style: Constants.AppTypography.body.copyWith(
                              color: Constants.AppColors.ink),
                        ),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            notification['formatted_date'],
                            style: Constants.AppTypography.label.copyWith(
                                color: Constants.AppColors.inkSoft),
                          ),
                        ),
                        trailing: notification['seen'] == '0'
                            ? const Icon(Icons.notifications_active,
                                color: Constants.AppColors.amberNotice)
                            : const Icon(Icons.notifications_none,
                                color: Constants.AppColors.brand),
                      ),
                    );
                  },
                ),
    );
  }
}

// Future<void> downloadTranslations() async {
//     try {
//       var status = await Permission.storage.status;
//       if (!status.isGranted) {
//         await Permission.storage.request();
//       }

//       // Specify the destination path
//       final destinationPath = '/storage/emulated/0/Download/Invoice';
//       final destinationDir = Directory(destinationPath);

//       // Ensure the destination directory exists
//       await destinationDir.create(recursive: true);

//       // ✅ Define the folder inside the directory
//       final folderPath = '${destinationDir.path}/Appointment_Details';
//       final folder = Directory(folderPath);

//       // ✅ Create folder if it doesn't exist
//       if (!await folder.exists()) {
//         await folder.create(recursive: true);
//       }

//       // ✅ Define file path
//       final filePath = '$folderPath/translations.txt';
//       final file = File(filePath);

//       // ✅ Convert translations Map to readable text format
//       StringBuffer buffer = StringBuffer();
//       translations.forEach((key, value) {
//         buffer.writeln("$key: ${value.toString()}");
//       });

//       // ✅ Write to file
//       await file.writeAsString(buffer.toString());

//       // ✅ Print full file path
//       print("✅ Translations saved at: ${file.absolute.path}");
//     } catch (e) {
//       print("❌ Error saving translations: $e");
//     }
//   }
