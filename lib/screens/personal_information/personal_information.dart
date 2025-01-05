import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:signature/signature.dart';
import 'package:http/http.dart' as http;
import 'package:world_bank_loan/screens/bank_account/bank_account.dart';
import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'dart:io';
import 'package:image/image.dart' as img;

import '../../auth/saved_login/user_session.dart';

class PersonalInfoScreen extends StatefulWidget {
  @override
  _PersonalInfoScreenState createState() => _PersonalInfoScreenState();
}

class _PersonalInfoScreenState extends State<PersonalInfoScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers for input fields
  final TextEditingController nameController = TextEditingController();
  final TextEditingController idController = TextEditingController();
  final TextEditingController nidNameController = TextEditingController();
  final TextEditingController monthyIncomController = TextEditingController();
  final TextEditingController currentAddressController =
      TextEditingController();
  final TextEditingController permanentAddressController =
      TextEditingController();
  final TextEditingController professionController = TextEditingController();
  final TextEditingController loanPurposeController = TextEditingController();
  final TextEditingController nomineeRelationController =
      TextEditingController();
  final TextEditingController nomineeNameController = TextEditingController();
  final TextEditingController nomineePhoneController = TextEditingController();

  // Signature and Image Pickers
  final SignatureController _signatureController = SignatureController();
  final ImagePicker _picker = ImagePicker();
  XFile? frontIdImage;
  XFile? backIdImage;
  XFile? selfieWithIdImage;
  bool _isLoading = false;
  bool _isFormDisabled = false; // To manage form's enable/disable state

  String _signatureUrl = "";

  // get Personal Information ==============================
  Future<void> _checkStatus() async {
    var uri = Uri.parse('https://wbli.org/api/getverified');
    String? token = await UserSession.getToken();

    try {
      var response = await http.get(
        uri,
        headers: {'Authorization': 'Bearer $token'},
      );



      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        if (jsonResponse['status'] > 0) {
          setState(() {
            _isFormDisabled = true;
            // Populate fields with data from the response
            nameController.text = jsonResponse['name'] ?? '';
            idController.text = jsonResponse['nidNumber'] ?? '';
            currentAddressController.text =
                jsonResponse['currentAddress'] ?? '';
            permanentAddressController.text =
                jsonResponse['permanentAddress'] ?? '';
            professionController.text = jsonResponse['profession'] ?? '';
            loanPurposeController.text = jsonResponse['loanPurpose'] ?? '';
            nomineeRelationController.text =
                jsonResponse['nomineeRelation'] ?? '';
            nomineeNameController.text = jsonResponse['nomineeName'] ?? '';
            nomineePhoneController.text = jsonResponse['nomineePhone'] ?? '';
            nidNameController.text = jsonResponse['nidName'] ?? '';
            monthyIncomController.text = jsonResponse['income'] ?? '';

            // Load image URLs into the image fields
            selfieWithIdImage = jsonResponse['selfie'] != null
                ? XFile(jsonResponse['selfie'])
                : null;
            frontIdImage = jsonResponse['nidFrontImage'] != null
                ? XFile(jsonResponse['nidFrontImage'])
                : null;
            backIdImage = jsonResponse['nidBackImage'] != null
                ? XFile(jsonResponse['nidBackImage'])
                : null;

            // Populate signature URL
            _signatureUrl = jsonResponse['signature'] ?? '';
          });
        } else {
          setState(() {
            _isFormDisabled = false; // Enable form if status is not 1
          });
        }
      } else {
        throw Exception('Failed to load status');
      }
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error occurred: $e')));
    }
  }

  Future<File> _convertImageToJpg(File file) async {
    final originalImage = img.decodeImage(file.readAsBytesSync());
    final jpgImage = img.encodeJpg(originalImage!);

    final convertedFile = File('${file.path.split('.').first}.jpg')
      ..writeAsBytesSync(jpgImage);
    return convertedFile;
  }

  // Submit Personal Information
  Future<void> _submitForm() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _isLoading = true;
      });

      var uri = Uri.parse('https://wbli.org/api/verify');
      String? token = await UserSession.getToken();

      // Convert signature to image
      final signatureImage = await _getSignatureImage();

      // Prepare files for web compatibility
      http.MultipartFile? frontImage;
      http.MultipartFile? backImage;
      http.MultipartFile? selfieImage;

      if (kIsWeb) {
        if (frontIdImage != null) {
          final frontBytes = await frontIdImage!.readAsBytes();
          frontImage = http.MultipartFile.fromBytes('nidFrontImage', frontBytes,
              filename: frontIdImage!.name);
        }
        if (backIdImage != null) {
          final backBytes = await backIdImage!.readAsBytes();
          backImage = http.MultipartFile.fromBytes('nidBackImage', backBytes,
              filename: backIdImage!.name);
        }
        if (selfieWithIdImage != null) {
          final selfieBytes = await selfieWithIdImage!.readAsBytes();
          selfieImage = http.MultipartFile.fromBytes('selfie', selfieBytes,
              filename: selfieWithIdImage!.name);
        }
      } else {
        if (frontIdImage != null) {
          frontImage = await http.MultipartFile.fromPath(
              'nidFrontImage', frontIdImage!.path);
        }
        if (backIdImage != null) {
          backImage = await http.MultipartFile.fromPath(
              'nidBackImage', backIdImage!.path);
        }
        if (selfieWithIdImage != null) {
          selfieImage = await http.MultipartFile.fromPath(
              'selfie', selfieWithIdImage!.path);
        }
      }

      if (selfieImage == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Selfie image not available or invalid')),
        );
        setState(() {
          _isLoading = false;
        });
        return;
      }

      final signatureMultipart = http.MultipartFile.fromBytes(
          'signature', signatureImage,
          filename: 'signature.png');

      var request = http.MultipartRequest('POST', uri)
        ..headers['Authorization'] = 'Bearer $token'
        ..fields['name'] = nameController.text
        ..fields['nidNumber'] = idController.text
        ..fields['currentAddress'] = currentAddressController.text
        ..fields['permanentAddress'] = permanentAddressController.text
        ..fields['loanPurpose'] = loanPurposeController.text
        ..fields['profession'] = professionController.text
        ..fields['nomineeRelation'] = nomineeRelationController.text
        ..fields['nomineeName'] = nomineeNameController.text
        ..fields['nomineePhone'] = nomineePhoneController.text
        ..fields['nidName'] = nidNameController.text
        ..fields['income'] = monthyIncomController.text;

      if (frontImage != null) request.files.add(frontImage);
      if (backImage != null) request.files.add(backImage);
      request.files.add(selfieImage);
      request.files.add(signatureMultipart);

      try {
        var response = await request.send();
        var responseBody = await response.stream.bytesToString();
        print(responseBody);

        if (response.statusCode == 200) {
          final jsonResponse = json.decode(responseBody);
          String message = jsonResponse['message'];

          Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (context) => BankAccountScreen()));

          // Show success message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(message)),
          );

          // Clear form fields
          _clearForm();
        } else {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text('Failed to submit data')));
        }
      } catch (e) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error occurred: $e')));
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _clearForm() {
    nameController.clear();
    idController.clear();
    currentAddressController.clear();
    permanentAddressController.clear();
    professionController.clear();
    loanPurposeController.clear();
    nomineeRelationController.clear();
    nomineeNameController.clear();
    nomineePhoneController.clear();
    monthyIncomController.clear();
    nidNameController.clear();
    setState(() {
      frontIdImage = null;
      backIdImage = null;
      selfieWithIdImage = null;
      _signatureController.clear();
    });
  }

  Future<Uint8List> _getSignatureImage() async {
    final ui.Image? image = await _signatureController.toImage();
    final byteData = await image!.toByteData(format: ui.ImageByteFormat.png);
    return byteData!.buffer.asUint8List();
  }


  Future<void> _pickImage(String type, ImageSource source) async {
    XFile? pickedFile;

    try {
      pickedFile = await _picker.pickImage(source: source);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('ইমেজ পিক করার সময় ত্রুটি: $e')),
      );
      return;
    }

    if (pickedFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('কোনো বৈধ ইমেজ নির্বাচন করা হয়নি। আবার চেষ্টা করুন।')),
      );
      return;
    }

    setState(() {
      if (type == 'front') {
        frontIdImage = pickedFile;
      } else if (type == 'back') {
        backIdImage = pickedFile;
      } else if (type == 'selfie') {
        selfieWithIdImage = pickedFile;
      }
    });


  }




  @override
  void dispose() {
    nameController.dispose();
    idController.dispose();
    currentAddressController.dispose();
    permanentAddressController.dispose();
    professionController.dispose();
    loanPurposeController.dispose();
    nomineeRelationController.dispose();
    nomineeNameController.dispose();
    nomineePhoneController.dispose();
    _signatureController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _checkStatus(); // Call _checkStatus immediately after screen creation
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Personal Information'),
      ),
      body: Center(
        // Center the content on larger screens
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 600),
          // Limit width to 600 pixels
          child: SingleChildScrollView(
            padding: EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle('Your Information'),
                  _buildTextField(' Name', nameController),
                  SizedBox(height: 8.0),
                  _buildTextField('Current Address', currentAddressController),
                  SizedBox(height: 8.0),
                  _buildTextField(
                      'Permanent Address', permanentAddressController),
                  SizedBox(height: 8.0),
                  _buildTextField('Profession', professionController),
                  SizedBox(height: 8.0),
                  _buildTextField('Monthly Income', monthyIncomController),
                  SizedBox(height: 8.0),
                  _buildTextField('Purpose of Loan', loanPurposeController),
                  SizedBox(height: 16.0),
                  _buildSectionTitle('Nominee Information'),
                  _buildTextField('Nominee Name', nomineeNameController),
                  SizedBox(height: 8.0),
                  _buildTextField('Relation', nomineeRelationController),
                  SizedBox(height: 8.0),
                  _buildTextField(
                      'Nominee Mobile Number', nomineePhoneController),
                  SizedBox(height: 16.0),
                  _buildSectionTitle('Image Collection'),
                  SizedBox(height: 8.0),
                  _buildTextField('NID Name', nidNameController),
                  SizedBox(height: 8.0),
                  _buildTextField('NID Number', idController),
                  SizedBox(height: 8.0),
                  _buildImageUploadField(
                      'Front Side of Your ID Card', 'front', frontIdImage),
                  _buildImageUploadField(
                      'Back Side of Your ID Card', 'back', backIdImage),
                  _buildImageUploadField(
                      'Selfie with Your ID Card', 'selfie', selfieWithIdImage),

                  SizedBox(height: 16.0),
                  _buildSignatureField('Sign in the box below'),
                  SizedBox(height: 16.0),
                  if (_isLoading) Center(child: CircularProgressIndicator()),
                  SizedBox(height: 16.0),
                  _buildSaveButton(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        title,
        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(),
      ),
      enabled: !_isFormDisabled, // Disable the field if form is disabled
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please fill out this field';
        }
        return null;
      },
    );
  }

  void _showImageSourceSelection(String type) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Select an option'),
          actions: <Widget>[
            TextButton(
              child: Text('Gallery'),
              onPressed: () {
                Navigator.of(context).pop();
                _pickImage(type, ImageSource.gallery);
              },
            ),
            TextButton(
              child: Text('Camera'),
              onPressed: () {
                Navigator.of(context).pop();
                _pickImage(type, ImageSource.camera);
              },
            ),
          ],
        );
      },
    );
  }


  Widget _buildImageUploadField(
      String label, String type, XFile? imageFile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 24)),
        SizedBox(height: 8.0),
        GestureDetector(
          onTap: () => _showImageSourceSelection(type),
          child: Container(
            height: 150,
            width: double.infinity,
            color: Colors.grey[300],
            child: imageFile == null
                ? Icon(Icons.add_photo_alternate, size: 50)
                : kIsWeb
                ? Image.network(imageFile.path, fit: BoxFit.cover)
                : Image.file(File(imageFile.path), fit: BoxFit.cover),
          ),
        ),
      ],
    );
  }




  Widget _buildSignatureField(String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 24)),
        SizedBox(height: 8.0),
        Container(
          height: 150,
          decoration: BoxDecoration(border: Border.all(color: Colors.grey)),
          child: _isFormDisabled && _signatureUrl.isNotEmpty
              ? Image.network(
                  _signatureUrl,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return Center(child: Text("Signature not found"));
                  },
                )
              : Signature(
                  controller: _signatureController,
                  backgroundColor: Colors.white,
                ),
        ),
        if (!_isFormDisabled)
          TextButton(
            onPressed: () {
              _signatureController.clear();
            },
            child: Text('Clear Signature'),
          ),
      ],
    );
  }

  Widget _buildSaveButton() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18.0),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: _isFormDisabled ? null : _submitForm,
          // Disable button if form is disabled
          child: Text('Save'),
        ),
      ),
    );
  }
}
