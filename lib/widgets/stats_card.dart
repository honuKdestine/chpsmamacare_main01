import 'package:flutter/material.dart';

class StatsCard extends StatelessWidget {
  final String title;
  final String value;
  final Image image;
  final Color color;

  const StatsCard({
    super.key,
    required this.title,
    required this.value,
    required this.image,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),

      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFF90CAF9), // soft blue
            Color(0xFF1565C0), // deeper blue
          ], // blue gradient
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.13),
            spreadRadius: 1,
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(width: 28, height: 28, child: image),
              Text(
                value,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: title.toLowerCase().contains('danger')
                      ? Colors.red
                      : Colors.black,
                  shadows: [],
                ),
              ),
            ],
          ),
          const SizedBox(height: 9),
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              color:
                  Colors.brown.shade900, // solid dark brown for best contrast
              fontWeight: FontWeight.w600,
              letterSpacing: 0.2,
              shadows: [],
            ),
          ),
        ],
      ),
    );
  }
}
