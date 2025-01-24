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

  //final TextEditingController phoneController = TextEditingController();
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
    var uri = Uri.parse('https://app.wbli.org/api/getverified');
    String? token = await UserSession.getToken();

    try {
      var response = await http.get(
        uri,
        headers: {'Authorization': 'Bearer $token'},
      );

      print(response.body);

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
            // phoneController.text = jsonResponse['phone'] ?? '';
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

      var uri = Uri.parse('https://app.wbli.org/api/verify');
      String? token = await UserSession.getToken();

      // Convert signature to image
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
      //..fields['phone'] = phoneController.text // এ লাইনটি যোগ করুন
        ..files.add(frontImage)
        ..files.add(backImage)
        ..files.add(selfieImage)
        ..files.add(signatureMultipart);

      try {
        var response = await request.send();
        var responseBody = await response.stream.bytesToString();
        print(responseBody);

        if (response.statusCode == 200) {
          final jsonResponse = json.decode(responseBody);
          String message = jsonResponse['message'];
          Map<String, dynamic> user = jsonResponse['user'];

          Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (context) => BankAccountScreen()));
          // Show success message and user details
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Text('Success'),
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(message),
                  SizedBox(height: 8),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);

                    // Clear form fields after success
                    nameController.clear();
                    idController.clear();
                    currentAddressController.clear();
                    permanentAddressController.clear();
                    //phoneController.clear();
                    professionController.clear();
                    loanPurposeController.clear();
                    nomineeRelationController.clear();
                    nomineeNameController.clear();
                    nomineePhoneController.clear();
                    monthyIncomController.clear();
                    nidNameController.clear();

                    // Clear images and signature
                    setState(() {
                      frontIdImage = null;
                      backIdImage = null;
                      selfieWithIdImage = null;
                      _signatureController.clear();
                    });
                  },
                  child: Text('OK'),
                ),
              ],
            ),
          );
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
    _checkStatus(); // Check status when the screen is loaded
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('ব্যাক্তিগত'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle('আপনার তথ্য'),
              _buildTextField(' নাম', nameController),
              SizedBox(height: 8.0),
              _buildTextField('বর্তমান ঠিকানা', currentAddressController),
              SizedBox(height: 8.0),
              _buildTextField('স্থায়ী ঠিকানা', permanentAddressController),
              SizedBox(height: 8.0),
              //_buildTextField('Your Mobile Number', phoneController),
              SizedBox(height: 8.0),
              _buildTextField('পেশা', professionController),
              SizedBox(height: 8.0),
              _buildTextField('মাসিক আয়', monthyIncomController),
              SizedBox(height: 8.0),
              _buildTextField('ঋণের উদ্দেশ্য', loanPurposeController),
              SizedBox(height: 16.0),
              _buildSectionTitle('মনোনীত ব্যক্তির তথ্য'),
              _buildTextField('মনোনীত ব্যক্তির নাম', nomineeNameController),
              SizedBox(height: 8.0),
              _buildTextField('সম্পর্ক', nomineeRelationController),
              SizedBox(height: 8.0),
              _buildTextField('মনোনীত ব্যক্তির মোবাইল নম্বর', nomineePhoneController),
              SizedBox(height: 16.0),
              _buildSectionTitle('ছবির সংগ্রহ'),
              SizedBox(height: 8.0),
              _buildTextField('জাতীয় পরিচয়পত্রের নাম', nidNameController),
              SizedBox(height: 8.0),
              _buildTextField('জাতীয় পরিচয়পত্র নম্বর', idController),
              SizedBox(height: 8.0),


              _buildImageUploadField('আপনার আইডি কার্ডের সামনের দিক',
                      () => _pickImage('front'), frontIdImage),
              _buildImageUploadField('আপনার আইডি কার্ডের পিছনের দিক',
                      () => _pickImage('back'), backIdImage),
              _buildImageUploadField('আপনার আইডি কার্ডের সাথে সেলফি',
                      () => _pickImage('selfie'), selfieWithIdImage),


              SizedBox(height: 16.0),
              _buildSignatureField('নিচের বাক্সে সাইন ইন করুন'),
              SizedBox(height: 16.0),
              if (_isLoading) Center(child: CircularProgressIndicator()),
              SizedBox(height: 16.0),
              _buildSaveButton(),
            ],
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
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.white), // White label text
        hintText: 'Enter your $label', // Optional hint text
        hintStyle: TextStyle(color: Colors.white70), // Optional hint text color
        border: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.white), // White border color
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.white), // White border when enabled
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.white), // White border when focused
        ),
      ),
      style: TextStyle(color: Colors.white), // White text color
      enabled: !_isFormDisabled, // Disable the field if form is disabled
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'সব ঘরট পূরণ করুন।';
        }
        return null;
      },
    );
  }




  Widget _buildImageUploadField(
      String label, VoidCallback onTap, XFile? imageFile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 16)),
        SizedBox(height: 8.0),
        GestureDetector(
          onTap: _isFormDisabled ? null : onTap,
          child: Container(
            height: 150,
            width: double.infinity,
            color: Colors.grey[300],
            child: imageFile == null
                ? Icon(Icons.add_photo_alternate, size: 50)
                : imageFile!.path.contains('http')
                ? Image.network(imageFile.path,
                fit: BoxFit.cover) // Show image from URL
                : Image.file(File(imageFile.path),
                fit: BoxFit.cover), // Show local image
          ),
        ),
      ],
    );
  }

  Widget _buildSignatureField(String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 16)),
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
            child: Text('স্বাক্ষর মুছুন', style: TextStyle(color: Colors.white),),
          ),
      ],
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isFormDisabled ? null : _submitForm,
        // Disable button if form is disabled
        child: Text('সেইভ'),
      ),
    );
  }

  Future<void> _pickImage(String type) async {
    final pickedFile = await showDialog<XFile?>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('একটি  বেছে নিন'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.camera_alt),
                title: Text('ছবি তুলুন'),
                onTap: () async {
                  final pickedFile =
                  await _picker.pickImage(source: ImageSource.camera);
                  Navigator.pop(context, pickedFile);
                },
              ),
              ListTile(
                leading: Icon(Icons.photo_library),
                title: Text('গ্যালারি থেকে নির্বাচন করুন'),
                onTap: () async {
                  final pickedFile =
                  await _picker.pickImage(source: ImageSource.gallery);
                  Navigator.pop(context, pickedFile);
                },
              ),
            ],
          ),
        );
      },
    );

    if (pickedFile == null || !File(pickedFile.path).existsSync()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No valid image selected. Please try again.')),
      );
      return;
    }

    // Save the selected file to state
    setState(() {
      if (type == 'front') {
        frontIdImage = pickedFile;
        _checkFileFormat(frontIdImage);
      } else if (type == 'back') {
        backIdImage = pickedFile;
        _checkFileFormat(backIdImage);
      } else if (type == 'selfie') {
        selfieWithIdImage = pickedFile;
        _checkFileFormat(selfieWithIdImage);
      }
    });

    print('Selected file path: ${pickedFile.path}');
  }


  void _checkFileFormat(XFile? file) async {
    if (file != null) {
      String fileExtension = file.path.split('.').last.toLowerCase();
      print('File format: $fileExtension');
      if (fileExtension != 'jpg' && fileExtension != 'jpeg' && fileExtension != 'png') {
        print('Invalid file format. Converting to JPG...');
        File originalFile = File(file.path);
        File convertedFile = await _convertImageToJpg(originalFile);

        // Update the file reference after conversion
        setState(() {
          if (file == selfieWithIdImage) {
            selfieWithIdImage = XFile(convertedFile.path);
          } else if (file == frontIdImage) {
            frontIdImage = XFile(convertedFile.path);
          } else if (file == backIdImage) {
            backIdImage = XFile(convertedFile.path);
          }
        });
      }
    }
  }



  @override
  void dispose() {
    nameController.dispose();
    idController.dispose();
    currentAddressController.dispose();
    permanentAddressController.dispose();
    //phoneController.dispose();
    professionController.dispose();
    loanPurposeController.dispose();
    nomineeRelationController.dispose();
    nomineeNameController.dispose();
    nomineePhoneController.dispose();
    _signatureController.dispose();
    super.dispose();
  }
}