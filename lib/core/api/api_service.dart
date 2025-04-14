import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:world_bank_loan/core/api/api_endpoints.dart';
import 'package:world_bank_loan/auth/saved_login/user_session.dart';
import 'package:http_parser/http_parser.dart';

class ApiResponse<T> {
  final bool success;
  final String message;
  final T? data;
  final int statusCode;

  ApiResponse({
    required this.success,
    required this.message,
    this.data,
    required this.statusCode,
  });

  factory ApiResponse.fromJson(
      Map<String, dynamic> json, T? Function(dynamic)? dataParser) {
    // Check if success is explicitly defined or infer from status code or message
    final isSuccess = json['success'] ??
        (json['status'] == 1 ||
            json['status'] == true ||
            json['message']?.toString().toLowerCase().contains('success') ==
                true);

    // Get the message
    final message = json['message'] ?? 'Unknown response';

    // For data extraction, try different approaches:
    // 1. If 'data' field exists, use that
    // 2. If 'user' field exists, consider the whole json as data
    // 3. If neither exists but there are meaningful fields, use the whole json
    dynamic dataToProcess;
    if (json.containsKey('data') && json['data'] != null) {
      dataToProcess = json['data'];
    } else if (json.containsKey('user') ||
        (json.keys.length > 2 &&
            !json.keys.every((k) =>
                ['success', 'message', 'status', 'statusCode'].contains(k)))) {
      dataToProcess = json;
    }

    final data = dataToProcess != null && dataParser != null
        ? dataParser(dataToProcess)
        : null;

    return ApiResponse(
      success: isSuccess,
      message: message,
      data: data,
      statusCode: json['statusCode'] ?? 200,
    );
  }

  factory ApiResponse.error(String message, {int statusCode = 500}) {
    return ApiResponse(
      success: false,
      message: message,
      data: null,
      statusCode: statusCode,
    );
  }
}

class ApiService {
  final http.Client _client = http.Client();

  // Get authentication token using UserSession
  Future<String?> _getAuthToken() async {
    try {
      return await UserSession.getToken();
    } catch (e) {
      if (kDebugMode) {
        print('Error getting auth token: $e');
      }
      return null;
    }
  }

  // Add auth headers if token is available
  Future<Map<String, String>> _getAuthHeaders() async {
    final token = await _getAuthToken();
    final headers = <String, String>{};

    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
      headers['Content-Type'] = 'application/json';
    }

