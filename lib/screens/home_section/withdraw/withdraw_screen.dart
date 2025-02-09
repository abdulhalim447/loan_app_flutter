import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import '../../../auth/saved_login/user_session.dart';

class WithdrawScreen extends StatefulWidget {
  @override
  _WithdrawScreenState createState() => _WithdrawScreenState();
}

class _WithdrawScreenState extends State<WithdrawScreen> {
  String balance = "0"; // Now String
  String loan = "0"; // Now String
  String bankName = "N/A";
  String account = "N/A";
  String bankUser = "N/A";
  String message = "Not provided";
  String fee = "0";
  String ifc = "N/A";

  int status = 0;

  // For Transaction Screenshot section
  String imagePath = "N/A";

  // Admin Bank Details section
  String adminBankName = "N/A";
  String adminAccountName = "N/A";
  String adminAccountNumber = "N/A";
  String adminIfc = "N/A";
  String adminUpi = "N/A";

  File? _image;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _fetchWithdrawDetails();
  }

  Future<void> _fetchWithdrawDetails() async {
    String? token = await UserSession.getToken(); // Get token from UserSession

    if (token != null) {
      final response = await http.get(
        Uri.parse("https://wbli.org/api/method"),
        headers: {
          'Authorization': 'Bearer $token', // Sending Bearer token in header
        },
      );

      print(response.statusCode);
      print(response.body);

      if (response.statusCode == 200) {
        try {
          final data = json.decode(response.body);

          setState(() {
            // User Bank Info
            balance = (data['userBankInfo']['balance'] ?? 0).toString();
            loan = (data['userBankInfo']['loanBalance'] ?? 0).toString();
            bankName = data['userBankInfo']['bankName'] ?? "N/A";
            account =
                data['userBankInfo']['accountNumber']?.toString() ?? "N/A";
            bankUser = data['userBankInfo']['bankUserName'] ?? "N/A";
            fee = data['userBankInfo']['fee']?.toString() ?? "0";
            ifc = data['userBankInfo']['ifc'] ?? "N/A";
            message =
                data['userBankInfo']['message'] ?? " Message Not provided";

            // Admin Bank Info
            adminBankName = data['adminBankInfo']['adminBankName'] ?? "N/A";
            adminAccountNumber =
                data['adminBankInfo']['adminAccountNumber'] ?? "N/A";
            adminIfc = data['adminBankInfo']['adminIfc'] ?? "N/A";
            adminUpi = data['adminBankInfo']['adminUpi'] ?? "N/A";
            adminAccountName =
                data['adminBankInfo']['adminAccountName'] ?? "N/A";

            print("Balance: $balance, Loan: $loan"); // Debugging print
          });
        } catch (e) {
          print("Error parsing data: $e");
        }
      } else {
        print("Failed to load data: ${response.statusCode}");
      }
    } else {
      print("Token is null");
    }
  }

  // Function to pick an image from the gallery or camera
  Future<void> _pickImage() async {
    final XFile? pickedFile =
    await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  Future<void> _submitImage() async {
    if (_image == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Please select an image")));
      return;
    }

    String? token = await UserSession.getToken();
    if (token == null || token.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("User not authenticated")));
      return;
    }

    try {
      var uri = Uri.parse("https://wbli.org/api/recharge");
      var request = http.MultipartRequest('POST', uri);

      // Attach the image file
      request.files
          .add(await http.MultipartFile.fromPath('image', _image!.path));

      // Add headers
      request.headers.addAll({
        'Authorization': 'Bearer $token',
        'Content-Type': 'multipart/form-data',
      });

      // Send the request
      var response = await request.send();
      final responseString = await response.stream.bytesToString();
      print("Server Response: $responseString");

      if (response.statusCode == 200) {
        setState(() {
          _image = null; // Reset the image
        });
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Image submitted successfully")));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Failed: ${response.statusCode}")));
      }
    } catch (e) {
      print("Error: $e");
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Withdraw", style: TextStyle(fontSize: 20)),
        centerTitle: true,
      ),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          BalanceSection(balance: balance, loan: loan),
          SizedBox(height: 8),
          Text('Details', style: TextStyle(color: Colors.black)),
          BankDetails(
            bankName: bankName,
            account: account,
            bankUser: bankUser,
            ifc_code: ifc,
          ),
          NoteSection(message: message),
          AdminBankDetailsSection(
            bankName: adminBankName,
            accountNumber: adminAccountNumber,
            ifc: adminIfc,
            upi: adminUpi,
            adminAccountName: adminAccountName,
          ),
          TakaSection(fee: fee),
          TransactionScreenshot(
            imagePath: imagePath,
            status: status,
            onSuccess: _fetchWithdrawDetails,
          ),
        ],
      ),
    );
  }
}

