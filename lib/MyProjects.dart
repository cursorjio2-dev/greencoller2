import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:greencollar/l10n/app_localizations.dart';
import 'package:greencollar/labourhomepage.dart';
import 'package:greencollar/main.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:greencollar/constants.dart' as Constants;
import 'package:provider/provider.dart';
import 'package:translator/translator.dart';
import 'package:intl/intl.dart' hide TextDirection;
import 'package:greencollar/NearbyProject.dart';

class MyProjectsPage extends StatefulWidget {
  @override
  _MyProjectsPageState createState() => _MyProjectsPageState();
}

class _MyProjectsPageState extends State<MyProjectsPage> {
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
    fetchAppliedProjects();
  }

  Future<void> fetchAppliedProjects() async {
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

  void filterProjects(String query) {
    setState(() {
      filteredProjects = projects.where((project) {
        String title =
            project['title'] ?? '';
        String budget =
            project['budget']?.toString() ?? '';
        String city = project['city'] ?? '';
        String state =
            project['state'] ?? '';

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

  final GoogleTranslator _translator = GoogleTranslator();

  Map<String, Map<String, String>> _cachedTranslations = {};

  Map<String, Map<String, String>> translations =
      Constants.AppConstants.translations;
  String _selectedLanguage = 'en';

  Future<void> loadLanguage() async {
    String? language = await _secureStorage.read(key: 'selectedLanguage');
    _selectedLanguage = language ?? 'en';
    print(language);
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

      _cachedTranslations.putIfAbsent(text, () => {})[targetLang] =
          translation.text;
      setState(() {});
    } catch (e) {
      print("Translation error: $e");
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
        await loadLanguage();
        await fetchAppliedProjects();

        setState(() {});
      },
      child: Scaffold(
        backgroundColor: Constants.AppColors.surface,
        appBar: AppBar(
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: Constants.AppColors.brandGradient,
            ),
          ),
          title: Text(
            translate('My Projects', 'मेरी परियोजनाएँ'),
            style: Constants.AppTypography.h3.copyWith(color: Colors.white),
          ),
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back,
              color: Colors.white,
            ),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
        body: SafeArea(
          child: Container(
            width: double.infinity,
            height: double.infinity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Search bar
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (value) {
                      filterProjects(value);
                    },
                    decoration: InputDecoration(
                      prefixIcon:
                      const Icon(Icons.search, color: Constants.AppColors.brand),
                      hintText: translate(
                          'Search by title, budget, city, or state',
                          'शीर्षक, बजट, शहर या राज्य द्वारा खोजें'),
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
                Expanded(
                  child: isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : filteredProjects.isEmpty
                      ? Center(
                    child: Text(
                      translate('No applied projects found', 'कोई आवेदित परियोजना नहीं मिली'),
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
                                  // ── Farmer Name ──
                                  if (project['farmer_name'] != null)
                                    Padding(
                                      padding: const EdgeInsets.only(bottom: 8),
                                      child: Row(
                                        children: [
                                          const Icon(Icons.person_outline, size: 14, color: Colors.grey),
                                          const SizedBox(width: 6),
                                          Expanded(
                                            child: Text(
                                              "${translate('Farmer', 'किसान')}: ${translateText(project['farmer_name']?.toString() ?? 'N/A')}",
                                              style: Constants.AppTypography.body.copyWith(
                                                color: Constants.AppColors.inkSoft,
                                                fontWeight: FontWeight.w600,
                                                fontSize: 14,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
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
    final language = Provider.of<LanguageProvider>(context, listen: false).selectedLanguage;
    String translate(String enText, String hiText) {
      return language == 'en' ? enText : hiText;
    }

    String label = translate('View Details', 'विवरण देखें');

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
