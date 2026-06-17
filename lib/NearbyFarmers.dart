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
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    loadLanguage();
    fetchfarmers();
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

  Future<void> fetchfarmers({String? searchQuery}) async {
    setState(() {
      isLoading = true;
    });

    String? userId = await _secureStorage.read(key: 'id');
    if (userId == null && searchQuery == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User ID not found in secure storage')),
      );
      setState(() {
        isLoading = false;
      });
      return;
    }

    final Map<String, dynamic> requestBody =
        (searchQuery != null && searchQuery.isNotEmpty)
            ? {'searchquery': searchQuery}
            : {'id': userId};

    final apiUrl = (searchQuery != null && searchQuery.isNotEmpty)
        ? '${Constants.AppConstants.apiUrl}labour/searchnearbyfarmers'
        : '${Constants.AppConstants.apiUrl}labour/nearbyfarmers';
    print(apiUrl);
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
        final responseData = jsonDecode(response.body);
        if (responseData['success'] == true) {
          setState(() {
            farmers = responseData['data'];
            isExpandedList = List.generate(farmers.length, (index) => false);
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(responseData['message'] ?? 'No farmers found')),
          );
        }
      } else {}
    } catch (e) {
      print(e);
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  List<bool> isExpandedList = [];
  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        // Assuming loadLanguage, fetchProjects, and fetchJobTypes are async functions.
        await loadLanguage(); // Load the language (make sure it's an async function)
        fetchfarmers();

        setState(() {
          // If you need to update the UI state, you can do it here after all async tasks are done.
        });
      },
      child: WillPopScope(
        onWillPop: () async {
          SystemNavigator.pop();
          return false;
        },
        child: Scaffold(
          backgroundColor: Constants.AppColors.surface,
          body: Container(
            color: Constants.AppColors.surface,
            child: SafeArea(
              child: ListView(
                children: [
                  Column(
                    children: [
                      // Search Bar
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Container(
                          decoration: const BoxDecoration(
                            boxShadow: [Constants.AppShadows.soft],
                          ),
                          child: TextField(
                            controller: _searchController,
                            onChanged: (value) =>
                                fetchfarmers(searchQuery: value),
                            style: Constants.AppTypography.body,
                            decoration: InputDecoration(
                              prefixIcon:
                                  const Icon(Icons.search, color: Constants.AppColors.brand),
                              suffixIcon: MicIconButton(controller: _searchController),
                              hintText: AppLocalizations.of(context)!.search_by,
                              hintStyle: Constants.AppTypography.body.copyWith(color: Constants.AppColors.inkSoft),
                              fillColor: Constants.AppColors.card,
                              filled: true,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(Constants.AppRadii.md),
                                borderSide: const BorderSide(color: Constants.AppColors.border, width: 1.0),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(Constants.AppRadii.md),
                                borderSide: const BorderSide(
                                    color: Constants.AppColors.brand, width: 1.5),
                              ),
                            ),
                          ),
                        ),
                      ),
                      isLoading
                          ? const Center(child: CircularProgressIndicator())
                          : farmers.isEmpty
                              ? Center(
                                  child: Text(
                                    translateText('No farmers found'),
                                    style: Constants.AppTypography.h3.copyWith(
                                      color: Constants.AppColors.inkSoft,
                                    ),
                                  ),
                                )
                              : ListView.builder(
                                  shrinkWrap:
                                      true, // Prevent infinite expansion inside a Column
                                  physics:
                                      const NeverScrollableScrollPhysics(), // Avoids nested scrolling issues
                                  itemCount: farmers.length,
                                  itemBuilder: (context, index) {
                                    final labour = farmers[
                                        index]; // ✅ Use `labour`, not `widget.labour`

                                    return InkWell(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                FarmerDetailsPage(farmer: labour),
                                          ),
                                        );
                                      },
                                      child: AnimatedContainer(
                                      duration:
                                          const Duration(milliseconds: 500),
                                      curve: Curves.easeInOut,
                                      margin: const EdgeInsets.symmetric(
                                          horizontal: 16, vertical: 8),
                                      decoration: BoxDecoration(
                                        color: Constants.AppColors.card,
                                        borderRadius: BorderRadius.circular(Constants.AppRadii.lg),
                                        border: Border.all(color: Constants.AppColors.border, width: 1.0),
                                        boxShadow: const [Constants.AppShadows.soft],
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.all(12.0),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: [
                                            // Profile Image and About Me section
                                            Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              // Aligns children at the top
                                              children: [
                                                Container(
                                                  width: 50,
                                                  height: 50,
                                                  decoration: BoxDecoration(
                                                    color: Constants.AppColors.brandTint,
                                                    borderRadius:
                                                        BorderRadius.circular(14),
                                                  ),
                                                  child: labour['profile'] !=
                                                              null &&
                                                          labour['profile']
                                                              .isNotEmpty
                                                      ? ClipRRect(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(14),
                                                          child: Image.network(
                                                            '${Constants.AppConstants.folderUrl}storage/upload/farmerprofile/${labour['profile']}',
                                                            fit: BoxFit.cover,
                                                            errorBuilder:
                                                                (context, error,
                                                                    stackTrace) {
                                                              // If there's an error loading the image, show the default icon
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
                                                Expanded(
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            left: 16.0),
                                                    child: Column(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment.start,
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Text(
                                                          translateText(
                                                              labour['name'] ??
                                                                  'Unknown'),
                                                          style: Constants.AppTypography.h3.copyWith(
                                                            color: Constants.AppColors.ink,
                                                          ),
                                                        ),
                                                        const SizedBox(height: 4),
                                                        Row(
                                                          children: [
                                                            const Icon(Icons.location_on, size: 14, color: Constants.AppColors.brand),
                                                            const SizedBox(width: 4),
                                                            Expanded(
                                                              child: Text(
                                                                '${translateText(labour['city'] ?? 'Unknown City')}',
                                                                style: Constants.AppTypography.subhead.copyWith(
                                                                  color: Constants.AppColors.inkSoft,
                                                                  fontWeight: FontWeight.w600,
                                                                ),
                                                                overflow: TextOverflow.ellipsis,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                        if (labour['aboutme'] !=
                                                            null) ...[
                                                          const SizedBox(height: 8),
                                                          Text(
                                                            labour['aboutme'] ??
                                                                'N/A', // Ensure about_me is not null
                                                            style: Constants.AppTypography.body.copyWith(
                                                              color: Constants.AppColors.inkSoft,
                                                            ),
                                                            maxLines:
                                                                isExpandedList[
                                                                        index]
                                                                    ? null
                                                                    : 2,
                                                            overflow: isExpandedList[
                                                                    index]
                                                                ? TextOverflow
                                                                    .visible
                                                                    : TextOverflow
                                                                        .ellipsis,
                                                          ),
                                                          // Read More / Read Less button
                                                          const SizedBox(height: 4),
                                                          InkWell(
                                                            onTap: () {
                                                              setState(() {
                                                                isExpandedList[
                                                                        index] =
                                                                    !isExpandedList[
                                                                        index]; // Toggle expansion
                                                              });
                                                            },
                                                            child: Text(
                                                              isExpandedList[
                                                                      index]
                                                                  ? 'Read Less'
                                                                  : 'Read More',
                                                              style: Constants.AppTypography.label.copyWith(
                                                                color: Constants.AppColors.brand,
                                                                fontWeight:
                                                                    FontWeight.bold,
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ],
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
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class AnimatedCard extends StatelessWidget {
  final dynamic labour;
  final int index;

  Future<void> _launchPhoneDialer(String phoneNumber) async {
    final Uri url = Uri.parse('tel:$phoneNumber');
    if (!await launchUrl(url)) {
      throw 'Could not launch $url';
    }
  }

  const AnimatedCard({required this.labour, required this.index});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Constants.AppColors.card,
        borderRadius: BorderRadius.circular(Constants.AppRadii.lg),
        border: Border.all(color: Constants.AppColors.border, width: 1.0),
        boxShadow: const [Constants.AppShadows.soft],
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Constants.AppColors.brandTint,
          child: Text(
            labour['name'][0].toUpperCase(),
            style: Constants.AppTypography.h3.copyWith(color: Constants.AppColors.brand),
          ),
        ),
        title: Text(
          labour['name'] ?? 'Unknown',
          style: Constants.AppTypography.h3.copyWith(color: Constants.AppColors.ink),
        ),
        subtitle: Text(
          '${labour['city'] ?? 'Unknown City'}, ${labour['state'] ?? 'Unknown State'}',
          style: Constants.AppTypography.body.copyWith(color: Constants.AppColors.inkSoft),
        ),
        // trailing: GestureDetector(
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
      ),
    );
  }
}
