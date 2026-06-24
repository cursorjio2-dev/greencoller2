import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:greencollar/constants.dart';
import 'package:greencollar/constants.dart' as Constants;
import 'package:phonepe_payment_sdk/phonepe_payment_sdk.dart';
import 'package:http/http.dart' as http;

/// Shared wallet helper for coin management, contact unlocking,
/// PhonePe SDK payment, and purchase history.
class WalletHelper {
  static const FlutterSecureStorage _storage = FlutterSecureStorage();
  static const String _coinsKey = 'wallet_coins';
  static const String _unlockedKey = 'unlocked_contacts';
  static const String _historyKey = 'purchase_history';
  static const int _defaultCoins = 100;
  static const int _unlockCost = 5;

  // ── PhonePe Config ─────────────────────────────────────────────────────
  static const String _packageName = 'com.apstia.greencollar';
  static bool _sdkInitialized = false;

  // ── SDK Init ───────────────────────────────────────────────────────────

  /// Initialize PhonePe SDK with server-provided configuration.
  static Future<void> initPhonePeSdk({
    required String environment,
    required String merchantId,
    String? appId,
  }) async {
    try {
      _sdkInitialized = false;
      bool result = await PhonePePaymentSdk.init(
        environment,
        appId,
        merchantId,
        true, // enableLogging
      );
      _sdkInitialized = result;
      debugPrint('PhonePe SDK Init Success: $result (env: $environment, merchant: $merchantId)');
      if (!result) {
        debugPrint('PhonePe SDK Init returned false — SDK may not be available on this device');
      }
    } catch (e) {
      debugPrint('PhonePe SDK Init Error: $e');
      _sdkInitialized = false;
    }
  }

  // ── Coin Balance ──────────────────────────────────────────────────────

  /// Read current coin balance (defaults to 100 on first launch).
  static Future<int> getCoins() async {
    String? val = await _storage.read(key: _coinsKey);
    if (val == null) {
      await _storage.write(key: _coinsKey, value: _defaultCoins.toString());
      return _defaultCoins;
    }
    return int.tryParse(val) ?? _defaultCoins;
  }

  /// Set the coin balance to a specific value.
  static Future<void> setCoins(int coins) async {
    await _storage.write(key: _coinsKey, value: coins.toString());
  }

