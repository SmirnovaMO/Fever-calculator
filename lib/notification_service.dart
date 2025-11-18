import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';
import 'models/custom_medication.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();
  
  static Future<void> initialize() async {
    tz_data.initializeTimeZones();
    
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    
    const settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );
    
    await _notifications.initialize(settings);
    await _requestPermissions();
  }
  
  static Future<void> _requestPermissions() async {
    await _notifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
  }
  
  static Future<void> scheduleMedicationReminders(CustomMedication medication) async {
    if (!medication.hasReminders) return;
    
    for (int day = 0; day < medication.durationDays; day++) {
      for (int timeIndex = 0; timeIndex < medication.times.length; timeIndex++) {
        final time = medication.times[timeIndex];
        final scheduledDate = medication.startDate.add(Duration(days: day));
        final scheduledTime = DateTime(
          scheduledDate.year,
          scheduledDate.month,
          scheduledDate.day,
          time.hour,
          time.minute,
        );
        
        if (scheduledTime.isAfter(DateTime.now())) {
          final id = medication.name.hashCode + day * 100 + timeIndex;
          
          await _notifications.zonedSchedule(
            id,
            'Время принять лекарство',
            'Пора принять ${medication.name}',
            _convertToTZDateTime(scheduledTime),
            const NotificationDetails(
              android: AndroidNotificationDetails(
                'medication_channel',
                'Напоминания о лекарствах',
                channelDescription: 'Уведомления о времени приема лекарств',
                importance: Importance.high,
                priority: Priority.high,
              ),
              iOS: DarwinNotificationDetails(
                presentAlert: true,
                presentBadge: true,
                presentSound: true,
              ),
            ),
            androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
            uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
          );
        }
      }
    }
  }
  
  static tz.TZDateTime _convertToTZDateTime(DateTime dateTime) {
    return tz.TZDateTime.from(dateTime, tz.local);
  }
  
  static Future<void> cancelMedicationReminders(CustomMedication medication) async {
    for (int day = 0; day < medication.durationDays; day++) {
      for (int timeIndex = 0; timeIndex < medication.times.length; timeIndex++) {
        final id = medication.name.hashCode + day * 100 + timeIndex;
        await _notifications.cancel(id);
      }
    }
  }
}