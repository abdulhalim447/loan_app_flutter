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

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:file_picker/file_picker.dart';

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

            selfieWithIdImage = jsonResponse['selfie'] != null
                ? XFile(jsonResponse['selfie'])
                : null;
            frontIdImage = jsonResponse['nidFrontImage'] != null
                ? XFile(jsonResponse['nidFrontImage'])
                : null;
            backIdImage = jsonResponse['nidBackImage'] != null
                ? XFile(jsonResponse['nidBackImage'])
                : null;

            _signatureUrl = jsonResponse['signature'] ?? '';
          });
        } else {
          setState(() {
            _isFormDisabled = false;
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

  Future<void> _submitForm() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _isLoading = true;
      });

      var uri = Uri.parse('https://wbli.org/api/verify');
      String? token = await UserSession.getToken();

      final signatureImage = await _getSignatureImage();

      final frontImage = await http.MultipartFile.fromPath(
          'nidFrontImage', frontIdImage!.path);
      final backImage =
      await http.MultipartFile.fromPath('nidBackImage', backIdImage!.path);
      final selfieImage = selfieWithIdImage != null &&
          File(selfieWithIdImage!.path).existsSync()
          ? await http.MultipartFile.fromPath('selfie', selfieWithIdImage!.path)
          : null;

      if (selfieImage == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Selfie image not available or invalid')),
        );
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
        ..fields['income'] = monthyIncomController.text
        ..files.add(frontImage)
        ..files.add(backImage)
        ..files.add(selfieImage)
        ..files.add(signatureMultipart);

      try {
        var response = await request.send();
        var responseBody = await response.stream.bytesToString();
        if (response.statusCode == 200) {
          Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (context) => BankAccountScreen()));
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

  Future<Uint8List> _getSignatureImage() async {
    final ui.Image? image = await _signatureController.toImage();
    final byteData = await image!.toByteData(format: ui.ImageByteFormat.png);
    return byteData!.buffer.asUint8List();
  }

  @override
  void initState() {
    super.initState();
    _checkStatus();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: Text('Personal Information'),
      ),
      body: Center(
        child: Container(
          width: screenWidth > 600 ? 600 : screenWidth,
          child: SingleChildScrollView(
            padding: EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle('Your Information'),

                  _buildTextField('Name', nameController),
                  SizedBox(height: 10),
                  _buildTextField('Current Address', currentAddressController),
                  SizedBox(height: 10),
                  _buildTextField('Permanent Address', permanentAddressController),
                  SizedBox(height: 10),
                  _buildTextField('Profession', professionController),
                  SizedBox(height: 10),
                  _buildTextField('Monthly Income', monthyIncomController),
                  SizedBox(height: 10),
                  _buildTextField('Purpose of Loan', loanPurposeController),
                  SizedBox(height: 10),
                  _buildSectionTitle('Nominee Information'),
                  SizedBox(height: 10),
                  _buildTextField('Nominee Name', nomineeNameController),
                  SizedBox(height: 10),
                  _buildTextField('Relation', nomineeRelationController),
                  SizedBox(height: 10),
                  _buildTextField('Nominee Mobile Number', nomineePhoneController),
                  SizedBox(height: 10),
                  _buildSectionTitle('Image Collection'),
                  SizedBox(height: 10),
                  _buildTextField('NID Name', nidNameController),
                  SizedBox(height: 10),
                  _buildTextField('NID Number', idController),
                  SizedBox(height: 10),
                  _buildImageUploadField('Front Side of Your ID Card',
                          () => _pickImage('front'), frontIdImage),
                  SizedBox(height: 10),
                  _buildImageUploadField('Back Side of Your ID Card',
                          () => _pickImage('back'), backIdImage),
                  SizedBox(height: 10),
                  _buildImageUploadField('Selfie with Your ID Card',
                          () => _pickImage('selfie'), selfieWithIdImage),
                  SizedBox(height: 10),
                  _buildSignatureField('Sign in the box below'),
                  if (_isLoading) Center(child: CircularProgressIndicator()),
                  SizedBox(height: 10),
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
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
      enabled: !_isFormDisabled,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please fill out this field';
        }
        return null;
      },
    );
  }

/*  Widget _buildImageUploadField(
      String label, VoidCallback onTap, XFile? imageFile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 16)),
        GestureDetector(
          onTap: onTap,
          child: Container(
            height: 150,
            width: double.infinity,
            color: Colors.grey[300],
            child: imageFile == null
                ? Icon(Icons.add_photo_alternate, size: 50)
                : Image.file(File(imageFile.path), fit: BoxFit.cover),
          ),
        ),
      ],
    );
  }*/

  Widget _buildSignatureField(String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 16)),
        Container(
          height: 150,
          decoration: BoxDecoration(border: Border.all(color: Colors.grey)),
          child: _isFormDisabled && _signatureUrl.isNotEmpty
              ? Image.network(_signatureUrl, fit: BoxFit.contain)
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
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isFormDisabled ? null : _submitForm,
        child: Text('Save'),
      ),
    );
  }


  Future<void> _pickImage(String type) async {
    if (kIsWeb) {
      // ওয়েবের জন্য ফাইল সিলেকশন
      final result = await FilePicker.platform.pickFiles(type: FileType.image);

      if (result != null && result.files.first.bytes != null) {
        Uint8List? webImageBytes = result.files.first.bytes;

        setState(() {
          if (type == 'front') {
            frontIdImage = XFile.fromData(webImageBytes!, name: result.files.first.name);
          } else if (type == 'back') {
            backIdImage = XFile.fromData(webImageBytes!, name: result.files.first.name);
          } else if (type == 'selfie') {
            selfieWithIdImage = XFile.fromData(webImageBytes!, name: result.files.first.name);
          }
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('No image selected. Please try again.')),
        );
      }
    } else {
      // মোবাইলের জন্য ফাইল সিলেকশন
      final pickedFile = await _picker.pickImage(source: ImageSource.gallery);

      if (pickedFile == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('No valid image selected. Please try again.')),
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
  }

  Widget _buildImageUploadField(
      String label, VoidCallback onTap, XFile? imageFile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 16)),
        GestureDetector(
          onTap: onTap,
          child: Container(
            height: 150,
            width: double.infinity,
            color: Colors.grey[300],
            child: imageFile == null
                ? Icon(Icons.add_photo_alternate, size: 50)
                : (kIsWeb
                ? FutureBuilder<Uint8List>(
              future: _getImageBytes(imageFile),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Icon(Icons.error));
                } else {
                  return Image.memory(
                    snapshot.data!,
                    fit: BoxFit.cover,
                  );
                }
              },
            )
                : Image.file(
              File(imageFile.path),
              fit: BoxFit.cover,
            )),
          ),
        ),
      ],
    );
  }

  Future<Uint8List> _getImageBytes(XFile file) async {
    if (kIsWeb) {
      return await file.readAsBytes();
    } else {
      return File(file.path).readAsBytesSync();
    }
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


}