  /// Fetch coin balance from server and sync locally.
  static Future<int> fetchCoinBalanceFromServer(String farmerId) async {
    try {
      final url = Uri.parse('${Constants.AppConstants.apiUrl}farmer/coinbalance');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'farmer_id': farmerId}),
      ).timeout(const Duration(seconds: 10));

      debugPrint('CoinBalance API status: ${response.statusCode}');
      debugPrint('CoinBalance API response: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data != null && (data['success'] == true || data['status'] == true)) {
          final coinBalance = data['coin_balance'] ?? data['data']?['coin_balance'];
          if (coinBalance != null) {
            int coins = int.tryParse(coinBalance.toString()) ?? 0;
            await setCoins(coins);
            return coins;
          }
        }
      }
    } catch (e) {
      debugPrint('Error fetching coin balance from server: $e');
    }
    return getCoins();
  }

  /// Sync coin balance using logged-in farmer's ID.
  static Future<int> syncCoinBalance() async {
    final farmerId = await _storage.read(key: 'id');
    if (farmerId == null) {
      return getCoins();
    }
    return fetchCoinBalanceFromServer(farmerId);
  }

  /// Deduct coins. Returns true if successful, false if insufficient funds.
  static Future<bool> deductCoins(int amount) async {
    int current = await getCoins();
    if (current < amount) return false;
    await setCoins(current - amount);
    return true;
  }

  /// Add coins to the balance.
  static Future<void> addCoins(int amount) async {
    int current = await getCoins();
    await setCoins(current + amount);
  }

  static int? _cachedCoinCharge;

  /// Fetch required coin charge to unlock one contact.
  static Future<int> getCoinCharge() async {
    try {
      final url = Uri.parse('${Constants.AppConstants.apiUrl}coincharge');
      final response = await http.post(url).timeout(const Duration(seconds: 5));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data != null && data['coin_charge'] != null) {
          int charge = int.tryParse(data['coin_charge'].toString()) ?? 5;
          _cachedCoinCharge = charge;
          await _storage.write(key: 'coin_charge', value: charge.toString());
          return charge;
        }
      }
    } catch (e) {
      debugPrint('Error getting coin charge: $e');
    }
    // Fallback to cache, local storage, or default 5
    if (_cachedCoinCharge != null) return _cachedCoinCharge!;
    String? local = await _storage.read(key: 'coin_charge');
    if (local != null) {
      _cachedCoinCharge = int.tryParse(local) ?? 5;
      return _cachedCoinCharge!;
    }
    return 5;
  }

  /// Fetch dynamic packages from API.
  static Future<List<Map<String, dynamic>>> getCoinPackages() async {
    try {
      final url = Uri.parse('${Constants.AppConstants.apiUrl}coinpackages');
      final response = await http.post(url).timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        var list = data is List ? data : (data['coin_packages'] ?? data['data'] ?? data['packages']);
        if (list != null && list is List) {
          return list.map<Map<String, dynamic>>((e) {
            return {
              'id': e['id'],
              'coins': int.tryParse(e['coins'].toString()) ?? 0,
              'price': (double.tryParse((e['amount'] ?? e['price']).toString()) ?? 0).toInt(),
              'name': (e['package_name'] ?? e['name'])?.toString() ?? 'Package',
            };
          }).toList();
        }
      }
    } catch (e) {
      debugPrint('Error fetching packages: $e');
    }
    // Default packages fallback
    return [
      {'id': 0, 'coins': 50, 'price': 25, 'name': 'Basic'},
      {'id': 0, 'coins': 100, 'price': 50, 'name': 'Standard'},
      {'id': 0, 'coins': 250, 'price': 100, 'name': 'Popular'},
      {'id': 0, 'coins': 500, 'price': 200, 'name': 'Premium'},
      {'id': 0, 'coins': 1000, 'price': 350, 'name': 'Super'},
    ];
  }

  /// Call API to record phone view and deduct coins on backend.
  static Future<bool> unlockPhoneNumber({
    required String farmerId,
    required String labourId,
  }) async {
    try {
      final url = Uri.parse('${Constants.AppConstants.apiUrl}farmer/phoneview');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'farmer_id': farmerId,
          'labour_id': labourId,
        }),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data != null && (data['success'] == true || data['status'] == true)) {
          return true;
        }
      }
    } catch (e) {
      debugPrint('Error unlocking phone number: $e');
    }
    return false;
  }

  /// Show coin unlock confirmation dialog.
  static Future<bool> showCoinUnlockDialog({
    required BuildContext context,
    required int coinCost,
    required String workerName,
  }) async {
    bool confirm = false;
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.buttonBg,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.lock_open, color: AppColors.amberNotice, size: 24),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Unlock Contact',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
          content: RichText(
            text: TextSpan(
              style: const TextStyle(fontSize: 15, color: AppColors.ink, height: 1.5),
              children: [
                const TextSpan(text: 'To see the contact number for '),
                TextSpan(
                  text: workerName,
                  style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.ink),
                ),
                const TextSpan(text: ', '),
                TextSpan(
                  text: '$coinCost coins',
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    color: AppColors.amberNotice,
                  ),
                ),
                const TextSpan(text: ' will be debited.\n\nDo you want to proceed?'),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(
                'Cancel',
                style: TextStyle(color: AppColors.inkSoft, fontWeight: FontWeight.w600),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Constants.AppColors.button,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () {
                confirm = true;
                Navigator.pop(ctx);
              },
              child: const Text('Yes, Unlock'),
            ),
          ],
        );
      },
    );
    return confirm;
  }

  // ── Unlocked Contacts ─────────────────────────────────────────────────

  static Future<List<String>> _getUnlockedList() async {
    String? val = await _storage.read(key: _unlockedKey);
    if (val == null || val.isEmpty) return [];
    try {
      return List<String>.from(jsonDecode(val));
    } catch (_) {
      return [];
    }
  }

  static Future<bool> isContactUnlocked(String contactId) async {
    List<String> unlocked = await _getUnlockedList();
    return unlocked.contains(contactId);
  }

  static Future<void> markContactUnlocked(String contactId) async {
    List<String> unlocked = await _getUnlockedList();
    if (!unlocked.contains(contactId)) {
      unlocked.add(contactId);
      await _storage.write(key: _unlockedKey, value: jsonEncode(unlocked));
    }
  }

  // ── Purchase History ──────────────────────────────────────────────────

  /// Get purchase history as a list of maps.
  static Future<List<Map<String, dynamic>>> getPurchaseHistory() async {
    try {
      final farmerId = await _storage.read(key: 'id');
      if (farmerId == null) {
        debugPrint('getPurchaseHistory: Farmer ID not found in secure storage');
        return _getLocalPurchaseHistory();
      }

      final url = Uri.parse('${Constants.AppConstants.apiUrl}farmer/purchasecoins');
      debugPrint('getPurchaseHistory: Fetching from API (farmer: $farmerId)');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'farmer_id': farmerId}),
      ).timeout(const Duration(seconds: 10));

      debugPrint('getPurchaseHistory: API Status: ${response.statusCode}');
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        if (responseData['success'] == true && responseData['data'] != null) {
          final List<dynamic> list = responseData['data'];
          final List<Map<String, dynamic>> parsedHistory = list.map<Map<String, dynamic>>((e) {
            return {
              'coins': int.tryParse(e['package_coins']?.toString() ?? '') ?? 0,
              'price': double.tryParse(e['package_amount']?.toString() ?? '')?.toInt() ?? 0,
              'transactionId': e['merchant_transaction_id']?.toString() ?? '',
              'status': e['payment_status']?.toString() ?? 'FAILED',
              'date': e['created_at']?.toString() ?? '',
            };
          }).toList();

          // Update local secure storage copy
          await _storage.write(key: _historyKey, value: jsonEncode(parsedHistory));
          return parsedHistory;
        }
      }
    } catch (e) {
      debugPrint('Error getting purchase history from API: $e');
    }

    // Fallback to local storage if API call fails or ID is missing
    return _getLocalPurchaseHistory();
  }

  static Future<List<Map<String, dynamic>>> _getLocalPurchaseHistory() async {
    String? val = await _storage.read(key: _historyKey);
    if (val == null || val.isEmpty) return [];
    try {
      return List<Map<String, dynamic>>.from(
        (jsonDecode(val) as List).map((e) => Map<String, dynamic>.from(e)),
      );
    } catch (_) {
      return [];
    }
  }

  /// Add a purchase record to history.
  static Future<void> _addPurchaseRecord({
    required int coins,
    required int priceInr,
    required String transactionId,
    required String status,
  }) async {
    List<Map<String, dynamic>> history = await getPurchaseHistory();
    history.insert(0, {
      'coins': coins,
      'price': priceInr,
      'transactionId': transactionId,
      'status': status,
      'date': DateTime.now().toIso8601String(),
    });
    // Keep only last 50 records
    if (history.length > 50) history = history.sublist(0, 50);
    await _storage.write(key: _historyKey, value: jsonEncode(history));
  }

  // ── Mask Phone ────────────────────────────────────────────────────────

  static String maskPhone(String phone) {
    if (phone.length <= 2) return phone;
    return phone.substring(0, 2) + 'X' * (phone.length - 2);
  }

  // ── PhonePe Payment (Server-Driven) ────────────────────────────────────

  /// Start a PhonePe payment transaction via backend API.
  /// The server generates the payment payload, checksum, and provides SDK config.
  /// Returns true if payment succeeded, false otherwise.
  static Future<bool> startPhonePePayment({
    required int packageId,
    required int coins,
    required int priceInr,
  }) async {
    try {
      // 1. Get farmer_id from secure storage
      final farmerId = await _storage.read(key: 'id');
      if (farmerId == null) {
        debugPrint('PhonePe Payment aborted — farmer_id not found in storage');
        return false;
      }

      // 2. Call backend to create payment
      debugPrint('PhonePe: Calling create-coin-payment API (farmer: $farmerId, package: $packageId)');
      final createUrl = Uri.parse('${Constants.AppConstants.apiUrl}createcoinpayment');
      final createResp = await http.post(
        createUrl,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'farmer_id': farmerId,
          'package_id': packageId,
        }),
      ).timeout(const Duration(seconds: 15));

      debugPrint('PhonePe: Create API status: ${createResp.statusCode}');
      debugPrint('PhonePe: Create API response: ${createResp.body}');

      if (createResp.statusCode != 200) {
        debugPrint('PhonePe: Create payment API returned status ${createResp.statusCode}');
        return false;
      }

      final createData = jsonDecode(createResp.body);
      if (createData['success'] != true) {
        debugPrint('PhonePe: Create payment API returned success=false: ${createData['message']}');
        return false;
      }

      final paymentData = createData['data'] ?? createData;
      final String body = paymentData['body'];
      final String checksum = paymentData['checksum'] ?? '';
      final String merchantId = paymentData['merchant_id'];
      final String? appId = paymentData['app_id'];
      final String environment = paymentData['environment'];
      final String transactionId = paymentData['transaction_id'];

      // 3. Init SDK with server-provided config
      await initPhonePeSdk(
        environment: environment,
        merchantId: merchantId,
        appId: appId,
      );

      if (!_sdkInitialized) {
        debugPrint('PhonePe Payment aborted — SDK not initialized');
        return false;
      }

      // 4. Start PhonePe transaction
      debugPrint('PhonePe: Starting transaction $transactionId for ₹$priceInr');

      // Use Completer since PhonePe SDK await may not resolve properly
      final completer = Completer<bool>();

      PhonePePaymentSdk.startTransaction(
        body,
        '', // appSchema
        checksum,
        _packageName,
      ).then((response) async {
        debugPrint('PhonePe SDK Raw Response: $response');
        debugPrint('PhonePe SDK Response Type: ${response.runtimeType}');

        // Parse status from response
        String status = '';
        if (response != null) {
          final dynamic rawResponse = response;
          if (rawResponse is Map) {
            status = rawResponse['status']?.toString() ?? '';
          } else if (rawResponse is String) {
            try {
              final parsed = jsonDecode(rawResponse);
              status = parsed['status']?.toString() ?? '';
            } catch (_) {
              status = rawResponse;
            }
          }
        }

        debugPrint('PhonePe: Parsed status = "$status"');

        if (status.toUpperCase() == 'SUCCESS') {
          debugPrint('PhonePe: SDK returned SUCCESS, verifying on server...');
          final verified = await _verifyPaymentOnServer(transactionId);
          if (verified) {
            await _addPurchaseRecord(
              coins: coins,
              priceInr: priceInr,
              transactionId: transactionId,
              status: 'SUCCESS',
            );
            completer.complete(true);
          } else {
            debugPrint('PhonePe: Transaction $transactionId — server verification failed');
            await _addPurchaseRecord(
              coins: coins,
              priceInr: priceInr,
              transactionId: transactionId,
              status: 'FAILED',
            );
            completer.complete(false);
          }
        } else {
          debugPrint('PhonePe: Transaction $transactionId ended with status: $status');
          await _addPurchaseRecord(
            coins: coins,
            priceInr: priceInr,
            transactionId: transactionId,
            status: status.isNotEmpty ? status : 'UNKNOWN',
          );
          completer.complete(false);
        }
      }).catchError((error) {
        debugPrint('PhonePe SDK Error: $error');
        completer.complete(false);
      });

      return await completer.future;
    } catch (e) {
      debugPrint('PhonePe Payment Error: $e');
      return false;
    }
  }

  /// Verify payment via backend API.
  /// The server checks PhonePe Status API and credits coins to the farmer.
  /// Returns true if verified and coins credited successfully.
  static Future<bool> _verifyPaymentOnServer(String transactionId) async {
    try {
      debugPrint('PhonePe: Verifying transaction $transactionId on server...');
      final url = Uri.parse('${Constants.AppConstants.apiUrl}verifycoinpayment');
      final resp = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'transaction_id': transactionId}),
      ).timeout(const Duration(seconds: 20));

      debugPrint('PhonePe: Verify API status: ${resp.statusCode}');
      debugPrint('PhonePe: Verify API response: ${resp.body}');

      if (resp.statusCode == 200) {
        final data = jsonDecode(resp.body);
        if (data['success'] == true) {
          // Server credited coins — update local balance from server response
          final newBalance = data['data']?['new_balance'];
          if (newBalance != null) {
            await setCoins(int.tryParse(newBalance.toString()) ?? await getCoins());
          }
          // Fetch and sync the official balance using the farmer's ID
          final farmerId = await _storage.read(key: 'id');
          if (farmerId != null) {
            await fetchCoinBalanceFromServer(farmerId);
          }
          debugPrint('PhonePe: Transaction $transactionId verified successfully. New balance: $newBalance');
          return true;
        }
      }
      return false;
    } catch (e) {
      debugPrint('Error verifying payment on server: $e');
      return false;
    }
  }

  // ── UI Helpers ────────────────────────────────────────────────────────

  /// Build the wallet icon button for the AppBar.
  static Widget buildWalletButton({
    required int coinBalance,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 4),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppColors.amberNotice, AppColors.amberNotice],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppColors.amberNotice.withValues(alpha: 0.4),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.monetization_on, color: Colors.white, size: 16),
            const SizedBox(width: 3),
            Text(
              coinBalance.toString(),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Show the Coin Shop bottom sheet.
  static void showCoinShop(BuildContext context, {required Function(int) onCoinsAdded}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return _CoinShopSheet(
          onCoinsAdded: onCoinsAdded,
        );
      },
    );
  }

  /// Show the unlock-contact confirmation dialog.
  static Future<bool> showUnlockDialog(
    BuildContext context, {
    required String contactId,
    required VoidCallback onInsufficientFunds,
  }) async {
    bool unlocked = false;
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.buttonBg,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.lock_open, color: AppColors.amberNotice, size: 24),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Unlock Contact',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
          content: RichText(
            text: TextSpan(
              style: const TextStyle(fontSize: 15, color: AppColors.ink, height: 1.5),
              children: [
                const TextSpan(text: 'To see the full mobile number, '),
                TextSpan(
                  text: '$_unlockCost coins',
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    color: AppColors.amberNotice,
                  ),
                ),
                const TextSpan(text: ' will be debited.\n\nDo you want to proceed?'),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(
                'No',
                style: TextStyle(color: AppColors.inkSoft, fontWeight: FontWeight.w600),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Constants.AppColors.button,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () async {
                bool success = await deductCoins(_unlockCost);
                if (success) {
                  await markContactUnlocked(contactId);
                  unlocked = true;
                  if (ctx.mounted) Navigator.pop(ctx);
                } else {
                  if (ctx.mounted) Navigator.pop(ctx);
                  onInsufficientFunds();
                }
              },
              child: const Text('Yes, Unlock'),
            ),
          ],
        );
      },
    );
    return unlocked;
  }

  /// Show an "Insufficient Coins" alert with option to buy coins.
  static void showInsufficientFundsDialog(BuildContext context, {required VoidCallback onBuyCoins}) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: AppColors.button, size: 28),
              SizedBox(width: 10),
              Text(
                'Insufficient Coins',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
              ),
            ],
          ),
          content: const Text(
            'You do not have enough coins to unlock this contact. Please buy more coins.',
            style: TextStyle(fontSize: 14, height: 1.5),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(
                'Cancel',
                style: TextStyle(color: AppColors.inkSoft),
              ),
            ),
            ElevatedButton.icon(
              icon: const Icon(Icons.shopping_cart, size: 18),
              label: const Text('Buy Coins'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.amberNotice,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () {
                Navigator.pop(ctx);
                onBuyCoins();
              },
            ),
          ],
        );
      },
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════
// Private Coin Shop Bottom Sheet Widget (with PhonePe + Purchase History)
// ═══════════════════════════════════════════════════════════════════════

