import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;

  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      tz.initializeTimeZones();
    } catch (e) {
      debugPrint('Timezone init error: $e');
    }

    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notificationsPlugin.initialize(
      settings: initSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        debugPrint('Notification clicked: ${response.payload}');
      },
    );

    // Request permissions for Android 13+
    if (!kIsWeb && Platform.isAndroid) {
      final androidImplementation = _notificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();
      await androidImplementation?.requestNotificationsPermission();
    }

    _isInitialized = true;
  }

  NotificationDetails _notificationDetails({
    required String channelId,
    required String channelName,
    required String channelDescription,
  }) {
    final AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      channelId,
      channelName,
      channelDescription: channelDescription,
      importance: Importance.max,
      priority: Priority.high,
      showWhen: true,
      icon: '@mipmap/ic_launcher',
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    return NotificationDetails(android: androidDetails, iOS: iosDetails);
  }

  /// Sends an immediate notification upon registration confirmation
  Future<void> showRegistrationConfirmation({
    required String eventTitle,
    required DateTime eventDate,
    required String eventLocation,
  }) async {
    final formattedDate = DateFormat('MMM d, yyyy').format(eventDate);
    final details = _notificationDetails(
      channelId: 'event_registration_channel',
      channelName: 'Event Registrations',
      channelDescription: 'Notifications for student event registrations',
    );

    final notificationId = DateTime.now().millisecondsSinceEpoch ~/ 1000;

    await _notificationsPlugin.show(
      id: notificationId,
      title: '🎉 Registered: $eventTitle',
      body:
          'You are officially registered! Date: $formattedDate at $eventLocation. A reminder has been set.',
      notificationDetails: details,
      payload: eventTitle,
    );
  }

  /// Sends a cancellation notification
  Future<void> showCancellationNotice({
    required String eventTitle,
  }) async {
    final details = _notificationDetails(
      channelId: 'event_cancellation_channel',
      channelName: 'Event Cancellations',
      channelDescription: 'Notifications for registration cancellations',
    );

    final notificationId = DateTime.now().millisecondsSinceEpoch ~/ 1000;

    await _notificationsPlugin.show(
      id: notificationId,
      title: '❌ Registration Cancelled',
      body: 'Your registration for "$eventTitle" has been cancelled.',
      notificationDetails: details,
    );
  }

  /// Schedules a reminder notification before the event
  Future<void> scheduleEventReminder({
    required int notificationId,
    required String eventTitle,
    required DateTime eventDate,
    required String eventLocation,
  }) async {
    try {
      final scheduledTime = eventDate.subtract(const Duration(hours: 2));
      final now = DateTime.now();

      // Only schedule if reminder is in the future
      if (scheduledTime.isAfter(now)) {
        final tzScheduledTime = tz.TZDateTime.from(scheduledTime, tz.local);
        final details = _notificationDetails(
          channelId: 'event_reminder_channel',
          channelName: 'Event Reminders',
          channelDescription: 'Scheduled reminders before upcoming events',
        );

        await _notificationsPlugin.zonedSchedule(
          id: notificationId,
          scheduledDate: tzScheduledTime,
          notificationDetails: details,
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          title: '⏰ Event Reminder: $eventTitle',
          body: 'Starts in 2 hours at $eventLocation. Don\'t forget to attend!',
        );
      }
    } catch (e) {
      debugPrint('Error scheduling notification: $e');
    }
  }

  /// Cancels a scheduled reminder
  Future<void> cancelNotification(int id) async {
    await _notificationsPlugin.cancel(id: id);
  }
}
