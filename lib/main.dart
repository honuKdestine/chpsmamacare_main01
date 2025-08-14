import 'package:chpsmamacare_main01/models/appointment.dart';
import 'package:chpsmamacare_main01/models/emergency_contact.dart';
import 'package:chpsmamacare_main01/models/pregnancy_record.dart';
import 'package:chpsmamacare_main01/screens/animated_splash_screen.dart';
import 'package:chpsmamacare_main01/services/notification_service.dart';
import 'package:chpsmamacare_main01/utils/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'firebase_options.dart';
import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Initialize Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Enable offline sync
  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: true,
    cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
);

  // final FirebaseFirestore firestore = FirebaseFirestore.instance;

  print("Starting CHPS MamaCare...");
  // Request notification permission early
  await requestNotificationPermission();

  try {
    // Initialize Hive for local storage
    await Hive.initFlutter();
    print("Hive Initialized");

    // Register Hive Adapters
    Hive.registerAdapter(PregnancyRecordAdapter());
    Hive.registerAdapter(CheckupRecordAdapter());
    Hive.registerAdapter(AppointmentAdapter());
    Hive.registerAdapter(EmergencyContactAdapter());
    print("Adapters registered");

    // Open Hive Boxes
    await Hive.openBox<PregnancyRecord>("pregnancy_records");
    await Hive.openBox<Appointment>("appointments");
    await Hive.openBox<EmergencyContact>("emergency_contacts");
    await Hive.openBox("app_settings");
    print("Boxes opened");

    // Initialize flutter local notifications
    await NotificationService().init();
    tz_data.initializeTimeZones();
    print("Notification service initialized");

    // Schedule daily health tips
    NotificationService().scheduleHealthTipNotifications();
    print("Daily health tip scheduled");

    // Request permissions
    await _requestPermissions();
  } catch (e) {
    print("Initialization error: $e");
  }

  runApp(const MyApp());
}

Future<void> _requestPermissions() async {
  // Request notification permissions
  await requestNotificationPermission();
  {
    // Request storage permission for file access
    await Permission.storage.request();
  }

  // Request microphone permission for speech recognition
  await Permission.microphone.request();

  // Request phone permission for making calls
  await Permission.phone.request();
}

// Request notification permission for Android 13+
Future<void> requestNotificationPermission() async {
  if (Platform.isAndroid) {
    final androidInfo = await DeviceInfoPlugin().androidInfo;
    if (androidInfo.version.sdkInt >= 33) {
      final status = await Permission.notification.request();
      print('Notification permission status: $status');
    }
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CHPS MamaCare',
      debugShowCheckedModeBanner: false,
      navigatorKey: navigatorKey,
      theme: AppTheme.lightTheme,
      home: const AnimatedSplashScreen(),
    );
  }
}
