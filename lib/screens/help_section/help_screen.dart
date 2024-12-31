import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

import '../../auth/saved_login/user_session.dart';

class ContactScreen extends StatefulWidget {
  @override
  _ContactScreenState createState() => _ContactScreenState();
}

class _ContactScreenState extends State<ContactScreen> {
  String? whatsappContact;
  String? telegramContact;

  @override
  void initState() {
    super.initState();
    _fetchContactDetails();
  }

  // Function to fetch the contact details using the API
  Future<void> _fetchContactDetails() async {
    String? token = await UserSession.getToken();
    if (token != null) {
      final response = await http.get(
        Uri.parse("https://wbli.org/api/support"),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body); // Decode the JSON response
        setState(() {
          // Extract the whatsapp and telegram contact info from the JSON response
          whatsappContact = data['whatsapp'];
          telegramContact = data['telegram'];
        });
      } else {
        // Handle API failure
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to fetch contact details.')),
        );
      }
    }
  }

  // Function to launch the URL
  void _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    // স্ক্রিনের উইডথ নির্ধারণ
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;

    return Scaffold(
      appBar: AppBar(
        title: Text('Contact Us'),
        centerTitle: true, // অ্যাপবারের টাইটেল সেন্টারে রাখা
      ),
      body: Center( // মূল কনটেন্টকে সেন্টারে রাখা
        child: SingleChildScrollView( // স্ক্রল যোগ করা যাতে ছোট স্ক্রীনে ভালো দেখায়
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              width: isMobile ? double.infinity : 600, // ডেস্কটপে নির্দিষ্ট প্রস্থ
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(
                    Icons.support_agent,
                    size: isMobile ? 80 : 100, // মোবাইলে আইকন সাইজ কমানো
                    color: Colors.orange,
                  ),
                  SizedBox(height: isMobile ? 12 : 16),
                  Text(
                    "You can contact us through any of the methods below or make an appointment to visit the office directly.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: isMobile ? 14 : 16, // মোবাইলে ফন্ট সাইজ কমানো
                    ),
                  ),
                  SizedBox(height: isMobile ? 12 : 16),
                  Text(
                    "The World Bank, No 11, Taramani Link Rd, Tharamani, Chennai, Tamil Nadu 600113, India",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: isMobile ? 12 : 14,
                      color: Colors.grey[700],
                    ),
                  ),
                  SizedBox(height: isMobile ? 16 : 20),
                  if (whatsappContact != null && telegramContact != null)
                    Column(
                      children: [
                        ContactOption(
                          icon: FontAwesomeIcons.whatsapp,
                          color: Colors.green,
                          title: "Contact via WhatsApp",
                          contact: whatsappContact!,
                          onTap: () => _launchURL("https://wa.me/$whatsappContact"),
                          isMobile: isMobile,
                        ),
                        ContactOption(
                          icon: FontAwesomeIcons.telegram,
                          color: Colors.blueAccent,
                          title: "Contact via Telegram",
                          contact: telegramContact!,
                          onTap: () => _launchURL("https://t.me/$telegramContact"),
                          isMobile: isMobile,
                        ),
                      ],
                    )
                  else
                    CircularProgressIndicator(), // লোডিং ইন্ডিকেটর দেখানো হচ্ছে
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class ContactOption extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String contact;
  final VoidCallback onTap;
  final bool isMobile;

  ContactOption({
    required this.icon,
    required this.color,
    required this.title,
    required this.contact,
    required this.onTap,
    required this.isMobile,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: isMobile ? 6 : 8),
      padding: EdgeInsets.all(isMobile ? 10 : 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Colors.grey[100],
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: isMobile ? 24 : 32), // আইকন সাইজ পরিবর্তন
          SizedBox(width: isMobile ? 12 : 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: isMobile ? 14 : 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  contact,
                  style: TextStyle(
                    fontSize: isMobile ? 12 : 14,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(Icons.launch, size: isMobile ? 20 : 24),
            onPressed: onTap,
          ),
        ],
      ),
    );
  }
}
