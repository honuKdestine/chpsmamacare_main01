import 'package:chpsmamacare_main01/screens/emergency_referral_screen.dart';
import 'package:chpsmamacare_main01/utils/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:chpsmamacare_main01/utils/danger_signs.dart';

class DangerSignsScreen extends StatelessWidget {
  const DangerSignsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Danger Signs',
          style: TextStyle(
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.w700,
            fontSize: 20,
            color: Colors.white,
          ),
        ),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header section with background image and gradient overlay
            SizedBox(
              width: double.infinity,
              height: 220,
              child: Stack(
                children: [
                  // Background image with dark overlay
                  Container(
                    width: double.infinity,
                    height: 220,
                    decoration: const BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage('images/danger_rec.jpg'),
                        fit: BoxFit.cover,
                        colorFilter: ColorFilter.mode(
                          Colors.black54, // dark overlay
                          BlendMode.darken,
                        ),
                      ),
                    ),
                  ),
                  // Gradient overlay and content
                  Container(
                    width: double.infinity,
                    height: 220,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          const Color.fromARGB(255, 255, 0, 0).withOpacity(0.9),
                          const Color.fromARGB(
                            199,
                            0,
                            174,
                            255,
                          ).withOpacity(0.3),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image(
                          image: AssetImage('images/danger_maternal.png'),
                          width: 48,
                          height: 48,
                          // color: Colors.white,
                        ),

                        SizedBox(height: 12),
                        Text(
                          'Maternal Danger Signs',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'These signs require immediate medical attention',
                          style: TextStyle(color: Colors.white, fontSize: 16),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Danger signs list
                  const Text(
                    'Warning Signs to Watch For:',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),

                  ...DangerSigns.maternalDangerSigns.map(
                    (sign) => _buildDangerSignCard(sign, context),
                  ),

                  const SizedBox(height: 32),

                  // Action steps
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.danger.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.danger.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(
                              Icons.emergency,
                              color: AppColors.danger,
                              size: 24,
                            ),
                            SizedBox(width: 12),
                            Text(
                              'Emergency Action Steps',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        _buildActionStep(
                          '1',
                          'Assess Immediately',
                          'Quickly determine the severity of the situation',
                          AppColors.danger,
                        ),
                        const SizedBox(height: 12),
                        _buildActionStep(
                          '2',
                          'Stabilize if Possible',
                          'Provide first aid or initial treatment if trained',
                          AppColors.warning,
                        ),
                        const SizedBox(height: 12),
                        _buildActionStep(
                          '3',
                          'Refer Immediately',
                          'Contact nearest health facility with capabilities',
                          AppColors.secondary,
                        ),
                        const SizedBox(height: 12),
                        _buildActionStep(
                          '4',
                          'Document Everything',
                          'Record observations and actions for continuity',
                          AppColors.primary,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),
                  // Emergency contact button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                const EmergencyReferralScreen(),
                          ),
                        );
                      },
                      icon: const Icon(Icons.phone),
                      label: const Text('Emergency Contacts & Referrals'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.danger,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDangerSignCard(String sign, BuildContext context) {
    final description = DangerSigns.dangerSignDescriptions[sign] ?? '';

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ExpansionTile(
        leading: const Icon(
          Icons.warning_amber_rounded,
          color: AppColors.danger,
          size: 24,
        ),
        title: Text(
          sign,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
        ),
        children: [
          if (description.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Text(
                description,
                style: TextStyle(color: Colors.grey[600], fontSize: 14),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildActionStep(
    String number,
    String title,
    String description,
    Color color,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          child: Center(
            child: Text(
              number,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: TextStyle(color: Colors.grey[600], fontSize: 14),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
