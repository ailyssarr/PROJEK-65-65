// lib/services/notification_service.dart
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    // Konfigurasi Android
    const AndroidInitializationSettings androidInit =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // iOS bisa diabaikan, tapi kita inisialisasi default
    const DarwinInitializationSettings iosInit = DarwinInitializationSettings();

    const InitializationSettings initSettings =
        InitializationSettings(android: androidInit, iOS: iosInit);

    await _plugin.initialize(initSettings);

    // Minta izin notif (terutama Android 13+)
    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
  }

  /// Notif selamat datang setelah login
  static Future<void> showWelcomeNotification(String userName) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'foodmate_channel', // id channel
      'FoodMate Channel', // nama channel
      channelDescription: 'Notifikasi FoodMate',
      importance: Importance.high,
      priority: Priority.high,
    );

    const NotificationDetails notifDetails =
        NotificationDetails(android: androidDetails);

    await _plugin.show(
      0, // id notif
      'Selamat datang, $userName 👋',
      'Kamu berhasil login ke FoodMate. Yuk cari resep kesukaanmu!',
      notifDetails,
    );
  }
}
