import 'package:chpsmamacare_main01/main.dart';
import 'package:chpsmamacare_main01/screens/notification_detail_screen.dart';
import 'package:chpsmamacare_main01/utils/health_tips.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();

  factory NotificationService() => _instance;

  NotificationService._internal();

  final FlutterLocalNotificationsPlugin notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  // Handle notification tap
  void _handleNotificationTap(String payload) {
    final parts = payload.split('|');
    final title = parts[0];
    final body = parts[1];
    final image = parts.length > 2 ? parts[2] : null;

    navigatorKey.currentState?.push(
      MaterialPageRoute(
        builder: (_) => NotificationDetailScreen(
          title: title,
          body: body,
          imageAsset: image,
        ),
      ),
    );
  }

  // initialisation method form main.dart
  // This method should be called in the main function before running the app
  Future<void> init() async {
    tz.initializeTimeZones();

    tz.setLocalLocation(tz.getLocation('Africa/Accra'));

    // prepare android init settings
    const androidSettings = AndroidInitializationSettings('ic_notification');

    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings();

    const InitializationSettings initializationSettings =
        InitializationSettings(android: androidSettings, iOS: iosSettings);

    await notificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        if (response.payload != null) {
          final payload = response.payload!;
          // Navigate to detail screen
          _handleNotificationTap(payload);
        }
      },
    );
  }

  Future<void> scheduleDailyHealthTip({
    required int id,
    required String title,
    required String? body,
    String? imageAsset, // optional image asset for the notification
    required TimeOfDay timeOfDay,
  }) async {
    final now = tz.TZDateTime.now(tz.local);
    final scheduleDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      timeOfDay.hour,
      timeOfDay.minute,
    );

    final notificationTime = scheduleDate.isBefore(now)
        ? scheduleDate.add(const Duration(days: 1))
        : scheduleDate;

    // Use BigPictureStyleInformation with drawable resource
    final bigPictureStyle = imageAsset != null
        ? BigPictureStyleInformation(
            DrawableResourceAndroidBitmap(imageAsset),
            contentTitle: title,
            summaryText: body,
          )
        : null;

    await notificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      notificationTime,
      NotificationDetails(
        android: AndroidNotificationDetails(
          'daily_health_tips_channel_id',
          'Daily Health Tips',
          channelDescription: 'Channel for daily health tips',
          importance: Importance.max,
          priority: Priority.high,
          playSound: true,
          sound: const RawResourceAndroidNotificationSound('mama_alert'),
          icon: 'ic_notification',
          styleInformation: bigPictureStyle,
        ),
        iOS: const DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
      payload: '$title|$body|$imageAsset',
    );
  }

  void scheduleHealthTipNotifications() {
    final times = [
      const TimeOfDay(hour: 11, minute: 30),
      const TimeOfDay(hour: 12, minute: 10),
      const TimeOfDay(hour: 12, minute: 30),
      const TimeOfDay(hour: 1, minute: 10),
      const TimeOfDay(hour: 1, minute: 30),
    ];

    // Randomize or rotate tips
    final tips = List<HealthTip>.from(HealthTips.tips)..shuffle();

    for (int i = 0; i < times.length; i++) {
      final tip = tips[i % tips.length]; // in case tips < 5, wrap around
      NotificationService().scheduleDailyHealthTip(
        id: 100 + i,
        title: tip.title,
        imageAsset: tip.drawableName,
        body: tip.content,
        timeOfDay: times[i],
      );
    }
  }
}












































// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:timezone/timezone.dart' as tz;
// import 'package:timezone/data/latest.dart' as tz_data;
// import 'package:flutter/material.dart';
// // ignore: depend_on_referenced_packages
// import 'package:chpsmamacare_main01/models/appointment.dart';
// import 'package:chpsmamacare_main01/utils/health_tips.dart';
// import 'package:permission_handler/permission_handler.dart';
// import 'dart:math';

// class NotificationService {
//   static final NotificationService _instance = NotificationService._();
//   static NotificationService get instance => _instance;

//   final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
//       FlutterLocalNotificationsPlugin();

//   NotificationService._();

//   Future<void> initialize() async {
//     tz_data.initializeTimeZones();