class _CoinShopSheet extends StatefulWidget {
  final Function(int) onCoinsAdded;

  const _CoinShopSheet({required this.onCoinsAdded});

  @override
  State<_CoinShopSheet> createState() => _CoinShopSheetState();
}

class _CoinShopSheetState extends State<_CoinShopSheet> with SingleTickerProviderStateMixin {
  int _currentBalance = 0;
  int? _processingIndex;
  bool _showSuccess = false;
  int _addedCoins = 0;
  List<Map<String, dynamic>> _purchaseHistory = [];
  List<Map<String, dynamic>> _packages = [];
  bool _isLoadingPackages = true;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    int bal = await WalletHelper.getCoins();
    List<Map<String, dynamic>> history = await WalletHelper.getPurchaseHistory();
    List<Map<String, dynamic>> pkgs = await WalletHelper.getCoinPackages();

    if (mounted) {
      setState(() {
        _currentBalance = bal;
        _purchaseHistory = history;
        _packages = pkgs;
        _isLoadingPackages = false;
      });
    }
  }

  Future<void> _purchasePackage(int index) async {
    final pkg = _packages[index];
    final packageId = pkg['id'];
    final coins = int.tryParse(pkg['coins'].toString()) ?? 0;
    final price = int.tryParse(pkg['price'].toString()) ?? 0;

    if (packageId == null || packageId == 0) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Invalid package. Please try again later.'),
            backgroundColor: AppColors.button,
          ),
        );
      }
      return;
    }

    setState(() => _processingIndex = index);

    // Start PhonePe payment via server API
    bool success = await WalletHelper.startPhonePePayment(
      packageId: packageId,
      coins: coins,
      priceInr: price,
    );

    if (success) {
      int newBalance = await WalletHelper.getCoins();
      List<Map<String, dynamic>> history = await WalletHelper.getPurchaseHistory();

      setState(() {
        _processingIndex = null;
        _currentBalance = newBalance;
        _showSuccess = true;
        _addedCoins = coins;
        _purchaseHistory = history;
      });

      widget.onCoinsAdded(newBalance);

      // Auto-dismiss success after 2 seconds
      await Future.delayed(const Duration(seconds: 2));
      if (mounted) {
        setState(() => _showSuccess = false);
      }
    } else {
      setState(() => _processingIndex = null);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Payment failed or cancelled. Please try again.'),
            backgroundColor: AppColors.button,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.80,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          const SizedBox(height: 12),
          Container(
            width: 40, height: 4,
            decoration: BoxDecoration(
              color: AppColors.border,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),

          // Title + Balance
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.amberNotice, AppColors.amberNotice],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.account_balance_wallet, color: Colors.white, size: 24),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Coin Wallet',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
                    ),
                    Text(
                      'Balance: $_currentBalance coins',
                      style: TextStyle(fontSize: 14, color: AppColors.inkSoft),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // Success banner
          if (_showSuccess)
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.brandTint,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.brand),
              ),
              child: Row(
                children: [
                  const Icon(Icons.check_circle, color: AppColors.brand, size: 24),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      '$_addedCoins coins added successfully!',
                      style: const TextStyle(
                        color: AppColors.brandDeep,
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),

          const SizedBox(height: 4),

          // Tab Bar (Buy Coins / Purchase History)
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              color: AppColors.surface2,
              borderRadius: BorderRadius.circular(12),
            ),
            child: TabBar(
              controller: _tabController,
              indicator: BoxDecoration(
                color: Constants.AppColors.brand,
                borderRadius: BorderRadius.circular(12),
              ),
              indicatorSize: TabBarIndicatorSize.tab,
              labelColor: Colors.white,
              unselectedLabelColor: AppColors.inkSoft,
              labelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
              unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
              dividerColor: Colors.transparent,
              tabs: const [
                Tab(text: 'Buy Coins'),
                Tab(text: 'Purchase History'),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // Tab views
          Flexible(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildBuyCoinsTab(),
                _buildHistoryTab(),
              ],
            ),
          ),

          // PhonePe branding
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.security, size: 14, color: AppColors.inkSoft),
                const SizedBox(width: 4),
                Text(
                  'Powered by PhonePe (Sandbox)',
                  style: TextStyle(fontSize: 11, color: AppColors.inkSoft),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBuyCoinsTab() {
    if (_isLoadingPackages) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(40.0),
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.amberNotice),
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: _packages.length,
      itemBuilder: (context, index) {
        final pkg = _packages[index];
        final coins = int.tryParse(pkg['coins'].toString()) ?? 0;
        final price = int.tryParse(pkg['price'].toString()) ?? 0;
        final name = pkg['name']?.toString() ?? 'Package';
        final isProcessing = _processingIndex == index;

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(16),
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: isProcessing || _processingIndex != null
                  ? null
                  : () => _purchasePackage(index),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    // Coin icon
                    Container(
                      width: 48, height: 48,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppColors.amberNotice, AppColors.amberNotice],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(
                          '$coins',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name.isNotEmpty ? '$name ($coins Coins)' : '$coins Coins',
                            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Add $coins coins to your wallet',
                            style: TextStyle(color: AppColors.inkSoft, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                    // Price / loading
                    isProcessing
                        ? const SizedBox(
                            width: 24, height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(AppColors.amberNotice),
                            ),
                          )
                        : Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [AppColors.brand, AppColors.brand],
                              ),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              '₹$price',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                                fontSize: 14,
                              ),
                            ),
                          ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHistoryTab() {
    if (_purchaseHistory.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.receipt_long, size: 56, color: AppColors.border),
              const SizedBox(height: 12),
              Text(
                'No purchases yet',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.inkSoft,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Your coin purchase history will appear here',
                style: TextStyle(fontSize: 13, color: AppColors.inkSoft),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: _purchaseHistory.length,
      itemBuilder: (context, index) {
        final record = _purchaseHistory[index];
        final coins = record['coins'] ?? 0;
        final price = record['price'] ?? 0;
        final txnId = record['transactionId'] ?? '';
        final status = record['status'] ?? 'Unknown';
        final dateStr = record['date'] ?? '';

        // Parse date
        String formattedDate = '';
        try {
          final dt = DateTime.parse(dateStr);
          formattedDate = '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
        } catch (_) {
          formattedDate = dateStr;
        }

        final isSuccess = status.toString().toUpperCase().contains('SUCCESS');

        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              // Status icon
              Container(
                width: 40, height: 40,
                decoration: BoxDecoration(
                  color: isSuccess
                      ? AppColors.brandTint
                      : AppColors.buttonBg,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  isSuccess ? Icons.check_circle : Icons.cancel,
                  color: isSuccess ? AppColors.brand : Colors.red,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '+$coins Coins',
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '₹$price • $formattedDate',
                      style: TextStyle(fontSize: 12, color: AppColors.inkSoft),
                    ),
                    Text(
                      'ID: ${txnId.length > 20 ? '${txnId.substring(0, 20)}...' : txnId}',
                      style: TextStyle(fontSize: 10, color: AppColors.inkSoft),
                    ),
                  ],
                ),
              ),
              // Status badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isSuccess
                      ? AppColors.brandTint
                      : AppColors.buttonBg,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  isSuccess ? 'Success' : 'Failed',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: isSuccess ? AppColors.brand : Colors.red,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}