    return headers;
  }

  // GET request
  Future<ApiResponse<T>> get<T>(
    String url, {
    Map<String, String>? headers,
    T? Function(dynamic data)? dataParser,
  }) async {
    try {
      // Get authentication headers
      final authHeaders = await _getAuthHeaders();

      final response = await _client.get(
        Uri.parse(url),
        headers: {
          'Accept': 'application/json',
          ...authHeaders,
          ...?headers,
        },
      );

      return _handleResponse<T>(response, dataParser);
    } on SocketException {
      return ApiResponse.error('No internet connection');
    } catch (e) {
      if (kDebugMode) {
        print('GET Error: $e');
      }
      return ApiResponse.error('An error occurred: ${e.toString()}');
    }
  }

  // POST request
  Future<ApiResponse<T>> post<T>(
    String url, {
    Map<String, String>? headers,
    dynamic body,
    T? Function(dynamic data)? dataParser,
    Map<String, File>? files,
  }) async {
    try {
      // Get authentication headers
      final authHeaders = await _getAuthHeaders();

      if (files != null && files.isNotEmpty) {
        return await _multipartPost<T>(
          url,
          headers: {...authHeaders, ...?headers},
          body: body,
          files: files,
          dataParser: dataParser,
        );
      } else {
        final response = await _client.post(
          Uri.parse(url),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            ...authHeaders,
            ...?headers,
          },
          body: jsonEncode(body),
        );

        return _handleResponse<T>(response, dataParser);
      }
    } on SocketException {
      return ApiResponse.error('No internet connection');
    } catch (e) {
      if (kDebugMode) {
        print('POST Error: $e');
      }
      return ApiResponse.error('An error occurred: ${e.toString()}');
    }
  }

  // Multipart POST request for file uploads
  Future<ApiResponse<T>> _multipartPost<T>(
    String url, {
    Map<String, String>? headers,
    Map<String, dynamic>? body,
    required Map<String, File> files,
    T? Function(dynamic data)? dataParser,
  }) async {
    try {
      var request = http.MultipartRequest('POST', Uri.parse(url));

      // Get auth token for Authorization header
      final token = await _getAuthToken();

      // Add headers
      final requestHeaders = {
        'Accept': 'application/json',
        ...?headers,
      };

      // Add Authorization header if token exists
      if (token != null && token.isNotEmpty) {
        requestHeaders['Authorization'] = 'Bearer $token';
      }

      request.headers.addAll(requestHeaders);

      // Add fields
      if (body != null) {
        body.forEach((key, value) {
          request.fields[key] = value.toString();
        });
      }

      // Add files
      for (var entry in files.entries) {
        request.files.add(
          await http.MultipartFile.fromPath(
            entry.key,
            entry.value.path,
          ),
        );
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      return _handleResponse<T>(response, dataParser);
    } on SocketException {
      return ApiResponse.error('No internet connection');
    } catch (e) {
      if (kDebugMode) {
        print('Multipart POST Error: $e');
      }
      return ApiResponse.error('An error occurred: ${e.toString()}');
    }
  }

  // Handle HTTP response
  ApiResponse<T> _handleResponse<T>(
    http.Response response,
    T? Function(dynamic data)? dataParser,
  ) {
    try {
      final responseData = jsonDecode(response.body);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return ApiResponse.fromJson(responseData, dataParser);
      } else {
        return ApiResponse(
          success: false,
          message: responseData['message'] ?? 'Server error',
          data: null,
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print('Response handling error: $e');
      }
      return ApiResponse.error(
        'Failed to process response',
        statusCode: response.statusCode,
      );
    }
  }

  // Personal information submission
  Future<ApiResponse<Map<String, dynamic>>> submitPersonalInfo({
    required String name,
    required String loanPurpose,
    required String profession,
    required String nomineeRelation,
    required String nomineePhone,
    required String nomineeName,
    required File selfie,
    required File nidFrontImage,
    required File nidBackImage,
    required File signature,
    required String income,
    required String bankuserName,
    required String bankName,
    required String account,
    required String branchName,
    required String nidNumber,
    required String edu,
    required String currentAddress,
  }) async {
    try {
      // Prepare files
      final files = {
        'selfie': selfie,
        'nidFrontImage': nidFrontImage,
        'nidBackImage': nidBackImage,
        'signature': signature,
      };

      // Prepare form data fields
      final formData = {
        'name': name,
        'loanPurpose': loanPurpose,
        'profession': profession,
        'nomineeRelation': nomineeRelation,
        'nomineePhone': nomineePhone,
        'nomineeName': nomineeName,
        'income': income,
        'bankuserName': bankuserName,
        'bankName': bankName,
        'account': account,
        'branchName': branchName,
        'nidNumber': nidNumber,
        'edu': edu,
        'currentAddress': currentAddress,
      };

      return await _multipartPost<Map<String, dynamic>>(
        ApiEndpoints.personalInfoVerify,
        body: formData,
        files: files,
        dataParser: (data) => data as Map<String, dynamic>,
      );
    } catch (e) {
      if (kDebugMode) {
        print('Personal Info Submit Error: $e');
      }
      return ApiResponse.error(
          'Failed to submit personal information: ${e.toString()}');
    }
  }

  // For web platform - direct binary upload
  Future<ApiResponse<Map<String, dynamic>>> submitPersonalInfoWithImageBytes({
    required String name,
    required String loanPurpose,
    required String profession,
    required String nomineeRelation,
    required String nomineePhone,
    required String nomineeName,
    required Uint8List selfieBytes,
    required Uint8List nidFrontBytes,
    required Uint8List nidBackBytes,
    Uint8List? signatureBytes,
    required String income,
    required String bankuserName,
    required String bankName,
    required String account,
    required String branchName,
    required String nidNumber,
    required String edu,
    required String currentAddress,
  }) async {
    try {
      // Create MultipartRequest
      final token = await UserSession.getToken();
      if (token == null) {
        throw Exception('Authentication token is missing');
      }

      final uri = Uri.parse(ApiEndpoints.personalInfoVerify);
      final request = http.MultipartRequest('POST', uri);

      // Add headers
      request.headers.addAll({
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      });

      // Add form fields
      request.fields['name'] = name;
      request.fields['loanPurpose'] = loanPurpose;
      request.fields['profession'] = profession;
      request.fields['nomineeRelation'] = nomineeRelation;
      request.fields['nomineePhone'] = nomineePhone;
      request.fields['nomineeName'] = nomineeName;
      request.fields['income'] = income;
      request.fields['bankuserName'] = bankuserName;
      request.fields['bankName'] = bankName;
      request.fields['account'] = account;
      request.fields['branchName'] = branchName;
      request.fields['nidNumber'] = nidNumber;
      request.fields['edu'] = edu;
      request.fields['currentAddress'] = currentAddress;

      // Add binary file data
      request.files.add(http.MultipartFile.fromBytes(
        'selfie',
        selfieBytes,
        filename: 'selfie.jpg',
        contentType: MediaType('image', 'jpeg'),
      ));

      request.files.add(http.MultipartFile.fromBytes(
        'nidFrontImage',
        nidFrontBytes,
        filename: 'nid_front.jpg',
        contentType: MediaType('image', 'jpeg'),
      ));

      request.files.add(http.MultipartFile.fromBytes(
        'nidBackImage',
        nidBackBytes,
        filename: 'nid_back.jpg',
        contentType: MediaType('image', 'jpeg'),
      ));

      // Add signature if available
      if (signatureBytes != null) {
        request.files.add(http.MultipartFile.fromBytes(
          'signature',
          signatureBytes,
          filename: 'signature.png',
          contentType: MediaType('image', 'png'),
        ));
      }

      // Send request
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      // Process response
      if (response.statusCode == 200 || response.statusCode == 201) {
        final jsonResponse = jsonDecode(response.body);
        return ApiResponse(
          success: true,
          message: jsonResponse['message'] ??
              'Personal information submitted successfully',
          data: jsonResponse['data'] as Map<String, dynamic>,
          statusCode: response.statusCode,
        );
      } else {
        if (kDebugMode) {
          print('API Error (${response.statusCode}): ${response.body}');
        }
        final jsonResponse = jsonDecode(response.body);
        final message =
            jsonResponse['message'] ?? 'Failed to submit personal information';
        return ApiResponse(
          success: false,
          message: message,
          data: null,
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print('Personal Info Submit Error (Web): $e');
      }
      return ApiResponse.error(
          'Failed to submit personal information: ${e.toString()}');
    }
  }

  // Fetch personal information verification status and data
  Future<ApiResponse<Map<String, dynamic>>> fetchPersonalInfo() async {
    try {
      return await get<Map<String, dynamic>>(
        ApiEndpoints.getPersonalInfoVerify,
        dataParser: (data) => data as Map<String, dynamic>,
      );
    } catch (e) {
      if (kDebugMode) {
        print('Fetch Personal Info Error: $e');
      }
      return ApiResponse.error(
          'Failed to fetch personal information: ${e.toString()}');
    }
  }
}
