import 'package:chpsmamacare_main01/utils/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:hive/hive.dart';
import '../models/emergency_contact.dart';
import '../widgets/add_emergency_contact_dialog.dart';

class EmergencyReferralScreen extends StatefulWidget {
  const EmergencyReferralScreen({super.key});

  @override
  State<EmergencyReferralScreen> createState() =>
      _EmergencyReferralScreenState();
}

class _EmergencyReferralScreenState extends State<EmergencyReferralScreen> {
  late Box<EmergencyContact> _contactBox;
  List<EmergencyContact> _emergencyContacts = [];

  @override
  void initState() {
    super.initState();
    _initContacts();
  }

  Future<void> _initContacts() async {
    if (Hive.isBoxOpen('emergency_contacts')) {
      _contactBox = Hive.box<EmergencyContact>('emergency_contacts');
    } else {
      _contactBox = await Hive.openBox<EmergencyContact>('emergency_contacts');
    }
    if (_contactBox.isEmpty) {
      final List<EmergencyContact> defaults = [
        EmergencyContact(
          name: 'National Ambulance Service',
          phoneNumber: '112',
          role: 'Available 24/7 nationwide',
          isPrimary: true,
        ),
        EmergencyContact(
          name: 'District Hospital',
          phoneNumber: '0XX-XXX-XXXX',
          role: 'Main referral hospital',
        ),
        EmergencyContact(
          name: 'District Health Director',
          phoneNumber: '0XX-XXX-XXXX',
          role: 'For coordination and support',
        ),
        EmergencyContact(
          name: 'Regional Hospital',
          phoneNumber: '0XX-XXX-XXXX',
          role: 'For complex cases',
        ),
      ];
      await _contactBox.addAll(defaults);
    }
    setState(() {
      _emergencyContacts = _contactBox.values.toList();
    });
  }

  Future<void> _addEmergencyContact(Map<String, dynamic> map) async {
    final contact = EmergencyContact(
      name: map['title'] ?? '',
      phoneNumber: map['contact'] ?? '',
      role: map['description'] ?? '',
    );
    await _contactBox.add(contact);
    setState(() {
      _emergencyContacts = _contactBox.values.toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        floatingActionButton: SizedBox(
          height: 60,
          width: 60,
          child: DecoratedBox(
            decoration: BoxDecoration(
              shape: BoxShape.rectangle,
              borderRadius: BorderRadius.circular(13),
              gradient: LinearGradient(
                colors: [
                  const Color.fromARGB(255, 255, 7, 61),
                  const Color.fromARGB(255, 225, 48, 35),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.danger.withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Tooltip(
              message: 'Add Emergency Contact',
              child: RawMaterialButton(
                shape: const CircleBorder(),
                onPressed: () async {
                  final newContact = await showDialog<Map<String, dynamic>>(
                    context: context,
                    builder: (context) => const AddEmergencyContactDialog(),
                  );
                  if (newContact != null) {
                    await _addEmergencyContact(newContact);
                  }
                },
                elevation: 0,
                child: const Icon(
                  Icons.add_call,
                  color: Colors.white,
                  size: 30,
                ),
              ),
            ),
          ),
        ),

        appBar: AppBar(
          title: const Text(
            'Emergency Referrals',
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
              // Emergency header
              SizedBox(
                width: double.infinity,
                child: Stack(
                  children: [
                    // Background image with dark overlay
                    Container(
                      width: double.infinity,
                      height: 220,
                      decoration: const BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage('images/ambulance_bg1.png'),
                          fit: BoxFit.cover,
                          colorFilter: ColorFilter.mode(
                            Colors.black54, // stronger dark overlay
                            BlendMode.darken,
                          ),
                        ),
                      ),
                    ),
                    // Gradient overlay and content
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      height: 220,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            const Color.fromARGB(180, 234, 25, 10),
                            AppColors.danger.withOpacity(0.5),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.emergency, color: Colors.white, size: 48),
                          SizedBox(height: 12),
                          Text(
                            'Emergency Situation?',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Act quickly and follow the guidelines below',
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
                    // Emergency contacts
                    const Text(
                      'Emergency Contacts',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),

                    ..._emergencyContacts.map(
                      (c) => _buildContactCard(
                        c.name,
                        c.phoneNumber,
                        Icons.local_hospital, // fallback icon
                        c.role ?? '',
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Quick reference guide
                    const Text(
                      'Quick Reference Guide',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),

                    _buildReferralCard('Severe Bleeding', [
                      'Position patient lying flat with legs elevated',
                      'Apply direct pressure to bleeding sites',
                      'Start IV fluids if available and trained',
                      'Arrange immediate transport',
                      'Call ahead to alert receiving facility',
                    ], AppColors.danger),

                    _buildReferralCard('Severe Pre-eclampsia/\nEclampsia', [
                      'Position patient on left side',
                      'Administer magnesium sulfate if available',
                      'Monitor blood pressure frequently',
                      'Keep environment calm',
                      'Arrange immediate transport',
                    ], AppColors.warning),

                    _buildReferralCard('Obstructed Labor', [
                      'Do NOT attempt delivery at CHPS compound',
                      'Start IV fluids if available',
                      'Position patient comfortably',
                      'Monitor vital signs',
                      'Arrange immediate transport',
                    ], AppColors.primary),

                    const SizedBox(height: 32),

                    // Transport information
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.secondary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(
                                Icons.directions_car,
                                color: AppColors.secondary,
                                size: 24,
                              ),
                              SizedBox(width: 12),
                              Text(
                                'Transport Options',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'When ambulance is not available:',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 12),
                          _buildTransportOption(
                            'Community Emergency Transport',
                            'Contact community volunteer drivers',
                          ),
                          _buildTransportOption(
                            'Local Taxi Services',
                            'Have emergency numbers saved',
                          ),
                          _buildTransportOption(
                            'Community Leaders',
                            'They may help arrange transportation',
                          ),
                          _buildTransportOption(
                            'Police/Fire Service',
                            'May assist in extreme emergencies',
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContactCard(
    String title,
    String contact,
    IconData icon,
    String description,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppColors.primary.withOpacity(0.1),
          child: Icon(icon, color: AppColors.primary),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              contact,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            Text(description),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.phone),
          onPressed: () async {
            final phone = contact.replaceAll(RegExp(r'[^0-9+]'), '');
            final uri = Uri(scheme: 'tel', path: phone);
            if (await canLaunchUrl(uri)) {
              await launchUrl(uri);
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Cannot launch dialer for $contact')),
              );
            }
          },
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
    );
  }

  Widget _buildReferralCard(String condition, List<String> steps, Color color) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.medical_services, color: color, size: 20),
                ),
                const SizedBox(width: 12),
                Text(
                  condition,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...steps.map(
              (step) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.check_circle, color: color, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(step, style: const TextStyle(fontSize: 14)),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransportOption(String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.arrow_right, color: AppColors.secondary, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                Text(
                  description,
                  style: TextStyle(color: Colors.grey[600], fontSize: 14),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
