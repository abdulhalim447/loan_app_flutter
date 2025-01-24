import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class DataDeletionPolicyScreen extends StatelessWidget {
  const DataDeletionPolicyScreen({Key? key}) : super(key: key);

  // Function to handle external links
  void _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Data Deletion Policy', style: TextStyle(color: Colors.white)), // White color for AppBar text
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Text with white color
            const Text(
              'Data Deletion Policy',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.white),
            ),
            const SizedBox(height: 16),
            const Text(
              'User-Initiated Deletion',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white),
            ),
            const SizedBox(height: 8),
            const Text(
              'Users have the right to request the deletion of their personal data collected by our application. To initiate this process, please contact us at ',
              style: TextStyle(fontSize: 16, color: Colors.white),
            ),
            GestureDetector(
              onTap: () => _launchURL('mailto:abc@gmail.com'),
              child: const Text(
                'abc@gmail.com',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.blue,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
            const Text(
              ' with the subject line "Data Deletion Request." Upon verification of your identity, we will process your request and delete your data within 30 days.',
              style: TextStyle(fontSize: 16, color: Colors.white),
            ),
            const SizedBox(height: 16),
            const Text(
              'Automatic Data Deletion',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white),
            ),
            const SizedBox(height: 8),
            const Text(
              'If you choose to uninstall the application, please be aware that this action does not automatically delete the data we have collected. To ensure complete removal of your personal information, please follow the user-initiated deletion process outlined above.',
              style: TextStyle(fontSize: 16, color: Colors.white),
            ),
            const SizedBox(height: 16),
            const Text(
              'Data Retention',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white),
            ),
            const SizedBox(height: 8),
            const Text(
              'We retain user-provided data for as long as you use the application and for a reasonable period thereafter. If you would like us to delete user-provided data that you have provided via the application, please contact us at ',
              style: TextStyle(fontSize: 16, color: Colors.white),
            ),
            GestureDetector(
              onTap: () => _launchURL('mailto:abc@gmail.com'),
              child: const Text(
                'abc@gmail.com',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.blue,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
            const Text(
              ' and we will respond in a reasonable time.',
              style: TextStyle(fontSize: 16, color: Colors.white),
            ),
            const SizedBox(height: 16),
            const Text(
              'Third-Party Services',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white),
            ),
            const SizedBox(height: 8),
            const Text(
              'Please note that our application utilizes third-party services that may collect information used to identify you. We encourage you to review the privacy policies of these service providers to understand their data deletion practices.',
              style: TextStyle(fontSize: 16, color: Colors.white),
            ),
            const SizedBox(height: 16),
            const Text(
              'Policy Updates',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white),
            ),
            const SizedBox(height: 8),
            const Text(
              'We may update our Data Deletion Policy from time to time. Thus, you are advised to review this page periodically for any changes. We will notify you of any changes by posting the new Data Deletion Policy on this page.',
              style: TextStyle(fontSize: 16, color: Colors.white),
            ),
            const SizedBox(height: 16),
            const Text(
              'Contact Us',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white),
            ),
            const SizedBox(height: 8),
            const Text(
              'If you have any questions or suggestions about our Data Deletion Policy, do not hesitate to contact us at ',
              style: TextStyle(fontSize: 16, color: Colors.white),
            ),
            GestureDetector(
              onTap: () => _launchURL('mailto:abc@gmail.com'),
              child: const Text(
                'abc@gmail.com',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.blue,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
            const Text(
              '.',
              style: TextStyle(fontSize: 16, color: Colors.white),
            ),
            const SizedBox(height: 16),
            const Text(
              'By using our application, you agree to the terms outlined in this Data Deletion Policy.',
              style: TextStyle(fontSize: 16, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
