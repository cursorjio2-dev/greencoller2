import 'dart:convert';
import 'dart:developer' as developer;
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Helper class to format and log API calls.
class ApiLogger {
  static const Map<String, String> widgetToFileMap = {
    'AddProjectForm': 'lib/Addproject.dart',
    'FarmerDetailsPage': 'lib/FarmerDetails.dart',
    'HomePage': 'lib/HomeScree.dart',
    'CombinedPage': 'lib/HomeScree.dart',
    'LabourAnimated': 'lib/HomeScree.dart',
    'ProjectPage': 'lib/HomeScree.dart',
    'ProjectApplicationsPage': 'lib/HomeScree.dart',
    'FarmerPage': 'lib/NearbyFarmers.dart',
    'NearbyProjectPage': 'lib/NearbyProject.dart',
    'ProjectDetailsPage': 'lib/NearbyProject.dart',
    'AppliedProjects': 'lib/NearbyProject.dart',
    'LabourPage': 'lib/Nearbylabours.dart',
    'AnimatedCard': 'lib/Nearbylabours.dart',
    'ProjectDetails': 'lib/ProjectDetails.dart',
    'UpdateProject': 'lib/UpdateProject.dart',
    'ApplicationDetailPage': 'lib/application_detaill.dart',
    'Labourhomepage': 'lib/labourhomepage.dart',
    'LabourHomepage': 'lib/labourhomepage.dart',
    'LabourNotification': 'lib/labournoti.dart',
    'SplashScreen': 'lib/main.dart',
    'LanguageSelectionScreen': 'lib/main.dart',
    'LoginScreen': 'lib/main.dart',
    'NotificationsPage': 'lib/noti.dart',
    'MyWebView': 'lib/privacypolicy.dart',
    'RegistrationForm': 'lib/register.dart',
    'UpdateLabourProfile': 'lib/updateprofile.dart',
    'LabourDetailsPage': 'lib/workerdetails.dart',
  };

  static void logScreenOpened(String screenName, {String action = 'Opened'}) {
    // Map screen/route name to the actual dart file path
    String filePath = 'Unknown File';
    if (screenName == '/') {
      screenName = 'SplashScreen';
      filePath = 'lib/main.dart';
    } else {
      filePath = widgetToFileMap[screenName] ?? 'Unknown File';
    }

    developer.log(
      '📺 SCREEN OPENED: $screenName (File: $filePath) ($action)',
      name: 'SCREEN_LOGGER',
      time: DateTime.now(),
    );
  }

  /// The single debug function used for all APIs in the project.
  /// Logs the full path, parameters/headers/body, and the complete response body.
  static void logApi({
    required String method,
    required String url,
    required Map<String, String> headers,
    required String body,
    required int statusCode,
    required String responseBody,
    required Duration duration,
  }) {
    final buffer = StringBuffer();
    buffer.writeln('==================== API CALL ====================');
    buffer.writeln('Method      : $method');
    buffer.writeln('URL         : $url');
    buffer.writeln('Duration    : ${duration.inMilliseconds} ms');
    buffer.writeln('Status Code : $statusCode');
    
    // Extract Bearer token from headers
    String? bearerToken;
    headers.forEach((key, value) {
      if (key.toLowerCase() == 'authorization') {
        bearerToken = value;
      } else if (value.toLowerCase().startsWith('bearer ')) {
        bearerToken = value;
      } else if (key.toLowerCase().contains('token')) {
        bearerToken = value;
      }
    });

    if (bearerToken != null) {
      buffer.writeln('Bearer Token: $bearerToken');
    } else {
      buffer.writeln('Bearer Token: None');
    }

    buffer.writeln('-------------------- Request Body ----------------');
    if (body.isEmpty) {
      buffer.writeln('Empty');
    } else {
      buffer.writeln(body);
    }

    buffer.writeln('-------------------- Response Body ---------------');
    if (responseBody.isEmpty) {
      buffer.writeln('Empty');
    } else {
      buffer.writeln(responseBody);
    }
    buffer.writeln('==================================================');

    // Use developer.log so that long JSON payloads are not truncated by standard console print
    developer.log(
      buffer.toString(),
      name: 'API_LOGGER',
      time: DateTime.now(),
    );
  }
}

/// Custom HTTP Client wrapper that intercepts all requests/responses
/// and logs them through [ApiLogger].
class LoggingHttpClient extends http.BaseClient {
  final http.Client _inner;

