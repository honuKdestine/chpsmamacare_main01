import 'package:chpsmamacare_main01/screens/add_record_screen.dart';
import 'package:chpsmamacare_main01/screens/appointments_screen.dart';
import 'package:chpsmamacare_main01/screens/danger_signs_screen.dart';
import 'package:chpsmamacare_main01/screens/emergency_referral_screen.dart';
import 'package:chpsmamacare_main01/screens/first_aid_guides_list_screen.dart';
import 'package:chpsmamacare_main01/screens/view_records_screen.dart';
import 'package:chpsmamacare_main01/services/database_service.dart';
import 'package:chpsmamacare_main01/models/pregnancy_record.dart';
import 'package:chpsmamacare_main01/utils/app_theme.dart';
import 'package:chpsmamacare_main01/widgets/home_card.dart';
import 'package:chpsmamacare_main01/widgets/stats_card.dart';
import 'package:chpsmamacare_main01/widgets/voice_danger_sign_button.dart';
import 'package:flutter/material.dart';
import 'dart:async';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void dispose() {
    _carouselTimer?.cancel();
    _pageController?.dispose();
    super.dispose();
  }

  final List<String> _carouselImages = [
    'images/image14.png',
    'images/image12.png',
    'images/image8.png',
    'images/image7.png',
    'images/image3.png',
  ];
  int _currentCarouselIndex = 0;
  Timer? _carouselTimer;
  final DatabaseService _databaseService = DatabaseService();
  late Map<String, int> _stats = {};
  bool _showVoiceButton = false;
  int _selectedIndex = 0;
  PageController? _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _selectedIndex);
    _loadStats();
  }

  Future<void> _loadStats() async {
    final stats = await _databaseService.getStatistics();
    setState(() {
      _stats = stats;
    });
  }

  void _handleDetectedDangerSigns(List<String> dangerSigns) {
    if (dangerSigns.isNotEmpty) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: AppColors.danger),
              SizedBox(width: 8),
              Text('Danger Signs Detected'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'The following danger signs were detected:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              ...dangerSigns.map(
                (sign) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.error_outline,
                        color: AppColors.danger,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(child: Text(sign)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Please take appropriate action immediately.',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const EmergencyReferralScreen(),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.danger,
              ),
              child: const Text('Emergency Contacts'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        // No appBar here; each screen manages its own app bar/header
        body: Stack(
          children: [
            PageView(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _selectedIndex = index;
                });
              },
              children: [
                _buildHomeContent(),
                ViewRecordsScreen(),
                EmergencyReferralScreen(),
                AppointmentsScreen(),
                const FirstAidGuidesListScreen(),
              ],
            ),
            if (_showVoiceButton)
              Positioned(
                bottom: 20,
                left: 0,
                right: 0,
                child: VoiceDangerSignButton(
                  onDangerSignsDetected: _handleDetectedDangerSigns,
                ),
              ),
          ],
        ),

        drawer: Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              const DrawerHeader(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color(0xFF42A5F5),
                      Color.fromARGB(255, 6, 65, 124),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Image(image: AssetImage("images/image12.png")),
              ),
              const SizedBox(height: 40),
              ListTile(
                leading: Image(image: AssetImage("images/settings-gears.png")),
                title: const Text('Settings'),
                onTap: () {
                  // Handle settings tap
                  Navigator.pushNamed(context, '/settings');
                },
              ),
              const SizedBox(height: 40),
              ListTile(
                leading: Image(image: AssetImage("images/information.png")),
                title: const Text('About'),
                onTap: () {
                  // Handle about tap
                  Navigator.pop(context);
                },
              ),
              const SizedBox(height: 470),
              Center(
                child: Text(
                  "CHPS MaMaCare v1.0.0",
                  style: TextStyle(
                    color: Colors.black,
                    fontFamily: 'Montserrat',
                  ),
                ),
              ),
            ],
          ),
        ),

        // floatingActionButton: FloatingActionButton(
        //   onPressed: () {
        //     NotificationService().showInstantNotification();
        //   },
        //   child: const Icon(Icons.add),
        //   backgroundColor: AppColors.primary,
        // ),
        bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          currentIndex: _selectedIndex,
          onTap: (index) {
            setState(() {
              _selectedIndex = index;
              _pageController?.animateToPage(
                index,
                duration: const Duration(milliseconds: 300),
                curve: Curves.ease,
              );
            });
          },
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
            BottomNavigationBarItem(
              icon: Icon(Icons.folder_open),
              label: 'Patients',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.phone),
              label: 'Emergency',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.calendar_month),
              label: 'Appointments',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.healing),
              label: 'First Aid',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHomeContent() {
    return Column(
      children: [
        AppBar(
          automaticallyImplyLeading: false,
          title: const Text(
            "CHPS MamaCare",
            style: TextStyle(
              fontFamily: 'Montserrat',
              fontWeight: FontWeight.w500,
              fontSize: 21.0,
              letterSpacing: 0.4,
              color: Color.fromARGB(255, 255, 255, 255),
            ),
          ),
          centerTitle: false,
          elevation: 8,
          toolbarOpacity: 0.8,
          toolbarHeight: 70,
          actions: [
            IconButton(
              icon: Icon(
                _showVoiceButton ? Icons.mic_off : Icons.mic,
                size: 38.0,
              ),
              onPressed: () {
                setState(() {
                  _showVoiceButton = !_showVoiceButton;
                });
              },
            ),
            Builder(
              builder: (context) => Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: Material(
                  color: Colors.transparent,
                  shape: const CircleBorder(),
                  child: InkWell(
                    customBorder: const CircleBorder(),
                    onTap: () {
                      Scaffold.of(context).openDrawer();
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: SizedBox(
                        width: 45.0,
                        height: 45.0,
                        child: Image.asset(
                          "images/image12.png",
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        Expanded(
          child: RefreshIndicator(
            onRefresh: () async {
              _loadStats();
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Welcome section
                    const Text(
                      'Welcome',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    const SizedBox(height: 18),
                    // Dynamic greeting section inside a Card with image background
                    Builder(
                      builder: (context) {
                        final hour = TimeOfDay.now().hour;
                        String greeting = hour < 12
                            ? 'Good morning!'
                            : (hour < 17 ? 'Good afternoon!' : 'Good evening!');
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12.0),
                          child: Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 3,
                            clipBehavior: Clip.antiAlias,
                            child: Stack(
                              children: [
                                SizedBox(
                                  height: 128,
                                  width: double.infinity,
                                  child: StatefulBuilder(
                                    builder: (context, setCarouselState) {
                                      // Start the timer only once
                                      _carouselTimer ??= Timer.periodic(
                                        const Duration(seconds: 10),
                                        (timer) {
                                          setCarouselState(() {
                                            _currentCarouselIndex =
                                                (_currentCarouselIndex + 1) %
                                                _carouselImages.length;
                                          });
                                        },
                                      );
                                      return ClipRRect(
                                        borderRadius: BorderRadius.circular(16),
                                        child: Image.asset(
                                          _carouselImages[_currentCarouselIndex],
                                          fit: BoxFit.cover,
                                          alignment: Alignment.center,
                                        ),
                                      );
                                    },
                                  ),
                                ),
                                Container(
                                  height: 128,
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(0.40),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                                SizedBox(
                                  height: 128,
                                  width: double.infinity,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 18.0,
                                      vertical: 8.0,
                                    ),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          greeting,
                                          textAlign: TextAlign.left,
                                          style: const TextStyle(
                                            fontSize: 26,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.white,
                                            shadows: [
                                              Shadow(
                                                blurRadius: 8,
                                                color: Colors.black87,
                                                offset: Offset(1, 2),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        const Text(
                                          'Ready to care for your community today?',
                                          textAlign: TextAlign.left,
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w500,
                                            color: Colors.white,
                                            shadows: [
                                              Shadow(
                                                blurRadius: 8,
                                                color: Colors.black87,
                                                offset: Offset(1, 2),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 20),
                    // Statistics cards with individual background images/illustrations
                    Row(
                      children: [
                        Expanded(
                          child: StatsCard(
                            title: 'Total Records',
                            value: _stats['totalRecords']?.toString() ?? '0',
                            image: Image.asset('images/records.png'),
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: StatsCard(
                            title: 'Danger Signs',
                            value:
                                _stats['dangerSignRecords']?.toString() ?? '0',
                            image: Image.asset('images/warning.png'),
                            color: AppColors.danger,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: StatsCard(
                            title: 'Total Checkups',
                            value: _stats['totalCheckups']?.toString() ?? '0',
                            image: Image.asset('images/medical-checkup.png'),
                            color: AppColors.secondary,
                          ),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: StatsCard(
                            title: 'Appointments',
                            value: '0',
                            image: Image.asset('images/appointment.png'),
                            color: AppColors.accent,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 50),
                    // Quick actions
                    const Text(
                      'Quick Actions',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Action cards grid
                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 1.1,
                      children: [
                        HomeCard(
                          title: 'Add Pregnancy',
                          icon: Icons.pregnant_woman,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const AddRecordScreen(patientId: ''),
                              ),
                            ).then((_) => _loadStats());
                          },
                        ),
                        HomeCard(
                          title: 'Danger Sign Checklist',
                          icon: Icons.warning_amber_rounded,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const DangerSignsScreen(),
                              ),
                            );
                          },
                        ),
                        HomeCard(
                          title: 'View Records',
                          icon: Icons.folder_open,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const ViewRecordsScreen(),
                              ),
                            ).then((_) => _loadStats());
                          },
                        ),
                        HomeCard(
                          title: 'Emergency Referrals',
                          icon: Icons.local_hospital,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const EmergencyReferralScreen(),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    // Recent activity section
                    const Text(
                      'Recent Activity',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Recent records
                    _buildRecentActivity(),
                    // Extra space at bottom for voice button
                    if (_showVoiceButton) const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRecentActivity() {
    return FutureBuilder<List<PregnancyRecord>>(
      future: _databaseService.getAllPregnancyRecords(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final recentRecords = snapshot.data!.take(3).toList();
        if (recentRecords.isEmpty) {
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  Icon(Icons.inbox_outlined, size: 48, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'No records yet',
                    style: TextStyle(color: Colors.grey[600], fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Add your first pregnancy record to get started',
                    style: TextStyle(color: Colors.grey[500]),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        }
        return Column(
          children: recentRecords.map((record) {
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: AppColors.primary.withOpacity(0.1),
                  child: const Icon(
                    Icons.pregnant_woman,
                    color: AppColors.primary,
                  ),
                ),
                title: Text(record.motherName),
                subtitle: Text(
                  'Week ${record.currentWeek} • ${record.checkups.length} checkups',
                ),
                trailing: record.latestCheckup?.hasDangerSigns == true
                    ? const Icon(Icons.warning, color: AppColors.danger)
                    : const Icon(Icons.check_circle, color: AppColors.success),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          ViewRecordsScreen(initialRecordId: record.id),
                    ),
                  ).then((_) => _loadStats());
                },
              ),
            );
          }).toList(),
        );
      },
    );
  }
}
