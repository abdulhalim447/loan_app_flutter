import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class PrivacyPolicyScreen extends StatelessWidget {
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
        title: Text("Privacy Policy"),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Privacy Policy",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18 ,color: Colors.white),
            ),
            SizedBox(height: 8),
            Text(
              "This privacy policy applies to the World Bank app (hereby referred to as 'Application') for mobile devices that was created by WorldBank (hereby referred to as 'Service Provider') as a Free service. This service is intended for use 'AS IS'.",
              style: TextStyle(fontSize: 16,color: Colors.white),
            ),
            SizedBox(height: 16),
            Text(
              "Information Collection and Use",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18,color: Colors.white),
            ),
            SizedBox(height: 8),
            Text(
              "The Application collects information when you download and use it. This information may include information such as:",
              style: TextStyle(fontSize: 16,color: Colors.white),
            ),
            SizedBox(height: 8),
            BulletPoint([
              "Your device's Internet Protocol address (e.g. IP address)",
              "The pages of the Application that you visit, the time and date of your visit, the time spent on those pages",
              "The time spent on the Application",
              "The operating system you use on your mobile device",

            ]),
            SizedBox(height: 16),
            Text(
              "The Application does not gather precise information about the location of your mobile device.",
              style: TextStyle(fontSize: 16,color: Colors.white),
            ),
            SizedBox(height: 16),
            Text(
              "The Service Provider may use the information you provided to contact you from time to time to provide you with important information, required notices, and marketing promotions.",
              style: TextStyle(fontSize: 16,color: Colors.white),
            ),
            SizedBox(height: 16),
            Text(
              "Third Party Access",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18,color: Colors.white),
            ),
            SizedBox(height: 8),
            Text(
              "Only aggregated, anonymized data is periodically transmitted to external services to aid the Service Provider in improving the Application and their service.",
              style: TextStyle(fontSize: 16,color: Colors.white),
            ),
            SizedBox(height: 8),
            GestureDetector(
              onTap: () =>
                  _launchURL("https://www.google.com/policies/privacy/"),
              child: Text(
                "Google Play Services Privacy Policy",
                style: TextStyle(
                  color: Colors.white,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
            SizedBox(height: 16),
            Text(
              "Opt-Out Rights",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18,color: Colors.white),
            ),
            SizedBox(height: 8),
            Text(
              "You can stop all collection of information by the Application easily by uninstalling it.",
              style: TextStyle(fontSize: 16,color: Colors.white),
            ),
            SizedBox(height: 16),
            Text(
              "Data Retention Policy",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18,color: Colors.white),
            ),
            SizedBox(height: 8),
            Text(
              "The Service Provider will retain User Provided data for as long as you use the Application and for a reasonable time thereafter.",
              style: TextStyle(fontSize: 16,color: Colors.white),
            ),
            SizedBox(height: 16),
            Text(
              "Children",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18,color: Colors.white),
            ),
            SizedBox(height: 8),
            Text(
              "The Application does not address anyone under the age of 13. The Service Provider does not knowingly collect personally identifiable information from children under 13 years of age.",
              style: TextStyle(fontSize: 16,color: Colors.white),
            ),
            SizedBox(height: 16),
            Text(
              "Security",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18,color: Colors.white),
            ),
            SizedBox(height: 8),
            Text(
              "The Service Provider is concerned about safeguarding the confidentiality of your information.",
              style: TextStyle(fontSize: 16,color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}

class BulletPoint extends StatelessWidget {
  final List<String> points;

  BulletPoint(this.points);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: points.map((point) {
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "• ",
              style: TextStyle(fontSize: 16,color: Colors.white),
            ),
            Expanded(
              child: Text(
                point,
                style: TextStyle(fontSize: 16,color: Colors.white),
              ),
            ),
          ],
        );
      }).toList(),
    );
  }
}
