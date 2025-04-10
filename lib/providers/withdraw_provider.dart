import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import '../auth/saved_login/user_session.dart';
import 'package:world_bank_loan/core/api/api_endpoints.dart';

enum WithdrawLoadingStatus {
  initial,
  loading,
  loaded,
  error,
  uploading,
  success
}

class WithdrawProvider extends ChangeNotifier {
  WithdrawLoadingStatus _loadingStatus = WithdrawLoadingStatus.initial;
  String _balance = "0";
  String _loan = "0";
  String _bankName = "N/A";
  String _account = "N/A";
  String _bankUser = "N/A";
  String _message = "Not provided";
  String _fee = "0";
  String _ifc = "N/A";
  String _adminBankName = "N/A";
  String _adminAccountName = "N/A";
  String _adminAccountNumber = "N/A";
  final String _adminIfc = "N/A";
  final String _adminUpi = "N/A";
  String _bkashNumber = "N/A";
  String _nagadNumber = "N/A";
  File? _image;
  String _errorMessage = '';
  final ImagePicker _picker = ImagePicker();

  // Getters
  WithdrawLoadingStatus get loadingStatus => _loadingStatus;
  String get balance => _balance;
  String get loan => _loan;
  String get bankName => _bankName;
  String get account => _account;
  String get bankUser => _bankUser;
  String get message => _message;
  String get fee => _fee;
  String get ifc => _ifc;
  String get adminBankName => _adminBankName;
  String get adminAccountName => _adminAccountName;
  String get adminAccountNumber => _adminAccountNumber;
  String get adminIfc => _adminIfc;
  String get adminUpi => _adminUpi;
  String get bkashNumber => _bkashNumber;
  String get nagadNumber => _nagadNumber;
  File? get image => _image;
  String get errorMessage => _errorMessage;
  bool get isLoading => _loadingStatus == WithdrawLoadingStatus.loading;
  bool get hasError => _loadingStatus == WithdrawLoadingStatus.error;
  bool get isUploading => _loadingStatus == WithdrawLoadingStatus.uploading;
  bool get isSuccess => _loadingStatus == WithdrawLoadingStatus.success;

  // Initialize provider
  Future<void> initialize() async {
    await fetchWithdrawDetails();
  }

  // Fetch withdraw details from API
  Future<void> fetchWithdrawDetails() async {
    _loadingStatus = WithdrawLoadingStatus.loading;
    _errorMessage = '';
    notifyListeners();

    try {
      String? token = await UserSession.getToken();
      if (token == null) {
        _setError('User not authenticated');
        return;
      }

      final response = await http.get(
        Uri.parse(ApiEndpoints.withdrawMethods),
        headers: {
          'Authorization': 'Bearer $token',
        },
      ).timeout(
        const Duration(seconds: 15),
        onTimeout: () => throw Exception('Connection timeout'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        try {
          // User Bank Info
          _balance = (data['userBankInfo']['balance'] ?? "0").toString();
          _loan = (data['userBankInfo']['loanBalance'] ?? "0").toString();
          _fee = (data['userBankInfo']['fee'] ?? "0").toString();
          _message = data['userBankInfo']['message'] ?? "";

          // Mobile payment options from adminBankInfo
          _bkashNumber = data['adminBankInfo']['bkash'] ?? "N/A";
          _nagadNumber = data['adminBankInfo']['nagad'] ?? "N/A";

          // Set dummy values for fields not in the API but used in UI
          _adminBankName = _bkashNumber;
          _adminAccountNumber = _nagadNumber;

          _bankName = data['userBankInfo']['bankName'] ?? "N/A";
          _account = data['userBankInfo']['accountNumber']?.toString() ?? "N/A";
          _bankUser = data['userBankInfo']['bankUserName'] ?? "N/A";
          _ifc = data['userBankInfo']['ifc'] ?? "N/A";

          _adminAccountName =
              data['adminBankInfo']['adminAccountName'] ?? "N/A";

          _loadingStatus = WithdrawLoadingStatus.loaded;
        } catch (e) {
          _setError('Failed to parse data: $e');
        }
      } else if (response.statusCode == 401) {
        _setError('Session expired. Please login again');
      } else if (response.statusCode == 422) {
        // Parse validation errors from the response
        try {
          final data = json.decode(response.body);
          if (data['message'] != null) {
            _setError('Validation error: ${data['message']}');
          } else if (data['errors'] != null) {
            // Extract first error message
            final firstError = data['errors'].values.first;
            if (firstError is List && firstError.isNotEmpty) {
              _setError('Validation error: ${firstError[0]}');
            } else {
              _setError('Validation error: Please check your submission');
            }
          } else {
            _setError('Invalid data submitted. Please check and try again.');
          }
        } catch (e) {
          _setError(
              'Invalid data submitted (422). Please check and try again.');
        }
      } else {
        _setError('Server error: ${response.statusCode}');
      }
    } catch (e) {
      _setError('Connection error: $e');
    }

    notifyListeners();
  }

  // Pick image from gallery
  Future<void> pickImage() async {
    final XFile? pickedFile =
        await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      _image = File(pickedFile.path);
      notifyListeners();
    }
  }

  // Submit image to server
  Future<void> submitImage() async {
    if (_image == null) {
      _setError('Please select an image');
      return;
    }

    _loadingStatus = WithdrawLoadingStatus.uploading;
    _errorMessage = '';
    notifyListeners();

    try {
      String? token = await UserSession.getToken();
      if (token == null) {
        _setError('User not authenticated');
        return;
      }

      var request = http.MultipartRequest(
        'POST',
        Uri.parse(ApiEndpoints.uploadScreenshot),
      );

      request.headers.addAll({
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      });

      request.files.add(
        await http.MultipartFile.fromPath(
          'image',
          _image!.path,
        ),
      );

      // Add required form fields
      request.fields['method'] = 'mobile_banking'; // Add payment method
      request.fields['transaction_id'] = 'MB${DateTime.now()
              .millisecondsSinceEpoch
              .toString()
              .substring(0, 8)}'; // Generated transaction ID
      request.fields['amount'] = _fee; // Add the fee amount

      var streamedResponse = await request.send().timeout(
            const Duration(seconds: 30),
            onTimeout: () => throw Exception('Upload timeout'),
          );
      var response = await http.Response.fromStream(streamedResponse);

      // Debug logging (remove in production)
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      // Enhance the debugging with more details
      // Debug logging (remove in production)
      print('========= API REQUEST DEBUG =========');
      print('URL: ${ApiEndpoints.uploadScreenshot}');
      print('Headers: ${request.headers}');
      print('Fields sent: ${request.fields}');
      print('Image path: ${_image?.path ?? "null"}');
      print('========= API RESPONSE DEBUG =========');
      print('Status: ${response.statusCode}');
      print('Body: ${response.body}');
      print('======================================');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          _loadingStatus = WithdrawLoadingStatus.success;
        } else {
          _setError(data['message'] ?? 'Failed to submit payment screenshot');
        }
      } else if (response.statusCode == 401) {
        _setError('Session expired. Please login again');
      } else {
        _setError('Server error: ${response.statusCode}');
      }
    } catch (e) {
      _setError('Connection error: $e');
    }

    notifyListeners();
  }

  // Reset state
  void reset() {
    _loadingStatus = WithdrawLoadingStatus.initial;
    _image = null;
    _errorMessage = '';
    notifyListeners();
  }

  // Set error state
  void _setError(String message) {
    _loadingStatus = WithdrawLoadingStatus.error;
    _errorMessage = message;
  }
}
