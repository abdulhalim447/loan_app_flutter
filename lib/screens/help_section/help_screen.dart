import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
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
    _loadStoredContactDetails(); // Load data from SharedPreferences
    _fetchContactDetails(); // Fetch data from API
  }

  // Save contact details to SharedPreferences
  Future<void> _saveContactDetails(String? whatsapp, String? telegram) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('whatsappContact', whatsapp ?? '');
    await prefs.setString('telegramContact', telegram ?? '');
  }

  // Load contact details from SharedPreferences
  Future<void> _loadStoredContactDetails() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      whatsappContact = prefs.getString('whatsappContact') ?? null;
      telegramContact = prefs.getString('telegramContact') ?? null;
    });
  }

  // Fetch contact details from API
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
        final data = json.decode(response.body);
        String? newWhatsappContact = data['whatsapp'];
        String? newTelegramContact = data['telegram'];

        // Save the new data if it has changed
        if (whatsappContact != newWhatsappContact || telegramContact != newTelegramContact) {
          await _saveContactDetails(newWhatsappContact, newTelegramContact);

          setState(() {
            whatsappContact = newWhatsappContact;
            telegramContact = newTelegramContact;
          });
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to fetch contact details.')),
        );
      }
    }
  }

  // Launch URL function
  void _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text('Contact Us'),
        centerTitle: true,
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              width: isMobile ? double.infinity : 600,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(
                    Icons.support_agent,
                    size: isMobile ? 80 : 100,
                    color: Colors.orange,
                  ),
                  SizedBox(height: isMobile ? 12 : 16),
                  Text(
                    "You can contact us through any of the methods below or make an appointment to visit the office directly.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: isMobile ? 14 : 16,
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
                          contact: "whatsappContact!",
                          onTap: () => _launchURL("https://wa.me/$whatsappContact"),
                          isMobile: isMobile,
                        ),
                        ContactOption(
                          icon: FontAwesomeIcons.telegram,
                          color: Colors.blueAccent,
                          title: "Contact via Telegram",
                          contact: "telegramContact!",
                          onTap: () => _launchURL("https://t.me/$telegramContact"),
                          isMobile: isMobile,
                        ),
                      ],
                    )
                  else
                    CircularProgressIndicator(),
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
          Icon(icon, color: color, size: isMobile ? 24 : 32),
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