//     const AndroidInitializationSettings androidSettings =
//         AndroidInitializationSettings('@mipmap/ic_launcher');


//     const DarwinInitializationSettings iosSettings =
//         DarwinInitializationSettings(
//           requestAlertPermission: true,
//           requestBadgePermission: true,
//           requestSoundPermission: true,
//         );

//     const InitializationSettings initSettings = InitializationSettings(
//       android: androidSettings,
//       iOS: iosSettings,
//     );

//     await _flutterLocalNotificationsPlugin.initialize(
//       initSettings,
//       onDidReceiveNotificationResponse: (NotificationResponse response) {
//         debugPrint('Notification clicked: ${response.payload}');
//         // Handle notification tap
//       },
//     );
//   }

//   //Request notification permissions
//   Future<bool> requestPermissions() async {
//     final status = await Permission.notification.status;

//     if (status.isGranted) {
//       return true;
//     } else {
//       final result = await Permission.notification.request();
//       return result.isGranted;
//     }
//   }

//   // Schedule daily health tip
//   Future<void> scheduleDailyHealthTip({
//     required TimeOfDay time,
//     required int id,
//   }) async {
//     final random = Random();
//     final healthTip = HealthTips.tips[random.nextInt(HealthTips.tips.length)];

//     final now = DateTime.now();
//     final scheduledTime = now.add(const Duration(minutes: 5));

//     final androidDetails = AndroidNotificationDetails(
//       'health_tips',
//       'Maternal Health Notifications',
//       channelDescription: 'Daily maternal health tips',
//       importance: Importance.max,
//       priority: Priority.high,
//       playSound: true,
//       sound: const RawResourceAndroidNotificationSound('mama_alert'),
//       styleInformation: BigTextStyleInformation(
//         '${healthTip.title}\n${healthTip.content}',
//       ),
//     );

//     const iosDetails = DarwinNotificationDetails(
//       //sound: 'notification_sound.aiff',
//       presentAlert: true,
//       presentBadge: true,
//       presentSound: true,
//     );

//     final platformDetails = NotificationDetails(
//       android: androidDetails,
//       iOS: iosDetails,
//     );

//     try {
//       await _flutterLocalNotificationsPlugin.zonedSchedule(
//         id,
//         'Maternal Health Tip',
//         healthTip.title,
//         tz.TZDateTime.from(scheduledTime, tz.local).add(Duration(minutes: 5)),
//         platformDetails,
//         androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
//         payload: 'health_tip_${healthTip.id}',
//         matchDateTimeComponents: DateTimeComponents.time,
//       );
//       debugPrint('✅ Notification scheduled successfully');
//     } catch (e, stack) {
//       debugPrint('❌ Failed to schedule notification: $e');
//       debugPrint(stack.toString());
//     }
//   }

//   Future<void> scheduleFiveDailyTips() async {
//     final times = [
//       TimeOfDay(hour: 9, minute: 00),
//       TimeOfDay(hour: 9, minute: 10),
//       TimeOfDay(hour: 9, minute: 20),
//       TimeOfDay(hour: 9, minute: 30),
//       TimeOfDay(hour: 9, minute: 35),
//     ];

//     for (int i = 0; i < times.length; i++) {
//       await scheduleDailyHealthTip(time: times[i], id: 100 + i);
//     }
//   }

//   // Schedule appointment reminder
//   Future<void> scheduleAppointmentReminder(Appointment appointment) async {
//     final androidDetails = AndroidNotificationDetails(
//       'appointments',
//       'Appointment Reminders',
//       channelDescription: 'Reminders for upcoming appointments',
//       importance: Importance.max,
//       priority: Priority.high,
//       sound: RawResourceAndroidNotificationSound(
//         appointment.soundFile ?? 'notification_sound',
//       ),
//     );

//     final iosDetails = DarwinNotificationDetails(
//       sound: '${appointment.soundFile ?? "notification_sound"}.aiff',
//       presentAlert: true,
//       presentBadge: true,
//       presentSound: true,
//     );

//     final platformDetails = NotificationDetails(
//       android: androidDetails,
//       iOS: iosDetails,
//     );

