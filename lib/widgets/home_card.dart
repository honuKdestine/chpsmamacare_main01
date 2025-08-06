import 'package:flutter/material.dart';

class HomeCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onTap;

  const HomeCard({
    super.key,
    required this.title,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isAddPregnancy = title.toLowerCase().contains('add pregnancy');
    final isDangerSign = title.toLowerCase().contains('danger sign');
    final isViewRecords = title.toLowerCase().contains('view records');
    final isEmergency = title.toLowerCase().contains('emergency');
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: isAddPregnancy
              ? Color(0xFF43E97B)
              : isDangerSign
              ? Color(0xFFFF5252)
              : isViewRecords
              ? Color(0xFF8E24AA) // solid purple
              : isEmergency
              ? Color(0xFFFF6F00) // deep orange
              : Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 56,
              color: isAddPregnancy
                  ? Colors.white
                  : isDangerSign
                  ? const Color.fromARGB(
                      255,
                      255,
                      221,
                      0,
                    ) // deep yellow only for danger signs
                  : isEmergency
                  ? Colors
                        .white // white for emergency
                  : isViewRecords
                  ? Colors
                        .white // white for view records
                  : null, // default color for others
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