class BalanceSection extends StatelessWidget {
  final String balance;
  final String loan;

  BalanceSection({required this.balance, required this.loan});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: Colors.red,
        ),
        padding: EdgeInsets.symmetric(vertical: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            BalanceColumn(label: "Balance (Rs)", amount: balance),
            BalanceColumn(label: "Loan (Rs)", amount: loan),
          ],
        ),
      ),
    );
  }
}

class BalanceColumn extends StatelessWidget {
  final String label;
  final String amount;

  BalanceColumn({required this.label, required this.amount});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(color: Colors.white, fontSize: 16),
        ),
        SizedBox(height: 5),
        Text(
          amount, // Directly show the string value
          style: TextStyle(
              color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}

// User BankDetails section is here ====================================
class BankDetails extends StatelessWidget {
  final String? bankName;
  final String? account;
  final String? bankUser;
  final String? ifc_code;

  BankDetails({this.bankName, this.account, this.bankUser, this.ifc_code});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(16),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
              color: Colors.grey.shade300, blurRadius: 6, offset: Offset(2, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          userDetailRow(label: "Bank Name", value: bankName ?? "Not Provided"),
          userDetailRow(
              label: "Account Number", value: account ?? "Not Provided"),
          userDetailRow(label: "User Name", value: bankUser ?? "Not Provided"),
          userDetailRow(label: "IFC Code", value: ifc_code ?? "Not Provided"),
        ],
      ),
    );
  }
}

class DetailRow extends StatelessWidget {
  final String label;
  final String value;

  DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisSize: MainAxisSize.min, // Add this to avoid unbounded width
        children: [
          Text(
            "$label :",
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
          Spacer(), // Add spacer for spacing
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              SizedBox(width: 8), // Space between text and button
              GestureDetector(
                onTap: () {
                  Clipboard.setData(ClipboardData(text: value));
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('$label copied to clipboard'),
                      duration: Duration(seconds: 1),
                    ),
                  );
                },
                child: Icon(Icons.copy, color: Colors.grey),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class userDetailRow extends StatelessWidget {
  final String label;
  final String value;

  userDetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisSize: MainAxisSize.min, // Add this to avoid unbounded width
        children: [
          Text(
            "$label :",
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
          Spacer(), // Add spacer for spacing
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// Admin BankDetails Section =====================
class AdminBankDetailsSection extends StatelessWidget {
  final String? bankName;
  final String? accountNumber;
  final String? ifc;
  final String? upi;
  final String? adminAccountName;

  AdminBankDetailsSection(
      {this.bankName,
        this.accountNumber,
        this.ifc,
        this.upi,
        required this.adminAccountName});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.all(16),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
              color: Colors.grey.shade300,
              blurRadius: 6,
              offset: Offset(2, 2))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DetailRow(label: "UPI", value: upi ?? "Not Provided"),
          SizedBox(
            height: 10,
          ),
          Divider(
            height: 2,
            color: Colors.black,
          ),
          SizedBox(
            height: 10,
          ),
          DetailRow(label: "Bank Name", value: bankName ?? "Not Provided"),
          DetailRow(
              label: "Holder Name", value: adminAccountName ?? "Not Provided"),
          DetailRow(
              label: "Account Number", value: accountNumber ?? "Not Provided"),
          DetailRow(label: "Ifc Code", value: ifc ?? "Not Provided"),
        ],
      ),
    );
  }
}