  LoggingHttpClient(this._inner);

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    final startTime = DateTime.now();

    // Read and inject Bearer token if not already present
    if (!request.headers.containsKey('Authorization')) {
      const secureStorage = FlutterSecureStorage();
      final token = await secureStorage.read(key: 'token');
      if (token != null && token.isNotEmpty) {
        String tokenVal = token;
        if (tokenVal.toLowerCase().startsWith('bearer ')) {
          tokenVal = tokenVal.substring(7).trim();
        }
        request.headers['Authorization'] = 'Bearer $tokenVal';
      }
    }

    // Extract request body/parameters
    String requestBody = '';
    if (request is http.Request) {
      requestBody = request.body;
    } else if (request is http.MultipartRequest) {
      final fieldsStr = request.fields.entries.map((e) => '${e.key}: ${e.value}').join(', ');
      final filesStr = request.files.map((f) => '${f.field} (${f.filename}, ${f.length} bytes)').join(', ');
      requestBody = 'Fields: {$fieldsStr}\nFiles: [$filesStr]';
    }

    try {
      final response = await _inner.send(request);
      final duration = DateTime.now().difference(startTime);

      // Read response stream bytes without consuming them forever
      final bytes = await response.stream.toBytes();
      
      // Attempt to decode the response body
      String responseBody;
      try {
        responseBody = utf8.decode(bytes);
      } catch (_) {
        try {
          responseBody = String.fromCharCodes(bytes);
        } catch (_) {
          responseBody = '<binary data: ${bytes.length} bytes>';
        }
      }

      // Format and print the logs
      ApiLogger.logApi(
        method: request.method,
        url: request.url.toString(),
        headers: request.headers,
        body: requestBody,
        statusCode: response.statusCode,
        responseBody: responseBody,
        duration: duration,
      );

      // Re-create StreamedResponse with the read bytes
      return http.StreamedResponse(
        Stream.value(bytes),
        response.statusCode,
        contentLength: response.contentLength,
        request: response.request,
        headers: response.headers,
        isRedirect: response.isRedirect,
        persistentConnection: response.persistentConnection,
        reasonPhrase: response.reasonPhrase,
      );
    } catch (e, stackTrace) {
      final duration = DateTime.now().difference(startTime);
      final buffer = StringBuffer();
      buffer.writeln('==================== API CALL FAILED =============');
      buffer.writeln('Method      : ${request.method}');
      buffer.writeln('URL         : ${request.url}');
      buffer.writeln('Duration    : ${duration.inMilliseconds} ms');
      buffer.writeln('Error       : $e');
      // Extract Bearer token from headers
      String? bearerToken;
      request.headers.forEach((key, value) {
        if (key.toLowerCase() == 'authorization') {
          bearerToken = value;
        } else if (value.toLowerCase().startsWith('bearer ')) {
          bearerToken = value;
        } else if (key.toLowerCase().contains('token')) {
          bearerToken = value;
        }
      });

      if (bearerToken != null) {
        buffer.writeln('Bearer Token: $bearerToken');
      } else {
        buffer.writeln('Bearer Token: None');
      }
      buffer.writeln('-------------------- Request Body ----------------');
      buffer.writeln(requestBody);
      buffer.writeln('==================================================');

      developer.log(
        buffer.toString(),
        name: 'API_LOGGER',
        error: e,
        stackTrace: stackTrace,
        time: DateTime.now(),
      );
      rethrow;
    }
  }
}

/// Navigator observer to track and log when screens are opened.
class ScreenObserver extends NavigatorObserver {
  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    _logRoute(route, 'Opened');
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    if (newRoute != null) {
      _logRoute(newRoute, 'Opened (Replacement)');
    }
  }

  void _logRoute(Route<dynamic> route, String action) {
    String? screenName = route.settings.name;
    
    // If name is null, check if it's a MaterialPageRoute and resolve the widget type
    if (screenName == null && route is MaterialPageRoute) {
      try {
        final context = navigator?.context;
        if (context != null) {
          final widget = route.builder(context);
          screenName = widget.runtimeType.toString();
        }
      } catch (_) {
        // Fallback
      }
    }
    
    screenName ??= route.settings.name ?? route.runtimeType.toString();

    ApiLogger.logScreenOpened(screenName, action: action);
  }
}
