// // import 'dart:convert';
//
// // import 'package:flutter/gestures.dart';
// // import 'package:flutter/material.dart';
// // import 'package:fluttertoast/fluttertoast.dart';
// // import 'package:greencollar/HomeScree.dart';
// // import 'package:greencollar/labourhomepage.dart';
// // import 'package:greencollar/register.dart';
// // import 'package:provider/provider.dart';
// // import 'package:shared_preferences/shared_preferences.dart';
// // import 'package:http/http.dart' as http;
// // import 'package:flutter_secure_storage/flutter_secure_storage.dart';
//
// // class NearbyProjectPage extends StatefulWidget {
// //   @override
// //   _NearbyProjectPageState createState() => _NearbyProjectPageState();
// // }
//
// // class _NearbyProjectPageState extends State<NearbyProjectPage> {
// //   final _secureStorage = const FlutterSecureStorage();
// //   List<dynamic> projects = [];
// //   List<dynamic> filteredProjects = []; // To store filtered results
// //   bool isLoading = true;
// //   TextEditingController _searchController = TextEditingController();
//
// //   @override
// //   void initState() {
// //     super.initState();
// //     fetchProjects();
// //   }
//
// //   Future<void> fetchProjects() async {
// //     final String apiUrl =
// //         '${Constants.AppConstants.apiUrl}labour/nearbyProjectApi';
//
// //     // Get user ID from secure storage
// //     String? userId = await _secureStorage.read(key: 'id');
// //     if (userId == null) {
// //       ScaffoldMessenger.of(context).showSnackBar(
// //         const SnackBar(content: Text('User ID not found in secure storage')),
// //       );
// //       return;
// //     }
//
// //     final Map<String, dynamic> requestBody = {
// //       'id': userId,
// //     };
//
// //     print(jsonEncode(requestBody));
//
// //     try {
// //       final response = await http.post(
// //         Uri.parse(apiUrl),
// //         headers: {'Content-Type': 'application/json'},
// //         body: jsonEncode(requestBody),
// //       );
//
// //       if (response.statusCode == 200) {
// //         setState(() {
// //           projects = json.decode(response.body)['data'];
// //           filteredProjects =
// //               projects; // Set the filtered list to all projects initially
// //           isLoading = false;
// //         });
// //       } else {
// //         ScaffoldMessenger.of(context).showSnackBar(
// //           SnackBar(content: Text('Failed to fetch projects: ${response.body}')),
// //         );
// //       }
// //     } catch (e) {
// //       ScaffoldMessenger.of(context).showSnackBar(
// //         SnackBar(content: Text('An error occurred: $e')),
// //       );
// //     }
// //   }
//
// //   void filterProjects(String query) {
// //     setState(() {
// //       filteredProjects = projects.where((project) {
// //         String title =
// //             project['title'] ?? ''; // Default to empty string if null
// //         String budget =
// //             project['budget']?.toString() ?? ''; // Convert to string if null
// //         String city = project['city'] ?? ''; // Default to empty string if null
// //         String state =
// //             project['state'] ?? ''; // Default to empty string if null
//
// //         // Perform the filtering check
// //         return title.toLowerCase().contains(query.toLowerCase()) ||
// //             budget.toLowerCase().contains(query.toLowerCase()) ||
// //             city.toLowerCase().contains(query.toLowerCase()) ||
// //             state.toLowerCase().contains(query.toLowerCase());
// //       }).toList();
// //     });
// //   }
//
// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       body: Container(
// //         decoration: const BoxDecoration(
// //           gradient: LinearGradient(
// //             begin: Alignment.topLeft,
// //             end: Alignment.bottomRight,
// //             colors: [
// //               Color(0xFFA8D5BA), // Light green
// //               Color(0xFF68A691), // Darker green
// //             ],
// //           ),
// //         ),
// //         child: SafeArea(
// //           child: Column(
// //             children: [
// //               // Search Bar
// //               Padding(
// //                 padding: const EdgeInsets.all(16.0),
// //                 child: TextField(
// //                   controller: _searchController,
// //                   onChanged: (value) {
// //                     filterProjects(
// //                         value); // Filter projects based on search input
// //                   },
// //                   decoration: InputDecoration(
// //                     prefixIcon: const Icon(Icons.search, color: Colors.green),
// //                     hintText: 'Search by title, budget, city, or state',
// //                     fillColor: Colors.white,
// //                     filled: true,
// //                     border: OutlineInputBorder(
// //                       borderRadius: BorderRadius.circular(15.0),
// //                       borderSide: const BorderSide(color: Colors.green),
// //                     ),
// //                     focusedBorder: OutlineInputBorder(
// //                       borderRadius: BorderRadius.circular(15.0),
// //                       borderSide:
// //                           const BorderSide(color: Colors.green, width: 2),
// //                     ),
// //                   ),
// //                 ),
// //               ),
// //               // Project List
// //               Expanded(
// //                 child: isLoading
// //                     ? const Center(child: CircularProgressIndicator())
// //                     : filteredProjects.isEmpty
// //                         ? const Center(
// //                             child: Text(
// //                               'No projects found',
// //                               style: TextStyle(
// //                                 fontSize: 18,
// //                                 fontWeight: FontWeight.w500,
// //                                 color: Colors.brown,
// //                               ),
// //                             ),
// //                           )
// //                         : ListView.builder(
// //                             itemCount: filteredProjects.length,
// //                             itemBuilder: (context, index) {
// //                               final project = filteredProjects[index];
// //                               return Card(
// //                                 elevation: 5,
// //                                 margin: const EdgeInsets.symmetric(
// //                                     vertical: 10, horizontal: 15),
// //                                 child: Padding(
// //                                   padding: const EdgeInsets.all(15.0),
// //                                   child: Column(
// //                                     crossAxisAlignment:
// //                                         CrossAxisAlignment.start,
// //                                     children: [
// //                                       Text(
// //                                         project['title'] ?? 'No Title',
// //                                         style: const TextStyle(
// //                                           fontSize: 18,
// //                                           fontWeight: FontWeight.bold,
// //                                           color: Colors.teal,
// //                                         ),
// //                                       ),
// //                                       const SizedBox(height: 5),
// //                                       Text(
// //                                         'Budget: ${project['budget'] ?? 'N/A'}',
// //                                         style: const TextStyle(fontSize: 16),
// //                                       ),
// //                                       Text(
// //                                         'Location: ${project['city']}, ${project['state']}',
// //                                         style: const TextStyle(fontSize: 16),
// //                                       ),
// //                                       const SizedBox(height: 10),
// //                                       Text(
// //                                         project['description'] ??
// //                                             'No Description',
// //                                         style: const TextStyle(fontSize: 14),
// //                                       ),
// //                                     ],
// //                                   ),
// //                                 ),
// //                               );
// //                             },
// //                           ),
// //               ),
// //             ],
// //           ),
// //         ),
// //       ),
// //     );
// //   }
// // }
//
// import 'dart:convert';
// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:greencollar/speech_helper.dart';
// import 'package:fluttertoast/fluttertoast.dart';
// import 'package:greencollar/HomeScree.dart';
// import 'package:greencollar/l10n/app_localizations.dart';
// import 'package:greencollar/labourhomepage.dart';
// import 'package:greencollar/main.dart';
// import 'package:http/http.dart' as http;
// import 'package:flutter_secure_storage/flutter_secure_storage.dart';
// import 'package:greencollar/constants.dart' as Constants;
// import 'package:permission_handler/permission_handler.dart';
// import 'package:provider/provider.dart';
// import 'package:translator/translator.dart';
// import 'package:intl/intl.dart' hide TextDirection;
// import 'package:greencollar/ProjectDetails.dart';
//
// class NearbyProjectPage extends StatefulWidget {
//   @override
//   _NearbyProjectPageState createState() => _NearbyProjectPageState();
// }
//
// class _NearbyProjectPageState extends State<NearbyProjectPage> {
//   final _secureStorage = const FlutterSecureStorage();
//   bool isLoading = true;
//   List<dynamic> projects = [];
//   List<dynamic> filteredProjects = [];
//   final ScrollController _scrollController = ScrollController();
//
//   @override
//   void dispose() {
//     _scrollController.dispose();
//     super.dispose();
//   }
//
//   @override
//   void initState() {
//     super.initState();
//     loadLanguage();
//     fetchProjects();
//     fetchJobTypes();
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
//       print(jsonEncode(requestBody));
//       final response = await http.post(
//         Uri.parse(apiUrl),
//         headers: {'Content-Type': 'application/json'},
//         body: jsonEncode(requestBody),
//       );
//       if (response.statusCode == 200) {
//         final responseBody = json.decode(response.body);
//         if (responseBody['status'] == 1) {
//           setState(() {
//             print(responseBody['data']);
//             projects = responseBody['data'];
//             filteredProjects = projects;
//             isLoading = false;
//           });
//         } else {
//           setState(() {
//             projects = [];
//             filteredProjects = [];
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
//                   Text('Failed to fetch projects: ${response.statusCode}')),
//         );
//       }
//     } catch (e) {
//       setState(() {
//         isLoading = false;
//       });
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
//   String translate(String enText, String hiText) {
//     final language =
//         Provider.of<LanguageProvider>(context, listen: false).selectedLanguage;
//     return language == 'en' ? enText : hiText;
//   }
//
//   Future<void> applyToProject(int projectId) async {
//     final String apiUrl =
//         '${Constants.AppConstants.apiUrl}labour/applyProjectApi';
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
//       'labourId': userId,
//       'projectId': projectId,
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
//         final responseBody = json.decode(response.body);
//         if (responseBody['status'] == 1) {
//           Fluttertoast.showToast(
//             msg: translate(
//                 'Applied successfully!', 'सफलतापूर्वक लागू किया गया!'),
//             toastLength: Toast.LENGTH_SHORT,
//             gravity: ToastGravity.BOTTOM,
//             backgroundColor: Colors.green.shade700,
//             textColor: Colors.white,
//             fontSize: 16.0,
//           );
//
//           fetchProjects(); // Reload projects to update applyStatus
//         } else {
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(
//                 content: Text(responseBody['message'] ?? 'Failed to apply')),
//           );
//         }
//       } else {
//         String errorMessage = 'Failed to apply';
//         try {
//           final decoded = json.decode(response.body);
//           if (decoded is Map<String, dynamic>) {
//             if (decoded.containsKey('errors') && decoded['errors'] is Map) {
//               final errorsMap = decoded['errors'] as Map<String, dynamic>;
//               List<String> allErrors = [];
//               errorsMap.forEach((key, value) {
//                 if (value is List) {
//                   allErrors.addAll(value.map((e) => e.toString()));
//                 } else {
//                   allErrors.add(value.toString());
//                 }
//               });
//               if (allErrors.isNotEmpty) errorMessage = allErrors.join(', ');
//             } else if (decoded.containsKey('message')) {
//               errorMessage = decoded['message'].toString();
//             }
//           }
//         } catch (e) {
//           String bodyText = response.body.length > 100 ? response.body.substring(0, 100) + "..." : response.body;
//           errorMessage = 'Failed to apply: $bodyText';
//         }
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text(errorMessage)),
//         );
//       }
//     } catch (e) {}
//   }
//
//   List<JobType> _jobTypes = [];
//   final TextEditingController _projectSearchController =
//       TextEditingController();
//   final TextEditingController _labourSearchController = TextEditingController();
//   String selectedCategory = 'All';
//   double selectedPriceRange = 1000000;
//   double selectedRating = 3;
//   String selectedJobType = 'All';
//   bool isDailyWageSelected = false;
//   bool isContractSelected = false;
//   void _showFilterDialog() {
//     final language =
//         Provider.of<LanguageProvider>(context, listen: false).selectedLanguage;
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
//             title: Text(translate('Filter Projects', 'प्रस्ताव फ़िल्टर करें')),
//             content: SingleChildScrollView(
//               child: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   // Job Type filter (using fetched job types) with label
//                   Padding(
//                     padding: const EdgeInsets.symmetric(vertical: 8.0),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(translate(
//                             'Select Job Type', 'कृपया नौकरी का प्रकार चुनें')),
//                         DropdownButton<String>(
//                           value: selectedJobType,
//                           isExpanded: true,
//                           items: [
//                             DropdownMenuItem<String>(
//                               value: 'All',
//                               child: Text(translate('All', 'सभी')),
//                             ),
//                             // Create a DropdownMenuItem for each jobType
//                             ..._jobTypes
//                                 .map((job) => DropdownMenuItem<String>(
//                                       value: job.jobname,
//                                       child: Text(translate(job.jobname,
//                                           job.jobname)), // Assuming jobname is in English
//                                     ))
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
//
//                   // Category filter with label
//                   Padding(
//                     padding: const EdgeInsets.symmetric(vertical: 8.0),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(translate(
//                             'Select Payment Type', 'भुगतान प्रकार चुनें')),
//                         DropdownButton<String>(
//                           value: selectedCategory,
//                           isExpanded: true,
//                           items: ['All', 'Project Basis', 'Milestone Basis']
//                               .map((category) => DropdownMenuItem<String>(
//                                     value: category,
//                                     child: Text(translate(category, category)),
//                                   ))
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
//
//                   // Search field
//                   Padding(
//                     padding: const EdgeInsets.all(16.0),
//                     child: TextField(
//                       controller: _labourSearchController,
//                       decoration: InputDecoration(
//                         prefixIcon:
//                             const Icon(Icons.search, color: Constants.AppColors.brand),
//                         suffixIcon: MicIconButton(controller: _labourSearchController),
//                         hintText: translate('Search by pincode, city, or state',
//                             'पिनकोड, शहर या राज्य द्वारा खोजें'),
//                         hintStyle: Constants.AppTypography.body.copyWith(
//                             color: Constants.AppColors.inkSoft),
//                         fillColor: Constants.AppColors.card,
//                         filled: true,
//                         contentPadding: const EdgeInsets.symmetric(
//                             horizontal: 16, vertical: 14),
//                         enabledBorder: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(
//                               Constants.AppRadii.md),
//                           borderSide: const BorderSide(
//                               color: Constants.AppColors.border, width: 1.0),
//                         ),
//                         focusedBorder: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(
//                               Constants.AppRadii.md),
//                           borderSide: const BorderSide(
//                               color: Constants.AppColors.brand, width: 1.5),
//                         ),
//                       ),
//                     ),
//                   ),
//
//                   // Price Range Slider
//                   Padding(
//                     padding: const EdgeInsets.symmetric(vertical: 8.0),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                             translate('Select Budget Range', 'बजट सीमा चुनें')),
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
//
//                   // Project Type filter using checkboxes (Daily Wage and Contract)
//                   Padding(
//                     padding: const EdgeInsets.symmetric(vertical: 8.0),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(translate(
//                             'Select Job Type', 'नौकरी का प्रकार चुनें')),
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
//                             Text(translate('Daily Wage', 'दैनिक वेतन')),
//                             const SizedBox(width: 10),
//                             Checkbox(
//                               value: isContractSelected,
//                               onChanged: (bool? value) {
//                                 setStateDialog(() {
//                                   isContractSelected = value!;
//                                 });
//                               },
//                             ),
//                             Text(translate('Contract', 'ठेका')),
//                           ],
//                         ),
//                       ],
//                     ),
//                   ),
//                   const SizedBox(height: 10),
//                   // Rating filter (optional)
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
//                 child: Text(translate('Apply Filters', 'फ़िल्टर लागू करें')),
//               ),
//               TextButton(
//                 onPressed: () {
//                   // Reset filters to default values
//                   setStateDialog(() {
//                     selectedJobType = 'All';
//                     selectedCategory = 'All';
//                     selectedPriceRange = 1000000;
//                     isDailyWageSelected = false;
//                     isContractSelected = false;
//                     _labourSearchController.clear(); // Clear the search field
//                   });
//                 },
//                 child: Text(translate('Reset Filters', 'फ़िल्टर रीसेट करें'),
//                     style: const TextStyle(color: Colors.red)),
//               ),
//             ],
//           );
//         },
//       ),
//     );
//   }
//
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
//       setState(() {});
//     } catch (e) {
//       print("Translation error: $e");
//     }
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
//     // Example API request to fetch filtered projects
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
//       if (response.statusCode == 200) {
//         final responseBody = json.decode(response.body);
//         if (responseBody['status'] == 1) {
//           setState(() {
//             projects = responseBody['data'];
//             filteredProjects = projects;
//             isLoading = false;
//           });
//         } else {
//           setState(() {
//             projects = [];
//             filteredProjects = [];
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
//                   Text('Failed to fetch projects: ${response.statusCode}')),
//         );
//       }
//     } catch (e) {
//       setState(() {
//         isLoading = false;
//       });
//     }
//   }
//
//   TextEditingController _searchController = TextEditingController();
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
//     return RefreshIndicator(
//       onRefresh: () async {
//         // Assuming loadLanguage, fetchProjects, and fetchJobTypes are async functions.
//         await loadLanguage(); // Load the language (make sure it's an async function)
//         await fetchProjects(); // Fetch projects (make sure it's an async function)
//         await fetchJobTypes(); // Fetch job types (make sure it's an async function)
//
//         setState(() {
//           // If you need to update the UI state, you can do it here after all async tasks are done.
//         });
//       },
//       child: Scaffold(
//         backgroundColor: Constants.AppColors.surface,
//         body: SafeArea(
//           child: Container(
//             width: double.infinity,
//             height: double.infinity,
//             // decoration: const BoxDecoration(
//             //   gradient: LinearGradient(
//             //     begin: Alignment.topLeft,
//             //     end: Alignment.bottomRight,
//             //     colors: [
//             //       Color(0xFFA8D5BA), // Light green
//             //       Color(0xFF68A691), // Darker green
//             //     ],
//             //   ),
//             // ),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.end,
//               children: [
//                 IconButton(
//                   icon: const Icon(Icons.filter_list, color: Constants.AppColors.brand),
//                   onPressed: () => _showFilterDialog(),
//                 ),
//                 Expanded(
//                   child: isLoading
//                       ? const Center(child: CircularProgressIndicator())
//                       : filteredProjects.isEmpty
//                           ? Center(
//                               child: Text(
//                                 AppLocalizations.of(context)!.noProjectsFound,
//                                 style: Constants.AppTypography.h3.copyWith(
//                                   color: Constants.AppColors.inkSoft,
//                                 ),
//                               ),
//                             )
//                           : Scrollbar(
//                               controller: _scrollController,
//                               thumbVisibility: true,
//                               child: ListView.builder(
//                                 controller: _scrollController,
//                                 itemCount: filteredProjects.length,
//                                 itemBuilder: (context, index) {
//                                   final project = filteredProjects[index];
//                                   return InkWell(
//                                      onTap: () {
//                                        Navigator.push(
//                                          context,
//                                          MaterialPageRoute(
//                                            builder: (context) =>
//                                                ProjectDetails(
//                                              projectId: project['id'].toString(),
//                                            ),
//                                          ),
//                                        );
//                                      },
//                                      child: Container(
//                                        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
//                                        decoration: BoxDecoration(
//                                          color: Constants.AppColors.card,
//                                          borderRadius: BorderRadius.circular(16),
//                                          border: Border.all(
//                                            color: const Color(0xFFF1F5EE),
//                                            width: 1.0,
//                                          ),
//                                          boxShadow: [
//                                            BoxShadow(
//                                              color: Colors.black.withOpacity(0.04),
//                                              blurRadius: 16,
//                                              offset: const Offset(0, 6),
//                                            ),
//                                          ],
//                                        ),
//                                        child: Padding(
//                                          padding: const EdgeInsets.all(16),
//                                          child: Column(
//                                            crossAxisAlignment: CrossAxisAlignment.start,
//                                            children: [
//                                              // ── TOP ROW: Avatar + Title/Meta + Status badge ──
//                                              Row(
//                                                crossAxisAlignment: CrossAxisAlignment.start,
//                                                children: [
//                                                  // Left: Farmer Avatar
//                                                  Container(
//                                                    width: 50,
//                                                    height: 50,
//                                                    decoration: const BoxDecoration(
//                                                      color: Color(0xFFF1F5EE),
//                                                      shape: BoxShape.circle,
//                                                    ),
//                                                    alignment: Alignment.center,
//                                                    child: const Text(
//                                                      '👨‍🌾',
//                                                      style: TextStyle(fontSize: 26),
//                                                    ),
//                                                  ),
//                                                  const SizedBox(width: 12),
//                                                  // Right: Title + status badge row + Date + Type
//                                                  Expanded(
//                                                    child: Column(
//                                                      crossAxisAlignment: CrossAxisAlignment.start,
//                                                      children: [
//                                                        // ── Title + status badge on same row ──
//                                                        Row(
//                                                          crossAxisAlignment: CrossAxisAlignment.start,
//                                                          children: [
//                                                            Expanded(
//                                                              child: Text(
//                                                                translateText(project['title']?.toString() ?? 'No Title') ?? 'No Title',
//                                                                style: Constants.AppTypography.h2.copyWith(
//                                                                  color: Constants.AppColors.ink,
//                                                                  fontWeight: FontWeight.bold,
//                                                                  fontSize: 16,
//                                                                ),
//                                                                maxLines: 2,
//                                                                overflow: TextOverflow.ellipsis,
//                                                              ),
//                                                            ),
//                                                            if (project['applyStatus'] != null) ...[
//                                                              const SizedBox(width: 8),
//                                                              _buildStatusBadge(project),
//                                                            ],
//                                                          ],
//                                                        ),
//                                                        const SizedBox(height: 6),
//                                                        // ── Date + contract type tag row ──
//                                                        Row(
//                                                          children: [
//                                                            const Icon(
//                                                              Icons.calendar_today_outlined,
//                                                              size: 13,
//                                                              color: Colors.grey,
//                                                            ),
//                                                            const SizedBox(width: 4),
//                                                            Text(
//                                                              _formatDate(project['created_at']?.toString() ?? ''),
//                                                              style: const TextStyle(
//                                                                fontSize: 13,
//                                                                color: Colors.grey,
//                                                              ),
//                                                            ),
//                                                            const SizedBox(width: 10),
//                                                            Container(
//                                                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//                                                              decoration: BoxDecoration(
//                                                                color: Constants.AppColors.brandTint,
//                                                                borderRadius: BorderRadius.circular(6),
//                                                              ),
//                                                              child: Row(
//                                                                mainAxisSize: MainAxisSize.min,
//                                                                children: [
//                                                                  const Text('🌾', style: TextStyle(fontSize: 12)),
//                                                                  const SizedBox(width: 4),
//                                                                  Text(
//                                                                    translateText(project['project_type'] ?? 'N/A') ?? 'N/A',
//                                                                    style: TextStyle(
//                                                                      fontSize: 12,
//                                                                      fontWeight: FontWeight.bold,
//                                                                      color: Constants.AppColors.brandDeep,
//                                                                    ),
//                                                                  ),
//                                                                ],
//                                                              ),
//                                                            ),
//                                                          ],
//                                                        ),
//                                                      ],
//                                                    ),
//                                                  ),
//                                                ],
//                                              ),
//                                              const SizedBox(height: 12),
//                                              const Divider(color: Color(0xFFF1F5EE), height: 1),
//                                              const SizedBox(height: 10),
//                                              // ── Location ──
//                                              Row(
//                                                children: [
//                                                  const Text('📍', style: TextStyle(fontSize: 14)),
//                                                  const SizedBox(width: 6),
//                                                  Expanded(
//                                                    child: Text(
//                                                      "${translateText(project['city'] ?? 'N/A')}, ${translateText(project['state'] ?? 'N/A')}",
//                                                      style: Constants.AppTypography.body.copyWith(
//                                                        color: Constants.AppColors.inkSoft,
//                                                        fontWeight: FontWeight.w600,
//                                                        fontSize: 14,
//                                                      ),
//                                                    ),
//                                                  ),
//                                                ],
//                                              ),
//                                              const SizedBox(height: 12),
//                                              // ── ROW 1: Workers · Amount · Duration ──
//                                              Row(
//                                                children: [
//                                                  _buildChip(
//                                                    icon: Icons.people_outline,
//                                                    label: '${project['qty_labours'] ?? '0'} ${translate('Workers', 'मजदूर')}',
//                                                    bgColor: const Color(0xFFEAF4E8),
//                                                    textColor: const Color(0xFF0E6805),
//                                                    iconColor: const Color(0xFF0E6805),
//                                                  ),
//                                                  const SizedBox(width: 8),
//                                                  _buildChip(
//                                                    icon: Icons.currency_rupee,
//                                                    label: '₹${project['budget'] ?? '0'}',
//                                                    bgColor: const Color(0xFFFFF3E0),
//                                                    textColor: const Color(0xFFE65100),
//                                                    iconColor: const Color(0xFFE65100),
//                                                  ),
//                                                  const SizedBox(width: 8),
//                                                  _buildChip(
//                                                    icon: Icons.access_time,
//                                                    label: translateText(project['days']?.toString() ?? '') ?? '',
//                                                    bgColor: const Color(0xFFE3F2FD),
//                                                    textColor: const Color(0xFF0D47A1),
//                                                    iconColor: const Color(0xFF0D47A1),
//                                                  ),
//                                                ],
//                                              ),
//                                              const SizedBox(height: 10),
//                                              // ── ROW 2: View Details right-aligned ──
//                                              Align(
//                                                alignment: Alignment.centerRight,
//                                                child: _buildViewDetailsButton(project),
//                                              ),
//                                            ],
//                                          ),
//                                        ),
//                                      ),
//                                    );
//                                 },
//                               ),
//                             ),
//                 )
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
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
//
// class MilestoneService {
//   static const String _baseUrl =
//       '${Constants.AppConstants.apiUrl}labour/milestoneComplete'; // Update with your actual API URL
//
//   // Function to send milestone completion request
//   static Future<Map<String, dynamic>> completeMilestone({
//     required int projectId,
//     required String milestoneSno,
//     required int labourId,
//   }) async {
//     final Uri url = Uri.parse(_baseUrl);
//
//     try {
//       // Prepare the request payload
//       final Map<String, dynamic> payload = {
//         "projectid": projectId,
//         "milestonesno": milestoneSno,
//         "id": labourId,
//       };
//       print(jsonEncode(payload));
//       // Send the POST request
//       final response = await http.post(
//         url,
//         headers: {
//           "Content-Type": "application/json",
//           "Accept": "application/json",
//         },
//         body: jsonEncode(payload),
//       );
//
//       // Check the response status
//       if (response.statusCode == 200) {
//         final Map<String, dynamic> responseBody = json.decode(response.body);
//         return responseBody;
//       } else {
//         // Handle non-200 status codes
//         return {
//           "status": "0",
//           "message":
//               "Failed to complete milestone. Status Code: ${response.statusCode}"
//         };
//       }
//     } catch (e) {
//       // Handle exceptions
//       return {"status": "0", "message": "An error occurred: $e"};
//     }
//   }
// }
//
// class ProjectDetailsPage extends StatefulWidget {
//   final int projectId;
//   final _secureStorage = const FlutterSecureStorage();
//
//   const ProjectDetailsPage({Key? key, required this.projectId})
//       : super(key: key);
//
//   @override
//   _ProjectDetailsPageState createState() => _ProjectDetailsPageState();
// }
//
// class _ProjectDetailsPageState extends State<ProjectDetailsPage> {
//   late Future<Map<String, dynamic>> projectDetails;
//   late Map<String, dynamic> project;
//   bool isLoading = true;
//   late TextEditingController _commentController;
//   late TextEditingController _payController;
//   String? selectedEstimateDays;
//   final ScrollController _milestoneScrollController = ScrollController();
//
//   // Valid values for the Estimated Days dropdown
//   static const List<String> _validEstimateDays = [
//     '1 day',
//     '2 days',
//     '3-7 days',
//     '8-15 days',
//     '15-1 month',
//     '1-3 months',
//     '3-6 months',
//     '6 months-1 year',
//     '>1 year',
//   ];
//
//   String? _normalizeEstimateDays(dynamic val) {
//     if (val == null) return null;
//     String sVal = val.toString().trim();
//     if (sVal == '1' || sVal == '1 day') return '1 day';
//     if (sVal == '2' || sVal == '2 days') return '2 days';
//     if (sVal == '3-7 days') return '3-7 days';
//     if (sVal == '8-15 days') return '8-15 days';
//     if (sVal == '15-1 month') return '15-1 month';
//     if (sVal == '1-3 months') return '1-3 months';
//     if (sVal == '3-6 months') return '3-6 months';
//     if (sVal == '6 months-1 year') return '6 months-1 year';
//     if (sVal == '>1 year') return '>1 year';
//
//     // If it's a number, map it to the range
//     int? daysInt = int.tryParse(sVal);
//     if (daysInt != null) {
//       if (daysInt == 1) return '1 day';
//       if (daysInt == 2) return '2 days';
//       if (daysInt >= 3 && daysInt <= 7) return '3-7 days';
//       if (daysInt >= 8 && daysInt <= 15) return '8-15 days';
//       if (daysInt > 15 && daysInt <= 30) return '15-1 month';
//       if (daysInt > 30 && daysInt <= 90) return '1-3 months';
//       if (daysInt > 90 && daysInt <= 180) return '3-6 months';
//       if (daysInt > 180 && daysInt <= 365) return '6 months-1 year';
//       if (daysInt > 365) return '>1 year';
//     }
//     return null;
//   }
//
//   @override
//   void initState() {
//     super.initState();
//     loadLanguage();
//     _commentController = TextEditingController();
//     _payController = TextEditingController();
//
//     projectDetails = fetchProjectDetails(context, widget.projectId);
//
//     projectDetails.then((data) {
//       setState(() {
//         project = data;
//         isLoading = false;
//       });
//     });
//   }
//
//   @override
//   void dispose() {
//     _commentController.dispose();
//     _milestoneScrollController.dispose();
//     super.dispose();
//   }
//
//   Future<void> confirmcancel(BuildContext context, int projectId) async {
//     final String apiUrl =
//         '${Constants.AppConstants.apiUrl}labour/confirmcancel';
//
//     // Get user ID from secure storage
//     String? userId = await widget._secureStorage.read(key: 'id');
//     if (userId == null) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//             content: Text(translate('User ID not found in secure storage',
//                 'सुरक्षित भंडारण में उपयोगकर्ता आईडी नहीं मिली'))),
//       );
//       return;
//     }
//
//     final Map<String, dynamic> requestBody = {
//       'projectid': projectId,
//       'labourid': userId,
//     };
//
//     try {
//       print(jsonEncode(requestBody));
//       final response = await http.post(
//         Uri.parse(apiUrl),
//         headers: {'Content-Type': 'application/json'},
//         body: jsonEncode(requestBody),
//       );
//
//       if (response.statusCode == 200) {
//         final responseBody = json.decode(response.body);
//         if (responseBody['status'] == '1') {
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(
//                 content: Text(translate('Job Cancelled successfully!',
//                     'काम सफलतापूर्वक रद्द कर दिया गया!'))),
//           );
//         } else {
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(
//               content: Text(responseBody['message'] ??
//                   translate('Failed to cancel work', 'काम रद्द करने में विफल')),
//             ),
//           );
//         }
//       } else {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//               content: Text(
//                   translate('Failed to cancel work', 'काम रद्द करने में विफल') +
//                       ': ${response.body}')),
//         );
//       }
//     } catch (e) {
//       // Handle exceptions here if needed
//     }
//   }
//
//   void handleMilestoneCompletion(BuildContext context, String milestone) async {
//     // Retrieve user ID from secure storage
//     String? userId = await widget._secureStorage.read(key: 'id');
//     if (userId == null) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text(translate('User ID not found in secure storage',
//               'सुरक्षित भंडारण में उपयोगकर्ता आईडी नहीं मिली')),
//           backgroundColor: Colors.red,
//         ),
//       );
//       return;
//     }
//
//     // Prepare parameters
//     int projectId = widget.projectId;
//     String milestoneSno =
//         milestone; // Convert milestone to int, default to 1 if invalid
//     int labourId = int.parse(userId);
//
//     // Call the milestone completion API
//     final result = await MilestoneService.completeMilestone(
//       projectId: projectId,
//       milestoneSno: milestoneSno,
//       labourId: labourId,
//     );
//
//     // Show the result in a SnackBar
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text(result['message'] ??
//             translate('Unknown response', 'अज्ञात प्रतिक्रिया')),
//         backgroundColor: result['status'] == "1" ? Colors.green : Colors.red,
//         duration: const Duration(seconds: 3),
//       ),
//     );
//   }
//
//   Future<void> startWork(
//       BuildContext context, int projectId, Map<String, dynamic> project) async {
//     // Determine the correct endpoint based on payment type
//     final String apiUrl = '${Constants.AppConstants.apiUrl}labour/'
//         '${project['payment_type'] == "1" ? "milestoneprojectworkstart" : "projectworkstart"}';
//     print(apiUrl);
//
//     // Get user ID from secure storage
//     String? userId = await widget._secureStorage.read(key: 'id');
//     if (userId == null) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//             content: Text(translate('User ID not found in secure storage',
//                 'सुरक्षित भंडारण में उपयोगकर्ता आईडी नहीं मिली'))),
//       );
//       return;
//     }
//
//     // Prepare request body with corrected parameter names
//     final Map<String, dynamic> requestBody = {
//       'projectid': projectId,
//       'labourid': userId, // Corrected from 'labourid' to 'id'
//     };
//
//     try {
//       print('Request Body: ${jsonEncode(requestBody)}');
//
//       final response = await http.post(
//         Uri.parse(apiUrl),
//         headers: {'Content-Type': 'application/json'},
//         body: jsonEncode(requestBody),
//       );
//
//       // Handle the response
//       if (response.statusCode == 200) {
//         final responseBody = json.decode(response.body);
//         Fluttertoast.showToast(
//           msg: translate('You have successfully started this job.',
//               'आपने इस नौकरी को सफलतापूर्वक शुरू किया है।'),
//           toastLength: Toast.LENGTH_SHORT,
//           gravity: ToastGravity.BOTTOM,
//           backgroundColor: Constants.AppColors.brand,
//           textColor: Constants.AppColors.card,
//           fontSize: 16.0,
//         );
//
//         bool isSuccess = responseBody['status'] == '1';
//
//         // Navigate to homepage if successful
//         if (isSuccess) {
//           await Future.delayed(const Duration(seconds: 1));
//           Navigator.pushReplacement(
//             context,
//             MaterialPageRoute(builder: (context) => Labourhomepage()),
//           );
//         }
//       } else {
//         // Handle HTTP errors
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//               content: Text(
//                   translate('Failed to start work', 'काम शुरू करने में विफल'))),
//         );
//       }
//     } catch (e) {
//       // Handle network or unexpected errors
//     }
//   }
//
//   String translate(String enText, String hiText) {
//     // Get the selected language from the provider
//     final language =
//         Provider.of<LanguageProvider>(context, listen: false).selectedLanguage;
//
//     // Return the appropriate text based on the selected language
//     return language == 'en' ? enText : hiText;
//   }
//
//   List<Map<String, dynamic>> milestones = [];
//
//   Future<Map<String, dynamic>> fetchProjectDetails(
//       BuildContext context, int projectId) async {
//     final String apiUrl =
//         '${Constants.AppConstants.apiUrl}labour/projectDetailByLabour';
//
//     try {
//       // Retrieve user ID from secure storage
//       String? userId = await widget._secureStorage.read(key: 'id');
//       if (userId == null) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('User ID not found in secure storage')),
//         );
//         throw Exception('User ID not found.');
//       }
//
//       // Create the request body
//       final Map<String, dynamic> requestBody = {
//         'id': userId,
//         'project_id': projectId,
//       };
//
//       print(jsonEncode(requestBody)); // Debugging output
//
//       // Send the POST request
//       final response = await http.post(
//         Uri.parse(apiUrl),
//         headers: {'Content-Type': 'application/json'},
//         body: jsonEncode(requestBody),
//       );
//
//       // Parse the response
//       if (response.statusCode == 200) {
//         final responseBody = json.decode(response.body);
//
//         if (responseBody['status'] == 1 && responseBody['data'] is List) {
//           final data = responseBody['data'];
//
//           if (data.isNotEmpty) {
//             final project = data[0];
//
//             _commentController.text =
//                 project['comment'] ?? ''; // Set project description as comment
//             selectedEstimateDays = _normalizeEstimateDays(project['wpay'] ?? project['days']);
//             _payController.text = project['praposal_amount'] ?? '';
//             setState(() {
//               if (project['applyStatus'] != null) {
//                 print(project['pmilestones']);
//                 milestones = project['pmilestones'] is String
//                     ? List<Map<String, dynamic>>.from(
//                         jsonDecode(project['pmilestones']))
//                     : [];
//               } else {
//                 milestones = project['milestones'] is String
//                     ? List<Map<String, dynamic>>.from(
//                         jsonDecode(project['milestones']))
//                     : [];
//               } // Get the first project
//               _commentController.text = project['comment'] ?? '';
//
//               selectedEstimateDays = _normalizeEstimateDays(project['wpay'] ?? project['days']);
//               print(selectedEstimateDays);
//               _payController.text = project['praposal_amount'] ?? '';
//             });
//             return project;
//           } else {
//             throw Exception('No project data available.');
//           }
//         } else {
//           throw Exception(responseBody['message'] ?? 'Failed to fetch details');
//         }
//       } else {
//         throw Exception('Failed to fetch details: ${response.statusCode}');
//       }
//     } catch (e) {
//       throw Exception('An error occurred: $e');
//     }
//   }
//
//   bool _isButtonDisabled =
//       false; // Flag to control button's enabled/disabled state
//
//   Future<void> applyToProject(BuildContext context, int projectId) async {
//     final String apiUrl = '${Constants.AppConstants.apiUrl}labour/projectApply';
//
//     // Validate if all milestones have the necessary data
//     for (var milestone in milestones) {
//       // Check if 'amount' is missing or invalid
//       if (milestone['proposalamount'] == null ||
//           milestone['proposalamount'] <= 0) {
//         Fluttertoast.showToast(
//           msg: translate('Please fill in the amount for all milestones.',
//               'कृपया सभी माइलस्टोन के लिए राशि भरें'),
//           toastLength: Toast.LENGTH_SHORT,
//           gravity: ToastGravity.BOTTOM,
//           backgroundColor: Colors.red.shade700,
//           textColor: Colors.white,
//           fontSize: 16.0,
//         );
//         return; // Exit early if validation fails
//       }
//
//       // Check if 'duration' is missing or invalid
//       if (milestone['duration'] == null || milestone['duration'] <= 0) {
//         Fluttertoast.showToast(
//           msg: translate('Please fill in the duration for all milestones.',
//               'कृपया सभी माइलस्टोन के लिए अवधि भरें'),
//           toastLength: Toast.LENGTH_SHORT,
//           gravity: ToastGravity.BOTTOM,
//           backgroundColor: Colors.red.shade700,
//           textColor: Colors.white,
//           fontSize: 16.0,
//         );
//         return; // Exit early if validation fails
//       }
//     }
//
//     // Get user ID from secure storage
//     String? userId = await widget._secureStorage.read(key: 'id');
//     if (userId == null) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text(translate('User ID not found in secure storage',
//               'यूज़र आईडी सुरक्षित भंडारण में नहीं मिली')),
//         ),
//       );
//       return;
//     }
//
//     final Map<String, dynamic> requestBody = {
//       'labourid': userId,
//       'projectid': projectId,
//       'comment': _commentController.text,
//       'pamount': _payController.text,
//       'wday': selectedEstimateDays,
//       'milestones': milestones,
//     };
//
//     // Disable the button before submitting the form
//     setState(() {
//       _isButtonDisabled = true;
//     });
//
//     try {
//       print(jsonEncode(requestBody));
//       final response = await http.post(
//         Uri.parse(apiUrl),
//         headers: {'Content-Type': 'application/json'},
//         body: jsonEncode(requestBody),
//       );
//       print(response.statusCode);
//
//       if (response.statusCode == 200) {
//         final responseBody = json.decode(response.body);
//         if (responseBody['status'] == "1") {
//           Fluttertoast.showToast(
//             msg: translate(
//                 'Applied successfully!', 'सफलतापूर्वक लागू किया गया!'),
//             toastLength: Toast.LENGTH_SHORT,
//             gravity: ToastGravity.BOTTOM,
//             backgroundColor: Constants.AppColors.brand,
//             textColor: Constants.AppColors.card,
//             fontSize: 16.0,
//           );
//
//           Future.delayed(Duration(seconds: 1), () {
//             Navigator.pushReplacement(
//               context,
//               MaterialPageRoute(
//                 builder: (context) => Labourhomepage(),
//               ),
//             );
//           });
//         } else {
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(
//               content: Text(translate(
//                   responseBody['message'] ?? 'Failed to apply',
//                   responseBody['message'] ?? 'आवेदन विफल हुआ')),
//             ),
//           );
//         }
//       } else {
//         String errorMessage = 'Failed to apply';
//         String errorMessageHi = 'आवेदन विफल हुआ';
//         try {
//           final decoded = json.decode(response.body);
//           if (decoded is Map<String, dynamic>) {
//             if (decoded.containsKey('errors') && decoded['errors'] is Map) {
//               final errorsMap = decoded['errors'] as Map<String, dynamic>;
//               List<String> allErrors = [];
//               errorsMap.forEach((key, value) {
//                 if (value is List) {
//                   allErrors.addAll(value.map((e) => e.toString()));
//                 } else {
//                   allErrors.add(value.toString());
//                 }
//               });
//               if (allErrors.isNotEmpty) {
//                 errorMessage = allErrors.join(', ');
//                 errorMessageHi = errorMessage;
//               }
//             } else if (decoded.containsKey('message')) {
//               errorMessage = decoded['message'].toString();
//               errorMessageHi = errorMessage;
//             }
//           }
//         } catch (e) {
//           String bodyText = response.body.length > 100 ? response.body.substring(0, 100) + "..." : response.body;
//           errorMessage = 'Failed to apply: $bodyText';
//           errorMessageHi = 'आवेदन विफल हुआ: $bodyText';
//         }
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text(translate(errorMessage, errorMessageHi)),
//           ),
//         );
//       }
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content:
//               Text(translate('An error occurred: $e', 'एक त्रुटि हुई: $e')),
//         ),
//       );
//     } finally {
//       // Re-enable the button after the response is received
//       setState(() {
//         _isButtonDisabled = false;
//       });
//     }
//   }
//
//   Future<void> completework(BuildContext context, int projectId) async {
//     final String apiUrl =
//         '${Constants.AppConstants.apiUrl}labour/projectcomplete';
//
//     // Get user ID from secure storage
//     String? userId = await widget._secureStorage.read(key: 'id');
//     if (userId == null) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//             content: Text(translate('User ID not found in secure storage',
//                 'यूज़र आईडी सुरक्षित भंडारण में नहीं मिली'))),
//       );
//       return;
//     }
//
//     // Show a dialog to input remark
//     TextEditingController _dialogRemarkController = TextEditingController();
//     await showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: Text(translate('Enter remark', 'टिप्पणी दर्ज करें')),
//           content: TextField(
//             controller: _dialogRemarkController,
//             decoration:
//                 InputDecoration(
//                   hintText: translate('Remark', 'टिप्पणी'),
//                   suffixIcon: MicIconButton(controller: _dialogRemarkController),
//                 ),
//             maxLines: 3, // Allow multiple lines
//           ),
//           actions: <Widget>[
//             TextButton(
//               child: Text(translate('Cancel', 'रद्द करें')),
//               onPressed: () {
//                 Navigator.of(context).pop();
//               },
//             ),
//             TextButton(
//               child: Text(translate('Submit', 'सबमिट करें')),
//               onPressed: () async {
//                 String remark = _dialogRemarkController.text.trim();
//                 if (remark.isEmpty) {
//                   ScaffoldMessenger.of(context).showSnackBar(
//                     SnackBar(
//                       content: Text(translate('Remark cannot be empty',
//                           'टिप्पणी खाली नहीं हो सकती')),
//                     ),
//                   );
//                   return;
//                 }
//                 Navigator.of(context).pop(); // Close the dialog
//                 await _sendCompleteRequest(context, projectId, userId, remark);
//               },
//             ),
//           ],
//         );
//       },
//     );
//   }
//
//   Future<void> _sendCompleteRequest(
//       BuildContext context, int projectId, String userId, String remark) async {
//     final Map<String, dynamic> requestBody = {
//       'projectid': projectId,
//       'labourid': userId,
//       'completeremark': remark, // Include remark in the request
//     };
//
//     try {
//       print(jsonEncode(requestBody));
//       final response = await http.post(
//         Uri.parse('${Constants.AppConstants.apiUrl}labour/projectcomplete'),
//         headers: {'Content-Type': 'application/json'},
//         body: jsonEncode(requestBody),
//       );
//
//       if (response.statusCode == 200) {
//         final responseBody = json.decode(response.body);
//         if (responseBody['status'] == '1') {
//           Navigator.pushReplacement(
//             context,
//             MaterialPageRoute(
//               builder: (context) => Labourhomepage(),
//             ),
//           );
//           Fluttertoast.showToast(
//             msg: translate('Job Complete Request Sent Successfully!',
//                 'काम पूरा करने का अनुरोध सफलतापूर्वक भेजा गया!'),
//             toastLength: Toast.LENGTH_SHORT,
//             gravity: ToastGravity.BOTTOM,
//             backgroundColor: Constants.AppColors.brand,
//             textColor: Constants.AppColors.card,
//             fontSize: 16.0,
//           );
//         } else {
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(
//               content: Text(responseBody['message'] ??
//                   translate('Failed to Complete Request Sent',
//                       'काम पूरा करने का अनुरोध भेजने में विफल')),
//             ),
//           );
//         }
//       } else {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//               content: Text(translate(
//                   'Failed to start work:', 'काम शुरू करने में विफल:'))),
//         );
//       }
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//             content: Text(translate('An error occurred.', 'एक त्रुटि हुई।'))),
//       );
//     }
//   }
//
//   final FlutterSecureStorage _secureStorage = FlutterSecureStorage();
//   final GoogleTranslator _translator = GoogleTranslator();
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
//   double _rating = 1.0;
//   TextEditingController _remarksController = TextEditingController();
//   Future<void> _submitReview() async {
//     const String _baseUrl =
//         '${Constants.AppConstants.apiUrl}farmer/reviewForFarmer'; // Update with your actual API URL
//     print(_baseUrl);
//     print(project);
//     // Prepare the request body
//     final Map<String, dynamic> requestBody = {
//       'projectid': project['id'].toString(),
//       'labourid': project['labourId'].toString(),
//       'rating': _rating,
//       'review': _remarksController.text,
//     };
//
//     print(
//       jsonEncode(requestBody),
//     );
//
//     try {
//       final response = await http.post(
//         Uri.parse(_baseUrl), // Replace with your API URL
//         body: jsonEncode(requestBody),
//         headers: {
//           'Content-Type': 'application/json',
//         },
//       );
//
//       if (response.statusCode == 200) {
//         // Handle the response
//         final responseData = jsonDecode(response.body);
//         if (responseData['status'] == "1") {
//           Fluttertoast.showToast(
//             msg: translate('Review submitted successfully!',
//                 'समीक्षा सफलतापूर्वक प्रस्तुत की गई!'),
//             toastLength: Toast.LENGTH_SHORT,
//             gravity: ToastGravity.BOTTOM,
//             backgroundColor: Constants.AppColors.brand,
//             textColor: Constants.AppColors.card,
//             fontSize: 16.0,
//           );
//         } else {
//           // Show failure message in the appropriate language
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(
//                 content: Text(
//               translate('Failed to submit review.',
//                   'समीक्षा प्रस्तुत करने में विफल।'), // Use custom translate function
//             )),
//           );
//         }
//       } else {
//         // Error with response
//       }
//     } catch (e) {
//       // Network or other failure
//     }
//   }
//
//   void _showReviewDialog() {
//     showDialog(
//       context: context,
//       builder: (context) {
//         return StatefulBuilder(
//           builder: (BuildContext context, setState) {
//             return AlertDialog(
//               title:
//                   Text(translate('Review', 'समीक्षा')), // Title of the dialog
//               content: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   // Star rating input using Row (star buttons)
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: List.generate(5, (index) {
//                       return IconButton(
//                         icon: Icon(
//                           index < _rating ? Icons.star : Icons.star_border,
//                           color: const Color.fromARGB(255, 66, 60, 4),
//                         ),
//                         onPressed: () {
//                           setState(() {
//                             _rating = index + 1.0; // Update the rating value
//                           });
//                         },
//                       );
//                     }),
//                   ),
//                   // Remarks input (text field)
//                   TextField(
//                     controller: _remarksController,
//                     maxLines: 3,
//                     decoration: InputDecoration(
//                       hintText: translate('Write a Review For Worker',
//                           'मजदूर के लिए समीक्षा लिखें'), // Hint text for the review input
//                       border: OutlineInputBorder(),
//                       suffixIcon: MicIconButton(controller: _remarksController),
//                     ),
//                   ),
//                 ],
//               ),
//               actions: [
//                 TextButton(
//                   onPressed: () {
//                     Navigator.of(context).pop(); // Close the dialog
//                   },
//                   child: Text(
//                       translate('Cancel', 'रद्द करें')), // Cancel button text
//                 ),
//                 TextButton(
//                   onPressed: () {
//                     Navigator.of(context).pop();
//                     _submitReview(); // Call submit review after dialog is closed
//                   },
//                   child: Text(
//                       translate('Submit', 'सबमिट करें')), // Submit button text
//                 ),
//               ],
//             );
//           },
//         );
//       },
//     );
//   }
//
//   final _formKey = GlobalKey<FormState>();
//
//   Widget _buildActionButton(Map<String, dynamic> project) {
//     final applyStatus = project['applyStatus']?.toString();
//     final cancelConfirm = project['cancel_confirm']?.toString();
//     final completeConfirm = project['complete_confirm']?.toString();
//
//     if (applyStatus == "1") {
//       // Show Start Work button if project is assigned and not started
//       return ElevatedButton(
//         onPressed: () => startWork(context, project['id'], project),
//         style: ElevatedButton.styleFrom(
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(12),
//           ),
//           backgroundColor: Constants.AppColors.brand,
//           foregroundColor: Colors.white,
//           elevation: 0,
//         ),
//         child: Text(
//           AppLocalizations.of(context)!.workStart,
//           style: const TextStyle(
//             fontSize: 16,
//             fontWeight: FontWeight.bold,
//             color: Colors.white,
//           ),
//         ),
//       );
//     } else if (applyStatus == "0") {
//       // Applied but not started / assigned
//       return ElevatedButton(
//         onPressed: null,
//         style: ElevatedButton.styleFrom(
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(12),
//           ),
//           backgroundColor: Colors.grey[400],
//           foregroundColor: Colors.white,
//           elevation: 0,
//         ),
//         child: Text(
//           AppLocalizations.of(context)!.applied,
//           style: const TextStyle(
//             fontSize: 16,
//             fontWeight: FontWeight.bold,
//             color: Colors.white,
//           ),
//         ),
//       );
//     } else if (applyStatus == "2") {
//       // In progress
//       if (cancelConfirm == "1") {
//         // Farmer sent cancel request and it is confirmed
//         return ElevatedButton(
//           onPressed: () => confirmcancel(context, project['id']),
//           style: ElevatedButton.styleFrom(
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(12),
//             ),
//             backgroundColor: const Color(0xFFDC2626), // Premium red
//             foregroundColor: Colors.white,
//             elevation: 0,
//           ),
//           child: Text(
//             translateText('Confirm Cancelled'),
//             style: const TextStyle(
//               fontSize: 16,
//               fontWeight: FontWeight.bold,
//               color: Colors.white,
//             ),
//           ),
//         );
//       } else if (completeConfirm == "1") {
//         // Complete request has been confirmed
//         return ElevatedButton(
//           onPressed: null,
//           style: ElevatedButton.styleFrom(
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(12),
//             ),
//             backgroundColor: Colors.grey[400],
//             foregroundColor: Colors.white,
//             elevation: 0,
//           ),
//           child: Text(
//             translateText('Completion Requested'),
//             style: const TextStyle(
//               fontSize: 16,
//               fontWeight: FontWeight.bold,
//               color: Colors.white,
//             ),
//           ),
//         );
//       } else {
//         // Project is in progress, but complete request is not confirmed
//         return ElevatedButton(
//           onPressed: () => completework(context, project['id']),
//           style: ElevatedButton.styleFrom(
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(12),
//             ),
//             backgroundColor: Constants.AppColors.brand,
//             foregroundColor: Colors.white,
//             elevation: 0,
//           ),
//           child: Text(
//             translateText('Complete Work'),
//             style: const TextStyle(
//               fontSize: 16,
//               fontWeight: FontWeight.bold,
//               color: Colors.white,
//             ),
//           ),
//         );
//       }
//     } else if (applyStatus == "3") {
//       // Completed, worker can review or see completed status
//       final language = Provider.of<LanguageProvider>(context, listen: false).selectedLanguage;
//       String translate(String enText, String hiText) {
//         return language == 'en' ? enText : hiText;
//       }
//       return Row(
//         children: [
//           Expanded(
//             child: SizedBox(
//               height: 52,
//               child: OutlinedButton(
//                 onPressed: _showReviewDialog,
//                 style: OutlinedButton.styleFrom(
//                   side: BorderSide(color: Constants.AppColors.brand, width: 1.5),
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                 ),
//                 child: Text(
//                   translate('Review', "समीक्षा"),
//                   style: TextStyle(
//                     fontSize: 16,
//                     fontWeight: FontWeight.bold,
//                     color: Constants.AppColors.brand,
//                   ),
//                 ),
//               ),
//             ),
//           ),
//           const SizedBox(width: 12),
//           Expanded(
//             child: SizedBox(
//               height: 52,
//               child: ElevatedButton(
//                 onPressed: null,
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: Colors.grey[400],
//                   foregroundColor: Colors.white,
//                   elevation: 0,
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                 ),
//                 child: Text(
//                   translateText('Completed'),
//                   style: const TextStyle(
//                     fontSize: 16,
//                     fontWeight: FontWeight.bold,
//                     color: Colors.white,
//                   ),
//                 ),
//               ),
//             ),
//           ),
//         ],
//       );
//     } else if (applyStatus == "4") {
//       // Cancelled
//       return ElevatedButton(
//         onPressed: null,
//         style: ElevatedButton.styleFrom(
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(12),
//           ),
//           backgroundColor: Colors.grey[400],
//           foregroundColor: Colors.white,
//           elevation: 0,
//         ),
//         child: Text(
//           translateText('Cancelled'),
//           style: const TextStyle(
//             fontSize: 16,
//             fontWeight: FontWeight.bold,
//             color: Colors.white,
//           ),
//         ),
//       );
//     } else if (applyStatus == null) {
//       // Applied but not assigned yet (Form submit action)
//       return ElevatedButton(
//         onPressed: _isButtonDisabled
//             ? null
//             : () async {
//                 if (_formKey.currentState?.validate() ?? false) {
//                   await applyToProject(context, project['id']);
//                 } else {
//                   print('Form is invalid');
//                 }
//               },
//         style: ElevatedButton.styleFrom(
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(12),
//           ),
//           backgroundColor: Constants.AppColors.brand,
//           foregroundColor: Colors.white,
//           elevation: 0,
//         ),
//         child: Text(
//           translateText('Apply Now'),
//           style: const TextStyle(
//             fontSize: 16,
//             fontWeight: FontWeight.bold,
//             color: Colors.white,
//           ),
//         ),
//       );
//     } else {
//       // Fallback Cancelled
//       return ElevatedButton(
//         onPressed: null,
//         style: ElevatedButton.styleFrom(
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(12),
//           ),
//           backgroundColor: Colors.grey[400],
//           foregroundColor: Colors.white,
//           elevation: 0,
//         ),
//         child: Text(
//           translateText('Cancelled'),
//           style: const TextStyle(
//             fontSize: 16,
//             fontWeight: FontWeight.bold,
//             color: Colors.white,
//           ),
//         ),
//       );
//     }
//   }
//
//   Widget _infoCell({
//     required IconData icon,
//     required String label,
//     required String value,
//   }) {
//     return Expanded(
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Container(
//             width: 32,
//             height: 32,
//             decoration: const BoxDecoration(
//               color: Color(0xFFEAF4E8),
//               shape: BoxShape.circle,
//             ),
//             child: Icon(
//               icon,
//               color: const Color(0xFF0E6805),
//               size: 16,
//             ),
//           ),
//           const SizedBox(width: 8),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 Text(
//                   label,
//                   style: TextStyle(
//                     fontSize: 10,
//                     color: Colors.grey[500],
//                     fontWeight: FontWeight.w500,
//                   ),
//                   maxLines: 1,
//                   overflow: TextOverflow.ellipsis,
//                 ),
//                 const SizedBox(height: 2),
//                 Text(
//                   value,
//                   style: const TextStyle(
//                     fontSize: 12,
//                     fontWeight: FontWeight.bold,
//                     color: Color(0xFF152018),
//                   ),
//                   maxLines: 2,
//                   overflow: TextOverflow.ellipsis,
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildMilestoneAction({
//     required String label,
//     required Color color,
//     VoidCallback? onPressed,
//   }) {
//     return SizedBox(
//       height: 32,
//       child: ElevatedButton(
//         style: ElevatedButton.styleFrom(
//           backgroundColor: color,
//           foregroundColor: Colors.white,
//           elevation: 0,
//           padding: const EdgeInsets.symmetric(horizontal: 12),
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(8),
//           ),
//         ),
//         onPressed: onPressed,
//         child: Text(
//           label,
//           style: const TextStyle(
//             fontSize: 11,
//             fontWeight: FontWeight.bold,
//             color: Colors.white,
//           ),
//         ),
//       ),
//     );
//   }
//
//   String _getEstimateDaysHindi(String val) {
//     switch (val) {
//       case '1 day': return '1 दिन';
//       case '2 days': return '2 दिन';
//       case '3-7 days': return '3-7 दिन';
//       case '8-15 days': return '8-15 दिन';
//       case '15-1 month': return '15-1 महीना';
//       case '1-3 months': return '1-3 महीने';
//       case '3-6 months': return '3-6 महीने';
//       case '6 months-1 year': return '6 महीने-1 साल';
//       case '>1 year': return '> 1 साल';
//       default: return val;
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     // Function to show the add milestone dialog
//     void showAddMilestoneDialog() {
//       final descriptionController = TextEditingController();
//       final amountController = TextEditingController();
//
//       showDialog(
//         context: context,
//         builder: (BuildContext context) {
//           return AlertDialog(
//             title: Text('Add Milestone'),
//             content: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 TextField(
//                   controller: descriptionController,
//                   decoration: InputDecoration(
//                     labelText: 'Milestone Description',
//                     hintText: 'Enter milestone description',
//                   ),
//                 ),
//                 SizedBox(height: 10),
//                 TextField(
//                   controller: amountController,
//                   decoration: InputDecoration(
//                     labelText: 'Amount',
//                     hintText: 'Enter milestone amount',
//                   ),
//                   keyboardType: TextInputType.number,
//                 ),
//               ],
//             ),
//             actions: [
//               TextButton(
//                 onPressed: () {
//                   Navigator.pop(context);
//                 },
//                 child: Text('Cancel'),
//               ),
//               TextButton(
//                 onPressed: () {
//                   if (descriptionController.text.isNotEmpty &&
//                       amountController.text.isNotEmpty) {
//                     setState(() {
//                       milestones.add({
//                         'description': descriptionController.text,
//                         'amount': double.tryParse(amountController.text) ?? 0.0,
//                       });
//                     });
//                     Navigator.pop(context);
//                   }
//                 },
//                 child: Text('Add'),
//               ),
//             ],
//           );
//         },
//       );
//     }
//
//     // Function to show the edit milestone dialog
//     void showEditMilestoneDialog(int index, BuildContext context) {
//       final descriptionController =
//           TextEditingController(text: milestones[index]['description']);
//       String sno = milestones[index]['sno'].toString();
//       final amountController =
//           TextEditingController(text: milestones[index]['amount'].toString());
//       final durationController = TextEditingController(
//         text: milestones[index]['duration'] != null
//             ? milestones[index]['duration'].toString()
//             : '',
//       );
//       final praposalController = TextEditingController(
//         text: milestones[index]['proposalamount'] != null
//             ? milestones[index]['proposalamount'].toString()
//             : '',
//       );
//
//       // Fetch the current language setting
//       final language = Provider.of<LanguageProvider>(context, listen: false)
//           .selectedLanguage;
//
//       String translate(String enText, String hiText) {
//         return language == 'en' ? enText : hiText;
//       }
//
//       showDialog(
//         context: context,
//         builder: (BuildContext context) {
//           return AlertDialog(
//             title: Text(translate('Edit Milestone', 'माइलस्टोन संपादित करें')),
//             content: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 TextField(
//                   controller: descriptionController,
//                   decoration: InputDecoration(
//                     labelText:
//                         translate('Milestone Description', 'माइलस्टोन विवरण'),
//                     hintText: translate('Edit milestone description',
//                         'माइलस्टोन विवरण संपादित करें'),
//                   ),
//                 ),
//                 SizedBox(height: 10),
//                 TextField(
//                   controller: amountController,
//                   decoration: InputDecoration(
//                     labelText: translate('Amount', 'राशि'),
//                     hintText: translate(
//                         'Edit milestone amount', 'माइलस्टोन राशि संपादित करें'),
//                   ),
//                   keyboardType: TextInputType.number,
//                 ),
//                 SizedBox(height: 10),
//                 TextField(
//                   controller: durationController,
//                   decoration: InputDecoration(
//                     labelText: translate('Duration', 'अवधि'),
//                     hintText: translate('Enter Duration', 'अवधि दर्ज करें'),
//                   ),
//                   keyboardType: TextInputType.number,
//                 ),
//                 SizedBox(height: 10),
//                 TextField(
//                   controller: praposalController,
//                   decoration: InputDecoration(
//                     labelText: translate('Proposal Amount', 'प्रस्ताव राशि'),
//                     hintText: translate(
//                         'Enter Proposal amount', 'प्रस्ताव राशि दर्ज करें'),
//                   ),
//                   keyboardType: TextInputType.number,
//                 ),
//               ],
//             ),
//             actions: [
//               TextButton(
//                 onPressed: () {
//                   Navigator.pop(context);
//                 },
//                 child: Text(translate('Cancel', 'रद्द करें')),
//               ),
//               TextButton(
//                 onPressed: () {
//                   if (descriptionController.text.isNotEmpty &&
//                       amountController.text.isNotEmpty) {
//                     setState(() {
//                       milestones[index] = {
//                         'sno': sno,
//                         'description': descriptionController.text,
//                         'amount': double.tryParse(amountController.text) ?? 0.0,
//                         'proposalamount':
//                             double.tryParse(praposalController.text) ?? 0.0,
//                         'duration': int.tryParse(durationController.text) ?? 0,
//                         'startdate': '',
//                         'completedate': '',
//                         'status': '0',
//                         'paymentstatus': '0',
//                       };
//
//                       double totalProposalAmount =
//                           milestones.fold(0.0, (sum, milestone) {
//                         return sum + (milestone['proposalamount'] ?? 0.0);
//                       });
//                       _payController.text = totalProposalAmount.toString();
//                     });
//                     Navigator.pop(context);
//                   }
//                 },
//                 child: Text(translate('Save', 'सहेजें')),
//               ),
//             ],
//           );
//         },
//       );
//     }
//
//     final language =
//         Provider.of<LanguageProvider>(context, listen: false).selectedLanguage;
//
//     String translate(String enText, String hiText) {
//       return language == 'en' ? enText : hiText;
//     }
//
//     if (isLoading) {
//       return Scaffold(
//         backgroundColor: const Color(0xFFFAFBF7),
//         appBar: AppBar(
//           backgroundColor: Constants.AppColors.brand,
//           foregroundColor: Colors.white,
//           elevation: 0,
//           title: Text(
//             AppLocalizations.of(context)!.projectDetails,
//             style: const TextStyle(
//               fontSize: 18,
//               fontWeight: FontWeight.w600,
//               color: Colors.white,
//             ),
//           ),
//           iconTheme: const IconThemeData(color: Colors.white),
//         ),
//         body: const Center(child: CircularProgressIndicator()),
//       );
//     }
//
//     // Resolve details
//     final String title = translateText(project['title']?.toString() ?? 'No Title');
//     final String budget = project['budget'] != null ? '₹${project['budget']}' : 'N/A';
//     final String workers = project['qty_labours']?.toString() ?? 'N/A';
//     final String duration = project['days']?.toString() ?? 'N/A';
//     final String city = project['city']?.toString() ?? 'N/A';
//     final String state = project['state']?.toString() ?? 'N/A';
//     final String address = project['address']?.toString() ?? 'N/A';
//     final String projectType = translateText(project['project_type']?.toString() ?? 'N/A');
//     final String description = project['description']?.toString() ?? 'N/A';
//     final String paymentType = project['payment_type'] == "1"
//         ? translate('Milestone Basis', 'माइलस्टोन आधार')
//         : translate('Project Basis', 'प्रोजेक्ट आधार');
//     final String skillsText = translateText(project['required_skills']?.toString() ?? 'N/A');
//
//     return Scaffold(
//       backgroundColor: const Color(0xFFFAFBF7),
//       appBar: AppBar(
//         backgroundColor: Constants.AppColors.brand,
//         foregroundColor: Colors.white,
//         elevation: 0,
//         title: Text(
//           AppLocalizations.of(context)!.projectDetails,
//           style: const TextStyle(
//             fontSize: 18,
//             fontWeight: FontWeight.w600,
//             color: Colors.white,
//           ),
//         ),
//         iconTheme: const IconThemeData(color: Colors.white),
//       ),
//       body: Column(
//         children: [
//           Expanded(
//             child: SingleChildScrollView(
//               padding: const EdgeInsets.all(16),
//               child: Form(
//                 key: _formKey,
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     // ── Hero card ─────────────────────────────────────────────
//                     Container(
//                       decoration: BoxDecoration(
//                         color: Colors.white,
//                         borderRadius: BorderRadius.circular(16),
//                         boxShadow: [
//                           BoxShadow(
//                             color: Colors.black.withOpacity(0.04),
//                             blurRadius: 12,
//                             offset: const Offset(0, 4),
//                           ),
//                         ],
//                       ),
//                       padding: const EdgeInsets.all(16),
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Row(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               const CowAvatar(size: 70),
//                               const SizedBox(width: 12),
//                               Expanded(
//                                 child: Column(
//                                   crossAxisAlignment: CrossAxisAlignment.start,
//                                   children: [
//                                     Text(
//                                       title,
//                                       style: const TextStyle(
//                                         fontSize: 17,
//                                         fontWeight: FontWeight.w700,
//                                         color: Color(0xFF1B2B1B),
//                                       ),
//                                     ),
//                                     const SizedBox(height: 6),
//                                     Row(
//                                       children: [
//                                         Icon(Icons.person_outline,
//                                             size: 14, color: Colors.grey[500]),
//                                         const SizedBox(width: 4),
//                                         Text(
//                                           translate('Posted by ', 'द्वारा पोस्ट किया गया '),
//                                           style: TextStyle(
//                                               fontSize: 11,
//                                               color: Colors.grey[500]),
//                                         ),
//                                         Expanded(
//                                           child: Text(
//                                             translateText(project['farmer_name']?.toString() ?? 'N/A'),
//                                             style: TextStyle(
//                                               fontSize: 11,
//                                               color: Constants.AppColors.brand,
//                                               fontWeight: FontWeight.bold,
//                                             ),
//                                             maxLines: 1,
//                                             overflow: TextOverflow.ellipsis,
//                                           ),
//                                         ),
//                                         const SizedBox(width: 4),
//                                         Icon(Icons.calendar_today_outlined,
//                                             size: 11, color: Colors.grey[400]),
//                                         const SizedBox(width: 3),
//                                         Text(
//                                           translateText(project['time_elapsed']?.toString() ?? 'N/A'),
//                                           style: TextStyle(
//                                               fontSize: 11,
//                                               color: Colors.grey[500]),
//                                         ),
//                                       ],
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                               const SizedBox(width: 4),
//                               Container(
//                                 padding: const EdgeInsets.symmetric(
//                                     horizontal: 8, vertical: 4),
//                                 decoration: BoxDecoration(
//                                   color: const Color(0xFFEAF4E8),
//                                   borderRadius: BorderRadius.circular(20),
//                                   border: Border.all(
//                                       color: const Color(0xFFA5D6A7), width: 1),
//                                 ),
//                                 child: Row(
//                                   mainAxisSize: MainAxisSize.min,
//                                   children: [
//                                     Icon(Icons.check,
//                                         size: 11,
//                                         color: Constants.AppColors.brand),
//                                     const SizedBox(width: 2),
//                                     Text(
//                                       translateText(project['status']?.toString() ?? 'Active'),
//                                       style: TextStyle(
//                                         fontSize: 10,
//                                         fontWeight: FontWeight.bold,
//                                         color: Constants.AppColors.brand,
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                             ],
//                           ),
//                           const SizedBox(height: 20),
//
//                           // 3x2 stats grid
//                           Row(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               _infoCell(
//                                 icon: Icons.currency_rupee,
//                                 label: translate('Budget', 'बजट'),
//                                 value: budget,
//                               ),
//                               _infoCell(
//                                 icon: Icons.group_outlined,
//                                 label: translate('Workers Required', 'आवश्यक मजदूर'),
//                                 value: workers,
//                               ),
//                               _infoCell(
//                                 icon: Icons.access_time_outlined,
//                                 label: translate('Duration', 'अवधि'),
//                                 value: duration,
//                               ),
//                             ],
//                           ),
//                           const SizedBox(height: 16),
//                           Row(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               _infoCell(
//                                 icon: Icons.location_on_outlined,
//                                 label: translate('Location', 'स्थान'),
//                                 value: '${translateText(city)}, ${translateText(state)}',
//                               ),
//                               _infoCell(
//                                 icon: Icons.business_outlined,
//                                 label: translate('Address', 'पता'),
//                                 value: address,
//                               ),
//                               _infoCell(
//                                 icon: Icons.description_outlined,
//                                 label: translate('Project Type', 'प्रोजेक्ट प्रकार'),
//                                 value: projectType,
//                               ),
//                             ],
//                           ),
//                         ],
//                       ),
//                     ),
//                     const SizedBox(height: 12),
//
//                     // Skills Required Card
//                     Container(
//                       width: double.infinity,
//                       decoration: BoxDecoration(
//                         color: Colors.white,
//                         borderRadius: BorderRadius.circular(16),
//                         boxShadow: [
//                           BoxShadow(
//                             color: Colors.black.withOpacity(0.04),
//                             blurRadius: 10,
//                             offset: const Offset(0, 2),
//                           ),
//                         ],
//                       ),
//                       padding: const EdgeInsets.all(16),
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Row(
//                             children: [
//                               Container(
//                                 width: 36,
//                                 height: 36,
//                                 decoration: const BoxDecoration(
//                                   color: Color(0xFFFFF3E0),
//                                   shape: BoxShape.circle,
//                                 ),
//                                 child: const Icon(
//                                   Icons.workspace_premium_outlined,
//                                   color: Color(0xFFFF8F00),
//                                   size: 18,
//                                 ),
//                               ),
//                               const SizedBox(width: 10),
//                               Text(
//                                 translate('Skills Required', 'आवश्यक कौशल'),
//                                 style: const TextStyle(
//                                   fontSize: 15,
//                                   fontWeight: FontWeight.w700,
//                                   color: Color(0xFF1B2B1B),
//                                 ),
//                               ),
//                             ],
//                           ),
//                           const SizedBox(height: 12),
//                           Wrap(
//                             spacing: 8,
//                             runSpacing: 8,
//                             children: skillsText.split(',').map((skill) {
//                               final cleanSkill = skill.trim();
//                               if (cleanSkill.isEmpty) return const SizedBox.shrink();
//                               return Container(
//                                 padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//                                 decoration: BoxDecoration(
//                                   color: const Color(0xFFFFFBEB),
//                                   borderRadius: BorderRadius.circular(20),
//                                   border: Border.all(color: const Color(0xFFFDE68A), width: 1),
//                                 ),
//                                 child: Text(
//                                   cleanSkill,
//                                   style: const TextStyle(
//                                     fontSize: 13,
//                                     fontWeight: FontWeight.w600,
//                                     color: Color(0xFFB45309),
//                                   ),
//                                 ),
//                               );
//                             }).toList(),
//                           ),
//                         ],
//                       ),
//                     ),
//                     const SizedBox(height: 12),
//
//                     // Payment Type Card
//                     Container(
//                       width: double.infinity,
//                       decoration: BoxDecoration(
//                         color: Colors.white,
//                         borderRadius: BorderRadius.circular(16),
//                         boxShadow: [
//                           BoxShadow(
//                             color: Colors.black.withOpacity(0.04),
//                             blurRadius: 10,
//                             offset: const Offset(0, 2),
//                           ),
//                         ],
//                       ),
//                       padding: const EdgeInsets.all(16),
//                       child: Row(
//                         children: [
//                           Container(
//                             width: 36,
//                             height: 36,
//                             decoration: const BoxDecoration(
//                               color: Color(0xFFEAF4E8),
//                               shape: BoxShape.circle,
//                             ),
//                             child: const Icon(
//                               Icons.receipt_long_outlined,
//                               color: Color(0xFF0E6805),
//                               size: 18,
//                             ),
//                           ),
//                           const SizedBox(width: 10),
//                           Expanded(
//                             child: Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 Text(
//                                   translate('Payment Type', 'भुगतान का प्रकार'),
//                                   style: TextStyle(
//                                     fontSize: 11,
//                                     color: Colors.grey[500],
//                                     fontWeight: FontWeight.w500,
//                                   ),
//                                 ),
//                                 const SizedBox(height: 2),
//                                 Text(
//                                   paymentType,
//                                   style: const TextStyle(
//                                     fontSize: 14,
//                                     fontWeight: FontWeight.bold,
//                                     color: Color(0xFF152018),
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                     const SizedBox(height: 12),
//
//                     // Project Description Card
//                     Container(
//                       width: double.infinity,
//                       decoration: BoxDecoration(
//                         color: Colors.white,
//                         borderRadius: BorderRadius.circular(16),
//                         boxShadow: [
//                           BoxShadow(
//                             color: Colors.black.withOpacity(0.04),
//                             blurRadius: 10,
//                             offset: const Offset(0, 2),
//                           ),
//                         ],
//                       ),
//                       padding: const EdgeInsets.all(16),
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Row(
//                             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                             children: [
//                               Row(
//                                 children: [
//                                   Icon(Icons.assignment_outlined,
//                                       color: Constants.AppColors.brand, size: 20),
//                                   const SizedBox(width: 8),
//                                   Text(
//                                     translate('Project Description', 'परियोजना विवरण'),
//                                     style: TextStyle(
//                                       fontSize: 15,
//                                       fontWeight: FontWeight.w700,
//                                       color: Constants.AppColors.ink,
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                               SpeakerIconButton(
//                                 text: translateText(description),
//                                 size: 18,
//                               ),
//                             ],
//                           ),
//                           const SizedBox(height: 10),
//                           Text(
//                             translateText(description),
//                             style: TextStyle(
//                               fontSize: 13,
//                               color: Colors.grey[700],
//                               height: 1.5,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                     const SizedBox(height: 12),
//
//                     // Milestone & Payment (only if Milestone Basis and milestones exist)
//                     if (project['payment_type'] == "1" && milestones.isNotEmpty) ...[
//                       Container(
//                         width: double.infinity,
//                         decoration: BoxDecoration(
//                           color: Colors.white,
//                           borderRadius: BorderRadius.circular(16),
//                           boxShadow: [
//                             BoxShadow(
//                               color: Colors.black.withOpacity(0.04),
//                               blurRadius: 10,
//                               offset: const Offset(0, 2),
//                             ),
//                           ],
//                         ),
//                         padding: const EdgeInsets.all(16),
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Row(
//                               children: [
//                                 Icon(Icons.layers_outlined,
//                                     color: Constants.AppColors.brand, size: 20),
//                                 const SizedBox(width: 8),
//                                 Text(
//                                   translate('Milestone & Payment', 'माइलस्टोन और भुगतान'),
//                                   style: TextStyle(
//                                     fontSize: 15,
//                                     fontWeight: FontWeight.w700,
//                                     color: Constants.AppColors.ink,
//                                   ),
//                                 ),
//                               ],
//                             ),
//                             const SizedBox(height: 12),
//
//                             // Horizontally Scrollable Table
//                             SingleChildScrollView(
//                               scrollDirection: Axis.horizontal,
//                               child: SizedBox(
//                                 width: 560,
//                                 child: Column(
//                                   children: [
//                                     // Table Header
//                                     Container(
//                                       decoration: BoxDecoration(
//                                         color: Constants.AppColors.brand,
//                                         borderRadius: const BorderRadius.only(
//                                           topLeft: Radius.circular(8),
//                                           topRight: Radius.circular(8),
//                                         ),
//                                       ),
//                                       padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
//                                       child: Row(
//                                         children: [
//                                           Expanded(
//                                             flex: 3,
//                                             child: Text(
//                                               translate('Description', 'विवरण'),
//                                               style: const TextStyle(
//                                                 color: Colors.white,
//                                                 fontWeight: FontWeight.w600,
//                                                 fontSize: 12,
//                                               ),
//                                             ),
//                                           ),
//                                           Expanded(
//                                             flex: 2,
//                                             child: Text(
//                                               translate('Amount', 'राशि'),
//                                               textAlign: TextAlign.center,
//                                               style: const TextStyle(
//                                                 color: Colors.white,
//                                                 fontWeight: FontWeight.w600,
//                                                 fontSize: 12,
//                                               ),
//                                             ),
//                                           ),
//                                           Expanded(
//                                             flex: 2,
//                                             child: Text(
//                                               translate('Proposal/Days', 'प्रस्ताव/दिन'),
//                                               textAlign: TextAlign.center,
//                                               style: const TextStyle(
//                                                 color: Colors.white,
//                                                 fontWeight: FontWeight.w600,
//                                                 fontSize: 12,
//                                               ),
//                                             ),
//                                           ),
//                                           Expanded(
//                                             flex: 2,
//                                             child: Text(
//                                               translate('Action', 'कार्रवाई'),
//                                               textAlign: TextAlign.right,
//                                               style: const TextStyle(
//                                                 color: Colors.white,
//                                                 fontWeight: FontWeight.w600,
//                                                 fontSize: 12,
//                                               ),
//                                             ),
//                                           ),
//                                         ],
//                                       ),
//                                     ),
//
//                                     // Rows
//                                     ...List.generate(milestones.length, (index) {
//                                       final milestone = milestones[index];
//                                       final isEven = index % 2 == 0;
//                                       final mStatus = milestone['status']?.toString();
//                                       final proposalAmt = milestone['proposalamount'] ?? milestone['proposal'] ?? '-';
//                                       final mDuration = milestone['duration'] ?? '-';
//
//                                       return Container(
//                                         padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
//                                         decoration: BoxDecoration(
//                                           color: isEven ? Colors.white : const Color(0xFFF9FBF9),
//                                           border: Border(
//                                             bottom: BorderSide(color: Colors.grey[100]!, width: 1),
//                                           ),
//                                         ),
//                                         child: Row(
//                                           children: [
//                                             Expanded(
//                                               flex: 3,
//                                               child: Text(
//                                                 translateText(milestone['description'] ?? 'N/A'),
//                                                 style: TextStyle(
//                                                   fontSize: 13,
//                                                   color: Constants.AppColors.ink,
//                                                 ),
//                                               ),
//                                             ),
//                                             Expanded(
//                                               flex: 2,
//                                               child: Text(
//                                                 milestone['amount']?.toString() ?? 'N/A',
//                                                 textAlign: TextAlign.center,
//                                                 style: TextStyle(
//                                                   fontSize: 13,
//                                                   color: Constants.AppColors.ink,
//                                                 ),
//                                               ),
//                                             ),
//                                             Expanded(
//                                               flex: 2,
//                                               child: Text(
//                                                 '$proposalAmt / $mDuration',
//                                                 textAlign: TextAlign.center,
//                                                 style: TextStyle(
//                                                   fontSize: 13,
//                                                   color: Constants.AppColors.ink,
//                                                 ),
//                                               ),
//                                             ),
//                                             Expanded(
//                                               flex: 2,
//                                               child: Align(
//                                                 alignment: Alignment.centerRight,
//                                                 child: mStatus == '2'
//                                                     ? _buildMilestoneAction(
//                                                         label: translate('Complete', 'पूर्ण'),
//                                                         color: Constants.AppColors.brand,
//                                                         onPressed: () => handleMilestoneCompletion(
//                                                           context,
//                                                           milestone['sno'].toString(),
//                                                         ),
//                                                       )
//                                                     : mStatus == '3'
//                                                         ? _buildMilestoneAction(
//                                                             label: translate('Submitted', 'जमा किया'),
//                                                             color: const Color(0xFFF97316),
//                                                             onPressed: null,
//                                                           )
//                                                         : mStatus == '4'
//                                                             ? _buildMilestoneAction(
//                                                                 label: translate('Completed', 'पूर्ण किया'),
//                                                                 color: const Color(0xFF16A34A),
//                                                                 onPressed: null,
//                                                               )
//                                                             : IconButton(
//                                                                 icon: const Icon(Icons.edit_outlined,
//                                                                     color: Colors.blue, size: 20),
//                                                                 padding: EdgeInsets.zero,
//                                                                 constraints: const BoxConstraints(),
//                                                                 onPressed: () => showEditMilestoneDialog(
//                                                                     index, context),
//                                                               ),
//                                               ),
//                                             ),
//                                           ],
//                                         ),
//                                       );
//                                     }),
//                                   ],
//                                 ),
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                       const SizedBox(height: 12),
//                     ],
//
//                     // Proposal Summary / Form Input depending on applyStatus
//                     if (project['applyStatus'] != null) ...[
//                       // Applied: show proposal details in a premium card
//                       Container(
//                         decoration: BoxDecoration(
//                           color: const Color(0xFFF1F9F1),
//                           borderRadius: BorderRadius.circular(16),
//                           border: Border.all(color: const Color(0xFFE2EFE2), width: 1),
//                         ),
//                         padding: const EdgeInsets.all(16),
//                         child: Row(
//                           children: [
//                             // Proposal Amount
//                             Expanded(
//                               child: Row(
//                                 children: [
//                                   Container(
//                                     width: 32,
//                                     height: 32,
//                                     decoration: const BoxDecoration(
//                                       color: Color(0xFFEAF4E8),
//                                       shape: BoxShape.circle,
//                                     ),
//                                     child: const Icon(
//                                       Icons.edit_note_outlined,
//                                       color: Color(0xFF0E6805),
//                                       size: 18,
//                                     ),
//                                   ),
//                                   const SizedBox(width: 8),
//                                   Expanded(
//                                     child: Column(
//                                       crossAxisAlignment: CrossAxisAlignment.start,
//                                       children: [
//                                         Text(
//                                           translate('Proposal Amount', 'प्रस्ताव राशि'),
//                                           style: const TextStyle(
//                                             fontSize: 10,
//                                             color: Color(0xFF5B6B5E),
//                                             fontWeight: FontWeight.w500,
//                                           ),
//                                           maxLines: 1,
//                                           overflow: TextOverflow.ellipsis,
//                                         ),
//                                         const SizedBox(height: 2),
//                                         Text(
//                                           project['praposal_amount'] != null
//                                               ? '₹${project['praposal_amount']}'
//                                               : 'N/A',
//                                           style: const TextStyle(
//                                             fontSize: 12,
//                                             fontWeight: FontWeight.bold,
//                                             color: Color(0xFF152018),
//                                           ),
//                                           maxLines: 1,
//                                           overflow: TextOverflow.ellipsis,
//                                         ),
//                                       ],
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ),
//                             // Estimate Duration
//                             Expanded(
//                               child: Row(
//                                 children: [
//                                   Container(
//                                     width: 32,
//                                     height: 32,
//                                     decoration: const BoxDecoration(
//                                       color: Color(0xFFEAF4E8),
//                                       shape: BoxShape.circle,
//                                     ),
//                                     child: const Icon(
//                                       Icons.access_time_outlined,
//                                       color: Color(0xFF0E6805),
//                                       size: 18,
//                                     ),
//                                   ),
//                                   const SizedBox(width: 8),
//                                   Expanded(
//                                     child: Column(
//                                       crossAxisAlignment: CrossAxisAlignment.start,
//                                       children: [
//                                         Text(
//                                           translate('Estimate Duration', 'अनुमानित अवधि'),
//                                           style: const TextStyle(
//                                             fontSize: 10,
//                                             color: Color(0xFF5B6B5E),
//                                             fontWeight: FontWeight.w500,
//                                           ),
//                                           maxLines: 1,
//                                           overflow: TextOverflow.ellipsis,
//                                         ),
//                                         const SizedBox(height: 2),
//                                         Text(
//                                           translateText(project['wpay']?.toString() ?? 'N/A'),
//                                           style: const TextStyle(
//                                             fontSize: 12,
//                                             fontWeight: FontWeight.bold,
//                                             color: Color(0xFF152018),
//                                           ),
//                                           maxLines: 1,
//                                           overflow: TextOverflow.ellipsis,
//                                         ),
//                                       ],
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ),
//                             // Comment
//                             Expanded(
//                               child: Row(
//                                 children: [
//                                   Container(
//                                     width: 32,
//                                     height: 32,
//                                     decoration: const BoxDecoration(
//                                       color: Color(0xFFEAF4E8),
//                                       shape: BoxShape.circle,
//                                     ),
//                                     child: const Icon(
//                                       Icons.chat_bubble_outline,
//                                       color: Color(0xFF0E6805),
//                                       size: 16,
//                                     ),
//                                   ),
//                                   const SizedBox(width: 8),
//                                   Expanded(
//                                     child: Column(
//                                       crossAxisAlignment: CrossAxisAlignment.start,
//                                       children: [
//                                         Text(
//                                           translate('Comment', 'टिप्पणी'),
//                                           style: const TextStyle(
//                                             fontSize: 10,
//                                             color: Color(0xFF5B6B5E),
//                                             fontWeight: FontWeight.w500,
//                                           ),
//                                           maxLines: 1,
//                                           overflow: TextOverflow.ellipsis,
//                                         ),
//                                         const SizedBox(height: 2),
//                                         Text(
//                                           translateText(project['comment']?.toString() ?? 'N/A'),
//                                           style: const TextStyle(
//                                             fontSize: 12,
//                                             fontWeight: FontWeight.bold,
//                                             color: Color(0xFF152018),
//                                           ),
//                                           maxLines: 1,
//                                           overflow: TextOverflow.ellipsis,
//                                         ),
//                                       ],
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ] else ...[
//                       // Not applied: show Proposal inputs inside a card
//                       Container(
//                         decoration: BoxDecoration(
//                           color: Colors.white,
//                           borderRadius: BorderRadius.circular(16),
//                           boxShadow: [
//                             BoxShadow(
//                               color: Colors.black.withOpacity(0.04),
//                               blurRadius: 10,
//                               offset: const Offset(0, 2),
//                             ),
//                           ],
//                         ),
//                         padding: const EdgeInsets.all(16),
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Row(
//                               children: [
//                                 Icon(Icons.rate_review_outlined,
//                                     color: Constants.AppColors.brand, size: 20),
//                                 const SizedBox(width: 8),
//                                 Text(
//                                   translate('Submit Your Proposal', 'अपना प्रस्ताव जमा करें'),
//                                   style: TextStyle(
//                                     fontSize: 15,
//                                     fontWeight: FontWeight.w700,
//                                     color: Constants.AppColors.ink,
//                                   ),
//                                 ),
//                               ],
//                             ),
//                             const SizedBox(height: 16),
//                             TextFormField(
//                               controller: _payController,
//                               keyboardType: TextInputType.number,
//                               decoration: InputDecoration(
//                                 labelText: translate("Proposal Amount", "प्रस्ताव राशि"),
//                                 labelStyle: TextStyle(color: Colors.grey[600], fontSize: 13),
//                                 border: OutlineInputBorder(
//                                   borderRadius: BorderRadius.circular(10),
//                                   borderSide: BorderSide(color: Colors.grey[300]!),
//                                 ),
//                                 enabledBorder: OutlineInputBorder(
//                                   borderRadius: BorderRadius.circular(10),
//                                   borderSide: BorderSide(color: Colors.grey[200]!),
//                                 ),
//                                 focusedBorder: OutlineInputBorder(
//                                   borderRadius: BorderRadius.circular(10),
//                                   borderSide: BorderSide(color: Constants.AppColors.brand, width: 1.5),
//                                 ),
//                                 contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
//                               ),
//                               validator: (value) {
//                                 if (value == null || value.isEmpty) {
//                                   return translate('Please enter a proposal amount', 'कृपया प्रस्ताव राशि दर्ज करें');
//                                 }
//                                 if (double.tryParse(value) == null) {
//                                   return translate('Please enter a valid number', 'कृपया एक मान्य संख्या दर्ज करें');
//                                 }
//                                 return null;
//                               },
//                             ),
//                             const SizedBox(height: 16),
//                             DropdownButtonFormField<String>(
//                               value: selectedEstimateDays,
//                               onChanged: (newValue) {
//                                 setState(() {
//                                   selectedEstimateDays = newValue;
//                                 });
//                               },
//                               decoration: InputDecoration(
//                                 labelText: translate('Estimated Days', 'अनुमानित दिन'),
//                                 labelStyle: TextStyle(color: Colors.grey[600], fontSize: 13),
//                                 border: OutlineInputBorder(
//                                   borderRadius: BorderRadius.circular(10),
//                                   borderSide: BorderSide(color: Colors.grey[300]!),
//                                 ),
//                                 enabledBorder: OutlineInputBorder(
//                                   borderRadius: BorderRadius.circular(10),
//                                   borderSide: BorderSide(color: Colors.grey[200]!),
//                                 ),
//                                 focusedBorder: OutlineInputBorder(
//                                   borderRadius: BorderRadius.circular(10),
//                                   borderSide: BorderSide(color: Constants.AppColors.brand, width: 1.5),
//                                 ),
//                                 contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
//                               ),
//                               items: _validEstimateDays.map((val) {
//                                 return DropdownMenuItem<String>(
//                                   value: val,
//                                   child: Text(translate(val, _getEstimateDaysHindi(val))),
//                                 );
//                               }).toList(),
//                               validator: (value) {
//                                 if (value == null || value.isEmpty) {
//                                   return translate(
//                                       'Please enter the estimated days.',
//                                       'कृपया अनुमानित दिन दर्ज करें।');
//                                 }
//                                 return null;
//                               },
//                             ),
//                             const SizedBox(height: 16),
//                             TextFormField(
//                               controller: _commentController,
//                               decoration: InputDecoration(
//                                 labelText: translate("Enter your Comment", "अपनी टिप्पणी दर्ज करें"),
//                                 labelStyle: TextStyle(color: Colors.grey[600], fontSize: 13),
//                                 suffixIcon: MicIconButton(controller: _commentController),
//                                 border: OutlineInputBorder(
//                                   borderRadius: BorderRadius.circular(10),
//                                   borderSide: BorderSide(color: Colors.grey[300]!),
//                                 ),
//                                 enabledBorder: OutlineInputBorder(
//                                   borderRadius: BorderRadius.circular(10),
//                                   borderSide: BorderSide(color: Colors.grey[200]!),
//                                 ),
//                                 focusedBorder: OutlineInputBorder(
//                                   borderRadius: BorderRadius.circular(10),
//                                   borderSide: BorderSide(color: Constants.AppColors.brand, width: 1.5),
//                                 ),
//                                 contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
//                               ),
//                               maxLines: 2,
//                             ),
//                           ],
//                         ),
//                       ),
//                     ],
//
//                     const SizedBox(height: 100),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//
//           // ── Fixed bottom CTA ───────────────────────────────────────────────
//           Container(
//             color: const Color(0xFFFAFBF7),
//             padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
//             child: SizedBox(
//               width: double.infinity,
//               height: 52,
//               child: _buildActionButton(project),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
//
// class AppliedProjects extends StatefulWidget {
//   @override
//   _AppliedProjectsState createState() => _AppliedProjectsState();
// }
//
// class _AppliedProjectsState extends State<AppliedProjects> {
//   final _secureStorage = const FlutterSecureStorage();
//   bool isLoading = true;
//   List<dynamic> projects = [];
//   List<dynamic> filteredProjects = [];
//   List<JobType> _jobTypes = [];
//   final ScrollController _appliedProjectsScrollController = ScrollController();
//
//   final TextEditingController _labourSearchController = TextEditingController();
//
//   @override
//   void dispose() {
//     _projectSearchController.dispose();
//     _labourSearchController.dispose();
//     _appliedProjectsScrollController.dispose();
//     super.dispose();
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
//   @override
//   void initState() {
//     super.initState();
//     loadLanguage();
//     fetchProjects();
//     fetchJobTypes();
//   }
//
//   final TextEditingController _projectSearchController =
//       TextEditingController();
//   String selectedCategory = 'All';
//   double selectedPriceRange = 1000000;
//   double selectedRating = 3;
//   String selectedJobType = 'All';
//   bool isDailyWageSelected = false;
//   bool isContractSelected = false;
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
//   void _showFilterDialog() {
//     final language =
//         Provider.of<LanguageProvider>(context, listen: false).selectedLanguage;
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
//             title: Text(translate('Filter Projects', 'प्रस्ताव फ़िल्टर करें')),
//             content: SingleChildScrollView(
//               child: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   // Job Type filter (using fetched job types) with label
//                   Padding(
//                     padding: const EdgeInsets.symmetric(vertical: 8.0),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(translate(
//                             'Select Job Type', 'कृपया नौकरी का प्रकार चुनें')),
//                         DropdownButton<String>(
//                           value: selectedJobType,
//                           isExpanded: true,
//                           items: [
//                             DropdownMenuItem<String>(
//                               value: 'All',
//                               child: Text(translate('All', 'सभी')),
//                             ),
//                             // Create a DropdownMenuItem for each jobType
//                             ..._jobTypes
//                                 .map((job) => DropdownMenuItem<String>(
//                                       value: job.jobname,
//                                       child: Text(translate(job.jobname,
//                                           job.jobname)), // Assuming jobname is in English
//                                     ))
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
//
//                   // Category filter with label
//                   Padding(
//                     padding: const EdgeInsets.symmetric(vertical: 8.0),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(translate(
//                             'Select Payment Type', 'भुगतान प्रकार चुनें')),
//                         DropdownButton<String>(
//                           value: selectedCategory,
//                           isExpanded: true,
//                           items: ['All', 'Project Basis', 'Milestone Basis']
//                               .map((category) => DropdownMenuItem<String>(
//                                     value: category,
//                                     child: Text(translate(category, category)),
//                                   ))
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
//
//                   // Search field
//                   Padding(
//                     padding: const EdgeInsets.all(16.0),
//                     child: TextField(
//                       controller: _labourSearchController,
//                       decoration: InputDecoration(
//                         prefixIcon:
//                             const Icon(Icons.search, color: Colors.green),
//                         hintText: translate('Search by pincode, city, or state',
//                             'पिनकोड, शहर या राज्य द्वारा खोजें'),
//                         fillColor: Colors.white,
//                         filled: true,
//                         border: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(15.0),
//                           borderSide: const BorderSide(color: Colors.green),
//                         ),
//                         focusedBorder: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(15.0),
//                           borderSide:
//                               const BorderSide(color: Colors.green, width: 2),
//                         ),
//                       ),
//                     ),
//                   ),
//
//                   // Price Range Slider
//                   Padding(
//                     padding: const EdgeInsets.symmetric(vertical: 8.0),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                             translate('Select Budget Range', 'बजट सीमा चुनें')),
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
//
//                   // Project Type filter using checkboxes (Daily Wage and Contract)
//                   Padding(
//                     padding: const EdgeInsets.symmetric(vertical: 8.0),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(translate(
//                             'Select Job Type', 'नौकरी का प्रकार चुनें')),
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
//                             Text(translate('Daily Wage', 'दैनिक वेतन')),
//                             const SizedBox(width: 10),
//                             Checkbox(
//                               value: isContractSelected,
//                               onChanged: (bool? value) {
//                                 setStateDialog(() {
//                                   isContractSelected = value!;
//                                 });
//                               },
//                             ),
//                             Text(translate('Contract', 'ठेका')),
//                           ],
//                         ),
//                       ],
//                     ),
//                   ),
//                   const SizedBox(height: 10),
//                   // Rating filter (optional)
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
//                 child: Text(translate('Apply Filters', 'फ़िल्टर लागू करें')),
//               ),
//               TextButton(
//                 onPressed: () {
//                   // Reset filters to default values
//                   setStateDialog(() {
//                     selectedJobType = 'All';
//                     selectedCategory = 'All';
//                     selectedPriceRange = 1000000;
//                     isDailyWageSelected = false;
//                     isContractSelected = false;
//                     _labourSearchController.clear(); // Clear the search field
//                   });
//                 },
//                 child: Text(translate('Reset Filters', 'फ़िल्टर रीसेट करें'),
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
//     // Example API request to fetch filtered projects
//
//     fetchFilteredProjects(filters);
//   }
//
//   Future<void> fetchFilteredProjects(Map<String, dynamic> filters) async {
//     final String apiUrl =
//         '${Constants.AppConstants.apiUrl}labour/searchapplyProjectsApi';
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
//       if (response.statusCode == 200) {
//         final responseBody = json.decode(response.body);
//         if (responseBody['status'] == 1) {
//           setState(() {
//             projects = responseBody['data'];
//             filteredProjects = projects;
//             isLoading = false;
//           });
//         } else {
//           setState(() {
//             projects = [];
//             filteredProjects = [];
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
//                   Text('Failed to fetch projects: ${response.statusCode}')),
//         );
//       }
//     } catch (e) {
//       setState(() {
//         isLoading = false;
//       });
//     }
//   }
//
//   Future<void> fetchProjects() async {
//     final String apiUrl =
//         '${Constants.AppConstants.apiUrl}labour/appliedProjects';
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
//       print(jsonEncode(requestBody));
//       final response = await http.post(
//         Uri.parse(apiUrl),
//         headers: {'Content-Type': 'application/json'},
//         body: jsonEncode(requestBody),
//       );
//       if (response.statusCode == 200) {
//         final responseBody = json.decode(response.body);
//         if (responseBody['status'] == 1) {
//           setState(() {
//             print(responseBody['data']);
//             projects = responseBody['data'];
//             filteredProjects = projects;
//             isLoading = false;
//           });
//         } else {
//           setState(() {
//             projects = [];
//             filteredProjects = [];
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
//                   Text('Failed to fetch projects: ${response.statusCode}')),
//         );
//       }
//     } catch (e) {
//       setState(() {
//         isLoading = false;
//       });
//     }
//   }
//
//   String translate(String enText, String hiText) {
//     final language =
//         Provider.of<LanguageProvider>(context, listen: false).selectedLanguage;
//     return language == 'en' ? enText : hiText;
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
//   Future<void> applyToProject(int projectId) async {
//     final String apiUrl =
//         '${Constants.AppConstants.apiUrl}labour/applyProjectApi';
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
//       'labourId': userId,
//       'projectId': projectId,
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
//         final responseBody = json.decode(response.body);
//         if (responseBody['status'] == 1) {
//           // Success - Refresh the list
//           Fluttertoast.showToast(
//             msg: translate(
//                 'Applied successfully!', 'सफलतापूर्वक लागू किया गया!'),
//             toastLength: Toast.LENGTH_SHORT,
//             gravity: ToastGravity.BOTTOM,
//             backgroundColor: Colors.green.shade700,
//             textColor: Colors.white,
//             fontSize: 16.0,
//           );
//           fetchProjects(); // Reload projects to update applyStatus
//         } else {
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(
//                 content: Text(responseBody['message'] ?? 'Failed to apply')),
//           );
//         }
//       } else {
//         String errorMessage = 'Failed to apply';
//         try {
//           final decoded = json.decode(response.body);
//           if (decoded is Map<String, dynamic>) {
//             if (decoded.containsKey('errors') && decoded['errors'] is Map) {
//               final errorsMap = decoded['errors'] as Map<String, dynamic>;
//               List<String> allErrors = [];
//               errorsMap.forEach((key, value) {
//                 if (value is List) {
//                   allErrors.addAll(value.map((e) => e.toString()));
//                 } else {
//                   allErrors.add(value.toString());
//                 }
//               });
//               if (allErrors.isNotEmpty) errorMessage = allErrors.join(', ');
//             } else if (decoded.containsKey('message')) {
//               errorMessage = decoded['message'].toString();
//             }
//           }
//         } catch (e) {
//           String bodyText = response.body.length > 100 ? response.body.substring(0, 100) + "..." : response.body;
//           errorMessage = 'Failed to apply: $bodyText';
//         }
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text(errorMessage)),
//         );
//       }
//     } catch (e) {}
//   }
//
//   TextEditingController _searchController = TextEditingController();
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
//     return RefreshIndicator(
//       onRefresh: () async {
//         // Assuming loadLanguage, fetchProjects, and fetchJobTypes are async functions.
//         await loadLanguage(); // Load the language (make sure it's an async function)
//         await fetchProjects(); // Fetch projects (make sure it's an async function)
//         await fetchJobTypes(); // Fetch job types (make sure it's an async function)
//
//         setState(() {
//           // If you need to update the UI state, you can do it here after all async tasks are done.
//         });
//       },
//       child: Scaffold(
//         appBar: AppBar(
//           title: Text(
//             translateText("My Projects"),
//             style: TextStyle(color: Colors.white),
//           ),
//           flexibleSpace: Container(
//             decoration: BoxDecoration(
//               gradient: LinearGradient(
//                 colors: [Colors.green, Colors.teal],
//                 begin: Alignment.topLeft,
//                 end: Alignment.bottomRight,
//               ),
//             ),
//           ),
//           iconTheme: IconThemeData(color: Colors.white),
//         ),
//         body: SafeArea(
//           child: Container(
//             width: double.infinity,
//             height: double.infinity,
//             color: Colors.white,
//             // decoration: const BoxDecoration(
//             //   gradient: LinearGradient(
//             //     begin: Alignment.topLeft,
//             //     end: Alignment.bottomRight,
//             //     colors: [
//             //       Color(0xFFA8D5BA), // Light green
//             //       Color(0xFF68A691), // Darker green
//             //     ],
//             //   ),
//             // ),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.end,
//               children: [
//                 IconButton(
//                   icon: Icon(Icons.filter_list),
//                   onPressed: () => _showFilterDialog(),
//                 ),
//                 Expanded(
//                   child: isLoading
//                       ? const Center(child: CircularProgressIndicator())
//                       : filteredProjects.isEmpty
//                           ? Center(
//                               child: Text(
//                                 translateText('No projects found'),
//                                 style: TextStyle(
//                                   fontSize: 18,
//                                   fontWeight: FontWeight.w500,
//                                   color: Colors.brown,
//                                 ),
//                               ),
//                             )
//                           : Scrollbar(
//                               controller: _appliedProjectsScrollController,
//                               thumbVisibility: true,
//                               child: ListView.builder(
//                                 controller: _appliedProjectsScrollController,
//                                 itemCount: filteredProjects.length,
//                                 itemBuilder: (context, index) {
//                                   final project = filteredProjects[index];
//                                   return InkWell(
//                                      onTap: () {
//                                        Navigator.push(
//                                          context,
//                                          MaterialPageRoute(
//                                            builder: (context) =>
//                                                ProjectDetails(
//                                              projectId: project['id'].toString(),
//                                            ),
//                                          ),
//                                        );
//                                      },
//                                      child: Container(
//                                        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
//                                        decoration: BoxDecoration(
//                                          color: Constants.AppColors.card,
//                                          borderRadius: BorderRadius.circular(16),
//                                          border: Border.all(
//                                            color: const Color(0xFFF1F5EE),
//                                            width: 1.0,
//                                          ),
//                                          boxShadow: [
//                                            BoxShadow(
//                                              color: Colors.black.withOpacity(0.04),
//                                              blurRadius: 16,
//                                              offset: const Offset(0, 6),
//                                            ),
//                                          ],
//                                        ),
//                                        child: Padding(
//                                          padding: const EdgeInsets.all(16),
//                                          child: Column(
//                                            crossAxisAlignment: CrossAxisAlignment.start,
//                                            children: [
//                                              // ── TOP ROW: Avatar + Title/Meta + Status badge ──
//                                              Row(
//                                                crossAxisAlignment: CrossAxisAlignment.start,
//                                                children: [
//                                                  // Left: Farmer Avatar
//                                                  Container(
//                                                    width: 50,
//                                                    height: 50,
//                                                    decoration: const BoxDecoration(
//                                                      color: Color(0xFFF1F5EE),
//                                                      shape: BoxShape.circle,
//                                                    ),
//                                                    alignment: Alignment.center,
//                                                    child: const Text(
//                                                      '👨‍🌾',
//                                                      style: TextStyle(fontSize: 26),
//                                                    ),
//                                                  ),
//                                                  const SizedBox(width: 12),
//                                                  // Right: Title + status badge row + Date + Type
//                                                  Expanded(
//                                                    child: Column(
//                                                      crossAxisAlignment: CrossAxisAlignment.start,
//                                                      children: [
//                                                        // ── Title + status badge on same row ──
//                                                        Row(
//                                                          crossAxisAlignment: CrossAxisAlignment.start,
//                                                          children: [
//                                                            Expanded(
//                                                              child: Text(
//                                                                translateText(project['title']?.toString() ?? 'No Title') ?? 'No Title',
//                                                                style: Constants.AppTypography.h2.copyWith(
//                                                                  color: Constants.AppColors.ink,
//                                                                  fontWeight: FontWeight.bold,
//                                                                  fontSize: 16,
//                                                                ),
//                                                                maxLines: 2,
//                                                                overflow: TextOverflow.ellipsis,
//                                                              ),
//                                                            ),
//                                                            if (project['applyStatus'] != null) ...[
//                                                              const SizedBox(width: 8),
//                                                              _buildStatusBadge(project),
//                                                            ],
//                                                          ],
//                                                        ),
//                                                        const SizedBox(height: 6),
//                                                        // ── Date + contract type tag row ──
//                                                        Row(
//                                                          children: [
//                                                            const Icon(
//                                                              Icons.calendar_today_outlined,
//                                                              size: 13,
//                                                              color: Colors.grey,
//                                                            ),
//                                                            const SizedBox(width: 4),
//                                                            Text(
//                                                              _formatDate(project['created_at']?.toString() ?? ''),
//                                                              style: const TextStyle(
//                                                                fontSize: 13,
//                                                                color: Colors.grey,
//                                                              ),
//                                                            ),
//                                                            const SizedBox(width: 10),
//                                                            Container(
//                                                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//                                                              decoration: BoxDecoration(
//                                                                color: Constants.AppColors.brandTint,
//                                                                borderRadius: BorderRadius.circular(6),
//                                                              ),
//                                                              child: Row(
//                                                                mainAxisSize: MainAxisSize.min,
//                                                                children: [
//                                                                  const Text('🌾', style: TextStyle(fontSize: 12)),
//                                                                  const SizedBox(width: 4),
//                                                                  Text(
//                                                                    translateText(project['project_type'] ?? 'N/A') ?? 'N/A',
//                                                                    style: TextStyle(
//                                                                      fontSize: 12,
//                                                                      fontWeight: FontWeight.bold,
//                                                                      color: Constants.AppColors.brandDeep,
//                                                                    ),
//                                                                  ),
//                                                                ],
//                                                              ),
//                                                            ),
//                                                          ],
//                                                        ),
//                                                      ],
//                                                    ),
//                                                  ),
//                                                ],
//                                              ),
//                                              const SizedBox(height: 12),
//                                              const Divider(color: Color(0xFFF1F5EE), height: 1),
//                                              const SizedBox(height: 10),
//                                              // ── Location ──
//                                              Row(
//                                                children: [
//                                                  const Text('📍', style: TextStyle(fontSize: 14)),
//                                                  const SizedBox(width: 6),
//                                                  Expanded(
//                                                    child: Text(
//                                                      "${translateText(project['city'] ?? 'N/A')}, ${translateText(project['state'] ?? 'N/A')}",
//                                                      style: Constants.AppTypography.body.copyWith(
//                                                        color: Constants.AppColors.inkSoft,
//                                                        fontWeight: FontWeight.w600,
//                                                        fontSize: 14,
//                                                      ),
//                                                    ),
//                                                  ),
//                                                ],
//                                              ),
//                                              const SizedBox(height: 12),
//                                              // ── ROW 1: Workers · Amount · Duration ──
//                                              Row(
//                                                children: [
//                                                  _buildChip(
//                                                    icon: Icons.people_outline,
//                                                    label: '${project['qty_labours'] ?? '0'} ${translate('Workers', 'मजदूर')}',
//                                                    bgColor: const Color(0xFFEAF4E8),
//                                                    textColor: const Color(0xFF0E6805),
//                                                    iconColor: const Color(0xFF0E6805),
//                                                  ),
//                                                  const SizedBox(width: 8),
//                                                  _buildChip(
//                                                    icon: Icons.currency_rupee,
//                                                    label: '₹${project['budget'] ?? '0'}',
//                                                    bgColor: const Color(0xFFFFF3E0),
//                                                    textColor: const Color(0xFFE65100),
//                                                    iconColor: const Color(0xFFE65100),
//                                                  ),
//                                                  const SizedBox(width: 8),
//                                                  _buildChip(
//                                                    icon: Icons.access_time,
//                                                    label: translateText(project['days']?.toString() ?? '') ?? '',
//                                                    bgColor: const Color(0xFFE3F2FD),
//                                                    textColor: const Color(0xFF0D47A1),
//                                                    iconColor: const Color(0xFF0D47A1),
//                                                  ),
//                                                ],
//                                              ),
//                                              const SizedBox(height: 10),
//                                              // ── ROW 2: View Details right-aligned ──
//                                              Align(
//                                                alignment: Alignment.centerRight,
//                                                child: _buildViewDetailsButton(project),
//                                              ),
//                                            ],
//                                          ),
//                                        ),
//                                      ),
//                                    );
//                                 },
//                               ),
//                             ),
//                 )
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
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
//
// // ─── Custom Cow Avatar & Painter ──────────────────────────────────────────────
//
// class CowAvatar extends StatelessWidget {
//   final double size;
//   const CowAvatar({Key? key, this.size = 70}) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       width: size,
//       height: size,
//       decoration: const BoxDecoration(
//         color: Color(0xFFEAF4E8),
//         shape: BoxShape.circle,
//       ),
//       child: CustomPaint(
//         size: Size(size, size),
//         painter: CowPainter(),
//       ),
//     );
//   }
// }
//
// class CowPainter extends CustomPainter {
//   @override
//   void paint(Canvas canvas, Size size) {
//     final paint = Paint()
//       ..color = const Color(0xFF0E6805)
//       ..style = PaintingStyle.stroke
//       ..strokeWidth = 1.8
//       ..strokeCap = StrokeCap.round
//       ..strokeJoin = StrokeJoin.round;
//
//     final fillPaint = Paint()
//       ..color = const Color(0xFF0E6805)
//       ..style = PaintingStyle.fill;
//
//     final double w = size.width;
//     final double h = size.height;
//     final double scale = w / 100;
//
//     // Head / Face outline path
//     final facePath = Path()
//       ..moveTo(38 * scale, 32 * scale)
//       ..lineTo(62 * scale, 32 * scale)
//       ..quadraticBezierTo(65 * scale, 45 * scale, 64 * scale, 58 * scale)
//       ..quadraticBezierTo(50 * scale, 60 * scale, 36 * scale, 58 * scale)
//       ..quadraticBezierTo(35 * scale, 45 * scale, 38 * scale, 32 * scale);
//     canvas.drawPath(facePath, paint);
//
//     // Muzzle / Snout cup shape
//     final muzzlePath = Path()
//       ..moveTo(36 * scale, 58 * scale)
//       ..cubicTo(32 * scale, 68 * scale, 40 * scale, 76 * scale, 50 * scale, 76 * scale)
//       ..cubicTo(60 * scale, 76 * scale, 68 * scale, 68 * scale, 64 * scale, 58 * scale)
//       ..quadraticBezierTo(50 * scale, 60 * scale, 36 * scale, 58 * scale);
//     canvas.drawPath(muzzlePath, paint);
//
//     // Left Ear
//     final leftEar = Path()
//       ..moveTo(35 * scale, 38 * scale)
//       ..quadraticBezierTo(15 * scale, 35 * scale, 12 * scale, 45 * scale)
//       ..quadraticBezierTo(18 * scale, 52 * scale, 35 * scale, 46 * scale);
//     canvas.drawPath(leftEar, paint);
//
//     // Right Ear
//     final rightEar = Path()
//       ..moveTo(65 * scale, 38 * scale)
//       ..quadraticBezierTo(85 * scale, 35 * scale, 88 * scale, 45 * scale)
//       ..quadraticBezierTo(82 * scale, 52 * scale, 65 * scale, 46 * scale);
//     canvas.drawPath(rightEar, paint);
//
//     // Left Horn
//     final leftHorn = Path()
//       ..moveTo(39 * scale, 32 * scale)
//       ..quadraticBezierTo(32 * scale, 14 * scale, 22 * scale, 17 * scale)
//       ..quadraticBezierTo(30 * scale, 24 * scale, 43 * scale, 30 * scale);
//     canvas.drawPath(leftHorn, paint);
//
//     // Right Horn
//     final rightHorn = Path()
//       ..moveTo(61 * scale, 32 * scale)
//       ..quadraticBezierTo(68 * scale, 14 * scale, 78 * scale, 17 * scale)
//       ..quadraticBezierTo(70 * scale, 24 * scale, 57 * scale, 30 * scale);
//     canvas.drawPath(rightHorn, paint);
//
//     // Eyes
//     canvas.drawCircle(Offset(44 * scale, 44 * scale), 1.8 * scale, fillPaint);
//     canvas.drawCircle(Offset(56 * scale, 44 * scale), 1.8 * scale, fillPaint);
//
//     // Nostrils
//     canvas.drawCircle(Offset(44 * scale, 66 * scale), 1.5 * scale, fillPaint);
//     canvas.drawCircle(Offset(56 * scale, 66 * scale), 1.5 * scale, fillPaint);
//
//     // "IWM" text below the muzzle
//     final textPainter = TextPainter(
//       text: TextSpan(
//         text: 'IWM',
//         style: TextStyle(
//           color: const Color(0xFF0E6805),
//           fontSize: 8.5 * scale,
//           fontWeight: FontWeight.w900,
//           letterSpacing: 0.8,
//         ),
//       ),
//       textDirection: TextDirection.ltr,
//     );
//     textPainter.layout();
//     textPainter.paint(
//       canvas,
//       Offset((50 * scale) - (textPainter.width / 2), 79 * scale),
//     );
//   }
//
//   @override
//   bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
// }
// import 'dart:convert';

// import 'package:flutter/gestures.dart';
// import 'package:flutter/material.dart';
// import 'package:fluttertoast/fluttertoast.dart';
// import 'package:greencollar/HomeScree.dart';
// import 'package:greencollar/labourhomepage.dart';
// import 'package:greencollar/register.dart';
// import 'package:provider/provider.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:http/http.dart' as http;
// import 'package:flutter_secure_storage/flutter_secure_storage.dart';

// class NearbyProjectPage extends StatefulWidget {
//   @override
//   _NearbyProjectPageState createState() => _NearbyProjectPageState();
// }

// class _NearbyProjectPageState extends State<NearbyProjectPage> {
//   final _secureStorage = const FlutterSecureStorage();
//   List<dynamic> projects = [];
//   List<dynamic> filteredProjects = []; // To store filtered results
//   bool isLoading = true;
//   TextEditingController _searchController = TextEditingController();

//   @override
//   void initState() {
//     super.initState();
//     fetchProjects();
//   }

//   Future<void> fetchProjects() async {
//     final String apiUrl =
//         '${Constants.AppConstants.apiUrl}labour/nearbyProjectApi';

//     // Get user ID from secure storage
//     String? userId = await _secureStorage.read(key: 'id');
//     if (userId == null) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('User ID not found in secure storage')),
//       );
//       return;
//     }

//     final Map<String, dynamic> requestBody = {
//       'id': userId,
//     };

//     print(jsonEncode(requestBody));

//     try {
//       final response = await http.post(
//         Uri.parse(apiUrl),
//         headers: {'Content-Type': 'application/json'},
//         body: jsonEncode(requestBody),
//       );

//       if (response.statusCode == 200) {
//         setState(() {
//           projects = json.decode(response.body)['data'];
//           filteredProjects =
//               projects; // Set the filtered list to all projects initially
//           isLoading = false;
//         });
//       } else {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Failed to fetch projects: ${response.body}')),
//         );
//       }
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('An error occurred: $e')),
//       );
//     }
//   }

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

//         // Perform the filtering check
//         return title.toLowerCase().contains(query.toLowerCase()) ||
//             budget.toLowerCase().contains(query.toLowerCase()) ||
//             city.toLowerCase().contains(query.toLowerCase()) ||
//             state.toLowerCase().contains(query.toLowerCase());
//       }).toList();
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Container(
//         decoration: const BoxDecoration(
//           gradient: LinearGradient(
//             begin: Alignment.topLeft,
//             end: Alignment.bottomRight,
//             colors: [
//               Color(0xFFA8D5BA), // Light green
//               Color(0xFF68A691), // Darker green
//             ],
//           ),
//         ),
//         child: SafeArea(
//           child: Column(
//             children: [
//               // Search Bar
//               Padding(
//                 padding: const EdgeInsets.all(16.0),
//                 child: TextField(
//                   controller: _searchController,
//                   onChanged: (value) {
//                     filterProjects(
//                         value); // Filter projects based on search input
//                   },
//                   decoration: InputDecoration(
//                     prefixIcon: const Icon(Icons.search, color: Colors.green),
//                     hintText: 'Search by title, budget, city, or state',
//                     fillColor: Colors.white,
//                     filled: true,
//                     border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(15.0),
//                       borderSide: const BorderSide(color: Colors.green),
//                     ),
//                     focusedBorder: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(15.0),
//                       borderSide:
//                           const BorderSide(color: Colors.green, width: 2),
//                     ),
//                   ),
//                 ),
//               ),
//               // Project List
//               Expanded(
//                 child: isLoading
//                     ? const Center(child: CircularProgressIndicator())
//                     : filteredProjects.isEmpty
//                         ? const Center(
//                             child: Text(
//                               'No projects found',
//                               style: TextStyle(
//                                 fontSize: 18,
//                                 fontWeight: FontWeight.w500,
//                                 color: Colors.brown,
//                               ),
//                             ),
//                           )
//                         : ListView.builder(
//                             itemCount: filteredProjects.length,
//                             itemBuilder: (context, index) {
//                               final project = filteredProjects[index];
//                               return Card(
//                                 elevation: 5,
//                                 margin: const EdgeInsets.symmetric(
//                                     vertical: 10, horizontal: 15),
//                                 child: Padding(
//                                   padding: const EdgeInsets.all(15.0),
//                                   child: Column(
//                                     crossAxisAlignment:
//                                         CrossAxisAlignment.start,
//                                     children: [
//                                       Text(
//                                         project['title'] ?? 'No Title',
//                                         style: const TextStyle(
//                                           fontSize: 18,
//                                           fontWeight: FontWeight.bold,
//                                           color: Colors.teal,
//                                         ),
//                                       ),
//                                       const SizedBox(height: 5),
//                                       Text(
//                                         'Budget: ${project['budget'] ?? 'N/A'}',
//                                         style: const TextStyle(fontSize: 16),
//                                       ),
//                                       Text(
//                                         'Location: ${project['city']}, ${project['state']}',
//                                         style: const TextStyle(fontSize: 16),
//                                       ),
//                                       const SizedBox(height: 10),
//                                       Text(
//                                         project['description'] ??
//                                             'No Description',
//                                         style: const TextStyle(fontSize: 14),
//                                       ),
//                                     ],
//                                   ),
//                                 ),
//                               );
//                             },
//                           ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:greencollar/speech_helper.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:greencollar/HomeScree.dart';
import 'package:greencollar/l10n/app_localizations.dart';
import 'package:greencollar/labourhomepage.dart';
import 'package:greencollar/main.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:greencollar/constants.dart' as Constants;
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:translator/translator.dart';
import 'package:intl/intl.dart' hide TextDirection;

class NearbyProjectPage extends StatefulWidget {
  @override
  _NearbyProjectPageState createState() => _NearbyProjectPageState();
}

class _NearbyProjectPageState extends State<NearbyProjectPage> {
  final _secureStorage = const FlutterSecureStorage();
  bool isLoading = true;
  List<dynamic> projects = [];
  List<dynamic> filteredProjects = [];
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    loadLanguage();
    fetchProjects();
    fetchJobTypes();
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
      setState(() {
        isLoading = true;
      });

      final Map<String, dynamic> requestBody = {
        'id': userId,
      };
      print(jsonEncode(requestBody));
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );
      if (response.statusCode == 200) {
        final responseBody = json.decode(response.body);
        if (responseBody['status'] == 1) {
          setState(() {
            print(responseBody['data']);
            projects = responseBody['data'];
            filteredProjects = projects;
            isLoading = false;
          });
        } else {
          setState(() {
            projects = [];
            filteredProjects = [];
            isLoading = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(
                    responseBody['message'] ?? 'Failed to fetch projects')),
          );
        }
      } else {
        setState(() {
          isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content:
              Text('Failed to fetch projects: ${response.statusCode}')),
        );
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
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

  String translate(String enText, String hiText) {
    final language =
        Provider.of<LanguageProvider>(context, listen: false).selectedLanguage;
    return language == 'en' ? enText : hiText;
  }

  Future<void> applyToProject(int projectId) async {
    final String apiUrl =
        '${Constants.AppConstants.apiUrl}labour/applyProjectApi';

    // Get user ID from secure storage
    String? userId = await _secureStorage.read(key: 'id');
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User ID not found in secure storage')),
      );
      return;
    }

    final Map<String, dynamic> requestBody = {
      'labourId': userId,
      'projectId': projectId,
    };

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        final responseBody = json.decode(response.body);
        if (responseBody['status'] == 1) {
          Fluttertoast.showToast(
            msg: translate(
                'Applied successfully!', 'सफलतापूर्वक लागू किया गया!'),
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            backgroundColor: Colors.green.shade700,
            textColor: Colors.white,
            fontSize: 16.0,
          );

          fetchProjects(); // Reload projects to update applyStatus
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(responseBody['message'] ?? 'Failed to apply')),
          );
        }
      } else {
        String errorMessage = 'Failed to apply';
        try {
          final decoded = json.decode(response.body);
          if (decoded is Map<String, dynamic>) {
            if (decoded.containsKey('errors') && decoded['errors'] is Map) {
              final errorsMap = decoded['errors'] as Map<String, dynamic>;
              List<String> allErrors = [];
              errorsMap.forEach((key, value) {
                if (value is List) {
                  allErrors.addAll(value.map((e) => e.toString()));
                } else {
                  allErrors.add(value.toString());
                }
              });
              if (allErrors.isNotEmpty) errorMessage = allErrors.join(', ');
            } else if (decoded.containsKey('message')) {
              errorMessage = decoded['message'].toString();
            }
          }
        } catch (e) {
          String bodyText = response.body.length > 100 ? response.body.substring(0, 100) + "..." : response.body;
          errorMessage = 'Failed to apply: $bodyText';
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage)),
        );
      }
    } catch (e) {}
  }

  List<JobType> _jobTypes = [];
  final TextEditingController _projectSearchController =
  TextEditingController();
  final TextEditingController _labourSearchController = TextEditingController();
  String selectedCategory = 'All';
  double selectedPriceRange = 1000000;
  double selectedRating = 3;
  String selectedJobType = 'All';
  bool isDailyWageSelected = false;
  bool isContractSelected = false;
  void _showFilterDialog() {
    final language =
        Provider.of<LanguageProvider>(context, listen: false).selectedLanguage;

    String translate(String enText, String hiText) {
      return language == 'en' ? enText : hiText;
    }

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateDialog) {
          return AlertDialog(
            title: Text(translate('Filter Projects', 'प्रस्ताव फ़िल्टर करें')),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Job Type filter (using fetched job types) with label
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(translate(
                            'Select Job Type', 'कृपया नौकरी का प्रकार चुनें')),
                        DropdownButton<String>(
                          value: selectedJobType,
                          isExpanded: true,
                          items: [
                            DropdownMenuItem<String>(
                              value: 'All',
                              child: Text(translate('All', 'सभी')),
                            ),
                            // Create a DropdownMenuItem for each jobType
                            ..._jobTypes
                                .map((job) => DropdownMenuItem<String>(
                              value: job.jobname,
                              child: Text(translate(job.jobname,
                                  job.jobname)), // Assuming jobname is in English
                            ))
                                .toList(),
                          ],
                          onChanged: (value) {
                            setStateDialog(() {
                              selectedJobType = value!;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Category filter with label
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(translate(
                            'Select Payment Type', 'भुगतान प्रकार चुनें')),
                        DropdownButton<String>(
                          value: selectedCategory,
                          isExpanded: true,
                          items: ['All', 'Project Basis', 'Milestone Basis']
                              .map((category) => DropdownMenuItem<String>(
                            value: category,
                            child: Text(translate(category, category)),
                          ))
                              .toList(),
                          onChanged: (value) {
                            setStateDialog(() {
                              selectedCategory = value!;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Search field
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: TextField(
                      controller: _labourSearchController,
                      decoration: InputDecoration(
                        prefixIcon:
                        const Icon(Icons.search, color: Constants.AppColors.brand),
                        suffixIcon: MicIconButton(controller: _labourSearchController),
                        hintText: translate('Search by pincode, city, or state',
                            'पिनकोड, शहर या राज्य द्वारा खोजें'),
                        hintStyle: Constants.AppTypography.body.copyWith(
                            color: Constants.AppColors.inkSoft),
                        fillColor: Constants.AppColors.card,
                        filled: true,
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 14),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(
                              Constants.AppRadii.md),
                          borderSide: const BorderSide(
                              color: Constants.AppColors.border, width: 1.0),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(
                              Constants.AppRadii.md),
                          borderSide: const BorderSide(
                              color: Constants.AppColors.brand, width: 1.5),
                        ),
                      ),
                    ),
                  ),

                  // Price Range Slider
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                            translate('Select Budget Range', 'बजट सीमा चुनें')),
                        Slider(
                          value: selectedPriceRange,
                          min: 0,
                          max: 1000000,
                          divisions: 100,
                          label: '\$${selectedPriceRange.toStringAsFixed(0)}',
                          onChanged: (value) {
                            setStateDialog(() {
                              selectedPriceRange = value;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Project Type filter using checkboxes (Daily Wage and Contract)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(translate(
                            'Select Job Type', 'नौकरी का प्रकार चुनें')),
                        Row(
                          children: [
                            Checkbox(
                              value: isDailyWageSelected,
                              onChanged: (bool? value) {
                                setStateDialog(() {
                                  isDailyWageSelected = value!;
                                });
                              },
                            ),
                            Text(translate('Daily Wage', 'दैनिक वेतन')),
                            const SizedBox(width: 10),
                            Checkbox(
                              value: isContractSelected,
                              onChanged: (bool? value) {
                                setStateDialog(() {
                                  isContractSelected = value!;
                                });
                              },
                            ),
                            Text(translate('Contract', 'ठेका')),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  // Rating filter (optional)
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
                child: Text(translate('Apply Filters', 'फ़िल्टर लागू करें')),
              ),
              TextButton(
                onPressed: () {
                  // Reset filters to default values
                  setStateDialog(() {
                    selectedJobType = 'All';
                    selectedCategory = 'All';
                    selectedPriceRange = 1000000;
                    isDailyWageSelected = false;
                    isContractSelected = false;
                    _labourSearchController.clear(); // Clear the search field
                  });
                },
                child: Text(translate('Reset Filters', 'फ़िल्टर रीसेट करें'),
                    style: const TextStyle(color: Colors.red)),
              ),
            ],
          );
        },
      ),
    );
  }

  final GoogleTranslator _translator = GoogleTranslator();

  Map<String, Map<String, String>> _cachedTranslations = {};

  Map<String, Map<String, String>> translations =
      Constants.AppConstants.translations;
  String _selectedLanguage = 'en'; // Default language is English

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

  Future<void> _applyFilters() async {
    String? userId = await _secureStorage.read(key: 'id');
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User ID not found in secure storage')),
      );
      return;
    }
    Map<String, dynamic> filters = {
      'id': userId,
      'job_type': selectedJobType,
      'category': selectedCategory,
      'search': _labourSearchController.text,
      'budget': selectedPriceRange.toInt(),
      'dailyWage': isDailyWageSelected,
      'contract': isContractSelected,
    };

    // Example API request to fetch filtered projects

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
      setState(() {
        isLoading = true;
      });

      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(filters),
      );

      if (response.statusCode == 200) {
        final responseBody = json.decode(response.body);
        if (responseBody['status'] == 1) {
          setState(() {
            projects = responseBody['data'];
            filteredProjects = projects;
            isLoading = false;
          });
        } else {
          setState(() {
            projects = [];
            filteredProjects = [];
            isLoading = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(
                    responseBody['message'] ?? 'Failed to fetch projects')),
          );
        }
      } else {
        setState(() {
          isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content:
              Text('Failed to fetch projects: ${response.statusCode}')),
        );
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }

  TextEditingController _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final language =
        Provider.of<LanguageProvider>(context, listen: false).selectedLanguage;

    String translate(String enText, String hiText) {
      return language == 'en' ? enText : hiText;
    }

    return RefreshIndicator(
      onRefresh: () async {
        // Assuming loadLanguage, fetchProjects, and fetchJobTypes are async functions.
        await loadLanguage(); // Load the language (make sure it's an async function)
        await fetchProjects(); // Fetch projects (make sure it's an async function)
        await fetchJobTypes(); // Fetch job types (make sure it's an async function)

        setState(() {
          // If you need to update the UI state, you can do it here after all async tasks are done.
        });
      },
      child: Scaffold(
        backgroundColor: Constants.AppColors.surface,
        body: SafeArea(
          child: Container(
            width: double.infinity,
            height: double.infinity,
            // decoration: const BoxDecoration(
            //   gradient: LinearGradient(
            //     begin: Alignment.topLeft,
            //     end: Alignment.bottomRight,
            //     colors: [
            //       Color(0xFFA8D5BA), // Light green
            //       Color(0xFF68A691), // Darker green
            //     ],
            //   ),
            // ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                IconButton(
                  icon: const Icon(Icons.filter_list, color: Constants.AppColors.brand),
                  onPressed: () => _showFilterDialog(),
                ),
                Expanded(
                  child: isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : filteredProjects.isEmpty
                      ? Center(
                    child: Text(
                      AppLocalizations.of(context)!.noProjectsFound,
                      style: Constants.AppTypography.h3.copyWith(
                        color: Constants.AppColors.inkSoft,
                      ),
                    ),
                  )
                      : Scrollbar(
                    controller: _scrollController,
                    thumbVisibility: true,
                    child: ListView.builder(
                      controller: _scrollController,
                      itemCount: filteredProjects.length,
                      itemBuilder: (context, index) {
                        final project = filteredProjects[index];
                        return InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    ProjectDetailsPage(
                                      projectId: project['id'],
                                    ),
                              ),
                            );
                          },
                          child: Container(
                            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                            decoration: BoxDecoration(
                              color: Constants.AppColors.card,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: const Color(0xFFF1F5EE),
                                width: 1.0,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.04),
                                  blurRadius: 16,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // ── TOP ROW: Avatar + Title/Meta + Status badge ──
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      // Left: Farmer Avatar
                                      Container(
                                        width: 50,
                                        height: 50,
                                        decoration: const BoxDecoration(
                                          color: Color(0xFFF1F5EE),
                                          shape: BoxShape.circle,
                                        ),
                                        alignment: Alignment.center,
                                        child: const Text(
                                          '👨‍🌾',
                                          style: TextStyle(fontSize: 26),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      // Right: Title + status badge row + Date + Type
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            // ── Title + status badge on same row ──
                                            Row(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Expanded(
                                                  child: Text(
                                                    translateText(project['title']?.toString() ?? 'No Title') ?? 'No Title',
                                                    style: Constants.AppTypography.h2.copyWith(
                                                      color: Constants.AppColors.ink,
                                                      fontWeight: FontWeight.bold,
                                                      fontSize: 16,
                                                    ),
                                                    maxLines: 2,
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                ),
                                                if (project['applyStatus'] != null) ...[
                                                  const SizedBox(width: 8),
                                                  _buildStatusBadge(project),
                                                ],
                                              ],
                                            ),
                                            const SizedBox(height: 6),
                                            // ── Date + contract type tag row ──
                                            Row(
                                              children: [
                                                const Icon(
                                                  Icons.calendar_today_outlined,
                                                  size: 13,
                                                  color: Colors.grey,
                                                ),
                                                const SizedBox(width: 4),
                                                Text(
                                                  _formatDate(project['created_at']?.toString() ?? ''),
                                                  style: const TextStyle(
                                                    fontSize: 13,
                                                    color: Colors.grey,
                                                  ),
                                                ),
                                                const SizedBox(width: 10),
                                                Container(
                                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                                  decoration: BoxDecoration(
                                                    color: Constants.AppColors.brandTint,
                                                    borderRadius: BorderRadius.circular(6),
                                                  ),
                                                  child: Row(
                                                    mainAxisSize: MainAxisSize.min,
                                                    children: [
                                                      const Text('🌾', style: TextStyle(fontSize: 12)),
                                                      const SizedBox(width: 4),
                                                      Text(
                                                        translateText(project['project_type'] ?? 'N/A') ?? 'N/A',
                                                        style: TextStyle(
                                                          fontSize: 12,
                                                          fontWeight: FontWeight.bold,
                                                          color: Constants.AppColors.brandDeep,
                                                        ),
                                                      ),
                                                    ],
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
                                  const Divider(color: Color(0xFFF1F5EE), height: 1),
                                  const SizedBox(height: 10),
                                  // ── Location ──
                                  Row(
                                    children: [
                                      const Text('📍', style: TextStyle(fontSize: 14)),
                                      const SizedBox(width: 6),
                                      Expanded(
                                        child: Text(
                                          "${translateText(project['city'] ?? 'N/A')}, ${translateText(project['state'] ?? 'N/A')}",
                                          style: Constants.AppTypography.body.copyWith(
                                            color: Constants.AppColors.inkSoft,
                                            fontWeight: FontWeight.w600,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  // ── ROW 1: Workers · Amount · Duration ──
                                  Wrap(
                                    spacing: 8,
                                    runSpacing: 8,
                                    children: [
                                      _buildChip(
                                        icon: Icons.people_outline,
                                        label: '${project['qty_labours'] ?? '0'} ${translate('Workers', 'मजदूर')}',
                                        bgColor: const Color(0xFFEAF4E8),
                                        textColor: const Color(0xFF0E6805),
                                        iconColor: const Color(0xFF0E6805),
                                      ),
                                      _buildChip(
                                        icon: Icons.currency_rupee,
                                        label: '₹${project['budget'] ?? '0'}',
                                        bgColor: const Color(0xFFFFF3E0),
                                        textColor: const Color(0xFFE65100),
                                        iconColor: const Color(0xFFE65100),
                                      ),
                                      _buildChip(
                                        icon: Icons.access_time,
                                        label: translateText(project['days']?.toString() ?? '') ?? '',
                                        bgColor: const Color(0xFFE3F2FD),
                                        textColor: const Color(0xFF0D47A1),
                                        iconColor: const Color(0xFF0D47A1),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  // ── ROW 2: View Details right-aligned ──
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: _buildViewDetailsButton(project),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildChip({
    required IconData icon,
    required String label,
    required Color bgColor,
    required Color textColor,
    required Color iconColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: iconColor),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(dynamic project) {
    String? appliedStatus = project['applyStatus']?.toString();
    if (appliedStatus == null) return const SizedBox.shrink();

    final language = Provider.of<LanguageProvider>(context, listen: false).selectedLanguage;
    String translate(String enText, String hiText) {
      return language == 'en' ? enText : hiText;
    }

    String text = '';
    Color bgColor = const Color(0xFFEAF4E8);
    Color textColor = const Color(0xFF0E6805);
    Color borderColor = const Color(0xFFC8E6C9);
    IconData statusIcon = Icons.check;

    if (appliedStatus == "0") {
      text = translate('Applied', 'आवेदन किया');
      bgColor = const Color(0xFFEAF4E8);
      textColor = const Color(0xFF0E6805);
      borderColor = const Color(0xFFC8E6C9);
      statusIcon = Icons.check;
    } else if (appliedStatus == "1") {
      text = translate('Assigned', 'आवंटित');
      bgColor = const Color(0xFFEFF6FF);
      textColor = const Color(0xFF1E40AF);
      borderColor = const Color(0xFFBFDBFE);
      statusIcon = Icons.assignment_ind_outlined;
    } else if (appliedStatus == "2") {
      text = translate('Work Started', 'कार्य शुरू हुआ');
      if (project['complete_confirm']?.toString() == "1") {
        text = translate('Completion Requested', 'पूर्णता का अनुरोध');
      } else if (project['cancel_confirm']?.toString() == "1") {
        text = translate('Cancellation Requested', 'रद्दीकरण का अनुरोध');
      }
      bgColor = const Color(0xFFFFF7ED);
      textColor = const Color(0xFFC2410C);
      borderColor = const Color(0xFFFED7AA);
      statusIcon = Icons.hourglass_top_outlined;
    } else if (appliedStatus == "3") {
      text = translate('Work Completed', 'कार्य पूर्ण');
      bgColor = const Color(0xFFF0FDF4);
      textColor = const Color(0xFF15803D);
      borderColor = const Color(0xFFBBF7D0);
      statusIcon = Icons.check_circle_outline;
    } else if (appliedStatus == "4") {
      text = translate('Work Cancelled', 'रद्द किया गया');
      bgColor = const Color(0xFFFEF2F2);
      textColor = const Color(0xFF991B1B);
      borderColor = const Color(0xFFFCA5A5);
      statusIcon = Icons.close;
    } else {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: borderColor, width: 0.8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(statusIcon, size: 11, color: textColor),
          const SizedBox(width: 3),
          Text(
            text,
            style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.bold,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildViewDetailsButton(dynamic project) {
    String? appliedStatus = project['applyStatus']?.toString();
    final language = Provider.of<LanguageProvider>(context, listen: false).selectedLanguage;
    String translate(String enText, String hiText) {
      return language == 'en' ? enText : hiText;
    }

    String label = appliedStatus == null
        ? translate('Apply Now', 'आवेदन करें')
        : translate('View Details', 'विवरण देखें');

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFEAF4E8),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFC8E6C9), width: 0.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF0E6805),
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
          const SizedBox(width: 4),
          const Icon(
            Icons.arrow_forward_ios,
            size: 10,
            color: Color(0xFF0E6805),
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
}

class MilestoneService {
  static const String _baseUrl =
      '${Constants.AppConstants.apiUrl}labour/milestoneComplete'; // Update with your actual API URL

  // Function to send milestone completion request
  static Future<Map<String, dynamic>> completeMilestone({
    required int projectId,
    required String milestoneSno,
    required int labourId,
  }) async {
    final Uri url = Uri.parse(_baseUrl);

    try {
      // Prepare the request payload
      final Map<String, dynamic> payload = {
        "projectid": projectId,
        "milestonesno": milestoneSno,
        "id": labourId,
      };
      print(jsonEncode(payload));
      // Send the POST request
      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
        },
        body: jsonEncode(payload),
      );

      // Check the response status
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseBody = json.decode(response.body);
        return responseBody;
      } else {
        // Handle non-200 status codes
        return {
          "status": "0",
          "message":
          "Failed to complete milestone. Status Code: ${response.statusCode}"
        };
      }
    } catch (e) {
      // Handle exceptions
      return {"status": "0", "message": "An error occurred: $e"};
    }
  }
}

class ProjectDetailsPage extends StatefulWidget {
  final int projectId;
  final _secureStorage = const FlutterSecureStorage();

  const ProjectDetailsPage({Key? key, required this.projectId})
      : super(key: key);

  @override
  _ProjectDetailsPageState createState() => _ProjectDetailsPageState();
}

class _ProjectDetailsPageState extends State<ProjectDetailsPage> {
  late Future<Map<String, dynamic>> projectDetails;
  late Map<String, dynamic> project;
  bool isLoading = true;
  late TextEditingController _commentController;
  late TextEditingController _payController;
  String? selectedEstimateDays;
  final ScrollController _milestoneScrollController = ScrollController();

  // Valid values for the Estimated Days dropdown
  static const List<String> _validEstimateDays = [
    '1 day',
    '2 days',
    '3-7 days',
    '8-15 days',
    '15-1 month',
    '1-3 months',
    '3-6 months',
    '6 months-1 year',
    '>1 year',
  ];

  String? _normalizeEstimateDays(dynamic val) {
    if (val == null) return null;
    String sVal = val.toString().trim();
    if (sVal == '1' || sVal == '1 day') return '1 day';
    if (sVal == '2' || sVal == '2 days') return '2 days';
    if (sVal == '3-7 days') return '3-7 days';
    if (sVal == '8-15 days') return '8-15 days';
    if (sVal == '15-1 month') return '15-1 month';
    if (sVal == '1-3 months') return '1-3 months';
    if (sVal == '3-6 months') return '3-6 months';
    if (sVal == '6 months-1 year') return '6 months-1 year';
    if (sVal == '>1 year') return '>1 year';

    int? daysInt = int.tryParse(sVal);
    if (daysInt != null) {
      if (daysInt == 1) return '1 day';
      if (daysInt == 2) return '2 days';
      if (daysInt >= 3 && daysInt <= 7) return '3-7 days';
      if (daysInt >= 8 && daysInt <= 15) return '8-15 days';
      if (daysInt > 15 && daysInt <= 30) return '15-1 month';
      if (daysInt > 30 && daysInt <= 90) return '1-3 months';
      if (daysInt > 90 && daysInt <= 180) return '3-6 months';
      if (daysInt > 180 && daysInt <= 365) return '6 months-1 year';
      if (daysInt > 365) return '>1 year';
    }
    return null;
  }

  @override
  void initState() {
    super.initState();
    loadLanguage();
    _commentController = TextEditingController();
    _payController = TextEditingController();

    projectDetails = fetchProjectDetails(context, widget.projectId);

    projectDetails.then((data) {
      setState(() {
        project = data;
        isLoading = false;
      });
    });
  }

  @override
  void dispose() {
    _commentController.dispose();
    _milestoneScrollController.dispose();
    super.dispose();
  }

  // ------- Helper: Build stat chip for total/completed projects -------
  Widget _buildStatChip({
    required IconData icon,
    required String label,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5EE),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Constants.AppColors.inkSoft),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: Constants.AppColors.ink,
            ),
          ),
        ],
      ),
    );
  }

  // ---------- Existing methods (unchanged) ----------
  Future<void> confirmcancel(BuildContext context, int projectId) async {
    final String apiUrl =
        '${Constants.AppConstants.apiUrl}labour/confirmcancel';

    String? userId = await widget._secureStorage.read(key: 'id');
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(translate('User ID not found in secure storage',
                'सुरक्षित भंडारण में उपयोगकर्ता आईडी नहीं मिली'))),
      );
      return;
    }

    final Map<String, dynamic> requestBody = {
      'projectid': projectId,
      'labourid': userId,
    };

    try {
      print(jsonEncode(requestBody));
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        final responseBody = json.decode(response.body);
        if (responseBody['status'] == '1') {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(translate('Job Cancelled successfully!',
                    'काम सफलतापूर्वक रद्द कर दिया गया!'))),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(responseBody['message'] ??
                  translate('Failed to cancel work', 'काम रद्द करने में विफल')),
            ),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  translate('Failed to cancel work', 'काम रद्द करने में विफल') +
                      ': ${response.body}')),
        );
      }
    } catch (e) {
      // Handle exceptions here if needed
    }
  }

  void handleMilestoneCompletion(BuildContext context, String milestone) async {
    String? userId = await widget._secureStorage.read(key: 'id');
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(translate('User ID not found in secure storage',
              'सुरक्षित भंडारण में उपयोगकर्ता आईडी नहीं मिली')),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    int projectId = widget.projectId;
    String milestoneSno = milestone;
    int labourId = int.parse(userId);

    final result = await MilestoneService.completeMilestone(
      projectId: projectId,
      milestoneSno: milestoneSno,
      labourId: labourId,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(result['message'] ??
            translate('Unknown response', 'अज्ञात प्रतिक्रिया')),
        backgroundColor: result['status'] == "1" ? Colors.green : Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Future<void> startWork(
      BuildContext context, int projectId, Map<String, dynamic> project) async {
    final String apiUrl = '${Constants.AppConstants.apiUrl}labour/'
        '${project['payment_type'] == "1" ? "milestoneprojectworkstart" : "projectworkstart"}';
    print(apiUrl);

    String? userId = await widget._secureStorage.read(key: 'id');
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(translate('User ID not found in secure storage',
                'सुरक्षित भंडारण में उपयोगकर्ता आईडी नहीं मिली'))),
      );
      return;
    }

    final Map<String, dynamic> requestBody = {
      'projectid': projectId,
      'labourid': userId,
    };

    try {
      print('Request Body: ${jsonEncode(requestBody)}');

      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        final responseBody = json.decode(response.body);
        Fluttertoast.showToast(
          msg: translate('You have successfully started this job.',
              'आपने इस नौकरी को सफलतापूर्वक शुरू किया है।'),
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Constants.AppColors.brand,
          textColor: Constants.AppColors.card,
          fontSize: 16.0,
        );

        bool isSuccess = responseBody['status'] == '1';

        if (isSuccess) {
          await Future.delayed(const Duration(seconds: 1));
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => Labourhomepage()),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  translate('Failed to start work', 'काम शुरू करने में विफल'))),
        );
      }
    } catch (e) {
      // Handle network or unexpected errors
    }
  }

  String translate(String enText, String hiText) {
    final language =
        Provider.of<LanguageProvider>(context, listen: false).selectedLanguage;
    return language == 'en' ? enText : hiText;
  }

  List<Map<String, dynamic>> milestones = [];

  Future<Map<String, dynamic>> fetchProjectDetails(
      BuildContext context, int projectId) async {
    final String apiUrl =
        '${Constants.AppConstants.apiUrl}labour/projectDetailByLabour';

    try {
      String? userId = await widget._secureStorage.read(key: 'id');
      if (userId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User ID not found in secure storage')),
        );
        throw Exception('User ID not found.');
      }

      final Map<String, dynamic> requestBody = {
        'id': userId,
        'project_id': projectId,
      };

      print(jsonEncode(requestBody));

      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        final responseBody = json.decode(response.body);

        if (responseBody['status'] == 1 && responseBody['data'] is List) {
          final data = responseBody['data'];

          if (data.isNotEmpty) {
            final project = data[0];

            _commentController.text =
                project['comment'] ?? '';
            selectedEstimateDays = _normalizeEstimateDays(project['wpay'] ?? project['days']);
            _payController.text = project['praposal_amount'] ?? '';
            setState(() {
              if (project['applyStatus'] != null) {
                print(project['pmilestones']);
                milestones = project['pmilestones'] is String
                    ? List<Map<String, dynamic>>.from(
                    jsonDecode(project['pmilestones']))
                    : [];
              } else {
                milestones = project['milestones'] is String
                    ? List<Map<String, dynamic>>.from(
                    jsonDecode(project['milestones']))
                    : [];
              }
              _commentController.text = project['comment'] ?? '';
              selectedEstimateDays = _normalizeEstimateDays(project['wpay'] ?? project['days']);
              print(selectedEstimateDays);
              _payController.text = project['praposal_amount'] ?? '';
            });
            return project;
          } else {
            throw Exception('No project data available.');
          }
        } else {
          throw Exception(responseBody['message'] ?? 'Failed to fetch details');
        }
      } else {
        throw Exception('Failed to fetch details: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('An error occurred: $e');
    }
  }

  bool _isButtonDisabled = false;

  Future<void> applyToProject(BuildContext context, int projectId) async {
    final String apiUrl = '${Constants.AppConstants.apiUrl}labour/projectApply';

    for (var milestone in milestones) {
      if (milestone['proposalamount'] == null ||
          milestone['proposalamount'] <= 0) {
        Fluttertoast.showToast(
          msg: translate('Please fill in the amount for all milestones.',
              'कृपया सभी माइलस्टोन के लिए राशि भरें'),
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.red.shade700,
          textColor: Colors.white,
          fontSize: 16.0,
        );
        return;
      }

      if (milestone['duration'] == null || milestone['duration'] <= 0) {
        Fluttertoast.showToast(
          msg: translate('Please fill in the duration for all milestones.',
              'कृपया सभी माइलस्टोन के लिए अवधि भरें'),
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.red.shade700,
          textColor: Colors.white,
          fontSize: 16.0,
        );
        return;
      }
    }

    String? userId = await widget._secureStorage.read(key: 'id');
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(translate('User ID not found in secure storage',
              'यूज़र आईडी सुरक्षित भंडारण में नहीं मिली')),
        ),
      );
      return;
    }

    final Map<String, dynamic> requestBody = {
      'labourid': userId,
      'projectid': projectId,
      'comment': _commentController.text,
      'pamount': _payController.text,
      'wday': selectedEstimateDays,
      'milestones': milestones,
    };

    setState(() {
      _isButtonDisabled = true;
    });

    try {
      print(jsonEncode(requestBody));
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );
      print(response.statusCode);

      if (response.statusCode == 200) {
        final responseBody = json.decode(response.body);
        if (responseBody['status'] == "1") {
          Fluttertoast.showToast(
            msg: translate(
                'Applied successfully!', 'सफलतापूर्वक लागू किया गया!'),
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            backgroundColor: Constants.AppColors.brand,
            textColor: Constants.AppColors.card,
            fontSize: 16.0,
          );

          Future.delayed(Duration(seconds: 1), () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => Labourhomepage(),
              ),
            );
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(translate(
                  responseBody['message'] ?? 'Failed to apply',
                  responseBody['message'] ?? 'आवेदन विफल हुआ')),
            ),
          );
        }
      } else {
        String errorMessage = 'Failed to apply';
        String errorMessageHi = 'आवेदन विफल हुआ';
        try {
          final decoded = json.decode(response.body);
          if (decoded is Map<String, dynamic>) {
            if (decoded.containsKey('errors') && decoded['errors'] is Map) {
              final errorsMap = decoded['errors'] as Map<String, dynamic>;
              List<String> allErrors = [];
              errorsMap.forEach((key, value) {
                if (value is List) {
                  allErrors.addAll(value.map((e) => e.toString()));
                } else {
                  allErrors.add(value.toString());
                }
              });
              if (allErrors.isNotEmpty) {
                errorMessage = allErrors.join(', ');
                errorMessageHi = errorMessage;
              }
            } else if (decoded.containsKey('message')) {
              errorMessage = decoded['message'].toString();
              errorMessageHi = errorMessage;
            }
          }
        } catch (e) {
          String bodyText = response.body.length > 100 ? response.body.substring(0, 100) + "..." : response.body;
          errorMessage = 'Failed to apply: $bodyText';
          errorMessageHi = 'आवेदन विफल हुआ: $bodyText';
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(translate(errorMessage, errorMessageHi)),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
          Text(translate('An error occurred: $e', 'एक त्रुटि हुई: $e')),
        ),
      );
    } finally {
      setState(() {
        _isButtonDisabled = false;
      });
    }
  }

  Future<void> completework(BuildContext context, int projectId) async {
    final String apiUrl =
        '${Constants.AppConstants.apiUrl}labour/projectcomplete';

    String? userId = await widget._secureStorage.read(key: 'id');
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(translate('User ID not found in secure storage',
                'यूज़र आईडी सुरक्षित भंडारण में नहीं मिली'))),
      );
      return;
    }

    TextEditingController _dialogRemarkController = TextEditingController();
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(translate('Enter remark', 'टिप्पणी दर्ज करें')),
          content: TextField(
            controller: _dialogRemarkController,
            decoration:
            InputDecoration(
              hintText: translate('Remark', 'टिप्पणी'),
              suffixIcon: MicIconButton(controller: _dialogRemarkController),
            ),
            maxLines: 3,
          ),
          actions: <Widget>[
            TextButton(
              child: Text(translate('Cancel', 'रद्द करें')),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text(translate('Submit', 'सबमिट करें')),
              onPressed: () async {
                String remark = _dialogRemarkController.text.trim();
                if (remark.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(translate('Remark cannot be empty',
                          'टिप्पणी खाली नहीं हो सकती')),
                    ),
                  );
                  return;
                }
                Navigator.of(context).pop();
                await _sendCompleteRequest(context, projectId, userId, remark);
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _sendCompleteRequest(
      BuildContext context, int projectId, String userId, String remark) async {
    final Map<String, dynamic> requestBody = {
      'projectid': projectId,
      'labourid': userId,
      'completeremark': remark,
    };

    try {
      print(jsonEncode(requestBody));
      final response = await http.post(
        Uri.parse('${Constants.AppConstants.apiUrl}labour/projectcomplete'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        final responseBody = json.decode(response.body);
        if (responseBody['status'] == '1') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => Labourhomepage(),
            ),
          );
          Fluttertoast.showToast(
            msg: translate('Job Complete Request Sent Successfully!',
                'काम पूरा करने का अनुरोध सफलतापूर्वक भेजा गया!'),
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            backgroundColor: Constants.AppColors.brand,
            textColor: Constants.AppColors.card,
            fontSize: 16.0,
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(responseBody['message'] ??
                  translate('Failed to Complete Request Sent',
                      'काम पूरा करने का अनुरोध भेजने में विफल')),
            ),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(translate(
                  'Failed to start work:', 'काम शुरू करने में विफल:'))),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(translate('An error occurred.', 'एक त्रुटि हुई।'))),
      );
    }
  }

  final FlutterSecureStorage _secureStorage = FlutterSecureStorage();
  final GoogleTranslator _translator = GoogleTranslator();
  Map<String, Map<String, String>> _cachedTranslations = {};

  Map<String, Map<String, String>> translations =
      Constants.AppConstants.translations;
  String _selectedLanguage = 'en';

  Future<void> downloadTranslations() async {
    try {
      var status = await Permission.storage.status;
      if (!status.isGranted) {
        await Permission.storage.request();
      }

      final destinationPath = '/storage/emulated/0/Download/Invoice';
      final destinationDir = Directory(destinationPath);
      await destinationDir.create(recursive: true);

      final folderPath = '${destinationDir.path}/Appointment_Details';
      final folder = Directory(folderPath);
      if (!await folder.exists()) {
        await folder.create(recursive: true);
      }

      final filePath = '$folderPath/translations.txt';
      final file = File(filePath);

      StringBuffer buffer = StringBuffer();
      translations.forEach((key, value) {
        buffer.writeln("$key: ${value.toString()}");
      });

      await file.writeAsString(buffer.toString());
      print("✅ Translations saved at: ${file.absolute.path}");
    } catch (e) {
      print("❌ Error saving translations: $e");
    }
  }

  Future<void> loadLanguage() async {
    String? language = await _secureStorage.read(key: 'selectedLanguage');
    _selectedLanguage = language ?? 'en';
    print(language);
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

            if (!translations.containsKey(text)) {
              translations[text] = {
                "en": text,
                "hi": text
              };
            }
            translations[text]![lang] = translation;
          }

          _cachedTranslations = translations;

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

      for (var key in translations.keys) {
        if (!translations[key]!.containsKey("hi")) {
          await _fetchTranslation(key, "hi");
        }
        if (!translations[key]!.containsKey("en")) {
          await _fetchTranslation(key, "en");
        }
      }

      _cachedTranslations.putIfAbsent(text, () => {})[targetLang] =
          translation.text;
      setState(() {});
    } catch (e) {
      print("Translation error: $e");
    }
  }

  double _rating = 1.0;
  TextEditingController _remarksController = TextEditingController();
  Future<void> _submitReview() async {
    const String _baseUrl =
        '${Constants.AppConstants.apiUrl}farmer/reviewForFarmer';
    print(_baseUrl);
    print(project);
    final Map<String, dynamic> requestBody = {
      'projectid': project['id'].toString(),
      'labourid': project['labourId'].toString(),
      'rating': _rating,
      'review': _remarksController.text,
    };

    print(
      jsonEncode(requestBody),
    );

    try {
      final response = await http.post(
        Uri.parse(_baseUrl),
        body: jsonEncode(requestBody),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData['status'] == "1") {
          Fluttertoast.showToast(
            msg: translate('Review submitted successfully!',
                'समीक्षा सफलतापूर्वक प्रस्तुत की गई!'),
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            backgroundColor: Constants.AppColors.brand,
            textColor: Constants.AppColors.card,
            fontSize: 16.0,
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(
                  translate('Failed to submit review.',
                      'समीक्षा प्रस्तुत करने में विफल।'),
                )),
          );
        }
      } else {
        // Error with response
      }
    } catch (e) {
      // Network or other failure
    }
  }

  void _showReviewDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, setState) {
            return AlertDialog(
              title:
              Text(translate('Review', 'समीक्षा')),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) {
                      return IconButton(
                        icon: Icon(
                          index < _rating ? Icons.star : Icons.star_border,
                          color: const Color.fromARGB(255, 66, 60, 4),
                        ),
                        onPressed: () {
                          setState(() {
                            _rating = index + 1.0;
                          });
                        },
                      );
                    }),
                  ),
                  TextField(
                    controller: _remarksController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: translate('Write a Review For Worker',
                          'मजदूर के लिए समीक्षा लिखें'),
                      border: OutlineInputBorder(),
                      suffixIcon: MicIconButton(controller: _remarksController),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text(
                      translate('Cancel', 'रद्द करें')),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    _submitReview();
                  },
                  child: Text(
                      translate('Submit', 'सबमिट करें')),
                ),
              ],
            );
          },
        );
      },
    );
  }

  final _formKey = GlobalKey<FormState>();

  Widget _buildActionButton(Map<String, dynamic> project) {
    final applyStatus = project['applyStatus']?.toString();
    final cancelConfirm = project['cancel_confirm']?.toString();
    final completeConfirm = project['complete_confirm']?.toString();

    if (applyStatus == "1") {
      return ElevatedButton(
        onPressed: () => startWork(context, project['id'], project),
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          backgroundColor: Constants.AppColors.brand,
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        child: Text(
          AppLocalizations.of(context)!.workStart,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      );
    } else if (applyStatus == "0") {
      return ElevatedButton(
        onPressed: null,
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          backgroundColor: Colors.grey[400],
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        child: Text(
          AppLocalizations.of(context)!.applied,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      );
    } else if (applyStatus == "2") {
      if (cancelConfirm == "1") {
        return ElevatedButton(
          onPressed: () => confirmcancel(context, project['id']),
          style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            backgroundColor: const Color(0xFFDC2626),
            foregroundColor: Colors.white,
            elevation: 0,
          ),
          child: Text(
            translateText('Confirm Cancelled'),
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        );
      } else if (completeConfirm == "1") {
        return ElevatedButton(
          onPressed: null,
          style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            backgroundColor: Colors.grey[400],
            foregroundColor: Colors.white,
            elevation: 0,
          ),
          child: Text(
            translateText('Completion Requested'),
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        );
      } else {
        return ElevatedButton(
          onPressed: () => completework(context, project['id']),
          style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            backgroundColor: Constants.AppColors.brand,
            foregroundColor: Colors.white,
            elevation: 0,
          ),
          child: Text(
            translateText('Complete Work'),
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        );
      }
    } else if (applyStatus == "3") {
      final language = Provider.of<LanguageProvider>(context, listen: false).selectedLanguage;
      String translate(String enText, String hiText) {
        return language == 'en' ? enText : hiText;
      }
      return Row(
        children: [
          Expanded(
            child: SizedBox(
              height: 52,
              child: OutlinedButton(
                onPressed: _showReviewDialog,
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: Constants.AppColors.brand, width: 1.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  translate('Review', "समीक्षा"),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Constants.AppColors.brand,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: SizedBox(
              height: 52,
              child: ElevatedButton(
                onPressed: null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[400],
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  translateText('Completed'),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      );
    } else if (applyStatus == "4") {
      return ElevatedButton(
        onPressed: null,
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          backgroundColor: Colors.grey[400],
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        child: Text(
          translateText('Cancelled'),
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      );
    } else if (applyStatus == null) {
      return ElevatedButton(
        onPressed: _isButtonDisabled
            ? null
            : () async {
          if (_formKey.currentState?.validate() ?? false) {
            await applyToProject(context, project['id']);
          } else {
            print('Form is invalid');
          }
        },
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          backgroundColor: Constants.AppColors.brand,
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        child: Text(
          translateText('Apply Now'),
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      );
    } else {
      return ElevatedButton(
        onPressed: null,
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          backgroundColor: Colors.grey[400],
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        child: Text(
          translateText('Cancelled'),
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      );
    }
  }

  Widget _infoCell({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Expanded(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: const BoxDecoration(
              color: Color(0xFFEAF4E8),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: const Color(0xFF0E6805),
              size: 16,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey[500],
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF152018),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMilestoneAction({
    required String label,
    required Color color,
    VoidCallback? onPressed,
  }) {
    return SizedBox(
      height: 32,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        onPressed: onPressed,
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  String _getEstimateDaysHindi(String val) {
    switch (val) {
      case '1 day': return '1 दिन';
      case '2 days': return '2 दिन';
      case '3-7 days': return '3-7 दिन';
      case '8-15 days': return '8-15 दिन';
      case '15-1 month': return '15-1 महीना';
      case '1-3 months': return '1-3 महीने';
      case '3-6 months': return '3-6 महीने';
      case '6 months-1 year': return '6 महीने-1 साल';
      case '>1 year': return '> 1 साल';
      default: return val;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Function to show the add milestone dialog
    void showAddMilestoneDialog() {
      final descriptionController = TextEditingController();
      final amountController = TextEditingController();

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Add Milestone'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: descriptionController,
                  decoration: InputDecoration(
                    labelText: 'Milestone Description',
                    hintText: 'Enter milestone description',
                  ),
                ),
                SizedBox(height: 10),
                TextField(
                  controller: amountController,
                  decoration: InputDecoration(
                    labelText: 'Amount',
                    hintText: 'Enter milestone amount',
                  ),
                  keyboardType: TextInputType.number,
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  if (descriptionController.text.isNotEmpty &&
                      amountController.text.isNotEmpty) {
                    setState(() {
                      milestones.add({
                        'description': descriptionController.text,
                        'amount': double.tryParse(amountController.text) ?? 0.0,
                      });
                    });
                    Navigator.pop(context);
                  }
                },
                child: Text('Add'),
              ),
            ],
          );
        },
      );
    }

    // Function to show the edit milestone dialog
    void showEditMilestoneDialog(int index, BuildContext context) {
      final descriptionController =
      TextEditingController(text: milestones[index]['description']);
      String sno = milestones[index]['sno'].toString();
      final amountController =
      TextEditingController(text: milestones[index]['amount'].toString());
      final durationController = TextEditingController(
        text: milestones[index]['duration'] != null
            ? milestones[index]['duration'].toString()
            : '',
      );
      final praposalController = TextEditingController(
        text: milestones[index]['proposalamount'] != null
            ? milestones[index]['proposalamount'].toString()
            : '',
      );

      final language = Provider.of<LanguageProvider>(context, listen: false)
          .selectedLanguage;

      String translate(String enText, String hiText) {
        return language == 'en' ? enText : hiText;
      }

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(translate('Edit Milestone', 'माइलस्टोन संपादित करें')),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: descriptionController,
                  decoration: InputDecoration(
                    labelText:
                    translate('Milestone Description', 'माइलस्टोन विवरण'),
                    hintText: translate('Edit milestone description',
                        'माइलस्टोन विवरण संपादित करें'),
                  ),
                ),
                SizedBox(height: 10),
                TextField(
                  controller: amountController,
                  decoration: InputDecoration(
                    labelText: translate('Amount', 'राशि'),
                    hintText: translate(
                        'Edit milestone amount', 'माइलस्टोन राशि संपादित करें'),
                  ),
                  keyboardType: TextInputType.number,
                ),
                SizedBox(height: 10),
                TextField(
                  controller: durationController,
                  decoration: InputDecoration(
                    labelText: translate('Duration', 'अवधि'),
                    hintText: translate('Enter Duration', 'अवधि दर्ज करें'),
                  ),
                  keyboardType: TextInputType.number,
                ),
                SizedBox(height: 10),
                TextField(
                  controller: praposalController,
                  decoration: InputDecoration(
                    labelText: translate('Proposal Amount', 'प्रस्ताव राशि'),
                    hintText: translate(
                        'Enter Proposal amount', 'प्रस्ताव राशि दर्ज करें'),
                  ),
                  keyboardType: TextInputType.number,
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text(translate('Cancel', 'रद्द करें')),
              ),
              TextButton(
                onPressed: () {
                  if (descriptionController.text.isNotEmpty &&
                      amountController.text.isNotEmpty) {
                    setState(() {
                      milestones[index] = {
                        'sno': sno,
                        'description': descriptionController.text,
                        'amount': double.tryParse(amountController.text) ?? 0.0,
                        'proposalamount':
                        double.tryParse(praposalController.text) ?? 0.0,
                        'duration': int.tryParse(durationController.text) ?? 0,
                        'startdate': '',
                        'completedate': '',
                        'status': '0',
                        'paymentstatus': '0',
                      };

                      double totalProposalAmount =
                      milestones.fold(0.0, (sum, milestone) {
                        return sum + (milestone['proposalamount'] ?? 0.0);
                      });
                      _payController.text = totalProposalAmount.toString();
                    });
                    Navigator.pop(context);
                  }
                },
                child: Text(translate('Save', 'सहेजें')),
              ),
            ],
          );
        },
      );
    }

    final language =
        Provider.of<LanguageProvider>(context, listen: false).selectedLanguage;

    String translate(String enText, String hiText) {
      return language == 'en' ? enText : hiText;
    }

    if (isLoading) {
      return Scaffold(
        backgroundColor: const Color(0xFFFAFBF7),
        appBar: AppBar(
          backgroundColor: Constants.AppColors.brand,
          foregroundColor: Colors.white,
          elevation: 0,
          title: Text(
            AppLocalizations.of(context)!.projectDetails,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    // Resolve details
    final String title = translateText(project['title']?.toString() ?? 'No Title');
    final String budget = project['budget'] != null ? '₹${project['budget']}' : 'N/A';
    final String workers = project['qty_labours']?.toString() ?? 'N/A';
    final String duration = project['days']?.toString() ?? 'N/A';
    final String city = project['city']?.toString() ?? 'N/A';
    final String state = project['state']?.toString() ?? 'N/A';
    final String address = project['address']?.toString() ?? 'N/A';
    final String projectType = translateText(project['project_type']?.toString() ?? 'N/A');
    final String description = project['description']?.toString() ?? 'N/A';
    final String paymentType = project['payment_type'] == "1"
        ? translate('Milestone Basis', 'माइलस्टोन आधार')
        : translate('Project Basis', 'प्रोजेक्ट आधार');
    final String skillsText = translateText(project['required_skills']?.toString() ?? 'N/A');

    return Scaffold(
      backgroundColor: const Color(0xFFFAFBF7),
      appBar: AppBar(
        backgroundColor: Constants.AppColors.brand,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(
          AppLocalizations.of(context)!.projectDetails,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Hero card ─────────────────────────────────────────────
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const CowAvatar(size: 70),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      title,
                                      style: const TextStyle(
                                        fontSize: 17,
                                        fontWeight: FontWeight.w700,
                                        color: Color(0xFF1B2B1B),
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    // Farmer name + time elapsed
                                    Row(
                                      children: [
                                        Icon(Icons.person_outline,
                                            size: 14, color: Colors.grey[500]),
                                        const SizedBox(width: 4),
                                        Text(
                                          translate('Posted by ', 'द्वारा पोस्ट किया गया '),
                                          style: TextStyle(
                                              fontSize: 11,
                                              color: Colors.grey[500]),
                                        ),
                                        Expanded(
                                          child: Text(
                                            translateText(project['farmer_name']?.toString() ?? 'N/A'),
                                            style: TextStyle(
                                              fontSize: 11,
                                              color: Constants.AppColors.brand,
                                              fontWeight: FontWeight.bold,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        const SizedBox(width: 4),
                                        Icon(Icons.calendar_today_outlined,
                                            size: 11, color: Colors.grey[400]),
                                        const SizedBox(width: 3),
                                        Text(
                                          translateText(project['time_elapsed']?.toString() ?? 'N/A'),
                                          style: TextStyle(
                                              fontSize: 11,
                                              color: Colors.grey[500]),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    // ⭐ Farmer rating & review count
                                    Row(
                                      children: [
                                        Row(
                                          children: List.generate(5, (i) {
                                            final rating = (project['farmer_rating'] ?? 0).toDouble();
                                            return Icon(
                                              i < rating.floor()
                                                  ? Icons.star
                                                  : (i < rating.ceil() && rating % 1 != 0
                                                  ? Icons.star_half
                                                  : Icons.star_border),
                                              size: 14,
                                              color: Colors.amber,
                                            );
                                          }),
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          '(${project['review_count'] ?? 0} ${translate('reviews', 'समीक्षाएँ')})',
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: Colors.grey[600],
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    // 📊 Total & Completed projects
                                    Row(
                                      children: [
                                        _buildStatChip(
                                          icon: Icons.work_outline,
                                          label: '${translate('Total', 'कुल')}: ${project['total_projects'] ?? 0}',
                                        ),
                                        const SizedBox(width: 8),
                                        _buildStatChip(
                                          icon: Icons.check_circle_outline,
                                          label: '${translate('Completed', 'पूर्ण')}: ${project['completed_projects'] ?? 0}',
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 4),
                              // Status badge
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFEAF4E8),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                      color: const Color(0xFFA5D6A7), width: 1),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.check,
                                        size: 11,
                                        color: Constants.AppColors.brand),
                                    const SizedBox(width: 2),
                                    Text(
                                      translateText(project['status']?.toString() ?? 'Active'),
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        color: Constants.AppColors.brand,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          // 3x2 stats grid
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _infoCell(
                                icon: Icons.currency_rupee,
                                label: translate('Budget', 'बजट'),
                                value: budget,
                              ),
                              _infoCell(
                                icon: Icons.group_outlined,
                                label: translate('Workers Required', 'आवश्यक मजदूर'),
                                value: workers,
                              ),
                              _infoCell(
                                icon: Icons.access_time_outlined,
                                label: translate('Duration', 'अवधि'),
                                value: duration,
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _infoCell(
                                icon: Icons.location_on_outlined,
                                label: translate('Location', 'स्थान'),
                                value: '${translateText(city)}, ${translateText(state)}',
                              ),
                              _infoCell(
                                icon: Icons.business_outlined,
                                label: translate('Address', 'पता'),
                                value: address,
                              ),
                              _infoCell(
                                icon: Icons.description_outlined,
                                label: translate('Project Type', 'प्रोजेक्ट प्रकार'),
                                value: projectType,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Skills Required Card
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 36,
                                height: 36,
                                decoration: const BoxDecoration(
                                  color: Color(0xFFFFF3E0),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.workspace_premium_outlined,
                                  color: Color(0xFFFF8F00),
                                  size: 18,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Text(
                                translate('Skills Required', 'आवश्यक कौशल'),
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF1B2B1B),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: skillsText.split(',').map((skill) {
                              final cleanSkill = skill.trim();
                              if (cleanSkill.isEmpty) return const SizedBox.shrink();
                              return Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFFFBEB),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color: const Color(0xFFFDE68A), width: 1),
                                ),
                                child: Text(
                                  cleanSkill,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFFB45309),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Payment Type Card
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: const BoxDecoration(
                              color: Color(0xFFEAF4E8),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.receipt_long_outlined,
                              color: Color(0xFF0E6805),
                              size: 18,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  translate('Payment Type', 'भुगतान का प्रकार'),
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.grey[500],
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  paymentType,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF152018),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Project Description Card
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.assignment_outlined,
                                      color: Constants.AppColors.brand, size: 20),
                                  const SizedBox(width: 8),
                                  Text(
                                    translate('Project Description', 'परियोजना विवरण'),
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700,
                                      color: Constants.AppColors.ink,
                                    ),
                                  ),
                                ],
                              ),
                              SpeakerIconButton(
                                text: translateText(description),
                                size: 18,
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Text(
                            translateText(description),
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey[700],
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Milestone & Payment (only if Milestone Basis and milestones exist)
                    if (project['payment_type'] == "1" && milestones.isNotEmpty) ...[
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.04),
                              blurRadius: 10,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.layers_outlined,
                                    color: Constants.AppColors.brand, size: 20),
                                const SizedBox(width: 8),
                                Text(
                                  translate('Milestone & Payment', 'माइलस्टोन और भुगतान'),
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    color: Constants.AppColors.ink,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),

                            // Horizontally Scrollable Table
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: SizedBox(
                                width: 560,
                                child: Column(
                                  children: [
                                    // Table Header
                                    Container(
                                      decoration: BoxDecoration(
                                        color: Constants.AppColors.brand,
                                        borderRadius: const BorderRadius.only(
                                          topLeft: Radius.circular(8),
                                          topRight: Radius.circular(8),
                                        ),
                                      ),
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            flex: 3,
                                            child: Text(
                                              translate('Description', 'विवरण'),
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.w600,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            flex: 2,
                                            child: Text(
                                              translate('Amount', 'राशि'),
                                              textAlign: TextAlign.center,
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.w600,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            flex: 2,
                                            child: Text(
                                              translate('Proposal/Days', 'प्रस्ताव/दिन'),
                                              textAlign: TextAlign.center,
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.w600,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            flex: 2,
                                            child: Text(
                                              translate('Action', 'कार्रवाई'),
                                              textAlign: TextAlign.right,
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.w600,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),

                                    // Rows
                                    ...List.generate(milestones.length, (index) {
                                      final milestone = milestones[index];
                                      final isEven = index % 2 == 0;
                                      final mStatus = milestone['status']?.toString();
                                      final proposalAmt = milestone['proposalamount'] ?? milestone['proposal'] ?? '-';
                                      final mDuration = milestone['duration'] ?? '-';

                                      return Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                                        decoration: BoxDecoration(
                                          color: isEven ? Colors.white : const Color(0xFFF9FBF9),
                                          border: Border(
                                            bottom: BorderSide(color: Colors.grey[100]!, width: 1),
                                          ),
                                        ),
                                        child: Row(
                                          children: [
                                            Expanded(
                                              flex: 3,
                                              child: Text(
                                                translateText(milestone['description'] ?? 'N/A'),
                                                style: TextStyle(
                                                  fontSize: 13,
                                                  color: Constants.AppColors.ink,
                                                ),
                                              ),
                                            ),
                                            Expanded(
                                              flex: 2,
                                              child: Text(
                                                milestone['amount']?.toString() ?? 'N/A',
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                  fontSize: 13,
                                                  color: Constants.AppColors.ink,
                                                ),
                                              ),
                                            ),
                                            Expanded(
                                              flex: 2,
                                              child: Text(
                                                '$proposalAmt / $mDuration',
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                  fontSize: 13,
                                                  color: Constants.AppColors.ink,
                                                ),
                                              ),
                                            ),
                                            Expanded(
                                              flex: 2,
                                              child: Align(
                                                alignment: Alignment.centerRight,
                                                child: mStatus == '2'
                                                    ? _buildMilestoneAction(
                                                  label: translate('Complete', 'पूर्ण'),
                                                  color: Constants.AppColors.brand,
                                                  onPressed: () => handleMilestoneCompletion(
                                                    context,
                                                    milestone['sno'].toString(),
                                                  ),
                                                )
                                                    : mStatus == '3'
                                                    ? _buildMilestoneAction(
                                                  label: translate('Submitted', 'जमा किया'),
                                                  color: const Color(0xFFF97316),
                                                  onPressed: null,
                                                )
                                                    : mStatus == '4'
                                                    ? _buildMilestoneAction(
                                                  label: translate('Completed', 'पूर्ण किया'),
                                                  color: const Color(0xFF16A34A),
                                                  onPressed: null,
                                                )
                                                    : IconButton(
                                                  icon: const Icon(Icons.edit_outlined,
                                                      color: Colors.blue, size: 20),
                                                  padding: EdgeInsets.zero,
                                                  constraints: const BoxConstraints(),
                                                  onPressed: () => showEditMilestoneDialog(
                                                      index, context),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    }),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],

                    // Proposal Summary / Form Input depending on applyStatus
                    if (project['applyStatus'] != null) ...[
                      Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F9F1),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFFE2EFE2), width: 1),
                        ),
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            // Proposal Amount
                            Expanded(
                              child: Row(
                                children: [
                                  Container(
                                    width: 32,
                                    height: 32,
                                    decoration: const BoxDecoration(
                                      color: Color(0xFFEAF4E8),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.edit_note_outlined,
                                      color: Color(0xFF0E6805),
                                      size: 18,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          translate('Proposal Amount', 'प्रस्ताव राशि'),
                                          style: const TextStyle(
                                            fontSize: 10,
                                            color: Color(0xFF5B6B5E),
                                            fontWeight: FontWeight.w500,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          project['praposal_amount'] != null
                                              ? '₹${project['praposal_amount']}'
                                              : 'N/A',
                                          style: const TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFF152018),
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // Estimate Duration
                            Expanded(
                              child: Row(
                                children: [
                                  Container(
                                    width: 32,
                                    height: 32,
                                    decoration: const BoxDecoration(
                                      color: Color(0xFFEAF4E8),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.access_time_outlined,
                                      color: Color(0xFF0E6805),
                                      size: 18,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          translate('Estimate Duration', 'अनुमानित अवधि'),
                                          style: const TextStyle(
                                            fontSize: 10,
                                            color: Color(0xFF5B6B5E),
                                            fontWeight: FontWeight.w500,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          translateText(project['wpay']?.toString() ?? 'N/A'),
                                          style: const TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFF152018),
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // Comment
                            Expanded(
                              child: Row(
                                children: [
                                  Container(
                                    width: 32,
                                    height: 32,
                                    decoration: const BoxDecoration(
                                      color: Color(0xFFEAF4E8),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.chat_bubble_outline,
                                      color: Color(0xFF0E6805),
                                      size: 16,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          translate('Comment', 'टिप्पणी'),
                                          style: const TextStyle(
                                            fontSize: 10,
                                            color: Color(0xFF5B6B5E),
                                            fontWeight: FontWeight.w500,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          translateText(project['comment']?.toString() ?? 'N/A'),
                                          style: const TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFF152018),
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ] else ...[
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.04),
                              blurRadius: 10,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.rate_review_outlined,
                                    color: Constants.AppColors.brand, size: 20),
                                const SizedBox(width: 8),
                                Text(
                                  translate('Submit Your Proposal', 'अपना प्रस्ताव जमा करें'),
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    color: Constants.AppColors.ink,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _payController,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                labelText: translate("Proposal Amount", "प्रस्ताव राशि"),
                                hintText: translate('Enter proposal amount', 'प्रस्ताव राशि दर्ज करें'),
                                hintStyle: TextStyle(color: Colors.grey[400], fontSize: 13),
                                labelStyle: TextStyle(color: Colors.grey[600], fontSize: 13),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(color: Colors.grey[300]!),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(color: Colors.grey[200]!),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(color: Constants.AppColors.brand, width: 1.5),
                                ),
                                contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return translate('Please enter a proposal amount', 'कृपया प्रस्ताव राशि दर्ज करें');
                                }
                                if (double.tryParse(value) == null) {
                                  return translate('Please enter a valid number', 'कृपया एक मान्य संख्या दर्ज करें');
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            DropdownButtonFormField<String>(
                              value: selectedEstimateDays,
                              onChanged: (newValue) {
                                setState(() {
                                  selectedEstimateDays = newValue;
                                });
                              },
                              decoration: InputDecoration(
                                labelText: translate('Estimated Days', 'अनुमानित दिन'),
                                labelStyle: TextStyle(color: Colors.grey[600], fontSize: 13),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(color: Colors.grey[300]!),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(color: Colors.grey[200]!),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(color: Constants.AppColors.brand, width: 1.5),
                                ),
                                contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                              ),
                              items: _validEstimateDays.map((val) {
                                return DropdownMenuItem<String>(
                                  value: val,
                                  child: Text(translate(val, _getEstimateDaysHindi(val))),
                                );
                              }).toList(),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return translate(
                                      'Please enter the estimated days.',
                                      'कृपया अनुमानित दिन दर्ज करें।');
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _commentController,
                              decoration: InputDecoration(
                                labelText: translate("Enter your Comment", "अपनी टिप्पणी दर्ज करें"),
                                hintText: translate('Write your comment here', 'अपनी टिप्पणी यहाँ लिखें'),
                                hintStyle: TextStyle(color: Colors.grey[400], fontSize: 13),
                                labelStyle: TextStyle(color: Colors.grey[600], fontSize: 13),
                                suffixIcon: MicIconButton(controller: _commentController),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(color: Colors.grey[300]!),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(color: Colors.grey[200]!),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(color: Constants.AppColors.brand, width: 1.5),
                                ),
                                contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                              ),
                              maxLines: 2,
                            ),
                          ],
                        ),
                      ),
                    ],

                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
          ),

          // ── Fixed bottom CTA ───────────────────────────────────────────────
          Container(
            color: const Color(0xFFFAFBF7),
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            child: SizedBox(
              width: double.infinity,
              height: 52,
              child: _buildActionButton(project),
            ),
          ),
        ],
      ),
    );
  }
}

class AppliedProjects extends StatefulWidget {
  @override
  _AppliedProjectsState createState() => _AppliedProjectsState();
}

class _AppliedProjectsState extends State<AppliedProjects> {
  final _secureStorage = const FlutterSecureStorage();
  bool isLoading = true;
  List<dynamic> projects = [];
  List<dynamic> filteredProjects = [];
  List<JobType> _jobTypes = [];
  final ScrollController _appliedProjectsScrollController = ScrollController();

  final TextEditingController _labourSearchController = TextEditingController();

  @override
  void dispose() {
    _projectSearchController.dispose();
    _labourSearchController.dispose();
    _appliedProjectsScrollController.dispose();
    super.dispose();
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

  @override
  void initState() {
    super.initState();
    loadLanguage();
    fetchProjects();
    fetchJobTypes();
  }

  final TextEditingController _projectSearchController =
  TextEditingController();
  String selectedCategory = 'All';
  double selectedPriceRange = 1000000;
  double selectedRating = 3;
  String selectedJobType = 'All';
  bool isDailyWageSelected = false;
  bool isContractSelected = false;
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

  void _showFilterDialog() {
    final language =
        Provider.of<LanguageProvider>(context, listen: false).selectedLanguage;

    String translate(String enText, String hiText) {
      return language == 'en' ? enText : hiText;
    }

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateDialog) {
          return AlertDialog(
            title: Text(translate('Filter Projects', 'प्रस्ताव फ़िल्टर करें')),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Job Type filter (using fetched job types) with label
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(translate(
                            'Select Job Type', 'कृपया नौकरी का प्रकार चुनें')),
                        DropdownButton<String>(
                          value: selectedJobType,
                          isExpanded: true,
                          items: [
                            DropdownMenuItem<String>(
                              value: 'All',
                              child: Text(translate('All', 'सभी')),
                            ),
                            // Create a DropdownMenuItem for each jobType
                            ..._jobTypes
                                .map((job) => DropdownMenuItem<String>(
                              value: job.jobname,
                              child: Text(translate(job.jobname,
                                  job.jobname)), // Assuming jobname is in English
                            ))
                                .toList(),
                          ],
                          onChanged: (value) {
                            setStateDialog(() {
                              selectedJobType = value!;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Category filter with label
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(translate(
                            'Select Payment Type', 'भुगतान प्रकार चुनें')),
                        DropdownButton<String>(
                          value: selectedCategory,
                          isExpanded: true,
                          items: ['All', 'Project Basis', 'Milestone Basis']
                              .map((category) => DropdownMenuItem<String>(
                            value: category,
                            child: Text(translate(category, category)),
                          ))
                              .toList(),
                          onChanged: (value) {
                            setStateDialog(() {
                              selectedCategory = value!;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Search field
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: TextField(
                      controller: _labourSearchController,
                      decoration: InputDecoration(
                        prefixIcon:
                        const Icon(Icons.search, color: Colors.green),
                        hintText: translate('Search by pincode, city, or state',
                            'पिनकोड, शहर या राज्य द्वारा खोजें'),
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

                  // Price Range Slider
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                            translate('Select Budget Range', 'बजट सीमा चुनें')),
                        Slider(
                          value: selectedPriceRange,
                          min: 0,
                          max: 1000000,
                          divisions: 100,
                          label: '\$${selectedPriceRange.toStringAsFixed(0)}',
                          onChanged: (value) {
                            setStateDialog(() {
                              selectedPriceRange = value;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Project Type filter using checkboxes (Daily Wage and Contract)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(translate(
                            'Select Job Type', 'नौकरी का प्रकार चुनें')),
                        Row(
                          children: [
                            Checkbox(
                              value: isDailyWageSelected,
                              onChanged: (bool? value) {
                                setStateDialog(() {
                                  isDailyWageSelected = value!;
                                });
                              },
                            ),
                            Text(translate('Daily Wage', 'दैनिक वेतन')),
                            const SizedBox(width: 10),
                            Checkbox(
                              value: isContractSelected,
                              onChanged: (bool? value) {
                                setStateDialog(() {
                                  isContractSelected = value!;
                                });
                              },
                            ),
                            Text(translate('Contract', 'ठेका')),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  // Rating filter (optional)
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
                child: Text(translate('Apply Filters', 'फ़िल्टर लागू करें')),
              ),
              TextButton(
                onPressed: () {
                  // Reset filters to default values
                  setStateDialog(() {
                    selectedJobType = 'All';
                    selectedCategory = 'All';
                    selectedPriceRange = 1000000;
                    isDailyWageSelected = false;
                    isContractSelected = false;
                    _labourSearchController.clear(); // Clear the search field
                  });
                },
                child: Text(translate('Reset Filters', 'फ़िल्टर रीसेट करें'),
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
    Map<String, dynamic> filters = {
      'id': userId,
      'job_type': selectedJobType,
      'category': selectedCategory,
      'search': _labourSearchController.text,
      'budget': selectedPriceRange.toInt(),
      'dailyWage': isDailyWageSelected,
      'contract': isContractSelected,
    };

    // Example API request to fetch filtered projects

    fetchFilteredProjects(filters);
  }

  Future<void> fetchFilteredProjects(Map<String, dynamic> filters) async {
    final String apiUrl =
        '${Constants.AppConstants.apiUrl}labour/searchapplyProjectsApi';
    String? userId = await _secureStorage.read(key: 'id');
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User ID not found in secure storage')),
      );
      return;
    }
    print(jsonEncode(filters));
    try {
      setState(() {
        isLoading = true;
      });

      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(filters),
      );

      if (response.statusCode == 200) {
        final responseBody = json.decode(response.body);
        if (responseBody['status'] == 1) {
          setState(() {
            projects = responseBody['data'];
            filteredProjects = projects;
            isLoading = false;
          });
        } else {
          setState(() {
            projects = [];
            filteredProjects = [];
            isLoading = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(
                    responseBody['message'] ?? 'Failed to fetch projects')),
          );
        }
      } else {
        setState(() {
          isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content:
              Text('Failed to fetch projects: ${response.statusCode}')),
        );
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> fetchProjects() async {
    final String apiUrl =
        '${Constants.AppConstants.apiUrl}labour/appliedProjects';
    String? userId = await _secureStorage.read(key: 'id');
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User ID not found in secure storage')),
      );
      return;
    }

    try {
      setState(() {
        isLoading = true;
      });

      final Map<String, dynamic> requestBody = {
        'id': userId,
      };
      print(jsonEncode(requestBody));
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );
      if (response.statusCode == 200) {
        final responseBody = json.decode(response.body);
        if (responseBody['status'] == 1) {
          setState(() {
            print(responseBody['data']);
            projects = responseBody['data'];
            filteredProjects = projects;
            isLoading = false;
          });
        } else {
          setState(() {
            projects = [];
            filteredProjects = [];
            isLoading = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(
                    responseBody['message'] ?? 'Failed to fetch projects')),
          );
        }
      } else {
        setState(() {
          isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content:
              Text('Failed to fetch projects: ${response.statusCode}')),
        );
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }

  String translate(String enText, String hiText) {
    final language =
        Provider.of<LanguageProvider>(context, listen: false).selectedLanguage;
    return language == 'en' ? enText : hiText;
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

  Future<void> applyToProject(int projectId) async {
    final String apiUrl =
        '${Constants.AppConstants.apiUrl}labour/applyProjectApi';

    // Get user ID from secure storage
    String? userId = await _secureStorage.read(key: 'id');
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User ID not found in secure storage')),
      );
      return;
    }

    final Map<String, dynamic> requestBody = {
      'labourId': userId,
      'projectId': projectId,
    };

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        final responseBody = json.decode(response.body);
        if (responseBody['status'] == 1) {
          // Success - Refresh the list
          Fluttertoast.showToast(
            msg: translate(
                'Applied successfully!', 'सफलतापूर्वक लागू किया गया!'),
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            backgroundColor: Colors.green.shade700,
            textColor: Colors.white,
            fontSize: 16.0,
          );
          fetchProjects(); // Reload projects to update applyStatus
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(responseBody['message'] ?? 'Failed to apply')),
          );
        }
      } else {
        String errorMessage = 'Failed to apply';
        try {
          final decoded = json.decode(response.body);
          if (decoded is Map<String, dynamic>) {
            if (decoded.containsKey('errors') && decoded['errors'] is Map) {
              final errorsMap = decoded['errors'] as Map<String, dynamic>;
              List<String> allErrors = [];
              errorsMap.forEach((key, value) {
                if (value is List) {
                  allErrors.addAll(value.map((e) => e.toString()));
                } else {
                  allErrors.add(value.toString());
                }
              });
              if (allErrors.isNotEmpty) errorMessage = allErrors.join(', ');
            } else if (decoded.containsKey('message')) {
              errorMessage = decoded['message'].toString();
            }
          }
        } catch (e) {
          String bodyText = response.body.length > 100 ? response.body.substring(0, 100) + "..." : response.body;
          errorMessage = 'Failed to apply: $bodyText';
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage)),
        );
      }
    } catch (e) {}
  }

  TextEditingController _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final language =
        Provider.of<LanguageProvider>(context, listen: false).selectedLanguage;

    String translate(String enText, String hiText) {
      return language == 'en' ? enText : hiText;
    }

    return RefreshIndicator(
      onRefresh: () async {
        // Assuming loadLanguage, fetchProjects, and fetchJobTypes are async functions.
        await loadLanguage(); // Load the language (make sure it's an async function)
        await fetchProjects(); // Fetch projects (make sure it's an async function)
        await fetchJobTypes(); // Fetch job types (make sure it's an async function)

        setState(() {
          // If you need to update the UI state, you can do it here after all async tasks are done.
        });
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            translateText("My Projects"),
            style: TextStyle(color: Colors.white),
          ),
          flexibleSpace: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.green, Colors.teal],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          iconTheme: IconThemeData(color: Colors.white),
        ),
        body: SafeArea(
          child: Container(
            width: double.infinity,
            height: double.infinity,
            color: Colors.white,
            // decoration: const BoxDecoration(
            //   gradient: LinearGradient(
            //     begin: Alignment.topLeft,
            //     end: Alignment.bottomRight,
            //     colors: [
            //       Color(0xFFA8D5BA), // Light green
            //       Color(0xFF68A691), // Darker green
            //     ],
            //   ),
            // ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                IconButton(
                  icon: Icon(Icons.filter_list),
                  onPressed: () => _showFilterDialog(),
                ),
                Expanded(
                  child: isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : filteredProjects.isEmpty
                      ? Center(
                    child: Text(
                      translateText('No projects found'),
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: Colors.brown,
                      ),
                    ),
                  )
                      : Scrollbar(
                    controller: _appliedProjectsScrollController,
                    thumbVisibility: true,
                    child: ListView.builder(
                      controller: _appliedProjectsScrollController,
                      itemCount: filteredProjects.length,
                      itemBuilder: (context, index) {
                        final project = filteredProjects[index];
                        return InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    ProjectDetailsPage(
                                      projectId: project['id'],
                                    ),
                              ),
                            );
                          },
                          child: Container(
                            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                            decoration: BoxDecoration(
                              color: Constants.AppColors.card,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: const Color(0xFFF1F5EE),
                                width: 1.0,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.04),
                                  blurRadius: 16,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // ── TOP ROW: Avatar + Title/Meta + Status badge ──
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      // Left: Farmer Avatar
                                      Container(
                                        width: 50,
                                        height: 50,
                                        decoration: const BoxDecoration(
                                          color: Color(0xFFF1F5EE),
                                          shape: BoxShape.circle,
                                        ),
                                        alignment: Alignment.center,
                                        child: const Text(
                                          '👨‍🌾',
                                          style: TextStyle(fontSize: 26),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      // Right: Title + status badge row + Date + Type
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            // ── Title + status badge on same row ──
                                            Row(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Expanded(
                                                  child: Text(
                                                    translateText(project['title']?.toString() ?? 'No Title') ?? 'No Title',
                                                    style: Constants.AppTypography.h2.copyWith(
                                                      color: Constants.AppColors.ink,
                                                      fontWeight: FontWeight.bold,
                                                      fontSize: 16,
                                                    ),
                                                    maxLines: 2,
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                ),
                                                if (project['applyStatus'] != null) ...[
                                                  const SizedBox(width: 8),
                                                  _buildStatusBadge(project),
                                                ],
                                              ],
                                            ),
                                            const SizedBox(height: 6),
                                            // ── Date + contract type tag row ──
                                            Row(
                                              children: [
                                                const Icon(
                                                  Icons.calendar_today_outlined,
                                                  size: 13,
                                                  color: Colors.grey,
                                                ),
                                                const SizedBox(width: 4),
                                                Text(
                                                  _formatDate(project['created_at']?.toString() ?? ''),
                                                  style: const TextStyle(
                                                    fontSize: 13,
                                                    color: Colors.grey,
                                                  ),
                                                ),
                                                const SizedBox(width: 10),
                                                Container(
                                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                                  decoration: BoxDecoration(
                                                    color: Constants.AppColors.brandTint,
                                                    borderRadius: BorderRadius.circular(6),
                                                  ),
                                                  child: Row(
                                                    mainAxisSize: MainAxisSize.min,
                                                    children: [
                                                      const Text('🌾', style: TextStyle(fontSize: 12)),
                                                      const SizedBox(width: 4),
                                                      Text(
                                                        translateText(project['project_type'] ?? 'N/A') ?? 'N/A',
                                                        style: TextStyle(
                                                          fontSize: 12,
                                                          fontWeight: FontWeight.bold,
                                                          color: Constants.AppColors.brandDeep,
                                                        ),
                                                      ),
                                                    ],
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
                                  const Divider(color: Color(0xFFF1F5EE), height: 1),
                                  const SizedBox(height: 10),
                                  // ── Location ──
                                  Row(
                                    children: [
                                      const Text('📍', style: TextStyle(fontSize: 14)),
                                      const SizedBox(width: 6),
                                      Expanded(
                                        child: Text(
                                          "${translateText(project['city'] ?? 'N/A')}, ${translateText(project['state'] ?? 'N/A')}",
                                          style: Constants.AppTypography.body.copyWith(
                                            color: Constants.AppColors.inkSoft,
                                            fontWeight: FontWeight.w600,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  // ── ROW 1: Workers · Amount · Duration ──
                                  Row(
                                    children: [
                                      _buildChip(
                                        icon: Icons.people_outline,
                                        label: '${project['qty_labours'] ?? '0'} ${translate('Workers', 'मजदूर')}',
                                        bgColor: const Color(0xFFEAF4E8),
                                        textColor: const Color(0xFF0E6805),
                                        iconColor: const Color(0xFF0E6805),
                                      ),
                                      const SizedBox(width: 8),
                                      _buildChip(
                                        icon: Icons.currency_rupee,
                                        label: '₹${project['budget'] ?? '0'}',
                                        bgColor: const Color(0xFFFFF3E0),
                                        textColor: const Color(0xFFE65100),
                                        iconColor: const Color(0xFFE65100),
                                      ),
                                      const SizedBox(width: 8),
                                      _buildChip(
                                        icon: Icons.access_time,
                                        label: translateText(project['days']?.toString() ?? '') ?? '',
                                        bgColor: const Color(0xFFE3F2FD),
                                        textColor: const Color(0xFF0D47A1),
                                        iconColor: const Color(0xFF0D47A1),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  // ── ROW 2: View Details right-aligned ──
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: _buildViewDetailsButton(project),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildChip({
    required IconData icon,
    required String label,
    required Color bgColor,
    required Color textColor,
    required Color iconColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: iconColor),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(dynamic project) {
    String? appliedStatus = project['applyStatus']?.toString();
    if (appliedStatus == null) return const SizedBox.shrink();

    final language = Provider.of<LanguageProvider>(context, listen: false).selectedLanguage;
    String translate(String enText, String hiText) {
      return language == 'en' ? enText : hiText;
    }

    String text = '';
    Color bgColor = const Color(0xFFEAF4E8);
    Color textColor = const Color(0xFF0E6805);
    Color borderColor = const Color(0xFFC8E6C9);
    IconData statusIcon = Icons.check;

    if (appliedStatus == "0") {
      text = translate('Applied', 'आवेदन किया');
      bgColor = const Color(0xFFEAF4E8);
      textColor = const Color(0xFF0E6805);
      borderColor = const Color(0xFFC8E6C9);
      statusIcon = Icons.check;
    } else if (appliedStatus == "1") {
      text = translate('Assigned', 'आवंटित');
      bgColor = const Color(0xFFEFF6FF);
      textColor = const Color(0xFF1E40AF);
      borderColor = const Color(0xFFBFDBFE);
      statusIcon = Icons.assignment_ind_outlined;
    } else if (appliedStatus == "2") {
      text = translate('Work Started', 'कार्य शुरू हुआ');
      if (project['complete_confirm']?.toString() == "1") {
        text = translate('Completion Requested', 'पूर्णता का अनुरोध');
      } else if (project['cancel_confirm']?.toString() == "1") {
        text = translate('Cancellation Requested', 'रद्दीकरण का अनुरोध');
      }
      bgColor = const Color(0xFFFFF7ED);
      textColor = const Color(0xFFC2410C);
      borderColor = const Color(0xFFFED7AA);
      statusIcon = Icons.hourglass_top_outlined;
    } else if (appliedStatus == "3") {
      text = translate('Work Completed', 'कार्य पूर्ण');
      bgColor = const Color(0xFFF0FDF4);
      textColor = const Color(0xFF15803D);
      borderColor = const Color(0xFFBBF7D0);
      statusIcon = Icons.check_circle_outline;
    } else if (appliedStatus == "4") {
      text = translate('Work Cancelled', 'रद्द किया गया');
      bgColor = const Color(0xFFFEF2F2);
      textColor = const Color(0xFF991B1B);
      borderColor = const Color(0xFFFCA5A5);
      statusIcon = Icons.close;
    } else {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: borderColor, width: 0.8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(statusIcon, size: 11, color: textColor),
          const SizedBox(width: 3),
          Text(
            text,
            style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.bold,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildViewDetailsButton(dynamic project) {
    String? appliedStatus = project['applyStatus']?.toString();
    final language = Provider.of<LanguageProvider>(context, listen: false).selectedLanguage;
    String translate(String enText, String hiText) {
      return language == 'en' ? enText : hiText;
    }

    String label = appliedStatus == null
        ? translate('Apply Now', 'आवेदन करें')
        : translate('View Details', 'विवरण देखें');

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFEAF4E8),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFC8E6C9), width: 0.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF0E6805),
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
          const SizedBox(width: 4),
          const Icon(
            Icons.arrow_forward_ios,
            size: 10,
            color: Color(0xFF0E6805),
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
}

// ─── Custom Cow Avatar & Painter ──────────────────────────────────────────────

class CowAvatar extends StatelessWidget {
  final double size;
  const CowAvatar({Key? key, this.size = 70}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        color: Color(0xFFEAF4E8),
        shape: BoxShape.circle,
      ),
      child: CustomPaint(
        size: Size(size, size),
        painter: CowPainter(),
      ),
    );
  }
}

class CowPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF0E6805)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final fillPaint = Paint()
      ..color = const Color(0xFF0E6805)
      ..style = PaintingStyle.fill;

    final double w = size.width;
    final double h = size.height;
    final double scale = w / 100;

    // Head / Face outline path
    final facePath = Path()
      ..moveTo(38 * scale, 32 * scale)
      ..lineTo(62 * scale, 32 * scale)
      ..quadraticBezierTo(65 * scale, 45 * scale, 64 * scale, 58 * scale)
      ..quadraticBezierTo(50 * scale, 60 * scale, 36 * scale, 58 * scale)
      ..quadraticBezierTo(35 * scale, 45 * scale, 38 * scale, 32 * scale);
    canvas.drawPath(facePath, paint);

    // Muzzle / Snout cup shape
    final muzzlePath = Path()
      ..moveTo(36 * scale, 58 * scale)
      ..cubicTo(32 * scale, 68 * scale, 40 * scale, 76 * scale, 50 * scale, 76 * scale)
      ..cubicTo(60 * scale, 76 * scale, 68 * scale, 68 * scale, 64 * scale, 58 * scale)
      ..quadraticBezierTo(50 * scale, 60 * scale, 36 * scale, 58 * scale);
    canvas.drawPath(muzzlePath, paint);

    // Left Ear
    final leftEar = Path()
      ..moveTo(35 * scale, 38 * scale)
      ..quadraticBezierTo(15 * scale, 35 * scale, 12 * scale, 45 * scale)
      ..quadraticBezierTo(18 * scale, 52 * scale, 35 * scale, 46 * scale);
    canvas.drawPath(leftEar, paint);

    // Right Ear
    final rightEar = Path()
      ..moveTo(65 * scale, 38 * scale)
      ..quadraticBezierTo(85 * scale, 35 * scale, 88 * scale, 45 * scale)
      ..quadraticBezierTo(82 * scale, 52 * scale, 65 * scale, 46 * scale);
    canvas.drawPath(rightEar, paint);

    // Left Horn
    final leftHorn = Path()
      ..moveTo(39 * scale, 32 * scale)
      ..quadraticBezierTo(32 * scale, 14 * scale, 22 * scale, 17 * scale)
      ..quadraticBezierTo(30 * scale, 24 * scale, 43 * scale, 30 * scale);
    canvas.drawPath(leftHorn, paint);

    // Right Horn
    final rightHorn = Path()
      ..moveTo(61 * scale, 32 * scale)
      ..quadraticBezierTo(68 * scale, 14 * scale, 78 * scale, 17 * scale)
      ..quadraticBezierTo(70 * scale, 24 * scale, 57 * scale, 30 * scale);
    canvas.drawPath(rightHorn, paint);

    // Eyes
    canvas.drawCircle(Offset(44 * scale, 44 * scale), 1.8 * scale, fillPaint);
    canvas.drawCircle(Offset(56 * scale, 44 * scale), 1.8 * scale, fillPaint);

    // Nostrils
    canvas.drawCircle(Offset(44 * scale, 66 * scale), 1.5 * scale, fillPaint);
    canvas.drawCircle(Offset(56 * scale, 66 * scale), 1.5 * scale, fillPaint);

    // "IWM" text below the muzzle
    final textPainter = TextPainter(
      text: TextSpan(
        text: 'IWM',
        style: TextStyle(
          color: const Color(0xFF0E6805),
          fontSize: 8.5 * scale,
          fontWeight: FontWeight.w900,
          letterSpacing: 0.8,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset((50 * scale) - (textPainter.width / 2), 79 * scale),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}