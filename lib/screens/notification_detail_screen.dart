import 'package:flutter/material.dart';

class NotificationDetailScreen extends StatelessWidget {
  final String title;
  final String body;
  final String? imageAsset;

  const NotificationDetailScreen({
    super.key,
    required this.title,
    required this.body,
    this.imageAsset,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Notification",
          style: TextStyle(
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.w700,
            fontSize: 20,
            color: Colors.white,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (imageAsset != null)
              Center(
                child: Image.asset(
                  'drawable/$imageAsset', // Adjust if stored in drawable
                  height: 200,
                ),
              ),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text(body, style: const TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }
}