//     // Schedule for 1 day before
//     final reminderTime = appointment.dateTime.subtract(const Duration(days: 1));

//     await _flutterLocalNotificationsPlugin.zonedSchedule(
//       appointment.id.hashCode,
//       'Upcoming Appointment',
//       'Reminder: ${appointment.title} tomorrow at ${_formatTime(appointment.dateTime)}',
//       tz.TZDateTime.from(reminderTime, tz.local),
//       platformDetails,

//       androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
//       payload: 'appointment_${appointment.id}',
//     );

//     // Schedule for 1 hour before
//     final hourReminderTime = appointment.dateTime.subtract(
//       const Duration(hours: 1),
//     );

//     await _flutterLocalNotificationsPlugin.zonedSchedule(
//       appointment.id.hashCode + 1,
//       'Appointment Soon',
//       'Reminder: ${appointment.title} in 1 hour at ${_formatTime(appointment.dateTime)}',
//       tz.TZDateTime.from(hourReminderTime, tz.local),
//       platformDetails,

//       androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
//       payload: 'appointment_${appointment.id}_soon',
//     );
//   }

//   // Schedule pregnancy stage notification
//   Future<void> schedulePregnancyStageNotification({
//     required String motherName,
//     required int week,
//     required String stageInfo,
//     required DateTime notificationDate,
//   }) async {
//     final androidDetails = AndroidNotificationDetails(
//       'pregnancy_stages',
//       'Pregnancy Stage Updates',
//       channelDescription: 'Updates about pregnancy stages',
//       importance: Importance.high,
//       priority: Priority.high,
//       styleInformation: BigTextStyleInformation(stageInfo),
//     );

//     const iosDetails = DarwinNotificationDetails(
//       presentAlert: true,
//       presentBadge: true,
//       presentSound: true,
//     );

//     final platformDetails = NotificationDetails(
//       android: androidDetails,
//       iOS: iosDetails,
//     );

//     await _flutterLocalNotificationsPlugin.zonedSchedule(
//       motherName.hashCode + week,
//       'Pregnancy Update: Week $week',
//       '$motherName is now in week $week of pregnancy',
//       tz.TZDateTime.from(notificationDate, tz.local),
//       platformDetails,

//       androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
//       payload: 'pregnancy_stage_${motherName}_$week',
//     );
//   }

//   // Cancel a specific notification
//   Future<void> cancelNotification(int id) async {
//     await _flutterLocalNotificationsPlugin.cancel(id);
//   }

//   // Cancel all notifications
//   Future<void> cancelAllNotifications() async {
//     await _flutterLocalNotificationsPlugin.cancelAll();
//   }

//   Future<void> showScheduledTestNotification() async {
//     await _flutterLocalNotificationsPlugin.zonedSchedule(
//       1,
//       'Scheduled Notification',
//       'This notification was scheduled 5 seconds ago!',
//       tz.TZDateTime.now(tz.local).add(const Duration(seconds: 5)),
//       const NotificationDetails(
//         android: AndroidNotificationDetails(
//           'test_channel',
//           'Test Channel',
//           channelDescription: 'Channel for test notifications',
//           importance: Importance.max,
//           priority: Priority.high,
//         ),
//         iOS: DarwinNotificationDetails(),
//       ),
//       androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
//       payload: 'scheduled_test',
//       matchDateTimeComponents: DateTimeComponents.time, // optional
//     );
//   }

//   // Format time helper
//   String _formatTime(DateTime dateTime) {
//     final hour = dateTime.hour > 12 ? dateTime.hour - 12 : dateTime.hour;
//     final minute = dateTime.minute.toString().padLeft(2, '0');
//     final period = dateTime.hour >= 12 ? 'PM' : 'AM';
//     return '$hour:$minute $period';
//   }
// }

// 'health_tips',
//       'Maternal Health Notifications',
//       channelDescription: 'Daily maternal health tips',
//       importance: Importance.max,
//       priority: Priority.high,
//       playSound: true,
//       sound: const RawResourceAndroidNotificationSound('mama_alert'),
//       styleInformation: BigTextStyleInformation(
//         '${healthTip.title}\n${healthTip.content}',
