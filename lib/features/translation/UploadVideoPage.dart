import 'package:flutter/material.dart';

class UploadVideoPage extends StatelessWidget {
  const UploadVideoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: BackButton(color: Theme.of(context).textTheme.bodyLarge?.color)
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 40),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(25),
                border: Border.all(color: Theme.of(context).primaryColor.withOpacity(0.3), width: 2),
              ),
              child: Column(
                children: [
                  Icon(Icons.cloud_upload_outlined, size: 70, color: Theme.of(context).primaryColor),
                  const SizedBox(height: 20),
                  Text(
                      "Upload Video",
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).textTheme.bodyLarge?.color
                      )
                  ),
                  const SizedBox(height: 10),
                  Text(
                      "Drag and drop your video here",
                      style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color)
                  ),
                  const SizedBox(height: 30),
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                    ),
                    child: const Text("Browse Files"),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}