// TakaSection Widget ===================================
class TakaSection extends StatelessWidget {
  final String? fee;

  TakaSection({this.fee});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(16),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
              color: Colors.grey.shade300,
              blurRadius: 6,
              offset: Offset(2, 2)),
        ],
      ),
      child: Row(
        children: [
          Icon(Icons.money, color: Colors.green),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              "Fee: ${fee != null ? '$fee ' : 'Not Available'}",
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}

// NoteSection Widget ==================================
class NoteSection extends StatelessWidget {
  final String message;

  const NoteSection({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(16),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
              color: Colors.grey.shade300,
              blurRadius: 6,
              offset: Offset(2, 2)),
        ],
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: Colors.blue),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              //"Reserve Bank of India has made savings mandatory for loans, you must have to savings to get a loan. To withdraw cash, pay the savings fee. Deposit the savings fee to the number given below.",
              style: TextStyle(fontSize: 16, color: Colors.black),
            ),
          ),
        ],
      ),
    );
  }
}

// TransactionScreenshot Widget ==============================================

class TransactionScreenshot extends StatefulWidget {
  final String? imagePath; // Server Image Path
  final int status; // Status: 1 means already uploaded
  final Function onSuccess; // Callback for successful upload

  TransactionScreenshot({
    required this.imagePath,
    required this.status,
    required this.onSuccess,
  });

  @override
  _TransactionScreenshotState createState() => _TransactionScreenshotState();
}

class _TransactionScreenshotState extends State<TransactionScreenshot> {
  File? _selectedImage; // Locally selected image
  final ImagePicker _picker = ImagePicker();
  bool _isUploading = false; // Upload status

  // Function to pick image from gallery
  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  // Function to submit image to the server
  Future<void> _submitImage() async {
    if (_selectedImage == null) return;

    setState(() {
      _isUploading = true;
    });

    try {
      var uri = Uri.parse("https://wbli.org/api/recharge");
      var request = http.MultipartRequest('POST', uri);

      // Attach image file
      request.files.add(
        await http.MultipartFile.fromPath('image', _selectedImage!.path),
      );

      // Add headers (if necessary, e.g., Authorization)
      String? token =
      await UserSession.getToken(); // Get token from UserSession
      // Add headers
      request.headers.addAll({
        'Authorization': 'Bearer $token',
        'Content-Type': 'multipart/form-data',
      });

      var response = await request.send();

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Image uploaded successfully")),
        );

        widget.onSuccess(); // Callback after successful upload
        setState(() {
          _selectedImage = null; // Reset the selected image
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to upload image")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    } finally {
      setState(() {
        _isUploading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () {
            if (widget.status != 1) {
              _pickImage();
            }
          },
          child: Container(
            height: 180,
            width: double.infinity,
            margin: EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: Colors.grey.shade400,
                width: 2,
              ),
              image: _buildBackgroundImage(),
            ),
            child: widget.status != 1 && _selectedImage == null
                ? Center(
              child: Text(
                "Tap to select an image",
                style: TextStyle(color: Colors.grey, fontSize: 16),
              ),
            )
                : null,
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 16.0, right: 16, bottom: 24),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: (_selectedImage == null || _isUploading)
                  ? null // Disable button if no image or during upload
                  : _submitImage,
              child: _isUploading
                  ? SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
                  : Text(
                "Submit Screenshot",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // Function to show background image
  DecorationImage? _buildBackgroundImage() {
    if (widget.status == 1 && widget.imagePath != null) {
      return DecorationImage(
        image: NetworkImage(
            "https://wbli.org/storage/uploads/recharge/${widget.imagePath}"),
        fit: BoxFit.cover,
      );
    } else if (_selectedImage != null) {
      return DecorationImage(
        image: FileImage(_selectedImage!),
        fit: BoxFit.cover,
      );
    }
    return null;
  }
}
