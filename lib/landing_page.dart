import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:asian_development_bank/auth/LoginScreen.dart';
import 'package:asian_development_bank/auth/SignupScreen.dart';
import 'dart:html' as html;

class LandingPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Asian Development Bank"),
        centerTitle: true,
      ),
      body: Center(
        child: Container(
          width: MediaQuery.of(context).size.width < 600 ? double.infinity : 600,
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 40),
          color: Colors.white,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image.asset(
                "assets/icons/app_logo.png",
                height: 120,
                width: 120,
              ),
              Text(
                'Asian Development Bank',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => SignupScreen()));
                },
                child: Text('নিবন্ধন'),
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(double.infinity, 50),
                ),
              ),
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => LoginScreen()));
                },
                child: Text('লগইন'),
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(double.infinity, 50),
                ),
              ),
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {
                  showDownloadDialog(context);
                },
                child: Text("ডাউনলোড অ্যাপ"),
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(double.infinity, 50),
                ),
              ),
              SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }

  void showDownloadDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return DownloadProgressDialog(
          onDownloadComplete: () {
            Navigator.pop(context);
            showInstallDialog(context);
          },
        );
      },
    );
  }

  void showInstallDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Download Complete'),
          content: Text('Would you like to install the app?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                downloadFile(
                  "https://zkticcaajwyindsxjbcm.supabase.co/storage/v1/object/public/gh//asian_development.apk",
                  "asian_development_bank.apk",
                );
                Navigator.pop(context);
              },
              child: Text('Install'),
            ),
          ],
        );
      },
    );
  }

  void downloadFile(String url, String fileName) {
    if (html.window.navigator.userAgent.contains('Mobile')) {
      // This is mobile, so it's better to guide the user to a download page or show instructions
      html.window.open(url, '_blank');
    } else {
      // For Web platforms
      final html.AnchorElement anchor = html.AnchorElement(href: url)
        ..target = '_blank'
        ..download = fileName;
      anchor.click();
    }
  }
}

class DownloadProgressDialog extends StatelessWidget {
  final VoidCallback onDownloadComplete;

  DownloadProgressDialog({required this.onDownloadComplete});

  @override
  Widget build(BuildContext context) {
    Future.delayed(Duration(seconds: 3), onDownloadComplete);

    return AlertDialog(
      title: Text('Downloading'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Please wait...'),
          SizedBox(height: 10),
          LinearProgressIndicator(),
        ],
      ),
    );
  }
}
